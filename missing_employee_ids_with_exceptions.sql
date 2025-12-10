-- Find out missing employee ids using exception handling and nested block
DECLARE
  v_min_id employees.employee_id%TYPE;  
  v_max_id employees.employee_id%TYPE;  
  v_id employees.employee_id%TYPE;  
BEGIN

  SELECT MIN(employee_id), MAX(employee_id) 
   INTO v_min_id, v_max_id
  FROM employees;


  FOR EMPID IN V_MIN_EMPID + 1.. V_MAX_EMPID-1
  LOOP 
      -- NESTED BLOCK 
      BEGIN 
       SELECT EMPLOYEE_ID INTO V_EMPID
       FROM EMPLOYEES
       WHERE EMPLOYEE_ID = EMPID;
      EXCEPTION 
       WHEN NO_DATA_FOUND THEN
         DBMS_OUTPUT.PUT_LINE(EMPID);
      END;
       
  END LOOP;     

END;
