 set lines 200
 set pages 5000
 col object_type for a20
 col status for a25
 col type for a4
 col handle for a40
 col MB for 999g999d99
 
 select rcd.name "DB_NAME", decode(rcp.backup_type,'D','FULL','I','INCR','L','ARCH') "TYPE", rcp.incremental_level "LEVEL", rcp.handle "HANDLE", 
rcp.start_time "START", rcp.completion_time "END", rcp.tag, rcp.media,
decode(rcp.status, 'A', 'AVAILABLE','U','UNAVAILABLE','D' ,'DELETED','X' ,'EXPIRED') "STATUS", rcp.bytes/1024/1024 "MB"
 from rc_database rcd, rc_backup_piece rcp
 where rcd.dbid=rcp.db_id
 and rcd.name ='&DB_NAME'
/* and 
 rcp.start_time like (to_date('29/09/2014','DD/MM/YYYY'))
 rcp.start_time like (to_date('28/03/2014','DD/MM/YYYY'))*/
 order by rcp.start_time asc;


REM QUERY PARA VER TODOS LAS ACCIONES DE BACKUP CON RMAN
 
 set lines 200
 set pages 5000
 col object_type for a20
 col status for a25
 col mb for 999999999d99
 
 
 select start_time,OPERATION, STATUS, MBYTES_PROCESSED MB, OPTIMIZED, OBJECT_TYPE, end_time 
 from rc_rman_status 
 where 
 --db_name ='&DBNAME' 
 db_key='&DBID'
 order by start_time;


REM QUERY PARA VER LOS BACKUPS DE LOS ULTIMOS 3 DIAS DE UNA BBDD

set lines 250
 set pages 5000
 col object_type for a20
 col status for a25
 col operation for a40
 col mb for 999999999d99
 
 
 select 
 -- rcd.dbid dbid, rcd.name name, 
 rcs.session_key, rcs.start_time, rcs.OPERATION, rcs.STATUS, rcs.MBYTES_PROCESSED/1024 GB,rcs.output_bytes/1024/1024/1024 BCK_SIZE, 
 rcbsd.compressed, rcbsd.compression_Ratio, rcs.OBJECT_TYPE, rcbsd.completion_time
 from rc_rman_status rcs, rc_database rcd, rc_backup_set_details rcbsd
 where 
 rcs.db_key=rcd.db_key
 and rcs.db_key=rcbsd.db_key
 and rcd.dbid=2279678646
 and rcs.start_time > trunc(sysdate-3)
 order by rcs.start_time;
 
################################################################################################ 
 
 set lines 200
 set pages 5000
 col name for a100
 col status for a20
 
 REM STATUS: A (available), U (unavailable), D (deleted), or X (expired)
 
 select NAME, COMPLETION_TIME, ARCHIVED, STATUS 
 from "&RMAN_USER".RC_ARCHIVED_LOG where db_name ='&DBNAME' order by completion_time;
 
  REM STATUS: A (available), U (unavailable), D (deleted), or X (expired)
  
###############################################################################################




select 
DB_ID,
BACKUP_TYPE,
BYTES,
STATUS


 select rcd.dbid dbid, rcd.name name, rcs.session_key, rcs.start_time, rcs.OPERATION, rcs.STATUS, /*rcs.MBYTES_PROCESSED/1024 GB,*/
 sum(rcj.OUTPUT_BYTES)/1024/1024/1024 OUTPUT_GB, rcj.compression_Ratio compress_Ratio,/* rcj.elapsed_secods/60 sec*/
 rcs.OPTIMIZED, rcs.OBJECT_TYPE, rcs.end_time 
 from rc_rman_status rcs, rc_database rcd, rc_rman_backup_job_details rcj
 where 
 rcs.db_key=rcd.db_key
 and rcj.db_key=rcs.db_key
 and rcd.dbid=3916149112
 and rcs.start_time > trunc(sysdate-3)
 group by rcd.dbid, rcd.name, rcs.session_key, rcs.start_time, rcs.OPERATION, rcs.STATUS, rcj.compression_Ratio,rcs.OBJECT_TYPE, rcs.end_time ,rcs.OPTIMIZED
 order by rcs.start_time;



#####################################
###
### VER HISTORICO BACKUPS
###
#####################################


 alter session set nls_Date_format='dd/mm/yyyy hh24:mi';

select SESSION_KEY, /*SESSION_RECID, SESSION_STAMP,*/BCK_TYPE, BCK_CTRL,
START_TIME, DEVICE_TYPE, COMPRESSED, STATUS, ENCRYPTED, BACKED_BY_OSB,
sum(orig_size_GB) orig_size_GB, sum(compress_size_GB) compress_size_GB, trunc(avg(avg_compress_ratio),2) avg_compress_ratio,
trunc(sum(elapsed_seconds))
from
 (select rcbsd.SESSION_KEY  
 ,rcbsd.SESSION_RECID   
 ,rcbsd.SESSION_STAMP
 ,decode(rcbsd.BACKUP_TYPE,'D','FULL','I','INCR','L','ARCH') BCK_TYPE
 ,decode(rcbsd.CONTROLFILE_INCLUDED,'NONE','NO','BACKUP','YES') BCK_CTRL    
 --,rcbsd.INCREMENTAL_LEVEL 
 --,trunc(rcbsd.START_TIME) START_TIME
 ,to_char(rcbsd.START_TIME,'dd/mm/yyy hh24:mi') START_TIME
 ,rcbsd.ELAPSED_SECONDS 
 ,rcbsd.DEVICE_TYPE 
 ,rcbsd.COMPRESSED  
 ,trunc(rcbsd.ORIGINAL_INPUT_BYTES/1024/1024/1024,2) orig_size_GB
 ,trunc(rcbsd.OUTPUT_BYTES/1024/1024/1024,2) compress_size_GB
 ,trunc(rcbsd.COMPRESSION_RATIO,2) avg_compress_ratio
 ,rcs.STATUS    
 ,rcbsd.ENCRYPTED   
 ,rcbsd.BACKED_BY_OSB
 from rman.rc_backup_Set_Details rcbsd, rman.rc_database rcd, rman.rc_rman_status rcs
 where rcbsd.db_key=rcd.db_key 
 and rcd.dbid=3916083379 --&dbid
 and rcs.recid=rcbsd.session_recid
 and rcs.stamp=rcbsd.session_stamp
 --and session_recid=155
 --and session_stamp=1149891429
 and rcbsd.start_time>trunc(sysdate-5))
group by SESSION_KEY, SESSION_RECID, SESSION_STAMP,BCK_TYPE, BCK_CTRL, START_TIME, DEVICE_TYPE, COMPRESSED, STATUS, ENCRYPTED, BACKED_BY_OSB
order by start_time asc, session_stamp, BCK_TYPE
 ;
 
 
--------------------------------------------------------------------------

select SESSION_KEY, /*SESSION_RECID, SESSION_STAMP,*/BCK_TYPE, BCK_CTRL,TAG,
START_TIME, DEVICE_TYPE, COMPRESSED, STATUS, ENCRYPTED, BACKED_BY_OSB,
sum(orig_size_GB) orig_size_GB, sum(compress_size_GB) compress_size_GB, trunc(avg(avg_compress_ratio),2) avg_compress_ratio,
trunc(sum(elapsed_seconds))
from
 (select rcbsd.SESSION_KEY  
 ,rcbsd.SESSION_RECID   
 ,rcbsd.SESSION_STAMP
 ,rbp.tag
 ,decode(rcbsd.BACKUP_TYPE,'D','FULL','I','INCR','L','ARCH') BCK_TYPE
 ,decode(rcbsd.CONTROLFILE_INCLUDED,'NONE','NO','BACKUP','YES') BCK_CTRL    
 --,rcbsd.INCREMENTAL_LEVEL 
 --,trunc(rcbsd.START_TIME) START_TIME
 ,to_char(rcbsd.START_TIME,'dd/mm/yyy hh24:mi') START_TIME
 ,rcbsd.ELAPSED_SECONDS 
 ,rcbsd.DEVICE_TYPE 
 ,rcbsd.COMPRESSED  
 ,trunc(rcbsd.ORIGINAL_INPUT_BYTES/1024/1024/1024,2) orig_size_GB
 ,trunc(rcbsd.OUTPUT_BYTES/1024/1024/1024,2) compress_size_GB
 ,trunc(rcbsd.COMPRESSION_RATIO,2) avg_compress_ratio
 ,rcs.STATUS    
 ,rcbsd.ENCRYPTED   
 ,rcbsd.BACKED_BY_OSB
 from rman.rc_backup_Set_Details rcbsd, rman.rc_database rcd, rman.rc_rman_status rcs, RC_BACKUP_PIECE rbp
 where rcbsd.db_key=rcd.db_key 
 and rcd.dbid=3916083379 --&dbid
 and rcs.recid=rcbsd.session_recid
 and rcs.stamp=rcbsd.session_stamp
 and rcbsd.bs_key=rbp.bs_key
 --and session_recid=155
 --and session_stamp=1149891429
 and rcbsd.start_time>trunc(sysdate-5))
 where tag like 'TEST%'
group by SESSION_KEY, SESSION_RECID, SESSION_STAMP,BCK_TYPE, BCK_CTRL, START_TIME, DEVICE_TYPE, COMPRESSED, STATUS, ENCRYPTED, BACKED_BY_OSB,TAG
order by start_time asc, session_stamp, BCK_TYPE
 ;

