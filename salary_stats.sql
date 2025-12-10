-- Display no. of employees with salary > avg, < avg and = avg
set serveroutput on 
declare
   v_avg_salary employees.salary%type;
   v_high number(2);
   v_same number(2);
   v_low number(2);
begin
   select avg(salary) into v_avg_salary
   from employees;
   
   select count(*) into v_high
   from employees
   where salary > v_avg_salary;
   
   select count(*) into v_same
   from employees
   where salary = v_avg_salary;
   
   select count(*) into v_low
   from employees
   where salary < v_avg_salary;
   
   DBMS_APPLICATION_INFO.SET_ACTION('Reporting salary statistics');
   secure_log('INFO', 'Higher than avg : ' || TO_CHAR(v_high) || ', Session: ' || SYS_CONTEXT('USERENV','SESSIONID'));
   secure_log('INFO', 'Same as avg     : ' || TO_CHAR(v_same) || ', Session: ' || SYS_CONTEXT('USERENV','SESSIONID'));
   secure_log('INFO', 'Lower than avg  : ' || TO_CHAR(v_low) || ', Session: ' || SYS_CONTEXT('USERENV','SESSIONID'));
 
end;   

end;   
  
