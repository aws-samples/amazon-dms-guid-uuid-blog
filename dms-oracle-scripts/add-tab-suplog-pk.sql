-- ##################################################################################
-- Oracle Database as a source
-- Usage    : SQL> @add-tab-suplog-pk.sql SCHEMANAME 
-- ##################################################################################

DECLARE
 sql_stmt     VARCHAR2(1000);
BEGIN
 -- Get list of tables with Primary Keys
 FOR i IN (
           SELECT 'ALTER TABLE "' || tab.owner || '"."' || tab.table_name || '" ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS' pk_sup
            FROM dba_tables tab, dba_constraints cons
           WHERE tab.owner = cons.owner
             AND tab.table_name = cons.table_name
             AND cons.constraint_type = 'P'
             AND tab.owner = UPPER('&1')
          )
        LOOP
         BEGIN
            EXECUTE IMMEDIATE i.pk_sup;
            DBMS_OUTPUT.PUT_LINE (i.pk_sup || ';' || '-- DONE');
         EXCEPTION WHEN OTHERS
           THEN
             DBMS_OUTPUT.PUT_LINE (i.pk_sup || ';' || '-- FAILED' || ' - ' || SQLCODE || ', ' || SQLERRM);
         END;
        END LOOP;
END;
/