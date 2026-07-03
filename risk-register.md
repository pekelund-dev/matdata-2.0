# Risk register: Matdata 2.0

**Version:** 1.0
**Last updated:** 2026-06-29
**Status:** Pre-study ready for review

This document gathers the identified risks in Matdata 2.0. Risks are categorised, assessed and given a mitigation plan with a clear owner. The register is revised before each phase transition (see [project-plan_requirements.md](project-plan_requirements.md)).

## Contents
- [Scale and definitions](#scale-and-definitions)
- [How the register is used](#how-the-register-is-used)
- [Risk overview (matrix)](#risk-overview)
- [Technical risks (T)](#technical-risks)
- [Business and product risks (V)](#business-risks)
- [Security and GDPR risks (S)](#security-risks)
- [Supplier and dependency risks (L)](#supplier-risks)
- [Operational risks (O)](#operational-risks)
- [Financial risks (E)](#financial-risks)

## Scale and definitions <a name="scale-and-definitions"></a>

**Likelihood:**
* **High (H):** Likely to occur during the MVP phase.
* **Medium (M):** May occur, but not likely in the short term.
* **Low (L):** Unlikely during the MVP phase.

**Impact:**
* **High (H):** Threatens delivery, brand or legal compliance.
* **Medium (M):** Delays delivery or significantly worsens the user experience.
* **Low (L):** Manageable, mitigation still required so it does not grow.

**Risk level (combination):**

| Likelihood \\ Impact | Low | Medium | High |
| --- | --- | --- | --- |
| **High** | Medium | High | Critical |
| **Medium** | Low | Medium | High |
| **Low** | Low | Low | Medium |

## How the register is used <a name="how-the-register-is-used"></a>

* Each risk has a unique ID (`T1`, `V1`, etc.) and is referenced from code, comments and documentation.
* The owner is responsible for monitoring the trigger, executing the mitigation and proposing status changes.
* At every phase start (`Phase 1`–`Phase 5`) the register is walked through and the status updated.
* Risks that materialise are moved to `Realised` and get a report in an `Incidents` section (created when needed).

## Risk overview <a name="risk-overview"></a>

| ID | Risk | Likelihood | Impact | Risk level | Owner | Status |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | ICA/Kivra changes the PDF layout | High | High | Critical | Parser developer | Active |
| T2 | Complex EAN logic for weight items | High | Medium | High | Parser developer | Active |
| T3 | OpenTelemetry configuration against GCP does not work as expected | Medium | Medium | Medium | Platform owner | Active |
| T4 | Neon branching per PR introduces unexpected costs or delays | Medium | Medium | Medium | Platform owner | Active |
| T5 | Java 26 / Spring Boot 4.x introduces unexpected bugs (relatively new versions) | Medium | Medium | Medium | Lead developer | Active |
| T6 | Pub/Sub messages are delivered multiple times or out of order | High | Low | Medium | Parser developer | Active |
| V1 | Users upload few receipts and the data volume becomes too small to provide insights | Medium | High | High | Product owner | Active |
| V2 | Supporting only ICA at launch limits the target audience | High | Medium | High | Product owner | Active |
| V3 | Requirement K15 ("Moms-kollen") becomes irrelevant when the VAT reduction normalises | High | Low | Medium | Product owner | Active |
| S1 | Personal data is exposed via incorrect anonymisation | Low | High | Medium | Data protection officer | Active |
| S2 | The sign-in flow contains a vulnerability (e.g. session hijack) | Low | High | Medium | Security officer | Active |
| S3 | Users give consent without understanding what is being shared | Medium | High | High | Data protection officer | Active |
| S4 | Incident without the readiness to report within 72 hours (GDPR Art. 33) | Medium | High | High | Data protection officer | Active |
| L1 | Kivra changes its terms or blocks receipt downloads | Low | High | Medium | Product owner | Active |
| L2 | Neon discontinues free plans or raises prices substantially | Low | Medium | Low | Platform owner | Active |
| L3 | GCP raises prices or removes services (e.g. Pub/Sub) | Low | Medium | Low | Platform owner | Active |
| O1 | Only one developer (key person) on the project | High | High | Critical | Project owner | Active |
| O2 | Outages on Cloud Run or Neon without automatic failover | Medium | Medium | Medium | Platform owner | Active |
| O3 | Security patch or urgent Spring update is missed | Medium | Medium | Medium | Lead developer | Active |
| E1 | Cloud costs spiral out of control during traffic peaks or misconfiguration | Medium | Medium | Medium | Platform owner | Active |
| E2 | OCR/Vision API (K17) becomes more expensive than expected once activated | Low | Medium | Low | Product owner | Active |

## Technical risks (T) <a name="technical-risks"></a>

### T1 — ICA/Kivra changes the PDF layout
* **Description:** The parser is tightly coupled to ICA's current PDF layout. Layout changes break the parsing without warning.
* **Trigger:** Sudden increase in receipts with status `FAILED`, or the canary test (section 6.5 in the project plan) raises an alarm.
* **Mitigation:**
    * Version the parser with a clear store + format version (requirement in project plan 6.4).
    * Scheduled canary test against a reference PDF each week (project plan 6.5).
    * Alert rule in GCP Cloud Monitoring that triggers when the failure rate passes a threshold.
    * Recovery plan: fast hotfix process where an updated parser can be deployed within 24 hours without going through the normal release cycle.
* **Residual risk:** Users experience that the occasional receipt is not processed while a patch is being prepared.

### T2 — Complex EAN logic for weight items
* **Description:** EAN codes with prefix 20–29 contain weight/price within the code. Incorrect masking breaks the price history or creates duplicates.
* **Trigger:** Tests fail, or the product catalogue in the database grows unnaturally fast with "identical" products.
* **Mitigation:**
    * Extensive unit tests with known EAN examples (Phase 2, requirement K3).
    * Migration: ability to retroactively normalise products if incorrect logic is discovered (manual script via DBA role).
    * Documented reference table over handled prefixes.
* **Residual risk:** New stores (K20) may introduce new prefix conventions.

### T3 — OpenTelemetry configuration against GCP does not work as expected
* **Description:** OTel export to GCP Cloud Trace/Logging requires correct configuration. Failure means we lose observability in production.
* **Trigger:** Missing traces or logs in Cloud Trace after deployment.
* **Mitigation:**
    * Integration test that verifies a local trace is exported to a stub.
    * Early smoke test in Phase 3 in a dedicated environment.
    * Backup logging via Cloud Logging directly so that, in the worst case, we still have structured logs.

### T4 — Neon branching per PR introduces unexpected costs or delays
* **Description:** Per-PR branching is new and may introduce long waits or high costs.
* **Trigger:** PR jobs take > 5 minutes for database provisioning, or the monthly cost exceeds the budget in [cost-estimate.md](cost-estimate.md).
* **Mitigation:**
    * Set clear cost alerts in the Neon project.
    * Ability to fall back to a shared test database during large traffic peaks.
    * Automatic teardown at PR close (requirement in Phase 1).

### T5 — Java 26 / Spring Boot 4.x introduces unexpected bugs
* **Description:** Both versions are new and have less community experience behind them.
* **Trigger:** Bugs in the frameworks that block development.
* **Mitigation:**
    * Pin the version of every dependency. Escalation to the next minor only after it has been out > 1 month.
    * Monitor the Spring blog and changelog.
    * Ability to backport to Java 25/Spring 3.x in the worst case.

### T6 — Pub/Sub delivers duplicates or messages out of order
* **Description:** GCP Pub/Sub guarantees at-least-once delivery, not exactly once. Duplicates can cause double parsing.
* **Trigger:** Duplicates of receipts in the database.
* **Mitigation:**
    * Idempotency requirement in `parser-service` (architecture 10.5).
    * Status check (PENDING/COMPLETED) before processing starts.
    * `receipt_id` used as an idempotency key.

## Business and product risks (V) <a name="business-risks"></a>

### V1 — Small data volume yields low insights
* **Description:** For insights (inflation index, shrinkflation, global prices) to be meaningful a critical mass of receipts is required.
* **Trigger:** Users experience the dashboard as empty after onboarding.
* **Mitigation:**
    * UX-design "empty states" that encourage uploads (see [ux-ui_vision.md](ux-ui_vision.md) section on empty states).
    * Import guide that lets the user upload multiple receipts at once during the first onboarding.
    * Show global prices as a reference when the user's own data is small.

### V2 — Only ICA support limits the target audience
* **Description:** Three out of four Swedish households shop at more than just ICA. Supporting only ICA via Kivra excludes the majority.
* **Trigger:** A user survey shows that drop-off happens because "my store is not supported".
* **Mitigation:**
    * The plug-in architecture (K20) is prioritised early in the backlog after MVP.
    * Clear communication: "Today: ICA. Coming: Coop, Hemköp, Willys."
    * Accept the scope during MVP — better to launch with one store that works perfectly.

### V3 — Moms-kollen becomes irrelevant
* **Description:** Requirement K15 is tied to a specific societal issue (the VAT reduction). When the issue cools off the feature loses relevance.
* **Trigger:** Use of "Moms-kollen" declines over time.
* **Mitigation:**
    * Build "Moms-kollen" as a template for thematic views (see [ux-ui_vision.md](ux-ui_vision.md) section 2.5).
    * Plan future thematic campaigns (e.g. seasonal variation, holidays, holiday weeks).

## Security and GDPR risks (S) <a name="security-risks"></a>

### S1 — Incorrect anonymisation leaks personal data
* **Description:** "Anonymised" data may, in the worst case, be de-anonymised if the granularity is too fine (e.g. exact store and exact timestamp).
* **Trigger:** Security review, or report from a user or IMY.
* **Mitigation:**
    * Strict separation in the data model (Privacy by Design, K8).
    * Aggregation to city + month (architecture section 5).
    * Code review of all code that writes to `GLOBAL_PRICE_POINTS`.
    * See [dpia.md](dpia.md) for the full analysis.

### S2 — Sign-in flow is vulnerable
* **Description:** Spring Security is robust but misconfiguration can introduce vulnerabilities (session hijack, missed CSRF, weak passwords).
* **Trigger:** A penetration test finds flaws, or an incident in the logs (many failed sign-ins from the same IP).
* **Mitigation:**
    * Use Spring Security's default configuration as much as possible.
    * BCrypt for passwords, session regeneration after sign-in, HTTPS via Cloud Run.
    * Security tests in CI (see [non-functional-requirements.md](non-functional-requirements.md)).

### S3 — Users give consent without understanding
* **Description:** If the consent flow is unclear the consent is not valid under GDPR.
* **Trigger:** User tests reveal confusion, or IMY complaint.
* **Mitigation:**
    * UX text reviewed by legal and an ordinary user.
    * Consent is never pre-ticked (GDPR checklist in [gdpr.md](gdpr.md)).
    * Ability to withdraw consent at any time in the profile.

### S4 — Lack of incident readiness
* **Description:** GDPR Article 33 requires personal data incidents to be reported to IMY within 72 hours.
* **Trigger:** Incident occurs without a procedure in place.
* **Mitigation:**
    * Document the incident handling process (sub-process in [dpia.md](dpia.md)).
    * Alerts in GCP Cloud Monitoring for anomalies (many failed requests, data-leak patterns).
    * Contact list and template for the IMY notification are ready.

## Supplier and dependency risks (L) <a name="supplier-risks"></a>

### L1 — Kivra changes terms or blocks receipts
* **Description:** Kivra is an external company and may restrict receipt downloads.
* **Trigger:** Users report that they cannot download receipts.
* **Mitigation:**
    * The MVP is user-driven upload, not automatic integration. The risk is therefore borne by Kivra's users, not by us.
    * Backup plan: support for OCR of paper receipts (K17) opens an alternative input.

### L2 — Neon changes pricing plan or discontinues the free tier
* **Description:** Neon is a relatively young company.
* **Trigger:** Price increase or e-mail about changed terms.
* **Mitigation:**
    * All Postgres usage is standard. Migration to Cloud SQL or Supabase is possible.
    * The Terraform provider abstracts the provisioning.

### L3 — GCP raises prices or removes services
* **Description:** Less likely, but possible especially for newer services.
* **Trigger:** GCP announcement or price change.
* **Mitigation:**
    * Pub/Sub, Cloud Run and Cloud Storage are well-implemented standards.
    * Possible to switch platforms with reasonable effort if everything goes via Terraform.

## Operational risks (O) <a name="operational-risks"></a>

### O1 — Single developer (key person dependency)
* **Description:** Only one developer on the project. Illness or absence stops all development.
* **Trigger:** The project lead becomes unavailable.
* **Mitigation:**
    * The pre-study (this document set) is written so that a new developer can get up to speed quickly.
    * All code, infra and documentation is publicly in Git.
    * ADR-light in [open-decisions.md](open-decisions.md) preserves the reasoning behind decisions.

### O2 — Outage on Cloud Run or Neon
* **Description:** No SLA guarantees in the MVP phase.
* **Trigger:** Users report that the service is down.
* **Mitigation:**
    * Multi-zone handling is part of Cloud Run's base operation.
    * Neon snapshot frequency is described in [non-functional-requirements.md](non-functional-requirements.md).
    * Status page during major outages (Could-have post-MVP).

### O3 — Security patch is missed
* **Description:** Spring, Java or container CVE is missed.
* **Trigger:** Dependabot alerts are ignored or slip through.
* **Mitigation:**
    * Dependabot or Renovate enabled on the repo (requirement in Phase 1, added to the checklist).
    * Security updates are prioritised over new features.

## Financial risks (E) <a name="financial-risks"></a>

### E1 — Cloud costs spiral out of control
* **Description:** Misconfigured autoscaling or a loop can generate high bills.
* **Trigger:** Monthly invoice exceeds budget by > 50 %.
* **Mitigation:**
    * Budget alerts in GCP (90 % and 100 % of the monthly budget per [cost-estimate.md](cost-estimate.md)).
    * Caps (`maxScale`) on Cloud Run instances.
    * Pub/Sub messages are filtered so that the DLQ cannot loop.

### E2 — OCR/Vision API becomes more expensive than expected
* **Description:** K17 (OCR) is priced per document and can become expensive at scale.
* **Trigger:** K17 is implemented and the cost exceeds budget.
* **Mitigation:**
    * K17 is "Could have" and is not activated in the MVP.
    * When K17 is activated: test on a small volume first, cost alerts.
    * Ability to switch between Google Vision and Gemini Vision depending on price/performance.
