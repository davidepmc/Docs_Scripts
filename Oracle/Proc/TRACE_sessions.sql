TRACE SESSIONS 10.

EXECUTE DBMS_MONITOR.SESSION_TRACE_ENABLE(session_id => $SID, serial_num=>$SERIAL);

EXECUTE DBMS_MONITOR.SESSION_TRACE_DISABLE(session_id => $SID, serial_num=>$SERIAL);




execute dbms_system.set_sql_trace_in_session(15, 8560, true);

execute dbms_system.set_sql_trace_in_session(15, 8560, false);


Those procedures creates a trace file on UDUMP