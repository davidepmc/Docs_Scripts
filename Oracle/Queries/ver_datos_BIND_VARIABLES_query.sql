select
  sql_id,
  t.sql_text SQL_TEXT,
  b.name BIND_NAME,
  b.value_string BIND_STRING
from
  v$sql t
  join v$sql_bind_capture b
  using (sql_id)
where
  b.value_string is not null
  and sql_id='&SQL_ID'
/