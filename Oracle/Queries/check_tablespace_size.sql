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
