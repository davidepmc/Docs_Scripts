select b.name, b.user_comment, a.* 
from v$aq a, dba_queues b 
where a.qid = b.qid 
and b.name = '&QUEUE_NAME';