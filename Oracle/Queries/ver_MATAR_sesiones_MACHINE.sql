PROMPT MACHINES WHICH ARE CONNECTED TO SJGP

select machine, count (*) from v$session
group by machine, order by 1;

ACCEPT WHAT SESSION'S MACHINE DO YOU WANT TO KILL: 
PROMPT 

select username, 'ALTER SYSTEM KILL SESSION '''||SID||','||SERIAL#|| ''';' 
FROM V$SESSION
WHERE UPPER(MACHINE) LIKE UPPER('%&machine_name%')
and username not in ('SYS','SYSTEM')
order by sid;


select 'orakill SJGP ' || b.spid
from v$session a, v$process b
where a.paddr = b.addr
and upper(a.machine) like upper('%&machine_name%') 
and a.username is not null
and a.username not in ('SYS','SYSTEM')
order by 1;