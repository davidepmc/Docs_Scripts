
VER SI TENEMOS TRANSACCIONES DISTRIBUIDAS
------------------------------------------

select LOCAL_TRAN_ID, GLOBAL_TRAN_ID, STATE, FAIL_TIME, RETRY_TIME from dba_2pc_pending;


HACEMOS ROLLBACK DE LA TRANSACCION, PARA ELLO USAMOS LOCAL_TRAN_ID
------------------------------------------------------------------

ROLLBACK FORCE '&LOCAL_TRAN_ID';


SI FALLA, PODEOS EJECUTAR EL PROCEDIMIENTO PARA PURGAR LAS TRANSACCIONES DISTRIBUIDAS
-------------------------------------------------------------------------------------

execute sys.dbms_transaction.purge_lost_db_entry('&LOCAL_TRAN_ID')


-- Al ejecutar podría darse este error (aparecido en SIEBEL Oracle 9.2)

ORA-30019: Illegal rollback Segment operation in Automatic Undo mode

Para ello es necesario realizar el siguiente workaround:
column Parameter format a35 
column "Session Value" format a15 
column "Instance Value" format a15 

SELECT a.ksppinm "Parameter", b.ksppstvl "Session Value", c.ksppstvl "Instance Value" 
FROM x$ksppi a, x$ksppcv b, x$ksppsv c 
WHERE a.indx = b.indx AND a.indx = c.indx AND a.ksppinm LIKE '/_%' escape '/' AND a.ksppinm like '%smu_debug_mode%' / 
-- set it temporarily to 4:


SQL> alter system set "_smu_debug_mode" = 4; -- in 9.2x alter session can be used instead.
SQL> commit;

SQL>execute DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('local_tran_id');
SQL> commit; 
SQL> alter system set "_smu_debug_mode" = ; 
SQL> commit;


COMPROBAMOS QUE LA TRANSACCION YA NO ESTÁ
------------------------------------------

select LOCAL_TRAN_ID, GLOBAL_TRAN_ID, STATE, FAIL_TIME, RETRY_TIME from dba_2pc_pending;

