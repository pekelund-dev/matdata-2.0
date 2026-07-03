# User Stories: Matdata 2.0

| Metadata | |
| --- | --- |
| Version | 1.0 |
| Last updated | 2026-06-29 |
| Status | Pre-study ready for review |
| Place in the documentation | Derives an actionable backlog from [project-plan_requirements.md](project-plan_requirements.md). |

> This document breaks the requirements (K1–K20) and the NFRs down into **epics** and **user stories** with acceptance criteria in Given/When/Then form. Each story has at least 5 AC, a DoD checklist and traceability to K-requirements, NFRs and ADRs. Personas are taken from [ux-ui_vision.md](ux-ui_vision.md) section 1.5.

## Contents
- [1. Conventions](#conventions)
- [2. Overview of epics](#overview)
- [3. Traceability story → requirement](#traceability)
- [4. Epic 1 — Infrastructure and DevOps foundation](#epic-1)
- [5. Epic 2 — Account and authentication](#epic-2)
- [6. Epic 3 — Receipt upload and asynchronous parsing](#epic-3)
- [7. Epic 4 — Personal price history and search](#epic-4)
- [8. Epic 5 — Crowdsourcing and global statistics](#epic-5)
- [9. Epic 6 — Thematic insights (Moms-kollen and shrinkflation)](#epic-6)
- [10. Epic 7 — GDPR and user rights](#epic-7)
- [11. Epic 8 — Design system and accessibility](#epic-8)
- [12. Epic 9 — Observability and operations](#epic-9)

## 1. Conventions <a name="conventions"></a>

### 1.1 Story format
Each story follows the pattern:

> **As** \<persona\> **I want** \<capability\> **so that** \<value\>.

Personas: **Anna** (38, project manager), **Markus** (29, developer), **Sofia** (52, household CFO), **Developer** (internal), **Operations engineer**, **DPO/security reviewer**. See [ux-ui_vision.md](ux-ui_vision.md) §1.5.

### 1.2 Acceptance criteria (AC)
ACs are written in Given/When/Then form. **At least 5 AC per story** is required to capture the main flow, edge cases, error states, security/privacy requirements and measurable NFRs. For backend-only stories a technical verification criterion (test/measurement) may count as an AC.

### 1.3 Definition of Done (story level)
A story is done when:
* [ ] All AC are verified automatically (test) or manually per the PR checklist.
* [ ] Code coverage for new domain logic ≥ 80 % (NFR-M1) where applicable.
* [ ] No open critical or high security vulnerabilities (CVSS ≥ 7.0) in the changed files.
* [ ] Traceability to K-requirements/NFRs/ADRs exists in the PR description.
* [ ] If UI: review per [ux-ui_vision.md](ux-ui_vision.md) §9.3 (empty/error state, keyboard, contrast, screen reader).
* [ ] If a data model change: Flyway migration, indexing strategy and impact on [gdpr.md](gdpr.md)/[dpia.md](dpia.md) reviewed.
* [ ] Documentation updated (relevant `.md` + commit message per Conventional Commits, NFR-M6).

### 1.4 Estimation and priority
Stories inherit priority from the K-requirement they implement (M/S/C/W per MoSCoW). Estimates (story points) are set at sprint planning — they are not stated here.

### 1.5 Story ID
Format: `US-<epic>.<seq>`, e.g. `US-3.2`. The epic ID matches the section number in this document.

## 2. Overview of epics <a name="overview"></a>

| Epic | Theme | Primary requirements | Phase (per [project-plan_requirements.md](project-plan_requirements.md) §3) |
| --- | --- | --- | --- |
| Epic 1 | Infrastructure and DevOps foundation | K6, K7 | Phase 1 |
| Epic 2 | Account and authentication | K5 | Phase 4–5 |
| Epic 3 | Receipt upload and asynchronous parsing | K1, K2, K3, K9, K12 | Phase 2–4 |
| Epic 4 | Personal price history and search | K4, K12 | Phase 2–5 |
| Epic 5 | Crowdsourcing and global statistics | K8, K13, K14 | Phase 3 + post-MVP |
| Epic 6 | Thematic insights (Moms-kollen, shrinkflation) | K15, K16 | Post-MVP (C) |
| Epic 7 | GDPR and user rights | K8 + GDPR Art. 13–22 | Phase 4–5 |
| Epic 8 | Design system and accessibility | K11, K12, NFR-AC1–6 | Phase 4 |
| Epic 9 | Observability and operations | K10, NFR-O1–6, NFR-A1–4 | Phase 3 + Phase 5 |

## 3. Traceability story → requirement <a name="traceability"></a>

| Story | K-requirement | NFR | ADR |
| --- | --- | --- | --- |
| US-1.1 | K6 | NFR-SEC6, NFR-SEC7, NFR-SEC8 | — |
| US-1.2 | K7 | NFR-B5 | ADR-006 |
| US-1.3 | K6 | — | — |
| US-1.4 | K6 | NFR-A1, NFR-A2 | — |
| US-2.1 | K5 | NFR-SEC4, NFR-SEC5 | ADR-009 |
| US-2.2 | K5 | NFR-SEC10 | ADR-009 |
| US-2.3 | K5 | NFR-SEC3 | — |
| US-2.4 | K5 | NFR-D4 | — |
| US-3.1 | K1 | NFR-S4, NFR-P1 | — |
| US-3.2 | K2, K9 | NFR-A3, NFR-A4, NFR-P2 | ADR-002 |
| US-3.3 | K3 | NFR-M1 | — |
| US-3.4 | K12 | NFR-P3 | ADR-005 |
| US-3.5 | K9 | NFR-A4 | — |
| US-4.1 | K4 | NFR-S3 | ADR-003 |
| US-4.2 | K12 | NFR-P4 | ADR-012 |
| US-4.3 | K4 | — | — |
| US-4.4 | K4 | NFR-P1 | ADR-013 |
| US-5.1 | K8, K13 | NFR-D3 | ADR-007 |
| US-5.2 | K13 | — | ADR-007 |
| US-5.3 | K14 | — | — |
| US-6.1 | K15 | — | — |
| US-6.2 | K16 | — | — |
| US-7.1 | K5, K8 | NFR-D6 | — |
| US-7.2 | K8 | — | — |
| US-7.3 | K8 | NFR-D2, NFR-D3 | ADR-007 |
| US-7.4 | K8 | — | — |
| US-8.1 | K11 | NFR-M5 | — |
| US-8.2 | K11, K12 | NFR-AC1–6 | ADR-014 |
| US-9.1 | K10 | NFR-O1, NFR-O2 | — |
| US-9.2 | — | NFR-O3, NFR-O4 | — |
| US-9.3 | — | NFR-A4 | — |

## 4. Epic 1 — Infrastructure and DevOps foundation <a name="epic-1"></a>

**Goal:** Before a single business feature is implemented the repo, CI/CD, IaC and security scanning must be in place so that every PR generates an isolated, runnable environment. Corresponds to **Phase 1** in [project-plan_requirements.md](project-plan_requirements.md) §3.1.

**Requirements:** K6, K7. **NFR:** SEC6, SEC7, SEC8, B5.

### US-1.1 — CI pipeline for PR builds
**As** a developer **I want** every Pull Request to automatically build both Spring Boot services, run unit tests and static analysis **so that** I get fast feedback before merge.

| Field | Value |
| --- | --- |
| Priority | M (K6) |
| Traceability | K6, NFR-SEC6, NFR-SEC7, NFR-SEC8, NFR-M2 |
| Persona | Developer |

**Acceptance criteria:**
1. **Given** a developer opens a PR against `main`, **when** GitHub Actions starts, **then** workflow `build.yml` runs `mvn verify` for both `core-service` and `parser-service` in parallel.
2. **Given** a PR build, **when** the build job runs, **then** CodeQL (NFR-SEC7) and Dependabot report (NFR-SEC6) run and block merge on `error` findings.
3. **Given** a PR build, **when** the code is formatted incorrectly, **then** Spotless or an equivalent formatter (NFR-M2) marks the check as `failed`.
4. **Given** a successful PR build, **when** all checks are green, **then** Docker images are published to GitHub Container Registry with the tag `pr-<no>-<sha>`.
5. **Given** a GCP deploy from CI, **when** the workflow authenticates, **then** Workload Identity Federation (NFR-SEC8) is used — **no** long-lived service-account keys are stored in GitHub Secrets.
6. **Given** a PR build takes > 10 minutes, **when** the build time is measured, **then** a GitHub Actions cache is used for Maven dependencies so the median build time is ≤ 6 minutes.

**DoD:** Workflow file exists under `.github/workflows/`, documented in [architecture.md](architecture.md) §6, green checks required for merge per branch protection.

---

### US-1.2 — Terraform module for the base infrastructure
**As** a developer **I want** the GCP resources (GCS bucket, Pub/Sub topic, Cloud Run services, IAM) and the Neon project to be provisioned via Terraform **so that** environments can be recreated reproducibly.

| Field | Value |
| --- | --- |
| Priority | M (K7) |
| Traceability | K7, NFR-B5, ADR-006 |
| Persona | Developer, Operations engineer |

**Acceptance criteria:**
1. **Given** a new GCP project, **when** `terraform apply` is run from `/terraform`, **then** GCS bucket, Pub/Sub topic `receipt-uploads`, DLQ topic, two Cloud Run services and two service accounts are created without manual steps.
2. **Given** the Terraform modules, **when** `terraform validate` runs in CI, **then** all modules validate and `tflint`/`checkov` flag no open findings with severity ≥ `high`.
3. **Given** an existing environment state, **when** Terraform plans, **then** state is stored remotely (GCS bucket with versioning and lock via Cloud Storage) — never locally.
4. **Given** a Pull Request that changes Terraform code, **when** the PR is opened, **then** CI posts the `terraform plan` output as a PR comment.
5. **Given** the Neon project, **when** Terraform runs, **then** the main branch and the production database role are provisioned via the Neon Terraform provider with budget alerts enabled.
6. **Given** a disaster where the entire GCP project is lost, **when** Terraform is applied against a new project, **then** the whole infrastructure can be recreated in ≤ 1 hour (measured in a recovery test, NFR-B5).

**DoD:** Modules reside under `/terraform/modules/{gcp,neon}/`, documented in [architecture.md](architecture.md) §8, run in CI at least for the dev environment.

---

### US-1.3 — PR environment with Neon database branching
**As** a developer **I want** each PR to get an isolated database and Cloud Run deploy **so that** I can test migrations and new features against a clean environment without affecting prod.

| Field | Value |
| --- | --- |
| Priority | M (K6) |
| Traceability | K6 |
| Persona | Developer |

**Acceptance criteria:**
1. **Given** a new PR is opened, **when** workflow `pr-environment.yml` is triggered, **then** a Neon database branch is created from `main` with the suffix `pr-<no>`.
2. **Given** the PR environment is up, **when** the workflow is complete, **then** a PR comment is published with URLs to `core-service`, `parser-service` and the Neon branch.
3. **Given** two PRs open at the same time, **when** they deploy, **then** they use separate Pub/Sub topics per PR to prevent message clashes.
4. **Given** a PR is closed or merged, **when** workflow `pr-teardown.yml` is triggered, **then** Cloud Run revisions, Pub/Sub topic and Neon branch are deleted within 5 minutes.
5. **Given** a PR deploy that fails, **when** the workflow breaks, **then** the failure is reported as a PR check with a direct link to `get_job_logs` and the Neon branch is deleted regardless of the failure (cleanup step `if: always()`).
6. **Given** that Flyway migrations exist in the PR, **when** the PR environment starts, **then** the migrations run against the PR database branch automatically at deploy.

**DoD:** Workflows exist and have run green at least twice, documented in [architecture.md](architecture.md) §6.1.

---

### US-1.4 — Health and smoke checks after deploy
**As** an operations engineer **I want** every production deploy to be verified with smoke tests **so that** broken releases are caught before users are affected.

| Field | Value |
| --- | --- |
| Priority | M |
| Traceability | K6, NFR-A1, NFR-A2 |
| Persona | Operations engineer |

**Acceptance criteria:**
1. **Given** a deploy to the prod environment, **when** the `core-service` revision gets traffic, **then** `GET /healthz` returns `200 OK` with `status: UP`.
2. **Given** a green health check, **when** the workflow continues, **then** the smoke test runs `GET /login` and verifies that the page responds with `200` and contains a CSRF token.
3. **Given** a failed smoke check, **when** Cloud Run detects the failure, **then** traffic is rolled back to the previous revision (gradual rollout config) within 60 seconds.
4. **Given** a deploy, **when** it succeeds, **then** Cloud Monitoring annotates the deploy event so that the failure rate can be correlated with releases.
5. **Given** a production incident, **when** the team needs to know the most recent deploy, **then** `git tag prod-<date>` exists on the commit corresponding to the current revision.

**DoD:** Smoke test exists in `.github/workflows/deploy.yml`, documented in the release runbook.

## 5. Epic 2 — Account and authentication <a name="epic-2"></a>

**Goal:** Secure, session-based sign-in where the user only sees their own receipts. Corresponds to **Phase 4** + security work in **Phase 5**.

**Requirements:** K5. **NFR:** SEC1–SEC5, SEC10, D4. **ADR:** ADR-009.

### US-2.1 — Registration with e-mail and password
**As** Anna **I want** to be able to create an account with my e-mail and a password **so that** I can start uploading receipts.

| Field | Value |
| --- | --- |
| Priority | M (K5) |
| Traceability | K5, NFR-SEC4, NFR-SEC5, ADR-009 |
| Persona | Anna |

**Acceptance criteria:**
1. **Given** the registration form, **when** Anna enters a valid e-mail and a password ≥ 12 characters, **then** the account is created and she is signed in directly with a new session cookie.
2. **Given** a password that is < 12 characters or that appears in the `pwned-passwords` list, **when** the form is submitted, **then** a plain-language error is shown under the field and the account is **not** created.
3. **Given** that passwords are stored, **when** the record is written to `USERS`, **then** `password_hash` is a BCrypt hash with cost ≥ 12 (NFR-SEC4) and plaintext never remains in logs or in memory after the request.
4. **Given** an already registered e-mail, **when** someone tries to register the same address, **then** the system responds with a generic message ("If the e-mail is new you'll receive a confirmation") so that account existence is not disclosed.
5. **Given** a successful registration, **when** the session is created, **then** Spring Security's session regeneration runs (NFR-SEC5) and the cookie is set as `HttpOnly`, `Secure`, `SameSite=Lax`.
6. **Given** a registration attempt, **when** the user does not actively tick consent for crowdsourcing, **then** `USERS.share_anonymous_data = false` (default), per [gdpr.md](gdpr.md) §8.1.

**DoD:** Endpoint `POST /register` with integration test, documented in [architecture.md](architecture.md) §9.1.

---

### US-2.2 — Sign-in with rate limiting
**As** a user **I want** to be able to sign in with my e-mail and password **so that** I can reach my account, **without** malicious actors being able to brute-force their way in.

| Field | Value |
| --- | --- |
| Priority | M (K5) |
| Traceability | K5, NFR-SEC10 |
| Persona | Anna, Sofia |

**Acceptance criteria:**
1. **Given** correct credentials, **when** the form is submitted, **then** the user is redirected to `/dashboard` with a new session.
2. **Given** wrong credentials, **when** the form is submitted, **then** the error message is generic: "Wrong e-mail or password" (UX §5.2) — no indication of which field was wrong.
3. **Given** 5 failed attempts from the same IP within 10 minutes, **when** a sixth attempt is made, **then** the call returns `429 Too Many Requests` (NFR-SEC10) and a recovery time is shown.
4. **Given** rate limiting is triggered, **when** the event is logged, **then** the record is written to the audit log (NFR-D6) without disclosing whether the e-mail exists in the system.
5. **Given** that a user is already signed in, **when** she visits `/login`, **then** the page redirects to `/dashboard` automatically.
6. **Given** a successful sign-in, **when** the session is reused, **then** Spring Security regenerates the session ID (NFR-SEC5) to protect against session fixation.

**DoD:** Integration tests for 401, 429 and 302; rate-limiter configuration documented.

---

### US-2.3 — Sign-out and CSRF protection
**As** a user **I want** to be able to sign out safely **so that** no one else can continue using my account from my device.

| Field | Value |
| --- | --- |
| Priority | M (K5) |
| Traceability | K5, NFR-SEC3 |
| Persona | Anna, Sofia, Markus |

**Acceptance criteria:**
1. **Given** a signed-in session, **when** the user clicks "Sign out", **then** the session is invalidated server-side and the cookie is cleared in the client.
2. **Given** the sign-out form, **when** the request is submitted, **then** it requires a valid `X-XSRF-TOKEN` header (NFR-SEC3) — GET-based sign-out is blocked.
3. **Given** a signed-out session, **when** the user navigates back via the browser history, **then** protected pages respond with a redirect to `/login` (pages are not cached via `Cache-Control: no-store`).
4. **Given** that HTMX calls are made from a signed-in page, **when** a request is sent, **then** the `X-XSRF-TOKEN` header is included automatically (the pattern is described in [ux-ui_vision.md](ux-ui_vision.md) §3.4).
5. **Given** a sign-out, **when** the event happens, **then** it is logged in the audit log (NFR-D6) with a trace ID.

**DoD:** Endpoint `POST /logout` with tests for CSRF protection and session invalidation.

---

### US-2.4 — Session management across multiple instances
**As** an operations engineer **I want** sessions to be stored in the database (JDBC) **so that** Cloud Run can scale up to several instances without signing the user out.

| Field | Value |
| --- | --- |
| Priority | M |
| Traceability | K5, NFR-D4 |
| Persona | Operations engineer |

**Acceptance criteria:**
1. **Given** two `core-service` instances behind Cloud Run, **when** a user signs in to instance A and the next request goes to instance B, **then** the session is still valid.
2. **Given** Spring Session JDBC, **when** the session is created, **then** the record is written to the `SPRING_SESSION` table in Neon PostgreSQL.
3. **Given** an inactive session for 30 days (NFR-D4), **when** the cleanup job runs daily, **then** the session is deleted from the database.
4. **Given** that a user signs out, **when** the request is handled, **then** the record is deleted directly from `SPRING_SESSION`.
5. **Given** that Neon is temporarily unavailable, **when** session lookup fails, **then** the user gets the error message "Temporary problem, please try again" and an alert is triggered (NFR-A4).

**DoD:** Integration test with Testcontainers, documented in [architecture.md](architecture.md) §9.1.

## 6. Epic 3 — Receipt upload and asynchronous parsing <a name="epic-3"></a>

**Goal:** Implement the basic flow "PDF in → parsed data out" with an asynchronous architecture. Corresponds to **Phase 2–3** + UX in Phase 4.

**Requirements:** K1, K2, K3, K9, K12. **NFR:** A3, A4, P2, P3, M1, S4. **ADR:** ADR-002, ADR-005.

### US-3.1 — PDF upload from Kivra
**As** Anna **I want** to be able to upload a PDF file from Kivra via drag-and-drop **so that** I can register a new receipt.

| Field | Value |
| --- | --- |
| Priority | M (K1) |
| Traceability | K1, NFR-S4, NFR-P1 |
| Persona | Anna |

**Acceptance criteria:**
1. **Given** the upload view, **when** Anna drops a PDF (≤ 10 MB) into the drop zone, **then** the file is uploaded via `POST /api/receipts/upload` and `core-service` returns `202 Accepted` with `receiptId`.
2. **Given** an upload, **when** `core-service` receives the file, **then** the PDF is saved to a private GCS bucket with path `gs://<bucket>/<userId>/<receiptId>.pdf`, with no public URL created.
3. **Given** a file that is not a PDF or is > 10 MB (NFR-S4), **when** the upload is attempted, **then** the request is rejected with `400 Bad Request` and the plain-language error: "The file must be a PDF of at most 10 MB" (UX §5.2).
4. **Given** a successful upload, **when** the record is written, **then** a row in `RECEIPTS` is created with status `PENDING`, `user_id` from the session and `pdf_storage_uri`.
5. **Given** that the record has been created, **when** the upload is complete, **then** a Pub/Sub message `{receiptId, gcsUri, traceId}` is published to topic `receipt-uploads`.
6. **Given** a duplicated upload (same `sha256` hash of the PDF within 24 h), **when** Anna uploads again, **then** the system shows the warning "This receipt has already been uploaded" (UX §5.3) and creates no new `RECEIPTS` record.

**DoD:** Endpoint tested with MockMvc + Testcontainers (Pub/Sub emulator + Postgres), built per the sequence diagram in [architecture.md](architecture.md) §4.1.

---

### US-3.2 — Asynchronous parsing via Parser Service
**As** Anna **I want** my uploaded receipt to be processed in the background **so that** I can see prices and categorisation without waiting in the UI.

| Field | Value |
| --- | --- |
| Priority | M (K2, K9) |
| Traceability | K2, K9, NFR-A3, NFR-P2, ADR-002 |
| Persona | Anna, Markus |

**Acceptance criteria:**
1. **Given** a message on `receipt-uploads`, **when** `parser-service` consumes it, **then** the PDF is fetched from GCS and text is extracted via Apache PDFBox.
2. **Given** a parsed receipt, **when** the data is persisted, **then** `RECEIPT_ITEMS` rows are written linked to `PRODUCTS` (existing or new) and `RECEIPTS.status` is updated to `COMPLETED`.
3. **Given** a receipt of ≤ 5 MB, **when** parsing is performed, **then** the total processing time (from Pub/Sub message to `COMPLETED`) is < 30 seconds p95 (NFR-P2), measured via the `receipt_processing_seconds` metric.
4. **Given** a parser error (the PDF cannot be read), **when** an exception is thrown, **then** `RECEIPTS.status = FAILED` and `failure_reason` is written; the message is not acked and Pub/Sub can retry per policy.
5. **Given** that the same message is delivered twice (at-least-once), **when** `parser-service` starts processing, **then** it checks `RECEIPTS.status` — if `COMPLETED` it acks the message without writing again (idempotency, [architecture.md](architecture.md) §10.5).
6. **Given** successful processing of at least 95 % of 50 reference receipts, **when** acceptance tests run, **then** `parser_success_ratio` ≥ 0.95 (NFR-A3, linked to the release criterion in [project-plan_requirements.md](project-plan_requirements.md) §4.5).

**DoD:** Integration test with 10 real reference PDFs, OTel trace covers the whole flow (NFR-O1).

---

### US-3.3 — EAN/PLU masking for weight items
**As** Markus **I want** weight items (minced meat, cheese, etc.) to be grouped under the same product **so that** the price history is not split per package.

| Field | Value |
| --- | --- |
| Priority | M (K3) |
| Traceability | K3, NFR-M1 |
| Persona | Markus |

**Acceptance criteria:**
1. **Given** an EAN-13 with prefix `20`–`29`, **when** the parser processes the code, **then** the weight/price digits are masked and only the base article number is saved in `PRODUCTS.article_number`.
2. **Given** two receipts with the same weight item but different actual weights, **when** both have been parsed, **then** they point to the **same** row in `PRODUCTS` via the same `article_number`.
3. **Given** a standard EAN (non-weight item, e.g. prefix `73`), **when** the parser processes, **then** no masking occurs and the entire barcode is saved.
4. **Given** a PLU code (loose fruit/vegetables), **when** the parser identifies it, **then** the PLU number is saved in `PRODUCTS.article_number` without being mixed with EAN codes.
5. **Given** the EAN masking logic, **when** unit tests run, **then** ≥ 10 reference PDFs have the expected `article_number` (DoD Phase 2 in [project-plan_requirements.md](project-plan_requirements.md) §4.2) and the test coverage of the domain class is ≥ 80 % (NFR-M1).
6. **Given** an unknown EAN prefix, **when** the parser encounters it, **then** it makes a "safe default" decision (no masking) and logs a `WARN` so the rules can be extended.

**DoD:** Unit tests with reference PDFs, documented in [architecture.md](architecture.md) §4.2.

---

### US-3.4 — HTMX polling for status feedback
**As** Anna **I want** to see real-time status ("Uploading", "Extracting prices", "Done") **so that** I do not have to reload the page manually.

| Field | Value |
| --- | --- |
| Priority | S (K12) |
| Traceability | K12, NFR-P3, ADR-005 |
| Persona | Anna |

**Acceptance criteria:**
1. **Given** a successful upload, **when** `core-service` responds, **then** the HTMX fragment activates polling against `GET /api/receipts/{id}/status` every 2 seconds.
2. **Given** a poll, **when** the endpoint responds, **then** latency is < 100 ms p95 (NFR-P3) — measured via a Cloud Run metric.
3. **Given** that status goes from `PENDING` → `COMPLETED`, **when** the polling receives the new status value, **then** the UI replaces the spinner with a result fragment showing the number of items and the "View the receipt" button (UX §2.2).
4. **Given** that the status goes to `FAILED`, **when** the UI receives that response, **then** an error message is shown: "We couldn't read the receipt. Is it a PDF from Kivra?" (UX §5.2) with a report button.
5. **Given** that the process takes > 30 seconds, **when** it passes the threshold, **then** the UI shows the ongoing status "This is taking a little longer than usual. You can close the page and check back later" (UX §5.2).
6. **Given** that the polling is ongoing, **when** the status becomes `COMPLETED` or `FAILED`, **then** HTMX stops polling automatically via `hx-swap-oob` or `hx-trigger` update — no unnecessary load on the server.

**DoD:** Integration test with Playwright or equivalent (post-MVP), documented in UX §3.4.

---

### US-3.5 — Dead Letter Queue and failure monitoring
**As** an operations engineer **I want** messages that fail repeatedly to land in the DLQ and trigger an alert **so that** we can intervene quickly.

| Field | Value |
| --- | --- |
| Priority | M (K9) |
| Traceability | K9, NFR-A4 |
| Persona | Operations engineer |

**Acceptance criteria:**
1. **Given** a message that fails 5 times, **when** the retry policy is exhausted, **then** the message is moved to topic `receipt-uploads-dlq`.
2. **Given** a message in the DLQ, **when** it lands, **then** a separate handler updates `RECEIPTS.status = FAILED` so the user sees the error in the UI (UX §5.2).
3. **Given** traffic > 0 in the DLQ, **when** Cloud Monitoring detects it, **then** an alert is triggered within 5 minutes (NFR-A4) to the on-call channel.
4. **Given** a DLQ message, **when** the operations engineer reviews it, **then** the payload contains `receiptId`, `traceId` and `failure_reason` so the trace can be followed in Cloud Trace (NFR-O1).
5. **Given** that the operations engineer wants to replay, **when** a script is triggered, **then** the message can be moved back to `receipt-uploads` after manual verification.
6. **Given** that a receipt is in `FAILED` state, **when** Anna sees it in the UI, **then** she can click "Upload again" to retry.

**DoD:** DLQ configured in Terraform, alert documented in [architecture.md](architecture.md) §10.2.

## 7. Epic 4 — Personal price history and search <a name="epic-4"></a>

**Goal:** The user can see their own receipts, search for products and understand their own price development. Corresponds to **Phase 2 (data model)** + **Phase 4–5 (UI)**.

**Requirements:** K4, K12. **NFR:** P1, P4, S3. **ADR:** ADR-003, ADR-012, ADR-013.

### US-4.1 — Normalised data model for receipts and products
**As** a developer **I want** receipts, receipt lines and products to be stored normalised in Neon PostgreSQL **so that** price history per product can be computed efficiently.

| Field | Value |
| --- | --- |
| Priority | M (K4) |
| Traceability | K4, NFR-S3, ADR-003 |
| Persona | Developer |

**Acceptance criteria:**
1. **Given** Flyway migration V1, **when** it runs, **then** the tables `USERS`, `RECEIPTS`, `PRODUCTS`, `RECEIPT_ITEMS`, `GLOBAL_PRICE_POINTS` are created per the schema in [architecture.md](architecture.md) §5.
2. **Given** the schema, **when** `PRODUCTS.article_number` is `UK`, **then** an `INSERT` with an existing article number reuses the product ID (upsert pattern).
3. **Given** the `RECEIPT_ITEMS` table, **when** columns are created, **then** `vat_rate` is included so that Moms-kollen (K15) can be implemented later.
4. **Given** the `USERS` table, **when** the user is deleted, **then** `ON DELETE CASCADE` ensures that all `RECEIPTS` and `RECEIPT_ITEMS` are deleted (GDPR Art. 17, NFR-D2).
5. **Given** the database pool, **when** Hikari is configured, **then** max `maximumPoolSize = 10` per instance (NFR-S3).
6. **Given** a test run, **when** Testcontainers starts PostgreSQL, **then** all Flyway migrations run green and no row in `GLOBAL_PRICE_POINTS` has an FK to `USERS` (anonymisation, K8).

**DoD:** Flyway migration reviewed, ER diagram updated in [architecture.md](architecture.md) §5.

---

### US-4.2 — Product search with autocomplete
**As** Sofia **I want** to be able to search for a product (e.g. "coffee") and get suggestions immediately **so that** I can quickly find the price history.

| Field | Value |
| --- | --- |
| Priority | S (K12) |
| Traceability | K12, NFR-P4, ADR-012 |
| Persona | Sofia, Anna |

**Acceptance criteria:**
1. **Given** the search field, **when** Sofia types ≥ 2 characters, **then** HTMX sends `GET /api/search?q=...` after a 500 ms debounce (UX §3.4).
2. **Given** the search call, **when** SQL runs against `PRODUCTS.name`, **then** prefix matching via `ILIKE` is used against the index `idx_products_name_lower` and `LIMIT 10` is applied.
3. **Given** the search result, **when** the response is returned, **then** latency is < 200 ms p95 (NFR-P4), measured via an own metric.
4. **Given** several matching products, **when** the result is returned, **then** sorting is by popularity (number of `RECEIPT_ITEMS` rows) descending.
5. **Given** an autocomplete response, **when** the UI renders it, **then** the list has `role="listbox"` and the arrow keys work with the keyboard (NFR-AC3, UX §6.3).
6. **Given** no products match, **when** the result is empty, **then** an empty state is shown: "No products found — search among your items or the global statistics" (UX §5.1).

**DoD:** Integration test with 1,000 products, documented in [architecture.md](architecture.md) §12.1.

---

### US-4.3 — Product page with personal price history
**As** Anna **I want** to see how the price of a specific product has changed for **me** over time **so that** I can understand whether an item has become more expensive.

| Field | Value |
| --- | --- |
| Priority | M (K4) |
| Traceability | K4 |
| Persona | Anna, Sofia |

**Acceptance criteria:**
1. **Given** Anna clicks on a product in the search result, **when** the page loads, **then** `GET /products/{id}` shows the product name, category and a line chart with Anna's own prices.
2. **Given** the line chart, **when** it is rendered, **then** the Y-axis is price per unit and the X-axis is purchase date, based on `RECEIPT_ITEMS` for Anna's `user_id` (Row-Level Security via the repository layer).
3. **Given** that Anna has only one purchase of the product, **when** the page is shown, **then** an empty state is shown: "Only one purchase so far. Upload more receipts to see trends" (UX §5.1).
4. **Given** that another user tries to fetch `GET /products/{id}` with a specific `receiptItemId` that does not belong to them, **when** the request is handled, **then** no data is leaked (filter on `user_id` in SQL).
5. **Given** that global statistics are available for the product (`GLOBAL_PRICE_POINTS`), **when** Anna has given consent, **then** a second line shows "Global average price" (cf. [project-plan_requirements.md](project-plan_requirements.md) §3.5).
6. **Given** that no VAT data is present, **when** the page is rendered, **then** the Moms-kollen module is not displayed (depends on US-6.1).

**DoD:** Integration test with two users and verified RLS, documented in [ux-ui_vision.md](ux-ui_vision.md) §2.3.

---

### US-4.4 — Dashboard with monthly expenditure
**As** Anna **I want** to see her total amount for the month on the dashboard **so that** I can quickly get an overview.

| Field | Value |
| --- | --- |
| Priority | M (K4) |
| Traceability | K4, NFR-P1, ADR-013 |
| Persona | Anna, Sofia |

**Acceptance criteria:**
1. **Given** that Anna signs in, **when** `/dashboard` loads, **then** the widget "This month's expenditure" shows the sum of `RECEIPTS.total_amount` for the current calendar month and compares with the same date in the previous month.
2. **Given** that no receipts exist, **when** the dashboard renders, **then** an empty state is shown: "Welcome! Upload your first receipt to see trends" (UX §5.1).
3. **Given** that Anna has ≥ 3 receipts, **when** the dashboard renders, **then** the widget "Latest receipts" also shows the 3 most recent receipts with store, date, total.
4. **Given** the dashboard call, **when** the page renders, **then** TTFB < 500 ms p95 (NFR-P1), measured in Cloud Run.
5. **Given** that category data exists, **when** the donut chart renders, **then** it shows a breakdown by product category — the source for the category is decided in ADR-013.
6. **Given** that a user has disabled consent, **when** the dashboard is shown, **then** no parts of the UI display global statistics (cf. [gdpr.md](gdpr.md) §3.1).

**DoD:** UI test for empty state and full state, documented in [ux-ui_vision.md](ux-ui_vision.md) §2.1.

## 8. Epic 5 — Crowdsourcing and global statistics <a name="epic-5"></a>

**Goal:** Build the anonymised price pool and let the user see global price development — without leaking individual identity. Corresponds to **Phase 3** + post-MVP (K14).

**Requirements:** K8, K13, K14. **NFR:** D3. **ADR:** ADR-007.

### US-5.1 — Anonymised storage of global price data
**As** the DPO **I want** the global price pool to be irreversibly anonymous **so that** GDPR does not apply to these rows.

| Field | Value |
| --- | --- |
| Priority | M (K8, K13) |
| Traceability | K8, K13, NFR-D3, ADR-007 |
| Persona | DPO/security reviewer |

**Acceptance criteria:**
1. **Given** a parsed receipt from a user who has **given consent**, **when** `parser-service` writes to `GLOBAL_PRICE_POINTS`, **then** the record contains only `product_id`, `price`, `city`, `year_month` — **no** FK to `USERS` or `RECEIPTS`.
2. **Given** a receipt, **when** the city is derived, **then** only the city (e.g. "Malmö") is saved — never a specific store or postcode.
3. **Given** the date, **when** the record is created, **then** `year_month` is stored as `YYYY-MM` — never an exact date or timestamp.
4. **Given** that a user has **not** given consent (`share_anonymous_data = false`), **when** the receipt is parsed, **then** no row is written to `GLOBAL_PRICE_POINTS` for that receipt.
5. **Given** a user who deletes their account, **when** `ON DELETE CASCADE` runs, **then** `GLOBAL_PRICE_POINTS` is not affected (it is anonymous) — verified with an integration test.
6. **Given** that a user has < 3 purchases in a specific `(city, year_month, product_id)` aggregate, **when** the aggregate is shown publicly, **then** the data point is filtered out in the frontend to prevent re-identification (k-anonymity ≥ 3, cf. [dpia.md](dpia.md)).

**DoD:** Integration test verifies that `GLOBAL_PRICE_POINTS` lacks PII FKs, code review approved by the DPO.

---

### US-5.2 — Consent for crowdsourcing
**As** Markus **I want** to be able to actively give consent to share my prices anonymously **so that** I can contribute to global statistics.

| Field | Value |
| --- | --- |
| Priority | S (K13) |
| Traceability | K13, ADR-007 |
| Persona | Markus |

**Acceptance criteria:**
1. **Given** the profile page, **when** Markus toggles "Share my prices anonymously", **then** a modal shows exactly what is shared (article, price, city, month) and what is **not** shared, per [gdpr.md](gdpr.md) §2.2.
2. **Given** that Markus confirms in the modal, **when** the request is sent, **then** `USERS.share_anonymous_data = true` and `USERS.consent_updated_at` gets the current timestamp.
3. **Given** the consent event, **when** it is logged, **then** the record is written to the audit log (NFR-D6) with user ID, IP hash and timestamp.
4. **Given** that Markus withdraws the consent, **when** he toggles it off, **then** the flag is set to `false` immediately; previously contributed price points remain because they are anonymised.
5. **Given** that Markus never gave consent, **when** he sees the dashboard, **then** no widgets show global statistics; instead an info box shows: "Activate consent to see global price data" (UX §5.3).
6. **Given** the registration form, **when** Markus creates an account, **then** the consent toggle is **never** pre-ticked ([gdpr.md](gdpr.md) §8.1).

**DoD:** Integration test, UX review of the modal text, audit log verified.

---

### US-5.3 — Open statistics view for global price development (K14)
**As** Markus **I want** to be able to see global price development per product and city **so that** I can compare with my own history and contribute to transparency.

| Field | Value |
| --- | --- |
| Priority | C (K14) |
| Traceability | K14 |
| Persona | Markus |

**Acceptance criteria:**
1. **Given** Markus visits `/statistics/products/{id}`, **when** the page loads, **then** a line chart shows `GLOBAL_PRICE_POINTS` aggregated by `year_month` and `city`.
2. **Given** that Markus filters by city, **when** the filter is activated, **then** the chart updates via HTMX without a page reload.
3. **Given** a product with < 3 data points in a cell, **when** the chart renders, **then** that cell is shown as a gap, not as a misleading number (k-anonymity).
4. **Given** that Markus is signed out, **when** he visits the statistics view, **then** the page is shown because it is "open" — no authentication is required.
5. **Given** that Markus has given consent and has his own data, **when** the page renders, **then** a second line "My price" is shown on the same chart for comparison.
6. **Given** data volume (50,000 price points), **when** the page loads, **then** TTFB < 1 second p95 — aggregation runs in SQL, not in Java (cf. NFR-P1).

**DoD:** Endpoint documented in OpenAPI (NFR-M4), tests with synthetic data.

## 9. Epic 6 — Thematic insights (Moms-kollen and shrinkflation) <a name="epic-6"></a>

**Goal:** Value-add views that drive engagement. Classified as "Could have" in [project-plan_requirements.md](project-plan_requirements.md) §2.3, post-MVP.

**Requirements:** K15, K16.

### US-6.1 — Moms-kollen
**As** Sofia **I want** to see whether my store actually lowered the prices after the VAT reduction **so that** I know whether they kept the margin.

| Field | Value |
| --- | --- |
| Priority | C (K15) |
| Traceability | K15 |
| Persona | Sofia |

**Acceptance criteria:**
1. **Given** Sofia has receipts both before and after a configurable "VAT date", **when** she visits `/insights/vat`, **then** the view shows the average price per product before and after the date based on `RECEIPT_ITEMS.vat_rate`.
2. **Given** that a product's price was reduced ≥ the VAT reduction, **when** the row renders, **then** a green thumbs-up icon is shown: "The store reduced the price according to the VAT" (UX §2.4).
3. **Given** that a product's price is unchanged despite the VAT reduction, **when** the row renders, **then** a red warning triangle is shown: "The store kept the margin" (UX §2.4).
4. **Given** that Sofia lacks receipts from before the date, **when** the view loads, **then** an empty state is shown: "You need receipts from before and after the VAT reduction so we can compare" (UX §5.1) with the CTA "Upload an older receipt".
5. **Given** that the view is computed, **when** the SQL runs, **then** aggregation happens in a single query with `CASE WHEN purchase_date < :momsDate` — no N+1 calls.
6. **Given** that Sofia wants to see the underlying data, **when** she clicks a product row, **then** she is routed to the product page (US-4.3) with the date filter pre-selected.

**DoD:** Configurable `vat_change_date` via `application.yml`, integration test with synthetic data.

---

### US-6.2 — Shrinkflation warning
**As** Sofia **I want** to be warned if the package size has shrunk while the price has been kept **so that** I can spot hidden price increases.

| Field | Value |
| --- | --- |
| Priority | C (K16) |
| Traceability | K16 |
| Persona | Sofia, Anna |

**Acceptance criteria:**
1. **Given** two `RECEIPT_ITEMS` for the same `product_id` where `quantity` has decreased but `price_per_unit` is unchanged or higher, **when** Sofia visits the product page, **then** a yellow/red `badge-warning` shows: "The package shrunk from X to Y but the price per kilo is higher" (UX §2.3).
2. **Given** that the product's current price is compared, **when** the price per kilo is computed, **then** the calculation is shown clearly in the UI: old price/kilo vs new price/kilo.
3. **Given** that a product does not have two data points with different sizes, **when** the page renders, **then** the warning is **not** shown (false-positive protection).
4. **Given** the shrinkflation logic, **when** it is implemented, **then** it is a separate domain class `ShrinkflationDetector` with ≥ 80 % test coverage (NFR-M1).
5. **Given** that the warning is shown, **when** Sofia clicks it, **then** an explanation expands with the definition of shrinkflation and why it is relevant.
6. **Given** that a screen reader is used, **when** the warning renders, **then** it has `role="alert"` and `aria-live="polite"` (UX §6.2).

**DoD:** Unit tests for the detector class, manual UI test on mobile ≤ 320 px (NFR-BR6).

## 10. Epic 7 — GDPR and user rights <a name="epic-7"></a>

**Goal:** Implement Articles 13–22 in the code so that the DPIA is approved before the public launch. Corresponds to **Phase 4–5** + the checklist in [gdpr.md](gdpr.md) §8.

**Requirements:** K5, K8. **NFR:** D2, D3, D6. **ADR:** ADR-007.

### US-7.1 — Audit log for security events
**As** a security reviewer **I want** sign-ins, consent changes, data exports and deletions to be logged separately **so that** I can audit after a possible incident.

| Field | Value |
| --- | --- |
| Priority | M |
| Traceability | K5, K8, NFR-D6 |
| Persona | DPO/security reviewer |

**Acceptance criteria:**
1. **Given** a successful sign-in, **when** the event occurs, **then** a record is written to `AUDIT_LOG` with `user_id`, `event_type=LOGIN`, `ip_hash`, `timestamp`, `trace_id`.
2. **Given** a consent change, **when** the user toggles, **then** a record is written with `event_type=CONSENT_CHANGED` and both the old and the new value.
3. **Given** a data export (US-7.2), **when** it runs, **then** `event_type=DATA_EXPORTED` with format and size is logged.
4. **Given** an account deletion (US-7.4), **when** it runs, **then** `event_type=ACCOUNT_DELETED` is logged before the row is deleted from `USERS`.
5. **Given** audit logs, **when** the retention job runs, **then** records ≥ 1 year old are deleted automatically (NFR-D6).
6. **Given** that a record in `AUDIT_LOG` is written, **when** it is persisted, **then** it is stored in a separate bucket or table with write-protection for the application ("write-once") — tampering must be traceable.

**DoD:** Audit log is documented in [gdpr.md](gdpr.md) §3.1 and [dpia.md](dpia.md) §10.

---

### US-7.2 — Data export (Article 15 + 20)
**As** Anna **I want** to be able to download all my data in JSON or CSV **so that** my right of access and data portability are fulfilled.

| Field | Value |
| --- | --- |
| Priority | M (K8) |
| Traceability | K8 ([gdpr.md](gdpr.md) §3, GDPR Art. 15, 20) |
| Persona | Anna, Markus |

**Acceptance criteria:**
1. **Given** the profile page, **when** Anna clicks "Export my data", **then** a modal lets her choose the format (JSON or CSV).
2. **Given** Anna chooses JSON, **when** `GET /api/profile/export?format=json` runs, **then** the response contains account data, consent history, all `RECEIPTS` and `RECEIPT_ITEMS` belonging to her `user_id`.
3. **Given** Anna chooses CSV, **when** the same endpoint is called with `format=csv`, **then** a ZIP with separate CSV files per table is returned.
4. **Given** that the export is created, **when** the file is delivered, **then** no data about other users leaks — verified with an integration test with two users.
5. **Given** that the export is ready, **when** Anna receives the file, **then** the event is logged in the audit log (US-7.1).
6. **Given** that the export file is generated, **when** it is served, **then** `Content-Disposition: attachment` and `Cache-Control: no-store` are set so that the file is not cached by browsers or proxies.

**DoD:** Integration test with two users, documented in [gdpr.md](gdpr.md) §3.

---

### US-7.3 — Account deletion (Article 17)
**As** Anna **I want** to be able to delete my account completely **so that** I can exercise my right to be forgotten.

| Field | Value |
| --- | --- |
| Priority | M (K8) |
| Traceability | K8, NFR-D2, NFR-D3, ADR-007 ([gdpr.md](gdpr.md) §3) |
| Persona | Anna |

**Acceptance criteria:**
1. **Given** the profile page, **when** Anna clicks "Delete my account", **then** a modal requires her to type "DELETE" in a text field to enable the confirmation button.
2. **Given** double confirmation, **when** Anna confirms finally, **then** `DELETE FROM USERS WHERE id = :userId` triggers `ON DELETE CASCADE` so that `RECEIPTS` and `RECEIPT_ITEMS` are also deleted (NFR-D2).
3. **Given** that the deletion runs, **when** it completes, **then** an asynchronous job deletes all PDFs in GCS for the user's path (`gs://<bucket>/<userId>/*`) within 24 h.
4. **Given** that the account is deleted, **when** Anna tries to sign in, **then** the sign-in flow responds with the generic message "Wrong e-mail or password" (no account-existence leak).
5. **Given** that `GLOBAL_PRICE_POINTS` are anonymous, **when** the deletion runs, **then** these rows are **not affected** (NFR-D3) — verified with an integration test.
6. **Given** the deletion, **when** it is complete, **then** a confirmation e-mail is sent (post-MVP) or an equivalent UI confirmation is shown, and the audit-log record exists (US-7.1).

**DoD:** Integration test with two users, GDPR checklist §8.3 item 10 is complete.

---

### US-7.4 — Withdrawal of consent
**As** Markus **I want** to be able to withdraw my crowdsourcing consent at any time **so that** I have control over my data going forward.

| Field | Value |
| --- | --- |
| Priority | M (K8) |
| Traceability | K8 (GDPR Art. 7.3) |
| Persona | Markus |

**Acceptance criteria:**
1. **Given** that Markus has previously given consent, **when** he toggles it off in the profile, **then** `USERS.share_anonymous_data = false` immediately.
2. **Given** the withdrawal, **when** the event is logged, **then** the audit log (US-7.1) gets `event_type=CONSENT_CHANGED` with old value `true`, new value `false`.
3. **Given** the withdrawal, **when** future receipts are parsed, **then** no row is written to `GLOBAL_PRICE_POINTS`.
4. **Given** already shared price points, **when** Markus withdraws, **then** they remain in `GLOBAL_PRICE_POINTS` (they are anonymous, GDPR does not apply) — the modal explains this clearly.
5. **Given** that Markus changes his mind, **when** he toggles it on again, **then** the flow in US-5.2 runs again and a new audit log is created.
6. **Given** the legal basis "consent" per [gdpr.md](gdpr.md) §2.2, **when** Markus withdraws, **then** no degradation of other services occurs (he can still use the whole app).

**DoD:** Integration test, modal text reviewed by the DPO.

## 11. Epic 8 — Design system and accessibility <a name="epic-8"></a>

**Goal:** Establish a reusable component catalogue and ensure WCAG 2.1 AA. Corresponds to **Phase 4** + AC tests in Phase 5.

**Requirements:** K11, K12. **NFR:** AC1–AC6, M5. **ADR:** ADR-014.

### US-8.1 — Component catalogue at `/dev/components`
**As** a developer **I want** an internal page that shows all reusable Thymeleaf fragments **so that** I can quickly compare and test UI components.

| Field | Value |
| --- | --- |
| Priority | S (K11) |
| Traceability | K11, NFR-M5 |
| Persona | Developer |

**Acceptance criteria:**
1. **Given** `core-service` in the dev profile, **when** the developer goes to `/dev/components`, **then** the page renders all fragments from `fragments/components.html` per the catalogue in [ux-ui_vision.md](ux-ui_vision.md) §3.3.
2. **Given** the route, **when** the prod profile is active, **then** the route returns `404 Not Found` (security — the page must not be publicly accessible).
3. **Given** that a new fragment is added, **when** the developer follows the guide in UX §9.2, **then** the fragment is shown automatically on `/dev/components` without extra configuration.
4. **Given** that HTMX components are shown, **when** the developer clicks them, **then** they respond without a page reload — interaction is tested in isolation (UX §9.2).
5. **Given** each component on the page, **when** it renders, **then** a short explanatory text shows the intended use + a link to the relevant UX section.
6. **Given** that the page becomes long, **when** it is scrolled, **then** a side nav with anchor links to each category exists.

**DoD:** Route enabled only in the dev profile, documented in [ux-ui_vision.md](ux-ui_vision.md) §9.2.

---

### US-8.2 — WCAG 2.1 AA conformance
**As** a user with a disability **I want** to be able to use the whole app with the keyboard and a screen reader **so that** I have the same access as other users.

| Field | Value |
| --- | --- |
| Priority | M |
| Traceability | K11, NFR-AC1, NFR-AC2, NFR-AC3, NFR-AC4, NFR-AC5, NFR-AC6, ADR-014 |
| Persona | User with a disability |

**Acceptance criteria:**
1. **Given** every page in the app, **when** axe-core or pa11y runs in CI (NFR-AC4), **then** no `error`-level violation is reported.
2. **Given** all text, **when** the contrast is measured, **then** the ratio is ≥ 4.5:1 for normal text and ≥ 3:1 for large text (NFR-AC2).
3. **Given** the main flow (sign-in, upload, view receipt), **when** the user uses the keyboard only, **then** all interactive elements are reachable via `Tab` with a visible focus ring (NFR-AC3, UX §6.1).
4. **Given** the main flow, **when** it is tested with NVDA/VoiceOver (NFR-AC5), **then** all actions can be performed without the screen-reader user becoming blocked — at least one manual walkthrough per release.
5. **Given** the user's system has `prefers-reduced-motion`, **when** the UI renders animations, **then** confetti and slide animations are disabled (NFR-AC6, UX §6.4).
6. **Given** modals, **when** they open, **then** they have `role="dialog"`, `aria-modal="true"`, focus is trapped inside the modal, and Esc closes them (UX §6.2).

**DoD:** CI job green, manual screen-reader walkthrough documented, external WCAG audit before the public launch (release criterion).

## 12. Epic 9 — Observability and operations <a name="epic-9"></a>

**Goal:** Make sure we know when the system breaks — and why. Corresponds to **Phase 3** + launch criteria in Phase 5.

**Requirements:** K10. **NFR:** O1, O2, O3, O4, A1, A2, A4.

### US-9.1 — Distributed tracing end-to-end
**As** an operations engineer **I want** every request to be followed as one coherent trace through both `core-service` and `parser-service` **so that** I can quickly debug errors in the asynchronous flow.

| Field | Value |
| --- | --- |
| Priority | M (K10) |
| Traceability | K10, NFR-O1, NFR-O2 |
| Persona | Operations engineer |

**Acceptance criteria:**
1. **Given** a PDF upload, **when** `core-service` receives the request, **then** an OTel span is created with `trace_id` that is propagated to Pub/Sub attributes.
2. **Given** that `parser-service` consumes the message, **when** processing starts, **then** a child span is linked to the same `trace_id` so the entire flow shows up as a single trace in GCP Trace.
3. **Given** structured JSON logs (NFR-O2), **when** log rows are written, **then** each row contains `trace_id` and `span_id` for correlation.
4. **Given** that a user reports an error with a `traceId`, **when** the operations engineer searches, **then** all logs and spans for that `trace_id` can be listed in Cloud Trace within < 1 minute.
5. **Given** that logs are written, **when** PII is detected (e-mail, password), **then** the Logback mask replaces the value with `[redacted]` (NFR-O5).
6. **Given** sampling, **when** traffic increases, **then** the OTel sampler is configured to be adaptive (≥ 100 % in dev, ≤ 10 % in prod).

**DoD:** End-to-end trace verified manually, documented in [architecture.md](architecture.md) §7.2.

---

### US-9.2 — Metrics and dashboards for KPIs
**As** an operations engineer **I want** dashboards for processing time, failure rate and latency **so that** I can follow up on SLOs.

| Field | Value |
| --- | --- |
| Priority | M |
| Traceability | NFR-O3, NFR-O4, NFR-O6 |
| Persona | Operations engineer |

**Acceptance criteria:**
1. **Given** that Micrometer is configured, **when** the app runs, **then** the metrics `http_requests_total`, `receipt_processing_seconds`, `parser_success_ratio` are exported to GCP (NFR-O3).
2. **Given** Cloud Monitoring, **when** the dashboard is opened, **then** widgets show p50/p95/p99 for latency per endpoint, failure rate (5xx) and DLQ depth.
3. **Given** the SLO for TTFB < 500 ms p95 (NFR-P1), **when** the SLO breaks during a 5-min window, **then** an alert policy fires (NFR-O4) to the on-call channel.
4. **Given** the SLO for failure rate < 1 % (NFR-A2), **when** the ratio is exceeded for 10 min, **then** an alert goes to the same channel with a direct link to logs.
5. **Given** dashboards, **when** they are created, **then** they are version-controlled in Terraform — not hand-built in the Cloud Monitoring UI.
6. **Given** that a developer adds a new metric, **when** the PR is merged, **then** documentation is updated in `/observability/README.md` (or equivalent, NFR-M4).

**DoD:** Terraform module `monitoring/`, manual alert test documented.

---

### US-9.3 — DLQ alert and operations runbook
**As** an operations engineer **I want** to be alerted when messages land in the DLQ **so that** I can quickly investigate and possibly replay.

| Field | Value |
| --- | --- |
| Priority | M |
| Traceability | NFR-A4 |
| Persona | Operations engineer |

**Acceptance criteria:**
1. **Given** the Pub/Sub topic `receipt-uploads-dlq`, **when** a message lands, **then** the Cloud Monitoring metric `num_undelivered_messages` increases and an alert fires within 5 min (NFR-A4).
2. **Given** the alert, **when** it is sent, **then** it contains a link to the DLQ in the GCP console and to the runbook page.
3. **Given** the runbook, **when** the operations engineer opens it, **then** it describes step by step how DLQ messages are inspected, how traces are followed and how they are replayed.
4. **Given** that a DLQ message is replayed, **when** it is sent back, **then** the Cloud Monitoring metric `dlq_replay_count` increases and the receipt status is updated to `PENDING` again.
5. **Given** that the DLQ is empty after an incident, **when** Cloud Monitoring detects it, **then** a "recovery" event is logged to close the incident automatically.
6. **Given** quarterly recovery tests (NFR-B4), **when** the test runs, **then** a controlled DLQ scenario is triggered and the whole runbook is exercised.

**DoD:** Runbook in `/docs/runbooks/dlq.md` or equivalent, quarterly drill scheduled.

---

> **Next step:** Each epic becomes a parent issue in GitHub. Each user story becomes a sub-issue linked to its epic. Issues are tagged with `epic` and `user-story` respectively + an area label (`infra`, `auth`, `parsing`, `frontend`, `gdpr`, `observability`, etc.). When a story is started in the implementation phase a PR is created that links to the sub-issue via `Closes #<n>`.
