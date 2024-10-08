Comprobamos el espacio utilizado y por que componene:

set lines 200
col occupant_name for a40
col schema_name for a40
col move_procedure for a60

SELECT 
  occupant_name,  
      round( space_usage_kbytes/1024) "Space (M)",  
      schema_name, 
      move_procedure
    FROM 
      v$sysaux_occupants  
    ORDER BY 
      1  
   /

Ver tamaño de los objetos de SYSAUX

compute sum of MB break on report
break on report

select segment_name, segment_type, sum(bytes)/1024/1024 MB
from dba_segments
where tablespace_name='SYSAUX'
group by segment_name, segment_type
order by 3 asc


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


Purgamos los snapshot elegidos

BEGIN                                                               
  dbms_workload_repository.drop_snapshot_range(low_snap_id => 25096, high_snap_id=>25400);                                         
END;
/
