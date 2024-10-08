WITH cuando AS
  (SELECT /*+ MATERIALIZE */ dbid,snap_id, begin_interval_time, instance_number
   FROM dba_hist_snapshot
   WHERE begin_interval_time BETWEEN trunc(sysdate-7)
                                AND sysdate       
  )
  ,app_users as
  (select USER_ID 
   from dba_users 
   where ORACLE_MAINTAINED <> 'Y' 
   and username not in ('QAPRO','AUDI')
  )
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
   GROUP BY st.sql_id, st.plan_hash_value),
   sql_online as
   (select /*+ MATERIALIZE  */ /*  PARALLEL (s, parallelism) */
          sql_id, PLAN_HASH_VALUE PHV, sum(executions) ej_onl, trunc( (sum(ELAPSED_TIME)/sum(executions) )/1000 ,2 ) Elap_x_ej_ms, 
          trunc(sum(BUFFER_GETS)/sum(executions) ) BG_x_ej
    from gv$sql s, app_users appu
    where executions > 0
      and PLAN_HASH_VALUE > 0
      and s.parsing_schema_id=appu.user_id
    group by sql_id, PLAN_HASH_VALUE
   ), planes as
   (select /*+ MATERIALIZE */ 
          sql_id, count(*) PHVs_onl
    from sql_online
    group by sql_id
   )
   /*,sql_noregistradas as -- queries que estan en la gv$sql pero no en el AWR
   (select sql_id
    from sql_online
    where Elap_x_ej_ms > 500  -- parametrizar este valor (ms)
    minus
    select sql_id
    from sqlids
   )*/
   ,awr_comparativa as
   (select /*+ MATERIALIZE use_hash (sq so) leading (sq so)*/ sq.sql_id, sq.plan_hash_value , to_char(sq.time_mcsecs) avg_ms_awr , so.Elap_x_ej_ms avg_ms_onl, so.Elap_x_ej_ms-sq.time_mcsecs diff_ms,
    --round(((so.Elap_x_ej_ms-sq.time_mcsecs)/so.Elap_x_ej_ms)*100,1) pct_diff
    round(((so.Elap_x_ej_ms-sq.time_mcsecs)/sq.time_mcsecs)*100,1) pct_diff
    , p.PHVs_onl, null ej_onl
    from sqlids sq, sql_online so, planes p 
    where sq.sql_id=so.sql_id
    and sq.sql_id=p.sql_id
    and sq.plan_hash_value = so.PHV
    and so.Elap_x_ej_ms>0
    and sq.time_mcsecs>0
   )
   ,diff_phv as 
   (
    select /*+ MATERIALIZE */ *
    from awr_comparativa
    where pct_diff>50
   )
   , sql_onl as
   (
    select /*+ MATERIALIZE use_hash (sq p) leading (sq p) */ sq.sql_id, sq.PHV , 'solo online' avg_ms_awr, 
    sq.Elap_x_ej_ms avg_ms_onl, null diff_ms, null pct_diff, p.PHVs_onl, ej_onl 
    from sql_online sq, planes p
    where sq.sql_id=p.sql_id
    and (   (Elap_x_ej_ms > 500 and ej_onl>10)
            or(Elap_x_ej_ms > 10000)
        )    
    -- parametrizar este valor (ms)
   )
   select * from diff_phv
   union all
   select * from sql_onl
   ;