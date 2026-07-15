      ******************************************************************
      * COPYBOOK: CPYBAC03                                            *
      * DESCRIPTION: Authorized Signatory / Beneficial Owner Record   *
      * USED BY: BACONL01, BACBAT01                                   *
      * DATABASE:    TB_BAC_SIGNATORY                                   *
      * TYPE:        A = Authorized Signatory, B = Beneficial Owner   *
      ******************************************************************
       01  WS-BAC-SIGNATORY-REC.
           05  WS-SIG-ID                  PIC X(10).
           05  WS-SIG-APP-ID              PIC X(10).
           05  WS-SIG-CUST-ID             PIC X(10).
           05  WS-SIG-NAME                PIC X(50).
           05  WS-SIG-TITLE               PIC X(30).
           05  WS-SIG-DOB                 PIC X(10).
           05  WS-SIG-SSN                 PIC X(11).
           05  WS-SIG-ADDR.
               10  WS-SIG-ADDR-LINE1      PIC X(40).
               10  WS-SIG-ADDR-LINE2      PIC X(40).
               10  WS-SIG-ADDR-CITY       PIC X(25).
               10  WS-SIG-ADDR-STATE      PIC X(02).
               10  WS-SIG-ADDR-COUNTRY    PIC X(03).
               10  WS-SIG-ADDR-ZIP        PIC X(10).
           05  WS-SIG-PHONE               PIC X(15).
           05  WS-SIG-EMAIL               PIC X(50).
           05  WS-SIG-OWNERSHIP-PCT       PIC 9(03)V99 COMP-3.
           05  WS-SIG-TYPE                PIC X(01).
           05  WS-SIG-ID-TYPE             PIC X(10).
           05  WS-SIG-ID-NUMBER           PIC X(20).
           05  WS-SIG-CREATED-TIMESTAMP   PIC X(26).
           05  WS-SIG-UPDATED-TIMESTAMP   PIC X(26).
           05  FILLER                     PIC X(50).
