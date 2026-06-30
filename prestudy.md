# Pre-study: Matdata 2.0

**Smart shopping, price history and global statistics powered by digital receipts**

| Metadata | |
| --- | --- |
| Version | 1.0 |
| Last updated | 2026-06-29 |
| Status | Pre-study ready for review |
| Place in documentation | Overall vision document. Start here as a new reader. |

> This is the overall pre-study document. For other documents, see [README.md](README.md).

## Contents
- [1. Introduction](#introduction)
- [2. Target audience and personas](#target-audience)
- [3. Concept and core functionality (MVP)](#concept)
- [4. Technical solution and architecture](#technical)
- [5. Competitive analysis](#competition)
- [6. Risks and challenges](#risks)
- [7. Success criteria and key metrics](#success)
- [8. Scope and dependencies](#scope)
- [9. Next steps](#next-steps)

## 1. Introduction <a name="introduction"></a>

### 1.1 Background
As living costs rise and food prices fluctuate, consumers have a growing need to take control of their everyday grocery purchases. Matdata 2.0 is born out of the desire to gain control of these costs by collecting and analysing receipt data.

### 1.2 Purpose
The project has a dual purpose:
1. **Product-wise:** Build a platform where users can upload digital receipts to automatically extract price data, track expenses over time and (with active consent) contribute to a global, fully anonymised price statistic in order to counteract "shrinkflation" and hidden price hikes.
2. **Skills development:** Serve as a real project for going deep into and applying the most modern technologies possible: Java 26, Spring Boot 4, event-driven architecture (GCP Pub/Sub), OpenTelemetry and Terraform.

### 1.3 Goal
Define core functionality, a clear and cost-effective technical architecture with "Privacy by Design" at its core, and a plan for an MVP (Minimum Viable Product). The full architecture is described in [architecture.md](architecture.md) and the requirements in [project-plan_requirements.md](project-plan_requirements.md).

## 2. Target audience and personas <a name="target-audience"></a>

* **Price-aware consumers and data enthusiasts:** Individuals who like to budget and visualise their finances at the line-item level.
* **Socially conscious consumers:** People who want to contribute to "Moms-kollen" and open price statistics.
* **The developer (primary user initially):** Built to solve a personal problem while also serving as a robust, pioneering reference architecture for future projects.

Detailed personas (Anna, Markus, Sofia) are found in [ux-ui_vision.md](ux-ui_vision.md) section 1.5.

## 3. Concept and core functionality (MVP) <a name="concept"></a>

To quickly and effectively test the hypothesis, the MVP is scoped using the MoSCoW method in [project-plan_requirements.md](project-plan_requirements.md):

1. **Input (PDF focus):** Phase 1 handles only digital PDF receipts from ICA via Kivra. This provides precise data and eliminates the error sources of traditional OCR.
2. **Asynchronous data extraction:** The user gets immediate feedback in the interface (via HTMX polling) while a background process extracts store, date, article number (including logic for masking weight items), name and price.
3. **Insights and UI:** Search function, "Moms-kollen" and shrinkflation warnings. A "cookie-free" experience without intrusive banners.
4. **Anonymisation (crowdsourcing):** The system stores a copy of the price data completely detached from the user and timestamp, ready for future global price comparisons.

## 4. Technical solution and architecture <a name="technical"></a>

The project follows an **event-driven, distributed architecture** tailored for Google Cloud Platform (GCP). A full architecture description, diagrams and data model are available in [architecture.md](architecture.md). Non-functional requirements (performance, security, accessibility) are found in [non-functional-requirements.md](non-functional-requirements.md).

### 4.1 Back end (two services)
* **Language and framework:** Java 26 and Spring Boot 4.x.
* **Core Service:** Handles sign-in, database calls and the HTMX-powered web interface (Thymeleaf, Tailwind CSS).
* **Parser Service:** A separate worker service for heavy operations (Apache PDFBox).
* **Message queue:** Google Cloud Pub/Sub handles the asynchronous communication between Core and Parser.

### 4.2 Database and infrastructure (IaC)
* **Database:** Neon (serverless PostgreSQL) which scales to zero and enables database branching for every Pull Request (PR environments).
* **Hosting:** Google Cloud Run (serverless).
* **File system:** Google Cloud Storage (GCS) for temporary PDF storage with strict privacy rules.
* **Infrastructure as code:** The entire environment is provisioned and managed declaratively via **Terraform**.

### 4.3 Observability and CI/CD
* **OpenTelemetry (OTel):** Distributed tracing across both microservices; logs and metrics are exported directly to GCP (Cloud Trace/Logging) — eliminating the need for client-side Google Analytics.
* **CI/CD:** GitHub Actions for automated testing, building of Docker images, provisioning of test databases and deployment via Workload Identity Federation.

## 5. Competitive analysis <a name="competition"></a>

* **Matpriskollen:** Strong on offers, but weaker at tracking historical individual purchases.
* **Stores' own apps (ICA, Coop):** Locked to their own systems and reluctant to show price history that highlights price increases.
* **Finance apps (Tink, Zuper):** Capture the total amount from the bank, but lack the line-item data of the receipt.
* **Matdata 2.0's unique edge:** Line-item analysis, shrinkflation warnings and full transparency over the user's data (easy export, clear deletion).

## 6. Risks and challenges <a name="risks"></a>

The biggest risks are summarised here. A full risk register with likelihood, impact, mitigation and owner is available in [risk-register.md](risk-register.md).

* **T1 — External formats:** ICA/Kivra may change the layout of their PDF receipts, which would immediately break parsing. Mitigated with a versioned parser and canary tests.
* **T2 — Complexity in EAN handling:** Barcodes for weight items embed price/weight, which requires careful logic in the parser to avoid breaking the price history. Handled via unit tests in Phase 2.
* **S1 — Privacy (GDPR):** Handling purchase data is sensitive. "The right to be forgotten" and the separation between personal history and global statistics must be rock-solid from day one (Privacy by Design). See [gdpr.md](gdpr.md) and [dpia.md](dpia.md).
* **V2 — Limited store coverage:** Only ICA is supported at launch. A plug-in architecture (requirement K20) is intended to reduce this dependency over time.
* **O1 — Single developer:** Risk of bottlenecks and knowledge silos. Mitigated by this pre-study and the ADR-light log in [open-decisions.md](open-decisions.md).

## 7. Success criteria and key metrics <a name="success"></a>

The MVP phase is considered successful when the following measurable goals have been met. The criteria must be verifiable with data, not with subjective judgements.

### 7.1 Product success criteria
* At least **50 unique users** have created an account within 3 months of the public launch.
* At least **20 of those users** have uploaded 5 receipts or more.
* Average parsing accuracy on ICA receipts is **≥ 95 %** measured against manual verification of reference receipts.
* Time from PDF upload to completed parsing is **< 30 seconds (p95)**. See [non-functional-requirements.md](non-functional-requirements.md) NFR-P2.

### 7.2 Technical success criteria
* **CI/CD pipeline works** for both services with PR environments (requirement K6).
* **OpenTelemetry traces cover** the entire upload flow end-to-end (requirement K10, NFR-O1).
* **Downtime** for `core-service` during the MVP period is **less than 1 %** measured over 3 months (NFR-A1, a more lenient threshold than for a public service).
* **No GDPR incidents** linked to Matdata 2.0.

### 7.3 Learning goals
* Practical experience with Java 26 (Virtual Threads, Pattern Matching) and Spring Boot 4.x.
* Practical experience with distributed tracing using OpenTelemetry against GCP.
* Practical experience with Terraform against GCP and Neon.
* Practical experience with Neon's database branching per PR.
* A documented reference architecture that can be reused in future projects.

## 8. Scope and dependencies <a name="scope"></a>

* **Geography:** The MVP targets Swedish users and Swedish stores. Internationalisation is handled according to [non-functional-requirements.md](non-functional-requirements.md) section 9.
* **Platform:** Web application only. Native iOS/Android is "Won't have" (requirement K19).
* **Input:** Only digital PDF receipts from ICA via Kivra in the MVP. OCR (K17) and other chains (K20) are in the Could-have bucket.
* **Third-party dependencies:** Kivra (PDF delivery), Google (GCP), Neon (database). Risks documented in [risk-register.md](risk-register.md) section "Supplier and dependency risks".
* **Budget:** The MVP must be runnable within the suppliers' free tiers. Detailed estimate in [cost-estimate.md](cost-estimate.md).

## 9. Next steps <a name="next-steps"></a>

Follow the established **Project plan and Roadmap** in [project-plan_requirements.md](project-plan_requirements.md), starting with *Phase 1: Foundation (Infrastructure & Environment)* where the repo is set up and Terraform is configured.

Before Phase 1 starts, the following reviews and confirmations should take place:

1. **Review of the pre-study** by all stakeholders.
2. **Acceptance of the risk register** ([risk-register.md](risk-register.md)) including named owners.
3. **Confirmation of the cost estimate** ([cost-estimate.md](cost-estimate.md)) and budget.
4. **Make sure that all open ADRs** ([open-decisions.md](open-decisions.md)) that must be decided before Phase 4 are scheduled.
5. **Confirmation of the GDPR strategy and DPIA** ([gdpr.md](gdpr.md), [dpia.md](dpia.md)).
