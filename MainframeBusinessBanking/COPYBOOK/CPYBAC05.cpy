      ******************************************************************
      * COPYBOOK: CPYBAC05                                            *
      * DESCRIPTION: KYC / Compliance Document Record                 *
      * USED BY: BACONL01, BACBAT01                                   *
      * DATABASE:    TB_BAC_DOCUMENT                                    *
      ******************************************************************
       01  WS-BAC-DOCUMENT-REC.
           05  WS-DOC-APP-ID              PIC X(10).
           05  WS-DOC-DOC-TYPE            PIC X(02).
               88  WS-DOC-ARTICLES        VALUE 'AR'.
               88  WS-DOC-TAX-CERT        VALUE 'TC'.
               88  WS-DOC-ADDRESS-PROOF   VALUE 'AD'.
               88  WS-DOC-ID-PROOF        VALUE 'ID'.
               88  WS-DOC-UBO-DECL        VALUE 'BO'.
               88  WS-DOC-BOARD-RES       VALUE 'BR'.
           05  WS-DOC-DOC-REF             PIC X(30).
           05  WS-DOC-STATUS              PIC X(01).
           05  WS-DOC-RECEIVED-DATE       PIC X(10).
           05  WS-DOC-REMARKS             PIC X(50).
           05  FILLER                     PIC X(20).
