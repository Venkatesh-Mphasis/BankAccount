       IDENTIFICATION DIVISION.
       PROGRAM-ID.    BACONL01.
      ******************************************************************
      * LOCAL GNUCOBOL VERSION OF CICS BA01 - ACCOUNT CREATION         *
      * PROCESSES REQUESTS FROM DATA/BACREQ AND WRITES RESPONSES        *
      * RUN FROM: LOCAL/                                               *
      ******************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT BACREQ-FILE
               ASSIGN TO "DATA/BACREQ.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-REQ-STATUS.

           SELECT BACRESP-FILE
               ASSIGN TO "OUTPUT/BACRESP.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-RESP-STATUS.

           SELECT BACAPP-FILE
               ASSIGN TO "DATA/BACAPP"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-BACAPP-STATUS.

           SELECT BACSIG-FILE
               ASSIGN TO "DATA/BACSIG"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-BACSIG-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  BACREQ-FILE.
       01  BACREQ-REC                     PIC X(80).

       FD  BACRESP-FILE.
       01  BACRESP-REC                    PIC X(120).

       FD  BACAPP-FILE
           RECORD CONTAINS 712 CHARACTERS.
       01  BACAPP-REC                     PIC X(712).

       FD  BACSIG-FILE
           RECORD CONTAINS 452 CHARACTERS.
       01  BACSIG-REC                     PIC X(452).

       WORKING-STORAGE SECTION.
           COPY CPYBAC01.
           COPY CPYBAC03.
           COPY CPYCOM01.

       01  WS-REQ-STATUS                 PIC X(02).
       01  WS-RESP-STATUS                PIC X(02).
       01  WS-BACAPP-STATUS              PIC X(02).
       01  WS-BACSIG-STATUS              PIC X(02).

       01  WS-REQUEST.
           05  REQ-ACTION                 PIC X(02).
           05  REQ-KEY                    PIC X(10).
           05  FILLER                     PIC X(68).

       01  WS-APP-COUNT                  PIC 9(07) VALUE ZEROS.
       01  WS-SIG-COUNT                  PIC 9(07) VALUE ZEROS.
       01  WS-NEXT-APP-SEQ               PIC 9(07).
       01  WS-NEXT-SIG-SEQ               PIC 9(07).
       01  WS-APP-SEQ-STR                PIC 9(07).
       01  WS-SIG-SEQ-STR                PIC 9(07).

       01  WS-LD8                        PIC 9(08).
       01  WS-LT8                        PIC 9(08).
       01  WS-LFD                        PIC X(10).
       01  WS-LFT                        PIC X(08).
       01  WS-LFTS                       PIC X(26).

       01  WS-RESP-TEXT                  PIC X(120).
       01  WS-FOUND-FLAG                 PIC X(01) VALUE 'N'.
           88  WS-FOUND                   VALUE 'Y'.
           88  WS-NOT-FOUND               VALUE 'N'.

       01  WS-EDIT-AMOUNT                PIC ZZZ,ZZZ,ZZZ,ZZ9.99.

       PROCEDURE DIVISION.

       0000-MAIN.
           PERFORM 9000-GET-TIMESTAMP

           OPEN INPUT BACREQ-FILE
           OPEN OUTPUT BACRESP-FILE

           DISPLAY '=============================================='
           DISPLAY ' BUSINESS BANKING ACCOUNT CREATION PORTAL   '
           DISPLAY ' LOCAL GNUCOBOL SIMULATION                    '
           DISPLAY '=============================================='

           SET WS-NOT-EOF TO TRUE
           PERFORM 1000-PROCESS-REQUESTS
               UNTIL WS-EOF

           CLOSE BACREQ-FILE
           CLOSE BACRESP-FILE

           DISPLAY 'ONLINE PROCESSING COMPLETE'
           STOP RUN.

      ******************************************************************
      * 1000-PROCESS-REQUESTS: READ REQUESTS AND ROUTE                 *
      ******************************************************************
       1000-PROCESS-REQUESTS.
           READ BACREQ-FILE INTO WS-REQUEST
               AT END
                   SET WS-EOF TO TRUE
               NOT AT END
                   EVALUATE REQ-ACTION
                       WHEN '01'
                           PERFORM 3000-NEW-APPLICATION
                       WHEN '02'
                           PERFORM 3100-INQUIRY
                       WHEN '03'
                           SET WS-EOF TO TRUE
                       WHEN OTHER
                           MOVE 'INVALID REQUEST ACTION' TO WS-RESP-TEXT
                           PERFORM 9900-WRITE-RESPONSE
                   END-EVALUATE
           END-READ
           .

      ******************************************************************
      * 3000-NEW-APPLICATION: SIMULATE A PORTAL SUBMISSION             *
      ******************************************************************
       3000-NEW-APPLICATION.
           PERFORM 3010-COUNT-APPS
           PERFORM 3020-COUNT-SIGS

           ADD 1 TO WS-APP-COUNT
           MOVE WS-APP-COUNT TO WS-NEXT-APP-SEQ
           MOVE WS-NEXT-APP-SEQ TO WS-APP-SEQ-STR

           INITIALIZE WS-BAC-APPLICATION-REC

           STRING 'APP' WS-APP-SEQ-STR
               DELIMITED BY SIZE
               INTO WS-APP-ID
           END-STRING
           MOVE 'SB'                       TO WS-APP-STATUS
           MOVE 'Riverfront Tech Inc'      TO WS-APP-BUSINESS-NAME
           MOVE 'Riverfront'               TO WS-APP-TRADE-NAME
           MOVE 'REG-2026-004'             TO WS-APP-REGISTRATION-NO
           MOVE '66-9988776'               TO WS-APP-TAX-ID
           MOVE '2019-07-22'               TO WS-APP-INCORP-DATE
           MOVE 'CP'                       TO WS-APP-BUSINESS-TYPE
           MOVE '541511'                   TO WS-APP-INDUSTRY-CODE
           MOVE 4500000.00                 TO WS-APP-ANNUAL-REVENUE
           MOVE 85                         TO WS-APP-EMPLOYEE-COUNT
           MOVE '88 Innovation Way'        TO WS-APP-ADDR-LINE1
           MOVE 'Floor 3'                  TO WS-APP-ADDR-LINE2
           MOVE 'Austin'                   TO WS-APP-ADDR-CITY
           MOVE 'TX'                       TO WS-APP-ADDR-STATE
           MOVE 'USA'                      TO WS-APP-ADDR-COUNTRY
           MOVE '78701'                    TO WS-APP-ADDR-ZIP
           MOVE '5125550400'               TO WS-APP-PHONE
           MOVE 'ap@riverfrontech.com'     TO WS-APP-EMAIL
           MOVE 'Sam Wilson'              TO WS-APP-CONTACT-NAME
           MOVE 'CH'                       TO WS-APP-ACCOUNT-TYPE
           MOVE 'USD'                      TO WS-APP-CURRENCY
           MOVE 75000.00                   TO WS-APP-INITIAL-DEPOSIT
           MOVE 4000                       TO WS-APP-EXPECTED-TXN-VOL
           MOVE 350000.00                  TO WS-APP-EXPECTED-TXN-AMT
           MOVE 'Venture Capital'          TO WS-APP-SOURCE-OF-FUNDS
           MOVE 'MD'                       TO WS-APP-RISK-RATING
           MOVE 'N'                        TO WS-APP-PEP-FLAG
           MOVE 'N'                        TO WS-APP-SANCTIONS-FLAG
           MOVE 'Y'                        TO WS-APP-DOCS-RECEIVED
           MOVE 'Y'                        TO WS-APP-BOARD-RESOLUTION
           MOVE 'Y'                        TO WS-APP-UBO-DECLARATION
           MOVE 'OPR001'                   TO WS-APP-MAKER-ID
           MOVE SPACES                     TO WS-APP-CHECKER-ID
           MOVE WS-LFTS                    TO WS-APP-CREATED-TIMESTAMP
           MOVE WS-LFTS                    TO WS-APP-UPDATED-TIMESTAMP
           MOVE SPACES                     TO WS-APP-ACCOUNT-NUMBER
           MOVE 'BR0001'                   TO WS-APP-BRANCH-CODE
           MOVE SPACES                     TO WS-APP-REJECTION-REASON
           MOVE 'Y'                        TO WS-APP-CARD-REQUESTED
           MOVE 'DC'                       TO WS-APP-CARD-TYPE
           MOVE 2500.00                    TO WS-APP-CARD-DAILY-LIMIT
           MOVE 1000.00                    TO WS-APP-CARD-ATM-LIMIT
           MOVE 25000.00                   TO WS-APP-CARD-MONTHLY-LIMIT
           MOVE 'Sam Wilson / Riverfront'  TO WS-APP-CARD-EMBOSS-NAME

           OPEN EXTEND BACAPP-FILE
           IF WS-BACAPP-STATUS NOT = '00'
               DISPLAY 'BACAPP EXTEND ERROR ' WS-BACAPP-STATUS
               STOP RUN
           END-IF
           WRITE BACAPP-REC FROM WS-BAC-APPLICATION-REC
           CLOSE BACAPP-FILE

           ADD 1 TO WS-SIG-COUNT
           MOVE WS-SIG-COUNT TO WS-NEXT-SIG-SEQ
           MOVE WS-NEXT-SIG-SEQ TO WS-SIG-SEQ-STR

           INITIALIZE WS-BAC-SIGNATORY-REC

           STRING 'SIG' WS-SIG-SEQ-STR
               DELIMITED BY SIZE
               INTO WS-SIG-ID
           END-STRING
           MOVE WS-APP-ID                  TO WS-SIG-APP-ID
           MOVE SPACES                     TO WS-SIG-CUST-ID
           MOVE 'Sam Wilson'               TO WS-SIG-NAME
           MOVE 'Treasurer'                TO WS-SIG-TITLE
           MOVE '1985-03-12'               TO WS-SIG-DOB
           MOVE '55667788990'              TO WS-SIG-SSN
           MOVE '88 Innovation Way'        TO WS-SIG-ADDR-LINE1
           MOVE 'Floor 3'                  TO WS-SIG-ADDR-LINE2
           MOVE 'Austin'                   TO WS-SIG-ADDR-CITY
           MOVE 'TX'                       TO WS-SIG-ADDR-STATE
           MOVE 'USA'                      TO WS-SIG-ADDR-COUNTRY
           MOVE '78701'                    TO WS-SIG-ADDR-ZIP
           MOVE '5125550400'               TO WS-SIG-PHONE
           MOVE 'sam.wilson@riverfrontech.com' TO WS-SIG-EMAIL
           MOVE 30.00                      TO WS-SIG-OWNERSHIP-PCT
           MOVE 'A'                        TO WS-SIG-TYPE
           MOVE 'DRIVERSLIC'               TO WS-SIG-ID-TYPE
           MOVE 'DL1122334'                TO WS-SIG-ID-NUMBER
           MOVE WS-LFTS                    TO WS-SIG-CREATED-TIMESTAMP
           MOVE WS-LFTS                    TO WS-SIG-UPDATED-TIMESTAMP

           OPEN EXTEND BACSIG-FILE
           WRITE BACSIG-REC FROM WS-BAC-SIGNATORY-REC
           CLOSE BACSIG-FILE

           MOVE SPACES TO WS-RESP-TEXT
           MOVE WS-APP-CARD-DAILY-LIMIT TO WS-EDIT-AMOUNT
           STRING 'APP CREATED: ' WS-APP-ID
               ' STATUS: ' WS-APP-STATUS
               ' CARD: ' WS-APP-CARD-TYPE
               ' DAILY LIMIT: ' WS-EDIT-AMOUNT
               ' BUSINESS: ' WS-APP-BUSINESS-NAME
               DELIMITED BY SIZE
               INTO WS-RESP-TEXT
           END-STRING
           PERFORM 9900-WRITE-RESPONSE
           ADD 1 TO WS-RECORDS-WRITTEN
           .

      ******************************************************************
      * 3010-COUNT-APPS: COUNT EXISTING APPLICATION RECORDS            *
      ******************************************************************
       3010-COUNT-APPS.
           MOVE ZEROS TO WS-APP-COUNT
           SET WS-NOT-FOUND TO TRUE
           OPEN INPUT BACAPP-FILE
           IF WS-BACAPP-STATUS NOT = '00'
               EXIT PARAGRAPH
           END-IF

           SET WS-NOT-EOF TO TRUE
           PERFORM UNTIL WS-EOF
               READ BACAPP-FILE INTO WS-BAC-APPLICATION-REC
                   AT END
                       SET WS-EOF TO TRUE
                   NOT AT END
                       ADD 1 TO WS-APP-COUNT
               END-READ
           END-PERFORM
           CLOSE BACAPP-FILE
           SET WS-NOT-EOF TO TRUE
           .

      ******************************************************************
      * 3020-COUNT-SIGS: COUNT EXISTING SIGNATORY RECORDS             *
      ******************************************************************
       3020-COUNT-SIGS.
           MOVE ZEROS TO WS-SIG-COUNT
           SET WS-NOT-EOF TO TRUE
           OPEN INPUT BACSIG-FILE
           IF WS-BACSIG-STATUS NOT = '00'
               EXIT PARAGRAPH
           END-IF

           PERFORM UNTIL WS-EOF
               READ BACSIG-FILE INTO WS-BAC-SIGNATORY-REC
                   AT END
                       SET WS-EOF TO TRUE
                   NOT AT END
                       ADD 1 TO WS-SIG-COUNT
               END-READ
           END-PERFORM
           CLOSE BACSIG-FILE
           SET WS-NOT-EOF TO TRUE
           .

      ******************************************************************
      * 3100-INQUIRY: LOOKUP APPLICATION BY KEY                        *
      ******************************************************************
       3100-INQUIRY.
           SET WS-NOT-FOUND TO TRUE
           SET WS-NOT-EOF TO TRUE
           OPEN INPUT BACAPP-FILE

           PERFORM UNTIL WS-EOF
               READ BACAPP-FILE INTO WS-BAC-APPLICATION-REC
                   AT END
                       SET WS-EOF TO TRUE
                   NOT AT END
                       IF WS-APP-ID = REQ-KEY
                           SET WS-FOUND TO TRUE
                           MOVE SPACES TO WS-RESP-TEXT
                           MOVE WS-APP-INITIAL-DEPOSIT TO WS-EDIT-AMOUNT
                           STRING 'INQUIRY APP: ' WS-APP-ID
                                  ' STATUS: ' WS-APP-STATUS
                                  ' ACCT TYPE: ' WS-APP-ACCOUNT-TYPE
                                  ' DEPOSIT: ' WS-EDIT-AMOUNT
                               DELIMITED BY SIZE
                               INTO WS-RESP-TEXT
                           END-STRING
                           PERFORM 9900-WRITE-RESPONSE
                           ADD 1 TO WS-RECORDS-READ
                       END-IF
               END-READ
           END-PERFORM

           CLOSE BACAPP-FILE
           SET WS-NOT-EOF TO TRUE

           IF WS-NOT-FOUND
               STRING 'APPLICATION NOT FOUND: ' REQ-KEY
                   DELIMITED BY SIZE
                   INTO WS-RESP-TEXT
               END-STRING
               PERFORM 9900-WRITE-RESPONSE
           END-IF
           .

      ******************************************************************
      * 9900-WRITE-RESPONSE: WRITE RESPONSE RECORD                     *
      ******************************************************************
       9900-WRITE-RESPONSE.
           MOVE WS-RESP-TEXT TO BACRESP-REC
           WRITE BACRESP-REC
           DISPLAY WS-RESP-TEXT
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
