# Project plan and requirement matrix: Matdata 2.0

| Metadata | |
| --- | --- |
| Version | 1.0 |
| Last updated | 2026-06-29 |
| Status | Pre-study ready for review |
| Place in documentation | Steering document for requirements and roadmap. |

> This is the steering document for requirements and development phases. For other documents, see [README.md](README.md).

## Contents
- [1. Introduction and purpose](#purpose)
- [2. Requirement matrix (MoSCoW)](#matrix)
- [3. Development phases (roadmap)](#phases)
- [4. Definition of Done per phase](#dod)
- [5. Release criteria](#release)
- [6. Test strategy](#test)
- [7. Traceability between requirements and documents](#traceability)
- [8. Change management](#change)

## 1. Introduction and purpose <a name="purpose"></a>

This document acts as the steering document for the development of Matdata 2.0. Before any code is written, we establish here exactly *what* is to be built (requirement matrix) and in *what order* it is to be built (roadmap).

The purpose is to maintain focus on the Minimum Viable Product (MVP) and ensure that the skills-development goals within Java 26, Spring Boot 4.x, GCP and Terraform are achieved systematically, while the platform is future-proofed for global price statistics.

The vision and background are described in [prestudy.md](prestudy.md). The architecture that supports the requirements is described in [architecture.md](architecture.md). Non-functional requirements (performance, security, accessibility) are in [non-functional-requirements.md](non-functional-requirements.md). User-centred design requirements are in [ux-ui_vision.md](ux-ui_vision.md).

## 2. Requirement matrix (MoSCoW) <a name="matrix"></a>

The MoSCoW method is used to make priorities clear for the first version (MVP) of the system. Each requirement is traceable and refers — where relevant — to the corresponding NFR in [non-functional-requirements.md](non-functional-requirements.md) or ADR in [open-decisions.md](open-decisions.md).

### 2.1 M — Must Have (critical requirements for MVP)
*The system has no value without these.*

| ID | Requirement | Reference |
| --- | --- | --- |
| K1 | The application must be able to receive an uploaded PDF file (ICA receipt via Kivra). | [architecture.md](architecture.md) section 4 |
| K2 | The system must be able to extract text from the PDF via Apache PDFBox. | [architecture.md](architecture.md) section 4 |
| K3 | The system must be able to identify root article numbers (EAN/PLU) and handle or mask weight items so that they are grouped correctly. | [architecture.md](architecture.md) section 4.1 |
| K4 | Data must be stored in a normalised relational database (Neon PostgreSQL). | [architecture.md](architecture.md) section 5, ADR-003 |
| K5 | A user must be able to sign in securely and only see their own receipts. | [architecture.md](architecture.md) section 9, ADR-009 |
| K6 | A CI/CD pipeline via GitHub Actions must be in place from day 1, including PR environments with database branching. | [architecture.md](architecture.md) section 8 |
| K7 | Infrastructure must be provisioned via Terraform (IaC). | ADR-006 |
| K8 | (Privacy by Design) The data model and architecture must from the start be designed to strictly separate personally linked receipts from global price data. | [gdpr.md](gdpr.md), [dpia.md](dpia.md) |

### 2.2 S — Should Have (important, but the app survives initially without)
*Strongly recommended for a good architecture and UX.*

| ID | Requirement | Reference |
| --- | --- | --- |
| K9 | Split into two micro-services (`core-service` and `parser-service`) that communicate asynchronously via GCP Pub/Sub. | ADR-002, [architecture.md](architecture.md) section 2 |
| K10 | Observability via OpenTelemetry (traces and logs exported to GCP). | NFR-O1, NFR-O2 |
| K11 | UI component catalogue (Kitchen Sink) set up at a specific internal route (`/dev/components`) with Thymeleaf fragments. | [ux-ui_vision.md](ux-ui_vision.md) section 3 |
| K12 | HTMX polling for receipt upload so the user sees status "Processing…" without a page reload. | [ux-ui_vision.md](ux-ui_vision.md) section 2.2 |
| K13 | (Crowdsourcing engine) Logic in `parser-service` that automatically cleans and saves incoming receipt prices to an anonymised global price pool decoupled from the user. | [gdpr.md](gdpr.md) section 2.2, ADR-007 |

### 2.3 C — Could Have (bonus features, good for the backlog)
*Can be added if time or budget allows.*

| ID | Requirement | Reference |
| --- | --- | --- |
| K14 | An open statistics view where users can see global price development for items based on aggregated data. | [architecture.md](architecture.md) data model `GLOBAL_PRICE_POINTS`, [ux-ui_vision.md](ux-ui_vision.md) section 5.3 |
| K15 | Analysis view "Moms-kollen" to compare prices before and after a specific date. | [architecture.md](architecture.md) data model `RECEIPT_ITEMS.vat_rate` |
| K16 | Detection and warning system for shrinkflation if the package size shrinks but the price stays the same. | [ux-ui_vision.md](ux-ui_vision.md) section 2.3 |
| K17 | Support for paper receipts via OCR (Google Cloud Vision API or Gemini Vision). | [cost-estimate.md](cost-estimate.md) (potential cost item post-MVP) |
| K20 | Support for additional store formats (Coop, Hemköp, Willys) via a plug-in-based parser system. | [risk-register.md](risk-register.md) V2 |

### 2.4 W — Won't Have (outside the scope of this phase)
*Actively deprioritised to keep the project manageable.*

| ID | Requirement | Reason |
| --- | --- | --- |
| K18 | Integration directly with Kivra's or the banks' APIs (Open Banking). | The API is not publicly available. Rejected in [open-decisions.md](open-decisions.md) section "Rejected proposals". |
| K19 | Dedicated native iOS and Android apps. | Too high a cost. Web/PWA is sufficient. Rejected in [open-decisions.md](open-decisions.md). |

### 2.5 Traceability matrix (short)
The complete traceability between requirements and documentation is in [section 7](#traceability). Here is a summary of which phases address each requirement:

| Requirement | Phase 1 | Phase 2 | Phase 3 | Phase 4 | Phase 5 |
| --- | --- | --- | --- | --- | --- |
| K1–K2 | | × | × | | |
| K3 | | × | | | |
| K4 | × | × | × | | |
| K5 | | | | × | × |
| K6 | × | | | | |
| K7 | × | | | | |
| K8 | | × | × | | |
| K9 | | | × | | |
| K10 | | | × | | |
| K11–K12 | | | | × | |
| K13 | | | × | | |
| K14–K16 | | | | | (post-MVP) |

## 3. Development phases (roadmap) <a name="phases"></a>

To avoid building too much at once the project is divided into logical phases. Each phase must result in working, deployed code and meet its own Definition of Done criteria (see [section 4](#dod)).

### 3.1 Phase 1: Foundation (infrastructure and environment)
*Goal: An empty "Hello World" project that deploys automatically.*

Before this phase starts the following must be ready: review of the pre-study, acceptance of [risk-register.md](risk-register.md) and [cost-estimate.md](cost-estimate.md), and confirmation of the GDPR strategy per [gdpr.md](gdpr.md).

1. Create the GitHub repo (`matdata-monorepo`).
2. Set up the Terraform project (`/terraform`) and provision the GCS bucket, Pub/Sub topic and Neon database project.
3. Configure Workload Identity Federation between GitHub Actions and GCP (NFR-SEC8).
4. Generate an empty Spring Boot 4 application (Java 26).
5. Set up GitHub Actions that compile the code, build the Docker image and deploy to Cloud Run. Configure Neon DB branching for PRs.
6. Enable Dependabot and GitHub CodeQL (NFR-SEC6, NFR-SEC7).

### 3.2 Phase 2: Technical spike (PDF, domain logic and anonymisation)
*Goal: Prove that we can actually read the data and model it safely.*

1. Implement the database schema via Flyway. **Important:** Create separate tables for the user's own receipt items (`receipt_items`) and the global anonymised price data (`global_price_points`). The data model is specified in [architecture.md](architecture.md) section 5.
2. Build isolated Java logic with Apache PDFBox to load an ICA PDF.
3. Write unit tests with regex and domain logic that prove we can strip the weight out of weight items' barcodes (EAN prefix 20–29).
4. Implement the reference PDF in the canary test per section 6.5.

### 3.3 Phase 3: Core backend and asynchronous flow
*Goal: Get the architecture with Pub/Sub working.*

1. Separate the project into `core-service` and `parser-service` per ADR-002.
2. Integrate OpenTelemetry (OTel) in both services (NFR-O1).
3. Create an API endpoint in `core-service` to upload a file → save to GCS → send a message to Pub/Sub.
4. Let `parser-service` consume the Pub/Sub message, download the PDF from GCS and parse the data.
5. Save both the personal receipt linked to the user **and** the anonymous global price pool (`global_price_points`) decoupled from `users` (ADR-007).
6. Implement idempotency handling for Pub/Sub (cf. [risk-register.md](risk-register.md) T6) and configure a DLQ (NFR-A4).

### 3.4 Phase 4: Front end and design system
*Goal: Give the application a face with Thymeleaf and Tailwind.*

Before this phase starts the following ADRs must be closed: ADR-011 (chart library), ADR-012 (search architecture), ADR-013 (product categories), ADR-014 (accessibility tooling).

1. Take AI-generated Tailwind code from Stitch and split it into reusable Thymeleaf fragments (cards, buttons, tables).
2. Create the hidden `/dev/components` route (K11) per [ux-ui_vision.md](ux-ui_vision.md) section 3.
3. Build the dashboard view per [ux-ui_vision.md](ux-ui_vision.md) section 2.1.
4. Build the search function and receipt upload with HTMX (K12).
5. Set up Spring Security for sign-in and sign-out with BCrypt cost ≥ 12 (NFR-SEC4).
6. Implement the CSP header, CSRF protection and rate limiting on authentication endpoints (NFR-SEC2, NFR-SEC3, NFR-SEC10).

### 3.5 Phase 5: Polish and MVP launch
*Goal: Verify that everything fits together and is ready for daily use.*

1. Implement Row-Level Security checks in the database layer (K5).
2. Build the product detail view with price history charts, possibly with a chart line for "Your price" and a line for "Global average price".
3. Test with real receipts (at least 50 different receipts to verify ≥ 95 % parsing accuracy per [prestudy.md](prestudy.md) section 7.1).
4. Ensure logging and alerts in GCP per NFR-O4 and NFR-A4.
5. Perform an external security review per NFR-SEC9.
6. Verify the GDPR checklist in [gdpr.md](gdpr.md) section 8.
7. Perform a DPIA review per [dpia.md](dpia.md).
8. Acceptance test of WCAG 2.1 AA per NFR-AC1.

## 4. Definition of Done per phase <a name="dod"></a>

A phase is done when **all** of the criteria below are met. This couples the phase to measurable requirements and NFRs.

### 4.1 DoD — Phase 1
* [ ] Repo `matdata-monorepo` exists on GitHub with the correct directory structure ([architecture.md](architecture.md) section 14).
* [ ] Terraform applies the baseline infrastructure without manual intervention.
* [ ] GitHub Actions runs build + test + deploy on every PR.
* [ ] Neon DB branching creates a new isolated database on each PR.
* [ ] Dependabot and CodeQL are enabled.
* [ ] `core-service` answers `GET /healthz` via Cloud Run.

### 4.2 DoD — Phase 2
* [ ] Flyway migrations set up the data model per [architecture.md](architecture.md) section 5.
* [ ] Unit tests for PDF parsing reach at least 80 % line coverage on domain classes (NFR-M1).
* [ ] EAN masking for weight items is verified against at least 10 reference PDFs.
* [ ] The anonymisation in `global_price_points` is verified — no link to `users` or exact timestamp.

### 4.3 DoD — Phase 3
* [ ] The Pub/Sub flow runs from `core-service` to `parser-service` and back.
* [ ] OpenTelemetry traces cover the entire upload flow (NFR-O1).
* [ ] DLQ is configured and alerts on traffic (NFR-A4).
* [ ] Idempotency handling verified via a test that sends the same message twice.
* [ ] Structured JSON logs with trace ID (NFR-O2).

### 4.4 DoD — Phase 4
* [ ] All MVP pages render correctly in Chrome, Safari, Edge and mobile (NFR-BR1–NFR-BR6).
* [ ] Spring Security protects all relevant endpoints (CSRF, session regeneration).
* [ ] HTMX polling works for receipt upload without a page reload.
* [ ] `/dev/components` shows all UI components.
* [ ] Rate limiting on the authentication endpoints is active.
* [ ] axe-core or equivalent accessibility linter runs in CI (NFR-AC4).

### 4.5 DoD — Phase 5 (MVP launch)
* [ ] All "Must Have" requirements (K1–K8) are met and verified.
* [ ] WCAG 2.1 AA audit has been performed (NFR-AC1).
* [ ] The GDPR checklist in [gdpr.md](gdpr.md) section 8 is ticked off.
* [ ] DPIA review performed and approved.
* [ ] External security review performed (NFR-SEC9).
* [ ] Successful disaster recovery drill performed (NFR-B4).
* [ ] Manual test cases for at least 50 different receipts — ≥ 95 % accuracy ([prestudy.md](prestudy.md) section 7.1).

## 5. Release criteria <a name="release"></a>

Before Matdata 2.0 is considered ready for public launch the following gates must be passed:

### 5.1 Technical criteria
* [ ] All DoD criteria for Phases 1–5 are ticked off.
* [ ] No **critical** or **high** security bugs are open (CVSS ≥ 7.0).
* [ ] No open ADRs remain that block Phase 4 (see [open-decisions.md](open-decisions.md)).
* [ ] Smoke tests pass green in the prod environment after deploy.

### 5.2 Legal and compliance criteria
* [ ] DPIA is performed and approved per [dpia.md](dpia.md).
* [ ] Data processing agreements (DPA) are in place with all data processors ([gdpr.md](gdpr.md) section 7).
* [ ] Privacy policy is published.
* [ ] Cookie strategy is documented ("Zero Annoyance", [gdpr.md](gdpr.md) section 5.3).
* [ ] Incident process is documented and rehearsed ([dpia.md](dpia.md) section 10).

### 5.3 Operations criteria
* [ ] Alerts are configured for SLO breaches (NFR-O4) and DLQ (NFR-A4).
* [ ] On-call/escalation chain is documented.
* [ ] Backup routine is verified (NFR-B4).
* [ ] Cost monitoring and budget alerts are active ([cost-estimate.md](cost-estimate.md) section 7).

### 5.4 Product criteria
* [ ] User tests with at least 5 people from the target audience ([prestudy.md](prestudy.md) section 2) are performed and feedback addressed.
* [ ] Manual testing of the main flow (registration, sign-in, upload, search, deletion) is approved.
* [ ] Onboarding guide or introduction exists for new users ([ux-ui_vision.md](ux-ui_vision.md)).

## 6. Test strategy <a name="test"></a>

### 6.1 Unit tests
* JUnit 5 and Mockito are used as the standard frameworks.
* The focus is particularly on Parser Service domain logic, e.g. EAN masking and logic for weight items.
* The aim is for all business-critical business logic to be covered by unit tests. Specific target: ≥ 80 % line coverage on domain classes (NFR-M1).

### 6.2 Integration tests
* Spring Boot Test and Testcontainers are used for integration tests.
* PostgreSQL runs in a container to verify the repository layer, Flyway migrations and Pub/Sub integration (emulator).
* Neon DB branching is used for PR environments where more realistic verification is needed against shared cloud infrastructure.

### 6.3 End-to-end tests
* For the MVP manual testing with real ICA and Kivra PDFs in the PR environment is prioritised.
* Automated end-to-end tests are introduced post-MVP, for example with Playwright. The tooling decision is tied to ADR-014 in [open-decisions.md](open-decisions.md).

### 6.4 Parser version management and extensibility
* The parser is designed with a strategy or plug-in pattern so that new store formats can be added without modifying existing parsers.
* Each parser is identified by store and format version, so that layout changes at ICA or future players such as Coop, Hemköp and Willys can be handled in a controlled way (K20).

### 6.5 Monitoring of PDF layout changes (canary)
* A canary test runs weekly against a stored reference PDF.
* If the parsing result changes without an intended code change the test must alert, so that layout changes in source PDFs are detected early (mitigation for T1 in [risk-register.md](risk-register.md)).
* The canary test runs as a scheduled GitHub Actions job.

### 6.6 Security tests
* SAST: GitHub CodeQL (NFR-SEC7).
* Dependency scanning: Dependabot (NFR-SEC6).
* Container scanning: Trivy or equivalent in CI.
* External security review before the public launch (NFR-SEC9).

### 6.7 Accessibility tests
* axe-core or pa11y in CI (NFR-AC4). Tool choice in ADR-014.
* Manual tests with a screen reader (NVDA or VoiceOver) before launch (NFR-AC5).

### 6.8 Performance tests
* Load tests with k6 or Gatling are done before the public launch.
* Verifies the SLOs in [non-functional-requirements.md](non-functional-requirements.md) section 1.

## 7. Traceability between requirements and documents <a name="traceability"></a>

To keep the requirements anchored in the rest of the documentation the following traceability matrix is used. It is supplemented as needed by references directly in the requirements (see [section 2](#matrix)).

| Requirement | Short description | NFR | ADR | Architecture | UX/UI |
| --- | --- | --- | --- | --- | --- |
| K1 | PDF upload | NFR-S4 | — | [architecture.md](architecture.md) §4 | [ux-ui_vision.md](ux-ui_vision.md) §2.2 |
| K2 | Text extraction (PDFBox) | NFR-P2 | — | [architecture.md](architecture.md) §4 | — |
| K3 | EAN/PLU handling | — | — | [architecture.md](architecture.md) §4.1 | — |
| K4 | Normalised database | NFR-S3 | ADR-003 | [architecture.md](architecture.md) §5 | — |
| K5 | Secure sign-in + isolation | NFR-SEC1–SEC5 | ADR-009 | [architecture.md](architecture.md) §9 | [ux-ui_vision.md](ux-ui_vision.md) §2.5 |
| K6 | CI/CD with PR environments | NFR-SEC8 | — | [architecture.md](architecture.md) §8 | — |
| K7 | Terraform IaC | NFR-B5 | ADR-006 | [architecture.md](architecture.md) §8 | — |
| K8 | Privacy by Design | NFR-D1–D8 | ADR-007 | [architecture.md](architecture.md) §5, [gdpr.md](gdpr.md), [dpia.md](dpia.md) | — |
| K9 | Two micro-services + Pub/Sub | NFR-A3, NFR-A4 | ADR-002 | [architecture.md](architecture.md) §2 | — |
| K10 | OpenTelemetry | NFR-O1, NFR-O2 | — | [architecture.md](architecture.md) §11 | — |
| K11 | Component catalogue `/dev/components` | NFR-M5 | — | — | [ux-ui_vision.md](ux-ui_vision.md) §3 |
| K12 | HTMX polling | NFR-P3 | ADR-005 | [architecture.md](architecture.md) §2.2 | [ux-ui_vision.md](ux-ui_vision.md) §2.2 |
| K13 | Crowdsourcing engine | NFR-D3 | ADR-007 | [architecture.md](architecture.md) §5 | — |
| K14 | Open statistics view | — | — | data model `GLOBAL_PRICE_POINTS` | [ux-ui_vision.md](ux-ui_vision.md) §5.3 |
| K15 | Moms-kollen | — | — | data model `vat_rate` | [ux-ui_vision.md](ux-ui_vision.md) §2.4 |
| K16 | Shrinkflation warning | — | — | — | [ux-ui_vision.md](ux-ui_vision.md) §2.3 |
| K17 | OCR support | NFR-P2 | — | (post-MVP) | — |
| K20 | Pluggable parsers | — | — | (post-MVP) | — |

## 8. Change management <a name="change"></a>

Each new requirement or significant change to an existing requirement must:

1. Be described in a GitHub Issue with a clear motivation.
2. Be classified per MoSCoW.
3. If it is an architecture decision: create a new ADR in [open-decisions.md](open-decisions.md).
4. If it affects an NFR: update [non-functional-requirements.md](non-functional-requirements.md).
5. If it affects data protection: update [gdpr.md](gdpr.md) and [dpia.md](dpia.md).
6. Risk assessment: update [risk-register.md](risk-register.md) if the risk changes.
7. Cost assessment: update [cost-estimate.md](cost-estimate.md) if the cost picture changes.

Versioning of this document follows [SemVer](https://semver.org/): **MAJOR** on scope change of the MVP, **MINOR** on new requirements, **PATCH** on small clarifications.
