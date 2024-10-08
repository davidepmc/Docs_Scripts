spool fast_perf9i.log
set echo off
set pagesize 400
set linesize 200

prompt  **************************************************** 
prompt  Identification and Configration Menory Section  
prompt  **************************************************** 
prompt  
prompt  =========================  
prompt  NOMBRE BASE DE DATOS  
prompt  =========================  
prompt  

column name format a15
col "Version de Oracle" format a60
SELECT name, created, log_mode, b.banner "Version de Oracle"
  FROM v$database a, v$version b, v$version c
 WHERE b.banner LIKE '%Oracle%'
   AND ROWNUM = 1;

prompt  
prompt  =========================  
prompt  CONFIGURACION SGA  
prompt  =========================  
prompt  

break on report;
compute sum label 'TOTAL SGA' of value on report

column name format a20
column value format 9,999,999,999
SELECT name, value 
   FROM v$sga;

clear breaks
clear computes

prompt  
prompt  
prompt  **************************************************** 
prompt  Hit Ratio Section  
prompt  **************************************************** 
prompt  
prompt  =========================  
prompt  BUFFER HIT RATIO  
prompt  =========================  
prompt (Debe de ser > 85, sino incrementar el parametro db_block_buffers en el init.ora)  
prompt  

column "Logical Reads" format 99,999,999,999  
column "Physical Reads" format 999,999,999  
column "Physical Writes" format 999,999,999  

SELECT (a.VALUE + b.VALUE) "Logical Reads",
       c.VALUE "Physical Reads",
       d.VALUE "Physical Writes",
       TRUNC ((1 - c.VALUE / (b.VALUE + a.VALUE)) * 100, 2 ) " % Buffer Hit Ratio"
  FROM v$sysstat a,
       v$sysstat b,
       v$sysstat c,
       v$sysstat d
 WHERE a.name = 'consistent gets'
   AND b.name = 'db block gets'
   AND c.name = 'physical reads'
   AND d.name = 'physical writes';
 
prompt  
prompt  =========================  
prompt  DICTIONARY CACHE HIT RATIO  
prompt  =========================  
prompt (should be higher than 90 else increase shared_pool_size in init.ora)  
prompt  
  
column "Dict. Cache Gets"   format 999,999,999  
column "Dict. Cache Misses" format 999,999,999  
SELECT SUM (gets) "Dict. Cache Gets",
       SUM (getmisses) "Dict. Cache Misses",
       TRUNC ((1 -(SUM (getmisses) / SUM (gets))) * 100, 2) " % Dictionary Cache Hit Ratio"
  FROM v$rowcache;  

prompt
prompt =================================================
prompt DETALLE DE LA DICTIONARY CACHE POR TIPO DE OBJETO
prompt =================================================  
prompt

set lines 200

column "Tipo Objeto Dict. Cache" format a30
column "Gets" format 999,999,999
column "Misses" format 999,999,999

SELECT parameter "Tipo Objeto Dict. Cache",
       gets "Gets",
       getmisses "Misses",
       TRUNC (100 * (1 - getmisses / DECODE (gets, 0, 1, gets)), 2) " % Tipo Objeto D.C. Hit Ratio"
  FROM v$rowcache
 ORDER BY 4 DESC;

prompt  
prompt =========================  
prompt LIBRARY CACHE HIT RATIO  
prompt =========================  
prompt If Library Cache Hit Ratio < 99%, mas del 1% de los pins resulted in reloads =>
prompt REPARSING > 1%. REPARSING OCCURRED
prompt Then increase the shared_pool_size in init.ora, or modify your query.   
prompt  

column "Library Cache Hit Ratio" format 99.9999  
column " % REPARSING (< 1)" format 99.9999  
column "Executions" format 999,999,999  
column "Misses while executing" format 999,999,999  

SELECT SUM (pins) "Executions",
       SUM (reloads) "Misses while executing",
       100 * (1-(SUM (reloads) / SUM (pins)))" % Lib. Cache Hit Ratio",
	 100 * (SUM (reloads) / SUM (pins)) " % REPARSING (< 1)"
  FROM v$librarycache;
  
prompt  
prompt  ==============================================  
prompt  DETALLE DE LA LIBRARY CACHE POR TIPO DE OBJETO 
prompt  ==============================================  
prompt  Get Hit Ratio should be > 70, and Pin Hit Ratio > 85 
prompt
prompt  Get Hit Ratio: Este es el ratio de aciertos cuando un bloqueo es requerido para un objeto del
prompt                 tipo indicado..... (En estudio significado)
prompt  Pin Hit Ratio: Este ratio nos indica el porcentage de ejecuciones realizadas correctamente, si
prompt  		     su valor es inferior al 70% es ya muy preocupante.
prompt		     Es un identificativo de reparsing, y/o de shared pool escasa.
  
SELECT namespace,
       TRUNC (gethitratio * 100, 2) "Get Hit Ratio",
       TRUNC (pinhitratio * 100, 2) "Pin Hit Ratio"
  FROM v$librarycache
 WHERE namespace IN ('SQL AREA', 'TABLE/PROCEDURE', 'BODY', 'TRIGGER');

prompt
prompt  ===============================
prompt  MEMORIA LIBRE EN SHARED POOL 
prompt  ===============================
prompt

column bytes format 999,999,999  

SELECT pool, name, bytes
  FROM v$sgastat
 WHERE name = 'free memory';  


prompt
prompt  ============================
prompt  USO MEMORIA DE LA JAVA POOL
prompt  ============================
prompt

column bytes format 999,999,999  

SELECT pool, name, bytes
  FROM v$sgastat
 WHERE pool = 'java pool'
   AND name='memory in use';

prompt
prompt  =========================  
prompt  REDO LOG BUFFER  
prompt  =========================  
prompt Nos indican el numero de veces que una entrada a los 
prompt buffer de redo log no encontro espacio libre  

column "redo log space requests" format 999,999,999  
column "redo entries" format 999,999,999  
  
SELECT a.value "redo log space requests",
       b.value "redo entries",
       100 * (a.VALUE / b.VALUE) "Ratio Redo Log < 0.02%"
  FROM v$sysstat a, v$sysstat b
 WHERE a.name = 'redo log space requests'
   AND b.name = 'redo entries';



prompt ===========================
prompt  Tamaño medio de Redo Size
prompt ===========================
prompt Es el tamaño medio de las entrada al buffer de redo log.

 select to_char(round(a.value/b.value)) "Tamaño medio Redo Size (bytes)"
 from v$sysstat a,v$sysstat b
 where a.name = 'redo size'
 and b.name = 'redo entries';


prompt  
prompt =============================
prompt Resumen de varios Hit Ratios
prompt =============================  

SELECT 'Buffer Cache' name,
       ROUND( ( congets.VALUE + dbgets.VALUE - physreads.VALUE )* 100
	        / ( congets.VALUE + dbgets.VALUE),2 ) value
  FROM v$sysstat congets, v$sysstat dbgets, v$sysstat physreads
 WHERE congets.name = 'consistent gets'
   AND dbgets.name = 'db block gets'
   AND physreads.name = 'physical reads'
 UNION ALL
SELECT 'Execute/NoParse',
       DECODE (SIGN(ROUND((ec.VALUE - pc.VALUE)*100/DECODE(ec.VALUE, 0, 1, ec.VALUE), 2)),-1, 0,
	                ROUND((ec.VALUE - pc.VALUE) * 100 / DECODE (ec.VALUE, 0, 1, ec.VALUE),2))
  FROM v$sysstat ec, v$sysstat pc
 WHERE ec.name = 'execute count'
   AND pc.name IN ('parse count', 'parse count (total)')
 UNION ALL
SELECT 'Memory Sort',
       ROUND (ms.VALUE / DECODE ((ds.VALUE+ms.VALUE), 0, 1, ( ds.VALUE+ms.VALUE ))* 100,2)
  FROM v$sysstat ds, v$sysstat ms
 WHERE ms.name = 'sorts (memory)'
   AND ds.name = 'sorts (disk)'
 UNION ALL
SELECT 'SQL Area get hitrate',
       ROUND (gethitratio * 100, 2)
  FROM v$librarycache
 WHERE namespace = 'SQL AREA'
 UNION ALL
SELECT 'Avg Latch Hit (No Miss)',
       ROUND ((  SUM (gets) - SUM (misses) ) * 100 / SUM (gets), 2)
  FROM v$latch
 UNION ALL
SELECT 'Avg Latch Hit (No Sleep)', ROUND ((  SUM (gets) - SUM (sleeps)) * 100 / SUM (gets), 2)
  FROM   v$latch;





prompt****************************************************  
prompt Rollback Segment Section  
prompt****************************************************  
prompt if any count below is > 1% of the total number of requests for data  
prompt then more rollback segments are needed .
prompt
 
column count format 999,999,999  

SELECT class, count
  FROM v$waitstat
 WHERE class IN ('system undo header',
                 'system undo block',
                 'undo header',
                 'undo block')
 GROUP BY class, count;  
  
column "Tot # of Requests for Data" format 999,999,999,999  
 
SELECT SUM (VALUE) "Tot # of Requests for Data"
  FROM v$sysstat
 WHERE name IN ('db block gets', 'consistent gets');  
 
prompt  
prompt  =========================  
prompt  ROLLBACK SEGMENT CONTENTION  
prompt  =========================  
prompt  
prompt   If any ratio is > .01 then more rollback segments are needed  
  
column "Ratio" format 99.99999  

SELECT name, waits, gets, waits / gets "Ratio"
  FROM v$rollstat a, v$rollname b
 WHERE a.usn = b.usn;  


prompt Informacion de Undo and Recovery.
prompt

SELECT estimated_mttr
FROM   v$instance_recovery;

SELECT MAX (maxconcurrency),
       MAX (undoblks),
       AVG (undoblks)
FROM   v$undostat;

  
prompt
prompt  ==========================
prompt  Distribucion transacciones
prompt  ==========================

column rr heading 'RB Segment' format a18 
column us heading 'Username' format a15 
column os heading 'OS User' format a10 
column te heading 'Terminal' format a10 
 
SELECT r.name rr,
       NVL (s.username, 'no transaction') us,
       s.osuser os,
       s.terminal te
  FROM v$lock l, v$session s, v$rollname r
 WHERE l.sid = s.sid (+)
   AND TRUNC (l.id1 / 65536) = r.usn
   AND l.TYPE = 'TX'
   AND l.lmode = 6
 ORDER BY r.name;

column "total_waits" format 999,999,999  
column "total_timeouts" format 999,999,999  
prompt  
prompt  
set feedback on;  

prompt
prompt  *******
prompt   Sorts
prompt  *******
prompt

column value format 9,999,999,999
select substr(name,1,55) system_statistic, value  
 from v$sysstat  
 where name like '%sort%';

prompt  
prompt *****************************************************  
prompt file i/o should be evenly distributed across drives.  
prompt *****************************************************  

set linesize 140
column "ID#" format 999
column "Name" format a78
column "bytes" format 9,999,999,999
  
select  
a.file# "ID#",  
a.name "Name",  
a.status,  
a.bytes,  
b.phyrds,  
b.phywrts ,
b.readtim/decode(b.phyrds,0,1) "T. medio Lect(cent.sg)",
b.writetim/decode(b.phywrts,0,1) "T. medio Escr(cent.sg)"
from v$datafile a, v$filestat b  
where a.file# = b.file#;  
  
set linesize 100
  
prompt  
prompt *************
prompt latches
prompt *************  
prompt
prompt  =========================================================
prompt  Buffers de la L.R.U. recorridos hasta encontrar uno libre
prompt  =========================================================
prompt  Valor entre 1 y 2

Select 1+(a.value/b.value) 
  From v$sysstat a, v$sysstat b
    Where a.name = 'free buffer inspected' and
          b.name = 'free buffer requested';

prompt
prompt  ========================================================
prompt  Ratio de buffers de la L.R.U. sucios frente a los libres
prompt  ========================================================
prompt  Ratio poco elevado

Select (a.value/b.value) 
  From v$sysstat a, v$sysstat b
    Where a.name = 'dirty buffers inspected' and
          b.name = 'free buffer requested';

prompt  
Prompt Solamente para Oracle 8 y utilizando varias buffer_pools. Detecta contencion 
Prompt en los Latch de LRU.?¿
Prompt

column "ratio < 1%" format 999,999,999.999,999,999

 select a.name "Tipo cache datos",
    b. child# "nº identificador de latch" , 
    b.sleeps/b.gets "ratio < 1%"
 from v$buffer_pool a, v$latch_children b
   where a.lo_setid <= b.child# and
         a.hi_setid >= b.child# and
         b.name='cache buffers lru chain';


prompt =============================
prompt Contencion Latches (generico)
prompt =============================
prompt Si Miss Ratio ó Immediate Miss Ratio > 1 entonces puede que exista  
prompt contencion de estos latches. 
prompt  
column "miss_ratio" format 99.99  
column "immediate_miss_ratio" format 99.99  

set linesize 120
col name format a25
col gets format 999,999,999,999
col misses format 999,999,999,999
col immediate_gets format 999,999,999,999
col immediate_misses format 999,999,999,999

select substr(l.name,1,25) name,gets,misses,  
       trunc((misses/(gets+.001))*100,4) "Miss Ratio", 
	 immediate_gets, immediate_misses,
       trunc((immediate_misses/(immediate_gets+.001))*100,4) "I. Miss Ratio"  
from v$latch l, v$latchname ln  
where l.latch# = ln.latch#;

prompt ======================
prompt Contecion en Free List
prompt ======================

column count format 999,999,999  

SELECT class, count
  FROM v$waitstat
 WHERE class IN ('free list','data block');

prompt****************************************************  
prompt Session Event Section  
prompt****************************************************  
prompt Si el Tiempo medio de espera es > 0 puede existir contencion.  
prompt Si no se tienen activadas estadisticas de tiempo, solo se puede hacer una estimacion.
 
set linesize 120
col event format a30
select event, sum(total_waits) "Nº Total Espera",
       sum(total_timeouts) "Nº Total Timeouts",
  trunc ((sum(average_wait)/count(*))*0.001,4) "Tiempo Medio Espera (sg)",
  count(*) "Nº de Sesiones"
from v$session_event
-- where average_wait > 0
group by event
order by 4 desc;


prompt****************************************************  
prompt System Event Section  
prompt****************************************************  
prompt Si el Tiempo medio de espera es > 0 puede existir contencion.  
prompt Si no se tienen activadas estadisticas de tiempo, solo se puede hacer una estimacion.
 
SELECT event,time_waited*0.001 "Tiempo total espera Sg", total_waits , ((time_waited*0.001)/total_waits) "Tiempo Medio Espera (sg)"
  FROM v$system_event
 WHERE event NOT IN ('Null event',
                     'client message',
                     'smon timer',
                     'rdbms ipc message',
                     'pmon timer',
                     'WMON goes to sleep',
                     'virtual circuit status',
                     'dispatcher timer',
                     'SQL*Net message from client',
                     'parallel query dequeue wait',
                     'latch free',
                     'enqueue',
                     'write complete waits',
                     'free buffer waits',
                     'buffer busy waits',
                     'pipe gets',
                     'PL/SQL lock timer',
                     'null event',
                     'rdbms ipc reply',
                     'Parallel Query Idle Wait - Slaves',
                     'KXFX: Execution Message Dequeue - Slave',
                     'slave wait')
 ORDER BY time_waited DESC, total_waits DESC;

prompt
prompt**********************************************************  
prompt Consumo de memoria "PGA/UGA" por las sessiones de Oracle.  
prompt**********************************************************  
prompt  

prompt ===================
prompt Consumo Memoria PGA
prompt ===================

compute sum label 'TOTAL PGA Actual' of value on report
break on report

select value, n.name "Estadistica", sid
  from v$sesstat s , v$statname n
 where s.statistic# = n.statistic#
   and n.name like 'session pga memory';

prompt ==========================
prompt Consumo Memoria PGA Maxima
prompt ==========================

compute sum label 'TOTAL PGA Maxima' of value on report
break on report

select value, n.name "Estadistica", sid
  from v$sesstat s , v$statname n
 where s.statistic# = n.statistic#
   and n.name like 'session pga memory max';

prompt ===================
prompt Consumo Memoria UGA
prompt ===================

compute sum label 'TOTAL UGA Actual' of value on report
break on report

select value, n.name "Estadistica", sid
  from v$sesstat s , v$statname n
 where s.statistic# = n.statistic#
   and n.name like 'session uga memory';

prompt ==========================
prompt Consumo Memoria UGA Maxima
prompt ==========================

compute sum label 'TOTAL UGA Maxima' of value on report
break on report

select value, n.name "Estadistica", sid
  from v$sesstat s , v$statname n
 where s.statistic# = n.statistic#
   and n.name like 'session uga memory max';

clear breaks
clear computes


prompt ==============================
prompt Resumen estadistica de la PGA
prompt ==============================
col name format a30

SELECT name, value FROM v$pgastat;

prompt ======================================================
prompt Estimacion PGA necesaria para correcto funcionamiento.
prompt (Solo valido con gestion dinamica de PGA) 
prompt ======================================================

SELECT   ROUND (pga_target_for_estimate / 1024 / 1024) estim_target_mb,
         estd_pga_cache_hit_percentage,
         estd_overalloc_count,
         pga_target_factor
FROM     v$pga_target_advice
ORDER BY 1;


prompt
prompt *******************************************************************
prompt Existencia de bloqueos (Usuarios a la espera de adquirir bloqueos).
prompt *******************************************************************
prompt  

prompt ==========================================
prompt Blockeos existentes que provocan Contecion
prompt ==========================================

select * from dba_lock
where blocking_others!='Not Blocking';

prompt ===============================================
prompt Usuarios a la espera de que se liberen bloqueos
prompt ===============================================

select * from dba_blockers;

--prompt ===================================
--prompt Informacion Global sobre bloqueos
--prompt ===================================

SELECT /*+ RULE */ s.username, s.osuser, 
 S.PROGRAM "Program", s.serial# "Serial#", 
 s.sql_address "address", s.sql_hash_value "Sql hash", 
 lk.sid, 
 DECODE(lk.TYPE, 'MR', 'Media Recovery', 
                 'RT', 'Redo Thread', 
                 'UN', 'User Name', 
                 'TX', 'Transaction', 
                 'TM', 'DML', 
                 'UL', 'PL/SQL User Lock', 
                 'DX', 'Distributed Xaction', 
                 'CF', 'Control File', 
                 'IS', 'Instance State', 
                 'FS', 'File Set', 
                 'IR', 'Instance Recovery', 
                 'ST', 'Disk Space Transaction', 
                 'TS', 'Temp Segment', 
                 'IV', 'Library Cache Invalidation', 
                 'LS', 'Log Start or Switch', 
                 'RW', 'Row Wait', 
                 'SQ', 'Sequence Number', 
                 'TE', 'Extend Table', 
                 'TT', 'Temp Table', 
                 lk.TYPE) lock_type, 
 DECODE(lk.lmode, 
 0, 'None',  
 1, 'Null',  
 2, 'Row-S (SS)', 
 3, 'Row-X (SX)', 
 4, 'Share',   
 5, 'S/Row-X (SSX)', 
 6, 'Exclusive', 
 TO_CHAR(lk.lmode)) mode_held, 
     DECODE(request, 
 0, 'None', 
 1, 'Null', 
 2, 'Row-S (SS)',  
 3, 'Row-X (SX)',  
 4, 'Share',   
 5, 'S/Row-X (SSX)', 
 6, 'Exclusive',  
 TO_CHAR(lk.request)) mode_requested, 
 TO_CHAR(lk.id1) lock_id1, 
 TO_CHAR(lk.id2) lock_id2, 
 s.USERNAME  "DB User", s.sid,  
  OWNER||'.'||OBJECT_NAME "Object"
FROM v$lock lk,  v$session s, 
  DBA_OBJECTS ao
WHERE 
    lk.lmode  > 1
AND s.username is not null
AND lk.sid    = s.sid
AND ao.OBJECT_ID(+) = lk.id1
ORDER BY 1, "Object";

prompt ===========================================================
prompt Informacion de sobre sesiones bloqueadas por otra sessiones
prompt ===========================================================

SELECT /*+ CHOOSE */
 bs.username "Blocking User", 
 bs.username "DB User", 
 ws.username "Waiting User", 
 bs.sid "SID", 
 ws.sid "WSID", 
 bs.sql_address "address", 
 bs.sql_hash_value "Sql hash", 
 bs.program "Blocking App", 
 ws.program "Waiting App", 
 bs.machine "Blocking Machine", 
 ws.machine "Waiting Machine", 
 bs.osuser "Blocking OS User", 
 ws.osuser "Waiting OS User", 
 bs.serial# "Serial#", 
 DECODE(wk.TYPE, 
	'MR', 'Media Recovery',	'RT', 'Redo Thread','UN', 'USER Name', 
      'TX', 'Transaction', 	'TM', 'DML',	'UL', 'PL/SQL USER LOCK', 
	'DX', 'Distributed Xaction', 'CF', 'Control FILE',	'IS', 'Instance State', 
	'FS', 'FILE SET', 'IR', 'Instance Recovery',	'ST', 'Disk SPACE Transaction', 
	'TS', 'Temp Segment', 'IV', 'Library Cache Invalidation', 
	'LS', 'LOG START OR Switch',	'RW', 'ROW Wait','SQ', 'Sequence Number', 
	'TE', 'Extend TABLE', 'TT', 'Temp TABLE',	wk.TYPE) lock_type, 
 DECODE(hk.lmode, 0, 'None',	1, 'NULL', 	2, 'ROW-S (SS)', 	3, 'ROW-X (SX)', 
       4, 'SHARE',	5, 'S/ROW-X (SSX)', 6, 'EXCLUSIVE', TO_CHAR(hk.lmode)) mode_held, 
 DECODE(wk.request,	0, 'None',	1, 'NULL', 	2, 'ROW-S (SS)',  3, 'ROW-X (SX)', 
       4, 'SHARE',	5, 'S/ROW-X (SSX)',	6, 'EXCLUSIVE', 	TO_CHAR(wk.request)) mode_requested, 
 TO_CHAR(hk.id1) lock_id1, 
 TO_CHAR(hk.id2) lock_id2 
FROM 
   v$lock hk,  v$session bs, 
   v$lock wk,  v$session ws 
WHERE 
     hk.block   = 1 
AND  hk.lmode  != 0 
AND  hk.lmode  != 1 
AND  wk.request  != 0 
AND  wk.TYPE (+) = hk.TYPE 
AND  wk.id1  (+) = hk.id1 
AND  wk.id2  (+) = hk.id2 
AND  hk.sid    = bs.sid(+) 
AND  wk.sid    = ws.sid(+)
ORDER BY 1;



prompt
prompt ************************
prompt Otras Cositas (recursos)
prompt ************************
prompt  

set linesize 120 
col resource_name format a30
col current_utilization format 999,999,999,999
col max_utilization format 999,999,999,999
col initial_allocation format a20    
col limit_value format a20

select resource_name,
       current_utilization,
       max_utilization,
       initial_allocation,    
       limit_value 
from v$resource_limit;      

prompt
prompt ************************
prompt Estadisticas del sistema
prompt ************************
prompt  

col name format a60
col value format 999,999,999,999,999

select * from v$sysstat;

spool off
