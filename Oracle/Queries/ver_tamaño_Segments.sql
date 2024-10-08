set lines 200
set pages 2000
col owner for a25
col segment_type for a32
col segment_name for a40

select owner, segment_type, segment_name, tablespace_name, sum(bytes)/1024/1024/1024 MB
from dba_segments
where owner not like '%SYS%'
group by owner, segment_type, segment_name, tablespace_name
having sum(bytes)/1024/1024/1024>30
order by 5 asc, 1,2,3;