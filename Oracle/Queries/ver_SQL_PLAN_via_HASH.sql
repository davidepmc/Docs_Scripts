***************** 
--short version-- 
***************** 
set pagesize 600 
set tab off  
set linesize 140 
set echo off 
set long 4000 
col TQID format A4 
col "SLAVE SQL" format A95 WORD_WRAP 
col address format A12 
col sql_hash format A15 
col exec format 9999 
col sql_text format A75 WORD_WRAP 
 
select rpad('| '||substr(lpad(' ',1*(depth))||operation|| decode(options, null,'',' '||options), 1, 50), 50, ' ')||'|'||  
          rpad(substr(object_name||' ',1, 19), 20, ' ') 
          as "Explain plan"  
from  
       ( SELECT 
  /*+ no_merge */ 
  p.HASH_VALUE             , 
  p.ID                     , 
  p.DEPTH                  , 
  p.POSITION               , 
  p.OPERATION              , 
  p.OPTIONS                , 
  p.COST COST              , 
  p.CARDINALITY CARDINALITY, 
  p.BYTES BYTES            , 
  p.OBJECT_NODE            , 
  p.OBJECT_OWNER           , 
  p.OBJECT_NAME            , 
  p.OTHER_TAG              , 
  p.PARTITION_START        , 
  p.PARTITION_STOP         , 
  p.DISTRIBUTION            
  FROM V$sql_plan p 
  WHERE p.hash_value = 
  &hashvalue 
AND p.CHILD_NUMBER     = 0 
	 ) 
order by ID  
; 