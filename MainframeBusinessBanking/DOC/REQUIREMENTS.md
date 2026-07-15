# Business Banking Account Creation - Requirements

## 1. Overview

This mainframe-style application implements the end-to-end process for opening a **business bank account** for a corporate, SME, non-profit, or partnership customer.

It covers all of the real-world controls found in production banking systems:

* Customer onboarding and Know-Your-Business (KYB)
* Authorized signatory / beneficial owner capture
* KYC / AML document checklist
* PEP and sanctions screening
* Risk rating
* Maker-checker workflow
* Account opening through batch
* Debit / prepaid card request and issuance linked to the opened account

## 2. Business Requirements

### 2.1 Business Identification
* Legal business name and trade name
* Registration / incorporation number
* Tax ID / VAT / EIN
* Date of incorporation
* Business type (LLC, Corporation, Partnership, Sole Proprietor, Non-Profit, Trust)
* Industry NAICS/SIC code
* Annual revenue and employee count

### 2.2 Business Address and Contact
* Registered / mailing address (line 1, line 2, city, state, country, postal code)
* Primary phone and email
* Primary contact name and title

### 2.3 Account Product Selection
* Account type (Checking, Savings, Money Market, Term Deposit)
* Currency
* Expected monthly transaction volume and amount
* Source of funds
* Initial deposit amount
* Optional debit card request, card type, card network/product, daily/ATM/monthly limits, and emboss name

### 2.4 Authorized Signatories and Beneficial Owners
* Name, title, date of birth, SSN / national ID
* Address, phone, email
* Ownership percentage for beneficial owners
* ID type and ID number
* Signatory type (A = Authorized Signatory, B = Beneficial Owner)

### 2.5 Compliance and Risk
* PEP (Politically Exposed Person) flag
* Sanctions list flag
* Risk rating (Low / Medium / High)
* Document checklist (Articles, Tax Certificate, Address Proof, IDs, UBO Declaration, Board Resolution)

### 2.6 Workflow
* Application statuses: Draft, Submitted, Pending, KYC Pending, Approved, Rejected, Opened
* Maker data entry and checker approval
* Audit trail of every status change
* Rejection with documented reason

### 2.7 Account Opening
* Approved applications are processed by a nightly batch
* Customer master and account master records are created
* Account number generation with branch, product, sequence, and check digit
* Linked debit / prepaid card generated with 16-digit PAN, check digit, expiry, limits, card network/product, and plastic lifecycle when requested
* Application status updated to Opened

## 3. Technical Requirements

### 3.1 Online (CICS/BMS)
* Transaction `BA01` - account creation and submission
* Multi-screen BMS mapset `BACMAPS`
* COMMAREA state machine to retain data across screens
* DB2 inserts for application, signatory, document, audit, and card request

### 3.2 Batch
* Nightly `BACBAT01` job processes submitted and approved applications
* DB2 cursor `FOR UPDATE OF` for row locking
* Inserts into `TB_BAC_CUSTOMER`, `TB_BAC_ACCOUNT`, and `TB_BAC_CARD`
* Updates `TB_BAC_APPLICATION` to Opened
* Writes audit trail and account/card reports

### 3.3 Data
* DB2 tables: Application, Customer, Signatory, Account, Card, Document, Audit
* DB2 sequences for surrogate IDs
* VSAM KSDS definitions for legacy / settlement interfaces

### 3.4 Local Demonstration
* GnuCOBOL port under `LOCAL/` builds and runs without a mainframe
* Sequential file version of the DB2 tables is used for portability
* Generator, online simulation, batch, and report scripts provided
