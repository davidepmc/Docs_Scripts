useme ()
{
        echo ""
        echo "Use: $0 [directorio] [script a ejecutar sin extension (debe ser .sql)] [usuario] [cadena de conexion]"
        echo " Example: $0 directorio modif124 GEE genesis"
        exit 2
}

if [ $# = 4 ]
then

DIRSCRIPTS=$1
DIRLOG=$DIRSCRIPTS/log
SCRIPT=$DIRSCRIPTS/$2.sql
USUARIO=$3
CADENADECONEXION=$4

########### Defimos los usuarios o la cadena de que identifique a cada usuario, en este caso los usuarios son GEExx
for i in 01
#for i in 01 02 03 04 07 09 10 13 14 15 16 18 20 21 23 24 26 27 29 31 32 33 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 52 63 66 ES
#for i in 02 03 04 07 09 10 13 14 15 16 18 20 21 23 24 26 27 29 31 32 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 52 63 66
do
    echo "

########### Nos conectamos con el usuario correspondiente.

CONN $USUARIO${i}/$USUARIO${i}@$CADENADECONEXION

-- Definimos la vatiable delegacion (puede ser llamada como se quiera) para que podamos exportar $i a scripts
-- que llamemos mediante @SCRIPT
define delegacion=$i

set echo off
set feed on
set pagesize 5000

spool $DIRLOG/$2${i}.LOG

-- @SCRIPT

-- Definimos las querys que queremos ejecutar
create index remesa_tipo_contenedor_idx on GEPR_TINFORM_ADI_CLIENTE col (OID_REMESA, COD_TIPO_CONTENEDOR) tablespace geees;
create index termino_iac_idx on GEPR_TVALOR_POSIBLE col (OID_TERMINO_IAC) tablespace geees;

-- Definición completada

spool off

exit

" > $DIRLOG/create_index_delegaciones.log

sqlplus /nolog @$DIRLOG/create_index_delegaciones.log 

done

else
        useme
fi
