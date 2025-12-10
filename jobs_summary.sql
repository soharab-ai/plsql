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
  v_max_sal    employees.salary%type;
  v_names      varchar(100);
  
  cursor empnames(jobid varchar, maxsal number) is
    select first_name 
    from employees
    where job_id = jobid and salary = maxsal;
    
begin
  for jobrec in jobcur
  loop
     select avg(salary), count(*), max(salary), 
            avg(floor(months_between(sysdate,hire_date)/12))
            into v_avg_sal, v_count, v_max_sal, v_avg_exp
     from employees
     where job_id = jobrec.job_id;
     
     select count(*) into v_count_hist
     from job_history
     where job_id = jobrec.job_id;
     
     v_names := '';
     for namerec in empnames(jobrec.job_id, v_max_sal)
     loop
          v_names := v_names || namerec.first_name || ',';
     end loop;
    
     
     -- Initialize transaction ID for correlated logging
     v_transaction_id := sys_guid();
     
     -- Use robust logging with severity levels and parameter binding
     log_job_info(v_transaction_id, 'INFO', 'JOB_TITLE', jobrec.job_title);
     log_job_info(v_transaction_id, 'INFO', 'NO_EMPLOYEES', v_count);
     log_job_info(v_transaction_id, 'INFO', 'AVG_SALARY', v_avg_sal);
     log_job_info(v_transaction_id, 'INFO', 'AVG_EXPERIENCE', v_avg_exp);
     log_job_info(v_transaction_id, 'INFO', 'HISTORY_COUNT', v_count_hist);
     log_job_info(v_transaction_id, 'INFO', 'TOP_EMPLOYEES', rtrim(v_names,','));
  end loop;  
     

end;

