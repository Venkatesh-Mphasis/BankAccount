//BACVSMJ  JOB 1,'DEFINE VSAM CLUSTERS',CLASS=A,MSGCLASS=H,          J0000001
//             NOTIFY=&SYSUID,REGION=0M
//********************************************************************
//* JOB: DEFINE VSAM KSDS CLUSTERS FOR BACKUP / SETTLEMENT FILES     *
//********************************************************************
//DEFINE   EXEC PGM=IDCAMS
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  *
    DEFINE CLUSTER (NAME(HLQ.BANK.VSAM.BACAPP) -
           CISZ(4096) -
           TRK(5 5) -
           RECORDSIZE(712 712) -
           KEYS(10 0) -
           INDEXED)

    DEFINE CLUSTER (NAME(HLQ.BANK.VSAM.BACCUST) -
           CISZ(4096) -
           TRK(5 5) -
           RECORDSIZE(527 527) -
           KEYS(10 0) -
           INDEXED)

    DEFINE CLUSTER (NAME(HLQ.BANK.VSAM.BACACC) -
           CISZ(2048) -
           TRK(3 3) -
           RECORDSIZE(194 194) -
           KEYS(12 0) -
           INDEXED)

    DEFINE CLUSTER (NAME(HLQ.BANK.VSAM.BACSIG) -
           CISZ(4096) -
           TRK(3 3) -
           RECORDSIZE(452 452) -
           KEYS(10 0) -
           INDEXED)
//
