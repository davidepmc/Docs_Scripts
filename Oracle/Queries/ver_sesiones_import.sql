set linesize 200
set pagesize 100
column program format a25
column action format a20
column username format a10

  select s.username,s.sid, s.serial#, p.spid,s.status,
       si.physical_reads, si.block_gets, si.consistent_gets, si.block_changes, s.action
from v$process p,  
     v$session s,
     sys.V_$Sess_io si
where p.addr=s.paddr 
     and s.module like '%Data Pump%'
   --  and s.program like 'QRCOCAPRSP25%'
      and si.sid(+)=s.sid;
      
      
      
      
----------------------------------------------


set linesize 156
set pagesize 100
column program format a25
column action format a20
column username format a10

  select s.username,s.sid, s.serial#, p.spid,s.status,
       si.physical_reads, si.block_gets, si.consistent_gets, si.block_changes, s.action
from v$process p,  
     v$session s,
     sys.V_$Sess_io si
where p.addr=s.paddr 
     and s.module like '%imp%'
   --  and s.program like 'QRCOCAPRSP25%'
      and si.sid(+)=s.sid;