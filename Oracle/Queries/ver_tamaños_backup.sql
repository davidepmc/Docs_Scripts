  select DB_NAME, INPUT_TYPE, STATUS, to_char(START_TIME,'dd/mm/yy hh24:mi') FECHA_INICIO,
         to_char(END_TIME,'mm/dd/yy hh24:mi')   FECHA_FIN,
         round(elapsed_seconds/60)              MINUTOS,
         round(INPUT_BYTES/1024/1024/1024,2)    GB
  from RMAN.RC_RMAN_BACKUP_JOB_DETAILS
  where
    STATUS='COMPLETED' AND INPUT_TYPE='DB FULL'
  and START_TIME > sysdate-7 and START_TIME < sysdate -1
 order by DB_NAME, START_TIME;
