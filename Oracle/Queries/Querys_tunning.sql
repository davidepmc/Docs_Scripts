-- CREATE SNAPSHOT AWR
-- Si es un RAC el snap se crea en todas las instancias.

BEGIN
DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT ();
END;
/


-- VISTA PARA VER EL DB_TIME  A FATAL DE CONSEGUIR EL WAIT TIME

select fst.snap_id, sst.snap_id, fst.stat_name, sst.value/1000000 - fst.value/1000000 CPU_TIME
from DBA_HIST_SYS_TIME_MODEL fst, DBA_HIST_SYS_TIME_MODEL sst
where  fst.STAT_NAME = 'DB CPU'
and fst.stat_name=sst.stat_name
and fst.snap_id=sst.snap_id-1
order by 1
/


######################################
##                                  ##
## QUERY PARA VER TOP 5 POR SNAP_ID ##
##                                  ##
######################################


---------
-- GLOBAL
---------


set pages 5000
set lines 250
col inicio for a25
col fin for a15
col event_name for a40
col class for a15
break on fsnap on ssnap on inicio on fin skip 1;

  select fsnap,
  ssnap,
  to_char(finterval, 'DD/MM/YY hh24:mi:ss') inicio,
  to_char(sinterval, 'hh24:mi:ss') fin,
  event_name, 
  class,
  round(total_wait,3) total_wait from
  (
    select fsnap,ssnap,finterval, sinterval, event_name, class, total_wait
    ,row_number() OVER (PARTITION BY fsnap ORDER BY  (total_wait) desc ) pos
      FROM (
      select fst.snap_id fsnap, 
      sst.snap_id ssnap,
      sfst.END_INTERVAL_TIME finterval,
      ssst.END_INTERVAL_TIME sinterval, 
      fst.event_name, 
      fst.wait_class class,
      (sst.TIME_WAITED_MICRO-fst.TIME_WAITED_MICRO)/1000000 total_wait
      from DBA_HIST_SYSTEM_EVENT fst, DBA_HIST_SYSTEM_EVENT sst, DBA_HIST_SNAPSHOT sfst, DBA_HIST_SNAPSHOT ssst
      where fst.event_name = sst.event_name
      and fst.WAIT_CLASS=sst.WAIT_CLASS
      and fst.WAIT_CLASS <> 'Idle'
      and fst.snap_id=sst.snap_id-1
      and fst.snap_id=sfst.snap_id
      and sst.snap_id=ssst.snap_id
      union
      select fst.snap_id, 
      sst.snap_id,
      sfst.END_INTERVAL_TIME, 
      ssst.END_INTERVAL_TIME, 
      fst.stat_name, 
      'SYS STAT' "class",
      (sst.value-fst.value)/1000000 CPU_TIME
      from DBA_HIST_SYS_TIME_MODEL fst, DBA_HIST_SYS_TIME_MODEL sst, DBA_HIST_SNAPSHOT sfst, DBA_HIST_SNAPSHOT ssst
      where  fst.STAT_NAME = 'DB CPU'
      and fst.stat_name=sst.stat_name
      and fst.snap_id=sst.snap_id-1
      and fst.snap_id=sfst.snap_id
      and sst.snap_id=ssst.snap_id
      order by 1
      )
  )
  WHERE pos <= 5
  order by 1,total_wait desc
/


---------
--POR DIA
---------


set pages 5000
set lines 250
col fin for a20
col inicio for a20
col event_name for a40
col class for a15
break on fsnap on ssnap on inicio on fin skip 1;

ACCEPT FECHA PROMPT 'Introduce el día a mostrar (DD/MM/YY):'

  select fsnap,
  ssnap,
  to_char(finterval, 'DD/MM/YY hh24:mi:ss') inicio,
  to_char(sinterval, 'hh24:mi:ss') fin,
  event_name, 
  class,
  round(total_wait,3) total_wait from
  (
    select fsnap,ssnap,finterval, sinterval, event_name, class, total_wait
    ,row_number() OVER (PARTITION BY fsnap ORDER BY  (total_wait) desc ) pos
      FROM (
      select fst.snap_id fsnap, 
      sst.snap_id ssnap,
      sfst.END_INTERVAL_TIME finterval,
      ssst.END_INTERVAL_TIME sinterval, 
      fst.event_name, 
      fst.wait_class class,
      (sst.TIME_WAITED_MICRO-fst.TIME_WAITED_MICRO)/1000000 total_wait
      from DBA_HIST_SYSTEM_EVENT fst, DBA_HIST_SYSTEM_EVENT sst, DBA_HIST_SNAPSHOT sfst, DBA_HIST_SNAPSHOT ssst
      where fst.event_name = sst.event_name
      and fst.WAIT_CLASS=sst.WAIT_CLASS
      and fst.WAIT_CLASS <> 'Idle'
      and fst.snap_id=sst.snap_id-1
      and fst.snap_id=sfst.snap_id
      and sst.snap_id=ssst.snap_id
      union
      select fst.snap_id, 
      sst.snap_id,
      sfst.END_INTERVAL_TIME, 
      ssst.END_INTERVAL_TIME, 
      fst.stat_name, 
      'SYS STAT' "class",
      (sst.value-fst.value)/1000000 CPU_TIME
      from DBA_HIST_SYS_TIME_MODEL fst, DBA_HIST_SYS_TIME_MODEL sst, DBA_HIST_SNAPSHOT sfst, DBA_HIST_SNAPSHOT ssst
      where  fst.STAT_NAME = 'DB CPU'
      and fst.stat_name=sst.stat_name
      and fst.snap_id=sst.snap_id-1
      and fst.snap_id=sfst.snap_id
      and sst.snap_id=ssst.snap_id
      order by 1
      )
  )
  WHERE pos <= 5
  and '&FECHA' = to_char(finterval, 'DD/MM/YY')
  order by 1,total_wait desc
/


#############################################
##                                         ##
## QUERY PARA VER EJECUCIONES POR QUERY    ##
##                                         ##
#############################################

------------------------
-- GLOBAL  TOP 5 POR DÍA
------------------------

set pages 5000
set lines 300
col inicio for a25
col fin for a10

break on fsnap on ssnap on fin skip 1;

UNDEF ORDENAR
ACCEPT ORDENAR PROMPT 'Introduce el campo a ordenar: EXECS|SS_CPU|SS|SC_per_EXEC|PHY_RDS|BUFF_GET|:   '

ACCEPT FECHA PROMPT 'Introduce el día a mostrar (DD/MM/YY):'

select fsnap, ssnap, inicio, fin, HASH, SQL_ID, EXECs, SS_CPU, SS, SC_per_EXEC, PHY_RDS, BUFF_GET
    FROM
    (
      select fsnap,ssnap,inicio, fin, HASH, SQL_ID, EXECS, SS_CPU, SS, SC_per_EXEC, PHY_RDS, BUFF_GET
      ,row_number() OVER (PARTITION BY fsnap ORDER BY  (&ORDENAR) desc ) pos
      FROM (
	    select 
	    sfst.snap_id-1 fsnap, 
	    sfst.snap_id ssnap,
	    to_char(sfst.BEGIN_INTERVAL_TIME, 'DD/MM/YY HH24:MI:SS') inicio,
	    to_char(sfst.END_INTERVAL_TIME, 'HH24:MI:SS') fin,
	    sqlfst.PLAN_HASH_VALUE HASH,
	    sqlfst.sql_id SQL_ID,
	    SQLFST.EXECUTIONS_DELTA EXECS,
	    round(SQLFST.CPU_TIME_DELTA/1000000,3) SS_CPU, 
	    round(SQLFST.ELAPSED_TIME_DELTA/1000000,3) SS,
	    round (round(SQLFST.ELAPSED_TIME_DELTA/1000000,3)/decode(SQLFST.EXECUTIONS_DELTA,0,1,SQLFST.EXECUTIONS_DELTA),6) SC_per_EXEC,
	    sqlfst.DISK_READS_DELTA PHY_RDS,
	    SQLFST.BUFFER_GETS_DELTA BUFF_GET
	    from DBA_HIST_SNAPSHOT sfst, DBA_HIST_SQLSTAT sqlfst
	    WHERE sqlfst.snap_id=sfst.snap_id
	    --and SQLFST.EXECUTIONS_DELTA > 0
	      and '&FECHA' = to_char(sfst.BEGIN_INTERVAL_TIME, 'DD/MM/YY')
	   )
      )
  WHERE pos <= 5
  order by fsnap, &ORDENAR desc
/


--------------------
-- Ver Procedures --
--------------------
set long 50000

select sql_text from v$sqltext where sql_id='&SQL_ID'
order by piece asc;


------------
--POR SQL_ID
------------

set pages 5000
set lines 250
col finterval for a25
col sinterval for a25
col event_name for a40
col class for a15
break on fsnap on ssnap on fin skip 1;

select 
sqlfst.snap_id fsnap, 
to_char(sfst.END_INTERVAL_TIME, 'DD/MM/YY HH24:MI:SS') fin,
sqlfst.PLAN_HASH_VALUE HASH,
SQLFST.EXECUTIONS_DELTA EXECUTIONS,
round(SQLFST.CPU_TIME_DELTA/1000000,3) "SS CPU", 
round(SQLFST.ELAPSED_TIME_DELTA/1000000,3) SC,
round (round(SQLFST.ELAPSED_TIME_DELTA/1000000,3)/(decode(SQLFST.EXECUTIONS_DELTA,0,1)),6) SC_per_EXEC,
sqlfst.DISK_READS_DELTA PHYSICAL_READS,
SQLFST.BUFFER_GETS_DELTA BUFFER_GETS
from DBA_HIST_SNAPSHOT sfst, DBA_HIST_SQLSTAT sqlfst
WHERE SQLFST.SQL_ID='&SQL_ID'
and sqlfst.snap_id=sfst.snap_id
order by 1
/

----------------
--POR HASH_VALUE
----------------

set pages 5000
set lines 250
col finterval for a25
col sinterval for a25
col event_name for a40
col class for a15
break on fsnap on ssnap on fin skip 1;

select 
sqlfst.snap_id snap, 
to_char(sfst.END_INTERVAL_TIME, 'DD/MM/YY HH24:MI:SS') fin,
sqlfst.PLAN_HASH_VALUE HASH,
SQLFST.EXECUTIONS_DELTA EXECUTIONS,
round(SQLFST.CPU_TIME_DELTA/1000000,3) "SS CPU", 
round(SQLFST.ELAPSED_TIME_DELTA/1000000,3) SC,
round (round(SQLFST.ELAPSED_TIME_DELTA/1000000,3)/SQLFST.EXECUTIONS_DELTA,6) SC_per_EXEC,
sqlfst.DISK_READS_DELTA PHYSICAL_READS,
SQLFST.BUFFER_GETS_DELTA BUFFER_GETS
from DBA_HIST_SNAPSHOT sfst, DBA_HIST_SQLSTAT sqlfst
WHERE sqlfst.PLAN_HASH_VALUE='&PLAN_HASH_VALUE'
and sqlfst.snap_id=sfst.snap_id
order by 1
/

*/


#################################################
##                                             ##
##  VER EXPLAIN PLAN POR HASH                  ##
##                                             ##
#################################################

--UNDEF SQL_ID
--ACCEPT SQL_ID PROMPT 'Introduce el SQL_ID de la query: '


--select distinct plan_hash_value from dba_hist_sqlstat where sql_id='&SQL_ID';

SELECT * FROM table (dbms_xplan.display_awr('&SQL_ID','&HASH'));





##################################################
##                                              ##
##    REPORTE EJECUCIONES QUERY POR SQL_ID      ##
##                                              ##
##################################################

break on fecha skip 1 on report
set lines 250
set pages 500
col inicio for a20
col prog for a40
col module for a40
clear compute
compute sum of "SS CPU" SC PHYSICAL_READS BUFFER_GETS on report

ACCEPT FECHA PROMPT 'Introduce el día a mostrar (DD/MM/YY):'

undef SQL_ID


select snap, inicio, prog, SQL_ID, exec, CPU, ELAP, PHY_RDS, BUFF_GET
from 
(
    select 
    sfst.snap_id-1 snap, 
    to_char(sfst.begin_INTERVAL_TIME, 'DD/MM/YY HH24:MI:SS') inicio,
    dhash.program prog,
    dhash.sql_id SQL_ID,
    SQLFST.EXECUTIONS_DELTA EXEC,
    round(SQLFST.CPU_TIME_DELTA/1000000,3) CPU, 
    round(SQLFST.ELAPSED_TIME_DELTA/1000000,3) ELAP,
    sqlfst.DISK_READS_DELTA PHY_RDS,
    SQLFST.BUFFER_GETS_DELTA BUFF_GET
    from DBA_HIST_SNAPSHOT sfst, DBA_HIST_SQLSTAT sqlfst, dba_hist_active_sess_history dhash
    where dhash.sql_id='&SQL_ID'
    and sfst.snap_id=dhash.snap_id
    and sqlfst.snap_id=sfst.snap_id
    and sqlfst.sql_id=dhash.sql_id
    --and '&FECHA' = to_char(sfst.end_INTERVAL_TIME, 'DD/MM/YY')
)
group by snap, inicio, prog, SQL_ID, exec, CPU,ELAP, PHY_RDS,BUFF_GET
order by 1
/

----------------------
-- FILTRO POR PROGRAMA
----------------------

break on fecha skip 1 on report
set lines 250
set pages 500
col fin for a18
col prog for a40
col module for a40
clear compute
compute sum of "SS CPU" SC PHYSICAL_READS BUFFER_GETS on report

ACCEPT FECHA PROMPT 'Introduce el día a mostrar (DD/MM/YY):'

undef SQL_ID


select fsnap, fin, prog, SQL_ID, exec, CPU, ELAP, PHY_RDS, BUFF_GET
from 
(
    select 
    sqlfst.snap_id fsnap, 
    to_char(sfst.END_INTERVAL_TIME, 'DD/MM/YY HH24:MI:SS') fin,
    dhash.program prog,
    dhash.sql_id SQL_ID,
    SQLFST.EXECUTIONS_DELTA EXEC,
    round(SQLFST.CPU_TIME_DELTA/1000000,3) CPU, 
    round(SQLFST.ELAPSED_TIME_DELTA/1000000,3) ELAP,
    sqlfst.DISK_READS_DELTA PHY_RDS,
    SQLFST.BUFFER_GETS_DELTA BUFF_GET
    from DBA_HIST_SNAPSHOT sfst, DBA_HIST_SQLSTAT sqlfst, dba_hist_active_sess_history dhash
    WHERE dhash.module like '&module%'
    and sqlfst.sql_id=dhash.sql_id
    and sqlfst.snap_id=dhash.snap_id
    and sqlfst.snap_id=sfst.snap_id
    and '&FECHA' = to_char(sfst.BEGIN_INTERVAL_TIME, 'DD/MM/YY')
)
group by fsnap, fin, prog, SQL_ID, exec, CPU,ELAP, PHY_RDS,BUFF_GET
order by 1
/


#############################################
##                                         ##
## QUERY PARA VER Nº EVENTOS ESPERA x SNAP ##
##                                         ##
#############################################




col fin for a30
col eve_name for a30
col prog for a50
set lines 300
break on fsnap on ssnap on inicio on fin skip 1;

ACCEPT FECHA PROMPT 'Introduce el día a mostrar (DD/MM/YY):'

  select fsnap, ssnap,  fin, sql_id, eve_name, num, prog
  from 
      (
      select fsnap, ssnap,  fin, sql_id, eve_name, num, prog,
      row_number() OVER (PARTITION BY fsnap ORDER BY  (num) desc ) pos
      from (
	    select dhsf.snap_id fsnap, 
	    dhss.snap_id ssnap, 
	    to_char (dhss.END_INTERVAL_TIME,'DD/MM/YY hh24:mi:ss') fin,
	    dbhash.sql_id sql_id,
	    --dbhash.hash,
	    dbhen.event_name eve_name,
	    dbhash.wait_class w_class,
	    count (event_name) num,
	    dbhash.program prog
	    from dba_hist_active_sess_history dbhash, dba_hist_event_name dbhen,DBA_HIST_SNAPSHOT dhsf, DBA_HIST_SNAPSHOT dhss
	    where dbhash.snap_id=dhsf.snap_id
	    and dhsf.snap_id=(dhss.snap_id-1)
	    and dbhash.program not like 'oracle@%'
	    and dbhash.event_id=dbhen.event_id
	    and '&FECHA'=to_char(dhss.END_INTERVAL_TIME, 'DD/MM/YY')              
	    group by dhsf.snap_id, dhss.snap_id,dhsf.END_INTERVAL_TIME, dhss.END_INTERVAL_TIME, dbhash.session_state, dbhash.sql_id, dbhen.event_name, dbhash.wait_class, dbhash.program
	    order by 1
	    )
      )
    WHERE pos <= 5
    order by 1,num desc
  /


--------------------------
-- FILTRADO POR EVENT_NAME
--------------------------

col fin cor a30
col eve_name for a30
col prog for a50
set lines 300
break on fsnap on ssnap on inicio on fin skip 1;

ACCEPT FECHA PROMPT 'Introduce el día a mostrar (DD/MM/YY): '
ACCEPT EVENTO PROMPT 'Introduce el evento a filtrar: '

select fsnap, ssnap,  fin, sql_id, eve_name, num, prog
from 
    (
    select fsnap, ssnap,  fin, sql_id, eve_name, num, prog,
    row_number() OVER (PARTITION BY fsnap ORDER BY  (num) desc ) pos
    from (
	  select dhsf.snap_id fsnap, 
	  dhss.snap_id ssnap, 
	  dhss.END_INTERVAL_TIME fin,
	  dbhash.sql_id sql_id,
	  --dbhash.hash,
	  dbhen.event_name eve_name,
	  dbhash.wait_class w_class,
	  count (event_name) num,
	  dbhash.program prog
	  from dba_hist_active_sess_history dbhash, dba_hist_event_name dbhen,DBA_HIST_SNAPSHOT dhsf, DBA_HIST_SNAPSHOT dhss
	  where dbhash.snap_id=dhsf.snap_id
	  and dhsf.snap_id=(dhss.snap_id-1)
	  and dbhash.program not like 'oracle@%'
	  and dbhash.event_id=dbhen.event_id
	  and dbhen.event_name='&EVENTO'
	  group by dhsf.snap_id, dhss.snap_id,dhsf.END_INTERVAL_TIME, dhss.END_INTERVAL_TIME, dbhash.session_state, dbhash.sql_id, dbhen.event_name, dbhash.wait_class, dbhash.program
	  order by 1
	  )
    )
  WHERE pos <= 5
  and '&FECHA' = to_char(fin, 'DD/MM/YY')
  order by 1,num desc
/



#############################################
##                                         ##
##    QUERYS CON DIFERENTES HASH_VALUE     ##
##                                         ##
#############################################

set pages 5000
set lines 300
col inicio for a25
col fin for a10

break on sql_id skip 1;





      select  SQL_ID, HASH , sum(EXECS),sum(SS), ROUND(AVG(SC_EXEC),6), min(inicio) "1 exec"
      FROM (
	    select 
	    to_char(sfst.BEGIN_INTERVAL_TIME, 'DD/MM/YY hh24:mi:ss') inicio,
	    sqlfst1.PLAN_HASH_VALUE HASH,
	    sqlfst1.sql_id SQL_ID,
	    SQLFST1.EXECUTIONS_DELTA EXECS,
	    round(sqlfst1.ELAPSED_TIME_DELTA/1000000,3) SS,
	    round (round(SQLFST1.ELAPSED_TIME_TOTAL/1000000,3)/decode(SQLFST1.EXECUTIONS_TOTAL,0,1,SQLFST1.EXECUTIONS_TOTAL),6) SC_EXEC
	    from DBA_HIST_SNAPSHOT sfst, DBA_HIST_SQLSTAT sqlfst1, DBA_HIST_SQLSTAT sqlsst2
	    WHERE sqlfst1.snap_id=sfst.snap_id
	    and sqlfst1.sql_id=sqlsst2.sql_id
		--and sqlfst1.sql_id='cnypy80x7q581'
	    and sqlfst1.plan_hash_value <> sqlsst2.plan_hash_value
	    )
	    group by SQL_ID, HASH, inicio
	    order by sql_id, hash
/


---------------------
-- FILTRO POR SQL_ID
---------------------

set pages 5000
set lines 300
col inicio for a25
col fin for a10

break on sql_id skip 1;




      select  SQL_ID, HASH , sum(EXECS) EXECS,sum(SS) SS, ROUND(AVG(SC_EXEC),6) SC_EXEC, min(inicio) "1 exec"
      FROM (
	    select 
	    to_char(sfst.BEGIN_INTERVAL_TIME, 'DD/MM/YY hh24:mi:ss') inicio,
	    sqlfst1.PLAN_HASH_VALUE HASH,
	    sqlfst1.sql_id SQL_ID,
	    SQLFST1.EXECUTIONS_DELTA EXECS,
	    round(sqlfst1.ELAPSED_TIME_DELTA/1000000,3) SS,
	    round (round(SQLFST1.ELAPSED_TIME_TOTAL/1000000,3)/decode(SQLFST1.EXECUTIONS_TOTAL,0,1,SQLFST1.EXECUTIONS_TOTAL),6) SC_EXEC
	    from DBA_HIST_SNAPSHOT sfst, DBA_HIST_SQLSTAT sqlfst1, DBA_HIST_SQLSTAT sqlsst2
	    WHERE sqlfst1.snap_id=sfst.snap_id
	    and sqlfst1.sql_id=sqlsst2.sql_id
	    and sqlfst1.plan_hash_value <> sqlsst2.plan_hash_value
	    )
	    WHERE SQL_ID='&SQL_ID'
	    group by SQL_ID, HASH, inicio
	    order by  sql_id, hash
/


--------------------
-- Ver sesiones
--------------------

set lines 200 pages 5000

col begin_interval_time for a25
col end_interval_time for a25
col program for a 30
	
alter session set nls_date_format = 'DD/MM/YYYY hh24:mi:ss';

select sn.begin_interval_time, sn.end_interval_time, ss.SESSION_ID, ss.USER_ID, ss.SQL_ID, ss.program 
from DBA_HIST_ACTIVE_SESS_HISTORY ss, DBA_HIST_SNAPSHOT sn 
where sn.snap_id=ss.snap_id
--and sn.BEGIN_INTERVAL_TIME > '18/04/11'
--and sn.end_interval_time < '20/04/11'
and ss.SQL_ID='&SQL_ID'
order by 1
/



#########################################################################################################################################
#																																		#
######################################          		QUERYS PARA RAC				#################################
#																																		#
#########################################################################################################################################



-------------------------------------------------------------------------------------
--
--            Estimated top 5 - over last 30s per instance (EVENT DIMESION)
--
-------------------------------------------------------------------------------------
break on inst_id skip page 
COMPUTE SUM OF sess_count ON inst_id
set linesize 200
col event for a48 trun

SELECT
inst_id,
event,
sess_count
FROM
    (SELECT 
    inst_id,
    event,
    sess_count,
    row_number() OVER (PARTITION BY inst_id ORDER BY sess_count desc) ord
    FROM
        (SELECT
        inst_id,
        NVL(EVENT,'ON_CPU') event,
        count(1) sess_count
        FROM gV$ACTIVE_SESSION_HISTORY
        WHERE SAMPLE_TIME > (sysdate-30/(3600*24))
        group by inst_id ,NVL(EVENT,'ON_CPU')))
WHERE ord <=5
order by inst_id,sess_count desc;

-------------------------------------------------------------------------------------
--
--            TOP SQL consumer in the last 30s (SQL_ID dimension)
--
-------------------------------------------------------------------------------------
break on inst_id skip page 
COMPUTE SUM OF sess_count ON inst_id
col "Total (distinct)" for a16
col "SQL_ID (PLAN_HASH)" for a32

SELECT
inst_id,
sql_id || ' (' || SQL_PLAN_HASH_VALUE || ')' "SQL_ID (PLAN_HASH)",
LPAD (total || ' (' || dist_sess || ')',10,' ') "Total (distinct)",
ON_CPU,
WAITING
FROM (
    SELECT
    inst_id,
    sql_id,
    SQL_PLAN_HASH_VALUE,
    total,
    dist_sess,
    ON_CPU,
    WAITING,
    row_number() OVER (PARTITION BY inst_id ORDER BY total desc) ord
    FROM
        (SELECT
        inst_id,
        sql_id,
        SQL_PLAN_HASH_VALUE,
        count(1) total,
        count(distinct session_id) dist_sess,
        sum(decode(SESSION_STATE,'ON CPU',1,0)) ON_CPU,
        sum(decode(SESSION_STATE,'WAITING',1,0)) WAITING
        FROM gV$ACTIVE_SESSION_HISTORY
        WHERE SAMPLE_TIME > (sysdate-30/(3600*24)) 
        AND SESSION_TYPE = 'FOREGROUND'
        GROUP BY inst_id ,sql_id,SQL_PLAN_HASH_VALUE))
WHERE ord < 6;


-------------------------------------------------------------------------------------
--
--            TOP 5 Events by SQL_ID in the last 30s
--
-------------------------------------------------------------------------------------

break on inst_id skip page on SQL_ID_TOT_DIST skip 1
col SQL_ID_TOT_DIST for a32 trun
col total noprint

WITH top_sql as
(SELECT
inst_id, sql_id ,total,dist_sess
FROM
    (SELECT 
    inst_id,sql_id,total,dist_sess,
    row_number() OVER (PARTITION BY inst_id ORDER BY total DESC) ord
    FROM 
            (SELECT
            inst_id,
            sql_id,
            count(1) total,
            count(distinct session_id) dist_sess
            FROM gV$ACTIVE_SESSION_HISTORY
            WHERE  SESSION_TYPE = 'FOREGROUND'
            AND SAMPLE_TIME > (sysdate-30/(3600*24)) 
            GROUP BY inst_id,sql_id))
WHERE ord < 6)
SELECT 
inst_id,
total,
sql_id || ' - ' || total || ' (' || dist_sess ||')' sql_id_tot_dist,
event,event_count
FROM
    (SELECT
    inst_id,sql_id,total,dist_sess,event,event_count,
    row_number() OVER (PARTITION BY inst_id,sql_id ORDER BY event_count DESC) event_ord
    FROM
        (SELECT 
        vash.inst_id,
        vash.sql_id,
        nvl(vash.event,'CPU') event,
        ts.total,
        ts.dist_sess,
        count(1)  event_count
        FROM top_sql  ts,
             gV$ACTIVE_SESSION_HISTORY vash
        WHERE  
         ts.sql_id = vash.sql_id
        AND ts.inst_id = vash.inst_id
        AND SESSION_TYPE = 'FOREGROUND'
        AND vash.SAMPLE_TIME > (sysdate-30/(3600*24)) 
        GROUP BY vash.inst_id,vash.sql_id,vash.event,ts.total,ts.dist_sess))
WHERE event_ord < 6
order by inst_id,total desc ,event_count desc ;

-------------------------------------------------------------------------------------
--
--            Top FOREGROUND SESSIONS in the last 30s (session dimension) 
--
-------------------------------------------------------------------------------------

break on inst_id skip page 
COMPUTE SUM OF sess_count ON inst_id
col session_info for a40 trun


SELECT
inst_id,
nvl((SELECT SID || '(' || osuser || ' - ' || program || ')'  
    FROM GV$SESSION gvs 
    WHERE gvs.sid = SESSION_ID and SESSION_SERIAL# = SERIAL# 
    AND gvs.inst_id =  inst_id),'### DISCONNECTED ###') session_info,
total,
ON_CPU,
WAITING
FROM (
    SELECT
    inst_id,
    SESSION_ID,
    SESSION_SERIAL#,
    total,
    ON_CPU,
    WAITING,
    row_number() OVER (PARTITION BY inst_id ORDER BY total desc) ord
    FROM
        (SELECT
        inst_id,
        SESSION_ID,
        SESSION_SERIAL#,
        count(1) total,
        sum(decode(SESSION_STATE,'ON CPU',1,0)) ON_CPU,
        sum(decode(SESSION_STATE,'WAITING',1,0)) WAITING
        FROM gV$ACTIVE_SESSION_HISTORY
        WHERE SAMPLE_TIME > (sysdate-30/(3600*24))
        AND SESSION_TYPE = 'FOREGROUND'
        GROUP BY inst_id ,SESSION_ID,SESSION_SERIAL#))
WHERE ord < 6;
----------------------------------------------------------------
--
--            Top background SESSIONS in the last 30s (session dimension) 
--
-------------------------------------------------------------------------------------

break on inst_id skip page 
COMPUTE SUM OF sess_count ON inst_id
col session_info for a40 trun


SELECT
inst_id,
nvl((SELECT SID || '(' || osuser || ' - ' || program || ')'  
    FROM GV$SESSION gvs 
    WHERE gvs.sid = SESSION_ID and SESSION_SERIAL# = SERIAL# 
    AND gvs.inst_id =  inst_id and rownum <= 1),'### DISCONNECTED ###') session_info,
total,
ON_CPU,
WAITING
FROM (
    SELECT
    inst_id,
    SESSION_ID,
    SESSION_SERIAL#,
    total,
    ON_CPU,
    WAITING,
    row_number() OVER (PARTITION BY inst_id ORDER BY total desc) ord
    FROM
        (SELECT
        inst_id,
        SESSION_ID,
        SESSION_SERIAL#,
        count(1) total,
        sum(decode(SESSION_STATE,'ON CPU',1,0)) ON_CPU,
        sum(decode(SESSION_STATE,'WAITING',1,0)) WAITING
        FROM gV$ACTIVE_SESSION_HISTORY
        WHERE SAMPLE_TIME > (sysdate-30/(3600*24))
        AND SESSION_TYPE = 'BACKGROUND'
        GROUP BY inst_id ,SESSION_ID,SESSION_SERIAL#))
WHERE ord < 6;




-------------------------------------------------------------------------------------
--
--             CLUSTER WAITS by object and sql_id
--
-------------------------------------------------------------------------------------
break on inst_id skip page 
COMPUTE SUM OF sess_count ON inst_id    
col object for a42 trun
col event for a32 trun 

SELECT
inst_id,
sql_id,
plan_hash_value,
object,
sess_count,
dis_sess_count
FROM
    (SELECT
    inst_id,
    sql_id,
    plan_hash_value,
    object,
    sess_count,
    dis_sess_count,
    row_number() OVER (PARTITION BY inst_id ORDER BY sess_count desc) ord
    FROM
        (select  inst_id,sql_id,sql_plan_hash_value plan_hash_value,
                (select  object_name || ' (' || object_type || ')'
                from  dba_objects where object_id = CURRENT_OBJ#) object
                ,count(1) sess_count, count(distinct session_id) dis_sess_count
        from GV$ACTIVE_SESSION_HISTORY
        where  WAIT_CLASS = 'Cluster'
        and SAMPLE_TIME >= (sysdate-30/(3600*24))
        group by inst_id,sql_id,sql_plan_hash_value, CURRENT_OBJ#))
WHERE ord <=5
order by 1, sess_count desc 
/




