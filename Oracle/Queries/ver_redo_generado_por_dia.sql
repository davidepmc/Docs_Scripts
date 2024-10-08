set lines 200
col day  format a10
col "00" format a3
col "01" format a3
col "02" format a3
col "03" format a3
col "04" format a3
col "05" format a3
col "06" format a3
col "07" format a3
col "08" format a3
col "09" format a3
col "10" format a3
col "11" format a3
col "12" format a3
col "13" format a3
col "14" format a3
col "15" format a3
col "16" format a3
col "17" format a3
col "18" format a3
col "19" format a3
col "20" format a3
col "21" format a3
col "22" format a3
col "23" format a3
select to_char(first_time,'YYYY.MM.DD') day,
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'00',1,0)),'99') "00",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'01',1,0)),'99') "01",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'02',1,0)),'99') "02",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'03',1,0)),'99') "03",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'04',1,0)),'99') "04",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'05',1,0)),'99') "05",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'06',1,0)),'99') "06",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'07',1,0)),'99') "07",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'08',1,0)),'99') "08",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'09',1,0)),'99') "09",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'10',1,0)),'99') "10",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'11',1,0)),'99') "11",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'12',1,0)),'99') "12",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'13',1,0)),'99') "13",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'14',1,0)),'99') "14",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'15',1,0)),'99') "15",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'16',1,0)),'99') "16",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'17',1,0)),'99') "17",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'18',1,0)),'99') "18",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'19',1,0)),'99') "19",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'20',1,0)),'99') "20",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'21',1,0)),'99') "21",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'22',1,0)),'99') "22",
       to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'23',1,0)),'99') "23"
  from v$log_history
 group by to_char(first_time,'YYYY.MM.DD') 
 order by 1
/