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
