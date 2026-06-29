# Öppna beslut och ADR-light: Matdata 2.0

**Version:** 1.0
**Senast uppdaterad:** 2026-06-29
**Status:** Förstudie klar för granskning

Detta dokument samlar arkitekturbeslut (Architecture Decision Records, ADR) i en lättviktsversion. Varje beslut har en tydlig status, kontext och konsekvenser. Format är inspirerat av Michael Nygards ADR-modell.

## Innehåll
- [Status-flaggor](#status)
- [Stängda beslut](#stangda)
  - [ADR-001 — Monorepo](#adr-001)
  - [ADR-002 — Två tjänster bakom Pub/Sub](#adr-002)
  - [ADR-003 — Neon som primär databas](#adr-003)
  - [ADR-004 — Java 26 + Spring Boot 4.x](#adr-004)
  - [ADR-005 — Thymeleaf + HTMX istället för SPA](#adr-005)
  - [ADR-006 — Terraform för all infrastruktur](#adr-006)
  - [ADR-007 — Aggregeringsgranularitet "ort + månad" för anonym statistik](#adr-007)
  - [ADR-008 — Default 30 dagars PDF-retention](#adr-008)
  - [ADR-009 — Autentiseringsstrategi: lokal först, OAuth2 i fas 4](#adr-009)
  - [ADR-010 — Reposnamn: matdata-monorepo](#adr-010)
- [Öppna beslut](#oppna)
  - [ADR-011 — Bibliotek för diagram (Chart.js eller alternativ)](#adr-011)
  - [ADR-012 — Sökarkitektur (LIKE, pg_trgm eller dedikerad sökmotor)](#adr-012)
  - [ADR-013 — Källa för produktkategorier](#adr-013)
  - [ADR-014 — Verktyg för accessibility-tester](#adr-014)
  - [ADR-015 — Strategi för transaktionell e-post](#adr-015)
- [Tillbakavisade förslag](#avslag)
- [Hur du föreslår en ny ADR](#hur)

## Status-flaggor <a name="status"></a>
* **Stängd:** Beslut är fattat och dokumenterat. Implementation följer.
* **Öppen:** Beslut behöver fattas. Triggerdatum (deadline) anges.
* **Avslagen:** Alternativ som övervägdes men inte valdes. Bevaras för historik.

## Stängda beslut <a name="stangda"></a>

### ADR-001 — Monorepo <a name="adr-001"></a>
* **Status:** Stängd 2026-06-15
* **Kontext:** Behöver lagring av två Spring Boot-tjänster, Terraform och dokumentation.
* **Beslut:** Använd ett monorepo med tydlig katalogstruktur. Reponamnet är `matdata-monorepo`. Se [architecture.md](architecture.md) avsnitt 12.
* **Konsekvenser:** Enklare CI/CD och delad versionering. Kräver disciplin med katalogstrukturen och pipeline-filter (`paths:` i GitHub Actions) för att inte bygga om allt vid varje ändring.

### ADR-002 — Två tjänster bakom Pub/Sub <a name="adr-002"></a>
* **Status:** Stängd 2026-06-15
* **Kontext:** PDF-parsing är CPU- och minnesintensiv. Att låta `core-service` blockeras av detta försämrar svarstider.
* **Beslut:** Separera i `core-service` (webb) och `parser-service` (worker) som kommunicerar via GCP Pub/Sub. Se [architecture.md](architecture.md) avsnitt 2.1.
* **Konsekvenser:** Distribuerad arkitektur kräver tracing (NFR-O1), idempotenshantering (Pub/Sub levererar minst en gång) och DLQ.

### ADR-003 — Neon som primär databas <a name="adr-003"></a>
* **Status:** Stängd 2026-06-15
* **Kontext:** Behöver serverless PostgreSQL med databas-branchning för PR-miljöer.
* **Beslut:** Neon väljs. Se [architecture.md](architecture.md) avsnitt 2.3.
* **Konsekvenser:** Leverantörsrisk dokumenterad i [risk-register.md](risk-register.md) L2. Migration till Cloud SQL eller Supabase är möjlig eftersom vi använder standard-Postgres.

### ADR-004 — Java 26 + Spring Boot 4.x <a name="adr-004"></a>
* **Status:** Stängd 2026-06-15
* **Kontext:** Projektet är delvis ett kompetensutvecklingsprojekt. Java 26 och Spring Boot 4.x ger Virtual Threads, Pattern Matching och modern observabilitet.
* **Beslut:** Använd senaste stabila Java 26 och Spring Boot 4.x. Se [architecture.md](architecture.md) avsnitt 2.1.
* **Konsekvenser:** Mindre community-erfarenhet (risk T5 i [risk-register.md](risk-register.md)). Möjlighet att backporta till Java 25 om kritiska buggar uppstår.

### ADR-005 — Thymeleaf + HTMX istället för SPA <a name="adr-005"></a>
* **Status:** Stängd 2026-06-15
* **Kontext:** Vi vill ha SPA-känsla utan SPA:s komplexitet. Backend-renderad HTML passar Java-stacken.
* **Beslut:** Thymeleaf för server-side rendering, HTMX för dynamiska uppdateringar. Se [architecture.md](architecture.md) avsnitt 2.2.
* **Konsekvenser:** Snabbare utveckling, mindre kod. Vissa interaktioner som realtidssökning kräver lite mer omsorg om man vill ha helt klientside-första.

### ADR-006 — Terraform för all infrastruktur <a name="adr-006"></a>
* **Status:** Stängd 2026-06-15
* **Kontext:** Vi vill kunna återskapa miljöer (PR, dev, prod) deterministiskt.
* **Beslut:** Allt infrastrukturarbete beskrivs i Terraform. Inga manuella ändringar i GCP-konsolen utöver brandkårsuppdrag. Se [architecture.md](architecture.md) avsnitt 8.
* **Konsekvenser:** Längre ledtid för enklare ändringar i utbyte mot reproducerbarhet.

### ADR-007 — Aggregeringsgranularitet "ort + månad" för anonym statistik <a name="adr-007"></a>
* **Status:** Stängd 2026-06-20
* **Kontext:** För att inte göra anonymiserad data avanonymiserbar måste granulariteten balanseras: tillräckligt grov för att skydda individen, tillräckligt fin för att ge insikter.
* **Beslut:** Ort (t.ex. "Malmö", inte specifik butik) + år-månad (t.ex. "2026-06"). Se [architecture.md](architecture.md) avsnitt 5 och [gdpr.md](gdpr.md) avsnitt 2.2.
* **Konsekvenser:** Globala statistikvyer visar trender per ort och månad. Diskussionsmaterial som tidigare omtalade "vecka/månad" i [gdpr.md](gdpr.md) har konsoliderats till "månad".

### ADR-008 — Default 30 dagars PDF-retention <a name="adr-008"></a>
* **Status:** Stängd 2026-06-20
* **Kontext:** Användaren behöver inte se originalkvittot för evigt. Lagring av PDF medför både kostnads- och dataskyddsbelastning.
* **Beslut:** Default raderas PDF efter 30 dagar via lifecycle policy på Cloud Storage. Användaren kan välja att behålla per uppladdning. Se [non-functional-requirements.md](non-functional-requirements.md) NFR-D1.
* **Konsekvenser:** Lägre lagringskostnad ([cost-estimate.md](cost-estimate.md)), minskad dataskyddsexponering ([dpia.md](dpia.md) DPIA-R5).

### ADR-009 — Autentiseringsstrategi: lokal först, OAuth2 i fas 4 <a name="adr-009"></a>
* **Status:** Stängd 2026-06-29
* **Kontext:** [architecture.md](architecture.md) avsnitt 9 hade tidigare beskrivit detta som ett öppet beslut med två alternativ.
* **Beslut:** Implementera lokal autentisering (Spring Security form login med BCrypt) i Fas 4. OAuth2 via Google införs i en senare iteration som kompletterande inloggningsväg. Datamodellen är redan utformad för att stödja båda.
* **Konsekvenser:** Snabbare MVP utan extern beroende. Användaren får mer kontroll men måste hantera lösenord. Risk T6 (Pub/Sub) och S2 (sessionhijack) hanteras enligt [risk-register.md](risk-register.md).

### ADR-010 — Reposnamn: matdata-monorepo <a name="adr-010"></a>
* **Status:** Stängd 2026-06-29
* **Kontext:** Tidigare dokument refererade både `matdata-monorepo` och `matdata/`. Inkonsistens skapar förvirring.
* **Beslut:** Reposnamn på GitHub är `matdata-monorepo`. Katalogstrukturen inom repot speglas i [architecture.md](architecture.md) avsnitt 12.
* **Konsekvenser:** Alla dokument refererar nu samma namn. CI/CD-konfigurationer som anger reponamn kan skrivas konsistent.

## Öppna beslut <a name="oppna"></a>

### ADR-011 — Bibliotek för diagram <a name="adr-011"></a>
* **Status:** Öppen. Beslut behövs senast vid start av Fas 4.
* **Kontext:** [ux-ui_vision.md](ux-ui_vision.md) nämner Chart.js. Inget val är formellt fattat.
* **Alternativ:**
    * Chart.js (lättvikt, populär, fungerar bra med statisk HTML).
    * Apache ECharts (rikare funktionalitet, större bibliotek).
    * Server-side genererad SVG (helt JS-fri, mer arbete vid interaktivitet).
* **Beslutsunderlag som krävs:** Krav på interaktivitet (hover, zoom) och datavolym per graf.

### ADR-012 — Sökarkitektur <a name="adr-012"></a>
* **Status:** Öppen. Beslut behövs vid start av Fas 4.
* **Kontext:** Produktsök ([ux-ui_vision.md](ux-ui_vision.md) avsnitt 2.3) kräver fuzzy autocomplete på produktnamn.
* **Alternativ:**
    * PostgreSQL `ILIKE` med prefixindex (enklast, troligt tillräckligt för MVP).
    * `pg_trgm` extension i Postgres för trigram-baserad sök.
    * Meilisearch eller liknande sökmotor (overkill för MVP).
* **Beslutsunderlag som krävs:** Antal produkter och latenskrav (NFR-P4 säger < 200 ms p95).

### ADR-013 — Källa för produktkategorier <a name="adr-013"></a>
* **Status:** Öppen. Beslut behövs vid start av Fas 4 eller när dashboard ska visa kategorinedbrytning.
* **Kontext:** [ux-ui_vision.md](ux-ui_vision.md) avsnitt 2.1 visar en donut-graf med kategorinedbrytning. `PRODUCTS.category` finns i datamodellen men har ingen källa.
* **Alternativ:**
    * Manuell mappning från EAN-prefix-tabell.
    * Använda extern produktkatalog/API (kan tillkomma licens- och kostnadsfrågor).
    * AI-baserad klassificering på produktnamn vid första uppladdning.
    * Användardriven kategorisering (community moderation).
* **Beslutsunderlag som krävs:** Volym av nya produkter per månad, krav på precision i kategorin.

### ADR-014 — Verktyg för accessibility-tester <a name="adr-014"></a>
* **Status:** Öppen. Beslut behövs vid start av Fas 4.
* **Kontext:** [non-functional-requirements.md](non-functional-requirements.md) NFR-AC4 kräver linter för semantisk HTML.
* **Alternativ:**
    * `axe-core` via Playwright (kräver Playwright i Fas 4).
    * `pa11y` (Node-baserat, fristående).
    * Manuell granskning med skärmläsare (komplement, inte alternativ).
* **Beslutsunderlag som krävs:** Slutgiltigt val av e2e-verktyg (Playwright förespråkas i projektplanen).

### ADR-015 — Strategi för transaktionell e-post <a name="adr-015"></a>
* **Status:** Öppen. Beslut behövs när lösenordsåterställning ska byggas (post-MVP).
* **Kontext:** Lösenordsåterställning kräver e-postutskick. Spring stödjer JavaMail, men SMTP-leverantör måste väljas.
* **Alternativ:**
    * Brevo (gratis upp till 300 mejl/dag).
    * Resend (modern, generös free tier).
    * Postmark (premium, hög leveransbarhet).
    * Egen SMTP-server (avråds, dåligt rykte ur leveransbarhetssynpunkt).
* **Beslutsunderlag som krävs:** Volym, kostnad och leveransbarhetstester.

## Tillbakavisade förslag <a name="avslag"></a>

| Datum | Förslag | Skäl till avslag |
| --- | --- | --- |
| 2026-06-15 | Använda Kotlin istället för Java | Avviker från målet att djupdyka i moderna Java-funktioner (kompetensutveckling). |
| 2026-06-15 | Native iOS/Android-appar i MVP | För hög kostnad och komplexitet. Webb/PWA räcker (krav K19, Won't have). |
| 2026-06-20 | Direkt integration med Kivras API | Inte publikt tillgängligt. Användardriven uppladdning är enklare och mer transparent (krav K18, Won't have). |
| 2026-06-20 | Klientside-analys (Google Analytics) | Kräver cookie-banner. Server-side observability via OpenTelemetry valdes istället (se [gdpr.md](gdpr.md) avsnitt 4.3). |

## Hur du föreslår en ny ADR <a name="hur"></a>

1. Skapa en sektion längst ner under [Öppna beslut](#oppna) med nästa lediga `ADR-XXX`-nummer.
2. Beskriv **Kontext** (varför behövs ett beslut), **Alternativ** (minst två), och **Beslutsunderlag som krävs**.
3. Öppna en Pull Request med ändringen och länka relevanta dokument.
4. När beslut är fattat: ändra status till **Stängd**, flytta till [Stängda beslut](#stangda), uppdatera berörda dokument och länka tillbaka till ADR.
