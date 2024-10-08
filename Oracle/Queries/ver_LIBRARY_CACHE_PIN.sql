Comprobar si hay LIBRARY_CACHE_PIN

SQL> 
select count(*), event from v$session_wait
where wait_time=0 group by event;  2

  COUNT(*) EVENT
---------- ----------------------------------------
         4 HS message to agent
       508 SQL*Net message from client
         7 db file sequential read
        10 i/o slave wait
         4 jobq slave wait
        27 library cache pin
         1 pipe get
         1 pmon timer
         8 rdbms ipc message
         1 smon timer

Hay que ver qué sesión está provocando estos eventos de espera de library cache pin (utilizo el maravilloso script de Marta “Ver Library”)

SQL> conn /as sysdba
Connected.

SQL>
COLUMN EVENT FORMAT A30
SET VERIFY OFF
SELECT EVENT,P1RAW "P1 EN HEXADECIMAL",P2,P3
FROM V$SESSION_WAIT
WHERE EVENT = 'library cache pin' and wait_time=0
/

EVENT                          P1 EN HEXADECIMA         P2         P3
------------------------------ ---------------- ---------- ----------
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200
library cache pin              C0000005319B6828 1.3835E+19        200

27 rows selected.

SQL> SELECT KGLPNUSE,KGLPNMOD,KGLPNREQ
FROM X$KGLPN WHERE KGLPNHDL LIKE '%&Hexadecimal_P1%'
/  
Enter value for hexadecimal_p1: C0000005319B6828

KGLPNUSE           KGLPNMOD   KGLPNREQ
---------------- ---------- ----------
C00000051759F190          0          2
C00000051656E440          0          2
C000000516592930          0          2
C00000051655B1F0          0          2
C00000051956D290          0          2
C000000516574DE0          0          2
C0000005175508A0          0          2
C00000051956BD70          0          2
C00000051875C268          0          2
C0000005187A56D8          0          2
C00000051755DBE0          0          2
C0000005165D5400          0          2
C00000051877F238          0          2
C0000005175591F0          0          2
C00000051875ECA8          0          2
C0000005175C6B50          0          2
C00000051877DD18          0          2
C0000005187660D8          0          2
C0000005195A3F40          0          2
C00000051757B730          0          2
C00000051655E6C0          0          2
C000000516580170          0          2
C000000516567010          0          2
C0000005175D1450          0          2
C0000005165AF9F0          0          2
C00000051655D1A0          0          2
C000000519590260          0          2
C00000051955B560          3          0

28 rows selected.

SQL> SELECT P.SPID "PID S.O",S.OSUSER,S.SID,S.PROCESS,S.PROGRAM
FROM V$SESSION S, V$PROCESS P
WHERE S.SADDR='&Dame_kglnpuse_3'
AND S.PADDR = P.ADDR
  2    3    4    5  /
Enter value for dame_kglnpuse_3: C00000051955B560

PID S.O      OSUSER                                SID PROCESS      PROGRAM
------------ ------------------------------ ---------- ------------ ------------------------------------------------
28428        root                                   54 28422        sqlplus@esdc1srp00011 (TNS V1-V3)

La session 54 es quien monta el follón

SQL> select * from v$session where sid=54;

SADDR                   SID    SERIAL#     AUDSID PADDR                 USER# USERNAME                          COMMAND    OWNERID
---------------- ---------- ---------- ---------- ---------------- ---------- ------------------------------ ---------- ----------
TADDR            LOCKWAIT         STATUS   SERVER       SCHEMA# SCHEMANAME                     OSUSER
---------------- ---------------- -------- --------- ---------- ------------------------------ ------------------------------
PROCESS      MACHINE                                                          TERMINAL
------------ ---------------------------------------------------------------- ------------------------------
PROGRAM                                          TYPE       SQL_ADDRESS      SQL_HASH_VALUE PREV_SQL_ADDR    PREV_HASH_VALUE
------------------------------------------------ ---------- ---------------- -------------- ---------------- ---------------
MODULE                                           MODULE_HASH ACTION                           ACTION_HASH
------------------------------------------------ ----------- -------------------------------- -----------
CLIENT_INFO                                                      FIXED_TABLE_SEQUENCE ROW_WAIT_OBJ# ROW_WAIT_FILE# ROW_WAIT_BLOCK#
---------------------------------------------------------------- -------------------- ------------- -------------- ---------------
ROW_WAIT_ROW# LOGON_TIM LAST_CALL_ET PDM FAILOVER_TYPE FAILOVER_M FAI RESOURCE_CONSUMER_GROUP          PDML_STA PDDL_STA PQ_STATU
------------- --------- ------------ --- ------------- ---------- --- -------------------------------- -------- -------- --------
CURRENT_QUEUE_DURATION CLIENT_IDENTIFIER
---------------------- ----------------------------------------------------------------
C00000051955B560         54      12823  377383527 C000000518587638       5847 APP_BSM                                 3 2147483644
C00000051E3C67B8                  ACTIVE   DEDICATED       5847 APP_BSM                        root
28422        esdc1srp00011
sqlplus@esdc1srp00011 (TNS V1-V3)                USER       C00000062DA76158     3813905816 C00000062DA76158      3813905816
SQL*Plus                                          3669949024                                   4029777240
                                                                               624046            -1              0               0
            0 12-NOV-14        34542 NO  NONE          NONE       NO  DEFAULT_CONSUMER_GROUP           DISABLED ENABLED  ENABLED
                     0
Esta sesión está ejecutando esto:

SQL> select b.sql_text from v$sqlarea b, v$session a where b.address = a.sql_address and b.hash_value = a.sql_hash_value
and a.type='USER' and a.sid=  2  54;

SQL_TEXT
------------------------------------------------------------------------------------------------------------------------------------
select 1 from dual@CRA_PTB


Buscamos el PID y matamos la sesión:

SQL> SELECT p.spid, osuser, s.program
  FROM v$process p, v$session s
WHERE p.addr = s.paddr AND s.SID =  2    3  54;

SPID         OSUSER                         PROGRAM
------------ ------------------------------ ------------------------------------------------
28428        root                           sqlplus@esdc1srp00011 (TNS V1-V3)

SQL> !ps -ef | grep 28428
  oracle 28428     1  0 04:28:56 ?         0:00 oracleSIEBEL (LOCAL=NO)
  oracle 17325 17323  0 14:06:25 pts/9     0:00 grep 28428
  oracle 17323 11717  0 14:06:25 pts/9     0:00 /sbin/sh -c ps -ef | grep 28428

SQL> alter system kill session '54,12823' immediate;

Como no muere mato también el PID 28428


Tras morir la sesión…. Ya no hay eventos de espera de library cache pin

SQL> r
  1  select count(*), event from v$session_wait
  2* where wait_time=0 group by event

  COUNT(*) EVENT
---------- ----------------------------------------
         4 HS message to agent
       437 SQL*Net message from client
         5 db file sequential read
        10 i/o slave wait
         4 jobq slave wait
         1 pipe get
         1 pmon timer
         8 rdbms ipc message
         1 smon timer

9 rows selected.
