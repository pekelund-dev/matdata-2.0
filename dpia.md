# Data Protection Impact Assessment (DPIA): Matdata 2.0

**Version:** 1.0
**Last updated:** 2026-06-29
**Status:** Pre-study ready for review
**Responsible:** Data Protection Officer (DPO or equivalent)

This document constitutes a Data Protection Impact Assessment under GDPR Article 35. A DPIA is required when the processing is likely to result in a high risk to the rights and freedoms of natural persons, which is the case here because Matdata 2.0 handles data that may indirectly reveal sensitive information under Article 9 (e.g. health status through purchases of lactose-free products or religion via halal/kosher products).

The DPIA complements [gdpr.md](gdpr.md) (the strategy) and [risk-register.md](risk-register.md) (the risk management). Technical details in [architecture.md](architecture.md) and [non-functional-requirements.md](non-functional-requirements.md) are referenced where relevant.

## Contents
- [1. Processing and purposes](#processing)
- [2. Categories of personal data](#categories)
- [3. Legal basis](#legal-basis)
- [4. Recipients and third parties](#recipients)
- [5. Third-country transfers](#third-country)
- [6. Retention period](#retention)
- [7. Risk assessment](#risks)
- [8. Mitigating measures](#mitigating)
- [9. User rights (complete table)](#rights)
- [10. Incident handling process](#incident)
- [11. Conclusion and decision](#conclusion)
- [12. Revision history](#history)

## 1. Processing and purposes <a name="processing"></a>

Matdata 2.0 processes data in three clearly separated processes:

1. **Account management and sign-in** — to deliver the service.
2. **Receipt handling (personal price history)** — to let the user track their expenses.
3. **Anonymised statistics (crowdsourcing)** — to produce global price statistics. Decoupled from the user.

The sections below must be read against these three processes.

## 2. Categories of personal data <a name="categories"></a>

| Category | Example data | Process | Sensitivity |
| --- | --- | --- | --- |
| Identifiers | E-mail address, OAuth subject ID | Account management | Normal |
| Authentication data | Password hash (BCrypt) | Account management | High |
| Technical data | IP address (logs), session cookie, user agent | Account management | Normal |
| Purchase data (personal) | Store, date, article number, product name, price, quantity | Receipt handling | High (may reveal Art. 9 data) |
| Original receipt | Uploaded PDF | Receipt handling | High |
| Consent records | Timestamp and chosen sharing options | All | Normal |
| Aggregated statistics | Article number, price, city, month | Crowdsourcing | Anonymised (not covered by GDPR) |

No special categories of personal data (Art. 9) are collected *intentionally*. Some items on a receipt can, however, implicitly reveal such information. That is the reason for this DPIA.

## 3. Legal basis <a name="legal-basis"></a>

| Process | Legal basis | Reference |
| --- | --- | --- |
| Account management and sign-in | Contract (Art. 6(1)(b)) | The user creates an account to use the service |
| Receipt handling | Contract (Art. 6(1)(b)) | Core function of the service |
| Crowdsourcing/global statistics | Consent (Art. 6(1)(a)) | Active consent required (checkbox, not pre-ticked) |
| Security logs | Legitimate interest (Art. 6(1)(f)) | Protection against abuse, intrusion detection |
| Audit logs for consent | Legal obligation (Art. 6(1)(c)) | GDPR Art. 7(1) (burden of proof) |

## 4. Recipients and third parties <a name="recipients"></a>

No personal data is shared with third parties for marketing or sales. Data processors:

| Data processor | Processing | Agreement | Headquarters |
| --- | --- | --- | --- |
| Google Cloud Platform (GCP) | Hosting, storage, Pub/Sub, observability | DPA via Google Cloud agreement | EU (Belgium) |
| Neon Inc. | Database (PostgreSQL) | DPA via Neon's standard agreement | EU region selected |
| Brevo / Resend (e-mail) | Transactional e-mail (post-MVP) | DPA per the provider's terms | EU |
| Google (OAuth) | Sign-in if OAuth2 is chosen | Sign-in only, no permanent data sharing beyond subject ID | EU/Global |

## 5. Third-country transfers <a name="third-country"></a>

* All primary data storage takes place in EU regions (Cloud Run, Cloud Storage, Pub/Sub, Neon).
* Google accounts for OAuth2 are handled by Google in their global infrastructure. For users who choose OAuth2 sign-in, transit to a third country can occur.
* GCP is covered by the EU–US Data Privacy Framework and Standard Contractual Clauses (SCC).

## 6. Retention period <a name="retention"></a>

Summarised here. The full retention table is available in [non-functional-requirements.md](non-functional-requirements.md) section 5.

| Data type | Retention | Trigger for deletion |
| --- | --- | --- |
| Account + e-mail | Until the user deletes | User action, automatic after 24 months of inactivity |
| Password hash | Until the user deletes | User action |
| Personal receipt items | Until the user deletes | User action (ON DELETE CASCADE) |
| Original PDF | 30 days (default) or until the user deletes | Cron job + user action |
| Anonymised statistics | Permanent | Not affected by account deletion (not personal data) |
| Audit logs for consent | 1 year | Scheduled deletion |
| General logs | 30 days | Default in Cloud Logging |

## 7. Risk assessment <a name="risks"></a>

The risks are grouped along three dimensions: confidentiality, integrity and availability. Scale per [risk-register.md](risk-register.md).

| ID | Risk | Likelihood | Impact | Risk level |
| --- | --- | --- | --- | --- |
| DPIA-R1 | Unauthorised party reads another user's receipts | Low | High | Medium |
| DPIA-R2 | The anonymisation is insufficient and can be reversed | Low | High | Medium |
| DPIA-R3 | PDF in Cloud Storage exposed via incorrect ACL | Low | High | Medium |
| DPIA-R4 | User does not understand the scope of the consent | Medium | High | High |
| DPIA-R5 | Forgetful user keeps sensitive PDFs longer than desired | Medium | Medium | Medium |
| DPIA-R6 | Unintentional profiling arises (basket analysis per user) | Low | Medium | Low |
| DPIA-R7 | Incident not detected in time for the 72-hour reporting deadline | Medium | High | High |
| DPIA-R8 | Logs contain PII (e-mail address, IP) in plain text | Medium | Medium | Medium |
| DPIA-R9 | User cannot export all their data | Low | Medium | Low |
| DPIA-R10 | User cannot have their data deleted quickly enough | Low | Medium | Low |

## 8. Mitigating measures <a name="mitigating"></a>

| Risk ID | Measure | Where it is implemented |
| --- | --- | --- |
| DPIA-R1 | Row-Level Security in PostgreSQL + verification that all repository calls are tied to `user_id` | [architecture.md](architecture.md) section 7.1 |
| DPIA-R2 | Anonymisation aggregated to `city` + `month`, never exact store or timestamp; test cases in the parser suite | [architecture.md](architecture.md) section 5 |
| DPIA-R3 | Private Cloud Storage bucket, access only via signed URLs or service account; IaC audits the policy | [architecture.md](architecture.md) section 8 |
| DPIA-R4 | UX text reviewed, consent is never pre-ticked, separate "Help" explains the consequence | [gdpr.md](gdpr.md) section 5 |
| DPIA-R5 | Default 30-day PDF retention + clear choice at upload | [non-functional-requirements.md](non-functional-requirements.md) NFR-D1 |
| DPIA-R6 | No automatic profiling. Insight features such as the inflation index are aggregated and shown only to the user themselves. | [architecture.md](architecture.md) section 5 |
| DPIA-R7 | Alerts in Cloud Monitoring, documented process (section 10 below) | This document |
| DPIA-R8 | Logback mask for e-mail and password; PII review in code review | [non-functional-requirements.md](non-functional-requirements.md) NFR-O5 |
| DPIA-R9 | Export function (JSON or CSV) available from MVP | [gdpr.md](gdpr.md) section 3 |
| DPIA-R10 | Delete button uses `ON DELETE CASCADE` and deletes PDFs in the same transaction or via an asynchronous job with an audit log | [gdpr.md](gdpr.md) section 3 |

## 9. User rights (complete table) <a name="rights"></a>

GDPR provides eight main rights (Articles 13–22). The matrix shows how Matdata 2.0 handles each one.

| Right | Article | How Matdata 2.0 supports it |
| --- | --- | --- |
| Right to information | Art. 13, 14 | Privacy policy published at registration. Also shown at `/profile/privacy`. |
| Right of access | Art. 15 | "Export my data" produces JSON/CSV. Also contains logs of consent. |
| Right to rectification | Art. 16 | The user can edit profile and e-mail at `/profile`. Receipt items can be corrected manually if incorrect (planned post-MVP). |
| Right to erasure ("the right to be forgotten") | Art. 17 | "Delete my account" deletes account + receipts (ON DELETE CASCADE) + PDFs. Anonymous statistics remain. |
| Right to restriction of processing | Art. 18 | The user can withdraw consent for crowdsourcing at any time. Account deactivation (deregistering without deletion) is offered post-MVP. |
| Right to data portability | Art. 20 | Same export feature as the right of access. Formats: JSON and CSV. |
| Right to object | Art. 21 | Legitimate interest is used only for security logs. Objections are handled manually. |
| Rights related to automated decision-making | Art. 22 | Matdata 2.0 does not make automated decisions with legal or similar effect. |

## 10. Incident handling process <a name="incident"></a>

In the event of a personal data incident (GDPR Art. 33–34) Matdata 2.0 follows this process:

1. **Detection:** Incident is identified via alert (Cloud Monitoring), manual report from a user or security partner. Time is noted.
2. **Categorisation:** Within 4 hours the type (confidentiality, integrity, availability), scope and affected categories are determined.
3. **Containment:** Vulnerability is closed (rollback, patch, blocking). Forensic collection of relevant logs.
4. **Risk assessment for affected individuals:** Assessment of whether the incident "is likely to result in a risk" or "is likely to result in a high risk" per Art. 33–34.
5. **Notification to IMY:** If the risk is assessed as likely, the incident is reported to Integritetsskyddsmyndigheten (the Swedish supervisory authority) within 72 hours of detection. A notification template is prepared ahead of the MVP launch.
6. **Inform affected individuals:** In the case of a high risk, users are informed without undue delay, in plain language.
7. **Post-mortem:** Incident is documented, root cause analysed, actions added to [risk-register.md](risk-register.md) and the issue tracker.

The contact list is updated ahead of the MVP launch. Until then the sole responsible contact is the project owner.

## 11. Conclusion and decision <a name="conclusion"></a>

This DPIA shows that the processing in Matdata 2.0 **can be carried out** provided that:

* All mitigating measures in section 8 are implemented before the public launch.
* The consent flow for crowdsourcing is tested and reviewed.
* The incident handling process is documented and the contact list is current.
* The anonymisation logic has unit tests and is code-reviewed by at least one independent reviewer.
* The user rights in section 9 have working functionality in place at the latest by the public launch.

**Need for prior consultation with IMY:** Judged not to be necessary based on the planned architecture, because the risks are mitigated to an acceptable level. The judgement is revised if the scope is expanded (e.g. if health data is collected explicitly or if profiling is activated).

## 12. Revision history <a name="history"></a>

| Version | Date | Description |
| --- | --- | --- |
| 1.0 | 2026-06-29 | Initial DPIA produced as part of the pre-study. |
