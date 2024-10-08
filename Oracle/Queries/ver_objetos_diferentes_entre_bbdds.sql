## CREACION DEL USUARIO Y DEL DB_LINK

create user david identified by sonr22sa;

grant create session, select any table, select any dictionary, create database link to david;


create database link pruebas_david
connect to datap identified by c0ronilla
using 'DWCSA_WIND';


## NECESARIA MODIFICACION DEL TNSNAMES DE ORIGEN


##QUERYS A LANZAR CON MINUS/UNION/UNION ALL/INTERSECT

select a.table_name, a.index_name, a.column_name, b.index_type, column_position, column_length 
from dba_ind_columns a, dba_indexes b
where a.index_name=b.index_name
and a.table_name like 'GS%'
minus
select a.table_name, a.index_name, a.column_name, b.index_type, column_position, column_length 
from dba_ind_columns@pruebas_david a, dba_indexes@pruebas_david b
where a.index_name=b.index_name
and a.table_name like 'GS%'
order by 1,2,3;


select a.table_name, a.index_name, a.column_name, b.index_type, column_position, column_length 
from dba_ind_columns@pruebas_david a, dba_indexes@pruebas_david b
where a.index_name=b.index_name
and a.table_name like 'GS%'
intersect
select a.table_name, a.index_name, a.column_name, b.index_type, column_position, column_length 
from dba_ind_columns a, dba_indexes b
where a.index_name=b.index_name
and a.table_name like 'GS%'
order by 1,2,3;


select owner, object_type, object_name
from dba_objects
where owner in ('GCCDATAM','CSA','DMDBA')
and object_type <> 'INDEX'
AND STATUS='INVALID'
intersect
select owner, object_type, object_name
from dba_objects@pruebas_david
where owner in ('GCCDATAM','CSA','DMDBA')
AND STATUS='VALID'
order by 1,2,3;