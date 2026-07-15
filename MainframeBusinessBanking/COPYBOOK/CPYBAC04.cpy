      ******************************************************************
      * COPYBOOK: CPYBAC04                                            *
      * DESCRIPTION: Opened Account Master Record                     *
      * USED BY: BACBAT01, BACONL02                                   *
      * DATABASE:    TB_BAC_ACCOUNT                                     *
      ******************************************************************
       01  WS-BAC-ACCOUNT-REC.
           05  WS-ACC-ACCOUNT-NUMBER      PIC X(12).
           05  WS-ACC-APP-ID              PIC X(10).
           05  WS-ACC-CUST-ID             PIC X(10).
           05  WS-ACC-ACCOUNT-TYPE        PIC X(02).
           05  WS-ACC-CURRENCY            PIC X(03).
           05  WS-ACC-STATUS              PIC X(02).
               88  WS-ACC-STAT-ACTIVE     VALUE 'AC'.
               88  WS-ACC-STAT-CLOSED     VALUE 'CL'.
               88  WS-ACC-STAT-FROZEN     VALUE 'FR'.
           05  WS-ACC-OPEN-DATE           PIC X(10).
           05  WS-ACC-BALANCE             PIC S9(10)V99 COMP-3.
           05  WS-ACC-AVAILABLE-BALANCE   PIC S9(10)V99 COMP-3.
           05  WS-ACC-INITIAL-DEPOSIT     PIC S9(10)V99 COMP-3.
           05  WS-ACC-BRANCH-CODE         PIC X(06).
           05  WS-ACC-MAKER-ID            PIC X(08).
           05  WS-ACC-CHECKER-ID          PIC X(08).
           05  WS-ACC-CREATED-TIMESTAMP   PIC X(26).
           05  WS-ACC-UPDATED-TIMESTAMP   PIC X(26).
           05  FILLER                     PIC X(50).
