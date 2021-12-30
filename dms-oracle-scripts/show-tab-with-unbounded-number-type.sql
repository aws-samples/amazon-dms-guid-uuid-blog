-- ##################################################################################
-- Oracle Database as a source
-- Usage    : SQL> @add-tab-with-unbounded-number-type.sql TABLENAME 
-- ##################################################################################

COL owner FORMAT A15
COL table_name FORMAT A30
COL column_name FORMAT A30
COL data_type FORMAT A30
COL data_scale FORMAT A40
COL data_precision FORMAT A40
SELECT a.owner, a.table_name, b.object_type, a.column_name, a.data_type, a.data_scale, a.data_precision
 FROM dba_tab_columns a, dba_objects b
WHERE a.data_type = 'NUMBER'
  AND a.data_precision IS NULL 
  AND a.data_scale IS NULL 
  AND a.owner = UPPER('&1')
  AND a.owner = b.owner
  AND a.table_name = b.object_name
  AND b.object_type = 'TABLE';