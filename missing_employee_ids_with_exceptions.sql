-- Find out missing employee ids using exception handling and nested block
DECLARE
  V_MIN_EMPID EMPLOYEES.EMPLOYEE_ID%TYPE;  
  V_MAX_EMPID EMPLOYEES.EMPLOYEE_ID%TYPE;  
  V_EMPID EMPLOYEES.EMPLOYEE_ID%TYPE;  
BEGIN

  SELECT MIN(EMPLOYEE_ID), MAX(EMPLOYEE_ID) 
   INTO V_MIN_EMPID, V_MAX_EMPID
  FROM EMPLOYEES;

  FOR EMPID IN V_MIN_EMPID + 1.. V_MAX_EMPID-1
  LOOP 
      -- NESTED BLOCK 
      BEGIN 
       SELECT EMPLOYEE_ID INTO V_EMPID
       FROM EMPLOYEES
       WHERE EMPLOYEE_ID = EMPID;
      EXCEPTION 
       WHEN NO_DATA_FOUND THEN
         -- Log using application logging package
         app_logger.log_warning('Employee ID not found: '||TO_CHAR(EMPID), 'EMPLOYEE_VALIDATION');
      END;
       
  END LOOP;     

END;


END;
