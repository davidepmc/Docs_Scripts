set linesize 135
col COLUMN_NAME for a30
col INDEX_NAME for a30 
col INDEX_TYPE for a10 
col TABLE_NAME for a40 

SELECT a.index_name,a.index_type, a.uniqueness, a.join_index, a.table_name,b.column_name from DBA_INDEXES a, DBA_IND_COLUMNS b WHERE a.index_name = b.index_name and a.table_name like '%&TABLA%'
/
