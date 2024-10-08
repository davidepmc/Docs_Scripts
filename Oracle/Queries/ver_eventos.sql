SELECT p2raw,
to_number(substr(to_char(rawtohex(p2raw)),  1, 8), 'XXXXXXXX') sid 
FROM v$session 
WHERE event = 'cursor: pin S wait on X'; 