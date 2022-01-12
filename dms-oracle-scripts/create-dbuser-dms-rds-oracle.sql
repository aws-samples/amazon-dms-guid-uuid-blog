-- ##################################################################################
-- AWS RDS Oracle Database as a source
-- Usage    : SQL> @create-dbuser-dms-rds-oracle.sql USERNAME PASSWORD
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

/* Grant Privileges to the user created */
GRANT CREATE SESSION TO &1;
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_VIEWS',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_TAB_PARTITIONS',UPPER('&1'), 'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_NESTED_TABLES',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_NESTED_TABLE_COLS',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_INDEXES',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_OBJECTS',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_TABLES',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_USERS',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_CATALOG',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_CONSTRAINTS',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_CONS_COLUMNS',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_TAB_COLS',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_IND_COLUMNS',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_LOG_GROUPS',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('V_$ARCHIVED_LOG',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('V_$LOG',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGFILE',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('V_$DATABASE',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('V_$THREAD',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('V_$PARAMETER',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('V_$NLS_PARAMETERS',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('V_$TIMEZONE_NAMES',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('V_$TRANSACTION',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('DBA_REGISTRY',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('OBJ$',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ALL_ENCRYPTED_COLUMNS',UPPER('&1'), 'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_LOGS',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_CONTENTS',UPPER('&1'),'SELECT');
EXEC rdsadmin.rdsadmin_util.grant_sys_object('DBMS_LOGMNR',UPPER('&1'),'EXECUTE');
GRANT SELECT ANY TRANSACTION TO &1;
GRANT SELECT ON DBA_TABLESPACES TO &1;
GRANT EXECUTE ON rdsadmin.rdsadmin_util TO &1;

 /* For Oracle 12c only */
--GRANT LOGMINING TO &1;

/* as of AWS DMS versions 3.3.1 and later and as of Oracle versions 12.1 and later */
EXEC rdsadmin.rdsadmin_util.grant_sys_object('REGISTRY$SQLPATCH',UPPER('&1'), 'SELECT');

/* for Amazon RDS Active Dataguard Standby (ADG) */
EXEC rdsadmin.rdsadmin_util.grant_sys_object('V_$STANDBY_LOG',UPPER('&1'),'SELECT'); 

/* for transparent data encryption (TDE) */
EXEC rdsadmin.rdsadmin_util.grant_sys_object('ENC$',UPPER('&1'),'SELECT');

/* for validation with LOB columns */
EXEC rdsadmin.rdsadmin_util.grant_sys_object('DBMS_CRYPTO',UPPER('&1'),'EXECUTE');
                    
/* for binary reader */
EXEC rdsadmin.rdsadmin_util.grant_sys_object('DBA_DIRECTORIES',UPPER('&1'),'SELECT'); 

/* grant select for the tables */
GRANT SELECT ANY TABLE TO &1; -- You can grant SELECT privilege the the individual tables rather giving SELECT ANY TABLE

/* required if you plan to use Extra Connection Attribute "addSupplementalLogging=Y" to enable supplemental logging, alternatively grant to the specific tables */
-- GRANT ALTER ANY TABLE TO &1;

/* OR */ 
-- GRANT ALTER ON owner.table_name TO &1;

/* Create directory for online and archived redo logs **/
EXEC rdsadmin.rdsadmin_master_util.create_archivelog_dir;
EXEC rdsadmin.rdsadmin_master_util.create_onlinelog_dir;

/* Grant read access ONLINELOG_DIR and ARCHIVELOG_DIR if dmsuser is not master user */
SELECT directory_name, directory_path FROM all_directories WHERE directory_name LIKE ('ARCHIVELOG_DIR%') OR directory_name LIKE ('ONLINELOG_DIR%');
GRANT READ ON DIRECTORY ONLINELOG_DIR TO &1;
GRANT READ ON DIRECTORY ARCHIVELOG_DIR TO &1;

/* Configure adequate retention for archived redo log*/
EXEC rdsadmin.rdsadmin_util.set_configuration('archivelog retention hours',24);

