set lines 135
col name for a30
col text for a50

select a.NAME, a.TYPE, a.SEQUENCE, a.LINE, a.POSITION, a.TEXT, a.ATTRIBUTE, a.MESSAGE_NUMBER, b.LAST_DDL_TIME
from dba_errors a, dba_objects b where a.name=b.object_name
and a.owner = upper('&USUARIO')
order by b.LAST_DDL_TIME desc;
