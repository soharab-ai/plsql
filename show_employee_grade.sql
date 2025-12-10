set serveroutput on
declare
    v_name    varchar2(50);
    v_salary  employees.salary%type;
    v_grade   varchar2(10);
begin
   select first_name || ' ' || last_name , salary into v_name, v_salary
   from employees
   where employee_id = 120;
   /*
   v_grade :=  case 
                  when v_salary > 15000 then 'A'
                  when v_salary > 10000 then 'B'
                  else  'C'
               end;   */
               
   if v_salary > 15000 then
       v_grade := 'A';
   elsif  v_salary > 10000 then
       v_grade := 'B';
   else
       v_grade := 'C';
   end if;
       
   log_message('INFO', 'Employee ' || DBMS_ASSERT.ENQUOTE_LITERAL(v_name) || 
           ' has Grade ' || DBMS_ASSERT.ENQUOTE_LITERAL(v_grade));
end;   

-- Separate logging procedure with autonomous transaction
PROCEDURE log_message(p_level VARCHAR2, p_message VARCHAR2) IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   v_module VARCHAR2(64);
   v_action VARCHAR2(64);
BEGIN
   DBMS_APPLICATION_INFO.READ_MODULE(v_module, v_action);
   INSERT INTO application_logs (log_level, message, module, action, session_id, log_timestamp) 
   VALUES (p_level, p_message, v_module, v_action, SYS_CONTEXT('USERENV', 'SESSIONID'), SYSTIMESTAMP);
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      NULL; -- Logging should never cause main procedure to fail
END log_message;

