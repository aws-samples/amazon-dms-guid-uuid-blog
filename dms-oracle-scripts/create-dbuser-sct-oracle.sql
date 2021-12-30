-- ##################################################################################
-- Oracle Database as a source
-- Usage    : SQL> @create-dbuser-sct-oracle.sql USERNAME PASSWORD
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
  v_password := NVL(NULL, 'ChangeMePassword');
  SELECT COUNT(*) INTO v_status FROM dba_users WHERE username = v_username;
  IF (v_status = 0) THEN
    EXECUTE IMMEDIATE 'CREATE USER ' || v_username || ' IDENTIFIED BY ' || v_password || ' DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp';
  END IF;
END;
/

--DROP USER &1;
GRANT CREATE SESSION to &1;
GRANT SELECT_CATALOG_ROLE TO &1;
GRANT SELECT ANY DICTIONARY TO &1;
GRANT SELECT ON SYS.USER$ TO &1;