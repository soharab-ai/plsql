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
         INSERT INTO MISSING_EMPLOYEE_IDS VALUES(EMPID);
       WHEN DUP_VAL_ON_INDEX THEN
         -- Handle duplicate value errors separately
         INSERT INTO ERROR_LOG VALUES(SQLCODE, SQLERRM, SYSDATE, 'PROCESS_EMPLOYEES', 'WARNING', EMPID);
       WHEN OTHERS THEN
         -- Autonomous transaction ensures error logging regardless of transaction state
         DECLARE
           PRAGMA AUTONOMOUS_TRANSACTION;
         BEGIN
           INSERT INTO ERROR_LOG VALUES(SQLCODE, SQLERRM, SYSDATE, 'PROCESS_EMPLOYEES', 'ERROR', EMPID, 
                                      DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
           COMMIT;
         END;
         -- Uncomment the following line if you want to re-raise the exception
         -- RAISE;
      END;

       
  END LOOP;     

END;


END;
