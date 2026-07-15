-- ================================================================
-- DDL: CRTSEQ02.sql
-- SEQUENCE: BAC_CARD_SEQ
-- DESCRIPTION: Generates unique CARD_ID values for debit/credit cards
-- ================================================================

CREATE SEQUENCE BAC_CARD_SEQ
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE
    CACHE 10
    ORDER;

COMMENT ON SEQUENCE BAC_CARD_SEQ IS
    'Sequence for business banking card master IDs';
