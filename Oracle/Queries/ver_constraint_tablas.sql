set lines 135
col CONSTRAINT_NAME for a20
col COLUMN_NAME for a20
col table_name for a30

select t1.CONSTRAINT_NAME, t1.CONSTRAINT_TYPE, c1.column_name, 
t2.CONSTRAINT_NAME, t2.CONSTRAINT_TYPE, t2.table_name, c2.column_name
 from dba_constraints t1, dba_constraints t2, dba_cons_columns c1, dba_cons_columns c2
  where t1.table_name = '&TABLA' AND
  T1.CONSTRAINT_NAME = T2.R_CONSTRAINT_NAME and
  t1.CONSTRAINT_NAME = c1.CONSTRAINT_NAME and
  t2.CONSTRAINT_NAME = c2.CONSTRAINT_NAME;



