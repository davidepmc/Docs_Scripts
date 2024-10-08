select s.program, sum(stm.value)/1000000 db_time from v$session s, v$sess_time_model stm
where s.sid=stm.sid
group by s.program
/
