set lines 200

column TABLE_owner heading "owner" format a13
column table_name heading "TABLE" format a30
column index_name heading "INDEX" format a30
column owner heading "ESQUEMA" format a7
column leaf_blocks heading "BLOCK" format 999999999
column distinct_keys heading "KEYS" format 9999999999
column num_rows heading "ROWS" format 9999999999
column COLs heading COL format 99
column OCU heading "%OCUP" format 999.99
column MB_REC heading "-MB_REC" format 9999999
column COLumn_position heading "POS" format a3
column BLEVEL heading "BL" format 9

spool ind_recrear.lst

WITH tbs AS
(Select  /*+ materialize */ *
 FROM
   (select distinct (index_name) as index_name, block_size
    from dba_indexes i , dba_tablespaces tbs  
    where i.tablespace_name=tbs.tablespace_name
   union
    select distinct (index_name) as index_name, block_size
    from dba_ind_partitions i , dba_tablespaces tbs 
    where i.tablespace_name=tbs.tablespace_name
   union
    select distinct (index_name) as index_name, block_size
    from dba_ind_subpartitions i , dba_tablespaces tbs 
    where i.tablespace_name=tbs.tablespace_name
   )
),
ind AS
(SELECT /*+ materialize */
        t.owner, i.index_name, t.table_name, c.column_name,
        t.num_rows - i.num_rows as F_N ,     -- filas de la tabla menos filas del indice = numero nulos todos campos indice son nulos; Filas_nulas=F_N
        i.blevel, i.leaf_blocks, i.distinct_keys, i.num_rows, c.column_position, tbs.block_size as T_BLOCK, i.last_analyzed
 from DBA_TABLES t, DBA_INDEXES i, DBA_IND_COLUMNS c, tbs
 where  INDEX_TYPE='NORMAL'
   AND i.owner= c.INDEX_owner
   AND i.index_name=c.index_name
   AND i.TABLE_owner= t.owner
   AND i.table_name=t.table_name
   AND nvl(i.num_rows,0) > 1000000        -- filtramos a partir de 1M filas de indice
   AND nvl(t.num_rows,0) > 1000000        -- filtramos a partir de 1M filas de tabla
   AND t.owner NOT IN ('SYS','SYSTEM')
   AND tbs.index_name=i.index_name
)
SELECT table_owner, table_name, index_name,
       leaf_blocks,                                                         -- bloques indice
       distinct_keys,                                                       -- claves distintas indice
       num_rows,                                                            -- num filas del indice
       cols,                                                                -- num columnas totales
       OCU,                                                                 -- Ocupacion
       blevel,
       TamI,                                                                -- Total ocupacion indice neta
       (TOT * (90 - OCU) / 100)/1024/1024 as  MB_REC,                       -- Mb que ocuparia reconstruido     
       to_char(last_analyzed,'dd-mm-yy') as analisis
  FROM 
    (SELECT table_owner, table_name, index_name, blevel, last_analyzed,
       leaf_blocks,     T_BLOCK,                                                    -- bloques indice
       distinct_keys,                                                       -- claves distintas indice
       num_rows,                                                            -- num filas del indice
       cols,  TamI,                                                              -- num columnas totales
         (TamI + (num_rows * 10)) * 100 / (leaf_blocks * (T_BLOCK-200)) as OCU,      -- Porcentaje de lo que deberia ocupar el indice = OCU
         leaf_blocks * T_BLOCK as TOT                                                -- Total ocupado del indice ahora mismo = TOT
     FROM
       (SELECT
             table_owner, table_name, index_name, blevel, last_analyzed,
             leaf_blocks,                                                             -- bloques indice
             distinct_keys,                                                           -- claves distintas indice
             num_rows,                                                                -- num filas del indice
             t_block,																																	-- tamaño bloque de este indice
             count(column_position) as cols,                                          -- num columnas totales
             sum((num_rows - num_nulls + F_N) * avg_col_len) as TamI                  -- Total Ocupacion indice = Nonulos de cada columna * su tamaño = TamI
        FROM
          (SELECT index_name, ind.table_name, ind.owner AS TABLE_owner, ind.F_N,
               ind.leaf_blocks, ind.distinct_keys, ind.blevel,
               ind.num_rows, tcs.avg_col_len, tcs.num_distinct, tcs.num_nulls, ind.column_position, ind.T_BLOCK, ind.last_analyzed
           FROM ind, DBA_TAB_COL_STATISTICS tcs
           WHERE ind.owner=tcs.owner
             AND ind.table_name=tcs.table_name
             AND ind.column_name=tcs.column_name
           )
        GROUP BY table_owner, table_name, index_name, leaf_blocks, distinct_keys, num_rows, t_block, blevel, last_analyzed
       )
     )
  WHERE OCU < 71                                -- Se filtra por los indices en los que la ocupacion sea maximo el 70%
ORDER BY table_owner, leaf_blocks desc, table_name
;

spool off
