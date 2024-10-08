--Daily 
select thread# , to_char(FIRST_TIME,'yyyymmdd') as "Date", round(sum(BLOCKS*BLOCK_SIZE)/1024/1024/1024,2) as "  GB  " 
from gv$archived_log 
group by  thread#, to_char(FIRST_TIME,'yyyymmdd') 
order by 2;

-- Hourly
select to_char(FIRST_TIME,'yyyymmdd hh24') as "Date", round(sum(BLOCKS*BLOCK_SIZE)/1024/1024/1024,2) as "  GB  " from v$archived_log group by to_char(FIRST_TIME,'yyyymmdd hh24') order by 1;