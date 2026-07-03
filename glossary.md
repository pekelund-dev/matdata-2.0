# Glossary: Matdata 2.0

This glossary collects terms, acronyms and product-specific concepts used in the pre-study documents. Its purpose is to ensure that all contributors interpret the concepts in the same way.

## Contents
- [A–E](#aE)
- [F–L](#fL)
- [M–S](#mS)
- [T–Z](#tZ)

## A–E <a name="aE"></a>

| Term | Explanation |
| --- | --- |
| **Apache PDFBox** | Java library for reading and extracting text from PDF files. Used in `parser-service`. |
| **C4 model** | Notation by Simon Brown for describing software architecture at four levels: Context, Container, Component, Code. |
| **Canary test** | Recurring test against a known reference (e.g. a stored PDF) that raises an alarm if the result changes unintentionally. |
| **Cloud Run** | GCP service for running containers serverless with per-request billing. |
| **Cloud Storage (GCS)** | GCP object storage for files. Used in Matdata for temporary PDF storage. |
| **Cookie banner** | Modal for cookie consent. Matdata aims to avoid the need entirely (see [gdpr.md](gdpr.md)). |
| **Core Service** | Spring Boot application that powers the web interface, authentication and APIs. |
| **Crowdsourcing** | In Matdata: aggregation of anonymised prices from all consenting users. |
| **DLQ (Dead Letter Queue)** | Pub/Sub topic where messages are moved after a configured number of failed delivery attempts. |
| **DPIA** | Data Protection Impact Assessment per GDPR Article 35. See [dpia.md](dpia.md). |
| **EAN (European Article Number)** | Barcode standard for consumer goods. Matdata uses EAN-13 as the primary identifier. |
| **EAN weight item code** | EAN codes with prefix 20–29 where parts of the code represent weight or price. Must be masked so that the price history is not broken. |
| **ePrivacy** | EU directive that regulates electronic communication, including cookies. Complements GDPR. |

## F–L <a name="fL"></a>

| Term | Explanation |
| --- | --- |
| **FAB (Floating Action Button)** | Prominent, often circular, button for the primary action. In Matdata: upload receipt. |
| **Phase (Phases 1–5)** | Development phases in [project-plan_requirements.md](project-plan_requirements.md). |
| **Flyway** | Tool for version control of the database schema. Migrations run at start-up. |
| **Pre-study** | This set of project documents that describes what is to be built before implementation begins. |
| **GCP (Google Cloud Platform)** | Cloud platform that hosts all infrastructure in Matdata 2.0. |
| **GDPR** | EU data protection regulation (Regulation (EU) 2016/679). See [gdpr.md](gdpr.md). |
| **HTMX** | JavaScript library for issuing AJAX calls and updating the DOM without a bespoke JavaScript framework. |
| **IaC (Infrastructure as Code)** | The practice of describing infrastructure as code. Matdata uses Terraform. |
| **Idempotency** | The property that the same operation can be executed multiple times with the same result. Important for Pub/Sub messages. |
| **JDBC** | Java Database Connectivity – Java's standard for database access. |
| **Kitchen Sink** | The UI component catalogue at `/dev/components`. Shows all reusable Thymeleaf fragments. |
| **Kivra** | Swedish digital mailbox. Delivers ICA's digital receipts as PDF, among other things. |
| **Shrinkflation** | The phenomenon where packages shrink in content while the price is kept the same. Matdata warns about this. |

## M–S <a name="mS"></a>

| Term | Explanation |
| --- | --- |
| **Matdata 2.0** | The project name. "2.0" indicates that a first version exists, but the new version is built from scratch. |
| **MCP (Model Context Protocol)** | Protocol for connecting AI agents to external tools such as design systems. |
| **Mermaid** | Text-based notation for diagrams that is rendered by GitHub. Used in the architecture document. |
| **Moms-kollen** | Thematic analysis view that shows whether stores have passed on the VAT reduction on food. Requirement K15. (Swedish "moms" = VAT.) |
| **Monorepo** | Repository that contains multiple services (`core-service`, `parser-service`, `terraform`, etc.). |
| **MoSCoW** | Prioritisation method: Must / Should / Could / Won't have. See [project-plan_requirements.md](project-plan_requirements.md). |
| **MVP (Minimum Viable Product)** | The smallest version that delivers value and can be tested with users. |
| **Neon** | Serverless PostgreSQL provider with support for database branching per Pull Request. |
| **NFR (Non-Functional Requirement)** | Requirement on the system's quality attributes. See [non-functional-requirements.md](non-functional-requirements.md). |
| **OAuth2** | Standard for delegated authentication. Matdata supports OAuth2 via Google. |
| **OpenTelemetry (OTel)** | Standard for distributed tracing, logs and metrics. Exports to GCP Cloud Trace/Logging. |
| **Parser Service** | Spring Boot worker that extracts and normalises data from uploaded PDF files. |
| **PbD (Privacy by Design)** | Principle of building in data protection from the start (GDPR Article 25). |
| **PLU (Price Look-Up code)** | Numeric code for non-barcoded items, mainly fruit and vegetables. |
| **PR environment** | Per-Pull-Request deployment with its own Cloud Run instance, Pub/Sub topic and Neon database branch. |
| **Pub/Sub** | GCP's message queue service. Used between `core-service` and `parser-service`. |
| **RACI** | Responsibility matrix: Responsible, Accountable, Consulted, Informed. |
| **Row-Level Security (RLS)** | PostgreSQL feature that filters rows per user at the database level. |
| **RPO/RTO** | Recovery Point Objective (max acceptable data loss) / Recovery Time Objective (max acceptable downtime). |
| **SLA/SLO/SLI** | Service Level Agreement / Objective / Indicator. Defines and measures service quality. |
| **Spring Boot** | Java framework for rapid web application development. Matdata uses version 4.x. |
| **Spring Security** | Spring module for authentication and authorisation. |

## T–Z <a name="tZ"></a>

| Term | Explanation |
| --- | --- |
| **Tailwind CSS** | Utility-first CSS framework. Used for all styling in Matdata. |
| **Terraform** | IaC tool from HashiCorp. Describes GCP and Neon resources declaratively. |
| **Testcontainers** | Java library that starts Docker containers for integration tests (e.g. PostgreSQL). |
| **Thymeleaf** | Server-side templating engine for Spring Boot. Used instead of React/Vue. |
| **Trace ID** | Unique identifier that follows a request through all services. Generated by OpenTelemetry. |
| **VAT rate** | Value-Added Tax rate. In Sweden 12 % on food (temporarily 6 % during the VAT reduction). |
| **Workload Identity Federation** | Mechanism that lets GitHub Actions obtain GCP access without long-lived service account keys. |
| **XSRF-TOKEN** | Cookie used to protect against Cross-Site Request Forgery in Spring Security. |
