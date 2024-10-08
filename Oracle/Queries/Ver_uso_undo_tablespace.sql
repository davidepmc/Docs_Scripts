##########################################
##	VER USO DEL UNDO TABLESPACE	##
##########################################

select s.sid, s.username, s.status, t.start_time, t.USED_UBLK ublock, t.USED_UREC urecord
from v$session s, v$transaction t
where s.saddr=t.ses_addr
order by 5,6 
/
