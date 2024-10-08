# DEFINIMOS LA LOCALIACIÓN DEL TNSNAMES
export TNS_ADMIN=/tmp

# DEFINIMOS LA LOCALIACION DEL LOG
LOG_ARCHIVE=/tmp/script_`date +"%Y%m%d"`.txt


echo "


" >> $LOG_ARCHIVE

# ENCONTRAMOS LA CADENA DE CONEXION DEL FICHERO TNSNAMES

for SID in `awk '$1 !~ /^\(/ && $1 !~ /^\)/ && $1 !~ /^#/ && $0 ~ /[^ ]/  { print $1 }' $TNS_ADMIN/tnsnames.ora`
do
echo "Conectando a $SID"

# CONECTAMOS A $SID CON EL USUARIO QUE NECESITEMOS
sqlplus -S DATAP/c0ronilla@$SID << ini_sql
set pagesize 0
set feedback off
set linesize 100

spool $LOG_ARCHIVE 

/* Escribimos las sentencias que queremos que se ejecuten */

grant create  table to M4PSPNES, M4PSKSPT, M4PSPNESDI;

!cat $LOG_ARCHIVE >> $HOME/scripts/monitor/USUARIOS_DBA.txt
ini_sql

done


