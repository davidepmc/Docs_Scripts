rem -----------------------------------------------------------------------
rem Filename:   sga_stat.sql
rem Purpose:    Display database SGA statistics
rem Date:       14-Jun-2001
rem Author:     Anjan Roy (AnjanR@innotrex.com)
rem -----------------------------------------------------------------------

DECLARE
      libcac number(10,2);
      rowcac number(10,2);
      bufcac number(10,2);
      redlog number(10,2);
      spsize number;
      blkbuf number;
      logbuf number;
BEGIN
select value into redlog from v$sysstat
where name = 'redo log space requests';
select 100*(sum(pins)-sum(reloads))/sum(pins) into libcac from v$librarycache;
select 100*(sum(gets)-sum(getmisses))/sum(gets) into rowcac from v$rowcache;
select 100*(cur.value + con.value - phys.value)/(cur.value + con.value) into bufcac
from v$sysstat cur,v$sysstat con,v$sysstat phys,v$statname ncu,v$statname nco,v$statname nph
where cur.statistic# = ncu.statistic#
	and ncu.name = 'db block gets'
        and con.statistic# = nco.statistic#
        and nco.name = 'consistent gets'
        and phys.statistic# = nph.statistic#
        and nph.name = 'physical reads';
select value into spsize  from v$parameter where name = 'shared_pool_size';
select value into blkbuf  from v$parameter where name = 'db_block_buffers';
select value into logbuf  from v$parameter where name = 'log_buffer';
dbms_output.put_line('>                   SGA CACHE STATISTICS');
dbms_output.put_line('>                   ********************');
dbms_output.put_line('>              SQL Cache Hit rate = '||libcac);
dbms_output.put_line('>             Dict Cache Hit rate = '||rowcac);
dbms_output.put_line('>           Buffer Cache Hit rate = '||bufcac);
dbms_output.put_line('>         Redo Log space requests = '||redlog);
dbms_output.put_line('> ');
dbms_output.put_line('>                     INIT.ORA SETTING');
dbms_output.put_line('>                     ****************');
dbms_output.put_line('>               Shared Pool Size = '||spsize||' Bytes');
dbms_output.put_line('>                DB Block Buffer = '||blkbuf||' Blocks');
dbms_output.put_line('>                    Log Buffer  = '||logbuf||' Bytes');
dbms_output.put_line('> ');
if
	libcac < 99  then dbms_output.put_line('*** HINT: Library Cache too low! Increase the Shared Pool Size.');
END IF;
if
	rowcac < 85  then dbms_output.put_line('*** HINT: Row Cache too low! Increase the Shared Pool Size.');
END IF;
if
	bufcac < 90  then dbms_output.put_line('*** HINT: Buffer Cache too low! Increase the DB Block Buffer value.');
END IF;
if
	redlog > 100 then dbms_output.put_line('*** HINT: Log Buffer value is rather low!');
END IF;
END;
/
