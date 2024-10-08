set lines 195
col wait_class for a20
col machine for a35
col event for a35
select sw.sid, p.spid,s.username, s.machine, sw.event, sw.state, sw.WAIT_CLASS, sw.WAIT_TIME, sw.SECONDS_IN_WAIT  from v$session_wait sw, v$session s, v$process p
where sw.sid=s.sid
and s.paddr=p.addr
order by sid, state
/



######### Version 9i ###############

set lines 200
col wait_class for a20
col machine for a35
col event for a35
select sw.sid, p.spid, s.machine, sw.event, sw.state,  sw.WAIT_TIME, sw.SECONDS_IN_WAIT  
from v$session_wait sw, v$session s, v$process p
where sw.sid=s.sid
and s.paddr=p.addr
order by sid, state
/