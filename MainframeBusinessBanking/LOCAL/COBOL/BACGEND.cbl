       IDENTIFICATION DIVISION.
       PROGRAM-ID.    BACGEND.
      ******************************************************************
      * LOCAL GNUCOBOL DATA GENERATOR                                  *
      * CREATES SAMPLE MASTER FILES (SEQUENTIAL FORMAT)                *
      * RUN FROM: LOCAL/                                               *
      ******************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT BACAPP-FILE
               ASSIGN TO "DATA/BACAPP"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-BACAPP-STATUS.

           SELECT BACSIG-FILE
               ASSIGN TO "DATA/BACSIG"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-BACSIG-STATUS.

           SELECT BACCUST-FILE
               ASSIGN TO "DATA/BACCUST"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-BACCUST-STATUS.

           SELECT BACACC-FILE
               ASSIGN TO "DATA/BACACC"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-BACACC-STATUS.

           SELECT BACDOC-FILE
               ASSIGN TO "DATA/BACDOC"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-BACDOC-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  BACAPP-FILE
           RECORD CONTAINS 712 CHARACTERS.
       01  BACAPP-REC                     PIC X(712).

       FD  BACSIG-FILE
           RECORD CONTAINS 452 CHARACTERS.
       01  BACSIG-REC                     PIC X(452).

       FD  BACCUST-FILE
           RECORD CONTAINS 527 CHARACTERS.
       01  BACCUST-REC                    PIC X(527).

       FD  BACACC-FILE
           RECORD CONTAINS 194 CHARACTERS.
       01  BACACC-REC                     PIC X(194).

       FD  BACDOC-FILE
           RECORD CONTAINS 123 CHARACTERS.
       01  BACDOC-REC                     PIC X(123).

       WORKING-STORAGE SECTION.
           COPY CPYBAC01.
           COPY CPYBAC03.
           COPY CPYBAC05.
           COPY CPYCOM01.

       01  WS-BACAPP-STATUS              PIC X(02).
       01  WS-BACSIG-STATUS              PIC X(02).
       01  WS-BACCUST-STATUS             PIC X(02).
       01  WS-BACACC-STATUS              PIC X(02).
       01  WS-BACDOC-STATUS              PIC X(02).

       01  WS-LD8                        PIC 9(08).
       01  WS-LT8                        PIC 9(08).
       01  WS-LFD                        PIC X(10).
       01  WS-LFT                        PIC X(08).
       01  WS-LFTS                       PIC X(26).

       PROCEDURE DIVISION.

       0000-MAIN.
           PERFORM 9000-GET-TIMESTAMP
           DISPLAY 'BUSINESS BANKING - DATA GENERATOR'
           DISPLAY '---------------------------------'

           OPEN OUTPUT BACCUST-FILE
           CLOSE BACCUST-FILE
           OPEN OUTPUT BACACC-FILE
           CLOSE BACACC-FILE
           OPEN OUTPUT BACDOC-FILE
           CLOSE BACDOC-FILE

           OPEN OUTPUT BACSIG-FILE
           OPEN OUTPUT BACAPP-FILE

      *    APP 1 - SUBMITTED, READY FOR OPENING
           INITIALIZE WS-BAC-APPLICATION-REC
           MOVE 'APP0000001'             TO WS-APP-ID
           MOVE 'SB'                     TO WS-APP-STATUS
           MOVE 'Acme Manufacturing LLC' TO WS-APP-BUSINESS-NAME
           MOVE 'Acme'                   TO WS-APP-TRADE-NAME
           MOVE 'REG-2026-001'           TO WS-APP-REGISTRATION-NO
           MOVE '12-3456789'             TO WS-APP-TAX-ID
           MOVE '2015-03-10'             TO WS-APP-INCORP-DATE
           MOVE 'LC'                     TO WS-APP-BUSINESS-TYPE
           MOVE '321900'                 TO WS-APP-INDUSTRY-CODE
           MOVE 2500000.00               TO WS-APP-ANNUAL-REVENUE
           MOVE 120                      TO WS-APP-EMPLOYEE-COUNT
           MOVE '123 Industrial Parkway' TO WS-APP-ADDR-LINE1
           MOVE 'Suite 100'              TO WS-APP-ADDR-LINE2
           MOVE 'Detroit'                TO WS-APP-ADDR-CITY
           MOVE 'MI'                     TO WS-APP-ADDR-STATE
           MOVE 'USA'                    TO WS-APP-ADDR-COUNTRY
           MOVE '48201'                  TO WS-APP-ADDR-ZIP
           MOVE '3135550100'             TO WS-APP-PHONE
           MOVE 'finance@acme.com'       TO WS-APP-EMAIL
           MOVE 'John Doe'               TO WS-APP-CONTACT-NAME
           MOVE 'CH'                     TO WS-APP-ACCOUNT-TYPE
           MOVE 'USD'                    TO WS-APP-CURRENCY
           MOVE 50000.00                 TO WS-APP-INITIAL-DEPOSIT
           MOVE 5000                     TO WS-APP-EXPECTED-TXN-VOL
           MOVE 200000.00                TO WS-APP-EXPECTED-TXN-AMT
           MOVE 'Operating Revenue'      TO WS-APP-SOURCE-OF-FUNDS
           MOVE 'LO'                     TO WS-APP-RISK-RATING
           MOVE 'N'                      TO WS-APP-PEP-FLAG
           MOVE 'N'                      TO WS-APP-SANCTIONS-FLAG
           MOVE 'Y'                      TO WS-APP-DOCS-RECEIVED
           MOVE 'Y'                      TO WS-APP-BOARD-RESOLUTION
           MOVE 'Y'                      TO WS-APP-UBO-DECLARATION
           MOVE 'OPR001'                 TO WS-APP-MAKER-ID
           MOVE SPACES                   TO WS-APP-CHECKER-ID
           MOVE WS-LFTS                  TO WS-APP-CREATED-TIMESTAMP
           MOVE WS-LFTS                  TO WS-APP-UPDATED-TIMESTAMP
           MOVE SPACES                   TO WS-APP-ACCOUNT-NUMBER
           MOVE 'BR0001'                 TO WS-APP-BRANCH-CODE
           MOVE SPACES                   TO WS-APP-REJECTION-REASON
           PERFORM 9100-WRITE-APP

      *    APP 1 SIGNATORY
           INITIALIZE WS-BAC-SIGNATORY-REC
           MOVE 'SIG0000001'             TO WS-SIG-ID
           MOVE 'APP0000001'             TO WS-SIG-APP-ID
           MOVE SPACES                   TO WS-SIG-CUST-ID
           MOVE 'John Doe'               TO WS-SIG-NAME
           MOVE 'CFO'                    TO WS-SIG-TITLE
           MOVE '1975-06-15'             TO WS-SIG-DOB
           MOVE '12345678901'            TO WS-SIG-SSN
           MOVE '123 Industrial Parkway' TO WS-SIG-ADDR-LINE1
           MOVE 'Suite 100'              TO WS-SIG-ADDR-LINE2
           MOVE 'Detroit'                TO WS-SIG-ADDR-CITY
           MOVE 'MI'                     TO WS-SIG-ADDR-STATE
           MOVE 'USA'                    TO WS-SIG-ADDR-COUNTRY
           MOVE '48201'                  TO WS-SIG-ADDR-ZIP
           MOVE '3135550100'             TO WS-SIG-PHONE
           MOVE 'john.doe@acme.com'      TO WS-SIG-EMAIL
           MOVE 25.00                    TO WS-SIG-OWNERSHIP-PCT
           MOVE 'A'                      TO WS-SIG-TYPE
           MOVE 'PASSPORT'               TO WS-SIG-ID-TYPE
           MOVE 'P1234567'               TO WS-SIG-ID-NUMBER
           MOVE WS-LFTS                  TO WS-SIG-CREATED-TIMESTAMP
           MOVE WS-LFTS                  TO WS-SIG-UPDATED-TIMESTAMP
           PERFORM 9110-WRITE-SIG

      *    APP 2 - ALREADY APPROVED
           INITIALIZE WS-BAC-APPLICATION-REC
           MOVE 'APP0000002'               TO WS-APP-ID
           MOVE 'AP'                       TO WS-APP-STATUS
           MOVE 'Global Freight Partners LP' TO WS-APP-BUSINESS-NAME
           MOVE 'GFP'                      TO WS-APP-TRADE-NAME
           MOVE 'REG-2026-002'             TO WS-APP-REGISTRATION-NO
           MOVE '98-7654321'               TO WS-APP-TAX-ID
           MOVE '2008-11-20'               TO WS-APP-INCORP-DATE
           MOVE 'PT'                       TO WS-APP-BUSINESS-TYPE
           MOVE '484110'                   TO WS-APP-INDUSTRY-CODE
           MOVE 8000000.00                 TO WS-APP-ANNUAL-REVENUE
           MOVE 45                         TO WS-APP-EMPLOYEE-COUNT
           MOVE '450 Commerce Drive'       TO WS-APP-ADDR-LINE1
           MOVE 'Building B'               TO WS-APP-ADDR-LINE2
           MOVE 'Houston'                  TO WS-APP-ADDR-CITY
           MOVE 'TX'                       TO WS-APP-ADDR-STATE
           MOVE 'USA'                      TO WS-APP-ADDR-COUNTRY
           MOVE '77002'                    TO WS-APP-ADDR-ZIP
           MOVE '7135550200'               TO WS-APP-PHONE
           MOVE 'ap@globalfreight.com'     TO WS-APP-EMAIL
           MOVE 'Jane Smith'               TO WS-APP-CONTACT-NAME
           MOVE 'MM'                       TO WS-APP-ACCOUNT-TYPE
           MOVE 'USD'                      TO WS-APP-CURRENCY
           MOVE 100000.00                  TO WS-APP-INITIAL-DEPOSIT
           MOVE 2500                       TO WS-APP-EXPECTED-TXN-VOL
           MOVE 500000.00                  TO WS-APP-EXPECTED-TXN-AMT
           MOVE 'Operating Revenue'        TO WS-APP-SOURCE-OF-FUNDS
           MOVE 'MD'                       TO WS-APP-RISK-RATING
           MOVE 'N'                        TO WS-APP-PEP-FLAG
           MOVE 'N'                        TO WS-APP-SANCTIONS-FLAG
           MOVE 'Y'                        TO WS-APP-DOCS-RECEIVED
           MOVE 'Y'                        TO WS-APP-BOARD-RESOLUTION
           MOVE 'Y'                        TO WS-APP-UBO-DECLARATION
           MOVE 'OPR001'                   TO WS-APP-MAKER-ID
           MOVE 'CHK001'                   TO WS-APP-CHECKER-ID
           MOVE WS-LFTS                    TO WS-APP-CREATED-TIMESTAMP
           MOVE WS-LFTS                    TO WS-APP-UPDATED-TIMESTAMP
           MOVE SPACES                     TO WS-APP-ACCOUNT-NUMBER
           MOVE 'BR0002'                   TO WS-APP-BRANCH-CODE
           MOVE SPACES                     TO WS-APP-REJECTION-REASON
           PERFORM 9100-WRITE-APP

      *    APP 2 SIGNATORY
           INITIALIZE WS-BAC-SIGNATORY-REC
           MOVE 'SIG0000002'               TO WS-SIG-ID
           MOVE 'APP0000002'               TO WS-SIG-APP-ID
           MOVE SPACES                     TO WS-SIG-CUST-ID
           MOVE 'Jane Smith'               TO WS-SIG-NAME
           MOVE 'Managing Partner'         TO WS-SIG-TITLE
           MOVE '1980-09-22'               TO WS-SIG-DOB
           MOVE '98765432109'              TO WS-SIG-SSN
           MOVE '450 Commerce Drive'       TO WS-SIG-ADDR-LINE1
           MOVE 'Building B'               TO WS-SIG-ADDR-LINE2
           MOVE 'Houston'                  TO WS-SIG-ADDR-CITY
           MOVE 'TX'                       TO WS-SIG-ADDR-STATE
           MOVE 'USA'                      TO WS-SIG-ADDR-COUNTRY
           MOVE '77002'                    TO WS-SIG-ADDR-ZIP
           MOVE '7135550200'               TO WS-SIG-PHONE
           MOVE 'jane.smith@globalfreight.com' TO WS-SIG-EMAIL
           MOVE 50.00                      TO WS-SIG-OWNERSHIP-PCT
           MOVE 'A'                        TO WS-SIG-TYPE
           MOVE 'DRIVERSLIC'               TO WS-SIG-ID-TYPE
           MOVE 'DL9876543'                TO WS-SIG-ID-NUMBER
           MOVE WS-LFTS                    TO WS-SIG-CREATED-TIMESTAMP
           MOVE WS-LFTS                    TO WS-SIG-UPDATED-TIMESTAMP
           PERFORM 9110-WRITE-SIG

      *    APP 3 - DRAFT (NOT PROCESSED BY BATCH)
           INITIALIZE WS-BAC-APPLICATION-REC
           MOVE 'APP0000003'               TO WS-APP-ID
           MOVE 'DR'                       TO WS-APP-STATUS
           MOVE 'Sunrise Nonprofit Inc'    TO WS-APP-BUSINESS-NAME
           MOVE 'Sunrise'                  TO WS-APP-TRADE-NAME
           MOVE 'REG-2026-003'             TO WS-APP-REGISTRATION-NO
           MOVE '55-1234567'               TO WS-APP-TAX-ID
           MOVE '2012-01-15'               TO WS-APP-INCORP-DATE
           MOVE 'NP'                       TO WS-APP-BUSINESS-TYPE
           MOVE '813410'                   TO WS-APP-INDUSTRY-CODE
           MOVE 500000.00                  TO WS-APP-ANNUAL-REVENUE
           MOVE 12                         TO WS-APP-EMPLOYEE-COUNT
           MOVE '88 Hope Street'           TO WS-APP-ADDR-LINE1
           MOVE SPACES                     TO WS-APP-ADDR-LINE2
           MOVE 'Chicago'                  TO WS-APP-ADDR-CITY
           MOVE 'IL'                       TO WS-APP-ADDR-STATE
           MOVE 'USA'                      TO WS-APP-ADDR-COUNTRY
           MOVE '60601'                    TO WS-APP-ADDR-ZIP
           MOVE '3125550300'               TO WS-APP-PHONE
           MOVE 'treasury@sunrisenp.org'   TO WS-APP-EMAIL
           MOVE 'Alice Brown'              TO WS-APP-CONTACT-NAME
           MOVE 'SV'                       TO WS-APP-ACCOUNT-TYPE
           MOVE 'USD'                      TO WS-APP-CURRENCY
           MOVE 15000.00                   TO WS-APP-INITIAL-DEPOSIT
           MOVE 300                        TO WS-APP-EXPECTED-TXN-VOL
           MOVE 50000.00                   TO WS-APP-EXPECTED-TXN-AMT
           MOVE 'Donations and Grants'    TO WS-APP-SOURCE-OF-FUNDS
           MOVE 'LO'                       TO WS-APP-RISK-RATING
           MOVE 'N'                        TO WS-APP-PEP-FLAG
           MOVE 'N'                        TO WS-APP-SANCTIONS-FLAG
           MOVE 'N'                        TO WS-APP-DOCS-RECEIVED
           MOVE 'N'                        TO WS-APP-BOARD-RESOLUTION
           MOVE 'N'                        TO WS-APP-UBO-DECLARATION
           MOVE 'OPR001'                   TO WS-APP-MAKER-ID
           MOVE SPACES                     TO WS-APP-CHECKER-ID
           MOVE WS-LFTS                    TO WS-APP-CREATED-TIMESTAMP
           MOVE WS-LFTS                    TO WS-APP-UPDATED-TIMESTAMP
           MOVE SPACES                     TO WS-APP-ACCOUNT-NUMBER
           MOVE 'BR0003'                   TO WS-APP-BRANCH-CODE
           MOVE SPACES                     TO WS-APP-REJECTION-REASON
           PERFORM 9100-WRITE-APP

           CLOSE BACSIG-FILE
           CLOSE BACAPP-FILE

           DISPLAY 'GENERATED 3 APPLICATIONS AND 2 SIGNATORIES'
           STOP RUN.

       9100-WRITE-APP.
           WRITE BACAPP-REC FROM WS-BAC-APPLICATION-REC
           IF WS-BACAPP-STATUS NOT = '00'
               DISPLAY 'BACAPP WRITE ERROR ' WS-BACAPP-STATUS
               STOP RUN
           END-IF
           ADD 1 TO WS-RECORDS-WRITTEN
           .

       9110-WRITE-SIG.
           WRITE BACSIG-REC FROM WS-BAC-SIGNATORY-REC
           IF WS-BACSIG-STATUS NOT = '00'
               DISPLAY 'BACSIG WRITE ERROR ' WS-BACSIG-STATUS
               STOP RUN
           END-IF
           .

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
