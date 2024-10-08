col program for a25
col object for a20
select s.program PROGRAM, do.OBJECT_NAME OBJECT, lo.SESSION_ID SID, spid OS_PROCESS from v$locked_object lo, dba_objects do, v$session s, v$process p
where lo.object_id=do.object_id
and s.sid=lo.session_id
and s.paddr=p.addr
/
