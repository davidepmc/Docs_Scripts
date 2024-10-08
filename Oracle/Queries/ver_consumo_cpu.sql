
prompt ----------VER SID, MAQUINA, PROGRAMA Y TIMEPO DE USO DE CPU---------

alter session set nls_date_format = 'dd/mm/yyyy hh24:mi:ss';

select sysdate from dual;

		set linesize 250
		col machine for a40
		col service for a40
		col prog_cpu for a30
                col CPU_USAGE format 999d9

select ss.SID,
	P.SPID,
	ss.username,
	ss.machine,  
	ss.program SERVICE,
	p.program  PROG_CPU,
	ss.logon_time,
        VALUE/100 cpu_usage
from    v$session ss,
        v$sesstat se,
        v$statname sn,
	v$process p
where   se.STATISTIC# = sn.STATISTIC#
and     NAME like '%CPU used by this session%'
and     se.SID = ss.SID
and 	ss.paddr=p.addr
and 	value>0
order   by VALUE asc
/
