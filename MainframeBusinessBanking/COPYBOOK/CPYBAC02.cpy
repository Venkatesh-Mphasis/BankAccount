      ******************************************************************
      * COPYBOOK: CPYBAC02                                            *
      * DESCRIPTION: Business / Corporate Customer Master Record      *
      * USED BY: BACBAT01, BACONL02                                   *
      * DATABASE:    TB_BAC_CUSTOMER                                    *
      ******************************************************************
       01  WS-BAC-CUSTOMER-REC.
           05  WS-CUST-ID                 PIC X(10).
           05  WS-CUST-APP-ID             PIC X(10).
           05  WS-CUST-BUSINESS-NAME      PIC X(60).
           05  WS-CUST-TRADE-NAME         PIC X(40).
           05  WS-CUST-REGISTRATION-NO    PIC X(20).
           05  WS-CUST-TAX-ID             PIC X(15).
           05  WS-CUST-INCORP-DATE        PIC X(10).
           05  WS-CUST-BUSINESS-TYPE      PIC X(02).
           05  WS-CUST-INDUSTRY-CODE      PIC X(06).
           05  WS-CUST-ANNUAL-REVENUE     PIC S9(10)V99 COMP-3.
           05  WS-CUST-EMPLOYEE-COUNT     PIC 9(06).
           05  WS-CUST-ADDR.
               10  WS-CUST-ADDR-LINE1     PIC X(40).
               10  WS-CUST-ADDR-LINE2     PIC X(40).
               10  WS-CUST-ADDR-CITY      PIC X(25).
               10  WS-CUST-ADDR-STATE     PIC X(02).
               10  WS-CUST-ADDR-COUNTRY   PIC X(03).
               10  WS-CUST-ADDR-ZIP       PIC X(10).
           05  WS-CUST-PHONE              PIC X(15).
           05  WS-CUST-EMAIL              PIC X(50).
           05  WS-CUST-CONTACT-NAME       PIC X(50).
           05  WS-CUST-RISK-RATING        PIC X(02).
           05  WS-CUST-STATUS             PIC X(02).
           05  WS-CUST-CREATED-TIMESTAMP  PIC X(26).
           05  WS-CUST-UPDATED-TIMESTAMP  PIC X(26).
           05  FILLER                     PIC X(50).
