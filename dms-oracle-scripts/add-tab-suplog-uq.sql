-- ##################################################################################
-- Oracle Database as a source
-- Usage    : SQL> @add-tab-suplog-uq.sql SCHEMANAME 
-- ##################################################################################

DECLARE 
 sql_stmt     VARCHAR2(1000);
BEGIN
 -- Get list of tables with only Unique Keys
 FOR i IN (
           SELECT 'ALTER TABLE "' || owner || '"."' || table_name || '" ADD SUPPLEMENTAL LOG GROUP ' || log_group_name || ' (' || index_column || ') ALWAYS' uq_sup
           FROM (
           SELECT ind.index_owner owner, ind.table_name, ind.index_name, LOWER(ind.table_name)||'_dmsloggrp' log_group_name, rtrim(xmlagg(xmlelement(e,ind.column_name,',').extract('//text()') ORDER BY ind.column_position),',') AS index_column 
            FROM dba_ind_columns ind, dba_constraints cons 
           WHERE ind.index_owner=cons.owner 
             AND ind.table_name=cons.table_name 
             AND cons.constraint_type='U'
             AND ind.table_name NOT IN (SELECT tab.table_name FROM dba_tables tab, dba_constraints cons WHERE tab.owner = cons.owner AND tab.table_name = cons.table_name AND cons.constraint_type = 'P' AND tab.owner = UPPER('&1'))
             AND ind.index_owner = UPPER('&1')
           GROUP BY ind.index_owner, ind.table_name, ind.index_name
           ORDER BY ind.index_name)
          )
 	LOOP
	  BEGIN
            EXECUTE IMMEDIATE i.uq_sup;
	    DBMS_OUTPUT.PUT_LINE (i.uq_sup || ';' || '-- DONE');
          EXCEPTION WHEN OTHERS
           THEN
             DBMS_OUTPUT.PUT_LINE (i.uq_sup || ';' || '-- FAILED' || ' - ' || SQLCODE || ', ' || SQLERRM);
	  END;
 	END LOOP;
END;
/