set pages 999 lines 999 head off echo off feed off trims on;
--select rpad('+',length(x),'-')||'-+'||chr(10)||x||' |'||chr(10)||rpad('+',length(x),'-')||'-+' from (
--select '| '||name||'@'||host_name||' ~ RMAN Backups Status ~ '||to_char(sysdate,'dd-Mon-yyyy hh24:mi:ss') x from v$database,v$instance);
set head on;
col session_stamp for 999999999999;
col recid for a6;
col backup_type for a25;
col device_type for a10;
col time_frame for a34;
col elapsed_time for a13;
col status for a11;
col errors for a30;
col total_gb for 99,990.9;
col gb_hour for 9,990.9 head "GB/HOUR";
with rman_status as (
   select distinct substr(backup_type,1,instr(backup_type||' datafile',' datafile')) backup_type
        , round(mbytes_processed/1024,1) total_gb, output_device_type device_type
        , round((mbytes_processed/1024)/((end_time-start_time))/24,1) gb_hour
        , start_time, end_time, status, session_stamp, recid
        , to_char(mod(floor((end_time-start_time)*24),24),'00')||'h'
       || to_char(mod(floor((end_time-start_time)*24*60),60),'00')||'m'
       || to_char(mod(floor((end_time-start_time)*24*60*60),60),'00')||'s' elapsed_time
        , case when status='FAILED' then     
            case when (select count(1) from v$rman_output
                        where session_stamp = x.session_stamp
                          and rman_status_recid = x.recid) = 0
                 then 'RMAN Output Not Found'
                 else (select nvl(rtrim(xmlagg(xmlelement(e,substr(output,1,instr(output,':')-1)
                                    ||',')).extract('//text()'),','),'No Errors ~ Session Hung')
                         from v$rman_output
                        where session_stamp = x.session_stamp
                          and rman_status_recid = x.recid
                          and output like 'ORA-%')
            end              
          else null end errors     
     from (select nvl(substr(y.output,instr(y.output,'starting ')+9),object_type) backup_type
                , mbytes_processed, object_type, output_device_type
                , start_time, end_time, status, x.session_stamp, x.recid
             from v$rman_status x, v$rman_output y
            where x.session_stamp = y.session_stamp(+)
              and x.recid = y.rman_status_recid(+)
              and object_type in ('DB INCR','DB FULL')
              and status != 'RUNNING'
              and operation = 'BACKUP'
              and ((lower(y.output) like '%starting%datafile%backup%' 
              and lower(y.output) not like '%validation%') 
               or y.output is null)) x    
     order by session_stamp desc, recid desc
)
select session_stamp, recid||'' recid
     , substr(replace(initcap(backup_type),'Db ','DB '),1,25) backup_type
     , substr(device_type,1,10) device_type
     , substr(status,1,11) status
     , to_char(start_time,'dd-Mon-yyyy  hh24:mi')||' ~ '||to_char(end_time,'hh24:mi')||
       decode(trunc(end_time-start_time),0,null,'(+1Day)') time_frame
     , elapsed_time, total_gb, gb_hour, substr(errors,1,30) errors
  from rman_status
-- remove comment to check last backup
-- where (select 1 from rman_status where rownum=1 and status!='COMPLETED')=1
;
