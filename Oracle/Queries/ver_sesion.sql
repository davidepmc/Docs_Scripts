##### BY SID

set pages 5000
set lines 250
col username format a12
col osuser format a20
col machine format a35
col program format a35
col ouser format a15
col spid format a10

alter session set nls_date_format='DD/MM/YYYY hh24:mi:ss';

select s.inst_id, s.sid,s.serial#, p.spid,s.USERNAME,s.STATUS,s.OSUSER,s.MACHINE,s.PROGRAM, s.module, s.logon_time
from gv$session s, gv$process p
where s.paddr=p.addr
and sid = &SID
and s.inst_id=p.inst_id
order by machine, program
/


#### BY PID

set pages 5000
set lines 190
col username format a12
col osuser format a15
col machine format a35
col program format a35
col ouser format a15
col spid format a10

alter session set nls_date_format='DD/MM/YYYY hh24:mi:ss';

select s.inst_id, s.sid,s.serial#, p.spid,s.USERNAME,s.STATUS,s.OSUSER,s.MACHINE,s.PROGRAM
from gv$session s, gv$process p
where s.paddr=p.addr
and p.spid = &PID
and s.inst_id=p.inst_id
order by machine, program
/


#### BY USERNAME

set pages 5000
set lines 190
col username format a12
col osuser format a15
col machine format a35
col program format a35
col ouser format a15
col spid format a10

alter session set nls_date_format='DD/MM/YYYY hh24:mi:ss';

select s.inst_id, s.sid,s.serial#, p.spid,s.USERNAME,s.STATUS,s.OSUSER,s.MACHINE,s.PROGRAM
from gv$session s, gv$process p
where s.paddr=p.addr
and s.username='&username'
and s.inst_id=p.inst_id
order by machine, program
/


#### BY MACHINE

set pages 5000
set lines 190
col username format a12
col osuser format a15
col machine format a35
col program format a35
col ouser format a15
col spid format a10

alter session set nls_date_format='DD/MM/YYYY hh24:mi:ss';

select s.inst_id, s.sid,s.serial#, p.spid,s.USERNAME,s.STATUS,s.OSUSER,s.MACHINE,s.PROGRAM
from gv$session s, gv$process p
where s.paddr=p.addr
and s.machine='&machine'
and s.inst_id=p.inst_id
order by machine, program
/