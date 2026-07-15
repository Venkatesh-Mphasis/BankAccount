      ******************************************************************
      * COPYBOOK: CPYBAC07                                            *
      * DESCRIPTION: Debit / Prepaid Card Master Record                *
      * USED BY: BACBAT01 (account opening), BACCRD01 (card ops)      *
      * DATABASE:    TB_BAC_CARD                                         *
      ******************************************************************
       01  WS-BAC-CARD-REC.
           05  WS-CARD-ID                 PIC X(10).
           05  WS-CARD-APP-ID             PIC X(10).
           05  WS-CARD-ACCOUNT-NUM        PIC X(12).
           05  WS-CARD-CUST-ID            PIC X(10).
           05  WS-CARD-NUMBER             PIC X(16).
           05  WS-CARD-TYPE               PIC X(02).
               88  WS-CARD-TYPE-DEBIT      VALUE 'DC'.
               88  WS-CARD-TYPE-CREDIT      VALUE 'CC'.
               88  WS-CARD-TYPE-PREPAID     VALUE 'PC'.
           05  WS-CARD-STATUS             PIC X(02).
               88  WS-CARD-STAT-REQUESTED   VALUE 'RQ'.
               88  WS-CARD-STAT-APPROVED    VALUE 'AP'.
               88  WS-CARD-STAT-ISSUED      VALUE 'IS'.
           05  WS-CARD-PLASTIC-STATUS     PIC X(02).
               88  WS-CARD-PLAS-PENDING     VALUE 'PE'.
               88  WS-CARD-PLAS-EMBOSSED    VALUE 'EM'.
               88  WS-CARD-PLAS-DISPATCHED  VALUE 'DI'.
               88  WS-CARD-PLAS-DELIVERED   VALUE 'DE'.
           05  WS-CARD-EMBOSS-NAME        PIC X(30).
           05  WS-CARD-ISSUE-DATE         PIC X(10).
           05  WS-CARD-EXPIRY-DATE        PIC X(10).
           05  WS-CARD-DAILY-LIMIT        PIC S9(07)V99 COMP-3.
           05  WS-CARD-ATM-LIMIT          PIC S9(07)V99 COMP-3.
           05  WS-CARD-MONTHLY-LIMIT      PIC S9(09)V99 COMP-3.
           05  WS-CARD-AVAILABLE-LIMIT    PIC S9(09)V99 COMP-3.
           05  WS-CARD-CVV                PIC X(03).
           05  WS-CARD-PIN-STATUS         PIC X(01).
           05  WS-CARD-ACTIVATION-STATUS  PIC X(01).
           05  WS-CARD-DISPATCH-STATUS    PIC X(02).
           05  WS-CARD-MAKER-ID           PIC X(08).
           05  WS-CARD-CHECKER-ID         PIC X(08).
           05  WS-CARD-CREATED-TIMESTAMP  PIC X(26).
           05  WS-CARD-UPDATED-TIMESTAMP  PIC X(26).
           05  WS-CARD-NETWORK            PIC X(06).
           05  WS-CARD-PRODUCT            PIC X(10).
           05  FILLER                     PIC X(34).
