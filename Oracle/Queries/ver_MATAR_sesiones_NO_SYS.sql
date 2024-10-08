set pages 1000
set trims on
spool /tmp/okill.sh
select 'kill -9 ' || b.spid
from v$session a, v$process b
where a.paddr = b.addr
and a.username is not null
and a.username not in ('SYS','SYSTEM')
order by 1;


spool off