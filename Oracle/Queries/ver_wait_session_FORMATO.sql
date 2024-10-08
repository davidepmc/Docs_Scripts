col sid for 9999
set linesize 200
col event for a30
col osuser for a20
col program for a10
set pages 2000
col time for 99.99
break on state skip page
col state for a5

select DECODE(sw.state,'WAITED KNOWN TIME','WKT','WAITING','WAIT','WAITED SHORT TIME','WST') state,
vs.sid,sw.EVENT,vs.osuser,substr(program,1,10) program,sql_id, sw.p1, sw.p2, do.object_name, do.object_type
from v$session_wait sw, v$session vs, dba_objects do
where sw.wait_class <> 'Idle'
and sw.p2=do.object_id
and vs.sid=sw.sid
order by state,program ASc;


/*

col sid for 9999
set linesize 130
col event for a30
col osuser for a20
col program for a10
set pages 2000
col time for 99.99
break on state skip page
col state for a5

select DECODE(sw.state,'WAITED KNOWN TIME','WKT','WAITING','WAIT','WAITED SHORT TIME','WST') state,
vs.sid,sw.EVENT,vs.osuser,substr(program,1,10) program,sql_id, sw.p1, sw.p2
from v$session_wait sw, v$session vs
where sw.wait_class <> 'Idle'
and sw.event not like 'SQL%'
and vs.sid=sw.sid
order by state,program ASc;
*/

-- view what object is waiting 


select segment_name,segment_type,partition_name
from dba_extents
where
file_id=&p1_value
and
&p2_value between block_id and (block_id+blocks-1);


SELECT p1 "file#", p2 "block#", p3 "class#"
    FROM v$session_wait
    WHERE event = '&event';