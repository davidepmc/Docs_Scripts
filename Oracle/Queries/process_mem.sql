set linesize 135
col machine for a20
col program for a30
select pid, spid, s.PROGRAM, s.MACHINE, PGA_USED_MEM/1024/1024 "PGA_USED_MEM_MB",
PGA_ALLOC_MEM/1024/1024 "PGA_ALLOC_MEM_MB",
PGA_FREEABLE_MEM/1024/1024 "PGA_FREEABLE_MEM_MB",
PGA_MAX_MEM/1024/1024 "PGA_MAX_MEM_MB" from v$process p, v$session s
where p.addr = s.paddr
and spid=&SPID
/
