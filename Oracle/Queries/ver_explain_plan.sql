explain plan for
query
;

@?/rdbms/admin/utlxpls.sql


#################################################
##                                             ##
##  VER EXPLAIN PLAN POR HASH                  ##
##                                             ##
#################################################

--UNDEF SQL_ID
--ACCEPT SQL_ID PROMPT 'Introduce el SQL_ID de la query: '


--select distinct plan_hash_value from dba_hist_sqlstat where sql_id='&SQL_ID';

SELECT * FROM table (dbms_xplan.display_awr('&SQL_ID','&HASH'));

# Sentencia donde ver el orden de acceso de las tablas

select * from table(dbms_xplan.display_cursor(null,null,'iostats last'));