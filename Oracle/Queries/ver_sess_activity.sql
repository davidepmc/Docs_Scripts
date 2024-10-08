set verify off
set pages 200
--spool /oracle/ETP/util/monitoring/logs_monitoring/monsid.lst
column name form a60
column sid form 999
column serial# form 999999 Heading "Serial"
column logon_time format a15
column osuser format a12 heading "OS User"
column program format a22
column username format a12
column idle_mins format 99999 Heading "Idle"
column object format a30
column owner form a15 heading "Owner"
column type format a12
column event format a32
column total_waits form 999,999 heading twaits
column total_timeouts form 999,999 heading ttimeouts
column time_waited form 999,999 heading time_wait
column average_wait form 999,999 heading avg_wait
column max_wait form 999,999 heading max_wait

ACCEPT spid PROMPT 'Enter system id to refine (return for all) :'

select s.SID,s.USERNAME,s.OSUSER,s.PROGRAM, p.SPID
from v$session s, v$process p
where p.addr = s.paddr
and s.username is not null -- omit background processes
and p.spid like '&spid%'
/

ACCEPT sid PROMPT 'Enter sid to refine :'

select sid,serial#,username,program,status
,to_char(logon_time,'DD-MON-RR hh24:mi') logon_time
,trunc(last_call_et/60) idle_mins
from v$session
where sid = '&sid';

PROMPT
PROMPT Selecting V$SESSION_WAIT
PROMPT
column sid format 990
column seq# format 99990
column wait_time heading 'WTime' format 99990
column event format a30
column state forma a10 heading "State"
column seconds_in_wait form 999,999 heading secsinwait
column p1 format 9999999990
column p2 format 9999999990
column p3 format 9990

select event,p1,p2,p3,wait_time,seconds_in_wait
from v$session_wait
where sid = '&sid';

PROMPT
PROMPT Selecting V$SESSION_EVENT
PROMPT
select event,TOTAL_WAITS,TOTAL_TIMEOUTS,TIME_WAITED,AVERAGE_WAIT,  MAX_WAIT
from v$session_event where sid = '&sid';

PROMPT
PROMPT User is running the following queries

select oc.sid, t.sql_text
from v$open_cursor oc, v$sqltext t
where t.hash_value = oc.hash_value and t.address=oc.address
and oc.sid = '&sid'
order by oc.sid, t.address, t.hash_value, t.piece
/

PROMPT
PROMPT Selecting V$ACCESS (This may take some time on a large database)
PROMPT

REM select * from v$access where sid = '&sid';

ACCEPT stat PROMPT 'Filter on statistics (return for all) :'

select s.sid, sn.name, s.value
from v$sesstat s, v$statname sn, v$session sess
where s.sid=sess.sid
and sn.statistic#=s.statistic#
and s.sid LIKE '&sid%'
and sn.name like '&stat%'
and s.value != 0
order by s.sid, sn.name
/               

-- Ver tiempo restante que queda en la sesion para terminar la query
select sid, serial#, opname, target, sofar, totalwork, TIME_REMAINING from v$session_longops where sid = &SID
and totalwork <> sofar

       

spool off

