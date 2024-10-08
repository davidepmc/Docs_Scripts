 SELECT ms.value
  FROM   v$mystat ms,
         v$statname sn
  WHERE  ms.statistic# = sn.statistic#
  AND    sn.name like '%redo%';
  RETURN l_return;