-- Create table TEST_TBL_1 on Oracle
CREATE TABLE sports.test_tbl_1
(
   t_col1 VARCHAR2(10), 
   t_col2 RAW(16) DEFAULT SYS_GUID(), 
   t_col3 VARCHAR2(64) DEFAULT 'Available',
   CONSTRAINT test_tbl_1_t_col1_pk PRIMARY KEY (t_col1)
);

INSERT INTO sports.test_tbl_1 (t_col1) VALUES (1000);
INSERT INTO sports.test_tbl_1 (t_col1) VALUES (1001);
COMMIT;

COL t_col2 FORMAT a40
COL t_col3 FORMAT a20
SELECT * FROM sports.test_tbl_1;

-- Create materialized view log on sports.test_tbl_1 table with PRIMARY KEY
CREATE MATERIALIZED VIEW LOG ON sports.test_tbl_1 WITH PRIMARY KEY, ROWID;

-- Create materialized view sports.test_tbl_1_mvw and convert GUID value to UUID format
CREATE MATERIALIZED VIEW sports.test_tbl_1_mvw (t_col1, t_col2, t_col3)
 LOGGING
 NOCOMPRESS
 NOCACHE
 NOPARALLEL
 REFRESH FAST
 ON COMMIT
 WITH PRIMARY KEY
 DISABLE QUERY REWRITE
AS
SELECT t_col1 
      ,REGEXP_REPLACE(RAWTOHEX(t_col2),'([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5') AS t_col2
      ,t_col3
FROM  sports.test_tbl_1;

COL t_col2 FORMAT a40
COL t_col3 FORMAT a20
SELECT * FROM sports.test_tbl_1_mvw;

-- Enable supplemental logging on the materialized view sports.test_tbl_1_mvw 
ALTER TABLE sports.test_tbl_1_mvw ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;


-- Pre-create the target table with UUID data type
CREATE SCHEMA sports;
CREATE EXTENSION "uuid-ossp";
CREATE TABLE sports.test_tbl_1
(
    t_col1 VARCHAR(10) NOT NULL,
    t_col2 UUID NOT NULL DEFAULT uuid_generate_v4(),
    t_col3 VARCHAR(64) NOT NULL DEFAULT 'Available'::character varying,
    CONSTRAINT test_tbl_1_t_col1_pk PRIMARY KEY (t_col1)
);

SELECT * FROM sports.test_tbl_1;


-- Performing some DML operations on the TEST_TBL_1 table on Oracle
INSERT INTO sports.test_tbl_1 (t_col1) VALUES (1002);
INSERT INTO sports.test_tbl_1 (t_col1) VALUES (1003);
UPDATE sports.test_tbl_1 SET t_col3 = 'Unavailable' WHERE t_col1 = 1000;
COMMIT;

-- Compare Master table SPORTS.TEST_TBL_1 and Materialized View SPORTS.TEST_TBL_1_MVW have same records on Oracle
SELECT * FROM sports.test_tbl_1;
SELECT * FROM sports.test_tbl_1_mvw ORDER BY t_col1;

-- Query table on PostgreSQL if changes were replicated by DMS
SELECT * FROM sports.test_tbl_1 ODER BY t_col1;

-- Stop DMS task
