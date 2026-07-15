-- ================================================================
-- DDL: CRTTBL02.sql
-- TABLE: TB_BAC_CUSTOMER
-- DESCRIPTION: Opened business / corporate customer master
-- ================================================================

CREATE TABLE TB_BAC_CUSTOMER
(
    CUST_ID             CHAR(10)        NOT NULL,
    APP_ID              CHAR(10)        NOT NULL,
    BUSINESS_NAME       VARCHAR(60)     NOT NULL,
    TRADE_NAME          VARCHAR(40),
    REGISTRATION_NO     VARCHAR(20),
    TAX_ID              VARCHAR(15),
    INCORP_DATE         DATE,
    BUSINESS_TYPE       CHAR(2),
    INDUSTRY_CODE       VARCHAR(6),
    ANNUAL_REVENUE      DECIMAL(13,2),
    EMPLOYEE_COUNT      INTEGER,
    ADDR_LINE1          VARCHAR(40),
    ADDR_LINE2          VARCHAR(40),
    CITY                VARCHAR(25),
    STATE               CHAR(2),
    COUNTRY             CHAR(3),
    ZIP_CODE            VARCHAR(10),
    PHONE               VARCHAR(15),
    EMAIL               VARCHAR(50),
    CONTACT_NAME        VARCHAR(50),
    RISK_RATING         CHAR(2),
    STATUS              CHAR(2)         DEFAULT 'AC',
    CREATED_TIMESTAMP   TIMESTAMP       NOT NULL DEFAULT CURRENT TIMESTAMP,
    UPDATED_TIMESTAMP   TIMESTAMP       NOT NULL DEFAULT CURRENT TIMESTAMP,
    PRIMARY KEY (CUST_ID)
)
IN BACDB.BACTS01
CCSID EBCDIC;

ALTER TABLE TB_BAC_CUSTOMER
    ADD CONSTRAINT FK_BAC_CUST_APP
    FOREIGN KEY (APP_ID) REFERENCES TB_BAC_APPLICATION(APP_ID);

COMMENT ON TABLE TB_BAC_CUSTOMER IS
    'Business Banking Customer Master';
