-- ##################################################################################
-- Self Managed Oracle Database as a source
-- Usage    : SQL> @create-dbuser-dms-self-managed-oracle.sql USERNAME PASSWORD
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

--DROP USER &1 CASCADE;
--CREATE USER &1 IDENTIFIED BY "&2" DEFAULT TABLESPACE users;
GRANT CREATE SESSION TO &1;
GRANT SELECT ANY TRANSACTION TO &1;
GRANT SELECT ON V_$ARCHIVED_LOG TO &1;
GRANT SELECT ON V_$LOG TO &1;
GRANT SELECT ON V_$LOGFILE TO &1;
GRANT SELECT ON V_$LOGMNR_LOGS TO &1;
GRANT SELECT ON V_$LOGMNR_CONTENTS TO &1;
GRANT SELECT ON V_$DATABASE TO &1;
GRANT SELECT ON V_$THREAD TO &1;
GRANT SELECT ON V_$PARAMETER TO &1;
GRANT SELECT ON V_$NLS_PARAMETERS TO &1;
GRANT SELECT ON V_$TIMEZONE_NAMES TO &1;
GRANT SELECT ON V_$TRANSACTION TO &1;
GRANT SELECT ON GV_$TRANSACTION TO &1;
GRANT SELECT ON ALL_INDEXES TO &1;
GRANT SELECT ON ALL_OBJECTS TO &1;
GRANT SELECT ON ALL_TABLES TO &1;
GRANT SELECT ON ALL_USERS TO &1;
GRANT SELECT ON ALL_CATALOG TO &1;
GRANT SELECT ON ALL_CONSTRAINTS TO &1;
GRANT SELECT ON ALL_CONS_COLUMNS TO &1;
GRANT SELECT ON ALL_TAB_COLS TO &1;
GRANT SELECT ON ALL_IND_COLUMNS TO &1;
GRANT SELECT ON ALL_ENCRYPTED_COLUMNS TO &1;
GRANT SELECT ON ALL_LOG_GROUPS TO &1;
GRANT SELECT ON ALL_TAB_PARTITIONS TO &1;
GRANT SELECT ON SYS.DBA_REGISTRY TO &1;
GRANT SELECT ON SYS.OBJ$ TO &1;
GRANT SELECT ON DBA_TABLESPACES TO &1;
GRANT SELECT on ALL_VIEWS to &1;
GRANT SELECT ON SYS.DBA_DIRECTORIES TO &1;
-- Required if the Oracle version is earlier than 11.2.0.3
GRANT SELECT ON DBA_OBJECTS TO &1; 
-- Required if transparent data encryption (TDE) is enabled. For more information on using Oracle TDE
GRANT SELECT ON SYS.ENC$ TO &1; 
-- Grant SELECT on the specific tables you intend to migrate
-- GRANT SELECT ON <any-replicated-table> TO &1;
-- Alternatively can grant SELECT 
GRANT SELECT ANY TABLE TO &1;
-- Only required if using binary reader with Oracle ASM
GRANT SELECT ON V_$TRANSPORTABLE_PLATFORM TO &1;
-- Required only if the Oracle version is 12c or later
GRANT LOGMINING TO &1;
-- Required if you you enable validation
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO &1;
-- Required if you want DMS to enable table level supplemetnal logging via Extra Connection Attribute "addSupplementalLogging=Y"
GRANT ALTER ANY TABLE TO &1;
-- Required if you will connect to a standby
GRANT SELECT ON v_$standby_log TO &1;
-- Required if transparent data encryption (TDE) is enabled
GRANT SELECT ON SYS.ENC$ TO &1;
-- Required if you have nested tables
GRANT SELECT ON ALL_NESTED_TABLES TO &1;
GRANT SELECT ON ALL_NESTED_TABLE_COLS TO &1;