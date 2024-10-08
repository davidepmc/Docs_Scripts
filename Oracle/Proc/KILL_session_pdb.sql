show pdbs;
alter session set container=&container;
select 'alter system kill session '''||sid|| ','||serial#|| ',@' ||inst_id||''' immediate;' from gv$session where username = '&username';