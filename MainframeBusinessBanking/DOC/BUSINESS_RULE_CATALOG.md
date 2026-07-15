# Business Rule Catalog - Mainframe Business Banking Account Creation

A complete, source-derived catalog of the COBOL business-banking portal.

Scope:

- `COBOL/CICS/BACONL01.cbl` (transaction `BA01`) - online multi-screen application capture
- `COBOL/BATCH/BACBAT01.cbl` - nightly account/card opening batch
- `LOCAL/COBOL/BACONL01.cbl` / `BACGEND.cbl` / `BACBAT01.cbl` - GnuCOBOL demonstration
- `BMS/BACMAPS.bms` - 3270 screen definitions
- `COPYBOOK/CPYBAC*.cpy` - record, COMMAREA, and error layouts
- `DB2/DDL/*.sql`, `DB2/DML/*.sql` - relational model
- `JCL/*.jcl` - z/OS build, bind, run, and VSAM definitions

---

## 1. Modules

| Module | Type | Language | Transaction / Job | Purpose |
|--------|------|----------|-------------------|---------|
| `BACONL01` | CICS online | COBOL | `BA01` / mapset `BACMAPS` | Multi-screen business-account application capture, validation, and persistence to DB2 |
| `BACBAT01` | Batch COBOL | COBOL | `BACBATJ.jcl` | Reads submitted/approved applications, creates customer, account, and optional debit card |
| `BACGEND` | Generator | GnuCOBOL | `LOCAL/run.sh` | Creates sample sequential files used by the local demo |
| `LOCAL/BACONL01` | Online simulation | GnuCOBOL | `LOCAL/run.sh` | File-driven simulation of the CICS online flow |
| `LOCAL/BACBAT01` | Batch simulation | GnuCOBOL | `LOCAL/run.sh` | Sequential-file version of the account/card opening batch |
| `BACMAPS.bms` | BMS mapset | BMS macro | `BA01`, `BA02`, `BA03` | 3270 screens: menu, 4 application pages, review, confirmation, inquiry, approval |

**Key copybooks**

| Copybook | Purpose | Used by |
|----------|---------|---------|
| `CPYBAC00` | CICS `DFHCOMMAREA` layout (`WS-BAC-COMMAREA`) | `BACONL01` |
| `CPYBAC01` | Application master record (`TB_BAC_APPLICATION`) | `BACONL01`, `BACBAT01`, `BACGEND` |
| `CPYBAC02` | Customer master record (`TB_BAC_CUSTOMER`) | `BACBAT01` |
| `CPYBAC03` | Signatory/beneficial owner record (`TB_BAC_SIGNATORY`) | `BACONL01`, `BACBAT01` |
| `CPYBAC04` | Account master record (`TB_BAC_ACCOUNT`) | `BACBAT01` |
| `CPYBAC05` | Document checklist record (`TB_BAC_DOCUMENT`) | Copybook exists; not directly written by `BACONL01` |
| `CPYBAC06` | Audit trail record (`TB_BAC_AUDIT`) | `BACONL01`, `BACBAT01` |
| `CPYBAC07` | Debit/prepaid card master record (`TB_BAC_CARD`) | `BACBAT01` |
| `CPYCOM01` | Common date/counter/flag work areas | All programs |
| `CPYERR01` | Error-message table (16 entries) | All programs |

---

## 2. Screen Flows (CICS transaction `BA01`)

`BACONL01` is a state machine driven by `CA-SCREEN` in the COMMAREA. `EIBCALEN` distinguishes the first invocation from a returning terminal interaction.

### 2.1 Navigation matrix

| Current screen (`CA-SCREEN`) | User action | Next screen | Paragraph |
|-----------------------------|-------------|-------------|-----------|
| 0 (Menu) | `1` | 11 | `1110-SEND-APP1` |
| 0 (Menu) | `2`/`3`/`4` | 0 (menu with message) | `1010-SEND-MENU` |
| 0 (Menu) | `5` or `PF3` | Exit | `9900-EXIT-CICS` |
| 11 (App 1) | `PF3` | 0 | `1010-SEND-MENU` |
| 11 (App 1) | `PF7` | 0 | `1010-SEND-MENU` |
| 11 (App 1) | `PF8` / `ENTER` | 12 if valid, else 11 | `1210-SEND-APP2` / `1110-SEND-APP1` |
| 12 (App 2) | `PF3` | 0 | `1010-SEND-MENU` |
| 12 (App 2) | `PF7` | 11 | `1110-SEND-APP1` |
| 12 (App 2) | `PF8` / `ENTER` | 13 if valid, else 12 | `1310-SEND-APP3` / `1210-SEND-APP2` |
| 13 (App 3) | `PF3` | 0 | `1010-SEND-MENU` |
| 13 (App 3) | `PF7` | 12 | `1210-SEND-APP2` |
| 13 (App 3) | `PF8` / `ENTER` | 14 if valid, else 13 | `1410-SEND-APP4` / `1310-SEND-APP3` |
| 14 (App 4) | `PF3` | 0 | `1010-SEND-MENU` |
| 14 (App 4) | `PF7` | 13 | `1310-SEND-APP3` |
| 14 (App 4) | `PF8` / `ENTER` | 15 if valid, else 14 | `1510-SEND-REVIEW` / `1410-SEND-APP4` |
| 15 (Review) | `PF3` | 0 | `1010-SEND-MENU` |
| 15 (Review) | `PF7` | 14 | `1410-SEND-APP4` |
| 15 (Review) | `PF5` | 16 after submit | `1610-SEND-CONFIRM` |
| 15 (Review) | `ENTER` | 16 if `RVSUBAPPI='Y'`, else 15 | `1610-SEND-CONFIRM` / `1510-SEND-REVIEW` |
| 16 (Confirm) | Any AID / new transaction | 0 | `1010-SEND-MENU` (next cycle) |

### 2.2 Screens and fields

`BACMENU` - Main dashboard / portal menu

- `MNOPT` - `1` new app, `2` pending inquiry, `3` approve/reject, `4` opened inquiry, `5` exit
- `MNMSG` - informational / error message line

`BACAPP1` - Business identification

- `B1BUSNAM` (40) - legal business name
- `B1TRDNAM` (40) - trade / DBA name
- `B1REGNO` (20) - registration/incorporation number
- `B1TAXID` (15) - tax ID / EIN / VAT
- `B1INCDAT` (10) - incorporation date
- `B1BUSTYP` (2) - business type code
- `B1INDCDE` (6) - industry / NAICS / SIC code
- `B1ANNREV` (15) - annual revenue (numeric, edited)
- `B1EMPCNT` (6) - employee count
- `B1PHONE` (15) - business phone
- `B1EMAIL` (40) - business email
- `B1MSG` - message line

`BACAPP2` - Address and contact

- `B2ADDRL1` (40), `B2ADDRL2` (40), `B2CITY` (25), `B2STATE` (2), `B2COUNTRY` (3), `B2ZIP` (10)
- `B2CONNAM` (40) - primary contact name
- `B2CONPHN` (15), `B2CONEML` (40) - contact phone/email

`BACAPP3` - Product, source of funds, KYC / compliance

- `B3ACCTYP` (2) - account type
- `B3CURNCY` (3) - currency
- `B3INITDP` (15) - initial deposit
- `B3SRCFND` (30) - source of funds
- `B3RISKRT` (2) - risk rating
- `B3PEPFLG` (1) - PEP flag (`Y`/`N`)
- `B3SANFLG` (1) - sanctions flag (`Y`/`N`)
- `B3DOCREC` (1) - documents received
- `B3BOARDRES` (1) - board resolution received
- `B3UBOFLG` (1) - UBO declaration received
- `B3EXPTXA` (15) - expected monthly transaction amount

`BACAPP4` - Authorized signatory / beneficial owner

- `B4SIGNAM` (50) - signatory name
- `B4SIGTTL` (30) - title
- `B4SIGDOB` (10) - date of birth
- `B4SIGSSN` (11) - SSN / national ID
- `B4SIGADR1` (40), `B4SIGCTY` (25), `B4SIGST` (2), `B4SIGZIP` (10)
- `B4SIGPHN` (15) - phone
- `B4SIGOWN` (6) - ownership percentage (for beneficial owners)
- `B4SIGTYP` (1) - `A` = authorized signatory, `B` = beneficial owner
- `B4SIGIDT` (10) - ID type (PASSPORT, DRIVERSLIC, etc.)
- `B4SIGIDN` (20) - ID number

`BACREVU` - Review and submit

- `RVAPPID` (10) - generated application ID (protected)
- `RVBUSNAM` (40), `RVACCTYP` (2), `RVINITDP` (15), `RVRISKRT` (2)
- `RVPEPFLG` (1), `RVSANFLG` (1), `RVDOCREC` (1)
- `RVCRDREQ` (1) - card requested
- `RVCRDTL` (25) - card type / default daily limit summary
- `RVSUBAPP` (1) - submit confirmation (`Y`)

`BACCONF` - Submission confirmation

- `CFAPPID` (10) - application ID
- `CFSTATUS` (2) - final status
- `CFMSG` (60) - result message

`BACINQ` - Inquiry (map defined; no `BACONL02` program in repository)

`BACAPPR` - Checker approval/rejection (map defined; no `BACAPPR` program in repository)

---

## 3. Validations

`BACONL01` validates each page before allowing forward navigation. `WS-IS-VALID` is reset at the start of each validation paragraph.

### 3.1 Page 1 - `1130-VALIDATE-APP1`

| Field / check | Rule | Error message source |
|---------------|------|----------------------|
| Business name | `NOT SPACES` | `WS-ERR-ENTRY(3)` - "BUSINESS NAME IS REQUIRED" |
| Tax ID | `NOT SPACES` | `WS-ERR-ENTRY(4)` - "TAX ID IS REQUIRED" |
| Registration number | `NOT SPACES` | `WS-ERR-ENTRY(5)` - "REGISTRATION NO IS REQUIRED" |
| Business type | Must be `LC`, `CP`, `PT`, `SP`, `NP`, or `TR` | `WS-ERR-ENTRY(6)` - "INVALID BUSINESS TYPE" |
| Annual revenue | `>= 0` | `WS-ERR-ENTRY(8)` - "INITIAL DEPOSIT MUST BE >= 0" |

### 3.2 Page 2 - `1230-VALIDATE-APP2`

| Field / check | Rule | Error message |
|---------------|------|---------------|
| Address line 1, city, country | All `NOT SPACES` | "ADDRESS LINE1/CITY/COUNTRY REQUIRED" |
| If country = `USA` or `US ` | State and ZIP must `NOT SPACES` | "STATE AND ZIP REQUIRED FOR USA" |

### 3.3 Page 3 - `1330-VALIDATE-APP3`

| Field / check | Rule | Error message |
|---------------|------|---------------|
| Account type | `CH`, `SV`, `MM`, or `TD` | `WS-ERR-ENTRY(7)` - "ACCOUNT TYPE IS REQUIRED" |
| Currency | `NOT SPACES` | "CURRENCY REQUIRED" |
| Initial deposit | `>= 0` | `WS-ERR-ENTRY(8)` - "INITIAL DEPOSIT MUST BE >= 0" |
| Risk rating | `LO`, `MD`, or `HI` | "RISK RATING LO/MD/HI" |
| PEP or sanctions flag | Both must not be `Y` | `WS-ERR-ENTRY(10)` - "PEP / SANCTIONS HIT REJECTED" |
| KYC documents | `DOCS_RECEIVED`, `BOARD_RESOLUTION`, and `UBO_DECLARATION` must all be `Y` | `WS-ERR-ENTRY(9)` - "KYC DOCUMENTS NOT RECEIVED" |

### 3.4 Page 4 - `1430-VALIDATE-APP4`

| Field / check | Rule | Error message |
|---------------|------|---------------|
| Signatory name, DOB, type | All `NOT SPACES` | "SIGNATORY NAME/DOB/TYPE REQUIRED" |
| Signatory type | `A` or `B` | "TYPE A=AUTHORIZED B=BENEFICIAL" |

### 3.5 Numeric parsing

- `B1ANNREV`, `B1EMPCNT`, `B3INITDP`, `B3EXPTXA`, and `B4SIGOWN` are converted with `FUNCTION NUMVAL`.
- Non-numeric user input will raise a run-time conversion error; there is no explicit `NUMVAL` error trapping in the current source.

---

## 4. Status Transitions

### 4.1 Application status domain

| Code | Meaning | Source of truth |
|------|---------|-----------------|
| `DR` | Draft | Copybook / DDL default |
| `SB` | Submitted | `BACONL01` decision logic; default submit status |
| `PE` | Pending | Domain value; not set by current code |
| `KY` | KYC Pending | `BACONL01` decision logic (unreachable from screen because validation requires all doc flags = `Y`) |
| `AP` | Approved | Domain value; set externally or by a future checker program |
| `RJ` | Rejected | `BACONL01` when PEP/sanctions hit |
| `OP` | Opened | `BACBAT01` after customer/account creation |

### 4.2 Decision logic in `1540-SET-DECISION` (CICS)

```cobol
IF PEP-FLAG = 'Y' OR SANCTIONS-FLAG = 'Y'
    STATUS = 'RJ'
    REJECTION-REASON = 'PEP / SANCTIONS HIT - APPLICATION REJECTED'
ELSE
    IF any KYC doc flag = 'N'
        STATUS = 'KY'
    ELSE
        STATUS = 'SB'
    END-IF
END-IF

IF STATUS NOT = 'RJ'
    CARD_REQUESTED = 'Y'
    CARD_TYPE = 'DC'
    CARD_DAILY_LIMIT = 2500.00
    CARD_ATM_LIMIT = 1000.00
    CARD_MONTHLY_LIMIT = 25000.00
    CARD_EMBOSS_NAME = CONTACT_NAME
END-IF
```

Because page-3 validation rejects any `N` doc flag, the `KY` path cannot be reached from the online flow. The `KY` value is therefore effectively only a data-loaded state.

### 4.3 State transition diagram

```
[none]
  |
  v
+---------+      PEP/SANCTIONS=Y      +---------+
|  NEW   | ----------------------------> |   RJ    |
| (CICS) |                                |Rejected |
+---------+                                +---------+
  |                                              ^
  | KYC docs all = Y                             |
  v                                              |
+---------+      Checker approves (future)  +---------+
|   SB    | --------------------------------> |   AP    |
|Submitted|                                |Approved |
+---------+                                +---------+
  |                                              |
  | Batch BACBAT01                               | Batch BACBAT01
  v                                              v
+---------+                                +---------+
|   OP    |                                |   OP    |
| Opened  |                                | Opened  |
+---------+                                +---------+
```

### 4.4 Card status domain (`TB_BAC_CARD`)

| Status | Code | Meaning |
|--------|------|---------|
| `RQ` | Requested | DDL default |
| `AP` | Approved | Domain value |
| `IS` | Issued | Set by `BACBAT01` at account opening |
| `BL` | Blocked | Domain value; not used |
| `CA` | Cancelled | Domain value; not used |

### 4.5 Card plastic status domain

| Status | Code | Meaning |
|--------|------|---------|
| `PE` | Pending | DDL default |
| `EM` | Embossed | Set by `BACBAT01` |
| `DI` | Dispatched | Domain value |
| `DE` | Delivered | Domain value |
| `DA` | Damaged / returned | Domain value |

### 4.6 Account status domain

| Code | Meaning |
|------|---------|
| `AC` | Active (set by `BACBAT01`) |
| `CL` | Closed |
| `FR` | Frozen |

---

## 5. Batch Logic

### 5.1 `BACBAT01` mainframe flow

1. Open report file (`RPTFILE`) and write header.
2. Declare cursor `C1` over `TB_BAC_APPLICATION` where `APP_STATUS IN ('SB','AP')` with `FOR UPDATE OF APP_STATUS, ACCOUNT_NUMBER, CHECKER_ID, UPDATED_TIMESTAMP`.
3. For each fetched application:
   - `ADD 1 TO WS-RECORDS-READ`
   - Save old status to `WS-OLD-STATUS`
   - `PERFORM 3000-OPEN-ACCOUNT`
4. Close cursor, commit, close report.

### 5.2 `3000-OPEN-ACCOUNT` (mainframe)

1. `3100-GET-NEXT-ACC-SEQ` - fetches `BAC_ACC_SEQ`.
2. `3200-GENERATE-ACCOUNT-NUMBER` - builds 12-digit account number.
3. `3100-GET-NEXT-CUST-SEQ` - fetches `BAC_CUST_SEQ`.
4. Build `WS-BAC-CUSTOMER-REC` from application fields, status `AC`.
5. `INSERT INTO TB_BAC_CUSTOMER`.
6. Build `WS-BAC-ACCOUNT-REC`, balance/available/initial-deposit set to application initial deposit, status `AC`.
7. `INSERT INTO TB_BAC_ACCOUNT`.
8. `UPDATE TB_BAC_APPLICATION` to `OP`, set `ACCOUNT_NUMBER`, `CHECKER_ID = 'BATCH01'`, `UPDATED_TIMESTAMP = CURRENT TIMESTAMP` where `CURRENT OF C1`.
9. If `CARD_REQUESTED = 'Y'`, `PERFORM 3300-ISSUE-DEBIT-CARD`.
10. Insert audit row: `STATUS_FROM = WS-OLD-STATUS`, `STATUS_TO = 'OP'`, `USER_ID = 'BATCH01'`, `ACTION_TYPE = 'AO'`, `REMARKS = 'ACCOUNT OPENED BY BATCH'`.
11. Write report line.
12. `ADD 1 TO WS-RECORDS-WRITTEN` and `WS-COMMIT-COUNT`. Commit every 10 records.

### 5.3 Account number generation (`3200-GENERATE-ACCOUNT-NUMBER`)

1. Product code from account type:
   - `CH` -> `01`
   - `SV` -> `02`
   - `MM` -> `03`
   - `TD` -> `04`
   - other -> `00`
2. Branch part:
   - If `BRANCH-CODE(3:1)` is numeric, move `BRANCH-CODE(3:4)`
   - Else move `'0001'`
3. Concatenate `BRANCH-PART` + `PROD-CODE` + `ACC-SEQ-ZERO` into `WS-ACCOUNT-PART` (11 digits).
4. Compute Luhn-style check digit on 11 digits, alternating double starting at position 1.
5. Final account number = 11-digit part + check digit (12 digits).

Example: `BR0001` + `CH` + sequence `00016` -> `0001` + `01` + `00016` = `000101000016`.

### 5.4 Debit card generation (`3300-ISSUE-DEBIT-CARD`)

1. Fetch `BAC_CARD_SEQ`.
2. Build `CARD_ID` as `CARD` + 3-digit sequence (`CARD001`).
3. Build 15-digit PAN base:
   - `'400000'` + branch part + product code + 3-digit card sequence
4. Compute Luhn check digit on 15-digit base.
5. Final `CARD_NUMBER` = 16 digits.
6. Expiry date = `CURRENT DATE + 3 YEARS`.
7. Populate card master:
   - `CARD_STATUS = 'IS'` (Issued)
   - `PLASTIC_STATUS = 'EM'` (Embossed)
   - `CVV = '123'`
   - `PIN_STATUS = 'M'`
   - `ACTIVATION_STATUS = 'I'`
   - `DISPATCH_STATUS = 'PD'` (Pending dispatch)
   - `CARD_NETWORK = 'VISA'`
   - `CARD_PRODUCT = 'RUBY'`
   - Limits copied from application; `AVAILABLE_LIMIT = DAILY_LIMIT`
8. `INSERT INTO TB_BAC_CARD`.

### 5.5 Local batch differences

- Uses sequential files (`DATA/BACAPP`, `DATA/BACCUST`, `DATA/BACACC`, `DATA/BACCARD`, `DATA/BACAPP-UPDATED`).
- Writes two reports: `OUTPUT/ACCOUNT_OPEN_RPT.txt` and `OUTPUT/CARD_ISSUE_RPT.txt`.
- No explicit SQL commit; sequential write errors `STOP RUN`.
- Expiry date built by adding 3 to current year from `ACCEPT FROM DATE`.

---

## 6. Audit Behavior

### 6.1 Audit insert (`1560-INSERT-AUDIT`)

| Column | Value |
|--------|-------|
| `APP_ID` | New application ID |
| `STATUS_FROM` | `SPACES` |
| `STATUS_TO` | `CA-APP-STATUS` after decision |
| `USER_ID` | `CA-USER-ID` (default `OPR001`, or `EIBUSERID` if non-blank) |
| `ACTION_TIMESTAMP` | `CA-APP-CREATED-TIMESTAMP` |
| `ACTION_TYPE` | `CR` (Create) |
| `REMARKS` | `APPLICATION CREATED` |

### 6.2 Batch audit insert

| Column | Value |
|--------|-------|
| `APP_ID` | Application ID |
| `STATUS_FROM` | `WS-OLD-STATUS` (`SB` or `AP`) |
| `STATUS_TO` | `OP` |
| `USER_ID` | `BATCH01` |
| `ACTION_TIMESTAMP` | Default `CURRENT TIMESTAMP` |
| `ACTION_TYPE` | `AO` (Account Opened) |
| `REMARKS` | `ACCOUNT OPENED BY BATCH` |

### 6.3 Observations

- No audit row is written when an application is rejected online; the status is `RJ` but `1560-INSERT-AUDIT` is skipped in `1520-SUBMIT-APPLICATION` for rejected applications.
- Maker-checker approval (checker program `BACAPPR`) is not implemented in the repository, so no `AP` -> `OP` or `SB` -> `RJ` checker audit exists.

---

## 7. Data Entities

### 7.1 `TB_BAC_APPLICATION`

Primary application header. Copybook `CPYBAC01` / `CPYBAC00`.

Key fields and constraints:

| Field | Type / COBOL | Domain / notes |
|-------|--------------|----------------|
| `APP_ID` | `CHAR(10)` PK | `APP` + 7-digit sequence |
| `APP_STATUS` | `CHAR(2)` | `DR/SB/PE/KY/AP/RJ/OP` |
| `BUSINESS_NAME` | `VARCHAR(60)` / `X(60)` | Required |
| `TRADE_NAME` | `VARCHAR(40)` | Optional DBA |
| `REGISTRATION_NO` | `VARCHAR(20)` | Business registration |
| `TAX_ID` | `VARCHAR(15)` | Tax / EIN |
| `INCORP_DATE` | `DATE` / `X(10)` | ISO date string |
| `BUSINESS_TYPE` | `CHAR(2)` | `LC/CP/PT/SP/NP/TR` |
| `INDUSTRY_CODE` | `VARCHAR(6)` / `X(6)` | NAICS / SIC |
| `ANNUAL_REVENUE` | `DECIMAL(13,2)` / `S9(10)V99 COMP-3` | Revenue |
| `EMPLOYEE_COUNT` | `INTEGER` / `9(06)` | Headcount |
| `ADDR_LINE1/2` | `VARCHAR(40)` / `X(40)` | Address |
| `CITY` | `VARCHAR(25)` / `X(25)` | City |
| `STATE` | `CHAR(2)` | State code |
| `COUNTRY` | `CHAR(3)` / `X(3)` | ISO country code |
| `ZIP_CODE` | `VARCHAR(10)` / `X(10)` | Postal code |
| `PHONE` | `VARCHAR(15)` / `X(15)` | Phone |
| `EMAIL` | `VARCHAR(50)` / `X(50)` | Email |
| `CONTACT_NAME` | `VARCHAR(50)` / `X(50)` | Primary contact |
| `ACCOUNT_TYPE` | `CHAR(2)` | `CH/SV/MM/TD` |
| `CURRENCY` | `CHAR(3)` / `X(3)` | ISO currency |
| `INITIAL_DEPOSIT` | `DECIMAL(13,2)` / `COMP-3` | Opening deposit |
| `EXPECTED_TXN_VOL` | `INTEGER` / `9(07)` | Monthly volume (not captured on BMS screen) |
| `EXPECTED_TXN_AMT` | `DECIMAL(13,2)` / `COMP-3` | Monthly amount |
| `SOURCE_OF_FUNDS` | `VARCHAR(30)` / `X(30)` | Description |
| `RISK_RATING` | `CHAR(2)` | `LO/MD/HI` |
| `PEP_FLAG` | `CHAR(1)` | `Y`/`N` |
| `SANCTIONS_FLAG` | `CHAR(1)` | `Y`/`N` |
| `DOCS_RECEIVED` | `CHAR(1)` | `Y`/`N` |
| `BOARD_RESOLUTION` | `CHAR(1)` | `Y`/`N` |
| `UBO_DECLARATION` | `CHAR(1)` | `Y`/`N` |
| `MAKER_ID` | `CHAR(8)` | Online user ID |
| `CHECKER_ID` | `CHAR(8)` | Checker or `BATCH01` |
| `CREATED_TIMESTAMP` | `TIMESTAMP` / `X(26)` | Creation time |
| `UPDATED_TIMESTAMP` | `TIMESTAMP` / `X(26)` | Last update |
| `ACCOUNT_NUMBER` | `CHAR(12)` | Populated by batch |
| `BRANCH_CODE` | `CHAR(6)` | `BR0001` from online; hard-coded |
| `REJECTION_REASON` | `VARCHAR(100)` / `X(100)` | Rejection explanation |
| `CARD_REQUESTED` | `CHAR(1)` | `Y`/`N` |
| `CARD_TYPE` | `CHAR(2)` | `DC/CC/PC` |
| `CARD_DAILY_LIMIT` | `DECIMAL(9,2)` / `COMP-3` | Daily POS limit |
| `CARD_ATM_LIMIT` | `DECIMAL(9,2)` / `COMP-3` | ATM daily limit |
| `CARD_MONTHLY_LIMIT` | `DECIMAL(11,2)` / `COMP-3` | Monthly limit |
| `CARD_EMBOSS_NAME` | `VARCHAR(30)` / `X(30)` | Name on plastic |

### 7.2 `TB_BAC_CUSTOMER`

Copybook `CPYBAC02`. Mirrors many application fields. Status default `AC`.

### 7.3 `TB_BAC_SIGNATORY`

Copybook `CPYBAC03`. One signatory row per application in the current code.

| Field | Notes |
|-------|-------|
| `SIG_ID` | `SIG` + 7-digit sequence |
| `APP_ID` | FK to application |
| `CUST_ID` | Not populated by online path |
| `SIG_TYPE` | `A` = authorized signatory, `B` = beneficial owner |
| `OWNERSHIP_PCT` | Percentage for beneficial owners (`DECIMAL(5,2)` / `9(03)V99 COMP-3`) |

### 7.4 `TB_BAC_ACCOUNT`

Copybook `CPYBAC04`.

| Field | Notes |
|-------|-------|
| `ACCOUNT_NUMBER` | 12-digit generated value, PK |
| `APP_ID` | FK to application |
| `CUST_ID` | FK to customer |
| `STATUS` | `AC/CL/FR` |
| `BALANCE` | Set to initial deposit |
| `AVAILABLE_BALANCE` | Set to initial deposit |
| `INITIAL_DEPOSIT` | Opening deposit |

### 7.5 `TB_BAC_CARD`

Copybook `CPYBAC07`. Full plastic and limit lifecycle fields.

| Field | Notes |
|-------|-------|
| `CARD_ID` | `CARD` + 3-digit sequence, PK |
| `APP_ID` | FK to application |
| `ACCOUNT_NUMBER` | FK to account |
| `CUST_ID` | FK to customer |
| `CARD_NUMBER` | 16-digit PAN, unique |
| `CARD_TYPE` | `DC/CC/PC` |
| `CARD_STATUS` | `RQ/AP/IS/BL/CA` |
| `PLASTIC_STATUS` | `PE/EM/DI/DE/DA` |
| `DAILY_LIMIT` / `ATM_LIMIT` / `MONTHLY_LIMIT` / `AVAILABLE_LIMIT` | Transaction limits |
| `CVV` | Hard-coded `123` in batch demo |
| `PIN_STATUS` | `M` = mailed |
| `ACTIVATION_STATUS` | `I` = inactive |
| `DISPATCH_STATUS` | `PD` = pending dispatch |
| `CARD_NETWORK` | `VISA` |
| `CARD_PRODUCT` | `RUBY` |

### 7.6 `TB_BAC_DOCUMENT`

Copybook `CPYBAC05` / DDL `CRTTBL05.sql`. Defined but **not populated by `BACONL01`** in the current source; KYC checks rely only on the application header flags.

### 7.7 `TB_BAC_AUDIT`

Copybook `CPYBAC06`. Identity-generated `AUDIT_ID`; FK to application; indexed by `APP_ID`.

---

## 8. Inputs

### 8.1 CICS online (`BACONL01`)

- 3270 terminal input from operator/teller
- `DFHCOMMAREA` for state persistence across pseudo-conversations
- `EIBUSERID` for maker ID
- DB2 sequences: `BAC_APP_SEQ`, `BAC_SIG_SEQ`
- Current timestamp from `SYSIBM.SYSDUMMY1`

### 8.2 Batch (`BACBAT01`)

- `TB_BAC_APPLICATION` rows with `APP_STATUS IN ('SB','AP')`
- DB2 sequences: `BAC_CUST_SEQ`, `BAC_ACC_SEQ`, `BAC_CARD_SEQ`
- Current date/time from `SYSIBM.SYSDUMMY1`

### 8.3 Local demonstration

- `LOCAL/DATA/BACREQ.dat` - request file (`01` = new app, `02` = inquiry)
- `LOCAL/DATA/BACAPP` - application sequential master
- `LOCAL/DATA/BACSIG` - signatory sequential master
- `LOCAL/DATA/BACCUST` / `BACACC` / `BACCARD` - output master files

---

## 9. Outputs

### 9.1 DB2 tables (mainframe)

- Inserts: `TB_BAC_APPLICATION`, `TB_BAC_SIGNATORY`, `TB_BAC_AUDIT` (CICS); `TB_BAC_CUSTOMER`, `TB_BAC_ACCOUNT`, `TB_BAC_CARD`, `TB_BAC_AUDIT` (batch)
- Updates: `TB_BAC_APPLICATION` status to `OP`, `ACCOUNT_NUMBER`, `CHECKER_ID`, `UPDATED_TIMESTAMP`

### 9.2 Reports

| Report | Producer | Destination |
|--------|----------|-------------|
| Account opening report | `BACBAT01` mainframe | `RPTFILE` (`HLQ.BANK.OUTPUT.ACCTOPEN`) |
| Card issue report | `BACBAT01` local | `OUTPUT/CARD_ISSUE_RPT.txt` |
| Account opening report | `BACBAT01` local | `OUTPUT/ACCOUNT_OPEN_RPT.txt` |
| Online response | `LOCAL/BACONL01` | `OUTPUT/BACRESP.dat` |

### 9.3 VSAM / sequential files

- `VSAM/DEFAPP01.ams` / `HLQ.BANK.VSAM.BACAPP` - application KSDS (not written by current programs)
- `VSAM/DEFCUS01.ams` / `HLQ.BANK.VSAM.BACCUST` - customer KSDS
- `VSAM/DEFACC01.ams` / `HLQ.BANK.VSAM.BACACC` - account KSDS
- `VSAM/DEFSIG01.ams` / `HLQ.BANK.VSAM.BACSIG` - signatory KSDS

---

## 10. Edge Cases and Source Gaps

### 10.1 Functional edge cases

| Scenario | Current behavior | Risk / note |
|----------|------------------|-------------|
| PEP or sanctions flag = `Y` | Application rejected immediately; no customer/account created | Correct hard stop, but no external screening API is called |
| KYC document flag = `N` | Page validation fails; `KY` status in decision logic is unreachable | `KY` status is effectively dead code from online flow |
| Menu options `2`/`3`/`4` | Display "USE BA02 FOR INQUIRY", "USE BA03 FOR APPROVAL" and return to menu | Inquiry and approval programs are not implemented |
| Review submit with `PF5` | Always submits regardless of `RVSUBAPP` value | `PF5` does not check the `Y` confirmation flag; only `ENTER` does |
| Multiple signatories | Only one signatory is captured in `CA-SIGNATORY` and inserted | Real business accounts may require many signatories / UBOs |
| Expected monthly transaction volume | Field exists in `CPYBAC01` but is not on `BACAPP3` and is never set | Always zero from online flow |
| `BOARD_RESOLUTION` / `UBO_DECLARATION` / `DOCS_RECEIVED` | Stored as single-character flags only; `TB_BAC_DOCUMENT` is not written | No per-document audit trail or reference numbers |
| Account type `TD` | Treated as a product code `04` but no maturity, term, or interest terms captured | Term-deposit logic incomplete |
| Duplicate business / tax ID | No uniqueness check | Potential duplicate customer / application creation |
| Branch code | Hard-coded to `BR0001` in online program; checker/batch uses `BATCH01` | No real branch routing |
| `EIBUSERID` blank | Falls back to `OPR001`; no authentication failure | Maker ID may be unreliable |

### 10.2 Technical edge cases

- `FUNCTION NUMVAL` is used for currency/percentage fields; non-numeric input will cause a COBOL run-time error unless `NUMVAL-C` or explicit error handling is added.
- Batch `UPDATE ... WHERE CURRENT OF C1` relies on the cursor still being positioned. The `COMMIT` is performed only every 10 records; a long failure leaves uncommitted work.
- Mainframe batch writes `ACCT-OPEN-RPT` to a sequential dataset but the card report is only produced in the local `LOCAL/BACBAT01.cbl` source.
- The mainframe `BACBAT01` header line is initialized from a literal that historically exceeded fixed-format source limits; it is now set in `0000-MAIN` via `STRING`.
- The local `BACBAT01` sets `WS-CARD-HEADER-LINE` with `STRING` for the same fixed-format reason.

---

## 11. External Dependencies

### 11.1 Runtime (mainframe)

| Component | Usage |
|-----------|-------|
| CICS TS | Transaction `BA01`, mapset `BACMAPS`, `EXEC CICS` commands, `EIB*` fields, `DFHCOMMAREA` |
| DB2 for z/OS | Tables, sequences, cursors, SQLCA, `DSNHLI` interface |
| z/OS syslibs | `IGY.SIGYCOMP`, `CICSTS.SDFHLOAD`, `CICSTS.SDFHCOB`, `DB2.SDSNLOAD`, `DB2.SDSNSAMP`, `DB2.SDSNMACS` |
| TSO/IKJEFT01 | DSN command processor to run DB2 batch programs |
| IDCAMS | VSAM cluster definitions |
| HLQ datasets | `HLQ.BANK.COPY`, `HLQ.BANK.COBOL.CICS`, `HLQ.BANK.COBOL.BATCH`, `HLQ.BANK.LOAD`, `HLQ.BANK.OUTPUT.*` |
| CICS/BMS compile | `DFHMSD TYPE=&SYSPARM` |

### 11.2 Local demonstration

| Dependency | Usage |
|------------|-------|
| GnuCOBOL (`cobc`) | Compile with `-std=ibm` |
| `COPYBOOK/` directory | `-I` include path |
| Bash | `LOCAL/build.sh`, `LOCAL/run.sh` |
| Sequential files | Stand-in for DB2 and VSAM because indexed-file handler is disabled in this GnuCOBOL build |

### 11.3 Data sources

- DB2 sequences: `BAC_APP_SEQ`, `BAC_SIG_SEQ`, `BAC_CUST_SEQ`, `BAC_ACC_SEQ`, `BAC_CARD_SEQ`
- Indexes: status/app, branch/status, app on customer/signatory/document/card, account on card
- Foreign keys: application -> customer -> account -> card; document/audit/signatory -> application

---

## 12. Modernization Notes

### 12.1 Application tier

- Replace CICS/BMS 3270 screens with a responsive web portal or mobile app; keep the same state-machine concepts but implement with OAuth2/OpenID Connect, session tokens, and REST APIs.
- Externalize validation and status-transition rules into a decision engine (e.g., Drools, Camunda DMN) or configuration-driven rule tables.
- Move maker-checker workflow from a single `BACONL01` program into an explicit workflow/BPM engine with task queues, notifications, and SLA tracking.

### 12.2 Integration and compliance

- Replace hard-coded PEP/sanctions flags with real-time API calls to sanctions lists (OFAC, UN, EU, etc.) and politically-exposed-person databases.
- Integrate document management / OCR / digital KYC for `TB_BAC_DOCUMENT`; store images with reference numbers and verification status.
- Implement beneficial-ownership threshold rules (e.g., >25%) and collect all UBOs/signatories in a multi-row design.

### 12.3 Card and security

- Generate PANs, CVVs, and PINs using a certified HSM; never hard-code `CVV='123'`.
- Use tokenization for card numbers in non-HSM contexts.
- Implement encrypted PIN mailers, dispatch tracking, and activation workflows.
- Add card controls (geography, merchant category, online/MOTO, contactless limits).

### 12.4 Data and architecture

- Promote normalized DB2 schema; add missing `TB_BAC_DOCUMENT` writes and a `TB_BAC_CARD_PLASTIC` lifecycle table if more granular plastic events are required.
- Replace `DFHCOMMAREA` persistence with a Redis/session store or JWT claims; remove 2000-byte COMMAREA limits.
- Add idempotency keys for application submission to prevent duplicates on double-click / network retry.
- Add comprehensive unit tests (e.g., COBOL Check, ZUnit) and CI/CD pipelines for both mainframe and local GnuCOBOL builds.

### 12.5 Operations

- Convert JCL compile/bind/run jobs into CI/CD stages with GitOps promotion.
- Replace nightly batch with an event-driven, real-time account-opening microservice or a hybrid streaming/batch pipeline.
- Add centralized logging, distributed tracing, and real-time dashboards for application and card issuance metrics.
