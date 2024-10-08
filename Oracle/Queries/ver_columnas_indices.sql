set lines 200
col table_name for a30
col column_name for a30

break on index_name skip 1

select di.table_name, di.index_name, di.index_type, dic.column_name from dba_indexes di, dba_ind_columns dic
where di.index_name = dic.index_name 
and di.table_name = '&table_name'
order by 1,2,dic.column_position;
