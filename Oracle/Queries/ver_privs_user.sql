set lines 135
col table_name for a30
col column_name for a30

--spool /oracle/ETPP/util/monitoring/logs_monitoring/privs_&&USUARIO

prompt ----Privilegios de &&USUARIO sobre cualquier tabla----


select grantee, owner, table_name, privilege from dba_tab_privs where grantee= upper('E057419');

prompt ----Privilegios de &&USUARIO sobre cualquier columna----


select grantee, owner, table_name, column_name,  privilege from dba_col_privs where grantee= upper('E057419');

prompt ----Privilegios del sistema de &&USUARIO----


select * from dba_sys_privs where grantee= upper('E057419');


select * from dba_role_privs where grantee= upper('E057419');
select * from dba_role_privs where grantee= upper('QAPRO');


undefine USUARIO;

spool off

