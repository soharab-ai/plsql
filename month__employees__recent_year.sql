set serveroutput on
declare
  v_year number(4);
  v_count number(3);
begin
  select to_char(max(hire_date),'yyyy') into v_year
  from employees;
  
  for month in 1..12
  loop
     select count(*) into v_count
     from employees
     where to_char(hire_date,'yyyy') = v_year and
           to_char(hire_date,'mm') = month;
           
     log_message('INFO', month || ' - ' || v_count, 'month__employees__recent_year');
  end loop;
end;

-- Create log levels table
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE log_levels (
    level_id NUMBER PRIMARY KEY,
    level_name VARCHAR2(20) UNIQUE NOT NULL,
    description VARCHAR2(100)
  )';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -955 THEN -- Table already exists
      RAISE;
    END IF;
END;
/

-- Insert standard log levels
BEGIN
  INSERT INTO log_levels VALUES (1, 'DEBUG', 'Detailed debugging information');
  INSERT INTO log_levels VALUES (2, 'INFO', 'General informational messages');
  INSERT INTO log_levels VALUES (3, 'WARN', 'Warning conditions');
  INSERT INTO log_levels VALUES (4, 'ERROR', 'Error conditions');
  INSERT INTO log_levels VALUES (5, 'FATAL', 'Critical conditions');
  COMMIT;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN NULL;
END;
/

-- Create logging table if not exists
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE application_logs (
    log_id NUMBER GENERATED ALWAYS AS IDENTITY,
    log_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    log_level VARCHAR2(10),
    log_message VARCHAR2(4000),
    log_source VARCHAR2(100),
    username VARCHAR2(30) DEFAULT USER,
    client_info VARCHAR2(64) DEFAULT SYS_CONTEXT(''USERENV'', ''CLIENT_INFO''),
    ip_address VARCHAR2(45) DEFAULT SYS_CONTEXT(''USERENV'', ''IP_ADDRESS''),
    checksum RAW(16)
  )';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -955 THEN -- ORA-00955: name is already used by an existing object
      RAISE;
    END IF;
END;
/

-- Create log purging job
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'PURGE_OLD_LOGS',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN DELETE FROM application_logs WHERE log_timestamp < SYSTIMESTAMP - INTERVAL ''90'' DAY; COMMIT; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; INTERVAL=1',
    enabled         => TRUE);
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -27477 THEN -- Job already exists
      RAISE;
    END IF;
END;
/

-- Create enhanced logging procedure
CREATE OR REPLACE PROCEDURE log_message(
    p_level IN VARCHAR2,
    p_message IN VARCHAR2,
    p_source IN VARCHAR2 DEFAULT 'UNKNOWN'
) AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_sanitized_message VARCHAR2(4000);
    v_sanitized_level VARCHAR2(10);
    v_sanitized_source VARCHAR2(100);
    v_checksum RAW(16);
    v_log_error EXCEPTION;
BEGIN
    -- Sanitize inputs
    v_sanitized_message := REGEXP_REPLACE(p_message, '[[:cntrl:]]', '');
    v_sanitized_level := UPPER(SUBSTR(REGEXP_REPLACE(p_level, '[^A-Za-z0-9]', ''), 1, 10));
    v_sanitized_source := SUBSTR(REGEXP_REPLACE(p_source, '[[:cntrl:]]', ''), 1, 100);
    
    -- Generate checksum for tamper detection
    v_checksum := DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(v_sanitized_level||v_sanitized_message||v_sanitized_source||USER), DBMS_CRYPTO.HASH_SH1);
    
    -- Insert log with additional security metadata
    BEGIN
        INSERT INTO application_logs (log_level, log_message, log_source, checksum)
        VALUES (v_sanitized_level, v_sanitized_message, v_sanitized_source, v_checksum);
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            -- Ensure logging failures don't disrupt application flow
            ROLLBACK;
            -- Last resort fallback (could log to alert log instead)
            NULL;
    END;
EXCEPTION
    WHEN OTHERS THEN
        -- Silently handle all exceptions to prevent disruption
        NULL;
END;
/

 
  
