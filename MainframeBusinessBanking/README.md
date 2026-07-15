# Mainframe Business Banking Account Creation Portal

A complete mainframe-style **business banking account creation** application.

* **CICS/BMS online portal** (transaction `BA01`) for entering business applications
* **COBOL batch** nightly account-opening job
* **DB2** relational model for applications, customers, signatories, accounts, documents, and audit
* **VSAM** definitions for legacy KSDS interfaces
* **JCL** compile, bind, VSAM, and run jobs
* **GnuCOBOL local port** that builds and runs end-to-end without a mainframe

## Repository Structure

```
MainframeBusinessBanking/
├── BMS/               - BMS mapset (BACMAPS.bms)
├── COBOL/
│   ├── CICS/          - CICS online program (BACONL01.cbl)
│   └── BATCH/         - Batch account-opening program (BACBAT01.cbl)
├── COPYBOOK/          - COBOL copybooks for records, COMMAREA, errors, common areas
├── DB2/
│   ├── DDL/           - Table, index, and sequence creation SQL
│   └── DML/           - Sample inserts and inquiry SQL
├── JCL/               - Compile, bind, VSAM, batch run jobs
├── VSAM/              - IDCAMS definitions
├── LOCAL/             - GnuCOBOL demonstration
│   ├── COBOL/         - Local generator, online, batch sources
│   ├── DATA/          - Input request file
│   ├── OUTPUT/        - Runtime outputs
│   ├── BIN/           - Compiled binaries
│   ├── build.sh       - Compile all local programs
│   └── run.sh         - Run the local demo pipeline
└── DOC/
    └── REQUIREMENTS.md - Real-world business banking requirements
```

## Mainframe Components

### CICS Online Program

* **Transaction:** `BA01`
* **Program:** `BACONL01`
* **Mapset:** `BACMAPS` (menu, 4 application data screens, review, confirmation, inquiry, approval)

The online program walks a teller/operations user through a multi-screen flow:

1. Menu / dashboard
2. Business identification
3. Address and contact
4. Product and KYC details
5. Authorized signatories and beneficial owners
6. Review and submit
7. Confirmation

It validates PEP/sanctions flags, document checklist, and risk rating before submission. Submitted records are inserted into `TB_BAC_APPLICATION`, `TB_BAC_SIGNATORY`, `TB_BAC_DOCUMENT`, and `TB_BAC_AUDIT`.

### Batch Account Opening

* **Program:** `BACBAT01`
* **Tables:** `TB_BAC_APPLICATION`, `TB_BAC_CUSTOMER`, `TB_BAC_ACCOUNT`, `TB_BAC_AUDIT`

`BACBAT01` opens a cursor over submitted/approved applications, creates a customer and account for each, updates the application status to `OP`, writes an audit row, and produces an account-opening report.

### DB2 Schema

| Table | Purpose |
|-------|---------|
| `TB_BAC_APPLICATION` | Master application header |
| `TB_BAC_CUSTOMER` | Opened customer master |
| `TB_BAC_SIGNATORY` | Authorized signatories / beneficial owners |
| `TB_BAC_ACCOUNT` | Opened account master |
| `TB_BAC_DOCUMENT` | KYC document checklist |
| `TB_BAC_AUDIT` | Status change audit trail |

Sequences `BAC_APP_SEQ`, `BAC_SIG_SEQ`, `BAC_CUST_SEQ`, and `BAC_ACC_SEQ` generate surrogate IDs.

## Local GnuCOBOL Demonstration

The `LOCAL/` directory contains a fully working demonstration that can be built and run on any Linux/macOS/Windows machine with GnuCOBOL installed.

> **Note:** The local demonstration uses sequential files because the packaged GnuCOBOL in this environment was built without an indexed-file handler. The mainframe source itself targets DB2/VSAM.

### Build

```bash
cd LOCAL
bash build.sh
```

### Run

```bash
bash run.sh
```

### What `run.sh` does

1. `BACGEND` - creates sample application and signatory master files
2. `BACONL01` - simulates the CICS online portal, creates a new application, and answers an inquiry
3. `BACBAT01` - processes submitted/approved applications, creates customer and account records, and writes `OUTPUT/ACCOUNT_OPEN_RPT.txt`

### Expected Output

```text
APP CREATED: APP0000004 STATUS: SB BUSINESS: Riverfront Tech Inc
INQUIRY APP: APP0000001 STATUS: SB ACCT TYPE: CH DEPOSIT: 50,000.00

... batch output ...

 APP-ID     CUST-ID    ACCOUNT-NUM  BUSINESS-NAME
  APP0000001   CUST000001   000101000016   Acme Manufacturing LLC           CH       50,000.00  OP
```

## Real-World Banking Requirements Covered

See `DOC/REQUIREMENTS.md` for the full list. Highlights include:

* Business identification and legal documentation
* Authorized signatory and beneficial owner capture
* PEP / sanctions screening
* Document checklist and KYC controls
* Risk rating
* Maker-checker workflow
* Audit trail
* Account number generation with check digit

## Build / Deploy on Mainframe

1. Run `DB2/DDL/*.sql` to create tables, indexes, and sequences.
2. Optionally run `DB2/DML/INSBAC01.sql` for sample data.
3. Submit `JCL/BACCBLJC.jcl` to compile the CICS program.
4. Submit `JCL/BACCBLJB.jcl` to compile the batch program.
5. Submit `JCL/BACBINDJ.jcl` to bind the DB2 packages and plan.
6. Submit `JCL/BACVSMJ.jcl` to define VSAM clusters.
7. Submit `JCL/BACBATJ.jcl` to run the batch account-opening job.
8. Define CICS transaction `BA01` program `BACONL01` and mapset `BACMAPS`.

## Author / Target

Repository created for the **Venkatesh-Mphasis** GitHub account.
