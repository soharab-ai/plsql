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
DECLARE
   v_salary NUMBER;
   v_grade CHAR(1);
BEGIN
   -- Secure method to get salary using bind variables
   EXECUTE IMMEDIATE 'SELECT salary FROM employees WHERE id = :id' 
   INTO v_salary 
   USING p_employee_id;
   
   -- Use CASE statement to determine grade based on salary
   v_grade := CASE
      -- N/A grade: No salary information available
      WHEN v_salary IS NULL THEN 'N/A'
      -- A grade: High salary range
      WHEN v_salary > 15000 THEN 'A'
      -- B grade: Medium salary range
      WHEN v_salary > 10000 THEN 'B'
      -- C grade: Lower salary range
      ELSE 'C'
   END;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- Different code to distinguish from NULL case
      v_grade := 'X';
   WHEN OTHERS THEN
      -- Log the error but don't expose details externally
      log_error('Error in show_employee_grade: ' || SQLERRM);
      RAISE_APPLICATION_ERROR(-20001, 'Error processing employee grade');
END;


   dbms_output.put_line(v_name || ' has Grade ' || v_grade);
end;   
                  
   
