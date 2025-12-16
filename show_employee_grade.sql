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
       
   -- Log employee grade using application logging package
   app_logger.log(
     p_source => 'show_employee_grade',
     p_message => 'Employee '||DBMS_ASSERT.ENQUOTE_LITERAL(v_name)||' has Grade '||v_grade
   );
end;

                  
   
