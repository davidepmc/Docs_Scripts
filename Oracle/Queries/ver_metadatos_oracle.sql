col fuente for a150 word_wrapped
set long 99999
set pages 50000
SELECT DBMS_METADATA.GET_DDL('PACKAGE', 'EVSTREAMINGAPI', 'EVHUB') fuente FROM DUAL;



SELECT DBMS_METADATA.GET_DDL('TABLE','RC_DTOEMPLE', 'C4ONLINE') fuente from dual;

SELECT DBMS_METADATA.GET_DDL('TABLESPACE','tablespace_name_name') fuente from dual;


SELECT DBMS_METADATA.GET_DDL('VIEW','V_OLTP_T_BG_CONCEPTOS', 'DMDBA') fuente from dual;

SELECT DBMS_METADATA.GET_DDL('INDEX','I_GLC_ARTPEDCOMP4_RTRIM', 'SMSEXP') fuente FROM DUAL;


SELECT DBMS_METADATA.GET_DDL('TRIGGER','LOGON_USER', 'SYS') fuente FROM DUAL;

SELECT DBMS_METADATA.GET_DDL('FUNCTION','INFORA_RTRIM', 'SYS') fuente FROM DUAL;

SELECT DBMS_METADATA.GET_DDL('FUNCTION',u.object_name, 'AD1DB2')
FROM dba_objects u
WHERE object_type = 'FUNCTION'
AND   object_name = 'SIMMINIMO';

SELECT DBMS_METADATA.GET_DDL('PACKAGE','EVPURGINGMGR', 'EVHUB') fuente from dual;

SELECT DBMS_METADATA.GET_DDL('PACKAGE_BODY',u.object_name, 'AD1DB2')
FROM dba_objects u
WHERE object_type = 'PACKAGE_BODY'
AND   object_name = 'DV_PROSIMDE';


SELECT DBMS_METADATA.GET_DDL('PROCEDURE', 'CHECKHOSTNAME', 'SYSTEM') fuente FROM DUAL;
FROM dba_objects u
WHERE object_type = 'PROCEDURE'
AND   object_name = 'CONSUMOSRESUMEN';

SELECT DBMS_METADATA.GET_DDL('PROFILE','USU_UCC') fuente from dual;

SELECT DBMS_METADATA.GET_DDL('USER', 'OPENACCESS') fuente from dual;

SELECT DBMS_METADATA.GET_DDL('DB_LINK',  'AUT_EXELNKAUT','PUBLIC') fuente from dual;

SELECT DBMS_METADATA.GET_DDL('MATERIALIZED_VIEW', 'VM_CMVIG_TH_PLANTILLA', 'CMRRHH1') fuente from dual;

SELECT DBMS_METADATA.GET_DDL('SEQUENCE', 'SQ_IDDATOSFILO', 'TEXAS') fuente from dual;

SELECT DBMS_METADATA.GET_DDL('SYNONYM', 'INFORA_ALTER_TABLE_TRG', 'PUBLIC') fuente from dual;

SELECT DBMS_METADATA.GET_DDL('TYPE', 'MOLECULE', 'ACDSPECMAN') fuente from dual;


SELECT DBMS_METADATA.GET_DDL('LIBRARY', '', 'ACDSPECMAN') fuente from dual;

SELECT DBMS_METADATA.GET_DDL('PROCOBJ', 'MGMT_STATS_CONFIG_JOB', 'ORACLE_OCM') fuente from dual;






