select lock1.sid, ' BLOQUEA ', lock2.sid
from v$lock lock1, v$lock lock2
where lock1.block =1 and lock2.request > 0
and lock1.id1=lock2.id1
and lock1.id2=lock2.id2;


select s1.username as '@' ,s1.machine
 ' ( SID=' s1.sid ' ) esta bloqueando '
 s2.username as '@' ,s2.machine ' ( SID=' s2.sid ' ) ' AS bloqueos
 from v$lock l1, v$session s1, v$lock l2, v$session s2
 where s1.sid=l1.sid and s2.sid=l2.sid
 and l1.BLOCK=1 and l2.request > 0
 and l1.id1 = l2.id1
 and l2.id2 = l2.id2 ;