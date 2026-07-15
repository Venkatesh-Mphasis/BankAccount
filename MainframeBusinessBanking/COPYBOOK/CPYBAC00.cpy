      ******************************************************************
      * COPYBOOK: CPYBAC00                                            *
      * DESCRIPTION: CICS COMMAREA for Business Banking Application   *
      * USED BY: BACONL01, BACONL02, BACAPPR                          *
      * NOTE: NOT used by batch programs (see CPYBAC01-06)            *
      ******************************************************************
       01  WS-BAC-COMMAREA.
           05  CA-SCREEN                  PIC 9(02) VALUE ZEROS.
           05  CA-ACTION                  PIC X(02) VALUE SPACES.
               88  CA-FIRST-TIME          VALUE '  '.
               88  CA-NEW-APP             VALUE 'NE'.
               88  CA-SUBMIT-APP          VALUE 'SU'.
               88  CA-INQUIRY             VALUE 'IQ'.
               88  CA-APPROVE             VALUE 'AP'.
           05  CA-USER-ID                 PIC X(08) VALUE 'OPR001'.
           05  CA-APP-SEQ-NO              PIC S9(09) COMP VALUE ZEROS.
           05  CA-APP-SEQ-ZERO            PIC 9(07) VALUE ZEROS.
           05  CA-MSG                     PIC X(60) VALUE SPACES.
      *--- APPLICATION DATA -------------------------------------------
           05  CA-APPLICATION.
               10  CA-APP-ID              PIC X(10).
               10  CA-APP-STATUS          PIC X(02).
                   88  CA-APP-STAT-DRAFT  VALUE 'DR'.
                   88  CA-APP-STAT-SUBMITTED VALUE 'SB'.
                   88  CA-APP-STAT-PENDING VALUE 'PE'.
                   88  CA-APP-STAT-KYC-PEND VALUE 'KY'.
                   88  CA-APP-STAT-APPROVED VALUE 'AP'.
                   88  CA-APP-STAT-REJECTED VALUE 'RJ'.
                   88  CA-APP-STAT-OPENED VALUE 'OP'.
               10  CA-APP-BUSINESS-NAME   PIC X(60).
               10  CA-APP-TRADE-NAME      PIC X(40).
               10  CA-APP-REGISTRATION-NO PIC X(20).
               10  CA-APP-TAX-ID          PIC X(15).
               10  CA-APP-INCORP-DATE     PIC X(10).
               10  CA-APP-BUSINESS-TYPE   PIC X(02).
                   88  CA-APP-BT-LLC      VALUE 'LC'.
                   88  CA-APP-BT-CORP     VALUE 'CP'.
                   88  CA-APP-BT-PARTNERSHIP VALUE 'PT'.
                   88  CA-APP-BT-SOLEPROP VALUE 'SP'.
                   88  CA-APP-BT-NONPROFIT VALUE 'NP'.
                   88  CA-APP-BT-TRUST    VALUE 'TR'.
               10  CA-APP-INDUSTRY-CODE   PIC X(06).
               10  CA-APP-ANNUAL-REVENUE  PIC S9(10)V99 COMP-3.
               10  CA-APP-EMPLOYEE-COUNT  PIC 9(06).
               10  CA-APP-ADDR.
                   15  CA-APP-ADDR-LINE1  PIC X(40).
                   15  CA-APP-ADDR-LINE2  PIC X(40).
                   15  CA-APP-ADDR-CITY   PIC X(25).
                   15  CA-APP-ADDR-STATE  PIC X(02).
                   15  CA-APP-ADDR-COUNTRY PIC X(03).
                   15  CA-APP-ADDR-ZIP    PIC X(10).
               10  CA-APP-PHONE           PIC X(15).
               10  CA-APP-EMAIL           PIC X(50).
               10  CA-APP-CONTACT-NAME    PIC X(50).
               10  CA-APP-ACCOUNT-TYPE    PIC X(02).
                   88  CA-APP-AT-CHECKING VALUE 'CH'.
                   88  CA-APP-AT-SAVINGS  VALUE 'SV'.
                   88  CA-APP-AT-MONEYMRKT VALUE 'MM'.
                   88  CA-APP-AT-TDEPOSIT VALUE 'TD'.
               10  CA-APP-CURRENCY        PIC X(03).
               10  CA-APP-INITIAL-DEPOSIT PIC S9(10)V99 COMP-3.
               10  CA-APP-EXPECTED-TXN-VOL PIC 9(07).
               10  CA-APP-EXPECTED-TXN-AMT PIC S9(10)V99 COMP-3.
               10  CA-APP-SOURCE-OF-FUNDS PIC X(30).
               10  CA-APP-RISK-RATING     PIC X(02).
                   88  CA-APP-RISK-LOW    VALUE 'LO'.
                   88  CA-APP-RISK-MEDIUM VALUE 'MD'.
                   88  CA-APP-RISK-HIGH   VALUE 'HI'.
               10  CA-APP-PEP-FLAG        PIC X(01).
               10  CA-APP-SANCTIONS-FLAG  PIC X(01).
               10  CA-APP-DOCS-RECEIVED   PIC X(01).
               10  CA-APP-BOARD-RESOLUTION PIC X(01).
               10  CA-APP-UBO-DECLARATION PIC X(01).
               10  CA-APP-MAKER-ID        PIC X(08).
               10  CA-APP-CHECKER-ID      PIC X(08).
               10  CA-APP-CREATED-TIMESTAMP PIC X(26).
               10  CA-APP-UPDATED-TIMESTAMP PIC X(26).
               10  CA-APP-ACCOUNT-NUMBER  PIC X(12).
               10  CA-APP-BRANCH-CODE     PIC X(06).
               10  CA-APP-REJECTION-REASON PIC X(100).
               10  FILLER                 PIC X(50).
      *--- AUTHORIZED SIGNATORY / BENEFICIAL OWNER -------------------
           05  CA-SIGNATORY.
               10  CS-SIG-ID              PIC X(10).
               10  CS-SIG-APP-ID          PIC X(10).
               10  CS-SIG-CUST-ID         PIC X(10).
               10  CS-SIG-NAME            PIC X(50).
               10  CS-SIG-TITLE           PIC X(30).
               10  CS-SIG-DOB             PIC X(10).
               10  CS-SIG-SSN             PIC X(11).
               10  CS-SIG-ADDR.
                   15  CS-SIG-ADDR-LINE1  PIC X(40).
                   15  CS-SIG-ADDR-LINE2  PIC X(40).
                   15  CS-SIG-ADDR-CITY   PIC X(25).
                   15  CS-SIG-ADDR-STATE  PIC X(02).
                   15  CS-SIG-ADDR-COUNTRY PIC X(03).
                   15  CS-SIG-ADDR-ZIP    PIC X(10).
               10  CS-SIG-PHONE           PIC X(15).
               10  CS-SIG-EMAIL           PIC X(50).
               10  CS-SIG-OWNERSHIP-PCT   PIC 9(03)V99 COMP-3.
               10  CS-SIG-TYPE            PIC X(01).
               10  CS-SIG-ID-TYPE         PIC X(10).
               10  CS-SIG-ID-NUMBER       PIC X(20).
               10  CS-SIG-CREATED-TIMESTAMP PIC X(26).
               10  CS-SIG-UPDATED-TIMESTAMP PIC X(26).
               10  FILLER                 PIC X(50).
      *--- AUDIT TRAIL ------------------------------------------------
           05  CA-AUDIT.
               10  AU-APP-ID              PIC X(10).
               10  AU-STATUS-FROM         PIC X(02).
               10  AU-STATUS-TO           PIC X(02).
               10  AU-USER-ID             PIC X(08).
               10  AU-ACTION-TIMESTAMP    PIC X(26).
               10  AU-ACTION-TYPE         PIC X(02).
               10  AU-REMARKS             PIC X(100).
               10  FILLER                 PIC X(20).
