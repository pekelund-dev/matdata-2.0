# Non-functional requirements (NFR): Matdata 2.0

**Version:** 1.0
**Last updated:** 2026-06-29
**Status:** Pre-study ready for review

This document collects the non-functional requirements that do not fit in [project-plan_requirements.md](project-plan_requirements.md). The NFRs are measurable, tied to SLOs where meaningful, and prioritised according to MoSCoW.

## Contents
- [1. Performance](#performance)
- [2. Availability and reliability](#availability)
- [3. Scalability and capacity](#scalability)
- [4. Security](#security)
- [5. Data protection and retention](#data-protection)
- [6. Observability and operational requirements](#observability)
- [7. Backup and disaster recovery](#backup)
- [8. Accessibility (WCAG)](#accessibility)
- [9. Internationalisation and language](#i18n)
- [10. Browser and device support](#browser)
- [11. Maintainability](#maintainability)

## 1. Performance <a name="performance"></a>

| ID | Requirement | Target (MVP) | Measurement | Priority |
| --- | --- | --- | --- | --- |
| NFR-P1 | Time to first byte (TTFB) on signed-in dashboard | < 500 ms (p95) | Cloud Run metric `request_latencies` | M |
| NFR-P2 | Time from PDF upload to completed parsing | < 30 s (p95) for receipt ≤ 5 MB | Custom metric: `receipt_processing_seconds` | M |
| NFR-P3 | HTMX polling response for status check | < 100 ms (p95) | Cloud Run metric per endpoint | S |
| NFR-P4 | Search result (autocomplete) | < 200 ms (p95) | Custom metric | S |
| NFR-P5 | Cold start for `core-service` | < 5 s | Cloud Run startup latency | S |
| NFR-P6 | Cold start for `parser-service` | < 8 s (more memory, larger image) | Cloud Run startup latency | C |

The targets apply to the MVP. Either raise the threshold or set tighter SLOs before the official launch.

## 2. Availability and reliability <a name="availability"></a>

| ID | Requirement | Target (MVP) | Measurement | Priority |
| --- | --- | --- | --- | --- |
| NFR-A1 | Uptime for `core-service` | 99 % per month (≈ 7 h 18 min downtime) | Cloud Monitoring uptime check | M |
| NFR-A2 | Error rate (HTTP 5xx) on `core-service` | < 1 % of requests | Cloud Monitoring `5xx_ratio` | M |
| NFR-A3 | Asynchronous processing succeeds | ≥ 95 % of receipts go to COMPLETED without manual intervention | Custom metric: `parser_success_ratio` | M |
| NFR-A4 | DLQ flow | DLQ traffic > 0 triggers an alert within 5 minutes | Cloud Monitoring alert | M |

For the MVP a lower uptime than for a commercial service is accepted. Before the public launch, the SLOs must be renegotiated.

## 3. Scalability and capacity <a name="scalability"></a>

**Capacity assumptions for the MVP (first 6 months):**
* Active users: 50–500.
* Average receipt uploads per user per month: 10.
* Peak load: 5 simultaneous uploads.
* Data volume after 6 months: 30,000 receipts, ~500 MB in Cloud Storage, ~1 GB in PostgreSQL.

| ID | Requirement | Target | Priority |
| --- | --- | --- | --- |
| NFR-S1 | Horizontal scaling of `core-service` | Cloud Run min 0, max 5 instances | M |
| NFR-S2 | Horizontal scaling of `parser-service` | Cloud Run min 0, max 3 instances | M |
| NFR-S3 | Database connections | Connection pool ≤ 10 per instance, HikariCP | M |
| NFR-S4 | Maximum PDF size per upload | 10 MB | M |
| NFR-S5 | Maximum number of receipts per user batch | 20 | S |

## 4. Security <a name="security"></a>

| ID | Requirement | Measurement/verification | Priority |
| --- | --- | --- | --- |
| NFR-SEC1 | HTTPS only in all environments | Cloud Run configuration | M |
| NFR-SEC2 | Strict CSP header on all pages | Manual verification, automated smoke test | M |
| NFR-SEC3 | CSRF protection for all state-changing endpoints | Spring Security default + integration test | M |
| NFR-SEC4 | Passwords stored with BCrypt cost ≥ 12 | Code review | M |
| NFR-SEC5 | Session regeneration after sign-in | Spring Security default behaviour, verified in test | M |
| NFR-SEC6 | Dependency scanning in CI | Dependabot + `mvn dependency:tree` report | M |
| NFR-SEC7 | Static code analysis (SAST) | GitHub CodeQL enabled | S |
| NFR-SEC8 | Secrets in CI/CD managed via Workload Identity Federation | GitHub Actions configuration | M |
| NFR-SEC9 | Periodic external security review | At least one independent review before public launch | S |
| NFR-SEC10 | Rate limiting on authentication endpoints | Spring Security + optionally Cloud Armor | S |

## 5. Data protection and retention <a name="data-protection"></a>

See [gdpr.md](gdpr.md) and [dpia.md](dpia.md) for the full analysis. This section summarises the technical requirements.

| ID | Data type | Retention | Storage | Note |
| --- | --- | --- | --- | --- |
| NFR-D1 | Original PDF | 30 days (default) or until the user deletes/keeps | Cloud Storage | Cron job cleans up (see [gdpr.md](gdpr.md) section 5) |
| NFR-D2 | Receipt items (personal) | Until the user is deleted or deletes themselves | Neon PostgreSQL | ON DELETE CASCADE |
| NFR-D3 | Global price points (anonymous) | Permanent | Neon PostgreSQL | Not affected by user deletion |
| NFR-D4 | Sessions | 30 days inactivity | Neon PostgreSQL via Spring Session JDBC | Daily clean-up |
| NFR-D5 | Structured logs | 30 days | GCP Cloud Logging | Lower cost than longer retention |
| NFR-D6 | Audit logs (authentication, consent) | 1 year | GCP Cloud Logging (separate bucket) | Tamper protection |
| NFR-D7 | Trace data | 7 days | GCP Cloud Trace | Default |
| NFR-D8 | Database backup | Daily snapshot, 14-day retention | Neon | See section 7 |

## 6. Observability and operational requirements <a name="observability"></a>

| ID | Requirement | Implementation | Priority |
| --- | --- | --- | --- |
| NFR-O1 | End-to-end distributed tracing | OpenTelemetry from `core-service` via Pub/Sub to `parser-service` | M |
| NFR-O2 | Structured logs in JSON | Spring Boot + Logback JSON encoder, correlated with trace ID | M |
| NFR-O3 | Standardised metrics | `http_requests_total`, `receipt_processing_seconds`, `parser_success_ratio`, etc. | M |
| NFR-O4 | Alerts on SLO breaches | Cloud Monitoring policies | M |
| NFR-O5 | PII filtered out of logs | Logback masks + code review | M |
| NFR-O6 | Dashboards for the most important KPIs | Cloud Monitoring dashboards | S |

## 7. Backup and disaster recovery <a name="backup"></a>

| ID | Requirement | Target | Priority |
| --- | --- | --- | --- |
| NFR-B1 | RPO (Recovery Point Objective) — database | ≤ 24 h | M |
| NFR-B2 | RTO (Recovery Time Objective) — database | ≤ 4 h | M |
| NFR-B3 | RPO — Cloud Storage (PDF) | Best effort. Users are asked to keep originals in Kivra | C |
| NFR-B4 | Recovery test | At least one successful recovery from a snapshot per quarter | S |
| NFR-B5 | IaC in Git | All infrastructure recreated from Terraform in new GCP/Neon | M |

## 8. Accessibility (WCAG) <a name="accessibility"></a>

| ID | Requirement | Target | Priority |
| --- | --- | --- | --- |
| NFR-AC1 | WCAG 2.1 AA conformance for public pages | Audit before public launch | M |
| NFR-AC2 | Colour contrast ≥ 4.5:1 for normal text | Verified via design tokens and automated tests | M |
| NFR-AC3 | All interactive elements reachable via keyboard | Manual test + Playwright test after MVP | M |
| NFR-AC4 | Semantic HTML and correct landmark structure | Linter (axe-core or equivalent) in CI | M |
| NFR-AC5 | Screen reader can navigate the main flow (sign-in, upload, view receipt) | Manual test with NVDA or VoiceOver | S |
| NFR-AC6 | Animations respect `prefers-reduced-motion` | CSS implementation | S |

## 9. Internationalisation and language <a name="i18n"></a>

| ID | Requirement | Target | Priority |
| --- | --- | --- | --- |
| NFR-I1 | All UI text is read from message files | Spring `MessageSource` + Thymeleaf `#{...}` syntax | M |
| NFR-I2 | MVP supports Swedish only (`sv-SE`) | Default localisation | M |
| NFR-I3 | Date, time and currency format respect the locale | Spring `Locale` + JSR-310 | M |
| NFR-I4 | English as a second language | Activated after MVP | C |
| NFR-I5 | No hard-coded strings in Thymeleaf or Java | Linter rule or PR review | S |

## 10. Browser and device support <a name="browser"></a>

| ID | Platform | Versions | Priority |
| --- | --- | --- | --- |
| NFR-BR1 | Chrome | Latest 2 major versions | M |
| NFR-BR2 | Safari (iOS and macOS) | Latest 2 major versions | M |
| NFR-BR3 | Edge | Latest 2 major versions | M |
| NFR-BR4 | Firefox | Latest 2 major versions | S |
| NFR-BR5 | Mobile (Android Chrome, iOS Safari) | Latest 2 major versions | M |
| NFR-BR6 | Screen size | 320 px and up | M |
| NFR-BR7 | Internet Explorer | Not supported | W |

## 11. Maintainability <a name="maintainability"></a>

| ID | Requirement | Measurement | Priority |
| --- | --- | --- | --- |
| NFR-M1 | Unit test code coverage on business-critical code | ≥ 80 % line coverage on Parser Service domain classes | M |
| NFR-M2 | Code formatting per established standard | Spotless or Google Java Format in CI | M |
| NFR-M3 | Static analysis | SpotBugs + ErrorProne in CI | S |
| NFR-M4 | Documentation of public APIs | OpenAPI spec (springdoc) | S |
| NFR-M5 | Documentation of architecture decisions | [open-decisions.md](open-decisions.md) | M |
| NFR-M6 | Clear commit history | Conventional Commits | S |
