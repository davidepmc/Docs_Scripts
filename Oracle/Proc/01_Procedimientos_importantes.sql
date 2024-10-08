###########################################
#####   Procedimientos Interesantes   #####
###########################################

Notas importantes de METALINK


106285.1  --> TROUBLESHOOTING GUIDE: Common Performance Tuning Issues
153788.1  --> Ora 600 lookup
169706.1  --> Requisitos para instalar Oracle
188135.1  --> Index for RAC
248971.1  --> Query tuning best practices
215020.1  --> Toubleshooting logical standby
228913.1  --> Systemwide Tuning using StatsPack Reports
233112.1  --> Diagnosing Query Tuning Problems 
343424.1  --> Creacion Standby fisica con actualizaci�n en tiempo real
387266.1  --> Data Guard Swichtover and failover best practices
394937.1  --> Statspack guide
459411.1  --> Recreate a physical standby controlfile
61730.1   --> DBMS Job package
819533.1  --> Ver objetos de los bloques corruptos de ORA-01578



###########################################
####  Auditoría
###########################################


----  Activar auditoría (por defecto va al tbs de system si no se especifica lo contrario)




----  Mover tabla de auditoría de tablespace SYSTEM a otro tbs

Oracle 11g:

exec DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_DB_STD, audit_trail_location_value =>  '&tablespace_audit');


###########################################
#### Transacciones Distribuidas
###########################################

Se localizan las transacciones distribuidas

SELECT * FROM DBA_2PC_PENDING;

ALTER SYSTEM DISABLE DISTRIBUTED RECOVERY ;

Para cada LOCAL_TRAN_ID (este execute debe ser el primer elemento de una transacción si no sale un error ORA-01453: SET TRANSACTION must be first statement of transaction, en este caso lanzamos un commit o un rollback y repetimos )

exec DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('50.7.2682')
commit;

Si sale:

SQL> exec DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('50.7.2682')
BEGIN DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('50.7.2682'); END;
*
ERROR at line 1:
ORA-30019: Illegal rollback Segment operation in Automatic Undo mode
ORA-06512: at "SYS.DBMS_TRANSACTION", line 65
ORA-06512: at "SYS.DBMS_TRANSACTION", line 85
ORA-06512: at line 1

SQL> alter session set undo_suppress_errors=TRUE;
Session altered.

SQL> exec DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('50.7.2682')
PL/SQL procedure successfully completed.


