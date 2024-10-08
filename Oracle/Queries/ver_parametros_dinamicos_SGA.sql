set lines 200 pages 200
Col Component for a40

SELECT 
COMPONENT,
round(CURRENT_SIZE/power(1024,2)) Current_Size ,
OPER_COUNT operation_count,
LAST_OPER_TYPE 
FROM V$SGA_DYNAMIC_COMPONENTS;

Select round(CURRENT_SIZE/power(1024,2)) FREE_SGA_MEMORY from v$sga_dynamic_free_memory;