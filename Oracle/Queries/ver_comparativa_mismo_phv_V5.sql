WITH cuando AS
  (SELECT /*+ MATERIALIZE */ dbid,snap_id, begin_interval_time, instance_number
   FROM dba_hist_snapshot
   WHERE begin_interval_time BETWEEN trunc(sysdate-7)
                                AND sysdate       
  )
  -- Usuarios de aplicacion
  ,app_users as
  (select USER_ID 
   from dba_users 
   where ORACLE_MAINTAINED <> 'Y' 
   and username not in ('QAPRO','AUDI')
  )
  -- Estadisticas SQL en AWR
  ,sqlids AS
 (SELECT /*+ MATERIALIZE */ -- para tratar la query como una vista materializada
   st.sql_id
  ,st.plan_hash_value
  ,SUM(st.ELAPSED_TIME_DELTA)/1000 time_mcsecs
  ,SUM(st.executions_delta) ejecs
    FROM dba_hist_sqlstat st, cuando c
   WHERE st.snap_id = c.snap_id
     AND st.dbid = c.dbid
     AND st.instance_number = c.instance_number
     AND plan_hash_value > 0  -->> para quitar los inserts 
  --AND st.sql_id NOT IN ('') -->> Filtro para blackout de SQL_IDs
   GROUP BY st.sql_id, st.plan_hash_value
   )
   -- SQLs online con sus estadisticas (aparecen en gv$sql)
   ,sql_online as
   (select /*+ MATERIALIZE  */ /*  PARALLEL (s, parallelism) */
          sql_id, PLAN_HASH_VALUE PHV, sum(executions) ej_onl, trunc( (sum(ELAPSED_TIME)/sum(executions) )/1000 ,2 ) Elap_x_ej_ms, 
          trunc(sum(BUFFER_GETS)/sum(executions) ) BG_x_ej
    from gv$sql s, app_users appu
    where executions > 0
      and PLAN_HASH_VALUE > 0
      and s.parsing_schema_id=appu.user_id
    group by sql_id, PLAN_HASH_VALUE
   )
   -- num de planes por SQL Online
   , planes as
   (select /*+ MATERIALIZE */ 
          sql_id, count(*) PHVs_onl
    from sql_online
    group by sql_id
   )
   -- sqls que estan en la gv$sql pero no en el AWR
   ,sql_noregistradas as
    (
    select /*+ MATERIALIZE */ so.sql_id
    from sql_online so
    minus
    select sq.sql_id
    from sqlids sq
   )
   -- planes que estan en la gv$sql pero no en el AWR
   ,phv_noregistradas as 
   (select /*+ MATERIALIZE */ so.sql_id, so.phv
    from sql_online so,sql_noregistradas snr
    where (   (so.Elap_x_ej_ms > 500 and so.ej_onl>10)
              or(so.Elap_x_ej_ms > 10000)
          )  -- parametrizar este valores (ms y ejecuciones)
    and
    so.sql_id=snr.sql_id
   )
   -- comparativa de phv que existe en AWR para ver las que se comportan mal con el mismo plan
   ,awr_comparativa as
   (select /*+ MATERIALIZE use_hash (sq so) leading (sq so)*/ sq.sql_id, sq.plan_hash_value , to_char(sq.time_mcsecs) avg_ms_awr 
   , so.Elap_x_ej_ms avg_ms_onl, so.Elap_x_ej_ms-sq.time_mcsecs diff_ms,
    --round(((so.Elap_x_ej_ms-sq.time_mcsecs)/so.Elap_x_ej_ms)*100,1) pct_diff
    round(((so.Elap_x_ej_ms-sq.time_mcsecs)/sq.time_mcsecs)*100,1) pct_diff
    , p.PHVs_onl, so.ej_onl, 'mismo phv en awr' comentario
    from sqlids sq, sql_online so, planes p 
    where sq.sql_id=so.sql_id
    and sq.sql_id=p.sql_id
    and sq.plan_hash_value = so.PHV
    and so.Elap_x_ej_ms>0
    and sq.time_mcsecs>0
   )
   -- Diferencia de rendimiento entre los PHVs conocidos 
   ,diff_phv as 
   (
    select /*+ MATERIALIZE */ *
    from awr_comparativa
    where pct_diff>50
   )
   -- Filtrar los sql_online que nos interesan por tiempo y ejecuciones
   , sql_onl as
   (
    select /*+ MATERIALIZE use_hash (sq p) leading (sq p) */ sq.sql_id, sq.PHV , 'solo online' avg_ms_awr, 
    sq.Elap_x_ej_ms avg_ms_onl, null diff_ms, null pct_diff, p.PHVs_onl, ej_onl , 'phv solo onl' comentario
    from sql_online sq, planes p
    where sq.sql_id=p.sql_id
    and (   (Elap_x_ej_ms > 500 and ej_onl>10)
            or(Elap_x_ej_ms > 10000)
        )
    -- parametrizar este valor (ms)
   )
   -- Recolectar los mejores planes del AWR por cada sqlid
   , best_phv_awr_0 as
   (
    select /*+ MATERIALIZE*/  sq.sql_id, min(sq.time_mcsecs) mintime
    from sqlids sq, planes p
    where sq.sql_id=p.sql_id
    group by sq.sql_id
   ) 
   -- Datos del mejor phv de cada sqlid de AWR
   , best_phv_awr as
   (
    select /*+ MATERIALIZE */ sq.* 
    from sqlids sq, best_phv_awr_0 b
    where sq.sql_id=b.sql_id
    and sq.time_mcsecs=b.mintime
   )
   -- Diferencia entre phvs no conocidos y el mejor plan de la sql en AWR
   , diff_new_phv as
   (
    select /*+ MATERIALIZE use_hash (bpa) leading (pn so bpa)*/ pn.sql_id, pn.phv, to_char(bpa.time_mcsecs), so.Elap_x_ej_ms,  
    so.Elap_x_ej_ms-bpa.time_mcsecs diff_ms,
        round(((so.Elap_x_ej_ms-bpa.time_mcsecs)/bpa.time_mcsecs)*100,1) pct_diff,p.PHVs_onl, 
        so.ej_onl, 'mejor phv '||bpa.plan_hash_value comentario
    from phv_noregistradas pn, best_phv_awr bpa, sql_online so, planes p
    where pn.sql_id=bpa.sql_id
    and so.sql_id=pn.sql_id
    and so.phv=pn.phv
    and so.sql_id=p.sql_id
   )
select * from diff_phv
union all
select * from sql_onl
union all
select * from diff_new_phv
order by 
    1,2
;