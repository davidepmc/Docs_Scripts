col username form A15
col sid form 9990
col type form A4
col lmode form 990
col request form 990
col id1 form 9999990
col id2 form 9999990

break on id1 skip 1 dup
spool /oracle/ETP/util/monitoring/logs_monitoring/ver_deadlokcs.sql

SELECT sn.username, m.sid, m.type,
   DECODE(m.lmode, 0, 'None'
                 , 1, 'Null'
                 , 2, 'Row Share'
                 , 3, 'Row Excl.'
                 , 4, 'Share'
                 , 5, 'S/Row Excl.'
                 , 6, 'Exclusive'
                 , lmode, ltrim(to_char(lmode,'990'))) lmode,
   DECODE(m.request, 0, 'None'
                 , 1, 'Null'
                 , 2, 'Row Share'
                 , 3, 'Row Excl.'
                 , 4, 'Share'
                 , 5, 'S/Row Excl.'
                 , 6, 'Exclusive'
                 , request, ltrim(to_char(request,'990'))) request,
         m.id1,m.id2
FROM v$session sn, V$lock m
WHERE (sn.sid = m.sid AND m.request != 0)
   OR (sn.sid = m.sid
      AND m.request = 0 AND lmode != 4
      AND (id1, id2 ) IN (SELECT s.id1, s.id2
                          FROM v$lock s
                          WHERE request != 0
                                 AND s.id1 = m.id1
                                 AND s.id2 = m.id2 )
      )
ORDER BY id1,id2, m.request;
spool off
clear breaks
