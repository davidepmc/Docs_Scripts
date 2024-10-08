--Proceso Concreto

select ss.program, ss.machine, p.program, ss.sid, p.spid 
from v$process p, v$session ss where ss.paddr = p.addr and p.spid=&spid;

--Todos los Procesos

select ss.username, ss.program, ss.machine, p.program, ss.sid, p.spid 
from v$process p, v$session ss where ss.paddr = p.addr
order by ss.username;

--Proceso Concreto por SID

select ss.program, ss.machine, p.program, ss.sid, p.spid 
from v$process p, v$session ss where ss.paddr = p.addr and ss.sid=&sid;

--Proceso Concreto pro Nombre

select ss.username, ss.program, ss.machine, p.program, ss.sid, p.spid 
from v$process p, v$session ss where ss.paddr = p.addr
and ss.program like '%&process_name%'
order by ss.username;





