set lines 225
set pages 200
col tablespace for a25
col user for a25



select 
ts.tablespace "TABLESPACE" ,
ts.username "USER" ,
s.sid "SID",
s.serial# "SERIAL",
ts.SQL_ID "SQL_ID",
sq.PLAN_HASH_VALUE "HASH",
ts.segtype "SORT_TYPE",
round (((ts.blocks * p.value)/1024/1204),2) "SIZE_MB"
from
v$tempseg_usage ts,
v$session s,
v$parameter p,
v$sql sq
where p.NAME = 'db_block_size'
and ts.session_num = s.serial#
and ts.contents = 'TEMPORARY'
and ts.sql_id=sq.sql_id
order by 1,2,3
/