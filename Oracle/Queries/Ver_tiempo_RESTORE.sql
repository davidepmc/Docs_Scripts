col pdte hea "Mb Pendiente" for 999990;
col segs hea Segs for 99990;
col hecho hea "Mb realizado" for 999990;
col total hea "Mb Total" for 999990;
col vel hea "Mb/seg" for 990.90;
col pct hea "% Realizado" for 990.90;
col final hea "Finaliza" for A8;
select 
        sid,opname,
        TOTALWORK*(value/1024/1024) total,
        SOFAR*(value/1024/1024) hecho,
        (TOTALWORK-SOFAR)*(value/1024/1024) pdte,
        round(sofar/totalwork*100,2) pct,
        round(mod(to_char(sysdate,'HH24')+((((TOTALWORK-SOFAR)*(value/1024/1024))/(sofar*(value/1024)/1024/decode(elapsed_seconds,0,1,elapsed_seconds)))/60/60),60))||
':'||trunc(mod(to_char(sysdate,'MI')+(((TOTALWORK-SOFAR)*(value/1024/1024))/(sofar*(value/1024)/1024/decode(elapsed_seconds,0,1,elapsed_seconds)))/60,60)) final
from v$session_longops,v$parameter
where opname like 'RMAN%'
and name = 'db_block_size'
and (totalwork-sofar) > 0
order by pdte,totalwork
/