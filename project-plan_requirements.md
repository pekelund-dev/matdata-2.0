# Projektplan och kravmatris: Matdata 2.0

| Metadata | |
| --- | --- |
| Version | 1.0 |
| Senast uppdaterad | 2026-06-29 |
| Status | Förstudie klar för granskning |
| Plats i dokumentationen | Styrdokument för krav och roadmap. |

> Detta är styrdokumentet för krav och utvecklingsfaser. För övriga dokument, se [README.md](README.md).

## Innehåll
- [1. Introduktion och syfte](#syfte)
- [2. Kravmatris (MoSCoW)](#kravmatris)
- [3. Utvecklingsfaser (roadmap)](#faser)
- [4. Definition of Done per fas](#dod)
- [5. Lanseringskriterier (release criteria)](#release)
- [6. Teststrategi](#test)
- [7. Spårbarhet mellan krav och dokument](#spar)
- [8. Förändringshantering](#change)

## 1. Introduktion och syfte <a name="syfte"></a>

Detta dokument fungerar som styrdokument för utvecklingen av Matdata 2.0. Innan kod skrivs etablerar vi här exakt *vad* som ska byggas (kravmatris) och i *vilken ordning* det ska byggas (roadmap).

Syftet är att bibehålla fokus på Minimum Viable Product (MVP) och säkerställa att kompetensutvecklingsmålen inom Java 26, Spring Boot 4.x, GCP och Terraform uppnås systematiskt, samtidigt som plattformen framtidssäkras för global prisstatistik.

Visionen och bakgrunden beskrivs i [prestudy.md](prestudy.md). Arkitekturen som understödjer kraven beskrivs i [architecture.md](architecture.md). Icke-funktionella krav (prestanda, säkerhet, accessibility) finns i [non-functional-requirements.md](non-functional-requirements.md). Användarcentrerade designkrav i [ux-ui_vision.md](ux-ui_vision.md).

## 2. Kravmatris (MoSCoW) <a name="kravmatris"></a>

Metoden MoSCoW används för att tydliggöra prioriteringar för första versionen (MVP) av systemet. Varje krav är spårbart och refererar — där det är relevant — till motsvarande NFR i [non-functional-requirements.md](non-functional-requirements.md) eller ADR i [open-decisions.md](open-decisions.md).

### 2.1 M — Must Have (kritiska krav för MVP)
*Systemet saknar värde utan dessa.*

| ID | Krav | Referens |
| --- | --- | --- |
| K1 | Applikationen måste kunna ta emot en uppladdad PDF-fil (ICA-kvitto via Kivra). | [architecture.md](architecture.md) avsnitt 4 |
| K2 | Systemet måste kunna extrahera text från PDF:en via Apache PDFBox. | [architecture.md](architecture.md) avsnitt 4 |
| K3 | Systemet måste kunna identifiera rot-artikelnummer (EAN/PLU) och hantera eller maskera viktvaror så att de grupperas korrekt. | [architecture.md](architecture.md) avsnitt 4.1 |
| K4 | Data måste sparas i en normaliserad relationsdatabas (Neon PostgreSQL). | [architecture.md](architecture.md) avsnitt 5, ADR-003 |
| K5 | En användare måste kunna logga in säkert och endast se sina egna kvitton. | [architecture.md](architecture.md) avsnitt 9, ADR-009 |
| K6 | CI/CD-pipeline via GitHub Actions måste finnas på plats från dag 1, inklusive PR-miljöer med databasbranchning. | [architecture.md](architecture.md) avsnitt 8 |
| K7 | Infrastruktur måste provisioneras via Terraform (IaC). | ADR-006 |
| K8 | (Privacy by Design) Datamodellen och arkitekturen måste från start designas för att strikt separera personligt knutna kvitton från global prisdata. | [gdpr.md](gdpr.md), [dpia.md](dpia.md) |

### 2.2 S — Should Have (viktiga, men appen överlever initialt utan)
*Starkt rekommenderade för en bra arkitektur och UX.*

| ID | Krav | Referens |
| --- | --- | --- |
| K9 | Uppdelning i två mikrotjänster (`core-service` och `parser-service`) som kommunicerar asynkront via GCP Pub/Sub. | ADR-002, [architecture.md](architecture.md) avsnitt 2 |
| K10 | Observabilitet via OpenTelemetry (traces och loggar exporterade till GCP). | NFR-O1, NFR-O2 |
| K11 | UI-komponentkatalog (Kitchen Sink) uppsatt på en specifik intern route (`/dev/components`) med Thymeleaf-fragment. | [ux-ui_vision.md](ux-ui_vision.md) avsnitt 3 |
| K12 | HTMX-polling för kvitto-uppladdning så att användaren ser status \"Bearbetas…\" utan sidladdning. | [ux-ui_vision.md](ux-ui_vision.md) avsnitt 2.2 |
| K13 | (Crowdsourcing-motor) Logik i `parser-service` som automatiskt tvättar och sparar inkommande kvittopriser till en anonymiserad global pris-pool oberoende av användaren. | [gdpr.md](gdpr.md) avsnitt 2.2, ADR-007 |

### 2.3 C — Could Have (bonusfunktioner, bra för backlog)
*Kan läggas till om tid eller budget tillåter.*

| ID | Krav | Referens |
| --- | --- | --- |
| K14 | En öppen statistikvy där användare kan se global prisutveckling på varor baserat på aggregerad data. | [architecture.md](architecture.md) datamodell `GLOBAL_PRICE_POINTS`, [ux-ui_vision.md](ux-ui_vision.md) avsnitt 5.3 |
| K15 | Analysvyn \"Moms-kollen\" för att jämföra priser före och efter ett specifikt datum. | [architecture.md](architecture.md) datamodell `RECEIPT_ITEMS.vat_rate` |
| K16 | Detektions- och varningssystem för krympflation om förpackningsstorlek minskar men priset förblir detsamma. | [ux-ui_vision.md](ux-ui_vision.md) avsnitt 2.3 |
| K17 | Stöd för papperskvitton via OCR (Google Cloud Vision API eller Gemini Vision). | [cost-estimate.md](cost-estimate.md) (potentiell kostnadspost post-MVP) |
| K20 | Stöd för ytterligare butiksformat (Coop, Hemköp, Willys) via ett plugin-baserat parser-system. | [risk-register.md](risk-register.md) V2 |

### 2.4 W — Won't Have (ligger utanför scopet för denna fas)
*Aktivt bortvalda för att hålla projektet hanterbart.*

| ID | Krav | Skäl |
| --- | --- | --- |
| K18 | Integration direkt mot Kivras eller bankernas API:er (Open Banking). | API:et är inte publikt tillgängligt. Avslagen i [open-decisions.md](open-decisions.md) avsnitt \"Tillbakavisade förslag\". |
| K19 | Dedikerade native iOS- och Android-appar. | För hög kostnad. Webb/PWA räcker. Avslagen i [open-decisions.md](open-decisions.md). |

### 2.5 Spårbarhetsmatris (kort)
Den kompletta spårbarheten mellan krav och dokumentation finns i [avsnitt 7](#spar). Här en sammanfattning av vilka faser som adresserar respektive krav:

| Krav | Fas 1 | Fas 2 | Fas 3 | Fas 4 | Fas 5 |
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

## 3. Utvecklingsfaser (roadmap) <a name="faser"></a>

För att inte bygga för mycket på en gång delas projektet in i logiska faser. Varje fas ska resultera i fungerande, deployad kod och uppfylla sina egna Definition of Done-kriterier (se [avsnitt 4](#dod)).

### 3.1 Fas 1: Grunden (infrastruktur och miljö)
*Mål: Ett tomt \"Hello World\"-projekt som deployas automatiskt.*

Innan denna fas startar ska följande vara klart: granskning av förstudien, acceptans av [risk-register.md](risk-register.md) och [cost-estimate.md](cost-estimate.md), samt bekräftelse av GDPR-strategi enligt [gdpr.md](gdpr.md).

1. Skapa GitHub-repo (`matdata-monorepo`).
2. Sätt upp Terraform-projekt (`/terraform`) och provisionera GCS-bucket, Pub/Sub-topic och Neon-databasprojekt.
3. Konfigurera Workload Identity Federation mellan GitHub Actions och GCP (NFR-SEC8).
4. Generera en tom Spring Boot 4-applikation (Java 26).
5. Sätt upp GitHub Actions som kompilerar koden, bygger Docker-image och driftsätter till Cloud Run. Konfigurera Neon DB-branching för PR:er.
6. Aktivera Dependabot och GitHub CodeQL (NFR-SEC6, NFR-SEC7).

### 3.2 Fas 2: Teknisk spike (PDF, domänlogik och anonymisering)
*Mål: Bevisa att vi faktiskt kan läsa datan och modellera den säkert.*

1. Implementera databasschemat via Flyway. **Viktigt:** Skapa separata tabeller för användarens egna kvittorader (`receipt_items`) och den globala anonymiserade prisdatan (`global_price_points`). Datamodellen specificeras i [architecture.md](architecture.md) avsnitt 5.
2. Bygg isolerad Java-logik med Apache PDFBox för att ladda in en ICA-PDF.
3. Skriv enhetstester med regex och domänlogik som bevisar att vi kan skala bort vikten från viktvarors streckkoder (EAN-prefix 20–29).
4. Implementera referens-PDF i canary-test enligt avsnitt 6.5.

### 3.3 Fas 3: Core backend och asynkront flöde
*Mål: Få arkitekturen med Pub/Sub att fungera.*

1. Separera projektet i `core-service` och `parser-service` enligt ADR-002.
2. Integrera OpenTelemetry (OTel) i båda tjänsterna (NFR-O1).
3. Skapa API-endpoint i `core-service` för att ladda upp fil → spara i GCS → skicka meddelande till Pub/Sub.
4. Låt `parser-service` konsumera Pub/Sub-meddelandet, ladda ner PDF från GCS och parsa datan.
5. Spara både det personliga kvittot som knyts till användaren **och** den anonyma globala pris-poolen (`global_price_points`) frikopplat från `users` (ADR-007).
6. Implementera idempotenshantering för Pub/Sub (jfr [risk-register.md](risk-register.md) T6) och konfigurera DLQ (NFR-A4).

### 3.4 Fas 4: Frontend och designsystem
*Mål: Ge applikationen ett ansikte med Thymeleaf och Tailwind.*

Innan denna fas startar ska följande ADR vara stängda: ADR-011 (chart-bibliotek), ADR-012 (sökarkitektur), ADR-013 (produktkategorier), ADR-014 (accessibility-verktyg).

1. Ta in AI-genererad Tailwind-kod från Stitch och bryt isär den i återanvändbara Thymeleaf-fragment (cards, buttons, tables).
2. Skapa den dolda `/dev/components`-routen (K11) enligt [ux-ui_vision.md](ux-ui_vision.md) avsnitt 3.
3. Bygg upp dashboard-vyn enligt [ux-ui_vision.md](ux-ui_vision.md) avsnitt 2.1.
4. Bygg sökfunktionen och kvitto-uppladdningen med HTMX (K12).
5. Sätt upp Spring Security för inloggning och utloggning med BCrypt cost ≥ 12 (NFR-SEC4).
6. Implementera CSP-header, CSRF-skydd och rate limiting på autentiseringsendpoints (NFR-SEC2, NFR-SEC3, NFR-SEC10).

### 3.5 Fas 5: Polering och lansering av MVP
*Mål: Verifiera att allt hänger ihop och är redo för dagligt bruk.*

1. Implementera Row-Level Security-kontroller i databaslagret (K5).
2. Bygg produktdetalj-vyn med prishistorikgrafer, eventuellt med en graf-linje för \"Ditt pris\" och en linje för \"Globalt snittpris\".
3. Testning med riktiga kvitton (minst 50 olika kvitton för att verifiera ≥ 95 % parsing-träffsäkerhet enligt [prestudy.md](prestudy.md) avsnitt 7.1).
4. Säkerställ loggning och larm i GCP enligt NFR-O4 och NFR-A4.
5. Genomför extern säkerhetsgranskning enligt NFR-SEC9.
6. Verifiera GDPR-checklistan i [gdpr.md](gdpr.md) avsnitt 8.
7. Genomför DPIA-revision enligt [dpia.md](dpia.md).
8. Acceptanstest av WCAG 2.1 AA enligt NFR-AC1.

## 4. Definition of Done per fas <a name="dod"></a>

En fas är klar när **samtliga** kriterier nedan är uppfyllda. Detta kopplar fasen till mätbara krav och NFR:er.

### 4.1 DoD — Fas 1
* [ ] Repo `matdata-monorepo` finns på GitHub med korrekt katalogstruktur ([architecture.md](architecture.md) avsnitt 14).
* [ ] Terraform applicerar grundinfrastrukturen utan manuella ingrepp.
* [ ] GitHub Actions kör build + test + deploy på varje PR.
* [ ] Neon DB-branching skapar ny isolerad databas vid PR.
* [ ] Dependabot och CodeQL är aktiverade.
* [ ] `core-service` svarar på `GET /healthz` via Cloud Run.

### 4.2 DoD — Fas 2
* [ ] Flyway-migreringar lägger upp datamodellen enligt [architecture.md](architecture.md) avsnitt 5.
* [ ] Enhetstester för PDF-parsning täcker minst 80 % linjetäckning på domänklasser (NFR-M1).
* [ ] EAN-maskning för viktvaror är verifierad mot minst 10 referens-PDF:er.
* [ ] Anonymiseringen i `global_price_points` är verifierad — ingen koppling till `users` eller exakt tidsstämpel.

### 4.3 DoD — Fas 3
* [ ] Pub/Sub-flöde går från `core-service` till `parser-service` och tillbaka.
* [ ] OpenTelemetry-traces täcker hela uppladdningsflödet (NFR-O1).
* [ ] DLQ är konfigurerad och larmar vid trafik (NFR-A4).
* [ ] Idempotenshantering verifierad genom test som skickar samma meddelande två gånger.
* [ ] Strukturerade JSON-loggar med trace ID (NFR-O2).

### 4.4 DoD — Fas 4
* [ ] Alla MVP-sidor renderas korrekt i Chrome, Safari, Edge och mobil (NFR-BR1–NFR-BR6).
* [ ] Spring Security skyddar alla relevanta endpoints (CSRF, sessionsregenerering).
* [ ] HTMX-polling fungerar för kvitto-uppladdning utan sidladdning.
* [ ] `/dev/components` visar samtliga UI-komponenter.
* [ ] Rate limiting på autentiseringsendpoints är aktiv.
* [ ] axe-core eller motsvarande accessibility-linter kör i CI (NFR-AC4).

### 4.5 DoD — Fas 5 (MVP-lansering)
* [ ] Samtliga \"Must Have\"-krav (K1–K8) är uppfyllda och verifierade.
* [ ] WCAG 2.1 AA-audit är genomförd (NFR-AC1).
* [ ] GDPR-checklistan i [gdpr.md](gdpr.md) avsnitt 8 är avbockad.
* [ ] DPIA-revision genomförd och godkänd.
* [ ] Extern säkerhetsgranskning genomförd (NFR-SEC9).
* [ ] Lyckad katastrofåterhämtningsövning genomförd (NFR-B4).
* [ ] Manuella testfall för minst 50 olika kvitton — ≥ 95 % träffsäkerhet ([prestudy.md](prestudy.md) avsnitt 7.1).

## 5. Lanseringskriterier (release criteria) <a name="release"></a>

Innan Matdata 2.0 anses redo för publik lansering ska följande grindar passeras:

### 5.1 Tekniska kriterier
* [ ] Samtliga DoD-kriterier för Fas 1–5 är avbockade.
* [ ] Inga **kritiska** eller **höga** säkerhetsbuggar är öppna (CVSS ≥ 7.0).
* [ ] Inga öppna ADR återstår som blockerar Fas 4 (se [open-decisions.md](open-decisions.md)).
* [ ] Smoke-tester körs gröna i prod-miljön efter deploy.

### 5.2 Juridiska och compliance-kriterier
* [ ] DPIA är genomförd och godkänd enligt [dpia.md](dpia.md).
* [ ] Personuppgiftsbiträdesavtal (DPA) är på plats med samtliga biträden ([gdpr.md](gdpr.md) avsnitt 7).
* [ ] Integritetspolicy är publicerad.
* [ ] Cookie-strategi är dokumenterad (\"Zero Annoyance\", [gdpr.md](gdpr.md) avsnitt 5.3).
* [ ] Incidentprocess är dokumenterad och övad ([dpia.md](dpia.md) avsnitt 10).

### 5.3 Driftskriterier
* [ ] Larm är konfigurerade för SLO-brott (NFR-O4) och DLQ (NFR-A4).
* [ ] On-call/eskaleringskedja är dokumenterad.
* [ ] Backup-rutin är verifierad (NFR-B4).
* [ ] Cost monitoring och budget-larm är aktiva ([cost-estimate.md](cost-estimate.md) avsnitt 7).

### 5.4 Produktkriterier
* [ ] Användartester med minst 5 personer från målgruppen ([prestudy.md](prestudy.md) avsnitt 2) är genomförda och feedback adresserad.
* [ ] Manuell testning av huvudflödet (registrering, inloggning, uppladdning, sökning, radering) är godkänd.
* [ ] Onboarding-guide eller introduktion finns för nya användare ([ux-ui_vision.md](ux-ui_vision.md)).

## 6. Teststrategi <a name="test"></a>

### 6.1 Enhetstester (unit tests)
* JUnit 5 och Mockito används som standardramverk.
* Fokus ligger särskilt på Parser Service-domänlogik, till exempel EAN-maskning och logik för viktvaror.
* Målsättningen är att all affärskritisk business logic ska vara täckt av enhetstester. Specifikt mål: ≥ 80 % linjetäckning på domänklasser (NFR-M1).

### 6.2 Integrationstester
* Spring Boot Test och Testcontainers används för integrationstester.
* PostgreSQL körs i container för att verifiera repository-lager, Flyway-migreringar och Pub/Sub-integration (emulator).
* Neon DB-branching används för PR-miljöer där mer realistiska verifieringar behövs mot delad molninfrastruktur.

### 6.3 End-to-end-tester
* För MVP prioriteras manuell testning med riktiga ICA- och Kivra-PDF:er i PR-miljön.
* Automatiserade end-to-end-tester införs efter MVP, exempelvis med Playwright. Beslut om verktyg är kopplat till ADR-014 i [open-decisions.md](open-decisions.md).

### 6.4 Parser-versionshantering och extensibilitet
* Parsern utformas med ett strategi- eller pluginmönster så att nya butiksformat kan läggas till utan att befintliga parsers behöver modifieras.
* Varje parser identifieras med butik och formatversion, så att layoutförändringar hos ICA eller framtida aktörer som Coop, Hemköp och Willys kan hanteras kontrollerat (K20).

### 6.5 Övervakning av PDF-layoutförändringar (canary)
* En canary-test körs veckovis mot en lagrad referens-PDF.
* Om parsingresultatet förändras utan avsedd kodändring ska testet larma, så att layoutändringar i käll-PDF:er upptäcks tidigt (mitigering för T1 i [risk-register.md](risk-register.md)).
* Canary-testet körs som ett schemalagt GitHub Actions-jobb.

### 6.6 Säkerhetstester
* SAST: GitHub CodeQL (NFR-SEC7).
* Dependency scanning: Dependabot (NFR-SEC6).
* Container scanning: Trivy eller motsvarande i CI.
* Extern säkerhetsgranskning innan publik lansering (NFR-SEC9).

### 6.7 Accessibility-tester
* axe-core eller pa11y i CI (NFR-AC4). Verktygsval i ADR-014.
* Manuella tester med skärmläsare (NVDA eller VoiceOver) innan lansering (NFR-AC5).

### 6.8 Prestanda-tester
* Lasttester med k6 eller Gatling görs innan publik lansering.
* Verifierar SLO:er i [non-functional-requirements.md](non-functional-requirements.md) avsnitt 1.

## 7. Spårbarhet mellan krav och dokument <a name="spar"></a>

För att hålla kraven förankrade i övrig dokumentation används följande spårbarhetsmatris. Den kompletteras vid behov av referenser direkt i kraven (se [avsnitt 2](#kravmatris)).

| Krav | Beskrivning kort | NFR | ADR | Arkitektur | UX/UI |
| --- | --- | --- | --- | --- | --- |
| K1 | PDF-uppladdning | NFR-S4 | — | [architecture.md](architecture.md) §4 | [ux-ui_vision.md](ux-ui_vision.md) §2.2 |
| K2 | Textextraktion (PDFBox) | NFR-P2 | — | [architecture.md](architecture.md) §4 | — |
| K3 | EAN/PLU-hantering | — | — | [architecture.md](architecture.md) §4.1 | — |
| K4 | Normaliserad databas | NFR-S3 | ADR-003 | [architecture.md](architecture.md) §5 | — |
| K5 | Säker inloggning + isolering | NFR-SEC1–SEC5 | ADR-009 | [architecture.md](architecture.md) §9 | [ux-ui_vision.md](ux-ui_vision.md) §2.5 |
| K6 | CI/CD med PR-miljöer | NFR-SEC8 | — | [architecture.md](architecture.md) §8 | — |
| K7 | Terraform IaC | NFR-B5 | ADR-006 | [architecture.md](architecture.md) §8 | — |
| K8 | Privacy by Design | NFR-D1–D8 | ADR-007 | [architecture.md](architecture.md) §5, [gdpr.md](gdpr.md), [dpia.md](dpia.md) | — |
| K9 | Två mikrotjänster + Pub/Sub | NFR-A3, NFR-A4 | ADR-002 | [architecture.md](architecture.md) §2 | — |
| K10 | OpenTelemetry | NFR-O1, NFR-O2 | — | [architecture.md](architecture.md) §11 | — |
| K11 | Komponentkatalog `/dev/components` | NFR-M5 | — | — | [ux-ui_vision.md](ux-ui_vision.md) §3 |
| K12 | HTMX-polling | NFR-P3 | ADR-005 | [architecture.md](architecture.md) §2.2 | [ux-ui_vision.md](ux-ui_vision.md) §2.2 |
| K13 | Crowdsourcing-motor | NFR-D3 | ADR-007 | [architecture.md](architecture.md) §5 | — |
| K14 | Öppen statistikvy | — | — | datamodell `GLOBAL_PRICE_POINTS` | [ux-ui_vision.md](ux-ui_vision.md) §5.3 |
| K15 | Moms-kollen | — | — | datamodell `vat_rate` | [ux-ui_vision.md](ux-ui_vision.md) §2.4 |
| K16 | Krympflations-varning | — | — | — | [ux-ui_vision.md](ux-ui_vision.md) §2.3 |
| K17 | OCR-stöd | NFR-P2 | — | (post-MVP) | — |
| K20 | Pluginbara parsers | — | — | (post-MVP) | — |

## 8. Förändringshantering <a name="change"></a>

Varje nytt krav eller större förändring av befintligt krav ska:

1. Beskrivas i en GitHub Issue med tydlig motivering.
2. Klassificeras enligt MoSCoW.
3. Om det är ett arkitekturbeslut: skapa ny ADR i [open-decisions.md](open-decisions.md).
4. Om det påverkar NFR: uppdatera [non-functional-requirements.md](non-functional-requirements.md).
5. Om det påverkar dataskydd: uppdatera [gdpr.md](gdpr.md) och [dpia.md](dpia.md).
6. Riskbedömning: uppdatera [risk-register.md](risk-register.md) om risken ändras.
7. Kostnadsbedömning: uppdatera [cost-estimate.md](cost-estimate.md) om kostnadsbilden ändras.

Versionering av detta dokument följer [SemVer](https://semver.org/): **MAJOR** vid scope-ändring av MVP, **MINOR** vid nya krav, **PATCH** vid små klargöranden.
