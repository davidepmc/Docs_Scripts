sqlplus "/as sysdba" <<eof
spool /oracle/ETP/util/monitoring/rendimiento.log app
@/oracle/ETP/util/monitoring/rendimiento.sql
spool off

exit
eof
