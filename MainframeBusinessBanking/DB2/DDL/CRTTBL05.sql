-- ================================================================
-- DDL: CRTTBL05.sql
-- TABLE: TB_BAC_DOCUMENT
-- DESCRIPTION: KYC / Compliance document checklist
-- ================================================================

CREATE TABLE TB_BAC_DOCUMENT
(
    APP_ID              CHAR(10)        NOT NULL,
    DOC_TYPE            CHAR(2)         NOT NULL,
    DOC_REF             VARCHAR(30),
    STATUS              CHAR(1)         DEFAULT 'N',
    RECEIVED_DATE       DATE,
    REMARKS             VARCHAR(50),
    PRIMARY KEY (APP_ID, DOC_TYPE)
)
IN BACDB.BACTS01
CCSID EBCDIC;

ALTER TABLE TB_BAC_DOCUMENT
    ADD CONSTRAINT FK_BAC_DOC_APP
    FOREIGN KEY (APP_ID) REFERENCES TB_BAC_APPLICATION(APP_ID);

ALTER TABLE TB_BAC_DOCUMENT
    ADD CONSTRAINT CK_BAC_DOC_TYPE
    CHECK (DOC_TYPE IN ('AR','TC','AD','ID','BO','BR'));

COMMENT ON TABLE TB_BAC_DOCUMENT IS
    'KYC Document Checklist';
