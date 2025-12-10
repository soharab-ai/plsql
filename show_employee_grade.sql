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
               
   -- Using CASE statement for better readability and maintainability
   v_grade := CASE
      WHEN v_salary > 15000 THEN 'A'
      WHEN v_salary > 10000 THEN 'B'
      ELSE 'C'
   END;


   dbms_output.put_line(v_name || ' has Grade ' || v_grade);
end;   
                  
   
