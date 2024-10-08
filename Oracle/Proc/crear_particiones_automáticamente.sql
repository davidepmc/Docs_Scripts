#!/usr/bin/ksh
export ORACLE_SID=BRIDGEH
. $HOME/orauser11g

LOG_DIR=$HOME/admin/scripts/logs
set -x
LOG_BASH=$LOG_DIR/ParticionesBRIDGE_bash.`date +"%Y%m%d%H%M"`.log
LOG_SQL=$LOG_DIR/ParticionesBRIDGE_sql.`date +"%Y%m%d%H%M"`.log
exec > $LOG_BASH 2>&1

sqlplus -S / << INI_SQL
WHENEVER SQLERROR EXIT sql.sqlcode

spool $LOG_SQL

-- Borra las particiones del cuarto mes anterior a la fecha de ejecucion y crea la del segundo mes posterior
-- TABLAS: META4PRO.CSP_IF_M4_SIP2K, META4PRO.P_PT_CSP_IF_M4_SIP2K, META4PRO.P_PT_CSP_IF_M4_SIP2K_PCP
--         META4PRO.P_CSP_IF_M4_SIP2K, META4PRO.P_CSP_IF_M4_SIP2K_PCP

set serveroutput on
set lines 132 

declare
v_ErrorText VARCHAR2(200);    -- Variable to hold the error message text
v_TableName VARCHAR2(50);     -- Variable to hold table name

begin

    DBMS_OUTPUT.put_line('********************* Tabla META4PRO.CSP_IF_M4_SIP2K: **********************************************'); 

    execute immediate 'alter table meta4pro.CSP_IF_M4_SIP2K drop partition P_'||to_char(add_months(sysdate,-4),'yymm');
    
    execute immediate 'alter table meta4pro.CSP_IF_M4_SIP2K add partition P_'||to_char(add_months(sysdate,2),'yymm')||
                      ' VALUES LESS THAN (to_date('''||'01/'||to_char(add_months(sysdate,3),'mm/yyyy')||' 00:00:00'''||
                      ','||'''dd/mm/yyyy hh24:mi:ss'''||'))';
                       
    DBMS_OUTPUT.put_line('Ejecucisn correcta.');          
            
   
    DBMS_OUTPUT.put_line('********************* Tabla META4PRO.P_CSP_IF_M4_SIP2K: **********************************************'); 

    execute immediate 'alter table meta4pro.P_CSP_IF_M4_SIP2K drop partition P_'||to_char(add_months(sysdate,-4),'yymm');
    
    execute immediate 'alter table meta4pro.P_CSP_IF_M4_SIP2K add partition P_'||to_char(add_months(sysdate,2),'yymm')||
                      ' VALUES LESS THAN (to_date('''||'01/'||to_char(add_months(sysdate,3),'mm/yyyy')||' 00:00:00'''||
                      ','||'''dd/mm/yyyy hh24:mi:ss'''||'))';
                       
    DBMS_OUTPUT.put_line('Ejecucisn correcta.');          
            
    DBMS_OUTPUT.put_line('********************* Tabla META4PRO.P_CSP_IF_M4_SIP2K_PCP: *****************************************'); 

    execute immediate 'alter table meta4pro.P_CSP_IF_M4_SIP2K_PCP drop partition P_'||to_char(add_months(sysdate,-4),'yymm');
    
    execute immediate 'alter table meta4pro.P_CSP_IF_M4_SIP2K_PCP add partition P_'||to_char(add_months(sysdate,2),'yymm')||
                      ' VALUES LESS THAN (to_date('''||'01/'||to_char(add_months(sysdate,3),'mm/yyyy')||' 00:00:00'''||
                      ','||'''dd/mm/yyyy hh24:mi:ss'''||'))';
                       
    DBMS_OUTPUT.put_line('Ejecucisn correcta.');          
            
   
   
    DBMS_OUTPUT.put_line('********************* Tabla META4PRO.P_PT_CSP_IF_M4_SIP2K: *****************************************'); 
   
    execute immediate 'alter table meta4pro.P_PT_CSP_IF_M4_SIP2K drop partition P_'||to_char(add_months(sysdate,-4),'yymm');
    
    execute immediate 'alter table meta4pro.P_PT_CSP_IF_M4_SIP2K add partition P_'||to_char(add_months(sysdate,2),'yymm')||
                      ' VALUES LESS THAN (to_date('''||'01/'||to_char(add_months(sysdate,3),'mm/yyyy')||' 00:00:00'''||
                      ','||'''dd/mm/yyyy hh24:mi:ss'''||'))';
                       
    DBMS_OUTPUT.put_line('Ejecucisn correcta.');
    

    DBMS_OUTPUT.put_line('********************* Tabla META4PRO.P_PT_CSP_IF_M4_SIP2K_PCP: ************************************'); 
      
    execute immediate 'alter table meta4pro.P_PT_CSP_IF_M4_SIP2K_PCP drop partition P_'||to_char(add_months(sysdate,-4),'yymm');
    
    execute immediate 'alter table meta4pro.P_PT_CSP_IF_M4_SIP2K_PCP add partition P_'||to_char(add_months(sysdate,2),'yymm')||
                      ' VALUES LESS THAN (to_date('''||'01/'||to_char(add_months(sysdate,3),'mm/yyyy')||' 00:00:00'''||
                      ','||'''dd/mm/yyyy hh24:mi:ss'''||'))';
                      
    DBMS_OUTPUT.put_line('Ejecucisn correcta.');            
           
    dbms_stats.gather_table_stats('META4PRO','P_PT_CSP_IF_M4_SIP2K_PCP',cascade=>true,estimate_percent=>5,degree=>2);
    dbms_stats.gather_table_stats('META4PRO','P_CSP_IF_M4_SIP2K',cascade=>true,estimate_percent=>5,degree=>2);
    dbms_stats.gather_table_stats('META4PRO','P_PT_CSP_IF_M4_SIP2K',cascade=>true,estimate_percent=>5,degree=>2);
    dbms_stats.gather_table_stats('META4PRO','CSP_IF_M4_SIP2K',cascade=>true,estimate_percent=>5,degree=>2);
    dbms_stats.gather_table_stats('META4PRO','P_CSP_IF_M4_SIP2K_PCP',cascade=>true,estimate_percent=>5,degree=>2);

EXCEPTION
    when others then
    v_ErrorText := SUBSTR(SQLERRM(SQLCODE), 1, 200);
    DBMS_OUTPUT.put_line(v_ErrorText); 
end;
/

spool off

exit

INI_SQL
error=$?
if [ $error -ne 0 ]
then
  MENSAJE="ERROR EN EL EL BORRADO DE PARTICIONES EN LA BD $ORACLE_SID EN $HOST (Abrid incidencia. No llamad a Guardia)"
  mailx -s "$MENSAJE \n" Dti.Expl-Operaciones@prosegur.com < $LOG_BASH
  echo $MENSAJE
fi

find $LOG_DIR -name "ParticionesBRIDGE_bash.*.log.gz" -mtime +60 -exec rm {} \;
find $LOG_DIR -name "ParticionesBRIDGE_sql.*.log.gz" -mtime +60 -exec rm {} \;

/usr/contrib/bin/gzip $LOG_SQL
/usr/contrib/bin/gzip $LOG_BASH

exit $error
