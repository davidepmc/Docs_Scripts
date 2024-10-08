select sn.name "NOMBRE", decode (sn.class,1 , 'USER', 2, 'REDO', 4, 'ENQUEUE', 8, 'CACHE', 16, 'OS', 32, 'RAC', 64, 'SQL', 128, 'DEBUG') "TIPO", ss.value "VALOR"
from v$sesstat ss, v$statname sn 
where ss.statistic#=sn.statistic# 
and ss.value != 0
and ss.sid = &SID;
