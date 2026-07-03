# Deep dive: GDPR and cookie handling in Matdata 2.0

| Metadata | |
| --- | --- |
| Version | 1.0 |
| Last updated | 2026-06-29 |
| Status | Pre-study ready for review |
| Place in documentation | Data protection and cookie strategy. Complemented by [dpia.md](dpia.md). |

> This document describes the strategy. For the full Data Protection Impact Assessment, see [dpia.md](dpia.md). For other documents, see [README.md](README.md).

## Contents
- [1. Why is Matdata 2.0 particularly sensitive?](#sensitivity)
- [2. GDPR strategy and legal basis](#legal-basis)
- [3. User rights (how we build them in code)](#rights)
- [4. Retention and data minimisation](#retention)
- [5. Cookie handling and the "cookie-free" dream](#cookies)
- [6. Incident handling](#incident)
- [7. Data processors and DPAs](#processors)
- [8. Summary checklist for the build phase](#checklist)

## 1. Why is Matdata 2.0 particularly sensitive? <a name="sensitivity"></a>

Collecting receipt data means collecting highly sensitive behavioural data. A receipt does not just show that someone bought "Milk", it shows exactly *which* store (geographical location), *when* (time of visit), and can indirectly reveal sensitive personal data under GDPR Article 9 (e.g. health status through purchases of lactose-free products or medication, or religion via kosher/halal products).

That is the reason a formal DPIA has been produced. See [dpia.md](dpia.md).

## 2. GDPR strategy and legal basis <a name="legal-basis"></a>

To process data legally, every process must have a "Legal basis". We split the platform into two parts:

### 2.1 Core function (private price history)
* **Purpose:** Let the user see their own history and upload their receipts.
* **Legal basis:** *Contract* (Article 6(1)(b)). The user creates an account to use the service. We have to store the data in order to deliver the service.
* **Storage of PDF:** The original PDF in Google Cloud Storage should fall under "Data minimisation". Does the user really need to see the original receipt forever?
    * *Solution:* By default the PDF is deleted after 30 days (see ADR-008 in [open-decisions.md](open-decisions.md)). The user can choose to keep a specific PDF longer directly at upload time.

### 2.2 Crowdsourcing and global statistics (requirement K13)
* **Purpose:** Collect price points from all users to show global trends ("Swedish Milk 3%, average price in Sweden").
* **Legal basis:** *Consent* (Article 6(1)(a)). The user must actively tick "I want to share my prices anonymously to help others". This must *not* be pre-ticked.
* **The technical solution (anonymisation):** GDPR does *not* apply to fully anonymised data. But removing the name is not enough. If the database stores "Receipt from ICA Nära Möllevången, 2026-06-23 09:42" with exactly which 34 items were bought, it may be possible to identify the person if anyone happened to see them in the store.
    * *Technical implementation:* Our `parser-service` must "break up" the receipt. When it writes to the global statistics (`global_price_points`), it only stores: article number, price, city (e.g. "Malmö", *not* the specific store) and **year-month** (`YYYY-MM`, *not* the exact timestamp). That way each individual item is decoupled from the actual "shopping basket", which makes the data irreversibly anonymous.
    * The granularity is decided in ADR-007 in [open-decisions.md](open-decisions.md).

## 3. User rights (how we build them in code) <a name="rights"></a>

GDPR gives users eight main rights (Articles 13–22). The table summarises them and points to where they are handled in Matdata 2.0. A full matrix is also found in [dpia.md](dpia.md) section 9.

| Right | Article | Implementation in Matdata 2.0 |
| --- | --- | --- |
| **Right to information** | 13, 14 | Privacy policy shown at registration and always via `/profile/privacy`. Written in plain language. |
| **Right of access** | 15 | "Export my data" produces JSON or CSV with account, consents and all receipts. |
| **Right to rectification** | 16 | The user can edit profile and e-mail in `/profile`. Correction of individual receipt items is planned post-MVP. |
| **Right to erasure ("the right to be forgotten")** | 17 | "Delete my account". Uses `ON DELETE CASCADE` + deletes PDFs in Cloud Storage. The anonymous price data in `global_price_points` is not affected, as it is no longer linked to the individual. |
| **Right to restriction of processing** | 18 | The user can withdraw consent for crowdsourcing at any time. Account deactivation (without deletion) is offered post-MVP. |
| **Right to data portability** | 20 | Same export feature as the right of access. Formats: JSON and CSV. |
| **Right to object** | 21 | Legitimate interest is used only for security logs. Objections are handled manually via support. |
| **Rights related to automated decision-making** | 22 | Matdata 2.0 does not make automated decisions with legal or similar effect. |

### 3.1 Practical design choices
* **Deletion:** `ON DELETE CASCADE` on FK to `USERS`. An asynchronous job deletes the associated objects in Cloud Storage. An audit log is created (NFR-D6 in [non-functional-requirements.md](non-functional-requirements.md)).
* **Export:** Endpoint `GET /api/profile/export?format=json|csv`. Standardised and versioned output.
* **Consent:** A timestamp is stored (`USERS.consent_updated_at`) along with the chosen option. Traces of withdrawn consent are logged in the audit log.

## 4. Retention and data minimisation <a name="retention"></a>

| Data type | Retention period | Trigger for deletion | Source |
| --- | --- | --- | --- |
| Account + e-mail | Until the user deletes | User action, automatically after 24 months of inactivity | [non-functional-requirements.md](non-functional-requirements.md) NFR-D2 |
| Password hash | Until the user deletes | User action | NFR-D2 |
| Personal receipt items | Until the user deletes | User action (ON DELETE CASCADE) | NFR-D2 |
| Original PDF | 30 days (default) or until the user deletes | Cron job + user action | NFR-D1 |
| Anonymised statistics | Permanent | Not affected by account deletion | NFR-D3 |
| Audit logs | 1 year | Scheduled deletion | NFR-D6 |
| General logs | 30 days | Cloud Logging default | NFR-D5 |
| Sessions | 30 days inactivity | Daily clean-up | NFR-D4 |

## 5. Cookie handling and the "cookie-free" dream <a name="cookies"></a>

In the EU we are used to enormous, intrusive cookie banners. Because we build Matdata 2.0 from scratch with modern technology, we can make an active choice to *minimise the need for a banner*.

### 5.1 Necessary cookies (exempt from banner requirement)
The law (the ePrivacy directive) says that cookies which are *strictly necessary* for the service to work do not require consent/banner, only information in a privacy policy.

* **`SESSION` (Spring Session):** Required for sign-in and to know who the user is. (Necessary.)
* **`XSRF-TOKEN` (Spring Security CSRF):** Required to protect forms against Cross-Site Request Forgery (especially important for HTMX calls). (Necessary.)

### 5.2 Non-necessary cookies (require a banner)
These are tracking tools, marketing and third-party analytics (e.g. Google Analytics, Meta Pixel).

### 5.3 Our strategy: "Zero Annoyance" (no banner)
Because Matdata 2.0 is primarily an internal tool for the user (we are not going to sell ads based on their browsing behaviour), we can opt out of client-side analytics entirely.

* **Server-side analytics (OpenTelemetry):** As specified in requirement **K10** we use OpenTelemetry for observability. By measuring traffic (number of sign-ins, which endpoints are called, error messages) directly on the Spring Boot server and in GCP, we get all the statistics we need about the app's health *without* setting a tracking cookie in the user's browser.
* **Result:** When a user lands on Matdata 2.0 they simply sign in. No giant "Accept all cookies" pop-up covers the screen. This gives an incredibly premium, fast and clean experience.

### 5.4 OAuth via Google (post-MVP)
When Google OAuth2 is activated (see ADR-009 in [open-decisions.md](open-decisions.md)) the user is sent to `accounts.google.com` to sign in. Because this is a clear user action (clicking "Sign in with Google") no cookie consent of our own is required. The privacy policy must, however, clearly inform that Google becomes a data processor for the OAuth flow.

## 6. Incident handling <a name="incident"></a>

GDPR Article 33 requires personal data breaches to be reported to the supervisory authority (in Sweden: Integritetsskyddsmyndigheten / IMY) within **72 hours** of detection. In case of high risk to individuals' rights, the affected persons must also be informed (Article 34).

A full description of the incident handling process is available in [dpia.md](dpia.md) section 10. Summary:

1. **Detection** via alert, internal report or external signal.
2. **Categorisation** within 4 hours.
3. **Containment** of exposure.
4. **Risk assessment** for individuals.
5. **Notification to IMY** within 72 hours if the risk is judged likely.
6. **Information to affected individuals** in case of high risk.
7. **Post-mortem** is documented and actions added to [risk-register.md](risk-register.md).

## 7. Data processors and DPAs <a name="processors"></a>

| Data processor | Processing | Location | Agreement |
| --- | --- | --- | --- |
| Google Cloud Platform | Hosting, storage, Pub/Sub, observability | EU region (Belgium) | Google Cloud DPA |
| Neon Inc. | Database (PostgreSQL) | EU region selected | Neon's standard DPA |
| E-mail provider (Brevo/Resend, post-MVP) | Transactional e-mail | EU | Provider's DPA |
| Google (OAuth, post-MVP) | Identity at OAuth2 sign-in | Global | The user's own relationship + Google OAuth DPA |

Third-country transfers are assessed in [dpia.md](dpia.md) section 5.

## 8. Summary checklist for the build phase <a name="checklist"></a>

The following items must be ready before the public launch:

### 8.1 Consent and legal basis
1. [ ] **Consent checkbox:** Must be present on the registration page and in the profile for sharing anonymous statistics. Never pre-ticked.
2. [ ] **Consent register:** Timestamp and chosen option are stored in `USERS`. Withdrawn consent is logged in the audit log.
3. [ ] **Legal basis per processing activity:** Documented in [dpia.md](dpia.md) section 3.

### 8.2 Retention and data minimisation
4. [ ] **Cron job for PDF clean-up:** Create a process in GCP/Spring that automatically deletes PDF files older than 30 days, unless the user has explicitly requested to keep them.
5. [ ] **Lifecycle policy on Cloud Storage:** Backup safeguard for the cron job.
6. [ ] **Cron job for session clean-up:** Default 30 days of inactivity.
7. [ ] **Cron job for audit logs:** Default 1-year retention.

### 8.3 User rights (Articles 13–22)
8. [ ] **Privacy policy page:** Write a clear, easy-to-read page (without legalese) that explains the 2 cookies the app uses and why they are needed for the security of the sign-in.
9. [ ] **Export button:** Create an API endpoint that returns account + receipts as JSON or CSV.
10. [ ] **Delete flow:** Button in the profile that triggers full deletion (ON DELETE CASCADE + PDF deletion).
11. [ ] **Rectification flow:** The user can edit profile and e-mail in `/profile`.
12. [ ] **Withdrawal of consent:** A toggle in the profile that removes consent for crowdsourcing.

### 8.4 Security and logging
13. [ ] **PII masking in logs:** Logback masks for e-mail addresses and passwords. Review of all code that logs.
14. [ ] **Audit logs:** Sign-in, consent changes, data export and deletion are logged separately (NFR-D6).
15. [ ] **Incident process:** Template for the IMY notification and contact list updated.
16. [ ] **DPIA review:** [dpia.md](dpia.md) is reviewed before the public launch and annually thereafter.
