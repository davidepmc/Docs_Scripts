https://nenadnoveljic.com/blog/troubleshooting-ora-00054-resource-busy-and-acquire-with-nowait-specified-or-timeout-expired/

set head on
set pages 500
set lines 200
col sql_text for a90 wrapped
col username for a10
col machine for a40
col module for a40


SELECT  s.inst_id, s.sid, s.username, s.machine, s.module, a.sql_id, a.hash_value, a.sql_text
FROM gv$session s, gv$sqltext a 
WHERE s.sql_address = a.address
  --AND s.sql_id in (select distinct sql_id from v$session where SID=&SID)
  --AND a.sql_text like '%T_KBGE_PAYMENT%'
  AND s.username='O000173'
  AND s.inst_id=a.inst_id
ORDER BY 1,2, piece
/



SELECT v.*
  FROM gv$locked_object v, dba_objects d
  WHERE v.object_id = d.object_id and object_name = 'T_KBGE_PAYMENT';




set pages 5000
set lines 250
col username format a12
col osuser format a20
col machine format a35
col program format a35
col ouser format a15

alter session set nls_date_format='DD/MM/YYYY hh24:mi:ss';

select s.inst_id, s.SID,s.serial#, p.spid,s.USERNAME,s.STATUS,s.OSUSER,s.MACHINE,s.PROGRAM, s.module, s.logon_time
from gv$session s, gv$process p
where s.paddr=p.addr
--and sid = &SID
and s.username='&username'
and s.inst_id=p.inst_id
order by machine, program
/


select 'alter system kill session ''' || s.sid  || ',' || s.serial# || ',@' || s.inst_id|| ';' || p.spid
from gv$session s, gv$process p  where s.username ='O000173'
and s.paddr=p.addr
and s.inst_id=p.inst_id;



