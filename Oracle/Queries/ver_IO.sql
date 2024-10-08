set linesize 200
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
        col ACC_NAME for a40
        col ACC_MACHINE for a35
        col ACC_UNAME for a25
		select sysdate from dual;
        select s.sid, p.spid, s.program ACC_NAME, machine ACC_MACHINE, s.username ACC_UNAME,
        PHYSICAL_READS ACC_READS, BLOCK_CHANGES ACC_CHG, CONSISTENT_GETS ACC_GETS from v$session s, v$sess_io ss, v$process p
        where s.sid=ss.sid
		and s.paddr=p.addr
		order by s.program, machine;



select program ACC_NAME, machine ACC_MACHINE, sum(PHYSICAL_READS) ACCS_READS,
        sum(BLOCK_CHANGES) ACCS_CHG, sum(CONSISTENT_GETS) ACCS_GETS from v$session s, v$sess_io ss
        where s.sid=ss.sid group by program, machine order by program, machine;
