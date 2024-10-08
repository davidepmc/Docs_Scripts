set pages 5000
set lines 225
col username format a12
col os_process for a5
col process for a10
col osuser format a15
col machine format a30
col program format a35
col ouser format a15
alter session set nls_date_format = 'DD/MM/YYYY hh24:mi:ss';

select s.inst_id, s.SID, s.serial#,p.spid OS_PROCESS, p.pid PROCESS, s.USERNAME,s.STATUS,s.OSUSER, s.MACHINE,s.PROGRAM, s.logon_time
from gv$session s, gv$process p
where p.addr=s.paddr
and s.inst_id=p.inst_id
--and s.program not like 'w3wp%'
--and s.username='XE24480'
order by  program
/


#### RAC

set pages 5000
set lines 225
col username format a12
col os_process for a10
col process for a5
col osuser format a15
col machine format a30
col program format a35
col ouser format a15
alter session set nls_date_format = 'DD/MM/YYYY hh24:mi:ss';

select s.inst_id, s.SID, s.serial#,p.spid OS_PROCESS, p.pid PROCESS, s.USERNAME,s.STATUS,s.OSUSER, s.MACHINE,s.PROGRAM, s.logon_time
from gv$session s, gv$process p
where p.addr=s.paddr
and p.inst_id=s.inst_id
--and s.program like '%niku%'
--and s.username in ('CNMUSER','QBEUSER','USMUSER','REFUSER','LOG','EXEWR')
and s.username='&user'
order by machine, program, s.inst_id
/


#### kill sessions 

select 'alter system kill session '''||sid||','||serial#||',@'||inst_id||''' immediate;'
from gv$session where username in ('&users');


#### Sacar el Kill -9 de determinadas sesiones

SELECT 'kill -9 ' || p.spid, s.username, s.status from v$session s, v$process p
where p.addr=s.paddr
and s.username in ('CNMUSER','QBEUSER','USMUSER','REFUSER','LOG','EXEWR')
/

