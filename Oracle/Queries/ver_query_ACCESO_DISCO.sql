ACCEPT DAY  PROMPT 'Day to monitor (DD/MM/RRRR) -> '
ACCEPT orderBy  PROMPT 'Enter order criteria [execs|elap|cpu|gets|physical]  -> '

set pages 200000
set linesize 200
col snaps for a27
BREAK on Snaps skip 1
set pages 200
col "Buffer Gets" for 999,999,999,999
col "Physical I/O" for 999,999,999,999
col "Elap [s]" for 999,999
col "Cpu [s]" for 999,999
col "Execs" for 99,999,999
col pos noprint

SELECT * FROM (
SELECT 
to_char(snap_id-1) || '-' || to_char(snap_id) || '(' ||inter || ')'  "Snaps",
sql_id "SQL ID",
elap "Elap [s]",
cpu "Cpu [s]",
execs "Execs",
gets "Buffer Gets" ,
Physical "Physical I/O",
PLAN_HASH_VALUE "Plan Hash",
ROW_NUMBER()  OVER (PARTITION BY  snap_id ORDER BY (&orderBy) desc ) pos
FROM 
(
  SELECT
    hist.snap_id,
    to_char(hist.begin_interval_time,'hh24:mi') || '-' ||  to_char(hist.end_interval_time,'hh24:mi') inter,
    sql_id,
    sqls.EXECUTIONS_DELTA execs,
    round(sqls.ELAPSED_TIME_DELTA/1000000) Elap,	
    round(sqls.CPU_TIME_DELTA/1000000)  Cpu,
    sqls.BUFFER_GETS_DELTA Gets,
    sqls.DISK_READS_DELTA Physical,
    sqls.PLAN_HASH_VALUE 
  FROM sys.WRH$_SQLSTAT sqls, DBA_HIST_SNAPSHOT hist
  WHERE
    hist.snap_id = sqls.snap_id
    -- and sql_id in ( Select distinct SQL_ID from dba_hist_sql_plan where object_name like '%NOMBRE_OBJETO' )
    AND sqls.EXECUTIONS_DELTA IS NOT NULL AND sqls.ELAPSED_TIME_DELTA IS NOT NULL AND sqls.CPU_TIME_DELTA IS NOT NULL
    AND sqls.BUFFER_GETS_DELTA IS NOT NULL AND sqls.DISK_READS_DELTA IS NOT NULL
    and sqls.SNAP_ID IN (SELECT SNAP_ID from DBA_HIST_SNAPSHOT where end_interval_time >= to_date('&DAY','dd/mm/rrrr')
    and end_interval_time < to_date('&DAY','dd/mm/rrrr')+1)
) sqls)
where pos <= 5;