      ******************************************************************
      * COPYBOOK: CPYCOM01                                            *
      * DESCRIPTION: Common Work Areas, Counters and Date Routines      *
      * USED BY: All Business Banking Account programs                  *
      ******************************************************************
       01  WS-CURRENT-DATE-DATA.
           05  WS-CURRENT-DATE.
               10  WS-CURRENT-YEAR        PIC 9(04).
               10  WS-CURRENT-MONTH       PIC 9(02).
               10  WS-CURRENT-DAY         PIC 9(02).
           05  WS-CURRENT-TIME.
               10  WS-CURRENT-HOUR        PIC 9(02).
               10  WS-CURRENT-MIN         PIC 9(02).
               10  WS-CURRENT-SEC         PIC 9(02).
               10  WS-CURRENT-HUND        PIC 9(02).
           05  WS-GMT-OFFSET             PIC S9(04).

       01  WS-FORMATTED-DATE             PIC X(10).
       01  WS-FORMATTED-TIME             PIC X(08).
       01  WS-FORMATTED-TIMESTAMP        PIC X(26).

       01  WS-COMMON-COUNTERS.
           05  WS-RECORDS-READ           PIC 9(09) VALUE ZEROS.
           05  WS-RECORDS-WRITTEN        PIC 9(09) VALUE ZEROS.
           05  WS-RECORDS-UPDATED        PIC 9(09) VALUE ZEROS.
           05  WS-RECORDS-REJECTED       PIC 9(09) VALUE ZEROS.
           05  WS-RECORDS-BYPASSED       PIC 9(09) VALUE ZEROS.

       01  WS-COMMON-FLAGS.
           05  WS-EOF-FLAG               PIC X(01) VALUE 'N'.
               88  WS-EOF                VALUE 'Y'.
               88  WS-NOT-EOF            VALUE 'N'.
           05  WS-PROCESS-FLAG           PIC X(01) VALUE 'Y'.
               88  WS-CONTINUE-PROCESS   VALUE 'Y'.
               88  WS-STOP-PROCESS       VALUE 'N'.

       01  WS-RETURN-CODE                PIC S9(04) COMP VALUE 0.
       01  WS-ABEND-CODE                   PIC X(04) VALUE SPACES.
