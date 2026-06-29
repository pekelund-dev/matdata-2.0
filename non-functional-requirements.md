# Icke-funktionella krav (NFR): Matdata 2.0

**Version:** 1.0
**Senast uppdaterad:** 2026-06-29
**Status:** Förstudie klar för granskning

Detta dokument samlar de icke-funktionella krav som inte ryms i [project-plan_requirements.md](project-plan_requirements.md). NFR:erna är mätbara, kopplade till SLO:er där det är meningsfullt, och prioriterade enligt MoSCoW.

## Innehåll
- [1. Prestanda](#prestanda)
- [2. Tillgänglighet och tillförlitlighet](#tillganglighet)
- [3. Skalbarhet och kapacitet](#skalbarhet)
- [4. Säkerhet](#sakerhet)
- [5. Dataskydd och retention](#dataskydd)
- [6. Observabilitet och driftnära krav](#observabilitet)
- [7. Backup och katastrofåterställning](#backup)
- [8. Tillgänglighet (accessibility, WCAG)](#accessibility)
- [9. Internationalisering och språk](#i18n)
- [10. Webbläsar- och enhetsstöd](#browser)
- [11. Underhållbarhet](#underhall)

## 1. Prestanda <a name="prestanda"></a>

| ID | Krav | Mål (MVP) | Mätning | Prioritet |
| --- | --- | --- | --- | --- |
| NFR-P1 | Tid till första byte (TTFB) på inloggad dashboard | < 500 ms (p95) | Cloud Run metric `request_latencies` | M |
| NFR-P2 | Tid från PDF-uppladdning till färdig parsing | < 30 s (p95) för kvitto ≤ 5 MB | Egen metric: `receipt_processing_seconds` | M |
| NFR-P3 | HTMX-polling-svar för statuskontroll | < 100 ms (p95) | Cloud Run metric per endpoint | S |
| NFR-P4 | Sökresultat (autocomplete) | < 200 ms (p95) | Egen metric | S |
| NFR-P5 | Cold start för `core-service` | < 5 s | Cloud Run startup latency | S |
| NFR-P6 | Cold start för `parser-service` | < 8 s (mer minne, större image) | Cloud Run startup latency | C |

Måtten gäller MVP. Skala upp tröskeln eller fastställ snävare SLO:er innan officiell lansering.

## 2. Tillgänglighet och tillförlitlighet <a name="tillganglighet"></a>

| ID | Krav | Mål (MVP) | Mätning | Prioritet |
| --- | --- | --- | --- | --- |
| NFR-A1 | Uppåtgångstid för `core-service` | 99 % per månad (≈ 7 h 18 min nedtid) | Cloud Monitoring uptime check | M |
| NFR-A2 | Felgrad (HTTP 5xx) på `core-service` | < 1 % av requests | Cloud Monitoring `5xx_ratio` | M |
| NFR-A3 | Asynkron processning lyckas | ≥ 95 % av kvitton går till COMPLETED utan manuell åtgärd | Egen metric: `parser_success_ratio` | M |
| NFR-A4 | DLQ-flöde | DLQ-trafik > 0 utlöser larm inom 5 min | Cloud Monitoring alert | M |

För MVP accepteras lägre uppåtgångstid än för en kommersiell tjänst. Innan publik lansering ska SLO:er omförhandlas.

## 3. Skalbarhet och kapacitet <a name="skalbarhet"></a>

**Kapacitetsantaganden för MVP (första 6 månader):**
* Aktiva användare: 50–500.
* Genomsnittlig kvittouppladdning per användare och månad: 10.
* Toppbelastning: 5 samtidiga uppladdningar.
* Datavolym efter 6 månader: 30 000 kvitton, ~500 MB i Cloud Storage, ~1 GB i PostgreSQL.

| ID | Krav | Mål | Prioritet |
| --- | --- | --- | --- |
| NFR-S1 | Horisontell skalning av `core-service` | Cloud Run min 0, max 5 instanser | M |
| NFR-S2 | Horisontell skalning av `parser-service` | Cloud Run min 0, max 3 instanser | M |
| NFR-S3 | Databasanslutningar | Connection pool ≤ 10 per instans, HikariCP | M |
| NFR-S4 | Maximal PDF-storlek per uppladdning | 10 MB | M |
| NFR-S5 | Maximalt antal kvitton per användarbatch | 20 | S |

## 4. Säkerhet <a name="sakerhet"></a>

| ID | Krav | Mätning/verifiering | Prioritet |
| --- | --- | --- | --- |
| NFR-SEC1 | Endast HTTPS i alla miljöer | Cloud Run-konfiguration | M |
| NFR-SEC2 | Strikt CSP-header på alla sidor | Manuell verifiering, automatiserat smoke-test | M |
| NFR-SEC3 | CSRF-skydd för alla state-changing-endpoints | Spring Security default + integrationstest | M |
| NFR-SEC4 | Lösenord lagras med BCrypt cost ≥ 12 | Kod-review | M |
| NFR-SEC5 | Sessionsregenerering efter inloggning | Spring Securitys defaultbeteende, verifieras i test | M |
| NFR-SEC6 | Beroendescanning i CI | Dependabot + `mvn dependency:tree`-rapport | M |
| NFR-SEC7 | Statisk kodanalys (SAST) | GitHub CodeQL aktiverat | S |
| NFR-SEC8 | Hemligheter i CI/CD hanteras via Workload Identity Federation | GitHub Actions-konfiguration | M |
| NFR-SEC9 | Periodisk extern säkerhetsgranskning | Minst en oberoende granskning innan publik lansering | S |
| NFR-SEC10 | Rate limiting på autentiseringsendpoints | Spring Security + ev. Cloud Armor | S |

## 5. Dataskydd och retention <a name="dataskydd"></a>

Se [gdpr.md](gdpr.md) och [dpia.md](dpia.md) för fullständig analys. Detta avsnitt sammanfattar de tekniska kraven.

| ID | Datatyp | Retention | Lagringsplats | Anmärkning |
| --- | --- | --- | --- | --- |
| NFR-D1 | Original-PDF | 30 dagar (default) eller tills användaren raderar/sparar | Cloud Storage | Cronjobb rensar (se [gdpr.md](gdpr.md) avsnitt 5) |
| NFR-D2 | Kvittorader (personlig) | Tills användaren raderas eller raderar själv | Neon PostgreSQL | ON DELETE CASCADE |
| NFR-D3 | Globala prispunkter (anonym) | Permanent | Neon PostgreSQL | Påverkas inte av användarradering |
| NFR-D4 | Sessioner | 30 dagar inaktivitet | Neon PostgreSQL via Spring Session JDBC | Daglig rensning |
| NFR-D5 | Strukturerade loggar | 30 dagar | GCP Cloud Logging | Lägre kostnad än längre retention |
| NFR-D6 | Audit-loggar (autentisering, samtycke) | 1 år | GCP Cloud Logging (separat bucket) | Skydd mot manipulering |
| NFR-D7 | Trace-data | 7 dagar | GCP Cloud Trace | Standard |
| NFR-D8 | Backup av databas | Daglig snapshot, 14 dagar retention | Neon | Se avsnitt 7 |

## 6. Observabilitet och driftnära krav <a name="observabilitet"></a>

| ID | Krav | Implementation | Prioritet |
| --- | --- | --- | --- |
| NFR-O1 | Distribuerad spårning ände-till-ände | OpenTelemetry från `core-service` via Pub/Sub till `parser-service` | M |
| NFR-O2 | Strukturerade loggar i JSON | Spring Boot + Logback JSON encoder, korrelerade med trace ID | M |
| NFR-O3 | Standardiserade metrics | `http_requests_total`, `receipt_processing_seconds`, `parser_success_ratio`, m.fl. | M |
| NFR-O4 | Larm vid SLO-brott | Cloud Monitoring policies | M |
| NFR-O5 | PII filtreras ur loggar | Logback masker + kodgranskning | M |
| NFR-O6 | Dashboards för viktigaste KPI:er | Cloud Monitoring dashboards | S |

## 7. Backup och katastrofåterställning <a name="backup"></a>

| ID | Krav | Mål | Prioritet |
| --- | --- | --- | --- |
| NFR-B1 | RPO (Recovery Point Objective) — databas | ≤ 24 h | M |
| NFR-B2 | RTO (Recovery Time Objective) — databas | ≤ 4 h | M |
| NFR-B3 | RPO — Cloud Storage (PDF) | Best effort. Användare uppmanas behålla original i Kivra | C |
| NFR-B4 | Återhämtningstest | Minst en lyckad återhämtning från snapshot per kvartal | S |
| NFR-B5 | IaC i Git | All infrastruktur återskapas från Terraform i ny GCP/Neon | M |

## 8. Tillgänglighet — accessibility (WCAG) <a name="accessibility"></a>

| ID | Krav | Mål | Prioritet |
| --- | --- | --- | --- |
| NFR-AC1 | WCAG 2.1 AA-konformans för publika sidor | Audit före publik lansering | M |
| NFR-AC2 | Färgkontrast ≥ 4,5:1 för normaltext | Verifieras via designtokens och automatiska tester | M |
| NFR-AC3 | Alla interaktiva element nås via tangentbord | Manuellt test + Playwright-test efter MVP | M |
| NFR-AC4 | Semantisk HTML och korrekt landmark-struktur | Linter (axe-core eller motsv.) i CI | M |
| NFR-AC5 | Skärmläsare kan navigera huvudflödet (login, ladda upp, se kvitto) | Manuellt test med NVDA eller VoiceOver | S |
| NFR-AC6 | Animationer respekterar `prefers-reduced-motion` | CSS-implementation | S |

## 9. Internationalisering och språk <a name="i18n"></a>

| ID | Krav | Mål | Prioritet |
| --- | --- | --- | --- |
| NFR-I1 | All UI-text läses från meddelandefiler | Spring `MessageSource` + Thymeleaf `#{...}`-syntax | M |
| NFR-I2 | MVP stödjer endast svenska (`sv-SE`) | Standardlokalisering | M |
| NFR-I3 | Datum-, tids- och valutaformat respekterar lokal | Spring `Locale` + JSR-310 | M |
| NFR-I4 | Engelska som andra språk | Aktiveras efter MVP | C |
| NFR-I5 | Inga hårdkodade strängar i Thymeleaf eller Java | Linter-regel eller PR-granskning | S |

## 10. Webbläsar- och enhetsstöd <a name="browser"></a>

| ID | Plattform | Versioner | Prioritet |
| --- | --- | --- | --- |
| NFR-BR1 | Chrome | Senaste 2 stora versioner | M |
| NFR-BR2 | Safari (iOS och macOS) | Senaste 2 stora versioner | M |
| NFR-BR3 | Edge | Senaste 2 stora versioner | M |
| NFR-BR4 | Firefox | Senaste 2 stora versioner | S |
| NFR-BR5 | Mobil (Android Chrome, iOS Safari) | Senaste 2 stora versioner | M |
| NFR-BR6 | Skärmstorlek | 320 px och uppåt | M |
| NFR-BR7 | Internet Explorer | Stöds inte | W |

## 11. Underhållbarhet <a name="underhall"></a>

| ID | Krav | Mätning | Prioritet |
| --- | --- | --- | --- |
| NFR-M1 | Enhetstestens kodtäckning på affärskritisk kod | ≥ 80 % linjetäckning på Parser Service domänklasser | M |
| NFR-M2 | Kodformatering enligt etablerad standard | Spotless eller Google Java Format i CI | M |
| NFR-M3 | Statisk analys | SpotBugs + ErrorProne i CI | S |
| NFR-M4 | Dokumentation av offentliga API:er | OpenAPI-spec (springdoc) | S |
| NFR-M5 | Dokumentation av arkitekturbeslut | [open-decisions.md](open-decisions.md) | M |
| NFR-M6 | Tydlig commit-historik | Conventional Commits | S |
