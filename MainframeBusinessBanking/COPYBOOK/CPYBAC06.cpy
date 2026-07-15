      ******************************************************************
      * COPYBOOK: CPYBAC06                                            *
      * DESCRIPTION: Application Status Audit Trail Record              *
      * USED BY: BACONL01, BACBAT01, BACAPPR                          *
      * DATABASE:    TB_BAC_AUDIT                                       *
      ******************************************************************
       01  WS-BAC-AUDIT-REC.
           05  WS-AUD-APP-ID              PIC X(10).
           05  WS-AUD-STATUS-FROM         PIC X(02).
           05  WS-AUD-STATUS-TO           PIC X(02).
           05  WS-AUD-USER-ID             PIC X(08).
           05  WS-AUD-ACTION-TIMESTAMP    PIC X(26).
           05  WS-AUD-ACTION-TYPE         PIC X(02).
           05  WS-AUD-REMARKS             PIC X(100).
           05  FILLER                     PIC X(20).
