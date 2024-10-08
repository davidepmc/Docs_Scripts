################################################################
##
##		Live Monitoring 
##
################################################################

-------------------------------------------------------------------------------------
--
--             Waiting sessions
--
-------------------------------------------------------------------------------------

set linesize 130
col event for a305390320300
col osuser for a20
col program for a10
set pages 2000

select vs.sid,sw.EVENT,vs.osuser,substr(program,1,10) program,sw.state,sql_hash_value
from v$session_wait sw, v$session vs
where sw.event not like 'SQL%' 
and sw.event not in 
('jobq slave wait','queue messages','rdbms ipc message',
'PL/SQL lock timer','smon timer','pmon timer','wakeup time manager') 
and vs.sid=sw.sid
order by state desc;


-------------------------------------------------------------------------------------
--
--             Waiting sessions ++
--
-------------------------------------------------------------------------------------

col sid for 9999
set linesize 130
col event for a30
col osuser for a20
col program for a10
set pages 2000
col time 99.99
break on state skip page
col state for a5

select DECODE(sw.state,'WAITED KNOWN TIME','WKT','WAITING','WAIT','WAITED SHORT TIME','WST') state,
vs.sid,sw.EVENT,vs.osuser,substr(program,1,10) program,sql_id
from v$session_wait sw, v$session vs
where sw.wait_class <> 'Idle'
and sw.event not like 'SQL%'
and vs.sid=sw.sid
order by state,program ASc;


-------------------------------------------------------------------------------------
--
--             Sessions Waiting for Latches
--
-------------------------------------------------------------------------------------
set linesize 130
col event for a30
col osuser for a20
col program for a10
set pages 2000

select vs.sid,sw.EVENT,vs.osuser,substr(vs.program,1,10) program,la.name,gets,misses,sleeps
from v$session_wait sw, v$session vs, v$latch la
where sw.event not like 'SQL%'
and sw.event like 'latch%'
and vs.sid=sw.sid
and  sw.p2 = la.LATCH#
order by sw.state desc;



-------------------------------------------------------------------------------------
--
--             Monitor 1 session events
--
-------------------------------------------------------------------------------------

set linesize 130
col event for a30
col osuser for a20
col program for a10
set pages 2000

---- Run the Accep line only to put the number of the sid

ACCEPT SSID  PROMPT 'SID to monitor  -> '

---- Run the query as many times as you need

select vs.sid,sw.EVENT,vs.osuser,substr(program,1,10) program,sw.state,sql_id,sw.SECONDS_IN_WAIT
from v$session_wait sw, v$session vs
where vs.sid=sw.sid
and vs.sid=&SSID
order by state desc;



-------------------------------------------------------------------------------------
--
--             TOP Events for  1 session events
--
-------------------------------------------------------------------------------------

col name for a40
col class for a15
set linesize 100

SELECT s.* , ROW_NUMBER()  OVER (ORDER BY time_s desc ) "order" 
FROM (
SELECT STAT_NAME NAME,'SYS STAT' CLASS ,round(value/1000000,1) time_s,0 avg_ms
FROM v$sess_time_model
WHERE SID = &SID
AND stat_name = 'DB CPU'
UNION ALL
SELECT  EVENT,wait_class,round(TIME_WAITED_MICRO/1000000,1) time_s ,round((TIME_WAITED_MICRO/1000)/TOTAL_WAITS,1) avg_ms
FROM V$SESSION_EVENT
WHERE SID = &SID
AND TOTAL_WAITS <> 0 ) s
.

ACCEPT SID  PROMPT 'SID for TOP EVENTS -> '


-------------------------------------------------------------------------------------
--
--             Enqueues Wait detail - Details (user and object info) for Enqueues
--
-------------------------------------------------------------------------------------


col object for a30
col owner for a20
set linesize 150
set pages 2000
col osuser for a20
col program for a10

SELECT 
sid,
vs.osuser,
substr(program,1,10) program,
owner || '.' || object_name || '(' || object_type || ')' "Object",
ROW_WAIT_BLOCK#,
ROW_WAIT_ROW#  
FROM v$session vs, dba_objects do
where 
do.object_id = vs.ROW_WAIT_OBJ#
and sid in (
SELECT sw.sid from  v$session_wait sw
where sw.event like 'enq:%');


-------------------------------------------------------------------------------------
--
--             V$SESSION_LONGOPS 
--
-------------------------------------------------------------------------------------


RMAN RESTORE PROCESS

col opname for a30
col target for a10
set linesize 120
alter session set nls_date_format='dd/mm/yy hh24:mi';

select opname,target,sid,serial#,ELAPSED_SECONDS,round((sofar*100)/totalwork) "%done",
sysdate + TIME_REMAINING/3600/24 end_at
from gv$session_longops
where time_remaining > 0
AND opname like 'RMAN%'
order by start_time desc;




set linesize 200
col SID for 999999
col opname for a20
col target for a40
col username for a12
col elapsed_seconds for 99999
col time_remaining for 99999
col "COMPLETE %" for 999.99
col sql_id for a18


select SID, serial#,OPNAME,TARGET,USERNAME,ELAPSED_SECONDS,TIME_REMAINING,
      (ELAPSED_SECONDS*100/(ELAPSED_SECONDS+TIME_REMAINING)) "COMPLETE %", SQL_ADDRESS
from V$SESSION_LONGOPS
where time_remaining>0;


-------------------------------------------------------------------------------------
--
--             ACtive sessions --- solo para 10g (hermoso query)
--
------------------------------------------------------------------------------------

col username for a20
col osuser for a20
set pages 2000
set linesize 200
break on Timestamp skip 1

select to_char(sesh.sample_time,'hh24:mi:ss') "Timestamp" ,
sesh.session_id,
sesh.SQL_ID,
sesh.session_state,
ses.username,ses.osuser
from V$ACTIVE_SESSION_HISTORY sesh ,v$session ses
where ses.sid = sesh.session_id
and  SAMPLE_TIME > sysdate - 1/(10*(24*60))
and session_type = 'FOREGROUND'
order by sesh.sample_time desc;


-------------------------------------------------------------------------------------
--
--             sql by hash
--
-------------------------------------------------------------------------------------

select sql_text 
from v$sqltext
where hash_value =  &1
order by piece asc;


-------------------------------------------------------------------------------------
--
--             sql by sql_id
--
-------------------------------------------------------------------------------------


select sql_text 
from v$sqltext
where sql_id =  '&1'
order by piece asc;


-------------------------------------------------------------------------------------
--
--             SQL PLAN  by hash and id
--
-------------------------------------------------------------------------------------
****************
--long version--
****************

col Plan for a60
column id noprint
set linesize 240
set trim on


SELECT distinct lpad(' ',level-1)||operation||' '||options||' '|| object_name "Plan",IO_COST,cardinality,id
   FROM V$SQL_PLAN
CONNECT BY prior id = parent_id
        AND prior HASH_VALUE = HASH_VALUE
  START WITH id = 0 AND HASH_VALUE = &1
  ORDER BY id;

*****************
--short version--
*****************
set pagesize 600
set tab off 
set linesize 140
set echo off
set long 4000
col TQID format A4
col "SLAVE SQL" format A95 WORD_WRAP
col address format A12
col sql_hash format A15
col exec format 9999
col sql_text format A75 WORD_WRAP

select rpad('| '||substr(lpad(' ',1*(depth))||operation|| decode(options, null,'',' '||options), 1, 50), 50, ' ')||'|'|| 
          rpad(substr(object_name||' ',1, 19), 20, ' ')
          as "Explain plan" 
from 
       ( SELECT
  /*+ no_merge */
  p.HASH_VALUE             ,
  p.ID                     ,
  p.DEPTH                  ,
  p.POSITION               ,
  p.OPERATION              ,
  p.OPTIONS                ,
  p.COST COST              ,
  p.CARDINALITY CARDINALITY,
  p.BYTES BYTES            ,
  p.OBJECT_NODE            ,
  p.OBJECT_OWNER           ,
  p.OBJECT_NAME            ,
  p.OTHER_TAG              ,
  p.PARTITION_START        ,
  p.PARTITION_STOP         ,
  p.DISTRIBUTION           
  FROM V$sql_plan p
  WHERE p.sql_id = '&sql_id'
AND p.CHILD_NUMBER     = 0
	 )
order by ID 
;


-------------------------------------------------------------------------------------
--
--             TEMP SPACE MONITORING
--
------------------------------------------------------------------------------------

col username for a20
col osuser for a20
col program for a30
set pages 200
set linesize 200
set trim on
col MBS for 999,999,999

SELECT vs.sid,vs.username,program,round((blocks*8192)/power(1024,2),2) Mbs,vs.sql_id
from V$Session vs, V$TEMPSEG_USAGE tu
where vs.saddr = tu.SESSION_ADDR   
and blocks > 1000
order by 4 desc;



-------------------------------------------------------------------------------------
--
--          UNDO blocks by TX
--
----------------------------------------------------------------------------------

col machine for a30
col username for a30
select sid,USED_UBLK,username,program,machine
from v$transaction t, v$session s
where SES_ADDR = s.saddr;




-------------------------------------------------------------------------------------
--
--          Init parameters including the hidden ones
--
----------------------------------------------------------------------------------


col name for a40
col value for a20

SELECT
  x.ksppinm name,
  y.ksppstvl VALUE
FROM x$ksppi x,
  x$ksppcv y
WHERE x.inst_id = userenv('Instance')
 AND y.inst_id = userenv('Instance')
 AND x.indx = y.indx
 AND x.ksppinm LIKE '%&param%';



################################################################
##
##		SESSION KILLING 
##
################################################################

-------------------------------------------------------------------------------------
--
--             Single SESSION with ORAKILL
--
------------------------------------------------------------------------------------

select a.username, a.program, a.osuser, b.spid
from v$session a, v$process b
where a.paddr = b.addr
and a.username is not null
and a.sid = &1;

-------------------------------------------------------------------------------------
--
--             Multiple SESSIONs with ORAKILL
--
------------------------------------------------------------------------------------

col db noprint new_value db
SELECT value db
FROM v$parameter
WHERE name LIKE 'db_name';


set pages 1000
set trims on
spool c:\temp\okill.bat
select 'orakill &db ' || b.spid
from v$session a, v$process b
where a.paddr = b.addr
and a.username is not null
and a.username not in ('SYS','SYSTEM')
order by 1;


spool off



################################################################
##
##		LOCKS
##
################################################################

-------------------------------------------------------------------------------------
--
--            BLOCKING LOCKS 64b
--
-------------------------------------------------------------------------------------

truncate table lock_TMP;

insert into lock_TMP (select * from v$lock);
commit;

SELECT /*+ RULE */
               w.sid waiter_sid,
               h.sid holder_sid,
               w.type lock_type,
               h.lmode mode_held,
               DECODE(h.lmode, 0,   'NONE', 1, 'NULL', 2, 'ROW SHARE', 3, 'ROW EXCLUSIVE', 4, 'SHARE', 5, 'SHARE ROW EXCLUSIVE', 6, 'EXCLUSIVE', '?') description_held,
               h.ctime,
               w.request mode_requested,
               DECODE(w.request, 0, 'NONE', 1, 'NULL', 2, 'ROW SHARE', 3, 'ROW EXCLUSIVE', 4, 'SHARE', 5, 'SHARE ROW EXCLUSIVE', 6, 'EXCLUSIVE', '?') description_requested,
               w.id1,
               w.id2
            FROM lock_TMP w, lock_TMP h
            WHERE h.block      !=  0
            AND h.lmode      !=  0
            AND h.lmode      !=  1
            AND w.request    !=  0
            AND w.type       != 'MR'
            AND h.type       != 'MR'
            AND w.type       =   h.type
            AND w.id1        =   h.id1
            AND w.id2        =   h.id2;


-------------------------------------------------------------------------------------
--
--            BLOCKING LOCKS 10g
--
-------------------------------------------------------------------------------------

col HELD  for a4
col req for a3
col "Object" for a30
break on holder skip 1
col holder for a15
col waiter for a15
set linesize 200
set pages 2000
col "RowID" for a18

SELECT 
h.sid || ' (' || hs.username || ')' holder,
w.sid || ' (' || ws.username || ')' waiter,
w.type lock_type,
DECODE(h.lmode, 0,   'NONE', 1, 'NULL', 2, 'RS', 3, 'RX', 4, 'S', 5, 'SRX', 6, 'X', '?') held,
DECODE(w.request, 0, 'NONE', 1, 'NULL', 2, 'RS', 3, 'RX', 4, 'S', 5, 'SRX', 6, 'X', '?') req,
DECODE(w.type,'TX',(SELECT owner || '.' || object_name from dba_objects where OBJECT_ID = ws.ROW_WAIT_OBJ#),
              'TM',(SELECT owner || '.' || object_name from dba_objects where OBJECT_ID = w.id1))"Object",
DECODE(w.type,'TX',dbms_rowid.rowid_create ( 1, ws.ROW_WAIT_OBJ#, ws.ROW_WAIT_FILE#, ws.ROW_WAIT_BLOCK#, ws.ROW_WAIT_ROW# ),
	      'TM','N/A') "RowID",
ws.sql_id ,
h.ctime
FROM v$lock w, v$lock h, v$session ws, v$session hs
WHERE h.block      !=  0
AND h.lmode      !=  0
AND h.lmode      !=  1
AND w.request    !=  0
AND w.type       != 'MR'
AND h.type       != 'MR'
AND w.type       =   h.type
AND w.id1        =   h.id1
AND w.id2        =   h.id2
AND w.sid	      = ws.sid
AND h.sid  =  hs.sid
order by 1;

-------------------------------------------------------------------------------------
--
--            Library cache LOCKS 
--
-------------------------------------------------------------------------------------

set linesize 120

select /*+ ordered */ w1.sid  waiting_session,
	h1.sid  holding_session,
	w.kgllktype lock_or_pin,
        w.kgllkhdl address,
	decode(h.kgllkmod,  0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
	   'Unknown') mode_held, 
	decode(w.kgllkreq,  0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
	   'Unknown') mode_requested
  from dba_kgllock w, dba_kgllock h, v$session w1, v$session h1
 where
  (((h.kgllkmod != 0) and (h.kgllkmod != 1)
     and ((h.kgllkreq = 0) or (h.kgllkreq = 1)))
   and
     (((w.kgllkmod = 0) or (w.kgllkmod= 1))
     and ((w.kgllkreq != 0) and (w.kgllkreq != 1))))
  and  w.kgllktype	 =  h.kgllktype
  and  w.kgllkhdl	 =  h.kgllkhdl
  and  w.kgllkuse     =   w1.saddr
  and  h.kgllkuse     =   h1.saddr
/


################################################################
##
##		MEMORY SPECIFIC
##
################################################################

=========================================================================
-- Memory used by sql childs
=========================================================================
set pages 200
set linesize 300
col osuser for a15
col program for a40
BREAK ON REPORT
COLUMN DUMMY HEADING ''
COMPUTE SUM LABEL 'TOTAL' OF mem ON REPORT;

select sql_id,count(1) childs,round(sum(SHARABLE_MEM)/power(1024,2),2) mem,
count(distinct plan_hash_value) "distinct plans"
from v$sql
group by sql_id
having count(1) > 20
order by 3 desc;

=========================================================================
-- PGA used by jobs
=========================================================================

set linesize 300

col osuser for a15
col program for a35
col job_name for a40

BREAK ON REPORT
COLUMN DUMMY HEADING ''
COMPUTE SUM LABEL 'TOTAL' OF mem_mbs ON REPORT;


select
 s.sid,s.serial#,p.spid,status,
round(PGA_ALLOC_MEM/power(1024,2),3) mem_mbs,
dj.job job_id, substr(what,1,instr(what,'>>')+1) job_name
from v$session S, v$process p,dba_jobs_running rj, dba_jobs dj
where p.addr=s.paddr
and rj.sid=s.sid and rj.job=dj.job
order by 1
/

=========================================================================
-- PGA used by all sessions
=========================================================================

set linesize 300
col osuser for a15
col program for a40
BREAK ON REPORT
COLUMN DUMMY HEADING ''
COMPUTE SUM LABEL 'TOTAL' OF "Mem used" ON REPORT;
COMPUTE SUM LABEL 'TOTAL' OF "Number of Sessions" ON REPORT;

select
s.program,round(sum(PGA_ALLOC_MEM)/power(1024,2),3) "Mem used" ,
count(s.program) "Number of Sessions",round(avg(s.last_call_et/(60)),2) "Avg iddle [min]"
from v$session S, v$process p  where p.addr=s.paddr AND S.type='USER'
group by s.program 
order by 2;
/

=========================================================================
-- TOP 10 PGA users
=========================================================================

set linesize 300
col program for a40

SELECT 
SID,PROGRAM,status,sql_id,"Mem used"
FROM
	(select
	s.sid,s.program,
	round(PGA_ALLOC_MEM/power(1024,2),3) "Mem used" ,
	s.status,
	s.sql_id,
	ROW_NUMBER()  OVER ( ORDER BY round(PGA_ALLOC_MEM/power(1024,2),3) desc ) "order"
	from v$session S, v$process p  
	where p.addr=s.paddr AND S.type='USER')
WHERE "order" <=10;


=========================================================================
--Memory parameters
=========================================================================
col name for a30

select name,value/power(1024,2) "Mbs" 
from v$parameter 
where name in ( 'db_keep_cache_size','db_cache_size','shared_pool_size',
'pga_aggregate_target','large_pool_size','java_pool_size','sga_target');


=========================================================================
-- SGA components Free memory
=========================================================================
select pool,round(bytes/power(1024,2),2) "FREE MBs"
from  V$SGASTAT
where name = 'free memory';

SELECT * FROM(SELECT NAME, BYTES/(1024*1024) MB 
FROM V$SGASTAT WHERE POOL = 'shared pool'ORDER BY BYTES DESC) 
where rownum <=10;


=========================================================================
-- SGA usada por querys de usuario
=========================================================================
set lines 160

select ss.sid, ss.serial#, ss.username, ss.logon_time,
sq.sql_id, sq.SHARABLE_MEM/power(1024,2) sm, sq.PERSISTENT_MEM/power(1024,2) pm ,sq.RUNTIME_MEM/power(1024,2) rm
from v$session ss, v$sqlarea sq
where ss.sql_id=sq.sql_id
order by sm;



=========================================================================
-- PGA ALLOCATION
=========================================================================

select name,round(value/power(1024,2),2) "Mbs"
from v$pgastat
where name in ('total PGA allocated','total PGA inuse','aggregate PGA target parameter');


=========================================================================
-- PGA Advise
=========================================================================
set linesize 100

select 
round(PGA_TARGET_FOR_ESTIMATE/power(1024,2)) PGA_TARGET_FOR_ESTIMATE,
PGA_TARGET_FACTOR              ,
ESTD_PGA_CACHE_HIT_PERCENTAGE,
ESTD_OVERALLOC_COUNT          
from  V$PGA_TARGET_ADVICE;


=========================================================================
-- Dynamic components SIZES 
=========================================================================
Col Component for a40

SELECT 
COMPONENT,
round(CURRENT_SIZE/power(1024,2)) CS ,
OPER_COUNT ,
LAST_OPER_TYPE 
FROM V$SGA_DYNAMIC_COMPONENTS;


################################################################
##
##		Misc Stuff 
##
################################################################



-------------------------------------------------------------------------------------
--
--             Oracle Trace using EVENT 10046
--
-------------------------------------------------------------------------------------

 -- Start Trace (this trace will include wait event notifications)

exec dbms_system.set_ev(<SID>,<SERIAL>,10046,<TRACE LEVEL>,'')

NOTE: The 4th parameter is the trace level -->

0 --> Trace disabled
1 --> Standard trace
4 --> Standard trace plus bind variables (they dont show after using tkprof :( )
8 --> Standard trace plus Wait event info (tkprof will show this info)
12--> Standard trace plus bind variables and Wait event info

The best one is 8 :)

-- Stop Trace 

exec dbms_system.set_ev(<SID>,<SERIAL>,10046,0,'')

-------------------------------------------------------------------------------------
--
--             INVALID OBJECTS
--
-------------------------------------------------------------------------------------
set linesize 100
col object_name for a30
SELECT object_name,owner,object_type from dba_objects where status <> 'VALID'
and object_name not like 'BIN$%' and object_type <> 'SYNONYM'
and owner not in ('SYS','SYSTEM');


-------------------------------------------------------------------------------------
--
--             INVALID OBJECTS COMPILATION
-------------------------------------------------------------------------------------

SELECT 'ALTER ' || decode(object_type,'PACKAGE BODY','PACKAGE',object_type) || ' ' || owner || '.' 
|| object_name || ' COMPILE ' || decode(object_type,'PACKAGE BODY','BODY;',';')
from dba_objects where status <> 'VALID'
and object_name not like 'BIN$%' and object_type <> 'SYNONYM'
and owner not in ('SYS','SYSTEM');


-------------------------------------------------------------------------------------
--
--             Database links
--
------------------------------------------------------------------------------------
col db_link for a20
col owner for a20
col host for a20

SELECT db_link,owner,host,username
FROM dba_db_links;


-------------------------------------------------------------------------------------
--
--             DBA_JOBS monitoring
--
------------------------------------------------------------------------------------

alter session set nls_date_format = 'dd.mm.rrrr hh24:mi:ss';
column job_name for a40
set linesize 120
set pagesize 2000


select job,last_date,next_date,round(total_time/60) total_time, substr(what,1,instr(what,'>>')+1) job_name
from dba_jobs
order by 3 asc;


-------------------------------------------------------------------------------------
--
--           Files Checkpoint Sequence#
--
-------------------------------------------------------------------------------------

column MIN_CHECKPOINT format 999999999999
column MAX_CHECKPOINT format 999999999999

select min(CHECKPOINT_CHANGE#) MIN_CHECKPOINT,
max(CHECKPOINT_CHANGE#)  MAX_CHECKPOINT,
max(CHECKPOINT_CHANGE#) - min(CHECKPOINT_CHANGE#) DIFF
from  v$datafile;


-------------------------------------------------------------------------------------
--
--           Users assigned a role 
--
----------------------------------------------------------------------------------
select user$.name, admin_option, default_role
           from user$, sysauth$, dba_role_privs
           where privilege# = (select user# from user$
                               where name = 'CONNECT')
           and   user$.user# = grantee#
           and   grantee = user$.name
           and   granted_role = '&1';


-------------------------------------------------------------------------------------
--
--           Count and summarize the archives created in a particular day 
--
----------------------------------------------------------------------------------
col nr for 9999
col hh for a10
col size_gb for 99999.999

select count(SEQUENCE#) nr, to_char(COMPLETION_TIME, 'hh24') hh, round(sum(blocks*block_size)/power(1024,3), 2) size_gb  
	from v$archived_log
	where dest_id=1
	and trunc(completion_time) = trunc(sysdate)
	group by to_char(COMPLETION_TIME, 'hh24');


---------------------------
--Count of users, group by user
---------------------------
SELECT COUNT(username), username FROM V$SESSION WHERE username is not null
and username not in ('SYS','SYSTEM')
group by username;


################################################################
##
##		RMAN 
##
################################################################


-------------------------------------------------------------------------------------
--
--           Backup speed
--
----------------------------------------------------------------------------------

Col Location  for a40

SELECT
trunc(OPEN_TIME) "Date",
substr(handle,1,instr(handle,'\',1,4)) "location",
round(avg(EFFECTIVE_BYTES_PER_SECOND)/power(1024,2),2) "avg MBs/s"
from V$BACKUP_ASYNC_IO bio, v$backup_piece bp
where OPEN_TIME > trunc(sysdate-5) and type = 'AGGREGATE'
and bp.set_stamp = bio.set_stamp
group  by trunc(OPEN_TIME),substr(handle,1,instr(handle,'\',1,4));


###############################################################
##
##        Execute SNAPSHOT
##
###############################################################

EXECUTE DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT();


###############################################################
##
##       View Execution Plan from Historic 
##
###############################################################

set linesize 150
col snaps for a15
col interval for a30
col "[s/exec] Rate" for 999990.09
BREAK on Snaps skip 1
set pages 200

SELECT
trunc(hist.end_interval_time) "Day",
sum(sqls.EXECUTIONS_DELTA) "Execs",
sum(round(sqls.ELAPSED_TIME_DELTA/1000000,2)) "Elap [s]",	
round(sum(sqls.ELAPSED_TIME_DELTA/1000000)/
decode(sum(sqls.EXECUTIONS_DELTA),0,1,sum(sqls.EXECUTIONS_DELTA)),2) "[s/exec] Rate",
sum(round(sqls.CPU_TIME_DELTA/1000000,2))  "Cpu [s]",
sum(sqls.BUFFER_GETS_DELTA) "Buffer Gets",
sum(sqls.DISK_READS_DELTA) "Physical I/O",
sqls.PLAN_HASH_VALUE
FROM sys.WRH$_SQLSTAT sqls, DBA_HIST_SNAPSHOT hist
WHERE
hist.snap_id = sqls.snap_id
AND sqls.SQL_ID = '&sqlid'
group by trunc(hist.end_interval_time),sqls.PLAN_HASH_VALUE
order by 1;
