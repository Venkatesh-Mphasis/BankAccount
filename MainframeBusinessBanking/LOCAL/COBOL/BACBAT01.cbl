       IDENTIFICATION DIVISION.
       PROGRAM-ID.    BACBAT01.
      ******************************************************************
      * LOCAL GNUCOBOL BATCH - ACCOUNT OPENING                         *
      * PROCESSES SUBMITTED/APPROVED APPLICATIONS FROM DATA/BACAPP       *
      * CREATES CUSTOMER/ACCOUNT MASTERS AND ACCOUNT_OPEN_RPT.txt        *
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

           SELECT BACRPT-FILE
               ASSIGN TO "OUTPUT/ACCOUNT_OPEN_RPT.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-BACRPT-STATUS.

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

       FD  BACRPT-FILE.
       01  BACRPT-REC                     PIC X(120).

       WORKING-STORAGE SECTION.
           COPY CPYBAC01.
           COPY CPYBAC02.
           COPY CPYBAC04.
           COPY CPYCOM01.

       01  WS-BACAPP-STATUS              PIC X(02).
       01  WS-BACAPP-UPD-STATUS          PIC X(02).
       01  WS-BACCUST-STATUS             PIC X(02).
       01  WS-BACACC-STATUS              PIC X(02).
       01  WS-BACRPT-STATUS              PIC X(02).

       01  WS-CUST-SEQ                   PIC 9(06) VALUE ZEROS.
       01  WS-ACC-SEQ                    PIC 9(05) VALUE ZEROS.
       01  WS-CUST-SEQ-STR               PIC 9(06).
       01  WS-ACC-SEQ-STR                PIC 9(05).

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

       PROCEDURE DIVISION.

       0000-MAIN.
           PERFORM 9000-GET-TIMESTAMP

           OPEN INPUT BACAPP-FILE
           OPEN OUTPUT BACAPP-UPDATED-FILE
           OPEN OUTPUT BACCUST-FILE
           OPEN OUTPUT BACACC-FILE
           OPEN OUTPUT BACRPT-FILE

           WRITE BACRPT-REC FROM WS-HEADER-LINE

           SET WS-NOT-EOF TO TRUE
           PERFORM 2000-READ-NEXT-APP
               UNTIL WS-EOF

           CLOSE BACAPP-FILE
           CLOSE BACAPP-UPDATED-FILE
           CLOSE BACCUST-FILE
           CLOSE BACACC-FILE
           CLOSE BACRPT-FILE

           DISPLAY 'BATCH ACCOUNT OPENING COMPLETE'
           DISPLAY 'APPLICATIONS READ:    ' WS-RECORDS-READ
           DISPLAY 'ACCOUNTS OPENED:      ' WS-RECORDS-WRITTEN
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
      * 3000-OPEN-ACCOUNT: CREATE CUSTOMER, ACCOUNT AND UPDATE APP     *
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

      *    WRITE REPORT
           MOVE WS-APP-ID               TO RPT-APP-ID
           MOVE WS-CUST-ID              TO RPT-CUST-ID
           MOVE WS-ACCOUNT-NUM          TO RPT-ACCOUNT-NUM
           MOVE WS-APP-BUSINESS-NAME    TO RPT-BUSINESS-NAME
           MOVE WS-APP-ACCOUNT-TYPE     TO RPT-ACCOUNT-TYPE
           MOVE WS-APP-INITIAL-DEPOSIT  TO RPT-INITIAL-DEPOSIT
           MOVE 'OP'                    TO RPT-STATUS
           WRITE BACRPT-REC FROM WS-REPORT-LINE

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
