########################
#  VER QUERY POR SPID  #
########################


set head on
set pages 500
set lines 160
col sql_text for a90 wrapped
col username for a10
SELECT  s.sid, s.username, a.hash_value, a.sql_text
FROM v$session s, v$sqltext a 
WHERE s.sql_address = a.address
  AND s.sql_id in (select distinct sql_id from v$session where paddr= (select addr from v$process where spid =&PID))
ORDER BY 1,2, piece
/


### ORACLE 9i

set head on
set pages 500
set lines 160
col sql_text for a90 wrapped
col username for a10
SELECT  s.sid, s.username, a.hash_value, a.sql_text
FROM v$session s, v$sqltext a 
WHERE s.sql_address = a.address
  AND s.sql_address in (select distinct sql_address from v$session where paddr= (select addr from v$process where spid =&PID))
ORDER BY 1,2, piece
/


#######################
#  VER QUERY POR SID  #
#######################


set head on
set pages 500
set lines 160
col sql_text for a90 wrapped
col username for a10
SELECT  s.sid, s.username, a.sql_id, a.hash_value, a.sql_text
FROM v$session s, v$sqltext a 
WHERE s.sql_address = a.address
  AND s.sql_id in (select distinct sql_id from v$session where SID=&SID)
ORDER BY 1,2, piece
/


### ORACLE 9i


set head on
set pages 500
set lines 160
col sql_text for a90 wrapped
col username for a10
SELECT  s.sid, s.username, a.address, a.hash_value, a.sql_text
FROM v$session s, v$sqltext a 
WHERE s.sql_address = a.address
  AND s.sql_address in (select distinct sql_address from v$session where SID=&SID)
ORDER BY 1,2, piece
/

-- Una vez que sacamos el ADDRESS podemos conseguir los datos de la sentencia (tal vez sea necesario modificar algo la sentencia en el GROUP BY si aparecen varias sesiones)

SELECT  s.sid, s.username, a.executions, a.hash_value, 
a.buffer_gets, (a.buffer_gets/a.executions) GETs_per_exec,
a.disk_reads, (a.disk_reads/a.executions) DISK_per_exec,
a.ROWS_PROCESSED, (a.rows_processed/a.executions) ROWS_per_exec,
 a.cpu_time/1000/1000 SS_CPU, 
a.elapsed_time/1000/1000 SS_TOTAL, ((a.elapsed_time/1000/1000)/a.executions) SS_per_exec
FROM v$session s, v$sql a 
WHERE s.sql_address = a.address
  AND a.address='&ADDRESS'
and executions>0
Group by  s.sid, s.username, a.executions, a.buffer_gets, a.disk_reads, a.ROWS_PROCESSED, a.hash_value, a.cpu_time, a.elapsed_time
order by s.sid
/


#####################################
#  VER QUERY POR USUARIO CONECTADO  #
#####################################

### ORACLE 10G

set head on
set pages 500
set lines 200
col sql_text for a90 wrapped
col username for a20
SELECT  s.sid, s.username, a.sql_id, a.hash_value, a.sql_text
FROM v$session s, v$sqltext a 
WHERE s.sql_address = a.address
  AND s.sql_id in (select distinct sql_id from v$session where SID IN (SELECT SID FROM V$SESSION WHERE USERNAME ='&USUARIO'))
ORDER BY 1,2, piece
/

### ORACLE 9i

set pages 500
set lines 200
COL USERNAME FOR A20
col sql_text for a90 wrapped
SELECT  s.sid, s.username, a.hash_value, a.sql_text
FROM v$session s, v$sqltext a 
WHERE s.sql_address = a.address
  AND s.sql_address in (select distinct sql_address from v$session where SID IN (SELECT SID FROM V$SESSION WHERE USERNAME ='&USUARIO'))
ORDER BY 1,2, piece
/