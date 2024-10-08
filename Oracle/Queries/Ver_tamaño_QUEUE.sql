select owner, segment_type, segment_name, blocks, sum(bytes)/1024/1024 from dba_segments where segment_name in (                         
select index_name from dba_indexes where table_name like '%FOBSQUEUE%'                                                                   
union all                                                                                                                                
select table_name from dba_indexes where table_name like '%FOBSQUEUE%'                                                                   
)                                                                                                                                        
group by owner, segment_type, segment_name, blocks                                                                                       