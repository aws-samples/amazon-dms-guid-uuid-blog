-- Create table TEST_TBL_2 on Oracle
CREATE TABLE sports.test_tbl_2
(
   t_col1 VARCHAR2(10), 
   t_col2 RAW(16) DEFAULT SYS_GUID(), 
   t_col3 VARCHAR2(64) DEFAULT 'Available',
   CONSTRAINT test_tbl_2_t_col1_pk PRIMARY KEY (t_col1)
);

INSERT INTO sports.test_tbl_2 (t_col1, t_col2) VALUES (1000, SYS_GUID());
INSERT INTO sports.test_tbl_2 (t_col1, t_col2) VALUES (1001, SYS_GUID());
INSERT INTO sports.test_tbl_2 (t_col1, t_col2) VALUES (1002, SYS_GUID());
COMMIT;

COL t_col2 FORMAT a40
COL t_col3 FORMAT a20
SELECT * FROM sports.test_tbl_2;

-- Enabling supplemental logging on TEST_TBL_2 table
ALTER TABLE sports.test_tbl_2 ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;

-- Pre-create the target table with UUID data type for column T_COL2_TMP and keep T_COL2 as BYTEA data type (AWS DMS by default map Oracle RAW data type to BYTEA on PostgreSQL)

CREATE TABLE sports.test_tbl_2
(
    t_col1 varchar(10) NOT NULL,
    t_col2_tmp uuid NOT NULL DEFAULT uuid_generate_v4(),
    t_col3 varchar(64) NOT NULL DEFAULT 'Available'::character varying,
    t_col2 bytea,
    CONSTRAINT test_tbl_2_t_col1_pk PRIMARY KEY (t_col1)
);

SELECT * FROM sports.test_tbl_2;


-- Performing some DML operations on the TEST_TBL_2 table on Oracle
INSERT INTO sports.test_tbl_2 (t_col1, t_col2) VALUES (1003, SYS_GUID());
INSERT INTO sports.test_tbl_2 (t_col1, t_col2) VALUES (1004, SYS_GUID());
INSERT INTO sports.test_tbl_2 (t_col1, t_col2) VALUES (1005, SYS_GUID());
INSERT INTO sports.test_tbl_2 (t_col1, t_col2) VALUES (1006, SYS_GUID());
INSERT INTO sports.test_tbl_2 (t_col1, t_col2) VALUES (1007, SYS_GUID());
UPDATE sports.test_tbl_2 SET t_col3 = 'Unavailable' WHERE t_col1 IN (1000,1001,1002);
COMMIT;

COL t_col2 FORMAT a40
COL t_col3 FORMAT a20
SELECT * FROM sports.test_tbl_2;


-- Check the PostgreSQL target to confirm the data is replicated:

SELECT * FROM sports.test_tbl_2 ORDER BY t_col1;


-- On the PostgreSQL target, after the AWS DMS task is stopped, you can drop T_COL2 and rename T_COL2_TMP back to T_COL2:

-- At this stage, DMS task is stopped
ALTER TABLE sports.test_tbl_2 DROP column t_col2;
ALTER TABLE sports.test_tbl_2 RENAME COLUMN t_col2_tmp TO t_col2;
SELECT * FROM sports.test_tbl_2 ORDER BY t_col1;
