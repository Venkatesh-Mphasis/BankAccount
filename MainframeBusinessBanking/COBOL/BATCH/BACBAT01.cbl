       IDENTIFICATION DIVISION.
       PROGRAM-ID.    BACBAT01.
      ******************************************************************
      * BATCH COBOL: ACCOUNT OPENING + DEBIT CARD ISSUE                 *
      * PROCESSES TB_BAC_APPLICATION (STATUS 'SB' OR 'AP')             *
      * CREATES TB_BAC_CUSTOMER, TB_BAC_ACCOUNT, TB_BAC_CARD,           *
      * UPDATES APPLICATION, WRITES AUDIT TRAIL AND PRODUCES REPORT     *
      ******************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCT-OPEN-RPT
               ASSIGN TO RPTFILE
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-RPT-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  ACCT-OPEN-RPT
           RECORDING MODE IS F
           RECORD CONTAINS 120 CHARACTERS
           BLOCK CONTAINS 0 RECORDS.
       01  RPT-RECORD                  PIC X(120).

       WORKING-STORAGE SECTION.
       01  WS-PROGRAM-ID               PIC X(08) VALUE 'BACBAT01'.
       01  WS-RPT-STATUS               PIC X(02).
       01  WS-COMMIT-COUNT             PIC 9(05) VALUE ZEROS.
       01  WS-CUST-SEQ                 PIC 9(06) VALUE ZEROS.
       01  WS-ACC-SEQ                  PIC 9(05) VALUE ZEROS.
       01  WS-OLD-STATUS               PIC X(02).

       01  WS-HV-CUST-SEQ              PIC S9(09) COMP.
       01  WS-HV-CUST-SEQ-ZERO         PIC 9(06).
       01  WS-HV-ACC-SEQ               PIC S9(09) COMP.
       01  WS-HV-ACC-SEQ-ZERO          PIC 9(05).
       01  WS-HV-CARD-SEQ              PIC S9(09) COMP.
       01  WS-HV-CARD-SEQ-ZERO         PIC 9(03).

       01  WS-ACCOUNT-PART             PIC X(11).
       01  WS-ACCOUNT-NUM              PIC X(12).
       01  WS-PROD-CODE                PIC X(02).
       01  WS-BRANCH-PART              PIC X(04).
       01  WS-CHECK-DIGIT              PIC 9(01).
       01  WS-CHECK-SUM                PIC 9(04).
       01  WS-DIGIT                    PIC 9(01).
       01  WS-I                        PIC 9(02).

       01  WS-CARD-BASE                PIC X(15).
       01  WS-CARD-CHECK-DIGIT         PIC 9(01).
       01  WS-CARD-CHECK-SUM           PIC 9(04).
       01  WS-CARD-DGT                 PIC 9(01).
       01  WS-CARD-K                   PIC 9(02).

           COPY CPYBAC01.
           COPY CPYBAC02.
           COPY CPYBAC04.
           COPY CPYBAC07.
           COPY CPYBAC06.
           COPY CPYCOM01.
           COPY CPYERR01.

           EXEC SQL INCLUDE SQLCA END-EXEC.

       01  WS-REPORT-LINE.
           05  FILLER                    PIC X(02) VALUE SPACES.
           05  RPT-APP-ID              PIC X(10).
           05  FILLER                    PIC X(03) VALUE SPACES.
           05  RPT-CUST-ID             PIC X(10).
           05  FILLER                    PIC X(03) VALUE SPACES.
           05  RPT-ACCOUNT-NUM         PIC X(12).
           05  FILLER                    PIC X(03) VALUE SPACES.
           05  RPT-BUSINESS-NAME       PIC X(30).
           05  FILLER                    PIC X(03) VALUE SPACES.
           05  RPT-ACCOUNT-TYPE        PIC X(02).
           05  FILLER                    PIC X(03) VALUE SPACES.
           05  RPT-INITIAL-DEPOSIT     PIC ZZZ,ZZZ,ZZZ,ZZ9.99.
           05  FILLER                    PIC X(02) VALUE SPACES.
           05  RPT-STATUS              PIC X(02).

       01  WS-HEADER-LINE              PIC X(120) VALUE
           ' APP-ID     CUST-ID    ACCOUNT-NUM  BUSINESS-NAME'.

       PROCEDURE DIVISION.

       0000-MAIN.
           PERFORM 1000-OPEN-FILES
           PERFORM 1050-GET-TIMESTAMP
           PERFORM 2000-PROCESS-APPLICATIONS
           PERFORM 9000-DB2-COMMIT
           PERFORM 8000-CLOSE-FILES
           DISPLAY 'BACBAT01 COMPLETE - ACCOUNTS OPENED: '
                   WS-RECORDS-WRITTEN
           GOBACK.

      ******************************************************************
      * 1000-OPEN-FILES                                                *
      ******************************************************************
       1000-OPEN-FILES.
           OPEN OUTPUT ACCT-OPEN-RPT
           IF WS-RPT-STATUS NOT = '00'
               DISPLAY 'RPT OPEN ERROR ' WS-RPT-STATUS
               MOVE '9001' TO WS-ABEND-CODE
               PERFORM 9900-ABEND
           END-IF
           WRITE RPT-RECORD FROM WS-HEADER-LINE
           .

      ******************************************************************
      * 1050-GET-TIMESTAMP                                             *
      ******************************************************************
       1050-GET-TIMESTAMP.
           EXEC SQL
               SELECT CURRENT DATE, CURRENT TIME, CURRENT TIMESTAMP
               INTO :WS-FORMATTED-DATE, :WS-FORMATTED-TIME,
                    :WS-FORMATTED-TIMESTAMP
               FROM SYSIBM.SYSDUMMY1
           END-EXEC

           IF SQLCODE NOT = 0
               DISPLAY 'GET TIMESTAMP ERROR SQLCODE=' SQLCODE
               PERFORM 9900-DB2-ERROR
           END-IF
           .

      ******************************************************************
      * 2000-PROCESS-APPLICATIONS                                      *
      ******************************************************************
       2000-PROCESS-APPLICATIONS.
           EXEC SQL
               DECLARE C1 CURSOR FOR
               SELECT APP_ID, APP_STATUS, BUSINESS_NAME, TRADE_NAME,
                      REGISTRATION_NO, TAX_ID, INCORP_DATE,
                      BUSINESS_TYPE, INDUSTRY_CODE, ANNUAL_REVENUE,
                      EMPLOYEE_COUNT, ADDR_LINE1, ADDR_LINE2, CITY,
                      STATE, COUNTRY, ZIP_CODE, PHONE, EMAIL,
                      CONTACT_NAME, ACCOUNT_TYPE, CURRENCY,
                      INITIAL_DEPOSIT, EXPECTED_TXN_VOL,
                      EXPECTED_TXN_AMT, SOURCE_OF_FUNDS, RISK_RATING,
                      PEP_FLAG, SANCTIONS_FLAG, DOCS_RECEIVED,
                      BOARD_RESOLUTION, UBO_DECLARATION, MAKER_ID,
                      CHECKER_ID, CREATED_TIMESTAMP, UPDATED_TIMESTAMP,
                      ACCOUNT_NUMBER, BRANCH_CODE, REJECTION_REASON,
                      CARD_REQUESTED, CARD_TYPE, CARD_DAILY_LIMIT,
                      CARD_ATM_LIMIT, CARD_MONTHLY_LIMIT,
                      CARD_EMBOSS_NAME
               FROM TB_BAC_APPLICATION
               WHERE APP_STATUS IN ('SB','AP')
               FOR UPDATE OF APP_STATUS, ACCOUNT_NUMBER,
                             CHECKER_ID, UPDATED_TIMESTAMP
           END-EXEC

           IF SQLCODE NOT = 0
               DISPLAY 'DECLARE CURSOR ERROR SQLCODE=' SQLCODE
               PERFORM 9900-DB2-ERROR
           END-IF

           EXEC SQL OPEN C1 END-EXEC

           PERFORM UNTIL SQLCODE = +100
               EXEC SQL
                   FETCH C1 INTO
                   :WS-APP-ID, :WS-APP-STATUS,
                   :WS-APP-BUSINESS-NAME, :WS-APP-TRADE-NAME,
                   :WS-APP-REGISTRATION-NO, :WS-APP-TAX-ID,
                   :WS-APP-INCORP-DATE, :WS-APP-BUSINESS-TYPE,
                   :WS-APP-INDUSTRY-CODE, :WS-APP-ANNUAL-REVENUE,
                   :WS-APP-EMPLOYEE-COUNT, :WS-APP-ADDR-LINE1,
                   :WS-APP-ADDR-LINE2, :WS-APP-ADDR-CITY,
                   :WS-APP-ADDR-STATE, :WS-APP-ADDR-COUNTRY,
                   :WS-APP-ADDR-ZIP, :WS-APP-PHONE, :WS-APP-EMAIL,
                   :WS-APP-CONTACT-NAME, :WS-APP-ACCOUNT-TYPE,
                   :WS-APP-CURRENCY, :WS-APP-INITIAL-DEPOSIT,
                   :WS-APP-EXPECTED-TXN-VOL, :WS-APP-EXPECTED-TXN-AMT,
                   :WS-APP-SOURCE-OF-FUNDS, :WS-APP-RISK-RATING,
                   :WS-APP-PEP-FLAG, :WS-APP-SANCTIONS-FLAG,
                   :WS-APP-DOCS-RECEIVED, :WS-APP-BOARD-RESOLUTION,
                   :WS-APP-UBO-DECLARATION, :WS-APP-MAKER-ID,
                   :WS-APP-CHECKER-ID, :WS-APP-CREATED-TIMESTAMP,
                   :WS-APP-UPDATED-TIMESTAMP, :WS-APP-ACCOUNT-NUMBER,
                   :WS-APP-BRANCH-CODE, :WS-APP-REJECTION-REASON,
                   :WS-APP-CARD-REQUESTED, :WS-APP-CARD-TYPE,
                   :WS-APP-CARD-DAILY-LIMIT, :WS-APP-CARD-ATM-LIMIT,
                   :WS-APP-CARD-MONTHLY-LIMIT,
                   :WS-APP-CARD-EMBOSS-NAME
               END-EXEC

               IF SQLCODE = +100
                   EXIT PARAGRAPH
               END-IF
               IF SQLCODE < 0
                   DISPLAY 'FETCH ERROR SQLCODE=' SQLCODE
                   PERFORM 9900-DB2-ERROR
               END-IF

               ADD 1 TO WS-RECORDS-READ
               MOVE WS-APP-STATUS TO WS-OLD-STATUS
               PERFORM 3000-OPEN-ACCOUNT
           END-PERFORM

           EXEC SQL CLOSE C1 END-EXEC
           .

      ******************************************************************
      * 3000-OPEN-ACCOUNT: CREATE CUSTOMER, ACCOUNT, CARD AND UPDATE APP*
      ******************************************************************
       3000-OPEN-ACCOUNT.
           PERFORM 3100-GET-NEXT-ACC-SEQ
           PERFORM 3200-GENERATE-ACCOUNT-NUMBER

           INITIALIZE WS-BAC-CUSTOMER-REC
           PERFORM 3100-GET-NEXT-CUST-SEQ

           MOVE WS-APP-ID               TO WS-CUST-APP-ID
           MOVE WS-APP-BUSINESS-NAME    TO WS-CUST-BUSINESS-NAME
           MOVE WS-APP-TRADE-NAME       TO WS-CUST-TRADE-NAME
           MOVE WS-APP-REGISTRATION-NO  TO WS-CUST-REGISTRATION-NO
           MOVE WS-APP-TAX-ID           TO WS-CUST-TAX-ID
           MOVE WS-APP-INCORP-DATE      TO WS-CUST-INCORP-DATE
           MOVE WS-APP-BUSINESS-TYPE    TO WS-CUST-BUSINESS-TYPE
           MOVE WS-APP-INDUSTRY-CODE    TO WS-CUST-INDUSTRY-CODE
           MOVE WS-APP-ANNUAL-REVENUE   TO WS-CUST-ANNUAL-REVENUE
           MOVE WS-APP-EMPLOYEE-COUNT   TO WS-CUST-EMPLOYEE-COUNT
           MOVE WS-APP-ADDR-LINE1       TO WS-CUST-ADDR-LINE1
           MOVE WS-APP-ADDR-LINE2       TO WS-CUST-ADDR-LINE2
           MOVE WS-APP-ADDR-CITY        TO WS-CUST-ADDR-CITY
           MOVE WS-APP-ADDR-STATE       TO WS-CUST-ADDR-STATE
           MOVE WS-APP-ADDR-COUNTRY     TO WS-CUST-ADDR-COUNTRY
           MOVE WS-APP-ADDR-ZIP         TO WS-CUST-ADDR-ZIP
           MOVE WS-APP-PHONE            TO WS-CUST-PHONE
           MOVE WS-APP-EMAIL            TO WS-CUST-EMAIL
           MOVE WS-APP-CONTACT-NAME     TO WS-CUST-CONTACT-NAME
           MOVE WS-APP-RISK-RATING      TO WS-CUST-RISK-RATING
           MOVE 'AC'                    TO WS-CUST-STATUS
           MOVE WS-FORMATTED-TIMESTAMP  TO WS-CUST-CREATED-TIMESTAMP
           MOVE WS-FORMATTED-TIMESTAMP  TO WS-CUST-UPDATED-TIMESTAMP

           EXEC SQL
               INSERT INTO TB_BAC_CUSTOMER
               (CUST_ID, APP_ID, BUSINESS_NAME, TRADE_NAME,
                REGISTRATION_NO, TAX_ID, INCORP_DATE, BUSINESS_TYPE,
                INDUSTRY_CODE, ANNUAL_REVENUE, EMPLOYEE_COUNT,
                ADDR_LINE1, ADDR_LINE2, CITY, STATE, COUNTRY,
                ZIP_CODE, PHONE, EMAIL, CONTACT_NAME, RISK_RATING,
                STATUS, CREATED_TIMESTAMP, UPDATED_TIMESTAMP)
               VALUES
               (:WS-CUST-ID, :WS-APP-ID, :WS-CUST-BUSINESS-NAME,
                :WS-CUST-TRADE-NAME, :WS-CUST-REGISTRATION-NO,
                :WS-CUST-TAX-ID, :WS-CUST-INCORP-DATE,
                :WS-CUST-BUSINESS-TYPE, :WS-CUST-INDUSTRY-CODE,
                :WS-CUST-ANNUAL-REVENUE, :WS-CUST-EMPLOYEE-COUNT,
                :WS-CUST-ADDR-LINE1, :WS-CUST-ADDR-LINE2,
                :WS-CUST-ADDR-CITY, :WS-CUST-ADDR-STATE,
                :WS-CUST-ADDR-COUNTRY, :WS-CUST-ADDR-ZIP,
                :WS-CUST-PHONE, :WS-CUST-EMAIL, :WS-CUST-CONTACT-NAME,
                :WS-CUST-RISK-RATING, :WS-CUST-STATUS,
                :WS-CUST-CREATED-TIMESTAMP, :WS-CUST-UPDATED-TIMESTAMP)
           END-EXEC

           IF SQLCODE NOT = 0
               DISPLAY 'INSERT CUSTOMER ERROR SQLCODE=' SQLCODE
               PERFORM 9900-DB2-ERROR
           END-IF

           INITIALIZE WS-BAC-ACCOUNT-REC
           MOVE WS-ACCOUNT-NUM          TO WS-ACC-ACCOUNT-NUMBER
           MOVE WS-APP-ID               TO WS-ACC-APP-ID
           MOVE WS-CUST-ID              TO WS-ACC-CUST-ID
           MOVE WS-APP-ACCOUNT-TYPE     TO WS-ACC-ACCOUNT-TYPE
           MOVE WS-APP-CURRENCY         TO WS-ACC-CURRENCY
           MOVE 'AC'                    TO WS-ACC-STATUS
           MOVE WS-FORMATTED-DATE       TO WS-ACC-OPEN-DATE
           MOVE WS-APP-INITIAL-DEPOSIT  TO WS-ACC-BALANCE
           MOVE WS-APP-INITIAL-DEPOSIT  TO WS-ACC-AVAILABLE-BALANCE
           MOVE WS-APP-INITIAL-DEPOSIT  TO WS-ACC-INITIAL-DEPOSIT
           MOVE WS-APP-BRANCH-CODE      TO WS-ACC-BRANCH-CODE
           MOVE WS-APP-MAKER-ID         TO WS-ACC-MAKER-ID
           MOVE 'BATCH01'               TO WS-ACC-CHECKER-ID
           MOVE WS-FORMATTED-TIMESTAMP  TO WS-ACC-CREATED-TIMESTAMP
           MOVE WS-FORMATTED-TIMESTAMP  TO WS-ACC-UPDATED-TIMESTAMP

           EXEC SQL
               INSERT INTO TB_BAC_ACCOUNT
               (ACCOUNT_NUMBER, APP_ID, CUST_ID, ACCOUNT_TYPE,
                CURRENCY, STATUS, OPEN_DATE, BALANCE,
                AVAILABLE_BALANCE, INITIAL_DEPOSIT, BRANCH_CODE,
                MAKER_ID, CHECKER_ID, CREATED_TIMESTAMP,
                UPDATED_TIMESTAMP)
               VALUES
               (:WS-ACC-ACCOUNT-NUMBER, :WS-APP-ID, :WS-CUST-ID,
                :WS-ACC-ACCOUNT-TYPE, :WS-ACC-CURRENCY,
                :WS-ACC-STATUS, :WS-ACC-OPEN-DATE, :WS-ACC-BALANCE,
                :WS-ACC-AVAILABLE-BALANCE, :WS-ACC-INITIAL-DEPOSIT,
                :WS-ACC-BRANCH-CODE, :WS-ACC-MAKER-ID,
                :WS-ACC-CHECKER-ID, :WS-ACC-CREATED-TIMESTAMP,
                :WS-ACC-UPDATED-TIMESTAMP)
           END-EXEC

           IF SQLCODE NOT = 0
               DISPLAY 'INSERT ACCOUNT ERROR SQLCODE=' SQLCODE
               PERFORM 9900-DB2-ERROR
           END-IF

      *    UPDATE APPLICATION TO OPENED
           EXEC SQL
               UPDATE TB_BAC_APPLICATION
               SET APP_STATUS = 'OP',
                   ACCOUNT_NUMBER = :WS-ACCOUNT-NUM,
                   CHECKER_ID = 'BATCH01',
                   UPDATED_TIMESTAMP = CURRENT TIMESTAMP
               WHERE CURRENT OF C1
           END-EXEC

           IF SQLCODE NOT = 0
               DISPLAY 'UPDATE APP ERROR SQLCODE=' SQLCODE
               PERFORM 9900-DB2-ERROR
           END-IF

      *    ISSUE DEBIT CARD IF REQUESTED
           IF WS-APP-CARD-REQUESTED = 'Y'
               PERFORM 3300-ISSUE-DEBIT-CARD
           END-IF

      *    AUDIT TRAIL
           MOVE WS-APP-ID               TO WS-AUD-APP-ID
           MOVE WS-OLD-STATUS           TO WS-AUD-STATUS-FROM
           MOVE 'OP'                    TO WS-AUD-STATUS-TO
           MOVE 'BATCH01'               TO WS-AUD-USER-ID
           MOVE 'AO'                    TO WS-AUD-ACTION-TYPE
           MOVE 'ACCOUNT OPENED BY BATCH' TO WS-AUD-REMARKS

           EXEC SQL
               INSERT INTO TB_BAC_AUDIT
               (APP_ID, STATUS_FROM, STATUS_TO, USER_ID,
                ACTION_TYPE, REMARKS)
               VALUES
               (:WS-AUD-APP-ID, :WS-AUD-STATUS-FROM, :WS-AUD-STATUS-TO,
                :WS-AUD-USER-ID, :WS-AUD-ACTION-TYPE, :WS-AUD-REMARKS)
           END-EXEC

           IF SQLCODE NOT = 0
               DISPLAY 'INSERT AUDIT ERROR SQLCODE=' SQLCODE
               PERFORM 9900-DB2-ERROR
           END-IF

      *    WRITE REPORT
           MOVE WS-APP-ID               TO RPT-APP-ID
           MOVE WS-CUST-ID              TO RPT-CUST-ID
           MOVE WS-ACCOUNT-NUM          TO RPT-ACCOUNT-NUM
           MOVE WS-APP-BUSINESS-NAME    TO RPT-BUSINESS-NAME
           MOVE WS-APP-ACCOUNT-TYPE     TO RPT-ACCOUNT-TYPE
           MOVE WS-APP-INITIAL-DEPOSIT  TO RPT-INITIAL-DEPOSIT
           MOVE 'OP'                    TO RPT-STATUS
           WRITE RPT-RECORD FROM WS-REPORT-LINE

           ADD 1 TO WS-RECORDS-WRITTEN
           ADD 1 TO WS-COMMIT-COUNT
           IF WS-COMMIT-COUNT >= 10
               PERFORM 9000-DB2-COMMIT
               MOVE 0 TO WS-COMMIT-COUNT
           END-IF
           .

      ******************************************************************
      * 3100-GET-NEXT-CUST-SEQ: GENERATE NEXT CUST ID                  *
      ******************************************************************
       3100-GET-NEXT-CUST-SEQ.
           EXEC SQL
               SELECT NEXT VALUE FOR BAC_CUST_SEQ
               INTO :WS-HV-CUST-SEQ
               FROM SYSIBM.SYSDUMMY1
           END-EXEC

           IF SQLCODE NOT = 0
               DISPLAY 'CUST SEQ ERROR SQLCODE=' SQLCODE
               PERFORM 9900-DB2-ERROR
           END-IF

           MOVE WS-HV-CUST-SEQ TO WS-HV-CUST-SEQ-ZERO
           STRING 'CUST' WS-HV-CUST-SEQ-ZERO
               DELIMITED BY SIZE
               INTO WS-CUST-ID
           END-STRING
           .

      ******************************************************************
      * 3100-GET-NEXT-ACC-SEQ: GENERATE NEXT ACCOUNT SEQ                 *
      ******************************************************************
       3100-GET-NEXT-ACC-SEQ.
           EXEC SQL
               SELECT NEXT VALUE FOR BAC_ACC_SEQ
               INTO :WS-HV-ACC-SEQ
               FROM SYSIBM.SYSDUMMY1
           END-EXEC

           IF SQLCODE NOT = 0
               DISPLAY 'ACC SEQ ERROR SQLCODE=' SQLCODE
               PERFORM 9900-DB2-ERROR
           END-IF

           MOVE WS-HV-ACC-SEQ TO WS-HV-ACC-SEQ-ZERO
           .

      ******************************************************************
      * 3200-GENERATE-ACCOUNT-NUMBER: BRANCH+PRODUCT+SEQ+CHECK-DIGIT   *
      ******************************************************************
       3200-GENERATE-ACCOUNT-NUMBER.
           EVALUATE WS-APP-ACCOUNT-TYPE
               WHEN 'CH' MOVE '01' TO WS-PROD-CODE
               WHEN 'SV' MOVE '02' TO WS-PROD-CODE
               WHEN 'MM' MOVE '03' TO WS-PROD-CODE
               WHEN 'TD' MOVE '04' TO WS-PROD-CODE
               WHEN OTHER MOVE '00' TO WS-PROD-CODE
           END-EVALUATE

           IF WS-APP-BRANCH-CODE(3:1) IS NUMERIC
               MOVE WS-APP-BRANCH-CODE(3:4) TO WS-BRANCH-PART
           ELSE
               MOVE '0001' TO WS-BRANCH-PART
           END-IF

           STRING WS-BRANCH-PART WS-PROD-CODE WS-HV-ACC-SEQ-ZERO
               DELIMITED BY SIZE
               INTO WS-ACCOUNT-PART
           END-STRING

           MOVE ZEROS TO WS-CHECK-SUM
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
               MOVE FUNCTION NUMVAL(WS-ACCOUNT-PART(WS-I:1))
                   TO WS-DIGIT
               IF FUNCTION MOD(WS-I, 2) = 1
                   MULTIPLY WS-DIGIT BY 2 GIVING WS-DIGIT
               END-IF
               IF WS-DIGIT > 9
                   SUBTRACT 9 FROM WS-DIGIT
               END-IF
               ADD WS-DIGIT TO WS-CHECK-SUM
           END-PERFORM

           COMPUTE WS-CHECK-DIGIT = 10 - FUNCTION MOD(WS-CHECK-SUM, 10)
           IF WS-CHECK-DIGIT = 10
               MOVE 0 TO WS-CHECK-DIGIT
           END-IF

           STRING WS-ACCOUNT-PART WS-CHECK-DIGIT
               DELIMITED BY SIZE
               INTO WS-ACCOUNT-NUM
           END-STRING
           .

      ******************************************************************
      * 3300-ISSUE-DEBIT-CARD: GENERATE AND INSERT CARD MASTER          *
      ******************************************************************
       3300-ISSUE-DEBIT-CARD.
           INITIALIZE WS-BAC-CARD-REC

           EXEC SQL
               SELECT NEXT VALUE FOR BAC_CARD_SEQ
               INTO :WS-HV-CARD-SEQ
               FROM SYSIBM.SYSDUMMY1
           END-EXEC

           IF SQLCODE NOT = 0
               DISPLAY 'CARD SEQ ERROR SQLCODE=' SQLCODE
               PERFORM 9900-DB2-ERROR
           END-IF

           MOVE WS-HV-CARD-SEQ TO WS-HV-CARD-SEQ-ZERO
           STRING 'CARD' WS-HV-CARD-SEQ-ZERO
               DELIMITED BY SIZE
               INTO WS-CARD-ID
           END-STRING

      *    GENERATE 16 DIGIT PAN
           STRING '400000' WS-BRANCH-PART WS-PROD-CODE WS-HV-CARD-SEQ-ZERO
               DELIMITED BY SIZE
               INTO WS-CARD-BASE
           END-STRING

           MOVE ZEROS TO WS-CARD-CHECK-SUM
           PERFORM VARYING WS-CARD-K FROM 1 BY 1
                   UNTIL WS-CARD-K > 15
               MOVE FUNCTION NUMVAL(WS-CARD-BASE(WS-CARD-K:1))
                   TO WS-CARD-DGT
               IF FUNCTION MOD(WS-CARD-K, 2) = 1
                   MULTIPLY WS-CARD-DGT BY 2 GIVING WS-CARD-DGT
               END-IF
               IF WS-CARD-DGT > 9
                   SUBTRACT 9 FROM WS-CARD-DGT
               END-IF
               ADD WS-CARD-DGT TO WS-CARD-CHECK-SUM
           END-PERFORM

           COMPUTE WS-CARD-CHECK-DIGIT =
               10 - FUNCTION MOD(WS-CARD-CHECK-SUM, 10)
           IF WS-CARD-CHECK-DIGIT = 10
               MOVE 0 TO WS-CARD-CHECK-DIGIT
           END-IF

           STRING WS-CARD-BASE WS-CARD-CHECK-DIGIT
               DELIMITED BY SIZE
               INTO WS-CARD-NUMBER
           END-STRING

      *    EXPIRY DATE = TODAY + 3 YEARS
           EXEC SQL
               SELECT CURRENT DATE + 3 YEARS
               INTO :WS-CARD-EXPIRY-DATE
               FROM SYSIBM.SYSDUMMY1
           END-EXEC

           MOVE WS-APP-ID               TO WS-CARD-APP-ID
           MOVE WS-ACCOUNT-NUM          TO WS-CARD-ACCOUNT-NUM
           MOVE WS-CUST-ID              TO WS-CARD-CUST-ID
           MOVE WS-APP-CARD-TYPE        TO WS-CARD-TYPE
           MOVE 'IS'                    TO WS-CARD-STATUS
           MOVE 'EM'                    TO WS-CARD-PLASTIC-STATUS
           MOVE WS-APP-CARD-EMBOSS-NAME TO WS-CARD-EMBOSS-NAME
           MOVE WS-FORMATTED-DATE       TO WS-CARD-ISSUE-DATE
           MOVE WS-APP-CARD-DAILY-LIMIT TO WS-CARD-DAILY-LIMIT
           MOVE WS-APP-CARD-ATM-LIMIT   TO WS-CARD-ATM-LIMIT
           MOVE WS-APP-CARD-MONTHLY-LIMIT TO WS-CARD-MONTHLY-LIMIT
           MOVE WS-APP-CARD-DAILY-LIMIT TO WS-CARD-AVAILABLE-LIMIT
           MOVE '123'                   TO WS-CARD-CVV
           MOVE 'M'                     TO WS-CARD-PIN-STATUS
           MOVE 'I'                     TO WS-CARD-ACTIVATION-STATUS
           MOVE 'PD'                    TO WS-CARD-DISPATCH-STATUS
           MOVE 'VISA'                  TO WS-CARD-NETWORK
           MOVE 'RUBY'                  TO WS-CARD-PRODUCT
           MOVE 'BATCH01'               TO WS-CARD-MAKER-ID
           MOVE 'BATCH01'               TO WS-CARD-CHECKER-ID
           MOVE WS-FORMATTED-TIMESTAMP  TO WS-CARD-CREATED-TIMESTAMP
           MOVE WS-FORMATTED-TIMESTAMP  TO WS-CARD-UPDATED-TIMESTAMP

           EXEC SQL
               INSERT INTO TB_BAC_CARD
               (CARD_ID, APP_ID, ACCOUNT_NUMBER, CUST_ID, CARD_NUMBER,
                CARD_TYPE, CARD_STATUS, PLASTIC_STATUS, EMBOSS_NAME,
                ISSUE_DATE, EXPIRY_DATE, DAILY_LIMIT, ATM_LIMIT,
                MONTHLY_LIMIT, AVAILABLE_LIMIT, CVV, PIN_STATUS,
                ACTIVATION_STATUS, DISPATCH_STATUS, CARD_NETWORK,
                CARD_PRODUCT, MAKER_ID, CHECKER_ID,
                CREATED_TIMESTAMP, UPDATED_TIMESTAMP)
               VALUES
               (:WS-CARD-ID, :WS-CARD-APP-ID, :WS-CARD-ACCOUNT-NUM,
                :WS-CARD-CUST-ID, :WS-CARD-NUMBER, :WS-CARD-TYPE,
                :WS-CARD-STATUS, :WS-CARD-PLASTIC-STATUS,
                :WS-CARD-EMBOSS-NAME, :WS-CARD-ISSUE-DATE,
                :WS-CARD-EXPIRY-DATE, :WS-CARD-DAILY-LIMIT,
                :WS-CARD-ATM-LIMIT, :WS-CARD-MONTHLY-LIMIT,
                :WS-CARD-AVAILABLE-LIMIT, :WS-CARD-CVV,
                :WS-CARD-PIN-STATUS, :WS-CARD-ACTIVATION-STATUS,
                :WS-CARD-DISPATCH-STATUS, :WS-CARD-NETWORK,
                :WS-CARD-PRODUCT, :WS-CARD-MAKER-ID,
                :WS-CARD-CHECKER-ID, :WS-CARD-CREATED-TIMESTAMP,
                :WS-CARD-UPDATED-TIMESTAMP)
           END-EXEC

           IF SQLCODE NOT = 0
               DISPLAY 'INSERT CARD ERROR SQLCODE=' SQLCODE
               PERFORM 9900-DB2-ERROR
           END-IF
           .

      ******************************************************************
      * 8000-CLOSE-FILES                                               *
      ******************************************************************
       8000-CLOSE-FILES.
           CLOSE ACCT-OPEN-RPT
           .

      ******************************************************************
      * 9000-DB2-COMMIT                                                *
      ******************************************************************
       9000-DB2-COMMIT.
           EXEC SQL COMMIT END-EXEC
           .

      ******************************************************************
      * 9900-DB2-ERROR                                                 *
      ******************************************************************
       9900-DB2-ERROR.
           DISPLAY 'DB2 ERROR SQLCODE=' SQLCODE ' SQLERRMC='
                   SQLERRMC(1:50)
           PERFORM 9000-DB2-COMMIT
           MOVE '9999' TO WS-ABEND-CODE
           PERFORM 9900-ABEND
           .

      ******************************************************************
      * 9900-ABEND                                                     *
      ******************************************************************
       9900-ABEND.
           DISPLAY 'ABEND ' WS-ABEND-CODE
           MOVE 12 TO RETURN-CODE
           STOP RUN
           .
