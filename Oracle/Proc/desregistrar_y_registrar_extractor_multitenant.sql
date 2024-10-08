DESREGISTRAR EXTRACTOR:

stop extractor:
    source /home/oracle/ora_ogg.env
    gi
    info all
    stop EXC03GLP
    info all



remove extractor:
 source /home/oracle/ora_ogg.env
    gi
    info all
    dblogin USERIDALIAS c03glpro
    unregister extract EXC03GLP database
    delete EXC03GLP
    info all



REGISTRAR EXTRACTOR:

registrar extractor:
source /home/oracle/ora_ogg.env
    gi
	add extract EXC03GLP, integrated tranlog, begin now
	add exttrail /mnt/goldengate/c03glpro/trails/e1, extract EXC03GLP, megabytes 1024
	dblogin USERIDALIAS c03glpro
	register extract EXC03GLP database container(BGAPX003PRO)
	start EXC03GLP