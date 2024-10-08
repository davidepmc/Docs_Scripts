asmcmd

pwcopy --dbuniquename bmapx001_tcc '/u01/app/oracle/product/19131/dbhome_1/dbs/orapwbmapx001' '+ORAAWS06_BMAPX001_DATA/BMAPX001_TCC/PASSWORD/orapwbmapx001'


srvctl  modify database -db bmapx001_tcc -pwfile '+ORAAWS06_BMAPX001_DATA/BMAPX001_TCC/PASSWORD/orapwbmapx001' 
