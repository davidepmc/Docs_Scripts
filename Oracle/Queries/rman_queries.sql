select * from rman.rc_database;

select count (*) from rman.rc_backup_piece;

select * from rman.rc_site;

select * from rman.RC_BACKUP_SET;

select * from rman.rc_backup_piece where handle='vv1jrq8n_60415_1_1';

select  a.dbid, a.media , 'aws s3 ls --endpoint-url ${S3_ENDPOINT} s3://'|| SUBSTR(a.media, INSTR(a.media, '/') + 1)||'/file_chunk/' || a.dbid ||'/' MEDIA   from (
select rdb.dbid, rbp.* from rman.rc_database rdb, rman.rc_backup_piece rbp
where rdb.dbid=rbp.db_id
and rdb.dbid=3916149112
and rbp.device_type <> 'DISK'
) a;

select view_name from dba_views where owner='RMAN' order by 1;

select  a.dbid, a.media , 'aws s3 ls --endpoint-url ${S3_ENDPOINT} s3://'|| SUBSTR(a.media, INSTR(a.media, '/') + 1)||'/file_chunk/' || a.dbid ||'/ --summarize --human-readable ' from (
select rdb.dbid "DBID", rdb.name "DB_NAME", rs.db_unique_name "DB_UNIQUE_NAME", decode(rbp.backup_type,'D','FULL','I','INCR','L','ARCH') "TYPE", rbp.incremental_level "LEVEL", rbp.handle "HANDLE", 
rbp.start_time "START", rbp.completion_time "END", rbp.tag, rbp.media,
decode(rbp.status, 'A', 'AVAILABLE','U','UNAVAILABLE','D' ,'DELETED','X' ,'EXPIRED') "STATUS", rbp.bytes/1024/1024 "MB" 
from rman.rc_database rdb, rman.rc_backup_piece rbp, rman.rc_site rs
where rdb.dbid=rbp.db_id
 and rbp.site_KEY=rs.site_KEY
 and to_char(rbp.completion_time,'yyyy/mm/dd')<'2023/01/01'
 and media is not null
 and rbp.device_type <> 'DISK'
 ) a
 group by media, dbid /*, handle*/
 ;

-- Sacar carpetas de s3://besbckporawork/sbt_catalog anteriores al 2023/01/01

select  a.dbid, a.media , 'aws s3 ls --endpoint-url ${S3_ENDPOINT} s3://'|| SUBSTR(a.media, INSTR(a.media, '/') + 1)||'/sbt_catalog/' || a.handle ||'/' MEDIA from (
select rdb.dbid "DBID", rdb.name "DB_NAME", rs.db_unique_name "DB_UNIQUE_NAME", decode(rbp.backup_type,'D','FULL','I','INCR','L','ARCH') "TYPE", rbp.incremental_level "LEVEL", rbp.handle "HANDLE", 
rbp.start_time "START", rbp.completion_time "END", rbp.tag, rbp.media,
decode(rbp.status, 'A', 'AVAILABLE','U','UNAVAILABLE','D' ,'DELETED','X' ,'EXPIRED') "STATUS", rbp.bytes/1024/1024 "MB" 
from rman.rc_database rdb, rman.rc_backup_piece rbp, rman.rc_site rs
where rdb.dbid=rbp.db_id
 and rbp.site_key=rs.site_key
 and rdb.dbid not in (  select rdb.dbid "DBID"
 from rman.rc_database rdb, rman.rc_backup_piece rbp, rman.rc_site rs
 where rdb.dbid=rbp.db_id
 and rbp.site_key=rs.site_key
 and to_char(rbp.completion_time,'yyyy/mm/dd')>='2023/01/01'
 group by rdb.dbid)
 --and media is not null
 and rbp.device_type <> 'DISK'
 ) a
 group by media, dbid , handle
 ;
 
 select a.dbid, a.name from (
 select rdb.dbid, rdb.name, rbp.bp_key 
 from rman.rc_database rdb, rman.rc_backup_piece rbp 
 where rdb.dbid=rbp.db_id 
 and to_char(rbp.completion_time,'yyyy/mm/dd')<'2023/01/01'
 ) a
 group by dbid, name
 order by 2
 ; 

-- Sacamos informacion de los backups hechos despues de una fecha de todo el catalogo.

 select rdb.dbid "DBID", rdb.name "DB_NAME", decode(rbp.backup_type,'D','FULL','I','INCR','L','ARCH') "TYPE", rbp.incremental_level "LEVEL", rbp.handle "HANDLE", 
rbp.start_time "START", rbp.completion_time "END", rbp.tag, rbp.media,
decode(rbp.status, 'A', 'AVAILABLE','U','UNAVAILABLE','D' ,'DELETED','X' ,'EXPIRED') "STATUS", rbp.bytes/1024/1024 "MB"
 from rman.rc_database rdb, rman.rc_backup_piece rbp
 where rdb.dbid=rbp.db_id
 and to_char(rbp.completion_time,'yyyy/mm/dd')'2023/01/01'
 order by rbp.start_time asc;
 
 -- Sacamos el DBID, DB_NAME por cada bbdd que tiene backups anteriores a una fecha
 
 select a.dbid, a.db_name, a.rol from (
  select rdb.dbid "DBID", rdb.name "DB_NAME", rs.database_role "ROL", rs.db_unique_name "DB_UNIQUE_NAME", max(to_char(rbp.start_time,'yyyy/mm/dd')) "START", max(to_char(rbp.completion_time,'yyyy/mm/dd')) "END"
 from rman.rc_database rdb, rman.rc_backup_piece rbp, rman.rc_site rs
 where rdb.dbid=rbp.db_id
 and rbp.site_KEY=rs.site_KEY
 and to_char(rbp.completion_time,'yyyy/mm/dd')<'2023/01/01'
 group by rdb.dbid, rdb.name, rs.database_role, rbp.start_time,rbp.completion_time,rs.db_unique_name) A GROUP BY DBID, db_name, rol order by dbid,db_name;

-- Sacamos el DBID de las BBDD que tienen backups posteriores a la fecha

 select a.dbid from (
  select rdb.dbid "DBID", rdb.name "DB_NAME", rs.db_unique_name "DB_UNIQUE_NAME", max(to_char(rbp.start_time,'yyyy/mm/dd')) "START", max(to_char(rbp.completion_time,'yyyy/mm/dd')) "END"
 from rman.rc_database rdb, rman.rc_backup_piece rbp, rman.rc_site rs
 where rdb.dbid=rbp.db_id
 and rbp.site_key=rs.site_key
 and to_char(rbp.completion_time,'yyyy/mm/dd')>='2023/01/01'
 group by rdb.dbid, rdb.name,rbp.start_time,rbp.completion_time,rs.db_unique_name) A GROUP BY DBID, db_name order by dbid, db_name; 
 
 
 
 -- Sacamos el DBID, DB_NAME, DB_UNIQUE_NAME por cada bbdd que tiene backups anteriores a una fecha
 
 select a.dbid, a.db_name,  a.db_unique_name, a.rol from (
  select rdb.dbid "DBID", rdb.name "DB_NAME", rs.db_unique_name "DB_UNIQUE_NAME", rs.database_role "ROL", max(to_char(rbp.start_time,'yyyy/mm/dd')) "START", max(to_char(rbp.completion_time,'yyyy/mm/dd')) "END"
 from rman.rc_database rdb, rman.rc_backup_piece rbp, rman.rc_site rs
 where rdb.dbid=rbp.db_id
 and rbp.site_KEY=rs.site_KEY
 and to_char(rbp.completion_time,'yyyy/mm/dd')<'2023/01/01'
 group by rdb.dbid, rdb.name,rbp.start_time,rbp.completion_time,rs.db_unique_name, rs.database_role) A GROUP BY DBID, db_name, DB_UNIQUE_NAME, rol order by db_name, rol;
 
 

  select rdb.dbid "DBID"
 from rman.rc_database rdb, rman.rc_backup_piece rbp, rman.rc_site rs
 where rdb.dbid=rbp.db_id
 and rbp.site_key=rs.site_key
 and to_char(rbp.completion_time,'yyyy/mm/dd')>='2023/01/01'
 group by rdb.dbid;

 