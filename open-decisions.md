# Open decisions and ADR-light: Matdata 2.0

**Version:** 1.0
**Last updated:** 2026-06-29
**Status:** Pre-study ready for review

This document collects architecture decisions (Architecture Decision Records, ADR) in a lightweight form. Each decision has a clear status, context and consequences. The format is inspired by Michael Nygard's ADR model.

## Contents
- [Status flags](#status)
- [Closed decisions](#closed)
  - [ADR-001 — Monorepo](#adr-001)
  - [ADR-002 — Two services behind Pub/Sub](#adr-002)
  - [ADR-003 — Neon as the primary database](#adr-003)
  - [ADR-004 — Java 26 + Spring Boot 4.x](#adr-004)
  - [ADR-005 — Thymeleaf + HTMX instead of SPA](#adr-005)
  - [ADR-006 — Terraform for all infrastructure](#adr-006)
  - [ADR-007 — Aggregation granularity "city + month" for anonymous statistics](#adr-007)
  - [ADR-008 — Default 30-day PDF retention](#adr-008)
  - [ADR-009 — Authentication strategy: local first, OAuth2 in Phase 4](#adr-009)
  - [ADR-010 — Repository name: matdata-monorepo](#adr-010)
- [Open decisions](#open)
  - [ADR-011 — Charting library (Chart.js or alternative)](#adr-011)
  - [ADR-012 — Search architecture (LIKE, pg_trgm or dedicated search engine)](#adr-012)
  - [ADR-013 — Source for product categories](#adr-013)
  - [ADR-014 — Tooling for accessibility tests](#adr-014)
  - [ADR-015 — Strategy for transactional e-mail](#adr-015)
- [Rejected proposals](#rejected)
- [How to propose a new ADR](#how)

## Status flags <a name="status"></a>
* **Closed:** Decision has been made and documented. Implementation follows.
* **Open:** Decision needs to be made. The trigger date (deadline) is stated.
* **Rejected:** Alternative that was considered but not chosen. Kept for history.

## Closed decisions <a name="closed"></a>

### ADR-001 — Monorepo <a name="adr-001"></a>
* **Status:** Closed 2026-06-15
* **Context:** We need storage for two Spring Boot services, Terraform and documentation.
* **Decision:** Use a monorepo with a clear directory structure. The repository name is `matdata-monorepo`. See [architecture.md](architecture.md) section 12.
* **Consequences:** Simpler CI/CD and shared versioning. Requires discipline with the directory structure and pipeline filters (`paths:` in GitHub Actions) to avoid rebuilding everything on every change.

### ADR-002 — Two services behind Pub/Sub <a name="adr-002"></a>
* **Status:** Closed 2026-06-15
* **Context:** PDF parsing is CPU- and memory-intensive. Letting `core-service` be blocked by it degrades response times.
* **Decision:** Separate into `core-service` (web) and `parser-service` (worker) that communicate via GCP Pub/Sub. See [architecture.md](architecture.md) section 2.1.
* **Consequences:** Distributed architecture requires tracing (NFR-O1), idempotency handling (Pub/Sub delivers at least once) and a DLQ.

### ADR-003 — Neon as the primary database <a name="adr-003"></a>
* **Status:** Closed 2026-06-15
* **Context:** We need serverless PostgreSQL with database branching for PR environments.
* **Decision:** Neon is chosen. See [architecture.md](architecture.md) section 2.3.
* **Consequences:** Supplier risk documented in [risk-register.md](risk-register.md) L2. Migration to Cloud SQL or Supabase is possible because we use standard Postgres.

### ADR-004 — Java 26 + Spring Boot 4.x <a name="adr-004"></a>
* **Status:** Closed 2026-06-15
* **Context:** The project is partly a skills-development project. Java 26 and Spring Boot 4.x provide Virtual Threads, Pattern Matching and modern observability.
* **Decision:** Use the latest stable Java 26 and Spring Boot 4.x. See [architecture.md](architecture.md) section 2.1.
* **Consequences:** Less community experience (risk T5 in [risk-register.md](risk-register.md)). Ability to backport to Java 25 if critical bugs arise.

### ADR-005 — Thymeleaf + HTMX instead of SPA <a name="adr-005"></a>
* **Status:** Closed 2026-06-15
* **Context:** We want an SPA feel without the SPA complexity. Backend-rendered HTML fits the Java stack.
* **Decision:** Thymeleaf for server-side rendering, HTMX for dynamic updates. See [architecture.md](architecture.md) section 2.2.
* **Consequences:** Faster development, less code. Some interactions like real-time search require a little more care if you want a fully client-side-first experience.

### ADR-006 — Terraform for all infrastructure <a name="adr-006"></a>
* **Status:** Closed 2026-06-15
* **Context:** We need to be able to recreate environments (PR, dev, prod) deterministically.
* **Decision:** All infrastructure work is described in Terraform. No manual changes in the GCP console outside fire-drill missions. See [architecture.md](architecture.md) section 8.
* **Consequences:** Longer lead time for simpler changes in exchange for reproducibility.

### ADR-007 — Aggregation granularity "city + month" for anonymous statistics <a name="adr-007"></a>
* **Status:** Closed 2026-06-20
* **Context:** To avoid making anonymised data re-identifiable the granularity must be balanced: coarse enough to protect the individual, fine enough to provide insights.
* **Decision:** City (e.g. "Malmö", not specific store) + year-month (e.g. "2026-06"). See [architecture.md](architecture.md) section 5 and [gdpr.md](gdpr.md) section 2.2.
* **Consequences:** Global statistics views show trends per city and month. Discussion material that previously mentioned "week/month" in [gdpr.md](gdpr.md) has been consolidated to "month".

### ADR-008 — Default 30-day PDF retention <a name="adr-008"></a>
* **Status:** Closed 2026-06-20
* **Context:** The user does not need to see the original receipt forever. PDF storage carries both a cost and a data-protection burden.
* **Decision:** By default PDFs are deleted after 30 days via a lifecycle policy on Cloud Storage. The user can choose to keep them per upload. See [non-functional-requirements.md](non-functional-requirements.md) NFR-D1.
* **Consequences:** Lower storage cost ([cost-estimate.md](cost-estimate.md)), reduced data-protection exposure ([dpia.md](dpia.md) DPIA-R5).

### ADR-009 — Authentication strategy: local first, OAuth2 in Phase 4 <a name="adr-009"></a>
* **Status:** Closed 2026-06-29
* **Context:** [architecture.md](architecture.md) section 9 previously described this as an open decision with two alternatives.
* **Decision:** Implement local authentication (Spring Security form login with BCrypt) in Phase 4. OAuth2 via Google is introduced in a later iteration as a complementary sign-in path. The data model is already designed to support both.
* **Consequences:** Faster MVP without an external dependency. The user gets more control but must manage a password. Risks T6 (Pub/Sub) and S2 (session hijack) are handled per [risk-register.md](risk-register.md).

### ADR-010 — Repository name: matdata-monorepo <a name="adr-010"></a>
* **Status:** Closed 2026-06-29
* **Context:** Earlier documents referenced both `matdata-monorepo` and `matdata/`. Inconsistency creates confusion.
* **Decision:** The GitHub repository name is `matdata-monorepo`. The internal directory structure is mirrored in [architecture.md](architecture.md) section 12.
* **Consequences:** All documents now reference the same name. CI/CD configurations that reference the repository name can be written consistently.

## Open decisions <a name="open"></a>

### ADR-011 — Charting library <a name="adr-011"></a>
* **Status:** Open. Decision needed at the latest at the start of Phase 4.
* **Context:** [ux-ui_vision.md](ux-ui_vision.md) mentions Chart.js. No choice has been formally made.
* **Alternatives:**
    * Chart.js (lightweight, popular, works well with static HTML).
    * Apache ECharts (richer functionality, larger library).
    * Server-side generated SVG (entirely JS-free, more work for interactivity).
* **Decision inputs required:** Requirements for interactivity (hover, zoom) and data volume per chart.

### ADR-012 — Search architecture <a name="adr-012"></a>
* **Status:** Open. Decision needed at the start of Phase 4.
* **Context:** Product search ([ux-ui_vision.md](ux-ui_vision.md) section 2.3) requires fuzzy autocomplete on product names.
* **Alternatives:**
    * PostgreSQL `ILIKE` with prefix index (simplest, likely sufficient for MVP).
    * `pg_trgm` extension in Postgres for trigram-based search.
    * Meilisearch or similar search engine (overkill for MVP).
* **Decision inputs required:** Number of products and latency requirement (NFR-P4 says < 200 ms p95).

### ADR-013 — Source for product categories <a name="adr-013"></a>
* **Status:** Open. Decision needed at the start of Phase 4 or when the dashboard is to show a category breakdown.
* **Context:** [ux-ui_vision.md](ux-ui_vision.md) section 2.1 shows a donut chart with category breakdown. `PRODUCTS.category` exists in the data model but has no source.
* **Alternatives:**
    * Manual mapping from an EAN prefix table.
    * Use an external product catalogue/API (may add licence and cost questions).
    * AI-based classification on the product name at first upload.
    * User-driven categorisation (community moderation).
* **Decision inputs required:** Volume of new products per month, precision requirement for the category.

### ADR-014 — Tooling for accessibility tests <a name="adr-014"></a>
* **Status:** Open. Decision needed at the start of Phase 4.
* **Context:** [non-functional-requirements.md](non-functional-requirements.md) NFR-AC4 requires a linter for semantic HTML.
* **Alternatives:**
    * `axe-core` via Playwright (requires Playwright in Phase 4).
    * `pa11y` (Node-based, standalone).
    * Manual review with a screen reader (complement, not alternative).
* **Decision inputs required:** Final choice of e2e tooling (Playwright is advocated in the project plan).

### ADR-015 — Strategy for transactional e-mail <a name="adr-015"></a>
* **Status:** Open. Decision needed when password reset is to be built (post-MVP).
* **Context:** Password reset requires sending e-mail. Spring supports JavaMail, but an SMTP provider must be chosen.
* **Alternatives:**
    * Brevo (free up to 300 e-mails/day).
    * Resend (modern, generous free tier).
    * Postmark (premium, high deliverability).
    * Own SMTP server (discouraged, poor reputation for deliverability).
* **Decision inputs required:** Volume, cost and deliverability tests.

## Rejected proposals <a name="rejected"></a>

| Date | Proposal | Reason for rejection |
| --- | --- | --- |
| 2026-06-15 | Use Kotlin instead of Java | Deviates from the goal of going deep into modern Java features (skills development). |
| 2026-06-15 | Native iOS/Android apps in the MVP | Too high a cost and complexity. Web/PWA is enough (requirement K19, Won't have). |
| 2026-06-20 | Direct integration with Kivra's API | Not publicly available. User-driven upload is simpler and more transparent (requirement K18, Won't have). |
| 2026-06-20 | Client-side analytics (Google Analytics) | Requires a cookie banner. Server-side observability via OpenTelemetry was chosen instead (see [gdpr.md](gdpr.md) section 4.3). |

## How to propose a new ADR <a name="how"></a>

1. Create a section at the bottom of [Open decisions](#open) with the next free `ADR-XXX` number.
2. Describe **Context** (why a decision is needed), **Alternatives** (at least two) and **Decision inputs required**.
3. Open a Pull Request with the change and link the relevant documents.
4. When the decision has been made: change the status to **Closed**, move it to [Closed decisions](#closed), update the affected documents and link back to the ADR.
