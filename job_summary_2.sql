-- function to return names of employees with highest salary in the given job
create or replace function get_top_employees(p_jobid varchar)
return varchar is
 cursor empnames is
    select first_name 
    from employees
    where job_id = p_jobid and salary = 
      (select max(salary) from employees where job_id = p_jobid);

 v_names  varchar(100);
begin
     v_names := '';
     for namerec in empnames
     loop
          v_names := v_names || namerec.first_name || ',';
     end loop;
     
     return rtrim(v_names,',');
end;

---------------------------------------
-- Program to use the above function and display details of jobs 
set serveroutput on
declare
  cursor jobcur is
    select job_id, job_title
    from jobs
    where job_id in
      (select job_id from employees);
  v_count      number(3);    
  v_count_hist number(3);    
  v_avg_exp    number(2);    
  v_avg_sal    employees.salary%type;
  v_names      varchar(100);
    
begin
  for jobrec in jobcur
  loop
     select avg(salary), count(*), 
            avg(floor(months_between(sysdate,hire_date)/12))
            into v_avg_sal, v_count, v_avg_exp
     from employees
     where job_id = jobrec.job_id;
     
     select count(*) into v_count_hist
     from job_history
     where job_id = jobrec.job_id;
     
     v_names := get_top_employees(jobrec.job_id);
   
     
     -- Log job information with appropriate log levels
     log_job_info('Job Title', jobrec.job_title, 'INFO');
     log_job_info('No. Employees', v_count, 'INFO');
     log_job_info('Avg Salary', v_avg_sal, 'INFO');
     log_job_info('Avg Exp', v_avg_exp, 'INFO');
     log_job_info('History Count', v_count_hist, 'INFO');
     log_job_info('Top Employee(s)', v_names, 'INFO');
     
     -- Commit periodically to improve performance
     IF MOD(jobrec.job_id, 10) = 0 THEN
       COMMIT;
     END IF;
  end loop;
  
  -- Final commit if needed
  COMMIT;
end;

-- Enhanced logging procedure with severity levels and context information
CREATE OR REPLACE PROCEDURE log_job_info(
  p_label IN VARCHAR2, 
  p_value IN VARCHAR2,
  p_level IN VARCHAR2 DEFAULT 'INFO') 
IS
BEGIN
  INSERT INTO application_log (
    component, 
    log_level,
    message, 
    username, 
    session_id, 
    module
  )
  VALUES (
    'JOB_SUMMARY', 
    p_level,
    p_label || ' : ' || p_value,
    SYS_CONTEXT('USERENV', 'SESSION_USER'),
    SYS_CONTEXT('USERENV', 'SESSIONID'),
    SYS_CONTEXT('USERENV', 'MODULE')
  );
  -- No immediate commit to improve performance
EXCEPTION
  WHEN OTHERS THEN
    NULL; -- Prevent logging failures from affecting main process
END log_job_info;

-- Ensure this table exists with enhanced structure
CREATE TABLE IF NOT EXISTS application_log (
  log_id NUMBER GENERATED ALWAYS AS IDENTITY,
  log_time TIMESTAMP DEFAULT SYSTIMESTAMP,
  log_level VARCHAR2(10),
  component VARCHAR2(100),
  message VARCHAR2(4000),
  username VARCHAR2(30),
  session_id NUMBER,
  module VARCHAR2(64),
  CONSTRAINT pk_app_log PRIMARY KEY (log_id)
);

-- Log rotation procedure to prevent table growth issues
CREATE OR REPLACE PROCEDURE purge_old_logs(p_days_to_keep IN NUMBER DEFAULT 30) IS
BEGIN
  DELETE FROM application_log WHERE log_time < SYSTIMESTAMP - p_days_to_keep;
  COMMIT;
END purge_old_logs;

