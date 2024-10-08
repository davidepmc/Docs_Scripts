	set linesize 250
	set pages 500
        col ACC_NAME for a40
        col ACC_MACHINE for a40
        col ACC_UNAME for a15
	alter session set nls_date_format= 'dd/mm/yyyy hh24:mi:ss';
		
	/*spool '/oracle/ETP/util/rendimiento.log' app*/

	select sysdate from dual;
	
	        select s.inst_id, s.sid, program ACC_NAME, machine ACC_MACHINE, sum(PHYSICAL_READS) ACCS_READS,sum(block_gets) BLOCK_GETS,
        sum(BLOCK_CHANGES) ACCS_CHG, sum(CONSISTENT_GETS) ACCS_GETS  from gv$session s, gv$sess_io ss
        where  s.sid=ss.sid 
	--and s.sid=243
	group by s.inst_id, s.sid,program, machine order by 4,6;
		
		
	##############
	## 	RAC		##
	##############
		
        select s.inst_id, s.sid, program ACC_NAME, machine ACC_MACHINE, sum(PHYSICAL_READS) ACCS_READS,sum(block_gets) BLOCK_GETS,
        sum(BLOCK_CHANGES) ACCS_CHG, sum(CONSISTENT_GETS) ACCS_GETS  from gv$session s, gv$sess_io ss
        where  s.sid=ss.sid 
		and s.inst_id=ss.inst_id
	--and s.sid=243
	group by s.inst_id, s.sid,program, machine order by 4,6;

	/*spool off*/
	
	select s.sid, s.serial#, s.username, s.logon_time from v$session s where s.sid = &sid;






col opname for a30
col target for a40
set linesize 120


select opname,target,sid,serial#,ELAPSED_SECONDS,round((sofar*100)/totalwork) "%done"
from v$session_longops
--where time_remaining > 0
where sid=&&sid
order by start_time desc;



select session_id, client_id, event,
         sum(wait_time + time_waited) ttl_wait_time
    from v$active_session_history active_session_history
   where sample_time between sysdate - 60/2880 and sysdate
   group by session_id, client_id, event
   order by 2;

