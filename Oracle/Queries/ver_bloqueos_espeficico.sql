-- VER TODOS LOS BLOQUEOS --

select * from v$lock;

-- VER SESION BLOQUEA A OTRA SESION --

select l1.sid, ' IS BLOCKING ', l2.sid
from v$lock l1, v$lock l2
where l1.block =1 and l2.request > 0
and l1.id1=l2.id1
and l1.id2=l2.id2;

-- VER SESSION BLOQUEA A OTRA SESSION MÁS COMPLETO --

select s1.username || '@' || s1.machine
|| ' ( SID=' || s1.sid || ' )  is blocking '
|| s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
from v$lock l1, v$session s1, v$lock l2, v$session s2
where s1.sid=l1.sid and s2.sid=l2.sid
and l1.BLOCK=1 and l2.request > 0
and l1.id1 = l2.id1
and l2.id2 = l2.id2 ;

-- VER EL OBJETO QUE ESTÁ BLOQUEADO --

select object_name, object_type, owner from dba_objects where object_id=&object_id;

-- VER QUE ESTÁ SIENDO BLOQUEADO --

select row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#
from v$session where sid=&sid ;

-- VER OBJETO Y ROWID BLOQUEADO --

select do.object_name,
row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#,
dbms_rowid.rowid_create ( 1, ROW_WAIT_OBJ#, ROW_WAIT_FILE#, ROW_WAIT_BLOCK#, ROW_WAIT_ROW# )
from v$session s, dba_objects do
where sid=&sid
and s.ROW_WAIT_OBJ# = do.OBJECT_ID ;


-- VER FILA BLOQUEADA EN LA TABLA --

select * from tstlock where rowid='AAAAECiAAKAAAAAfAAA';

-- VER LA QUERY QUE HACE LA SESION BLOQUEADA --

select s.sid, q.sql_text from v$sqltext q, v$session s
where q.address = s.sql_address
and s.sid = &sid
order by piece;