-- ##################################################################################
-- Oracle Database as a source
-- Usage    : SQL> @show-schema-suplog.sql SCHEMANAME 
-- ##################################################################################

SET LINES 1000
SET PAGES 9999
COLUMN owner HEADING 'Owner' FORMAT A15
COLUMN log_group_name HEADING 'Log Group' FORMAT A30
COLUMN table_name HEADING 'Table' FORMAT A30
COLUMN always HEADING 'Conditional or|Unconditional' FORMAT A20
COLUMN log_group_type HEADING 'Type of Log Group' FORMAT A30

SELECT owner
      ,log_group_name
      ,table_name
      ,DECODE(ALWAYS,'ALWAYS', 'Unconditional','CONDITIONAL', 'Conditional') always
      ,log_group_type 
 FROM dba_log_groups 
WHERE owner IN UPPER('&1');