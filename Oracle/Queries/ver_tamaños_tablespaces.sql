set pagesize 2000

break on report skip 2
compute sum of "Max Size" on report
compute sum of "Used" on report
compute sum of "free" on report
compute avg of "Free %" on report


SELECT
tablespace_name,
sum(round(max_size)) "Max Size",
round(sum(used) - sum(nvl(fs.free,0)),2) "Used",
sum(round(nvl(fs.free,0) + (max_size - used),2)) "Free",
round(sum((nvl(fs.free,0) + (max_size - used))*100)/sum(max_size),2) "Free %"
from
(select
file_name,
tablespace_name,
file_id,
decode(autoextensible,'YES',maxbytes/power(1024,3),'NO',bytes/power(1024,3)) max_size,
bytes/power(1024,3) used
from dba_data_files
where bytes <= maxbytes
union
select
file_name,
tablespace_name,
file_id,
bytes/power(1024,3) max_size,
bytes/power(1024,3) used
from dba_data_files
where bytes > maxbytes)
df ,
(select file_id,sum(bytes)/power(1024,3) Free from dba_free_space group by file_id) fs
where df.file_id=fs.file_id (+)
group by tablespace_name
--having round(sum((nvl(fs.free,0) + (max_size - used))*100)/sum(max_size),2) < 80
order by 5 asc
/


set lines 200
set pages 200select segment_name from dba_segments where owner='KYFE' order by 1;

column "Tablespace" format a13
column "Used MB"    format 99,999,999
column "Free MB"    format 99,999,999
column "Total MB"   format 99,999,999
select
   fs.tablespace_name                          "Tablespace",
   (df.totalspace - fs.freespace)              "Used MB",
   fs.freespace                                "Free MB",
   df.totalspace                               "Total MB",
   round(100 * (fs.freespace / df.totalspace)) "Pct. Free"
from
   (select
      tablespace_name,
      round(sum(bytes) / 1048576) TotalSpace
   from
      dba_data_files
   group by
      tablespace_name
   ) df,
   (select
      tablespace_name,
      round(sum(bytes) / 1048576) FreeSpace
   from
      dba_free_space
   group by
      tablespace_name
   ) fs
where
   df.tablespace_name = fs.tablespace_name;
