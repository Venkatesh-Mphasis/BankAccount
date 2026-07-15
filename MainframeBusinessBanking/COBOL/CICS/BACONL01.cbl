       IDENTIFICATION DIVISION.
       PROGRAM-ID.    BACONL01.
       AUTHOR.        DEVIN MAINFRAME TEAM.
       DATE-WRITTEN.  2026-07-14.
      ******************************************************************
      * PROGRAM:     BACONL01                                          *
      * DESCRIPTION: CICS ONLINE BUSINESS BANKING ACCOUNT CREATION    *
      *              PORTAL. CAPTURES MULTI-SCREEN APPLICATION DATA    *
      *              VALIDATES KYC / COMPLIANCE, PERSISTS TO DB2.     *
      * TRANSACTION: BA01                                                *
      * MAP/MAPSET:  BACMAPS                                            *
      * DATABASE:    TB_BAC_APPLICATION, TB_BAC_SIGNATORY,             *
      *              TB_BAC_AUDIT                                       *
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       OBJECT-COMPUTER. IBM-ZOS.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  WS-PROGRAM-ID                  PIC X(08) VALUE 'BACONL01'.
       01  WS-TRANSACTION-ID              PIC X(04) VALUE 'BA01'.
       01  WS-MAPSET-NAME                 PIC X(08) VALUE 'BACMAPS'.

      * CICS / DB2 INTERFACE BLOCKS
           COPY DFHBMSCA.
           COPY DFHEIBLK.
           COPY DFHAID.
           EXEC SQL INCLUDE SQLCA END-EXEC.

      * COMMON WORK AREAS AND ERROR MESSAGES
           COPY CPYCOM01.
           COPY CPYERR01.

      * COMMAREA LAYOUT
           COPY CPYBAC00.

      * MAP INPUT / OUTPUT AREAS
       01  BACMENUI.
           05  FILLER                     PIC X(12).
           05  MNOPTL                     PIC S9(04) COMP.
           05  MNOPTF                     PIC X(01).
           05  MNOPTI                     PIC X(01).
           05  MNMSGL                     PIC S9(04) COMP.
           05  MNMSGF                     PIC X(01).
           05  MNMSGI                     PIC X(60).

       01  BACMENUO REDEFINES BACMENUI.
           05  FILLER                     PIC X(12).
           05  FILLER                     PIC X(03).
           05  MNOPTO                     PIC X(01).
           05  FILLER                     PIC X(03).
           05  MNMSGO                     PIC X(60).

       01  BACAPP1I.
           05  FILLER                     PIC X(12).
           05  B1BUSNAML                  PIC S9(04) COMP.
           05  B1BUSNAMF                  PIC X(01).
           05  B1BUSNAMI                  PIC X(40).
           05  B1TRDNAML                  PIC S9(04) COMP.
           05  B1TRDNAMF                  PIC X(01).
           05  B1TRDNAMI                  PIC X(40).
           05  B1REGNOL                   PIC S9(04) COMP.
           05  B1REGNOF                   PIC X(01).
           05  B1REGNOI                   PIC X(20).
           05  B1TAXIDL                   PIC S9(04) COMP.
           05  B1TAXIDF                   PIC X(01).
           05  B1TAXIDI                   PIC X(15).
           05  B1INCDATL                  PIC S9(04) COMP.
           05  B1INCDATF                  PIC X(01).
           05  B1INCDATI                  PIC X(10).
           05  B1BUSTYPL                  PIC S9(04) COMP.
           05  B1BUSTYPF                  PIC X(01).
           05  B1BUSTYPI                  PIC X(02).
           05  B1INDCDEL                  PIC S9(04) COMP.
           05  B1INDCDEF                  PIC X(01).
           05  B1INDCDEI                  PIC X(06).
           05  B1ANNREVL                  PIC S9(04) COMP.
           05  B1ANNREVF                  PIC X(01).
           05  B1ANNREVI                  PIC X(15).
           05  B1EMPCNTL                  PIC S9(04) COMP.
           05  B1EMPCNTF                  PIC X(01).
           05  B1EMPCNTI                  PIC X(06).
           05  B1PHONEL                   PIC S9(04) COMP.
           05  B1PHONEF                   PIC X(01).
           05  B1PHONEI                   PIC X(15).
           05  B1EMAILL                   PIC S9(04) COMP.
           05  B1EMAILF                   PIC X(01).
           05  B1EMAILI                   PIC X(40).
           05  B1MSGL                     PIC S9(04) COMP.
           05  B1MSGF                     PIC X(01).
           05  B1MSGI                     PIC X(60).

       01  BACAPP1O REDEFINES BACAPP1I.
           05  FILLER                     PIC X(12).
           05  FILLER                     PIC X(03).
           05  B1BUSNAMO                  PIC X(40).
           05  FILLER                     PIC X(03).
           05  B1TRDNAMO                  PIC X(40).
           05  FILLER                     PIC X(03).
           05  B1REGNOO                   PIC X(20).
           05  FILLER                     PIC X(03).
           05  B1TAXIDO                   PIC X(15).
           05  FILLER                     PIC X(03).
           05  B1INCDATO                  PIC X(10).
           05  FILLER                     PIC X(03).
           05  B1BUSTYPO                  PIC X(02).
           05  FILLER                     PIC X(03).
           05  B1INDCDEO                  PIC X(06).
           05  FILLER                     PIC X(03).
           05  B1ANNREVO                  PIC X(15).
           05  FILLER                     PIC X(03).
           05  B1EMPCNTO                  PIC X(06).
           05  FILLER                     PIC X(03).
           05  B1PHONEO                   PIC X(15).
           05  FILLER                     PIC X(03).
           05  B1EMAILO                   PIC X(40).
           05  FILLER                     PIC X(03).
           05  B1MSGO                     PIC X(60).

       01  BACAPP2I.
           05  FILLER                     PIC X(12).
           05  B2ADDRL1L                  PIC S9(04) COMP.
           05  B2ADDRL1F                  PIC X(01).
           05  B2ADDRL1I                  PIC X(40).
           05  B2ADDRL2L                  PIC S9(04) COMP.
           05  B2ADDRL2F                  PIC X(01).
           05  B2ADDRL2I                  PIC X(40).
           05  B2CITYL                    PIC S9(04) COMP.
           05  B2CITYF                    PIC X(01).
           05  B2CITYI                    PIC X(25).
           05  B2STATEL                   PIC S9(04) COMP.
           05  B2STATEF                   PIC X(01).
           05  B2STATEI                   PIC X(02).
           05  B2COUNTRYL                 PIC S9(04) COMP.
           05  B2COUNTRYF                 PIC X(01).
           05  B2COUNTRYI                 PIC X(03).
           05  B2ZIPL                     PIC S9(04) COMP.
           05  B2ZIPF                     PIC X(01).
           05  B2ZIPI                     PIC X(10).
           05  B2CONNAML                  PIC S9(04) COMP.
           05  B2CONNAMF                  PIC X(01).
           05  B2CONNAMI                  PIC X(40).
           05  B2CONPHNL                  PIC S9(04) COMP.
           05  B2CONPHNF                  PIC X(01).
           05  B2CONPHNI                  PIC X(15).
           05  B2CONEMLL                  PIC S9(04) COMP.
           05  B2CONEMLF                  PIC X(01).
           05  B2CONEMLI                  PIC X(40).
           05  B2MSGL                     PIC S9(04) COMP.
           05  B2MSGF                     PIC X(01).
           05  B2MSGI                     PIC X(60).

       01  BACAPP2O REDEFINES BACAPP2I.
           05  FILLER                     PIC X(12).
           05  FILLER                     PIC X(03).
           05  B2ADDRL1O                  PIC X(40).
           05  FILLER                     PIC X(03).
           05  B2ADDRL2O                  PIC X(40).
           05  FILLER                     PIC X(03).
           05  B2CITYO                    PIC X(25).
           05  FILLER                     PIC X(03).
           05  B2STATEO                   PIC X(02).
           05  FILLER                     PIC X(03).
           05  B2COUNTRYO                 PIC X(03).
           05  FILLER                     PIC X(03).
           05  B2ZIPO                     PIC X(10).
           05  FILLER                     PIC X(03).
           05  B2CONNAMO                  PIC X(40).
           05  FILLER                     PIC X(03).
           05  B2CONPHNO                  PIC X(15).
           05  FILLER                     PIC X(03).
           05  B2CONEMLO                  PIC X(40).
           05  FILLER                     PIC X(03).
           05  B2MSGO                     PIC X(60).

       01  BACAPP3I.
           05  FILLER                     PIC X(12).
           05  B3ACCTYPL                  PIC S9(04) COMP.
           05  B3ACCTYPF                  PIC X(01).
           05  B3ACCTYPI                  PIC X(02).
           05  B3CURNCYL                  PIC S9(04) COMP.
           05  B3CURNCYF                  PIC X(01).
           05  B3CURNCYI                  PIC X(03).
           05  B3INITDPL                  PIC S9(04) COMP.
           05  B3INITDPF                  PIC X(01).
           05  B3INITDPI                  PIC X(15).
           05  B3SRCFNDL                  PIC S9(04) COMP.
           05  B3SRCFNDF                  PIC X(01).
           05  B3SRCFNDI                  PIC X(30).
           05  B3RISKRTL                  PIC S9(04) COMP.
           05  B3RISKRTF                  PIC X(01).
           05  B3RISKRTI                  PIC X(02).
           05  B3PEPFLGL                  PIC S9(04) COMP.
           05  B3PEPFLGF                  PIC X(01).
           05  B3PEPFLGI                  PIC X(01).
           05  B3SANFLGL                  PIC S9(04) COMP.
           05  B3SANFLGF                  PIC X(01).
           05  B3SANFLGI                  PIC X(01).
           05  B3DOCRECL                  PIC S9(04) COMP.
           05  B3DOCRECF                  PIC X(01).
           05  B3DOCRECI                  PIC X(01).
           05  B3BOARDRESL                PIC S9(04) COMP.
           05  B3BOARDRESF                PIC X(01).
           05  B3BOARDRESI                PIC X(01).
           05  B3UBOFLGL                  PIC S9(04) COMP.
           05  B3UBOFLGF                  PIC X(01).
           05  B3UBOFLGI                  PIC X(01).
           05  B3EXPTXAL                  PIC S9(04) COMP.
           05  B3EXPTXAF                  PIC X(01).
           05  B3EXPTXAI                  PIC X(15).
           05  B3MSGL                     PIC S9(04) COMP.
           05  B3MSGF                     PIC X(01).
           05  B3MSGI                     PIC X(60).

       01  BACAPP3O REDEFINES BACAPP3I.
           05  FILLER                     PIC X(12).
           05  FILLER                     PIC X(03).
           05  B3ACCTYPO                  PIC X(02).
           05  FILLER                     PIC X(03).
           05  B3CURNCYO                  PIC X(03).
           05  FILLER                     PIC X(03).
           05  B3INITDPO                  PIC X(15).
           05  FILLER                     PIC X(03).
           05  B3SRCFNDO                  PIC X(30).
           05  FILLER                     PIC X(03).
           05  B3RISKRTO                  PIC X(02).
           05  FILLER                     PIC X(03).
           05  B3PEPFLGO                  PIC X(01).
           05  FILLER                     PIC X(03).
           05  B3SANFLGO                  PIC X(01).
           05  FILLER                     PIC X(03).
           05  B3DOCRECO                  PIC X(01).
           05  FILLER                     PIC X(03).
           05  B3BOARDRESO                PIC X(01).
           05  FILLER                     PIC X(03).
           05  B3UBOFLGO                  PIC X(01).
           05  FILLER                     PIC X(03).
           05  B3EXPTXAO                  PIC X(15).
           05  FILLER                     PIC X(03).
           05  B3MSGO                     PIC X(60).

       01  BACAPP4I.
           05  FILLER                     PIC X(12).
           05  B4SIGNAML                  PIC S9(04) COMP.
           05  B4SIGNAMF                  PIC X(01).
           05  B4SIGNAMI                  PIC X(50).
           05  B4SIGTTLL                  PIC S9(04) COMP.
           05  B4SIGTTLF                  PIC X(01).
           05  B4SIGTTLI                  PIC X(30).
           05  B4SIGDOBL                  PIC S9(04) COMP.
           05  B4SIGDOBF                  PIC X(01).
           05  B4SIGDOBI                  PIC X(10).
           05  B4SIGSSNL                  PIC S9(04) COMP.
           05  B4SIGSSNF                  PIC X(01).
           05  B4SIGSSNI                  PIC X(11).
           05  B4SIGADR1L                 PIC S9(04) COMP.
           05  B4SIGADR1F                 PIC X(01).
           05  B4SIGADR1I                 PIC X(40).
           05  B4SIGCTYL                  PIC S9(04) COMP.
           05  B4SIGCTYF                  PIC X(01).
           05  B4SIGCTYI                  PIC X(25).
           05  B4SIGSTL                   PIC S9(04) COMP.
           05  B4SIGSTF                   PIC X(01).
           05  B4SIGSTI                   PIC X(02).
           05  B4SIGZIPL                  PIC S9(04) COMP.
           05  B4SIGZIPF                  PIC X(01).
           05  B4SIGZIPI                  PIC X(10).
           05  B4SIGPHNL                  PIC S9(04) COMP.
           05  B4SIGPHNF                  PIC X(01).
           05  B4SIGPHNI                  PIC X(15).
           05  B4SIGOWNL                  PIC S9(04) COMP.
           05  B4SIGOWNF                  PIC X(01).
           05  B4SIGOWNI                  PIC X(06).
           05  B4SIGTYPL                  PIC S9(04) COMP.
           05  B4SIGTYPF                  PIC X(01).
           05  B4SIGTYPI                  PIC X(01).
           05  B4SIGIDTL                  PIC S9(04) COMP.
           05  B4SIGIDTF                  PIC X(01).
           05  B4SIGIDTI                  PIC X(10).
           05  B4SIGIDNL                  PIC S9(04) COMP.
           05  B4SIGIDNF                  PIC X(01).
           05  B4SIGIDNI                  PIC X(20).
           05  B4MSGL                     PIC S9(04) COMP.
           05  B4MSGF                     PIC X(01).
           05  B4MSGI                     PIC X(60).

       01  BACAPP4O REDEFINES BACAPP4I.
           05  FILLER                     PIC X(12).
           05  FILLER                     PIC X(03).
           05  B4SIGNAMO                  PIC X(50).
           05  FILLER                     PIC X(03).
           05  B4SIGTTLO                  PIC X(30).
           05  FILLER                     PIC X(03).
           05  B4SIGDOBO                  PIC X(10).
           05  FILLER                     PIC X(03).
           05  B4SIGSSNO                  PIC X(11).
           05  FILLER                     PIC X(03).
           05  B4SIGADR1O                 PIC X(40).
           05  FILLER                     PIC X(03).
           05  B4SIGCTYO                  PIC X(25).
           05  FILLER                     PIC X(03).
           05  B4SIGSTO                   PIC X(02).
           05  FILLER                     PIC X(03).
           05  B4SIGZIPO                  PIC X(10).
           05  FILLER                     PIC X(03).
           05  B4SIGPHNO                  PIC X(15).
           05  FILLER                     PIC X(03).
           05  B4SIGOWNO                  PIC X(06).
           05  FILLER                     PIC X(03).
           05  B4SIGTYPO                  PIC X(01).
           05  FILLER                     PIC X(03).
           05  B4SIGIDTO                  PIC X(10).
           05  FILLER                     PIC X(03).
           05  B4SIGIDNO                  PIC X(20).
           05  FILLER                     PIC X(03).
           05  B4MSGO                     PIC X(60).

       01  BACREVUI.
           05  FILLER                     PIC X(12).
           05  RVAPPIDL                   PIC S9(04) COMP.
           05  RVAPPIDF                   PIC X(01).
           05  RVAPPIDI                   PIC X(10).
           05  RVBUSNAML                  PIC S9(04) COMP.
           05  RVBUSNAMF                  PIC X(01).
           05  RVBUSNAMI                  PIC X(40).
           05  RVACCTYPL                  PIC S9(04) COMP.
           05  RVACCTYPF                  PIC X(01).
           05  RVACCTYPI                  PIC X(02).
           05  RVINITDPL                  PIC S9(04) COMP.
           05  RVINITDPF                  PIC X(01).
           05  RVINITDPI                  PIC X(15).
           05  RVRISKRTL                  PIC S9(04) COMP.
           05  RVRISKRTF                  PIC X(01).
           05  RVRISKRTI                  PIC X(02).
           05  RVPEPFLGL                  PIC S9(04) COMP.
           05  RVPEPFLGF                  PIC X(01).
           05  RVPEPFLGI                  PIC X(01).
           05  RVSANFLGL                  PIC S9(04) COMP.
           05  RVSANFLGF                  PIC X(01).
           05  RVSANFLGI                  PIC X(01).
           05  RVDOCRECL                  PIC S9(04) COMP.
           05  RVDOCRECF                  PIC X(01).
           05  RVDOCRECI                  PIC X(01).
           05  RVSUBAPPL                  PIC S9(04) COMP.
           05  RVSUBAPPF                  PIC X(01).
           05  RVSUBAPPI                  PIC X(01).
           05  RVMSGL                     PIC S9(04) COMP.
           05  RVMSGF                     PIC X(01).
           05  RVMSGI                     PIC X(60).

       01  BACREVUO REDEFINES BACREVUI.
           05  FILLER                     PIC X(12).
           05  FILLER                     PIC X(03).
           05  RVAPPIDO                   PIC X(10).
           05  FILLER                     PIC X(03).
           05  RVBUSNAMO                  PIC X(40).
           05  FILLER                     PIC X(03).
           05  RVACCTYPO                  PIC X(02).
           05  FILLER                     PIC X(03).
           05  RVINITDPO                  PIC X(15).
           05  FILLER                     PIC X(03).
           05  RVRISKRTO                  PIC X(02).
           05  FILLER                     PIC X(03).
           05  RVPEPFLGO                  PIC X(01).
           05  FILLER                     PIC X(03).
           05  RVSANFLGO                  PIC X(01).
           05  FILLER                     PIC X(03).
           05  RVDOCRECO                  PIC X(01).
           05  FILLER                     PIC X(03).
           05  RVSUBAPPO                  PIC X(01).
           05  FILLER                     PIC X(03).
           05  RVMSGO                     PIC X(60).

       01  BACCONFI.
           05  FILLER                     PIC X(12).
           05  CFAPPIDL                   PIC S9(04) COMP.
           05  CFAPPIDF                   PIC X(01).
           05  CFAPPIDI                   PIC X(10).
           05  CFSTATUSL                  PIC S9(04) COMP.
           05  CFSTATUSF                  PIC X(01).
           05  CFSTATUSI                  PIC X(02).
           05  CFMSGL                     PIC S9(04) COMP.
           05  CFMSGF                     PIC X(01).
           05  CFMSGI                     PIC X(60).

       01  BACCONFO REDEFINES BACCONFI.
           05  FILLER                     PIC X(12).
           05  FILLER                     PIC X(03).
           05  CFAPPIDO                   PIC X(10).
           05  FILLER                     PIC X(03).
           05  CFSTATUSO                  PIC X(02).
           05  FILLER                     PIC X(03).
           05  CFMSGO                     PIC X(60).

      * LOCAL WORK VARIABLES
       01  WS-CA-LENGTH                   PIC S9(04) COMP.
       01  WS-RESP-CODE                   PIC S9(08) COMP.
       01  WS-VALID-FLAG                  PIC X(01) VALUE 'Y'.
           88  WS-IS-VALID                VALUE 'Y'.
           88  WS-IS-INVALID              VALUE 'N'.
       01  WS-NEXT-SCREEN                 PIC 9(02) VALUE ZEROS.
       01  WS-EDIT-AMOUNT                 PIC ZZZ,ZZZ,ZZZ,ZZ9.99.
       01  WS-EDIT-PCT                    PIC ZZ9.99.
       01  WS-EDIT-EMP                    PIC ZZZZZ9.
       01  WS-AT-COUNT                    PIC 9(02) VALUE ZEROS.
       01  WS-HV-APP-SEQ                  PIC S9(09) COMP.
       01  WS-HV-APP-SEQ-ZERO             PIC 9(07).
       01  WS-HV-SIG-SEQ                  PIC S9(09) COMP.
       01  WS-HV-SIG-SEQ-ZERO             PIC 9(07).

       LINKAGE SECTION.
       01  DFHCOMMAREA                    PIC X(2000).

       PROCEDURE DIVISION.

       0000-MAIN-PROCESS.
           COMPUTE WS-CA-LENGTH = FUNCTION LENGTH(WS-BAC-COMMAREA)

           IF EIBCALEN > 0
               MOVE DFHCOMMAREA TO WS-BAC-COMMAREA
           ELSE
               MOVE SPACES TO WS-BAC-COMMAREA
               MOVE ZEROS  TO CA-SCREEN
               MOVE 'OPR001' TO CA-USER-ID
               IF EIBUSERID NOT = SPACES
                   MOVE EIBUSERID TO CA-USER-ID
               END-IF
           END-IF

           EVALUATE TRUE
               WHEN CA-SCREEN = 0
                   PERFORM 1000-PROCESS-MENU
               WHEN CA-SCREEN = 11
                   PERFORM 1100-PROCESS-APP1
               WHEN CA-SCREEN = 12
                   PERFORM 1200-PROCESS-APP2
               WHEN CA-SCREEN = 13
                   PERFORM 1300-PROCESS-APP3
               WHEN CA-SCREEN = 14
                   PERFORM 1400-PROCESS-APP4
               WHEN CA-SCREEN = 15
                   PERFORM 1500-PROCESS-REVIEW
               WHEN CA-SCREEN = 16
                   PERFORM 1600-PROCESS-CONFIRM
               WHEN OTHER
                   MOVE 0 TO CA-SCREEN
                   PERFORM 1000-PROCESS-MENU
           END-EVALUATE

           EXEC CICS RETURN
               TRANSID(WS-TRANSACTION-ID)
               COMMAREA(WS-BAC-COMMAREA)
               LENGTH(WS-CA-LENGTH)
           END-EXEC
           .

      ******************************************************************
      * 1000-PROCESS-MENU: DISPLAY PORTAL MENU AND HANDLE OPTION       *
      ******************************************************************
       1000-PROCESS-MENU.
           IF EIBCALEN > 0 AND NOT CA-FIRST-TIME
               EXEC CICS RECEIVE
                   MAP('BACMENU')
                   MAPSET(WS-MAPSET-NAME)
                   INTO(BACMENUI)
                   RESP(WS-RESP-CODE)
               END-EXEC
               IF WS-RESP-CODE = DFHRESP(NORMAL)
                   EVALUATE MNOPTI
                       WHEN '1'
                           MOVE 11 TO CA-SCREEN
                           MOVE 'NE' TO CA-ACTION
                           PERFORM 1110-SEND-APP1
                       WHEN '2'
                           MOVE 'USE BA02 FOR INQUIRY' TO CA-MSG
                           PERFORM 1010-SEND-MENU
                       WHEN '3'
                           MOVE 'USE BA03 FOR APPROVAL' TO CA-MSG
                           PERFORM 1010-SEND-MENU
                       WHEN '4'
                           MOVE 'USE BA02 FOR INQUIRY' TO CA-MSG
                           PERFORM 1010-SEND-MENU
                       WHEN '5'
                           PERFORM 9900-EXIT-CICS
                       WHEN OTHER
                           MOVE 'INVALID OPTION - SELECT 1-5' TO CA-MSG
                           PERFORM 1010-SEND-MENU
                   END-EVALUATE
               ELSE
                   MOVE 'MAP RECEIVE ERROR' TO CA-MSG
                   PERFORM 1010-SEND-MENU
               END-IF
           ELSE
               MOVE SPACES TO CA-MSG
               PERFORM 1010-SEND-MENU
           END-IF
           .

      ******************************************************************
      * 1010-SEND-MENU: SEND MAIN MENU / DASHBOARD                     *
      ******************************************************************
       1010-SEND-MENU.
           INITIALIZE BACMENUO
           MOVE MNOPTI        TO MNOPTO
           MOVE CA-MSG        TO MNMSGO
           EXEC CICS SEND
               MAP('BACMENU')
               MAPSET(WS-MAPSET-NAME)
               FROM(BACMENUO)
               ERASE
           END-EXEC
           MOVE 0 TO CA-SCREEN
           .

      ******************************************************************
      * 1100-PROCESS-APP1: BUSINESS IDENTIFICATION PAGE                *
      ******************************************************************
       1100-PROCESS-APP1.
           IF EIBCALEN > 0 AND NOT CA-FIRST-TIME
               EXEC CICS RECEIVE
                   MAP('BACAPP1')
                   MAPSET(WS-MAPSET-NAME)
                   INTO(BACAPP1I)
                   RESP(WS-RESP-CODE)
               END-EXEC
               IF WS-RESP-CODE = DFHRESP(NORMAL)
                   EVALUATE EIBAID
                       WHEN DFHPF3
                           MOVE 0 TO CA-SCREEN
                           PERFORM 1010-SEND-MENU
                       WHEN DFHPF7
                           MOVE 0 TO CA-SCREEN
                           PERFORM 1010-SEND-MENU
                       WHEN DFHPF8
                           PERFORM 1120-MAP-APP1-TO-COMMAREA
                           PERFORM 1130-VALIDATE-APP1
                           IF WS-IS-VALID
                               MOVE 12 TO CA-SCREEN
                               PERFORM 1210-SEND-APP2
                           ELSE
                               PERFORM 1110-SEND-APP1
                           END-IF
                       WHEN DFHENTER
                           PERFORM 1120-MAP-APP1-TO-COMMAREA
                           PERFORM 1130-VALIDATE-APP1
                           IF WS-IS-VALID
                               MOVE 12 TO CA-SCREEN
                               PERFORM 1210-SEND-APP2
                           ELSE
                               PERFORM 1110-SEND-APP1
                           END-IF
                       WHEN OTHER
                           MOVE 'PF3=EXIT PF7=BACK PF8=NEXT' TO CA-MSG
                           PERFORM 1110-SEND-APP1
                   END-EVALUATE
               ELSE
                   MOVE 'MAP RECEIVE ERROR' TO CA-MSG
                   PERFORM 1110-SEND-APP1
               END-IF
           ELSE
               MOVE 'ENTER BUSINESS IDENTIFICATION' TO CA-MSG
               PERFORM 1110-SEND-APP1
           END-IF
           .

      ******************************************************************
      * 1110-SEND-APP1: POPULATE AND SEND PAGE 1                        *
      ******************************************************************
       1110-SEND-APP1.
           INITIALIZE BACAPP1O
           MOVE CA-APP-BUSINESS-NAME  TO B1BUSNAMO
           MOVE CA-APP-TRADE-NAME     TO B1TRDNAMO
           MOVE CA-APP-REGISTRATION-NO TO B1REGNOO
           MOVE CA-APP-TAX-ID         TO B1TAXIDO
           MOVE CA-APP-INCORP-DATE    TO B1INCDATO
           MOVE CA-APP-BUSINESS-TYPE  TO B1BUSTYPO
           MOVE CA-APP-INDUSTRY-CODE  TO B1INDCDEO
           IF CA-APP-ANNUAL-REVENUE NOT = ZEROS
               MOVE CA-APP-ANNUAL-REVENUE TO WS-EDIT-AMOUNT
               MOVE WS-EDIT-AMOUNT       TO B1ANNREVO
           END-IF
           IF CA-APP-EMPLOYEE-COUNT NOT = ZEROS
               MOVE CA-APP-EMPLOYEE-COUNT TO WS-EDIT-EMP
               MOVE WS-EDIT-EMP          TO B1EMPCNTO
           END-IF
           MOVE CA-APP-PHONE          TO B1PHONEO
           MOVE CA-APP-EMAIL          TO B1EMAILO
           MOVE CA-MSG                TO B1MSGO
           EXEC CICS SEND
               MAP('BACAPP1')
               MAPSET(WS-MAPSET-NAME)
               FROM(BACAPP1O)
               ERASE
           END-EXEC
           .

      ******************************************************************
      * 1120-MAP-APP1-TO-COMMAREA: MOVE SCREEN FIELDS TO COMMAREA       *
      ******************************************************************
       1120-MAP-APP1-TO-COMMAREA.
           MOVE B1BUSNAMI             TO CA-APP-BUSINESS-NAME
           MOVE B1TRDNAMI             TO CA-APP-TRADE-NAME
           MOVE B1REGNOI              TO CA-APP-REGISTRATION-NO
           MOVE B1TAXIDI              TO CA-APP-TAX-ID
           MOVE B1INCDATI             TO CA-APP-INCORP-DATE
           MOVE B1BUSTYPI             TO CA-APP-BUSINESS-TYPE
           MOVE B1INDCDEI             TO CA-APP-INDUSTRY-CODE
           COMPUTE CA-APP-ANNUAL-REVENUE = FUNCTION NUMVAL(B1ANNREVI)
           COMPUTE CA-APP-EMPLOYEE-COUNT = FUNCTION NUMVAL(B1EMPCNTI)
           MOVE B1PHONEI              TO CA-APP-PHONE
           MOVE B1EMAILI              TO CA-APP-EMAIL
           .

      ******************************************************************
      * 1130-VALIDATE-APP1: BUSINESS IDENTIFICATION VALIDATION         *
      ******************************************************************
       1130-VALIDATE-APP1.
           SET WS-IS-VALID TO TRUE
           IF CA-APP-BUSINESS-NAME = SPACES
               SET WS-IS-INVALID TO TRUE
               MOVE WS-ERR-ENTRY (3) TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           IF CA-APP-TAX-ID = SPACES
               SET WS-IS-INVALID TO TRUE
               MOVE WS-ERR-ENTRY (4) TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           IF CA-APP-REGISTRATION-NO = SPACES
               SET WS-IS-INVALID TO TRUE
               MOVE WS-ERR-ENTRY (5) TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           IF NOT (CA-APP-BT-LLC OR CA-APP-BT-CORP OR
                   CA-APP-BT-PARTNERSHIP OR CA-APP-BT-SOLEPROP OR
                   CA-APP-BT-NONPROFIT OR CA-APP-BT-TRUST)
               SET WS-IS-INVALID TO TRUE
               MOVE WS-ERR-ENTRY (6) TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           IF CA-APP-ANNUAL-REVENUE < 0
               SET WS-IS-INVALID TO TRUE
               MOVE WS-ERR-ENTRY (8) TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           .

      ******************************************************************
      * 1200-PROCESS-APP2: ADDRESS AND CONTACT PAGE                    *
      ******************************************************************
       1200-PROCESS-APP2.
           IF EIBCALEN > 0 AND NOT CA-FIRST-TIME
               EXEC CICS RECEIVE
                   MAP('BACAPP2')
                   MAPSET(WS-MAPSET-NAME)
                   INTO(BACAPP2I)
                   RESP(WS-RESP-CODE)
               END-EXEC
               IF WS-RESP-CODE = DFHRESP(NORMAL)
                   EVALUATE EIBAID
                       WHEN DFHPF3
                           MOVE 0 TO CA-SCREEN
                           PERFORM 1010-SEND-MENU
                       WHEN DFHPF7
                           MOVE 11 TO CA-SCREEN
                           PERFORM 1110-SEND-APP1
                       WHEN DFHPF8
                           PERFORM 1220-MAP-APP2-TO-COMMAREA
                           PERFORM 1230-VALIDATE-APP2
                           IF WS-IS-VALID
                               MOVE 13 TO CA-SCREEN
                               PERFORM 1310-SEND-APP3
                           ELSE
                               PERFORM 1210-SEND-APP2
                           END-IF
                       WHEN DFHENTER
                           PERFORM 1220-MAP-APP2-TO-COMMAREA
                           PERFORM 1230-VALIDATE-APP2
                           IF WS-IS-VALID
                               MOVE 13 TO CA-SCREEN
                               PERFORM 1310-SEND-APP3
                           ELSE
                               PERFORM 1210-SEND-APP2
                           END-IF
                       WHEN OTHER
                           MOVE 'PF3=EXIT PF7=BACK PF8=NEXT' TO CA-MSG
                           PERFORM 1210-SEND-APP2
                   END-EVALUATE
               ELSE
                   MOVE 'MAP RECEIVE ERROR' TO CA-MSG
                   PERFORM 1210-SEND-APP2
               END-IF
           ELSE
               MOVE 'ENTER ADDRESS AND CONTACT' TO CA-MSG
               PERFORM 1210-SEND-APP2
           END-IF
           .

      ******************************************************************
      * 1210-SEND-APP2: POPULATE AND SEND PAGE 2                         *
      ******************************************************************
       1210-SEND-APP2.
           INITIALIZE BACAPP2O
           MOVE CA-APP-ADDR-LINE1     TO B2ADDRL1O
           MOVE CA-APP-ADDR-LINE2     TO B2ADDRL2O
           MOVE CA-APP-ADDR-CITY      TO B2CITYO
           MOVE CA-APP-ADDR-STATE     TO B2STATEO
           MOVE CA-APP-ADDR-COUNTRY   TO B2COUNTRYO
           MOVE CA-APP-ADDR-ZIP       TO B2ZIPO
           MOVE CA-APP-CONTACT-NAME   TO B2CONNAMO
           MOVE CA-APP-PHONE          TO B2CONPHNO
           MOVE CA-APP-EMAIL          TO B2CONEMLO
           MOVE CA-MSG                TO B2MSGO
           EXEC CICS SEND
               MAP('BACAPP2')
               MAPSET(WS-MAPSET-NAME)
               FROM(BACAPP2O)
               ERASE
           END-EXEC
           .

      ******************************************************************
      * 1220-MAP-APP2-TO-COMMAREA: MOVE SCREEN FIELDS TO COMMAREA      *
      ******************************************************************
       1220-MAP-APP2-TO-COMMAREA.
           MOVE B2ADDRL1I             TO CA-APP-ADDR-LINE1
           MOVE B2ADDRL2I             TO CA-APP-ADDR-LINE2
           MOVE B2CITYI               TO CA-APP-ADDR-CITY
           MOVE B2STATEI              TO CA-APP-ADDR-STATE
           MOVE B2COUNTRYI            TO CA-APP-ADDR-COUNTRY
           MOVE B2ZIPI                TO CA-APP-ADDR-ZIP
           MOVE B2CONNAMI             TO CA-APP-CONTACT-NAME
           MOVE B2CONPHNI             TO CA-APP-PHONE
           MOVE B2CONEMLI             TO CA-APP-EMAIL
           .

      ******************************************************************
      * 1230-VALIDATE-APP2: ADDRESS VALIDATION                         *
      ******************************************************************
       1230-VALIDATE-APP2.
           SET WS-IS-VALID TO TRUE
           IF CA-APP-ADDR-LINE1 = SPACES OR
              CA-APP-ADDR-CITY = SPACES OR
              CA-APP-ADDR-COUNTRY = SPACES
               SET WS-IS-INVALID TO TRUE
               MOVE 'ADDRESS LINE1/CITY/COUNTRY REQUIRED' TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           IF CA-APP-ADDR-COUNTRY = 'USA' OR 'US '
               IF CA-APP-ADDR-STATE = SPACES OR
                  CA-APP-ADDR-ZIP = SPACES
                   SET WS-IS-INVALID TO TRUE
                   MOVE 'STATE AND ZIP REQUIRED FOR USA' TO CA-MSG
                   EXIT PARAGRAPH
               END-IF
           END-IF
           .

      ******************************************************************
      * 1300-PROCESS-APP3: PRODUCT AND KYC PAGE                        *
      ******************************************************************
       1300-PROCESS-APP3.
           IF EIBCALEN > 0 AND NOT CA-FIRST-TIME
               EXEC CICS RECEIVE
                   MAP('BACAPP3')
                   MAPSET(WS-MAPSET-NAME)
                   INTO(BACAPP3I)
                   RESP(WS-RESP-CODE)
               END-EXEC
               IF WS-RESP-CODE = DFHRESP(NORMAL)
                   EVALUATE EIBAID
                       WHEN DFHPF3
                           MOVE 0 TO CA-SCREEN
                           PERFORM 1010-SEND-MENU
                       WHEN DFHPF7
                           MOVE 12 TO CA-SCREEN
                           PERFORM 1210-SEND-APP2
                       WHEN DFHPF8
                           PERFORM 1320-MAP-APP3-TO-COMMAREA
                           PERFORM 1330-VALIDATE-APP3
                           IF WS-IS-VALID
                               MOVE 14 TO CA-SCREEN
                               PERFORM 1410-SEND-APP4
                           ELSE
                               PERFORM 1310-SEND-APP3
                           END-IF
                       WHEN DFHENTER
                           PERFORM 1320-MAP-APP3-TO-COMMAREA
                           PERFORM 1330-VALIDATE-APP3
                           IF WS-IS-VALID
                               MOVE 14 TO CA-SCREEN
                               PERFORM 1410-SEND-APP4
                           ELSE
                               PERFORM 1310-SEND-APP3
                           END-IF
                       WHEN OTHER
                           MOVE 'PF3=EXIT PF7=BACK PF8=NEXT' TO CA-MSG
                           PERFORM 1310-SEND-APP3
                   END-EVALUATE
               ELSE
                   MOVE 'MAP RECEIVE ERROR' TO CA-MSG
                   PERFORM 1310-SEND-APP3
               END-IF
           ELSE
               MOVE 'ENTER PRODUCT AND KYC DATA' TO CA-MSG
               PERFORM 1310-SEND-APP3
           END-IF
           .

      ******************************************************************
      * 1310-SEND-APP3: POPULATE AND SEND PAGE 3                         *
      ******************************************************************
       1310-SEND-APP3.
           INITIALIZE BACAPP3O
           MOVE CA-APP-ACCOUNT-TYPE   TO B3ACCTYPO
           MOVE CA-APP-CURRENCY       TO B3CURNCYO
           IF CA-APP-INITIAL-DEPOSIT NOT = ZEROS
               MOVE CA-APP-INITIAL-DEPOSIT TO WS-EDIT-AMOUNT
               MOVE WS-EDIT-AMOUNT       TO B3INITDPO
           END-IF
           MOVE CA-APP-SOURCE-OF-FUNDS TO B3SRCFNDO
           MOVE CA-APP-RISK-RATING    TO B3RISKRTO
           MOVE CA-APP-PEP-FLAG       TO B3PEPFLGO
           MOVE CA-APP-SANCTIONS-FLAG TO B3SANFLGO
           MOVE CA-APP-DOCS-RECEIVED  TO B3DOCRECO
           MOVE CA-APP-BOARD-RESOLUTION TO B3BOARDRESO
           MOVE CA-APP-UBO-DECLARATION TO B3UBOFLGO
           IF CA-APP-EXPECTED-TXN-AMT NOT = ZEROS
               MOVE CA-APP-EXPECTED-TXN-AMT TO WS-EDIT-AMOUNT
               MOVE WS-EDIT-AMOUNT       TO B3EXPTXAO
           END-IF
           MOVE CA-MSG                TO B3MSGO
           EXEC CICS SEND
               MAP('BACAPP3')
               MAPSET(WS-MAPSET-NAME)
               FROM(BACAPP3O)
               ERASE
           END-EXEC
           .

      ******************************************************************
      * 1320-MAP-APP3-TO-COMMAREA: MOVE SCREEN FIELDS TO COMMAREA      *
      ******************************************************************
       1320-MAP-APP3-TO-COMMAREA.
           MOVE B3ACCTYPI             TO CA-APP-ACCOUNT-TYPE
           MOVE B3CURNCYI             TO CA-APP-CURRENCY
           COMPUTE CA-APP-INITIAL-DEPOSIT = FUNCTION NUMVAL(B3INITDPI)
           MOVE B3SRCFNDI             TO CA-APP-SOURCE-OF-FUNDS
           MOVE B3RISKRTI             TO CA-APP-RISK-RATING
           MOVE B3PEPFLGI             TO CA-APP-PEP-FLAG
           MOVE B3SANFLGI             TO CA-APP-SANCTIONS-FLAG
           MOVE B3DOCRECI             TO CA-APP-DOCS-RECEIVED
           MOVE B3BOARDRESI           TO CA-APP-BOARD-RESOLUTION
           MOVE B3UBOFLGI             TO CA-APP-UBO-DECLARATION
           COMPUTE CA-APP-EXPECTED-TXN-AMT = FUNCTION NUMVAL(B3EXPTXAI)
           .

      ******************************************************************
      * 1330-VALIDATE-APP3: PRODUCT AND KYC VALIDATION                 *
      ******************************************************************
       1330-VALIDATE-APP3.
           SET WS-IS-VALID TO TRUE
           IF NOT (CA-APP-AT-CHECKING OR CA-APP-AT-SAVINGS OR
                   CA-APP-AT-MONEYMRKT OR CA-APP-AT-TDEPOSIT)
               SET WS-IS-INVALID TO TRUE
               MOVE WS-ERR-ENTRY (7) TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           IF CA-APP-CURRENCY = SPACES
               MOVE 'CURRENCY REQUIRED' TO CA-MSG
               SET WS-IS-INVALID TO TRUE
               EXIT PARAGRAPH
           END-IF
           IF CA-APP-INITIAL-DEPOSIT < 0
               SET WS-IS-INVALID TO TRUE
               MOVE WS-ERR-ENTRY (8) TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           IF NOT (CA-APP-RISK-LOW OR CA-APP-RISK-MEDIUM OR
                   CA-APP-RISK-HIGH)
               SET WS-IS-INVALID TO TRUE
               MOVE 'RISK RATING LO/MD/HI' TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           IF CA-APP-PEP-FLAG = 'Y' OR CA-APP-SANCTIONS-FLAG = 'Y'
               SET WS-IS-INVALID TO TRUE
               MOVE WS-ERR-ENTRY (10) TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           IF CA-APP-DOCS-RECEIVED = 'N' OR
              CA-APP-BOARD-RESOLUTION = 'N' OR
              CA-APP-UBO-DECLARATION = 'N'
               SET WS-IS-INVALID TO TRUE
               MOVE WS-ERR-ENTRY (9) TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           .

      ******************************************************************
      * 1400-PROCESS-APP4: SIGNATORY / UBO PAGE                        *
      ******************************************************************
       1400-PROCESS-APP4.
           IF EIBCALEN > 0 AND NOT CA-FIRST-TIME
               EXEC CICS RECEIVE
                   MAP('BACAPP4')
                   MAPSET(WS-MAPSET-NAME)
                   INTO(BACAPP4I)
                   RESP(WS-RESP-CODE)
               END-EXEC
               IF WS-RESP-CODE = DFHRESP(NORMAL)
                   EVALUATE EIBAID
                       WHEN DFHPF3
                           MOVE 0 TO CA-SCREEN
                           PERFORM 1010-SEND-MENU
                       WHEN DFHPF7
                           MOVE 13 TO CA-SCREEN
                           PERFORM 1310-SEND-APP3
                       WHEN DFHPF8
                           PERFORM 1420-MAP-APP4-TO-COMMAREA
                           PERFORM 1430-VALIDATE-APP4
                           IF WS-IS-VALID
                               MOVE 15 TO CA-SCREEN
                               PERFORM 1510-SEND-REVIEW
                           ELSE
                               PERFORM 1410-SEND-APP4
                           END-IF
                       WHEN DFHENTER
                           PERFORM 1420-MAP-APP4-TO-COMMAREA
                           PERFORM 1430-VALIDATE-APP4
                           IF WS-IS-VALID
                               MOVE 15 TO CA-SCREEN
                               PERFORM 1510-SEND-REVIEW
                           ELSE
                               PERFORM 1410-SEND-APP4
                           END-IF
                       WHEN OTHER
                           MOVE 'PF3=EXIT PF7=BACK PF8=REVIEW' TO CA-MSG
                           PERFORM 1410-SEND-APP4
                   END-EVALUATE
               ELSE
                   MOVE 'MAP RECEIVE ERROR' TO CA-MSG
                   PERFORM 1410-SEND-APP4
               END-IF
           ELSE
               MOVE 'ENTER AUTHORIZED SIGNATORY' TO CA-MSG
               PERFORM 1410-SEND-APP4
           END-IF
           .

      ******************************************************************
      * 1410-SEND-APP4: POPULATE AND SEND PAGE 4                         *
      ******************************************************************
       1410-SEND-APP4.
           INITIALIZE BACAPP4O
           MOVE CS-SIG-NAME           TO B4SIGNAMO
           MOVE CS-SIG-TITLE          TO B4SIGTTLO
           MOVE CS-SIG-DOB            TO B4SIGDOBO
           MOVE CS-SIG-SSN            TO B4SIGSSNO
           MOVE CS-SIG-ADDR-LINE1     TO B4SIGADR1O
           MOVE CS-SIG-ADDR-CITY      TO B4SIGCTYO
           MOVE CS-SIG-ADDR-STATE     TO B4SIGSTO
           MOVE CS-SIG-ADDR-ZIP       TO B4SIGZIPO
           MOVE CS-SIG-PHONE          TO B4SIGPHNO
           IF CS-SIG-OWNERSHIP-PCT NOT = ZEROS
               MOVE CS-SIG-OWNERSHIP-PCT TO WS-EDIT-PCT
               MOVE WS-EDIT-PCT          TO B4SIGOWNO
           END-IF
           MOVE CS-SIG-TYPE           TO B4SIGTYPO
           MOVE CS-SIG-ID-TYPE        TO B4SIGIDTO
           MOVE CS-SIG-ID-NUMBER      TO B4SIGIDNO
           MOVE CA-MSG                TO B4MSGO
           EXEC CICS SEND
               MAP('BACAPP4')
               MAPSET(WS-MAPSET-NAME)
               FROM(BACAPP4O)
               ERASE
           END-EXEC
           .

      ******************************************************************
      * 1420-MAP-APP4-TO-COMMAREA: MOVE SCREEN FIELDS TO COMMAREA       *
      ******************************************************************
       1420-MAP-APP4-TO-COMMAREA.
           MOVE B4SIGNAMI             TO CS-SIG-NAME
           MOVE B4SIGTTLI             TO CS-SIG-TITLE
           MOVE B4SIGDOBI             TO CS-SIG-DOB
           MOVE B4SIGSSNI             TO CS-SIG-SSN
           MOVE B4SIGADR1I            TO CS-SIG-ADDR-LINE1
           MOVE B4SIGCTYI             TO CS-SIG-ADDR-CITY
           MOVE B4SIGSTI              TO CS-SIG-ADDR-STATE
           MOVE B4SIGZIPI             TO CS-SIG-ADDR-ZIP
           MOVE B4SIGPHNI             TO CS-SIG-PHONE
           COMPUTE CS-SIG-OWNERSHIP-PCT = FUNCTION NUMVAL(B4SIGOWNI)
           MOVE B4SIGTYPI             TO CS-SIG-TYPE
           MOVE B4SIGIDTI             TO CS-SIG-ID-TYPE
           MOVE B4SIGIDNI             TO CS-SIG-ID-NUMBER
           .

      ******************************************************************
      * 1430-VALIDATE-APP4: SIGNATORY VALIDATION                       *
      ******************************************************************
       1430-VALIDATE-APP4.
           SET WS-IS-VALID TO TRUE
           IF CS-SIG-NAME = SPACES OR
              CS-SIG-DOB = SPACES OR
              CS-SIG-TYPE = SPACES
               SET WS-IS-INVALID TO TRUE
               MOVE 'SIGNATORY NAME/DOB/TYPE REQUIRED' TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           IF CS-SIG-TYPE NOT = 'A' AND CS-SIG-TYPE NOT = 'B'
               SET WS-IS-INVALID TO TRUE
               MOVE 'TYPE A=AUTHORIZED B=BENEFICIAL' TO CA-MSG
               EXIT PARAGRAPH
           END-IF
           .

      ******************************************************************
      * 1500-PROCESS-REVIEW: REVIEW AND SUBMIT                         *
      ******************************************************************
       1500-PROCESS-REVIEW.
           IF EIBCALEN > 0 AND NOT CA-FIRST-TIME
               EXEC CICS RECEIVE
                   MAP('BACREVU')
                   MAPSET(WS-MAPSET-NAME)
                   INTO(BACREVUI)
                   RESP(WS-RESP-CODE)
               END-EXEC
               IF WS-RESP-CODE = DFHRESP(NORMAL)
                   EVALUATE EIBAID
                       WHEN DFHPF3
                           MOVE 0 TO CA-SCREEN
                           PERFORM 1010-SEND-MENU
                       WHEN DFHPF7
                           MOVE 14 TO CA-SCREEN
                           PERFORM 1410-SEND-APP4
                       WHEN DFHPF5
                           PERFORM 1520-SUBMIT-APPLICATION
                       WHEN DFHENTER
                           IF RVSUBAPPI = 'Y'
                               PERFORM 1520-SUBMIT-APPLICATION
                           ELSE
                               MOVE 'ENTER Y TO SUBMIT' TO CA-MSG
                               PERFORM 1510-SEND-REVIEW
                           END-IF
                       WHEN OTHER
                           MOVE 'PF3=EXIT PF5=SUBMIT PF7=EDIT' TO CA-MSG
                           PERFORM 1510-SEND-REVIEW
                   END-EVALUATE
               ELSE
                   MOVE 'MAP RECEIVE ERROR' TO CA-MSG
                   PERFORM 1510-SEND-REVIEW
               END-IF
           ELSE
               PERFORM 1510-SEND-REVIEW
           END-IF
           .

      ******************************************************************
      * 1510-SEND-REVIEW: POPULATE REVIEW SUMMARY                      *
      ******************************************************************
       1510-SEND-REVIEW.
           INITIALIZE BACREVUO
           MOVE 'REVIEW'              TO CA-MSG
           MOVE CA-APP-ID             TO RVAPPIDO
           MOVE CA-APP-BUSINESS-NAME  TO RVBUSNAMO
           MOVE CA-APP-ACCOUNT-TYPE   TO RVACCTYPO
           IF CA-APP-INITIAL-DEPOSIT NOT = ZEROS
               MOVE CA-APP-INITIAL-DEPOSIT TO WS-EDIT-AMOUNT
               MOVE WS-EDIT-AMOUNT       TO RVINITDPO
           END-IF
           MOVE CA-APP-RISK-RATING    TO RVRISKRTO
           MOVE CA-APP-PEP-FLAG       TO RVPEPFLGO
           MOVE CA-APP-SANCTIONS-FLAG TO RVSANFLGO
           MOVE CA-APP-DOCS-RECEIVED  TO RVDOCRECO
           IF CA-APP-PEP-FLAG = 'Y' OR CA-APP-SANCTIONS-FLAG = 'Y'
               MOVE 'N'               TO RVCRDREQO
               MOVE 'NOT ELIGIBLE'    TO RVCRDTLO
           ELSE
               MOVE 'Y'               TO RVCRDREQO
               MOVE 'DC / 2,500.00 DAILY' TO RVCRDTLO
           END-IF
           MOVE 'N'                   TO RVSUBAPPO
           MOVE CA-MSG                TO RVMSGO
           EXEC CICS SEND
               MAP('BACREVU')
               MAPSET(WS-MAPSET-NAME)
               FROM(BACREVUO)
               ERASE
           END-EXEC
           .

      ******************************************************************
      * 1520-SUBMIT-APPLICATION: PERSIST TO DB2 AND SEND CONFIRMATION   *
      ******************************************************************
       1520-SUBMIT-APPLICATION.
           PERFORM 1530-GENERATE-APP-ID
           PERFORM 1540-SET-DECISION

           EXEC SQL
               INSERT INTO TB_BAC_APPLICATION
               (APP_ID, APP_STATUS, BUSINESS_NAME, TRADE_NAME,
                REGISTRATION_NO, TAX_ID, INCORP_DATE, BUSINESS_TYPE,
                INDUSTRY_CODE, ANNUAL_REVENUE, EMPLOYEE_COUNT,
                ADDR_LINE1, ADDR_LINE2, CITY, STATE, COUNTRY, ZIP_CODE,
                PHONE, EMAIL, CONTACT_NAME, ACCOUNT_TYPE, CURRENCY,
                INITIAL_DEPOSIT, EXPECTED_TXN_VOL, EXPECTED_TXN_AMT,
                SOURCE_OF_FUNDS, RISK_RATING, PEP_FLAG,
                SANCTIONS_FLAG, DOCS_RECEIVED, BOARD_RESOLUTION,
                UBO_DECLARATION, MAKER_ID, CHECKER_ID,
                CREATED_TIMESTAMP, UPDATED_TIMESTAMP, ACCOUNT_NUMBER,
                BRANCH_CODE, REJECTION_REASON,
                CARD_REQUESTED, CARD_TYPE, CARD_DAILY_LIMIT,
                CARD_ATM_LIMIT, CARD_MONTHLY_LIMIT, CARD_EMBOSS_NAME)
               VALUES
               (:CA-APP-ID, :CA-APP-STATUS, :CA-APP-BUSINESS-NAME,
                :CA-APP-TRADE-NAME, :CA-APP-REGISTRATION-NO,
                :CA-APP-TAX-ID, :CA-APP-INCORP-DATE,
                :CA-APP-BUSINESS-TYPE, :CA-APP-INDUSTRY-CODE,
                :CA-APP-ANNUAL-REVENUE, :CA-APP-EMPLOYEE-COUNT,
                :CA-APP-ADDR-LINE1, :CA-APP-ADDR-LINE2,
                :CA-APP-ADDR-CITY, :CA-APP-ADDR-STATE,
                :CA-APP-ADDR-COUNTRY, :CA-APP-ADDR-ZIP,
                :CA-APP-PHONE, :CA-APP-EMAIL, :CA-APP-CONTACT-NAME,
                :CA-APP-ACCOUNT-TYPE, :CA-APP-CURRENCY,
                :CA-APP-INITIAL-DEPOSIT, :CA-APP-EXPECTED-TXN-VOL,
                :CA-APP-EXPECTED-TXN-AMT, :CA-APP-SOURCE-OF-FUNDS,
                :CA-APP-RISK-RATING, :CA-APP-PEP-FLAG,
                :CA-APP-SANCTIONS-FLAG, :CA-APP-DOCS-RECEIVED,
                :CA-APP-BOARD-RESOLUTION, :CA-APP-UBO-DECLARATION,
                :CA-APP-MAKER-ID, :CA-APP-CHECKER-ID,
                :CA-APP-CREATED-TIMESTAMP, :CA-APP-UPDATED-TIMESTAMP,
                :CA-APP-ACCOUNT-NUMBER, :CA-APP-BRANCH-CODE,
                :CA-APP-REJECTION-REASON,
                :CA-APP-CARD-REQUESTED, :CA-APP-CARD-TYPE,
                :CA-APP-CARD-DAILY-LIMIT, :CA-APP-CARD-ATM-LIMIT,
                :CA-APP-CARD-MONTHLY-LIMIT, :CA-APP-CARD-EMBOSS-NAME)
           END-EXEC

           IF SQLCODE = 0
               IF CA-APP-STATUS NOT = 'RJ'
                   PERFORM 1550-INSERT-SIGNATORY
                   PERFORM 1560-INSERT-AUDIT
               END-IF
               MOVE 16 TO CA-SCREEN
               MOVE WS-ERR-ENTRY (15) TO CA-MSG
               PERFORM 1610-SEND-CONFIRM
           ELSE
               MOVE WS-ERR-ENTRY (12) TO CA-MSG
               MOVE 15 TO CA-SCREEN
               PERFORM 1510-SEND-REVIEW
           END-IF
           .

      ******************************************************************
      * 1530-GENERATE-APP-ID: GET NEXT SEQUENCE AND FORMAT APP-ID       *
      ******************************************************************
       1530-GENERATE-APP-ID.
           EXEC SQL
               SELECT NEXT VALUE FOR BAC_APP_SEQ
               INTO :WS-HV-APP-SEQ
               FROM SYSIBM.SYSDUMMY1
           END-EXEC

           COMPUTE WS-HV-APP-SEQ-ZERO = WS-HV-APP-SEQ
           STRING 'APP' WS-HV-APP-SEQ-ZERO
               DELIMITED BY SIZE
               INTO CA-APP-ID
           END-STRING

           MOVE CA-USER-ID            TO CA-APP-MAKER-ID
           MOVE 'BR0001'              TO CA-APP-BRANCH-CODE

           EXEC SQL
               SELECT CURRENT TIMESTAMP
               INTO :CA-APP-CREATED-TIMESTAMP
               FROM SYSIBM.SYSDUMMY1
           END-EXEC
           MOVE CA-APP-CREATED-TIMESTAMP TO CA-APP-UPDATED-TIMESTAMP
           .

      ******************************************************************
      * 1540-SET-DECISION: SET APPLICATION STATUS BASED ON KYC          *
      ******************************************************************
       1540-SET-DECISION.
           IF CA-APP-PEP-FLAG = 'Y' OR CA-APP-SANCTIONS-FLAG = 'Y'
               MOVE 'RJ' TO CA-APP-STATUS
               MOVE 'PEP / SANCTIONS HIT - APPLICATION REJECTED'
                   TO CA-APP-REJECTION-REASON
           ELSE
               IF CA-APP-DOCS-RECEIVED = 'N' OR
                  CA-APP-BOARD-RESOLUTION = 'N' OR
                  CA-APP-UBO-DECLARATION = 'N'
                   MOVE 'KY' TO CA-APP-STATUS
               ELSE
                   MOVE 'SB' TO CA-APP-STATUS
               END-IF
           END-IF

      *    DEFAULT DEBIT CARD REQUEST FOR ELIGIBLE APPLICATIONS
           IF CA-APP-STATUS NOT = 'RJ'
               MOVE 'Y'                     TO CA-APP-CARD-REQUESTED
               MOVE 'DC'                    TO CA-APP-CARD-TYPE
               MOVE 2500.00               TO CA-APP-CARD-DAILY-LIMIT
               MOVE 1000.00               TO CA-APP-CARD-ATM-LIMIT
               MOVE 25000.00              TO CA-APP-CARD-MONTHLY-LIMIT
               MOVE CA-APP-CONTACT-NAME   TO CA-APP-CARD-EMBOSS-NAME
           END-IF
           .

      ******************************************************************
      * 1550-INSERT-SIGNATORY: PERSIST AUTHORIZED SIGNATORY            *
      ******************************************************************
       1550-INSERT-SIGNATORY.
           EXEC SQL
               SELECT NEXT VALUE FOR BAC_SIG_SEQ
               INTO :WS-HV-SIG-SEQ
               FROM SYSIBM.SYSDUMMY1
           END-EXEC

           COMPUTE WS-HV-SIG-SEQ-ZERO = WS-HV-SIG-SEQ
           STRING 'SIG' WS-HV-SIG-SEQ-ZERO
               DELIMITED BY SIZE
               INTO CS-SIG-ID
           END-STRING

           MOVE CA-APP-ID             TO CS-SIG-APP-ID
           MOVE CA-APP-CREATED-TIMESTAMP TO CS-SIG-CREATED-TIMESTAMP
           MOVE CA-APP-CREATED-TIMESTAMP TO CS-SIG-UPDATED-TIMESTAMP

           EXEC SQL
               INSERT INTO TB_BAC_SIGNATORY
               (SIG_ID, APP_ID, CUST_ID, NAME, TITLE, DOB, SSN,
                ADDR_LINE1, ADDR_LINE2, CITY, STATE, COUNTRY, ZIP_CODE,
                PHONE, EMAIL, OWNERSHIP_PCT, SIG_TYPE, ID_TYPE,
                ID_NUMBER, CREATED_TIMESTAMP, UPDATED_TIMESTAMP)
               VALUES
               (:CS-SIG-ID, :CS-SIG-APP-ID, :CS-SIG-CUST-ID,
                :CS-SIG-NAME, :CS-SIG-TITLE, :CS-SIG-DOB, :CS-SIG-SSN,
                :CS-SIG-ADDR-LINE1, :CS-SIG-ADDR-LINE2,
                :CS-SIG-ADDR-CITY, :CS-SIG-ADDR-STATE,
                :CS-SIG-ADDR-COUNTRY, :CS-SIG-ADDR-ZIP,
                :CS-SIG-PHONE, :CS-SIG-EMAIL, :CS-SIG-OWNERSHIP-PCT,
                :CS-SIG-TYPE, :CS-SIG-ID-TYPE, :CS-SIG-ID-NUMBER,
                :CS-SIG-CREATED-TIMESTAMP, :CS-SIG-UPDATED-TIMESTAMP)
           END-EXEC
           .

      ******************************************************************
      * 1560-INSERT-AUDIT: PERSIST STATUS CHANGE AUDIT RECORD            *
      ******************************************************************
       1560-INSERT-AUDIT.
           MOVE SPACES                TO AU-STATUS-FROM
           MOVE CA-APP-STATUS         TO AU-STATUS-TO
           MOVE CA-USER-ID            TO AU-USER-ID
           MOVE CA-APP-ID             TO AU-APP-ID
           MOVE 'CR'                  TO AU-ACTION-TYPE
           MOVE 'APPLICATION CREATED' TO AU-REMARKS
           MOVE CA-APP-CREATED-TIMESTAMP TO AU-ACTION-TIMESTAMP

           EXEC SQL
               INSERT INTO TB_BAC_AUDIT
               (APP_ID, STATUS_FROM, STATUS_TO, USER_ID,
                ACTION_TIMESTAMP, ACTION_TYPE, REMARKS)
               VALUES
               (:AU-APP-ID, :AU-STATUS-FROM, :AU-STATUS-TO,
                :AU-USER-ID, :AU-ACTION-TIMESTAMP,
                :AU-ACTION-TYPE, :AU-REMARKS)
           END-EXEC
           .

      ******************************************************************
      * 1600-PROCESS-CONFIRM: CONFIRMATION SCREEN                      *
      ******************************************************************
       1600-PROCESS-CONFIRM.
           IF EIBCALEN > 0 AND NOT CA-FIRST-TIME
               EXEC CICS RECEIVE
                   MAP('BACCONF')
                   MAPSET(WS-MAPSET-NAME)
                   INTO(BACCONFI)
                   RESP(WS-RESP-CODE)
               END-EXEC
           END-IF
           PERFORM 1610-SEND-CONFIRM
           .

      ******************************************************************
      * 1610-SEND-CONFIRM: DISPLAY APPLICATION ID AND STATUS           *
      ******************************************************************
       1610-SEND-CONFIRM.
           INITIALIZE BACCONFO
           MOVE CA-APP-ID             TO CFAPPIDO
           MOVE CA-APP-STATUS         TO CFSTATUSO
           IF CA-APP-STATUS = 'RJ'
               MOVE 'APPLICATION REJECTED - SEE AUDIT' TO CFMSGO
           ELSE
               IF CA-APP-CARD-REQUESTED = 'Y'
                   STRING 'APP SUBMITTED - '
                          CA-APP-CARD-TYPE
                          ' CARD REQUESTED'
                       DELIMITED BY SIZE
                       INTO CFMSGO
                   END-STRING
               ELSE
                   MOVE 'APPLICATION SUBMITTED SUCCESSFULLY' TO CFMSGO
               END-IF
           END-IF
           EXEC CICS SEND
               MAP('BACCONF')
               MAPSET(WS-MAPSET-NAME)
               FROM(BACCONFO)
               ERASE
           END-EXEC
           .

      ******************************************************************
      * 9900-EXIT-CICS: CLEAN EXIT                                     *
      ******************************************************************
       9900-EXIT-CICS.
           EXEC CICS SEND TEXT
               FROM('THANK YOU - BUSINESS BANKING PORTAL')
               LENGTH(40)
               ERASE
           END-EXEC
           EXEC CICS RETURN END-EXEC
           .
