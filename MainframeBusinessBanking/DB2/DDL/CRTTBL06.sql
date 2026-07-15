-- ================================================================
-- DDL: CRTTBL06.sql
-- TABLE: TB_BAC_AUDIT
-- DESCRIPTION: Application status audit trail
-- ================================================================

CREATE TABLE TB_BAC_AUDIT
(
    AUDIT_ID            BIGINT          NOT NULL
                        GENERATED ALWAYS AS IDENTITY,
    APP_ID              CHAR(10)        NOT NULL,
    STATUS_FROM         CHAR(2),
    STATUS_TO           CHAR(2),
    USER_ID             CHAR(8),
    ACTION_TIMESTAMP    TIMESTAMP       NOT NULL DEFAULT CURRENT TIMESTAMP,
    ACTION_TYPE         CHAR(2),
    REMARKS             VARCHAR(100),
    PRIMARY KEY (AUDIT_ID)
)
IN BACDB.BACTS01
CCSID EBCDIC;

ALTER TABLE TB_BAC_AUDIT
    ADD CONSTRAINT FK_BAC_AUD_APP
    FOREIGN KEY (APP_ID) REFERENCES TB_BAC_APPLICATION(APP_ID);

CREATE INDEX IX_BAC_AUDIT_APP
    ON TB_BAC_AUDIT (APP_ID)
    USING STOGROUP BACIX;

COMMENT ON TABLE TB_BAC_AUDIT IS
    'Application Status Audit Trail';
