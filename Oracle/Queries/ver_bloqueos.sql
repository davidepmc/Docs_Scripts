  set lines 190
  set pages 300
  col username form A20
  col sid form 9990
  col type form A4
  col lmode form a30
  col request form a30
  col objname form A25 Heading "Object Name"
  col owner for a15
  rem Display the object ids if the object_name is not unique
  rem col id1 form 999999900   
  rem col id2 form 999999900



  SELECT sn.username, m.sid, m.type,
    DECODE(m.lmode, 0, 'None'
		  , 1, 'Null'
		  , 2, 'Row Share'
		  , 3, 'Row Excl.'
		  , 4, 'Share'
		  , 5, 'S/Row Excl.'
		  , 6, 'Exclusive'
		  , lmode, ltrim(to_char(lmode,'990'))) lmode,
    DECODE(m.request, 0, 'None'
		  , 1, 'Null'
		  , 2, 'Row Share'
		  , 3, 'Row Excl.'
		  , 4, 'Share'
		  , 5, 'S/Row Excl.'
		  , 6, 'Exclusive'
		  , request, ltrim(to_char(request,'990'))) request,
	  obj1.object_name objname,obj1.owner, obj2.object_name objname, obj2.owner
  FROM v$session sn, V$lock m, dba_objects obj1, dba_objects obj2 
  WHERE sn.sid = m.sid
  AND m.id1 = obj1.object_id (+)
  AND m.id2 = obj2.object_id (+)
      AND lmode != 4 
  ORDER BY id1,id2, m.request
  /


  clear breaks
