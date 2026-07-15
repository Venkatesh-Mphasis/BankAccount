-- ================================================================
-- DDL: CRTSEQ01.sql
-- DESCRIPTION: DB2 sequences for surrogate IDs
-- ================================================================

CREATE SEQUENCE BAC_APP_SEQ
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO CYCLE
    CACHE 20;

CREATE SEQUENCE BAC_SIG_SEQ
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO CYCLE
    CACHE 20;

CREATE SEQUENCE BAC_CUST_SEQ
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO CYCLE
    CACHE 20;

CREATE SEQUENCE BAC_ACC_SEQ
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO CYCLE
    CACHE 20;
