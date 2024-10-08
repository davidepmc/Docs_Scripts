Comprobamos el espacio utilizado y por que componene:

col "Space (M)" for 999,999.99 
col occupant_name for a40
col schema_name for a40
col move_procedure for a60 
set lines 250 pages 250
	
SELECT 
  occupant_name,  
  round( space_usage_kbytes/1024) "Space (M)",  
  schema_name, 
  move_procedure
FROM 
  v$sysaux_occupants  
ORDER BY 
  2 asc ;

Comprobamos cual es el intervalo de snapshots almacenados.

SELECT 
      snap_id, begin_interval_time, end_interval_time 
    FROM 
      SYS.WRM$_SNAPSHOT 
    WHERE 
      snap_id = ( SELECT MIN (snap_id) FROM SYS.WRM$_SNAPSHOT)
    UNION 
    SELECT 
    snap_id, begin_interval_time, end_interval_time 
   FROM 
     SYS.WRM$_SNAPSHOT 
   WHERE 
     snap_id = ( SELECT MAX (snap_id) FROM SYS.WRM$_SNAPSHOT)
   /

Ver tamaño de los objetos de SYSAUX

compute sum of MB break on report
col segment_name for a32
break on report

select segment_name, segment_type, sum(bytes)/1024/1024 MB
from dba_segments
where tablespace_name='SYSAUX'
group by segment_name, segment_type
order by 3 asc
;


Vemos las particiones de las tablas de AWR

select min(snap_id),min(sample_time),max(snap_id),max(sample_time) from sys.WRH$_ACTIVE_SESSION_HISTORY;

SELECT snap_interval, retention, most_recent_purge_time FROM sys.wrm$_wr_control;
select dbms_stats.get_stats_history_retention from dual;
select min(SNAP_ID),max(SNAP_ID),min(BEGIN_INTERVAL_TIME),max(END_INTERVAL_TIME) from dba_hist_snapshot;
select min(SNAP_ID),max(SNAP_ID),min(SAMPLE_TIME),max(SAMPLE_TIME) from WRH$_ACTIVE_SESSION_HISTORY;



--Check the number of Orphan Records

SELECT DBID, count(1)
FROM SYS.WRH$_ACTIVE_SESSION_HISTORY A
WHERE NOT EXISTS (
SELECT 1
FROM SYS.WRM$_SNAPSHOT
WHERE snap_id = a.snap_id
AND dbid = a.dbid
AND instance_number = a.instance_number
)
group by DBID;

select a.table_name, a.partition_name, sum(bytes)/1024/1024 from 
dba_tab_partitions a, dba_segments b
where a.table_name='WRH$_ACTIVE_SESSION_HISTORY'
and a.partition_name=b.partition_name
group by a.table_name, a.partition_name
order by 1,2;


select count(*) from SYS.WRH$_ACTIVE_SESSION_HISTORY partition (partition_name);


Purgamos los snapshot elegidos

BEGIN                                                               
  dbms_workload_repository.drop_snapshot_range(low_snap_id => 6864, high_snap_id=>20437);                                         
END;
/


Cambiar la retención del AWR
Para cambiar la retención es necesario también modificar la window_baseline, que debe ser menor o igual a la retencion del AWR:
 exec dbms_workload_repository.modify_baseline_windows_size(window_size=>nº días, dbid=>&dbid);
 
 exec dbms_workload_repository.modify_snapshot_settings(retention=>/*(30*24*60)*/ 1440, interval=>60, topnsql=>100 /*,dbid=>3351930156*/);
