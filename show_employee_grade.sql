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
       
   -- Log with structured format and context information
   log_message('INFO', 'EMPLOYEE_GRADE', 
     '{"event":"grade_assignment","employee":"' || DBMS_ASSERT.ENQUOTE_LITERAL(v_name) || 
     '","grade":"' || v_grade || '","timestamp":"' || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM') || 
     '","session":"' || SYS_CONTEXT('USERENV','SESSIONID') || 
     '","user":"' || SYS_CONTEXT('USERENV','SESSION_USER') || '"}');
end;   
                  
   

                  
   
