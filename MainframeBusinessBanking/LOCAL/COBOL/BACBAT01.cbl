       IDENTIFICATION DIVISION.
       PROGRAM-ID.    BACBAT01.
      ******************************************************************
      * LOCAL GNUCOBOL BATCH - ACCOUNT OPENING + DEBIT CARD ISSUE    *
      * PROCESSES SUBMITTED/APPROVED APPLICATIONS FROM DATA/BACAPP     *
      * CREATES CUSTOMER, ACCOUNT AND CARD MASTERS                     *
      * RUN FROM: LOCAL/                                               *
      ******************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT BACAPP-FILE
               ASSIGN TO "DATA/BACAPP"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-BACAPP-STATUS.

           SELECT BACAPP-UPDATED-FILE
               ASSIGN TO "DATA/BACAPP-UPDATED"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-BACAPP-UPD-STATUS.

           SELECT BACCUST-FILE
               ASSIGN TO "DATA/BACCUST"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-BACCUST-STATUS.

           SELECT BACACC-FILE
               ASSIGN TO "DATA/BACACC"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-BACACC-STATUS.

           SELECT BACCARD-FILE
               ASSIGN TO "DATA/BACCARD"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-BACCARD-STATUS.

           SELECT BACRPT-FILE
               ASSIGN TO "OUTPUT/ACCOUNT_OPEN_RPT.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-BACRPT-STATUS.

           SELECT BACCARD-RPT-FILE
               ASSIGN TO "OUTPUT/CARD_ISSUE_RPT.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-BACCARD-RPT-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  BACAPP-FILE
           RECORD CONTAINS 712 CHARACTERS.
       01  BACAPP-REC                     PIC X(712).

       FD  BACAPP-UPDATED-FILE
           RECORD CONTAINS 712 CHARACTERS.
       01  BACAPP-UPDATED-REC             PIC X(712).

       FD  BACCUST-FILE
           RECORD CONTAINS 527 CHARACTERS.
       01  BACCUST-REC                    PIC X(527).

       FD  BACACC-FILE
           RECORD CONTAINS 194 CHARACTERS.
       01  BACACC-REC                     PIC X(194).

       FD  BACCARD-FILE
           RECORD CONTAINS 261 CHARACTERS.
       01  BACCARD-REC                    PIC X(261).

       FD  BACRPT-FILE.
       01  BACRPT-REC                     PIC X(120).

       FD  BACCARD-RPT-FILE.
       01  BACCARD-RPT-REC                PIC X(132).

       WORKING-STORAGE SECTION.
           COPY CPYBAC01.
           COPY CPYBAC02.
           COPY CPYBAC04.
           COPY CPYBAC07.
           COPY CPYCOM01.

       01  WS-BACAPP-STATUS              PIC X(02).
       01  WS-BACAPP-UPD-STATUS          PIC X(02).
       01  WS-BACCUST-STATUS             PIC X(02).
       01  WS-BACACC-STATUS              PIC X(02).
       01  WS-BACCARD-STATUS            PIC X(02).
       01  WS-BACRPT-STATUS              PIC X(02).
       01  WS-BACCARD-RPT-STATUS         PIC X(02).

       01  WS-CUST-SEQ                   PIC 9(06) VALUE ZEROS.
       01  WS-ACC-SEQ                    PIC 9(05) VALUE ZEROS.
       01  WS-CARD-SEQ                   PIC 9(03) VALUE ZEROS.
       01  WS-CUST-SEQ-STR               PIC 9(06).
       01  WS-ACC-SEQ-STR                PIC 9(05).
       01  WS-CARD-SEQ-STR               PIC 9(03).

       01  WS-LD8                        PIC 9(08).
       01  WS-LT8                        PIC 9(08).
       01  WS-LFD                        PIC X(10).
       01  WS-LFT                        PIC X(08).
       01  WS-LFTS                       PIC X(26).

       01  WS-ACCOUNT-PART              PIC X(11).
       01  WS-ACCOUNT-NUM               PIC X(12).
       01  WS-PROD-CODE                 PIC X(02).
       01  WS-BRANCH-PART               PIC X(04).
       01  WS-CHECK-DIGIT               PIC 9(01).
       01  WS-CHECK-SUM                 PIC 9(04).
       01  WS-DIGIT                     PIC 9(01).
       01  WS-I                         PIC 9(02).

       01  WS-CARD-BASE                 PIC X(15).
       01  WS-CARD-CHECK-DIGIT          PIC 9(01).
       01  WS-CARD-CHECK-SUM            PIC 9(04).
       01  WS-CARD-DGT                  PIC 9(01).
       01  WS-CARD-K                    PIC 9(02).
       01  WS-EXP-YEAR-NUM              PIC 9(04).

       01  WS-REPORT-LINE.
           05  FILLER                   PIC X(02) VALUE SPACES.
           05  RPT-APP-ID               PIC X(10).
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  RPT-CUST-ID              PIC X(10).
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  RPT-ACCOUNT-NUM          PIC X(12).
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  RPT-BUSINESS-NAME        PIC X(30).
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  RPT-ACCOUNT-TYPE         PIC X(02).
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  RPT-INITIAL-DEPOSIT      PIC ZZZ,ZZZ,ZZZ,ZZ9.99.
           05  FILLER                   PIC X(02) VALUE SPACES.
           05  RPT-STATUS               PIC X(02).

       01  WS-HEADER-LINE               PIC X(120) VALUE
           ' APP-ID     CUST-ID    ACCOUNT-NUM  BUSINESS-NAME'.

       01  WS-CARD-RPT-LINE.
           05  FILLER                   PIC X(02) VALUE SPACES.
           05  CRPT-APP-ID              PIC X(10).
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  CRPT-ACCOUNT-NUM         PIC X(12).
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  CRPT-CARD-ID             PIC X(10).
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  CRPT-CARD-NUMBER         PIC X(16).
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  CRPT-STATUS              PIC X(02).
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  CRPT-PLASTIC             PIC X(02).
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  CRPT-PRODUCT             PIC X(10).
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  CRPT-DAILY-LIMIT         PIC ZZZ,ZZZ,ZZ9.99.
           05  FILLER                   PIC X(03) VALUE SPACES.
           05  CRPT-EMBOSS-NAME         PIC X(30).

       01  WS-CARD-HEADER-LINE        PIC X(132) VALUE SPACES.

       PROCEDURE DIVISION.

       0000-MAIN.
           PERFORM 9000-GET-TIMESTAMP

           OPEN INPUT BACAPP-FILE
           OPEN OUTPUT BACAPP-UPDATED-FILE
           OPEN OUTPUT BACCUST-FILE
           OPEN OUTPUT BACACC-FILE
           OPEN OUTPUT BACCARD-FILE
           OPEN OUTPUT BACRPT-FILE
           OPEN OUTPUT BACCARD-RPT-FILE

           WRITE BACRPT-REC FROM WS-HEADER-LINE
           STRING ' APP-ID     ACCT-NUM     CARD-ID    '
                  'CARD-NUMBER       ST PL PRODUCT    DAILY-LIMIT  '
                  'EMBOSS-NAME'
               DELIMITED BY SIZE
               INTO WS-CARD-HEADER-LINE
           END-STRING
           WRITE BACCARD-RPT-REC FROM WS-CARD-HEADER-LINE

           SET WS-NOT-EOF TO TRUE
           PERFORM 2000-READ-NEXT-APP
               UNTIL WS-EOF

           CLOSE BACAPP-FILE
           CLOSE BACAPP-UPDATED-FILE
           CLOSE BACCUST-FILE
           CLOSE BACACC-FILE
           CLOSE BACCARD-FILE
           CLOSE BACRPT-FILE
           CLOSE BACCARD-RPT-FILE

           DISPLAY 'BATCH ACCOUNT OPENING COMPLETE'
           DISPLAY 'APPLICATIONS READ:    ' WS-RECORDS-READ
           DISPLAY 'ACCOUNTS OPENED:      ' WS-RECORDS-WRITTEN
           DISPLAY 'CARDS ISSUED:         ' WS-CARD-SEQ
           STOP RUN.

      ******************************************************************
      * 2000-READ-NEXT-APP: READ APPLICATIONS AND PROCESS              *
      ******************************************************************
       2000-READ-NEXT-APP.
           READ BACAPP-FILE INTO WS-BAC-APPLICATION-REC
               AT END
                   SET WS-EOF TO TRUE
               NOT AT END
                   ADD 1 TO WS-RECORDS-READ
                   IF WS-APP-STATUS = 'SB' OR WS-APP-STATUS = 'AP'
                       PERFORM 3000-OPEN-ACCOUNT
                   END-IF
                   WRITE BACAPP-UPDATED-REC FROM WS-BAC-APPLICATION-REC
           END-READ
           .

      ******************************************************************
      * 3000-OPEN-ACCOUNT: CREATE CUSTOMER, ACCOUNT, CARD AND UPDATE *
      ******************************************************************
       3000-OPEN-ACCOUNT.
           ADD 1 TO WS-ACC-SEQ
           MOVE WS-ACC-SEQ TO WS-ACC-SEQ-STR
           PERFORM 3100-GENERATE-ACCOUNT-NUMBER

      *    BUILD CUSTOMER MASTER
           INITIALIZE WS-BAC-CUSTOMER-REC

           ADD 1 TO WS-CUST-SEQ
           MOVE WS-CUST-SEQ TO WS-CUST-SEQ-STR
           STRING 'CUST' WS-CUST-SEQ-STR
               DELIMITED BY SIZE
               INTO WS-CUST-ID
           END-STRING

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
           MOVE WS-LFTS                 TO WS-CUST-CREATED-TIMESTAMP
           MOVE WS-LFTS                 TO WS-CUST-UPDATED-TIMESTAMP

           WRITE BACCUST-REC FROM WS-BAC-CUSTOMER-REC
           IF WS-BACCUST-STATUS NOT = '00'
               DISPLAY 'BACCUST WRITE ERROR ' WS-BACCUST-STATUS
               STOP RUN
           END-IF

      *    BUILD ACCOUNT MASTER
           INITIALIZE WS-BAC-ACCOUNT-REC
           MOVE WS-ACCOUNT-NUM          TO WS-ACC-ACCOUNT-NUMBER
           MOVE WS-APP-ID               TO WS-ACC-APP-ID
           MOVE WS-CUST-ID              TO WS-ACC-CUST-ID
           MOVE WS-APP-ACCOUNT-TYPE     TO WS-ACC-ACCOUNT-TYPE
           MOVE WS-APP-CURRENCY         TO WS-ACC-CURRENCY
           MOVE 'AC'                    TO WS-ACC-STATUS
           MOVE WS-LFD                  TO WS-ACC-OPEN-DATE
           MOVE WS-APP-INITIAL-DEPOSIT  TO WS-ACC-BALANCE
           MOVE WS-APP-INITIAL-DEPOSIT  TO WS-ACC-AVAILABLE-BALANCE
           MOVE WS-APP-INITIAL-DEPOSIT  TO WS-ACC-INITIAL-DEPOSIT
           MOVE WS-APP-BRANCH-CODE      TO WS-ACC-BRANCH-CODE
           MOVE WS-APP-MAKER-ID         TO WS-ACC-MAKER-ID
           MOVE 'BATCH01'               TO WS-ACC-CHECKER-ID
           MOVE WS-LFTS                 TO WS-ACC-CREATED-TIMESTAMP
           MOVE WS-LFTS                 TO WS-ACC-UPDATED-TIMESTAMP

           WRITE BACACC-REC FROM WS-BAC-ACCOUNT-REC
           IF WS-BACACC-STATUS NOT = '00'
               DISPLAY 'BACACC WRITE ERROR ' WS-BACACC-STATUS
               STOP RUN
           END-IF

      *    UPDATE APPLICATION
           MOVE 'OP'                    TO WS-APP-STATUS
           MOVE WS-ACCOUNT-NUM          TO WS-APP-ACCOUNT-NUMBER
           MOVE 'BATCH01'               TO WS-APP-CHECKER-ID
           MOVE WS-LFTS                 TO WS-APP-UPDATED-TIMESTAMP

      *    WRITE ACCOUNT REPORT
           MOVE WS-APP-ID               TO RPT-APP-ID
           MOVE WS-CUST-ID              TO RPT-CUST-ID
           MOVE WS-ACCOUNT-NUM          TO RPT-ACCOUNT-NUM
           MOVE WS-APP-BUSINESS-NAME    TO RPT-BUSINESS-NAME
           MOVE WS-APP-ACCOUNT-TYPE     TO RPT-ACCOUNT-TYPE
           MOVE WS-APP-INITIAL-DEPOSIT  TO RPT-INITIAL-DEPOSIT
           MOVE 'OP'                    TO RPT-STATUS
           WRITE BACRPT-REC FROM WS-REPORT-LINE

      *    ISSUE DEBIT CARD IF REQUESTED
           IF WS-APP-CARD-REQUESTED = 'Y'
               PERFORM 3200-ISSUE-DEBIT-CARD
           END-IF

           ADD 1 TO WS-RECORDS-WRITTEN
           .

      ******************************************************************
      * 3100-GENERATE-ACCOUNT-NUMBER: BRANCH+PRODUCT+SEQ+CHECK-DIGIT   *
      ******************************************************************
       3100-GENERATE-ACCOUNT-NUMBER.
           EVALUATE WS-APP-ACCOUNT-TYPE
               WHEN 'CH' MOVE '01' TO WS-PROD-CODE
               WHEN 'SV' MOVE '02' TO WS-PROD-CODE
               WHEN 'MM' MOVE '03' TO WS-PROD-CODE
               WHEN 'TD' MOVE '04' TO WS-PROD-CODE
               WHEN OTHER MOVE '00' TO WS-PROD-CODE
           END-EVALUATE

           IF WS-APP-BRANCH-CODE(3:1) NUMERIC
               MOVE WS-APP-BRANCH-CODE(3:4) TO WS-BRANCH-PART
           ELSE
               MOVE '0001' TO WS-BRANCH-PART
           END-IF

           STRING WS-BRANCH-PART WS-PROD-CODE WS-ACC-SEQ-STR
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
      * 3200-ISSUE-DEBIT-CARD: BUILD CARD MASTER AND PRODUCE PLASTIC   *
      ******************************************************************
       3200-ISSUE-DEBIT-CARD.
      *    PREPARE A CLEAN CARD RECORD
           INITIALIZE WS-BAC-CARD-REC

           ADD 1 TO WS-CARD-SEQ
           MOVE WS-CARD-SEQ TO WS-CARD-SEQ-STR

      *    GENERATE INTERNAL CARD ID
           STRING 'CARD' WS-CARD-SEQ-STR
               DELIMITED BY SIZE
               INTO WS-CARD-ID
           END-STRING

      *    GENERATE 16 DIGIT PAN WITH CHECK DIGIT
           STRING '400000' WS-BRANCH-PART WS-PROD-CODE WS-CARD-SEQ-STR
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
           COMPUTE WS-EXP-YEAR-NUM =
               FUNCTION NUMVAL(WS-LD8(1:4)) + 3
           STRING WS-EXP-YEAR-NUM '-' WS-LD8(5:2) '-' WS-LD8(7:2)
               DELIMITED BY SIZE
               INTO WS-CARD-EXPIRY-DATE
           END-STRING

      *    POPULATE REMAINING CARD MASTER FIELDS
           MOVE WS-APP-ID               TO WS-CARD-APP-ID
           MOVE WS-ACCOUNT-NUM          TO WS-CARD-ACCOUNT-NUM
           MOVE WS-CUST-ID              TO WS-CARD-CUST-ID
           MOVE WS-APP-CARD-TYPE        TO WS-CARD-TYPE
           MOVE 'IS'                    TO WS-CARD-STATUS
           MOVE 'EM'                    TO WS-CARD-PLASTIC-STATUS
           MOVE WS-APP-CARD-EMBOSS-NAME TO WS-CARD-EMBOSS-NAME
           MOVE WS-LFD                  TO WS-CARD-ISSUE-DATE
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
           MOVE WS-LFTS                 TO WS-CARD-CREATED-TIMESTAMP
           MOVE WS-LFTS                 TO WS-CARD-UPDATED-TIMESTAMP

           WRITE BACCARD-REC FROM WS-BAC-CARD-REC
           IF WS-BACCARD-STATUS NOT = '00'
               DISPLAY 'BACCARD WRITE ERROR ' WS-BACCARD-STATUS
               STOP RUN
           END-IF

      *    WRITE CARD ISSUE REPORT
           MOVE WS-APP-ID               TO CRPT-APP-ID
           MOVE WS-ACCOUNT-NUM          TO CRPT-ACCOUNT-NUM
           MOVE WS-CARD-ID              TO CRPT-CARD-ID
           MOVE WS-CARD-NUMBER          TO CRPT-CARD-NUMBER
           MOVE WS-CARD-STATUS          TO CRPT-STATUS
           MOVE WS-CARD-PLASTIC-STATUS  TO CRPT-PLASTIC
           MOVE WS-CARD-PRODUCT         TO CRPT-PRODUCT
           MOVE WS-CARD-DAILY-LIMIT     TO CRPT-DAILY-LIMIT
           MOVE WS-CARD-EMBOSS-NAME     TO CRPT-EMBOSS-NAME
           WRITE BACCARD-RPT-REC FROM WS-CARD-RPT-LINE
           .

      ******************************************************************
      * 9000-GET-TIMESTAMP: BUILD ISO TIMESTAMP FROM SYSTEM DATE/TIME  *
      ******************************************************************
       9000-GET-TIMESTAMP.
           ACCEPT WS-LD8 FROM DATE
           ACCEPT WS-LT8 FROM TIME
           STRING WS-LD8(1:4) '-' WS-LD8(5:2) '-' WS-LD8(7:2)
               DELIMITED BY SIZE
               INTO WS-LFD
           END-STRING
           STRING WS-LT8(1:2) ':' WS-LT8(3:2) ':' WS-LT8(5:2)
               DELIMITED BY SIZE
               INTO WS-LFT
           END-STRING
           STRING WS-LFD ' ' WS-LFT '.000000'
               DELIMITED BY SIZE
               INTO WS-LFTS
           END-STRING
           .
