###########################
#			  #
# VER SESIONES BLOQUEADAS #
###########################


  set lines 190
  set pages 300
  col username form A20
  col sid form 9990
  col type form A4
  col lmode form 990
  col request form 990
  col lmode for a15
  col request for a20
  col objname form A25 Heading "Object Name"
  col owner for a15
  rem Display the object ids if the object_name is not unique
  rem col id1 form 999999900   
  rem col id2 form 999999900



  SELECT sn.username, m.sid, sn.serial#, p.spid, m.type,
    DECODE(m.lmode, 0, 'None'
		  , 1, 'Null'
		  , 2, 'Row Share'
		  , 3, 'Row Excl.'
		  , 4, 'Share'
		  , 5, 'S/Row Excl.'
		  , 6, 'Exclusive'
		  , lmode, ltrim(to_char(lmode,'990'))) lmode,
    DECODE(m.request, 0, 'None'
		  , 1, 'Null'
		  , 2, 'Row Share'
		  , 3, 'Row Excl.'
		  , 4, 'Share'
		  , 5, 'S/Row Excl.'
		  , 6, 'Exclusive'
		  , request, ltrim(to_char(request,'990'))) request,
	  obj1.object_name objname,obj1.owner, obj2.object_name objname, obj2.owner
  FROM v$session sn, V$lock m, v$process p, dba_objects obj1, dba_objects obj2 
  WHERE sn.sid = m.sid
  AND m.id1 = obj1.object_id (+)
  AND m.id2 = obj2.object_id (+)
  AND sn.paddr=p.addr
      AND lmode != 4 
  ORDER BY id1,id2, m.request
  ;


  clear breaks


VER SID QUE BLOQUEAN A OTRAS SID

select lock1.sid, ' BLOQUEA ', lock2.sid
from v$lock lock1, v$lock lock2
where lock1.block =1 and lock2.request > 0
and lock1.id1=lock2.id1
and lock1.id2=lock2.id2;

####################################
## VER TRANSACCIONES DISTRIBUIDAS ##
####################################

Se localizan las transacciones distribuidas

SELECT * FROM DBA_2PC_PENDING;

ALTER SYSTEM DISABLE DISTRIBUTED RECOVERY ;

Para cada LOCAL_TRAN_ID (este execute debe ser el primer elemento de una transacción si no sale un error ORA-01453: SET TRANSACTION must be first statement of transaction, en este caso lanzamos un commit o un rollback y repetimos )
exec DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('50.7.2682')
commit;


Si sale:
SQL> exec DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('50.7.2682')
BEGIN DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('50.7.2682'); END;
*
ERROR at line 1:
ORA-30019: Illegal rollback Segment operation in Automatic Undo mode
ORA-06512: at "SYS.DBMS_TRANSACTION", line 65
ORA-06512: at "SYS.DBMS_TRANSACTION", line 85
ORA-06512: at line 1

SQL> alter session set undo_suppress_errors=TRUE;
Session altered.

SQL> exec DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('50.7.2682')
PL/SQL procedure successfully completed.

select s1.username  '@' ,s1.machine
 ' ( SID=' s1.sid ' ) esta bloqueando '
 s2.username  '@' , s2.machine ' ( SID=' s2.sid ' ) ' AS bloqueos
 from v$lock l1, v$session s1, v$lock l2, v$session s2
 where s1.sid=l1.sid and s2.sid=l2.sid
 and l1.BLOCK=1 and l2.request > 0
 and l1.id1 = l2.id1
 and l2.id2 = l2.id2 ;


########################################
##  VER BLOQUEOS LOGICOS DE INSTANCIA ##
########################################

set linesize 300
col event_blocker for a30
col event for a30
col username for a15
col sid for 99999
col wait_class for a15
col BLOCK_USER for a10
select (select username from v$session where sid=a.blocking_session) BLOCK_USER,
BLOCKING_SESSION BLOCK_SESS,
(select event from v$session where sid=a.BLOCKING_SESSION) event_blocker,
sid,username,wait_class,event  
from v$session a where BLOCKING_SESSION is not null order by BLOCKING_SESSION;


------------------------------------------------------------------------
VER OBJETOS BLOQUEADOS

Col Type FOR a15

select substr(a.os_user_name,1,8) "OS User"
, substr(b.object_name,1,30) "Object Name"
, substr(b.object_type,1,8) "Type"
, substr(c.segment_name,1,10) "RBS"
, e.process "PROCESS"
, substr(d.used_urec,1,8) "# of Records"
, e.sid
, e.serial#
from v$locked_object a
, dba_objects b
, dba_rollback_segs c
, v$transaction d
, v$session e
, v$process p
where a.object_id = b.object_id
--and e.sid in (1561,2278,2324)
and a.xidusn = c.segment_id
and a.xidusn = d.xidusn
and a.xidslot = d.xidslot
and d.addr = e.taddr
and p.addr = e.paddr
order by 2;


set lines 160
set pages 20
col username form A20
col sid form 9990
col type form A4
col lmode form 990
col request form 990
col objname form A25 Heading "Object Name"
rem Display the object ids if the object_name is not unique
rem col id1 form 999999900   
rem col id2 form 999999900



SELECT sn.username, m.sid, m.type,
   DECODE(m.lmode, 0, 'None'
                 , 1, 'Null'
                 , 2, 'Row Share'
                 , 3, 'Row Excl.'
                 , 4, 'Share'
                 , 5, 'S/Row Excl.'
                 , 6, 'Exclusive'
                 , lmode, ltrim(to_char(lmode,'990'))) lmode,
   DECODE(m.request, 0, 'None'
                 , 1, 'Null'
                 , 2, 'Row Share'
                 , 3, 'Row Excl.'
                 , 4, 'Share'
                 , 5, 'S/Row Excl.'
                 , 6, 'Exclusive'
                 , request, ltrim(to_char(request,'990'))) request,
         obj1.object_name objname, obj2.object_name objname
FROM v$session sn, V$lock m, dba_objects obj1, dba_objects obj2
WHERE sn.sid = m.sid
AND m.id1 = obj1.object_id (+)
AND m.id2 = obj2.object_id (+)
     AND lmode != 4 
ORDER BY id1,id2, m.request
/


clear breaks
