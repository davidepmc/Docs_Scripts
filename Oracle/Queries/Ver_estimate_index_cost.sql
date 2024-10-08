variable used number
variable alloc number
set autoprint on

exec dbms_space.create_index_cost ('DDL create index', :used, :alloc );

