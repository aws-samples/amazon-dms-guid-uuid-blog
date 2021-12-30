-- ##################################################################################
-- Oracle Database as a source
-- Usage    : SQL> @show-db-suplog.sql 
-- ##################################################################################

COLUMN log_min HEADING 'Minimum|Supplemental|Logging?' FORMAT A12
COLUMN log_pk HEADING 'Primary Key|Supplemental|Logging?' FORMAT A12
COLUMN log_fk HEADING 'Foreign Key|Supplemental|Logging?' FORMAT A12
COLUMN log_ui HEADING 'Unique|Supplemental|Logging?' FORMAT A12
COLUMN log_all HEADING 'All Columns|Supplemental|Logging?' FORMAT A12

SELECT supplemental_log_data_min log_min
      ,supplemental_log_data_pk log_pk
      ,supplemental_log_data_fk log_fk
      ,supplemental_log_data_ui log_ui
      ,supplemental_log_data_all log_all 
 FROM v$database;