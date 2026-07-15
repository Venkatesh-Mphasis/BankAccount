      ******************************************************************
      * COPYBOOK: CPYBAC01                                            *
      * DESCRIPTION: Business Banking Account Application Record      *
      * USED BY: BACONL01, BACONL02, BACBAT01                          *
      * DATABASE:    TB_BAC_APPLICATION                                 *
      ******************************************************************
       01  WS-BAC-APPLICATION-REC.
           05  WS-APP-ID                  PIC X(10).
           05  WS-APP-STATUS              PIC X(02).
               88  WS-APP-STAT-DRAFT      VALUE 'DR'.
               88  WS-APP-STAT-SUBMITTED  VALUE 'SB'.
               88  WS-APP-STAT-PENDING    VALUE 'PE'.
               88  WS-APP-STAT-KYC-PEND   VALUE 'KY'.
               88  WS-APP-STAT-APPROVED   VALUE 'AP'.
               88  WS-APP-STAT-REJECTED   VALUE 'RJ'.
               88  WS-APP-STAT-OPENED     VALUE 'OP'.
           05  WS-APP-BUSINESS-NAME       PIC X(60).
           05  WS-APP-TRADE-NAME          PIC X(40).
           05  WS-APP-REGISTRATION-NO     PIC X(20).
           05  WS-APP-TAX-ID              PIC X(15).
           05  WS-APP-INCORP-DATE         PIC X(10).
           05  WS-APP-BUSINESS-TYPE       PIC X(02).
               88  WS-APP-BT-LLC          VALUE 'LC'.
               88  WS-APP-BT-CORP         VALUE 'CP'.
               88  WS-APP-BT-PARTNERSHIP  VALUE 'PT'.
               88  WS-APP-BT-SOLEPROP     VALUE 'SP'.
               88  WS-APP-BT-NONPROFIT    VALUE 'NP'.
               88  WS-APP-BT-TRUST        VALUE 'TR'.
           05  WS-APP-INDUSTRY-CODE       PIC X(06).
           05  WS-APP-ANNUAL-REVENUE      PIC S9(10)V99 COMP-3.
           05  WS-APP-EMPLOYEE-COUNT      PIC 9(06).
           05  WS-APP-ADDR.
               10  WS-APP-ADDR-LINE1      PIC X(40).
               10  WS-APP-ADDR-LINE2      PIC X(40).
               10  WS-APP-ADDR-CITY       PIC X(25).
               10  WS-APP-ADDR-STATE      PIC X(02).
               10  WS-APP-ADDR-COUNTRY    PIC X(03).
               10  WS-APP-ADDR-ZIP        PIC X(10).
           05  WS-APP-PHONE               PIC X(15).
           05  WS-APP-EMAIL               PIC X(50).
           05  WS-APP-CONTACT-NAME        PIC X(50).
           05  WS-APP-ACCOUNT-TYPE        PIC X(02).
               88  WS-APP-AT-CHECKING     VALUE 'CH'.
               88  WS-APP-AT-SAVINGS      VALUE 'SV'.
               88  WS-APP-AT-MONEYMRKT    VALUE 'MM'.
               88  WS-APP-AT-TDEPOSIT     VALUE 'TD'.
           05  WS-APP-CURRENCY            PIC X(03).
           05  WS-APP-INITIAL-DEPOSIT     PIC S9(10)V99 COMP-3.
           05  WS-APP-EXPECTED-TXN-VOL    PIC 9(07).
           05  WS-APP-EXPECTED-TXN-AMT    PIC S9(10)V99 COMP-3.
           05  WS-APP-SOURCE-OF-FUNDS     PIC X(30).
           05  WS-APP-RISK-RATING         PIC X(02).
               88  WS-APP-RISK-LOW        VALUE 'LO'.
               88  WS-APP-RISK-MEDIUM     VALUE 'MD'.
               88  WS-APP-RISK-HIGH       VALUE 'HI'.
           05  WS-APP-PEP-FLAG            PIC X(01).
           05  WS-APP-SANCTIONS-FLAG      PIC X(01).
           05  WS-APP-DOCS-RECEIVED       PIC X(01).
           05  WS-APP-BOARD-RESOLUTION    PIC X(01).
           05  WS-APP-UBO-DECLARATION     PIC X(01).
           05  WS-APP-MAKER-ID            PIC X(08).
           05  WS-APP-CHECKER-ID          PIC X(08).
           05  WS-APP-CREATED-TIMESTAMP   PIC X(26).
           05  WS-APP-UPDATED-TIMESTAMP   PIC X(26).
           05  WS-APP-ACCOUNT-NUMBER      PIC X(12).
           05  WS-APP-BRANCH-CODE         PIC X(06).
           05  WS-APP-REJECTION-REASON    PIC X(100).
           05  WS-APP-CARD-REQUESTED     PIC X(01).
               88  WS-APP-CRD-REQUESTED   VALUE 'Y'.
           05  WS-APP-CARD-TYPE          PIC X(02).
               88  WS-APP-CRD-DEBIT       VALUE 'DC'.
               88  WS-APP-CRD-CREDIT      VALUE 'CC'.
               88  WS-APP-CRD-PREPAID     VALUE 'PC'.
           05  WS-APP-CARD-DAILY-LIMIT   PIC S9(07)V99 COMP-3.
           05  WS-APP-CARD-ATM-LIMIT     PIC S9(07)V99 COMP-3.
           05  WS-APP-CARD-MONTHLY-LIMIT PIC S9(09)V99 COMP-3.
           05  WS-APP-CARD-EMBOSS-NAME   PIC X(30).
           05  FILLER                     PIC X(05).
