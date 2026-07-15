      ******************************************************************
      * COPYBOOK: CPYERR01                                            *
      * DESCRIPTION: Common Error Message Table                         *
      * USED BY: All Business Banking Account programs                  *
      ******************************************************************
       01  WS-ERR-MSG-TABLE.
           05  FILLER                    PIC X(60) VALUE 'NO ERROR'.
           05  FILLER                    PIC X(60) VALUE 'INVALID MENU OPTION'.
           05  FILLER                    PIC X(60) VALUE 'BUSINESS NAME IS REQUIRED'.
           05  FILLER                    PIC X(60) VALUE 'TAX ID IS REQUIRED'.
           05  FILLER                    PIC X(60) VALUE 'REGISTRATION NO IS REQUIRED'.
           05  FILLER                    PIC X(60) VALUE 'INVALID BUSINESS TYPE'.
           05  FILLER                    PIC X(60) VALUE 'ACCOUNT TYPE IS REQUIRED'.
           05  FILLER                    PIC X(60) VALUE 'INITIAL DEPOSIT MUST BE >= 0'.
           05  FILLER                    PIC X(60) VALUE 'KYC DOCUMENTS NOT RECEIVED'.
           05  FILLER                    PIC X(60) VALUE 'PEP / SANCTIONS HIT REJECTED'.
           05  FILLER                    PIC X(60) VALUE 'APPLICATION NOT FOUND'.
           05  FILLER                    PIC X(60) VALUE 'DATABASE ERROR - CONTACT SUPPORT'.
           05  FILLER                    PIC X(60) VALUE 'APPROVAL REJECTED - SEE AUDIT'.
           05  FILLER                    PIC X(60) VALUE 'APPLICATION SUBMITTED SUCCESSFULLY'.
           05  FILLER                    PIC X(60) VALUE 'ACCOUNT OPENED SUCCESSFULLY'.
           05  FILLER                    PIC X(60) VALUE 'PROCESS COMPLETED WITH ERRORS'.

       01  WS-ERR-REDS REDEFINES WS-ERR-MSG-TABLE.
           05  WS-ERR-ENTRY              OCCURS 16 TIMES
                                          INDEXED BY WS-ERR-IDX.
               10  WS-ERR-MSG-TEXT        PIC X(60).
