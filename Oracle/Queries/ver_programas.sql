        set linesize 135
        col ACC_NAME for a30
        col ACC_MACHINE for a25
        col ACC_UNAME for a15
	alter session set nls_date_format = 'dd/mm/yyyy hh24:mi:ss';
	
	spool '/oracle/ETP/util/monitoring/logs_monitoring/ver_programas.log' app
	
	select sysdate from dual;
	
	 select machine, program, count(program) "Numero"  from v$session 
	where program = 'JscBackend.exe'  group by machine,program  order by "Numero" desc;

        select rownum ACC_INDEX, program ACC_NAME, machine ACC_MACHINE, username ACC_UNAME,
        PHYSICAL_READS ACC_READS, BLOCK_CHANGES ACC_CHG, CONSISTENT_GETS ACC_GETS from v$session s, v$sess_io ss
        where s.sid=ss.sid 
	and program = 'JscBackend.exe'
	order by program, machine;

	spool off
