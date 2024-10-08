
#######VER SID, MAQUINA, PROGRAMA Y TIEMPO DE USO DE CPU#######
set pages 200
set lines 190
alter session set nls_date_format = 'dd/mm/yyyy hh24:mi:ss';
select sysdate from dual;
		set linesize 135
		col machine for a30
		col service for a30
		col prog_cpu for a35
		select ss.SID,
		P.SPID,
		ss.machine,  
		ss.program SERVICE,
		p.program  PROG_CPU,
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
--and ss.program like '%&SERVICE%'--
order   by VALUE desc
/
