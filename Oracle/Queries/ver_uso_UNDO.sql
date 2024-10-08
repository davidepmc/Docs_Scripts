##########################################
#                                        #
#    Ver utilizacion tablespace UNDO     #
#                                        #
##########################################

col machine for a35
col username for a15
set lines 200
set pages 200

select owner, segment_name, SUM(BYTES/1024/1024) USED_MB, COUNT(*), status 
from  dbA_undo_extents 
group by owner, segment_name, status
order by USED_MB desc;


select sid,username,program,machine,(USED_UBLK*8)/1024 MB_USED
from v$transaction t, v$session s
where SES_ADDR = s.saddr;

select sid,username,program,machine,(USED_UBLK*8)/1024 MB_USED
from v$transaction t, v$session s
where SES_ADDR = s.saddr
and s.sql_id='&sql_id';


#########################################
#					#
#   Estimar tamaño undo tablespace	#
#					#
#########################################

SELECT ((UR * (UPS * DBS)) + (DBS * 24))/1024/1024 AS "MB" 
FROM (SELECT value AS UR FROM v$parameter WHERE name = 'undo_retention'), 
(SELECT (SUM(undoblks)/SUM(((end_time - begin_time)*86400))) AS UPS FROM v$undostat), 
(select block_size as DBS from dba_tablespaces where tablespace_name= 
(select value from v$parameter where name = 'undo_tablespace'));
