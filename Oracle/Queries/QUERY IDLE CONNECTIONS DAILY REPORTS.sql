QUERY IDLE CONNECTIONS FROM BATCHES DAILY REPORTS + UNDO DATA

SELECT LPAD(s.sid || ',' || s.serial# || ',@' || s.inst_id, 17, ' ') AS sid_serial_inst
     , s.username
     , s.osuser
     , SUBSTR(s.machine, 1, 20) maq
     , SUBSTR(s.program, 1, 40) prg
     , s.service_name
     , TRUNC(ROUND(s.last_call_et) / 3600) || 'hrs ' ||
       TRUNC(MOD(s.last_call_et,3600) / 60) || 'mm ' ||
       TRUNC(MOD(MOD(s.last_call_et, 3600), 60)) || 'secs' min_idle_time
     , substr(s.event,1,40) evento
     , t.USED_UBLK "USED UNDO BLOCK"
     , t.used_urec "UNDO RECORDS"
  FROM gv$session s, gv$transaction t, dba_users u
 WHERE s.username = u.username
   AND s.SADDR=t.ses_addr
   AND s.inst_id=t.inst_id
   AND u.oracle_maintained = 'N'
   AND s.service_name LIKE '%BATCH%'
   AND s.last_call_et > 300
   AND s.status = 'INACTIVE'
 ORDER BY username, last_call_et DESC;
PROMPT NOTA: Revisar si hay eventos distintos a 'SQL*Net message from client'




alter session set nls_date_format='DD-MM HH24:MI:SS';
WITH cuando AS
  (SELECT /*+ MATERIALIZE */ dbid,snap_id, END_INTERVAL_TIME, instance_number
   FROM dba_hist_snapshot
   WHERE begin_interval_time BETWEEN TO_DATE('26-11-2020 05:00','DD-MM-YYYY HH24:MI')
                                AND TO_DATE('26-11-2020 10:00','DD-MM-YYYY HH24:MI')
  ), sqls AS
  (select /*+ MATERIALIZE PARALLEL (ash, 8) USE_HASH (ash c) */
          ash.sql_id, SAMPLE_TIME, event, SESSION_ID, SESSION_STATE, P1,P2,P3,TIME_WAITED,BLOCKING_SESSION, CURRENT_OBJ#
   from dba_hist_active_sess_history ash,
        cuando c
   where ash.snap_id=c.snap_id
     and ash.instance_number=c.instance_number
     and ash.dbid=c.dbid
     and CAST(ash.sample_time as DATE) >= to_date('26-11-2020 05:00','YYYY-MM-DD HH24:MI')
     and CAST(ash.sample_time as DATE) <= to_date('26-11-2020 10:00','YYYY-MM-DD HH24:MI')
   and event='enq: TX - row lock contention'
   and sql_id in ('&SQLID')
 )
Select to_char(SAMPLE_TIME,'dd-mm-yyyy hh24:mi') DATE_FORMAT, BLOCKING_SESSION bs, current_obj#,count (*)
from sqls
group by to_char(SAMPLE_TIME,'dd-mm-yyyy hh24:mi'), BLOCKING_SESSION
order by 1;







9ywfxxvs9b1nh

26-11-2020 05:00
26-11-2020 10:00





alter session set nls_date_format='DD-MM HH24:MI:SS';
WITH cuando AS
  (SELECT /*+ MATERIALIZE */ dbid,snap_id, END_INTERVAL_TIME, instance_number
   FROM dba_hist_snapshot
   WHERE begin_interval_time BETWEEN TO_DATE('26-11-2020 05:00','DD-MM-YYYY HH24:MI')
                                AND TO_DATE('26-11-2020 10:00','DD-MM-YYYY HH24:MI')
  ), sqls AS
  (select /*+ MATERIALIZE PARALLEL (ash, 8) USE_HASH (ash c) */
          ash.sql_id, SAMPLE_TIME, event, SESSION_ID, SESSION_STATE, P1,P2,P3,TIME_WAITED,BLOCKING_SESSION,  do.OBJECT_NAME
   from dba_hist_active_sess_history ash, dba_objects do,
        cuando c
   where ash.snap_id=c.snap_id
     AND ash.current_obj#=do.OBJECT_ID 
     and ash.instance_number=c.instance_number
     and ash.dbid=c.dbid
     and CAST(ash.sample_time as DATE) >= to_date('26-11-2020 05:00','DD-MM-YYYY HH24:MI')
     and CAST(ash.sample_time as DATE) <= to_date('26-11-2020 10:00','DD-MM-YYYY HH24:MI')
   --and event='enq: TX - row lock contention'
   and sql_id in ('9ywfxxvs9b1nh')
   and session_id=337
 )
Select to_char(SAMPLE_TIME,'dd-mm-yyyy hh24:mi') DATE_FORMAT, SESSION_ID, SESSION_STATE, SQL_ID, BLOCKING_SESSION bs,  OBJECT_NAME, event, count (*)
from sqls
group by to_char(SAMPLE_TIME,'dd-mm-yyyy hh24:mi'), SESSION_ID, SESSION_STATE, SQL_ID, BLOCKING_SESSION, OBJECT_NAME, event 
order by 1;

select
sfst.instance_number inst_id,
sqlfst.snap_id fsnap, 
to_char(sfst.END_INTERVAL_TIME, 'DD/MM/YY HH24:MI') fin,
sqlfst.PLAN_HASH_VALUE HASH,
--sqlfst.session_id SID,
SQLFST.EXECUTIONS_DELTA EXECUTIONS,
round(SQLFST.CPU_TIME_DELTA/1000000,3) "SS CPU", 
round(SQLFST.ELAPSED_TIME_DELTA/1000000,3) SC,
round (round(SQLFST.ELAPSED_TIME_DELTA/1000000,3)/(decode(SQLFST.EXECUTIONS_DELTA,0,1)),6) SC_per_EXEC,
sqlfst.DISK_READS_DELTA PHYSICAL_READS,
SQLFST.BUFFER_GETS_DELTA BUFFER_GETS
from DBA_HIST_SNAPSHOT sfst, DBA_HIST_SQLSTAT sqlfst
WHERE SQLFST.SQL_ID='9ywfxxvs9b1nh'
and sqlfst.snap_id=sfst.snap_id
and sfst.instance_number=sqlfst.instance_number
order by 2,1
/