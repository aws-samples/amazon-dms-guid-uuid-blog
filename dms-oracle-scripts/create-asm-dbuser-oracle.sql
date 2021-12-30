-- ##################################################################################
-- Connect to ASM Oracle instance Source
-- Usage    : SQL> @create-asm-dbuser-oracle.sql USERNAME PASSWORD
-- USERNAME : Name of DB user
-- PASSWORD : Password for the user
-- ##################################################################################

/* Create user it does not exist and grant privileges */

DECLARE
v_status   NUMBER(1);
v_username VARCHAR2(40) := '&1';
v_password VARCHAR2(100) := '&2';
BEGIN
  v_username := UPPER(v_username);
  v_password := NVL(v_password, 'ChangeMePassword');
  SELECT COUNT(*) INTO v_status FROM dba_users WHERE username = v_username;
  IF (v_status = 0) THEN
    EXECUTE IMMEDIATE 'CREATE USER ' || v_username || ' IDENTIFIED BY ' || v_password || ' DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp';
  END IF;
END;
/

-- DROP USER &1;
-- CREATE USER  &1 IDENTIFIED BY "&2";
GRANT SYSASM TO &1;