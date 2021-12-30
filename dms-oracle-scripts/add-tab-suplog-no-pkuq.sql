-- ##################################################################################
-- Oracle Database as a source
-- Usage    : SQL> @add-tab-suplog-no-pkuq.sql SCHEMANAME 
-- ##################################################################################

DECLARE
 sql_stmt     VARCHAR2(1000);
BEGIN
 -- Get list of tables without Primary and Unique Keys
 FOR i IN (
           SELECT 'ALTER TABLE "' || tab.owner || '"."' || tab.table_name || '" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS' no_pk_uq
            FROM dba_tables tab
           WHERE tab.owner = UPPER('&1')
             AND tab.table_name NOT IN (SELECT cons.table_name FROM dba_constraints cons WHERE cons.owner = UPPER('&1') AND cons.constraint_type = ANY('P','U'))
             AND tab.table_name NOT LIKE '%MLOG$%')
        LOOP
         BEGIN
            EXECUTE IMMEDIATE i.no_pk_uq;
            DBMS_OUTPUT.PUT_LINE (i.no_pk_uq || ';' || '-- DONE');
         EXCEPTION WHEN OTHERS
           THEN
             DBMS_OUTPUT.PUT_LINE (i.no_pk_uq || ';' || '-- FAILED' || ' - ' || SQLCODE || ', ' || SQLERRM);
         END;
        END LOOP;
END;
/