-- ================================================================
-- DML: QRYCRD01.sql
-- DESCRIPTION: Common inquiries against the card master
-- ================================================================

-- List all cards with linked account and customer details
SELECT C.CARD_ID,
       C.CARD_NUMBER,
       C.CARD_TYPE,
       C.CARD_NETWORK,
       C.CARD_PRODUCT,
       C.CARD_STATUS,
       C.PLASTIC_STATUS,
       C.EMBOSS_NAME,
       C.DAILY_LIMIT,
       C.ATM_LIMIT,
       C.MONTHLY_LIMIT,
       C.EXPIRY_DATE,
       A.ACCOUNT_NUMBER,
       A.BUSINESS_NAME
FROM   TB_BAC_CARD C
JOIN   TB_BAC_ACCOUNT A
  ON   C.ACCOUNT_NUMBER = A.ACCOUNT_NUMBER
ORDER BY C.CREATED_TIMESTAMP;

-- Find cards for a specific account
SELECT CARD_ID,
       CARD_NUMBER,
       CARD_STATUS,
       PLASTIC_STATUS,
       DAILY_LIMIT,
       AVAILABLE_LIMIT
FROM   TB_BAC_CARD
WHERE  ACCOUNT_NUMBER = '000101000016';

-- Count cards by plastic status
SELECT PLASTIC_STATUS,
       COUNT(*) AS CARD_COUNT
FROM   TB_BAC_CARD
GROUP BY PLASTIC_STATUS;
