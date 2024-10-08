
SET ECHO OFF
ALTER SESSION SET nls_language='English';
SET LINES 128
BREAK ON yw SKIP 2 ON dy SKIP 1
COMPUTE SUM of ttl_wait_time ON yw
--
COL yw NOPRINT
COL dy NOPRINT
COL day           FOR A18
COL object_name   FOR A25 TRUNC
COL object_type   FOR A5  TRUNC HEAD TYPE
COL event         FOR A35
COL wait_class    FOR A13
COL ttl_wait_time FOR 999,999,999,990
--
SELECT TO_CHAR(h.sample_time, 'YYYYIW')       yw,
       TO_CHAR(h.sample_time, 'MMDD')   dy,
       TO_CHAR(h.sample_time, 'DY DD_MON_YYYY')  day,
       o.object_name,
       o.object_type,
       h.event,
       e.wait_class,
       SUM(h.wait_time +
           h.time_waited) ttl_wait_time
  FROM 
       dba_hist_active_sess_history h,
       dba_objects                  o,
       v$system_event               e
 WHERE 
       h.current_obj#   = o.object_id
   AND h.event LIKE 'enq%'
   AND e.event   = h.event
HAVING
       SUM(h.wait_time + h.time_waited)>100000
 GROUP 
    BY TO_CHAR(h.sample_time, 'YYYYIW'),
       TO_CHAR(h.sample_time, 'MMDD'),
       TO_CHAR(h.sample_time, 'DY DD_MON_YYYY'),
       o.object_name, o.object_type, h.event, e.wait_class
 ORDER
    BY TO_CHAR(h.sample_time, 'YYYYIW'),
       TO_CHAR(h.sample_time, 'MMDD'),
       SUM(h.wait_time + h.time_waited) DESC
/
--
CLEAR COLUMNS
SET ECHO ON
