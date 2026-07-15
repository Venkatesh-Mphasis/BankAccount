-- ================================================================
-- DDL: CRTTBL03.sql
-- TABLE: TB_BAC_SIGNATORY
-- DESCRIPTION: Authorized signatories and beneficial owners
-- ================================================================

CREATE TABLE TB_BAC_SIGNATORY
(
    SIG_ID              CHAR(10)        NOT NULL,
    APP_ID              CHAR(10)        NOT NULL,
    CUST_ID             CHAR(10),
    NAME                VARCHAR(50)     NOT NULL,
    TITLE               VARCHAR(30),
    DOB                 DATE,
    SSN                 VARCHAR(11),
    ADDR_LINE1          VARCHAR(40),
    ADDR_LINE2          VARCHAR(40),
    CITY                VARCHAR(25),
    STATE               CHAR(2),
    COUNTRY             CHAR(3),
    ZIP_CODE            VARCHAR(10),
    PHONE               VARCHAR(15),
    EMAIL               VARCHAR(50),
    OWNERSHIP_PCT       DECIMAL(5,2),
    SIG_TYPE            CHAR(1)         NOT NULL,
    ID_TYPE             VARCHAR(10),
    ID_NUMBER           VARCHAR(20),
    CREATED_TIMESTAMP   TIMESTAMP       NOT NULL DEFAULT CURRENT TIMESTAMP,
    UPDATED_TIMESTAMP   TIMESTAMP       NOT NULL DEFAULT CURRENT TIMESTAMP,
    PRIMARY KEY (SIG_ID)
)
IN BACDB.BACTS01
CCSID EBCDIC;

ALTER TABLE TB_BAC_SIGNATORY
    ADD CONSTRAINT FK_BAC_SIG_APP
    FOREIGN KEY (APP_ID) REFERENCES TB_BAC_APPLICATION(APP_ID);

ALTER TABLE TB_BAC_SIGNATORY
    ADD CONSTRAINT CK_BAC_SIG_TYPE
    CHECK (SIG_TYPE IN ('A','B'));

COMMENT ON TABLE TB_BAC_SIGNATORY IS
    'Authorized Signatory / Beneficial Owner Master';
