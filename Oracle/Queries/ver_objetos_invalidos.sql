set linesize 100
col object_name for a30
SELECT object_name,owner,object_type from dba_objects where status <> 'VALID'
and object_name not like 'BIN$%' and object_type <> 'SYNONYM'
and owner not in ('SYS','SYSTEM');