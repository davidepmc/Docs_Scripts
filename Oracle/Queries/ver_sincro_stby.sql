
# CHECK STANDBY REDO APPLY 

# On Primary Server:

alter system archive log current;

select thread#, max(sequence#) "Last Primary Seq Generated" 
from v$archived_log val, v$database vdb 
where val.resetlogs_change# = vdb.resetlogs_change# 
group by thread# 
order by 1;

# On Physical Standby Server:

--Check received log on standby
 select thread#, max(sequence#) "Last Standby Seq Received" 
 from v$archived_log val, v$database vdb 
 where val.resetlogs_change# = vdb.resetlogs_change# 
 group by thread# 
 order by 1;

--Check applied log on standby
 select thread#, max(sequence#) "Last Standby Seq Applied" 
 from v$archived_log val, v$database vdb 
 where val.resetlogs_change# = vdb.resetlogs_change# 
 and val.applied in ('YES','IN-MEMORY') 
 group by thread# 
 order by 1;







# CHECK LOGICAL STANDBY SYNCHRO USING DBLINK
# BARELY USED ANYMORE
select sysdate, td.CURRENT_SCN ETP_SCN, md.current_scn EMP_SCN, 
ms.LAST_CHANGE# LAST_CHG_APPLY, ms.LAST_TIME from dual@logical th, 
v$database@logical td,  V$STANDBY_LOG ms, v$database md where MS.FIRST_TIME > sysdate -1;


