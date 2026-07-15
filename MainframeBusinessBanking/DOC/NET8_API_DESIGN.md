# .NET 8 REST API Design - Business Banking Onboarding

This document designs a complete .NET 8 REST API that replaces the mainframe CICS/BMS and COBOL batch flows in `MainframeBusinessBanking`.

It is based on:

- `COBOL/CICS/BACONL01.cbl` (transaction `BA01`)
- `COBOL/BATCH/BACBAT01.cbl`
- `COPYBOOK/CPYBAC00.cpy` - `CPYBAC07.cpy`
- `DOC/BUSINESS_RULE_CATALOG.md`
- `DOC/DOMAIN_MODEL.md`

Target stack: **ASP.NET Core 8**, **MongoDB**, **MediatR**, **FluentValidation**, **MassTransit** domain events.

---

## 1. API standards

| Item | Value |
|------|-------|
| Base URL | `https://api.bank.example.com/v1` |
| Content type | `application/json` |
| Authentication | `Authorization: Bearer <JWT>` |
| Maker / checker identity | JWT `sub` claim mapped to `UserId` |
| Correlation id | Header `X-Correlation-ID` (returned in responses) |
| Pagination | `?page=1&pageSize=25` on list endpoints |
| Error contract | `{ "errorCode": "", "message": "", "details": [], "traceId": "" }` |

### HTTP status codes

| Code | Use |
|------|-----|
| `201 Created` | Resource created |
| `200 OK` | Read / update success |
| `204 No Content` | Delete / no response body |
| `400 Bad Request` | Validation failure |
| `401 Unauthorized` | Missing/invalid token |
| `403 Forbidden` | User not permitted (e.g., checker tries to approve own app) |
| `404 Not Found` | Application/account/card not found |
| `409 Conflict` | Invalid state transition (e.g., approve a rejected app) |
| `422 Unprocessable Entity` | Business rule violation |

### Shared error example

```json
{
  "errorCode": "APPLICATION_NOT_SUBMITTABLE",
  "message": "One or more validation rules failed.",
  "details": [
    "Business name is required.",
    "KYC documents are not complete."
  ],
  "traceId": "00-1234567890abcdef-1234567890abcdef-00"
}
```

---

## 2. Domain enumerations

These values replace the two-character codes used by the COBOL copybooks.

| COBOL value | .NET enum value | Description |
|-------------|-----------------|-------------|
| `LC` | `LLC` | Limited liability company |
| `CP` | `Corporation` | Corporation |
| `PT` | `Partnership` | Partnership |
| `SP` | `SoleProprietor` | Sole proprietor |
| `NP` | `NonProfit` | Non-profit |
| `TR` | `Trust` | Trust |
| `CH` | `Checking` | Checking account |
| `SV` | `Savings` | Savings account |
| `MM` | `MoneyMarket` | Money market account |
| `TD` | `TermDeposit` | Term deposit |
| `LO` | `Low` | Low risk |
| `MD` | `Medium` | Medium risk |
| `HI` | `High` | High risk |
| `DC` | `Debit` | Debit card |
| `CC` | `Credit` | Credit card |
| `PC` | `Prepaid` | Prepaid card |

Application status enum (replaces `APP_STATUS`):

| Value | Meaning |
|-------|---------|
| `Draft` | Saved but incomplete |
| `Submitted` | All pages valid and submitted |
| `KycPending` | Awaiting document verification |
| `Pending` | Under checker review |
| `Approved` | Checker approved |
| `Rejected` | PEP/sanctions hit or checker rejected |
| `Opened` | Account opened by batch/service |

---

## 3. Shared DTOs

### 3.1 `Address`

```json
{
  "line1": "123 Industrial Parkway",
  "line2": "Suite 100",
  "city": "Detroit",
  "state": "MI",
  "country": "USA",
  "zipCode": "48201"
}
```

**Validation rules**

- `line1`, `city`, `country`: required, max lengths 40, 25, 3.
- If `country` is `USA` or `US`, `state` (2 chars) and `zipCode` are required.
- `zipCode` max length 10.
- `state` max length 2.

### 3.2 `BusinessInfo`

```json
{
  "legalName": "Acme Manufacturing LLC",
  "tradeName": "Acme",
  "registrationNumber": "REG-2026-001",
  "taxId": "12-3456789",
  "incorporationDate": "2015-03-10",
  "businessType": "LLC",
  "industryCode": "321900",
  "annualRevenue": 2500000.00,
  "employeeCount": 120
}
```

**Validation rules**

- `legalName`: required, max 60.
- `taxId`: required, max 15.
- `registrationNumber`: required, max 20.
- `businessType`: required, one of `LLC`, `Corporation`, `Partnership`, `SoleProprietor`, `NonProfit`, `Trust`.
- `incorporationDate`: valid ISO date, not in the future.
- `industryCode`: max 6.
- `annualRevenue`: >= 0.
- `employeeCount`: >= 0.

### 3.3 `Contact`

```json
{
  "name": "John Doe",
  "phone": "3135550100",
  "email": "finance@acme.com"
}
```

**Validation rules**

- `name`: required, max 50.
- `phone`: max 15.
- `email`: valid email format, max 50.

### 3.4 `KycInfo`

```json
{
  "riskRating": "Low",
  "pep": false,
  "sanctions": false,
  "documentsReceived": true,
  "boardResolution": true,
  "uboDeclaration": true,
  "sourceOfFunds": "Operating Revenue",
  "expectedMonthlyVolume": 5000,
  "expectedMonthlyAmount": 200000.00
}
```

**Validation rules**

- `riskRating`: required, one of `Low`, `Medium`, `High`.
- `pep`, `sanctions`: boolean. If either is `true`, application can only move to `Rejected`.
- `documentsReceived`, `boardResolution`, `uboDeclaration`: must be `true` before `Submitted` or `Approved`.
- `sourceOfFunds`: max 30.
- `expectedMonthlyVolume`: >= 0.
- `expectedMonthlyAmount`: >= 0.

### 3.5 `AccountPreference`

```json
{
  "accountType": "Checking",
  "currency": "USD",
  "initialDeposit": 50000.00
}
```

**Validation rules**

- `accountType`: required, one of `Checking`, `Savings`, `MoneyMarket`, `TermDeposit`.
- `currency`: required, ISO 4217 currency code, max 3.
- `initialDeposit`: >= 0.

### 3.6 `CardRequest`

```json
{
  "cardType": "Debit",
  "dailyLimit": 2500.00,
  "atmLimit": 1000.00,
  "monthlyLimit": 25000.00,
  "embossName": "John Doe / Acme Mfg"
}
```

**Validation rules**

- `cardType`: one of `Debit`, `Credit`, `Prepaid`.
- `dailyLimit`, `atmLimit`, `monthlyLimit`: >= 0.
- `dailyLimit` <= `monthlyLimit`.
- `embossName`: max 30.
- If `cardType` is omitted, no card is requested.

### 3.7 `Signatory`

```json
{
  "id": "SIG0000001",
  "name": "John Doe",
  "title": "CFO",
  "dateOfBirth": "1975-06-15",
  "nationalId": "12345678901",
  "address": {
    "line1": "123 Industrial Parkway",
    "line2": "Suite 100",
    "city": "Detroit",
    "state": "MI",
    "country": "USA",
    "zipCode": "48201"
  },
  "phone": "3135550100",
  "email": "john.doe@acme.com",
  "ownershipPercentage": 25.00,
  "signatoryType": "Authorized",
  "idType": "Passport",
  "idNumber": "P1234567"
}
```

**Validation rules**

- `name`: required, max 50.
- `dateOfBirth`: valid ISO date, not in the future, applicant must be 18+.
- `signatoryType`: required, one of `Authorized`, `BeneficialOwner`.
- If `signatoryType` is `BeneficialOwner`, `ownershipPercentage` is required and must be 0 - 100.
- If `signatoryType` is `Authorized`, `ownershipPercentage` may be null or 0.
- `idType`: max 10.
- `idNumber`: max 20.

### 3.8 `Document`

```json
{
  "id": "DOC0000001",
  "documentType": "Articles",
  "reference": "AR-2026-001",
  "status": "Verified",
  "receivedDate": "2026-07-14",
  "remarks": "Articles received and verified"
}
```

**Document types**

| Value | Maps from COBOL |
|-------|-----------------|
| `Articles` | `AR` |
| `TaxCertificate` | `TC` |
| `AddressProof` | `AD` |
| `IdProof` | `ID` |
| `UboDeclaration` | `BO` |
| `BoardResolution` | `BR` |

**Validation rules**

- `documentType`: required, one of the above.
- `reference`: max 30.
- `status`: one of `NotReceived`, `Received`, `Verified`, `Rejected`.
- `receivedDate`: valid ISO date.

### 3.9 `AuditEntry`

```json
{
  "auditId": "AUD0000001",
  "entityType": "Application",
  "entityId": "APP0000001",
  "statusFrom": "Submitted",
  "statusTo": "Opened",
  "userId": "BATCH01",
  "actionType": "AccountOpened",
  "remarks": "Account opened by batch",
  "timestamp": "2026-07-14T11:00:00Z"
}
```

---

## 4. Endpoints

### 4.1 Create a new application

`POST /applications`

Creates an empty application in `Draft` status. This replaces the `BACONL01` menu option `1` and first invocation.

**Request**

```json
{
  "branchCode": "BR0001"
}
```

**Validation**

- `branchCode`: required, max 6.

**Response `201 Created`**

```json
{
  "id": "APP0000004",
  "status": "Draft",
  "branchCode": "BR0001",
  "createdAt": "2026-07-14T10:00:00Z",
  "updatedAt": "2026-07-14T10:00:00Z",
  "makerId": "OPR001"
}
```

---

### 4.2 Save / update business identification (page 1)

`PUT /applications/{applicationId}/business-info`

**Request**

```json
{
  "businessInfo": {
    "legalName": "Acme Manufacturing LLC",
    "tradeName": "Acme",
    "registrationNumber": "REG-2026-001",
    "taxId": "12-3456789",
    "incorporationDate": "2015-03-10",
    "businessType": "LLC",
    "industryCode": "321900",
    "annualRevenue": 2500000.00,
    "employeeCount": 120
  },
  "phone": "3135550100",
  "email": "finance@acme.com"
}
```

**Response `200 OK`**

```json
{
  "id": "APP0000004",
  "status": "Draft",
  "businessInfo": { ... },
  "phone": "3135550100",
  "email": "finance@acme.com",
  "updatedAt": "2026-07-14T10:01:00Z"
}
```

**Validation**

- `businessInfo` required and validated per `BusinessInfo` rules.
- If status is `Opened`, `Rejected`, return `409 Conflict`.

---

### 4.3 Save / update address and contact (page 2)

`PUT /applications/{applicationId}/address-contact`

**Request**

```json
{
  "address": {
    "line1": "123 Industrial Parkway",
    "line2": "Suite 100",
    "city": "Detroit",
    "state": "MI",
    "country": "USA",
    "zipCode": "48201"
  },
  "contact": {
    "name": "John Doe",
    "phone": "3135550100",
    "email": "finance@acme.com"
  }
}
```

**Response `200 OK`**

```json
{
  "id": "APP0000004",
  "status": "Draft",
  "address": { ... },
  "contact": { ... },
  "updatedAt": "2026-07-14T10:02:00Z"
}
```

**Validation**

- `address` and `contact` required.
- Address rules from section 3.1.

---

### 4.4 Save / update product and KYC (page 3)

`PUT /applications/{applicationId}/product-kyc`

**Request**

```json
{
  "accountPreference": {
    "accountType": "Checking",
    "currency": "USD",
    "initialDeposit": 50000.00
  },
  "kycInfo": {
    "riskRating": "Low",
    "pep": false,
    "sanctions": false,
    "documentsReceived": true,
    "boardResolution": true,
    "uboDeclaration": true,
    "sourceOfFunds": "Operating Revenue",
    "expectedMonthlyVolume": 5000,
    "expectedMonthlyAmount": 200000.00
  }
}
```

**Response `200 OK`**

```json
{
  "id": "APP0000004",
  "status": "Draft",
  "accountPreference": { ... },
  "kycInfo": { ... },
  "updatedAt": "2026-07-14T10:03:00Z"
}
```

**Validation**

- `accountPreference` and `kycInfo` required.
- If `pep` or `sanctions` is `true`, the API still saves the data but marks the application as ineligible for approval; `submit` will reject it.
- `documentsReceived`, `boardResolution`, `uboDeclaration` must be `true` for `submit` to succeed.

---

### 4.5 Add a signatory / beneficial owner

`POST /applications/{applicationId}/signatories`

**Request**

```json
{
  "name": "John Doe",
  "title": "CFO",
  "dateOfBirth": "1975-06-15",
  "nationalId": "12345678901",
  "address": { ... },
  "phone": "3135550100",
  "email": "john.doe@acme.com",
  "ownershipPercentage": 25.00,
  "signatoryType": "Authorized",
  "idType": "Passport",
  "idNumber": "P1234567"
}
```

**Response `201 Created`**

```json
{
  "id": "SIG0000001",
  "applicationId": "APP0000004",
  "name": "John Doe",
  "signatoryType": "Authorized",
  "createdAt": "2026-07-14T10:04:00Z"
}
```

**Validation**

- `name`, `dateOfBirth`, `signatoryType` required.
- `signatoryType` must be `Authorized` or `BeneficialOwner`.
- `ownershipPercentage` required when `signatoryType` is `BeneficialOwner`.
- Cannot add signatories to `Opened` or `Rejected` applications.

---

### 4.6 Update / remove a signatory

`PUT /applications/{applicationId}/signatories/{signatoryId}`  
`DELETE /applications/{applicationId}/signatories/{signatoryId}`

Same validation as `POST`. DELETE returns `204 No Content`.

---

### 4.7 Add or update a KYC document

`POST /applications/{applicationId}/documents`

**Request**

```json
{
  "documentType": "Articles",
  "reference": "AR-2026-001",
  "status": "Received",
  "receivedDate": "2026-07-14",
  "remarks": "Articles of incorporation received"
}
```

**Response `201 Created`**

```json
{
  "id": "DOC0000001",
  "applicationId": "APP0000004",
  "documentType": "Articles",
  "status": "Received",
  "createdAt": "2026-07-14T10:05:00Z"
}
```

**Validation**

- `documentType` required, from allowed list.
- `reference` max 30.
- `receivedDate` required if `status` is `Received` or `Verified`.

---

### 4.8 Verify / reject a document

`PATCH /applications/{applicationId}/documents/{documentId}`

**Request**

```json
{
  "status": "Verified",
  "remarks": "Verified against state registry"
}
```

**Response `200 OK`**

```json
{
  "id": "DOC0000001",
  "status": "Verified",
  "verifiedAt": "2026-07-14T10:06:00Z"
}
```

**Business rules**

- When all required documents are `Verified`, the `KycCase` publishes `KycCompleted`, allowing the application to move from `KycPending` to `Submitted` or `Approved`.

---

### 4.9 Request a debit card

`POST /applications/{applicationId}/card-request`

**Request**

```json
{
  "cardType": "Debit",
  "dailyLimit": 2500.00,
  "atmLimit": 1000.00,
  "monthlyLimit": 25000.00,
  "embossName": "John Doe / Acme Mfg"
}
```

**Response `200 OK`**

```json
{
  "applicationId": "APP0000004",
  "cardRequested": true,
  "cardRequest": {
    "cardType": "Debit",
    "dailyLimit": 2500.00,
    "atmLimit": 1000.00,
    "monthlyLimit": 25000.00,
    "embossName": "John Doe / Acme Mfg"
  }
}
```

**Business rules**

- Not allowed if application is `Rejected`.
- If request body is empty, card request is cleared (`cardRequested = false`).
- Default card request for eligible applications: `Debit`, daily 2500, ATM 1000, monthly 25000, emboss name = primary contact name.

---

### 4.10 Submit the application for review

`POST /applications/{applicationId}/submit`

This is the review/submit step. It runs the full validation set and sets the final status.

**Request**

```json
{
  "confirm": true
}
```

**Response `200 OK`**

On success (no PEP/sanctions, all KYC complete):

```json
{
  "id": "APP0000004",
  "status": "Submitted",
  "message": "Application submitted successfully. Debit card requested.",
  "updatedAt": "2026-07-14T10:07:00Z"
}
```

On PEP/sanctions hit:

```json
{
  "id": "APP0000004",
  "status": "Rejected",
  "rejectionReason": "PEP / SANCTIONS HIT - APPLICATION REJECTED",
  "updatedAt": "2026-07-14T10:07:00Z"
}
```

**Validation / business rules**

- All page-level validations run again:
  - Business info, address/contact, product/KYC, at least one signatory.
- `confirm` must be `true`.
- If `pep` or `sanctions` is `true`, status becomes `Rejected`.
- If any KYC document is not `Verified` (or legacy flags are not `true`), status becomes `KycPending`.
- Otherwise, status becomes `Submitted`.
- Publishes `ApplicationSubmitted` or `ApplicationRejected` domain event.

---

### 4.11 Approve an application

`POST /applications/{applicationId}/approve`

**Request**

```json
{
  "checkerId": "CHK001"
}
```

**Response `200 OK`**

```json
{
  "id": "APP0000004",
  "status": "Approved",
  "checkerId": "CHK001",
  "updatedAt": "2026-07-14T10:08:00Z"
}
```

**Business rules**

- Allowed only from `Submitted` or `KycPending` (with all KYC verified).
- Maker cannot approve their own application (checker != maker).
- Publishes `ApplicationApproved`.

---

### 4.12 Reject an application

`POST /applications/{applicationId}/reject`

**Request**

```json
{
  "checkerId": "CHK001",
  "reason": "Unable to verify beneficial ownership"
}
```

**Response `200 OK`**

```json
{
  "id": "APP0000004",
  "status": "Rejected",
  "rejectionReason": "Unable to verify beneficial ownership",
  "checkerId": "CHK001",
  "updatedAt": "2026-07-14T10:09:00Z"
}
```

**Business rules**

- Allowed from `Draft`, `Submitted`, `KycPending`, `Pending`, or `Approved`.
- Publishes `ApplicationRejected`.

---

### 4.13 Open an account

`POST /applications/{applicationId}/open-account`

Replaces the `BACBAT01` batch step. In a real system this may be invoked by a background worker after `ApplicationApproved`; the endpoint exists for operations and dry-run testing.

**Request**

```json
{
  "requestedBy": "BATCH01"
}
```

**Response `201 Created`**

```json
{
  "applicationId": "APP0000004",
  "customerId": "CUST000003",
  "accountNumber": "000101000032",
  "status": "Opened",
  "openedAt": "2026-07-14T11:00:00Z"
}
```

**Business rules**

- Allowed only from `Approved`.
- Generates customer, account, and optionally card.
- Account number: 4-digit branch part + 2-digit product code + 5-digit sequence + Luhn check digit (12 digits total).
- Product codes: `Checking=01`, `Savings=02`, `MoneyMarket=03`, `TermDeposit=04`.
- Publishes `ApplicationOpened`, `CustomerCreated`, `AccountOpened`, `DebitCardRequested`.

---

### 4.14 Issue / view a debit card

`POST /applications/{applicationId}/card`

Idempotent endpoint to generate the linked card for an opened application.

**Response `201 Created`**

```json
{
  "cardId": "CARD003",
  "applicationId": "APP0000004",
  "accountNumber": "000101000032",
  "customerId": "CUST000003",
  "cardNumberLastFour": "0034",
  "cardType": "Debit",
  "status": "Issued",
  "plasticStatus": "Embossed",
  "issueDate": "2026-07-14",
  "expiryDate": "2029-07-14",
  "dailyLimit": 2500.00,
  "atmLimit": 1000.00,
  "monthlyLimit": 25000.00,
  "cardNetwork": "VISA",
  "cardProduct": "RUBY"
}
```

**Business rules**

- Allowed only when `cardRequested = true` and application is `Opened`.
- PAN format: `400000` + branch part + product code + 3-digit sequence + Luhn check digit (16 digits total).
- Expiry = today + 3 years.
- CVV and PIN are generated by an HSM and stored as encrypted tokens, not returned in the response.

---

### 4.15 Get application by id

`GET /applications/{applicationId}`

**Response `200 OK`**

```json
{
  "id": "APP0000004",
  "status": "Submitted",
  "branchCode": "BR0001",
  "businessInfo": { ... },
  "address": { ... },
  "contact": { ... },
  "accountPreference": { ... },
  "kycInfo": { ... },
  "cardRequest": { ... },
  "signatories": [ ... ],
  "documents": [ ... ],
  "accountNumber": null,
  "makerId": "OPR001",
  "checkerId": null,
  "createdAt": "2026-07-14T10:00:00Z",
  "updatedAt": "2026-07-14T10:07:00Z"
}
```

---

### 4.16 Search applications

`GET /applications?status=Submitted&businessName=Acme&taxId=12-3456789&page=1&pageSize=25`

**Response `200 OK`**

```json
{
  "page": 1,
  "pageSize": 25,
  "total": 3,
  "items": [
    { "id": "APP0000001", "status": "Submitted", ... },
    { "id": "APP0000002", "status": "Approved", ... }
  ]
}
```

---

### 4.17 Get account

`GET /accounts/{accountNumber}`

**Response `200 OK`**

```json
{
  "accountNumber": "000101000032",
  "applicationId": "APP0000004",
  "customerId": "CUST000003",
  "accountType": "Checking",
  "currency": "USD",
  "status": "Active",
  "openDate": "2026-07-14",
  "balance": 75000.00,
  "availableBalance": 75000.00,
  "initialDeposit": 75000.00,
  "branchCode": "BR0001",
  "createdAt": "2026-07-14T11:00:00Z"
}
```

---

### 4.18 Get card

`GET /cards/{cardId}`

**Response `200 OK`**

```json
{
  "cardId": "CARD003",
  "applicationId": "APP0000004",
  "accountNumber": "000101000032",
  "customerId": "CUST000003",
  "cardNumberLastFour": "0034",
  "cardType": "Debit",
  "status": "Issued",
  "plasticStatus": "Embossed",
  "embossName": "Sam Wilson / Riverfront",
  "issueDate": "2026-07-14",
  "expiryDate": "2029-07-14",
  "dailyLimit": 2500.00,
  "atmLimit": 1000.00,
  "monthlyLimit": 25000.00,
  "availableLimit": 2500.00,
  "pinStatus": "Mailed",
  "activationStatus": "Inactive",
  "dispatchStatus": "PendingDispatch",
  "cardNetwork": "VISA",
  "cardProduct": "RUBY"
}
```

---

### 4.19 Get audit history

`GET /applications/{applicationId}/audit`

**Response `200 OK`**

```json
{
  "applicationId": "APP0000004",
  "entries": [
    {
      "auditId": "AUD0000001",
      "entityType": "Application",
      "entityId": "APP0000004",
      "statusFrom": null,
      "statusTo": "Submitted",
      "userId": "OPR001",
      "actionType": "ApplicationSubmitted",
      "remarks": "Application submitted",
      "timestamp": "2026-07-14T10:07:00Z"
    },
    {
      "auditId": "AUD0000002",
      "entityType": "Application",
      "entityId": "APP0000004",
      "statusFrom": "Approved",
      "statusTo": "Opened",
      "userId": "BATCH01",
      "actionType": "AccountOpened",
      "remarks": "Account opened by batch",
      "timestamp": "2026-07-14T11:00:00Z"
    }
  ]
}
```

---

### 4.20 Global audit search

`GET /audit?entityType=Application&entityId=APP0000004&page=1&pageSize=25`

**Response `200 OK`**

Same paginated list as `GET /applications/{id}/audit` but across any entity.

---

## 5. State machine and validation summary

### 5.1 Allowed status transitions

```
Draft
  ├─ submit ──> Submitted
  ├─ submit (pep/sanctions) ──> Rejected
  ├─ submit (kyc incomplete) ──> KycPending
  └─ reject ──> Rejected

Submitted
  ├─ approve ──> Approved
  ├─ reject ──> Rejected
  └─ (background) open-account ──> Opened  (normally from Approved)

KycPending
  ├─ kyc completed ──> Submitted
  ├─ approve (if docs verified) ──> Approved
  └─ reject ──> Rejected

Approved
  ├─ open-account ──> Opened
  └─ reject ──> Rejected

Opened
  └─ (none)

Rejected
  └─ (none)
```

### 5.2 Cross-field business rules

| Rule | Endpoint(s) | Result if violated |
|------|-------------|--------------------|
| PEP or sanctions = `true` | `submit`, `approve` | Status `Rejected` |
| KYC documents not all `Verified` | `submit`, `approve` | Status `KycPending` or `400` |
| Country = `USA` / `US` without state/zip | `address-contact` | `400` validation error |
| Maker approves own application | `approve` | `403 Forbidden` |
| Open account before `Approved` | `open-account` | `409 Conflict` |
| Card request on rejected app | `card-request` | `422` |
| Beneficial owner without ownership percentage | `POST signatories` | `400` |
| Account number check digit invalid | `open-account` | Internal error / `500` |

### 5.3 Default values

| Field | Default | Source |
|-------|---------|--------|
| `branchCode` | `BR0001` | Online application creation (legacy hard-coded) |
| `status` | `Draft` | On creation |
| `cardRequested` | `false` until submit | Application setup |
| At submit (eligible) | `Debit` card requested, daily 2500, ATM 1000, monthly 25000 | `BACONL01` logic |
| `cardNetwork` | `VISA` | Batch card generation |
| `cardProduct` | `RUBY` | Batch card generation |
| Account status | `Active` | Account opening |
| Customer status | `Active` | Account opening |

---

## 6. .NET 8 implementation structure

### 6.1 Recommended project layout

```
BusinessBanking.Onboarding.sln
├── src/
│   ├── Onboarding.Api/                  # ASP.NET Core 8 host
│   │   ├── Controllers/
│   │   │   ├── ApplicationsController.cs
│   │   │   ├── AccountsController.cs
│   │   │   ├── CardsController.cs
│   │   │   ├── DocumentsController.cs
│   │   │   ├── SignatoriesController.cs
│   │   │   └── AuditController.cs
│   │   ├── Program.cs
│   │   └── appsettings.json
│   ├── Onboarding.Application/          # MediatR commands/queries
│   │   ├── Applications/
│   │   ├── Signatories/
│   │   ├── Documents/
│   │   ├── Accounts/
│   │   └── Cards/
│   ├── Onboarding.Domain/               # Aggregates, entities, value objects
│   │   ├── Aggregates/
│   │   │   ├── Application.cs
│   │   │   ├── Customer.cs
│   │   │   ├── Account.cs
│   │   │   └── Card.cs
│   │   ├── ValueObjects/
│   │   │   ├── Address.cs
│   │   │   ├── BusinessInfo.cs
│   │   │   ├── Money.cs
│   │   │   └── AccountNumber.cs
│   │   └── Events/
│   ├── Onboarding.Infrastructure/       # MongoDB, MassTransit, Idempotency
│   │   ├── Persistence/
│   │   └── Messaging/
│   └── Onboarding.Contracts/            # DTOs and integration events
├── tests/
│   ├── Onboarding.UnitTests/
│   └── Onboarding.IntegrationTests/
└── Dockerfile
```

### 6.2 Key NuGet packages

| Package | Purpose |
|---------|---------|
| `MediatR` | Command/query dispatch |
| `FluentValidation` | Request validation |
| `MongoDB.Driver` | MongoDB persistence |
| `MassTransit` | Domain event bus |
| `MassTransit.RabbitMQ` or `Azure.ServiceBus` | Transport |
| `Swashbuckle.AspNetCore` | OpenAPI / Swagger |
| `Microsoft.AspNetCore.Authentication.JwtBearer` | JWT auth |

### 6.3 Program.cs essentials

```csharp
builder.Services
    .AddControllers()
    .AddFluentValidation(fv => fv.RegisterValidatorsFromAssemblyContaining<Program>());

builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblyContaining<Program>());

builder.Services.AddMassTransit(x =>
{
    x.UsingRabbitMq((context, cfg) =>
    {
        cfg.ConfigureEndpoints(context);
    });
});

builder.Services.AddSingleton<IMongoClient>(
    new MongoClient(builder.Configuration.GetConnectionString("MongoDb")));
```

### 6.4 Example FluentValidation rule

```csharp
public class ApplicationCreateRequestValidator : AbstractValidator<ApplicationCreateRequest>
{
    public ApplicationCreateRequestValidator()
    {
        RuleFor(x => x.BranchCode)
            .NotEmpty()
            .MaximumLength(6);
    }
}

public class SubmitApplicationRequestValidator : AbstractValidator<SubmitApplicationRequest>
{
    public SubmitApplicationRequestValidator()
    {
        RuleFor(x => x.Confirm).Equal(true).WithMessage("Confirm must be true to submit.");
    }
}
```

### 6.5 Example command handler (approve)

```csharp
public record ApproveApplicationCommand(string ApplicationId, string CheckerId) : IRequest<ApplicationResponse>;

public class ApproveApplicationCommandHandler : IRequestHandler<ApproveApplicationCommand, ApplicationResponse>
{
    private readonly IApplicationRepository _repository;

    public ApproveApplicationCommandHandler(IApplicationRepository repository)
    {
        _repository = repository;
    }

    public async Task<ApplicationResponse> Handle(ApproveApplicationCommand request, CancellationToken cancellationToken)
    {
        var application = await _repository.GetByIdAsync(request.ApplicationId, cancellationToken)
            ?? throw new NotFoundException("Application", request.ApplicationId);

        if (application.MakerId == request.CheckerId)
            throw new ForbiddenException("Maker cannot approve own application.");

        application.Approve(request.CheckerId);

        await _repository.UpdateAsync(application, cancellationToken);

        return application.ToResponse();
    }
}
```

### 6.6 Domain event example

```csharp
public record ApplicationSubmitted : DomainEvent
{
    public string ApplicationId { get; init; }
    public string BusinessName { get; init; }
    public bool CardRequested { get; init; }
    public string? CardType { get; init; }
}
```

---

## 7. MongoDB collection mapping

| Context | Collection | Main source |
|---------|------------|-------------|
| Onboarding | `Applications` | `TB_BAC_APPLICATION` |
| Onboarding | `ApplicationAudit` (link) | `TB_BAC_AUDIT` |
| Customer | `Customers` | `TB_BAC_CUSTOMER` |
| Customer | `Signatories` | `TB_BAC_SIGNATORY` |
| Account | `Accounts` | `TB_BAC_ACCOUNT` |
| Card | `Cards` | `TB_BAC_CARD` |
| KYC | `KycCases` | `TB_BAC_DOCUMENT` + `KycInfo` |
| KYC | `Documents` | `TB_BAC_DOCUMENT` |
| Audit | `AuditEntries` | `TB_BAC_AUDIT` |

**Indexes**

- `Applications`: `Status`, `BusinessName` (text), `TaxId`
- `Accounts`: `AccountNumber` (unique), `ApplicationId`, `CustomerId`
- `Cards`: `CardNumber` (unique), `ApplicationId`, `AccountNumber`
- `AuditEntries`: `EntityId`, `EntityType`, `Timestamp`
- `KycCases`: `ApplicationId`

---

## 8. Migration from mainframe

1. **Application IDs** - keep existing `APP` + 7-digit format for continuity, but internally use `ObjectId` or UUID.
2. **Account numbers** - migrate existing 12-digit values and validate check digits.
3. **Card numbers** - migrate last-4 only; full PANs should remain in the HSM/token vault.
4. **Status codes** - map `DR/SB/PE/KY/AP/RJ/OP` to new enum values.
5. **Batch jobs** - replace `BACBAT01` with a MassTransit consumer that handles `ApplicationApproved` and calls `POST /applications/{id}/open-account` or an internal `OpenAccountService`.
6. **CICS/BMS screens** - replace with React wizard calling these endpoints in sequence.
7. **Audit** - read from `TB_BAC_AUDIT` into `AuditEntries` and continue appending via domain events.
