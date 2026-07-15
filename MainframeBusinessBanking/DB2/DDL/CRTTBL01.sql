-- ================================================================
-- DDL: CRTTBL01.sql
-- TABLE: TB_BAC_APPLICATION
-- DATABASE: DB2 - Business Banking Account Creation
-- DESCRIPTION: Master application header for business accounts
-- ================================================================

CREATE TABLE TB_BAC_APPLICATION
(
    APP_ID              CHAR(10)        NOT NULL,
    APP_STATUS          CHAR(2)         NOT NULL DEFAULT 'DR',
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
    ACCOUNT_TYPE        CHAR(2),
    CURRENCY            CHAR(3),
    INITIAL_DEPOSIT     DECIMAL(13,2),
    EXPECTED_TXN_VOL    INTEGER,
    EXPECTED_TXN_AMT    DECIMAL(13,2),
    SOURCE_OF_FUNDS     VARCHAR(30),
    RISK_RATING         CHAR(2),
    PEP_FLAG            CHAR(1)         DEFAULT 'N',
    SANCTIONS_FLAG      CHAR(1)         DEFAULT 'N',
    DOCS_RECEIVED       CHAR(1)         DEFAULT 'N',
    BOARD_RESOLUTION    CHAR(1)         DEFAULT 'N',
    UBO_DECLARATION     CHAR(1)         DEFAULT 'N',
    MAKER_ID            CHAR(8),
    CHECKER_ID          CHAR(8),
    CREATED_TIMESTAMP   TIMESTAMP       NOT NULL DEFAULT CURRENT TIMESTAMP,
    UPDATED_TIMESTAMP   TIMESTAMP       NOT NULL DEFAULT CURRENT TIMESTAMP,
    ACCOUNT_NUMBER      CHAR(12),
    BRANCH_CODE         CHAR(6),
    REJECTION_REASON    VARCHAR(100),
    PRIMARY KEY (APP_ID)
)
IN BACDB.BACTS01
CCSID EBCDIC;

-- Check constraints
ALTER TABLE TB_BAC_APPLICATION
    ADD CONSTRAINT CK_BAC_APP_STATUS
    CHECK (APP_STATUS IN ('DR','SB','PE','KY','AP','RJ','OP'));

ALTER TABLE TB_BAC_APPLICATION
    ADD CONSTRAINT CK_BAC_BUSINESS_TYPE
    CHECK (BUSINESS_TYPE IN ('LC','CP','PT','SP','NP','TR'));

ALTER TABLE TB_BAC_APPLICATION
    ADD CONSTRAINT CK_BAC_ACCOUNT_TYPE
    CHECK (ACCOUNT_TYPE IN ('CH','SV','MM','TD'));

ALTER TABLE TB_BAC_APPLICATION
    ADD CONSTRAINT CK_BAC_RISK_RATING
    CHECK (RISK_RATING IN ('LO','MD','HI'));

COMMENT ON TABLE TB_BAC_APPLICATION IS
    'Business Banking Account Application Master';
