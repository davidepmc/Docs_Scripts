WITH app_users as
  (select USER_ID 
   from dba_users 
   where ORACLE_MAINTAINED <> 'Y' 
   and username not in ('QAPRO','AUDI')
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
   , sql_onl as
   (
    select so.* 
    from  sql_online so, planes p
    where so.sql_id=p.sql_id
    and p.phvs_onl>1 
   )
 -- Recolectar los mejores planes del online por cada sqlid
   , best_phv_onl_0 as
   (
    select /*+ MATERIALIZE*/  so.sql_id, min(so.Elap_x_ej_ms) mintime
    from sql_onl so, planes p
    where so.sql_id=p.sql_id
    group by so.sql_id
   ) 
   -- Datos del mejor phv de cada sqlid de online
   , best_phv_onl as
   (
    select /*+ MATERIALIZE */ so.* 
    from sql_onl so, best_phv_onl_0 b
    where so.sql_id=b.sql_id
    and so.Elap_x_ej_ms=b.mintime
   )
   -- Diferencia entre phvs no conocidos y el mejor plan de la sql en AWR
   , diff_new_phv as
   (
    select /*+ MATERIALIZE use_hash (bpa) leading (pn so bpa)*/ so.sql_id, so.phv,  so.Elap_x_ej_ms,  
    so.Elap_x_ej_ms-bpo.Elap_x_ej_ms diff_ms,
        round(((so.Elap_x_ej_ms-bpo.Elap_x_ej_ms)/bpo.Elap_x_ej_ms)*100,1) pct_diff,
        so.ej_onl, decode (so.phv,bpo.phv,'este es el mejor plan','mejor phv '||bpo.PHV) comentario
    from  sql_onl so, best_phv_onl bpo
    where so.sql_id=bpo.sql_id
   )
select * from diff_new_phv
   where ej_onl>1
   and (pct_diff> 25 or pct_diff=0)
   -- hay que buscar filtros que relacionen
   -- num ejecuciones
   -- tiempo medio ms 
   --  diff_pct
   /*(   (Elap_x_ej_ms > 500 and ej_onl>10)
            or (Elap_x_ej_ms > 10000 and ej_onl>1)
            or (Elap_x_ej_ms > 60000)  */
order by 1,5 desc
;