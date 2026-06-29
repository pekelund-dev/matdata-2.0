# User Stories: Matdata 2.0

| Metadata | |
| --- | --- |
| Version | 1.0 |
| Senast uppdaterad | 2026-06-29 |
| Status | Förstudie klar för granskning |
| Plats i dokumentationen | Härleder utvecklingsbar backlog från [project-plan_requirements.md](project-plan_requirements.md). |

> Detta dokument bryter ner kraven (K1–K20) och NFR:erna till **epics** och **user stories** med acceptanskriterier i Given/When/Then-form. Varje story har minst 5 AC, en DoD-checklista och spårbarhet till K-krav, NFR och ADR. Personas hämtas från [ux-ui_vision.md](ux-ui_vision.md) avsnitt 1.5.

## Innehåll
- [1. Konventioner](#konventioner)
- [2. Översikt av epics](#oversikt)
- [3. Spårbarhet story → krav](#sparbarhet)
- [4. Epic 1 — Infrastruktur och DevOps-grund](#epic-1)
- [5. Epic 2 — Konto och autentisering](#epic-2)
- [6. Epic 3 — Kvitto-uppladdning och asynkron parsing](#epic-3)
- [7. Epic 4 — Personlig prishistorik och sökning](#epic-4)
- [8. Epic 5 — Crowdsourcing och global statistik](#epic-5)
- [9. Epic 6 — Tematiska insikter (Moms-kollen och krympflation)](#epic-6)
- [10. Epic 7 — GDPR och användarrättigheter](#epic-7)
- [11. Epic 8 — Designsystem och accessibility](#epic-8)
- [12. Epic 9 — Observability och drift](#epic-9)

## 1. Konventioner <a name="konventioner"></a>

### 1.1 Storyformat
Varje story följer mönstret:

> **Som** \<persona\> **vill jag** \<förmåga\> **för att** \<värde\>.

Personas: **Anna** (38, projektledare), **Markus** (29, utvecklare), **Sofia** (52, ekonomichef i hushållet), **Utvecklare** (intern), **Driftansvarig**, **DPO/säkerhetsgranskare**. Se [ux-ui_vision.md](ux-ui_vision.md) §1.5.

### 1.2 Acceptanskriterier (AC)
AC:n skrivs som Given/When/Then. **Minst 5 AC per story** krävs för att fånga huvudflöde, edge cases, fel-states, säkerhets-/integritetskrav och mätbara NFR:er. För backend-only stories tillåts ett tekniskt verifieringskriterium (test/mätning) räknas som AC.

### 1.3 Definition of Done (story-nivå)
En story är klar när:
* [ ] Alla AC är verifierade automatiskt (test) eller manuellt enligt PR-checklistan.
* [ ] Kodtäckning för ny domänlogik ≥ 80 % (NFR-M1) där tillämpligt.
* [ ] Inga öppna kritiska eller höga säkerhetsbrister (CVSS ≥ 7.0) i ändrade filer.
* [ ] Spårbarhet till K-krav/NFR/ADR finns i PR-beskrivningen.
* [ ] Om UI: granskning enligt [ux-ui_vision.md](ux-ui_vision.md) §9.3 (empty/fel-state, tangentbord, kontrast, skärmläsare).
* [ ] Om datamodelländring: Flyway-migrering, indexstrategi och påverkan på [gdpr.md](gdpr.md)/[dpia.md](dpia.md) granskade.
* [ ] Dokumentation uppdaterad (relevant `.md` + commit-meddelande enligt Conventional Commits, NFR-M6).

### 1.4 Estimering och prioritet
Stories ärver prioritet från det K-krav de implementerar (M/S/C/W per MoSCoW). Estimat (story points) sätts vid sprintplanering — anges inte här.

### 1.5 Story-ID
Format: `US-<epic>.<löpnr>`, t.ex. `US-3.2`. Epic-ID matchar avsnittsnumreringen i detta dokument.

## 2. Översikt av epics <a name="oversikt"></a>

| Epic | Tema | Primära krav | Fas (enligt [project-plan_requirements.md](project-plan_requirements.md) §3) |
| --- | --- | --- | --- |
| Epic 1 | Infrastruktur och DevOps-grund | K6, K7 | Fas 1 |
| Epic 2 | Konto och autentisering | K5 | Fas 4–5 |
| Epic 3 | Kvitto-uppladdning och asynkron parsing | K1, K2, K3, K9, K12 | Fas 2–4 |
| Epic 4 | Personlig prishistorik och sökning | K4, K12 | Fas 2–5 |
| Epic 5 | Crowdsourcing och global statistik | K8, K13, K14 | Fas 3 + post-MVP |
| Epic 6 | Tematiska insikter (Moms-kollen, krympflation) | K15, K16 | Post-MVP (C) |
| Epic 7 | GDPR och användarrättigheter | K8 + GDPR Art. 13–22 | Fas 4–5 |
| Epic 8 | Designsystem och accessibility | K11, K12, NFR-AC1–6 | Fas 4 |
| Epic 9 | Observability och drift | K10, NFR-O1–6, NFR-A1–4 | Fas 3 + Fas 5 |

## 3. Spårbarhet story → krav <a name="sparbarhet"></a>

| Story | K-krav | NFR | ADR |
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

## 4. Epic 1 — Infrastruktur och DevOps-grund <a name="epic-1"></a>

**Mål:** Innan en enda affärsfunktion implementeras ska repo, CI/CD, IaC och säkerhetsskanning vara på plats så att varje PR genererar en isolerad, körbar miljö. Motsvarar **Fas 1** i [project-plan_requirements.md](project-plan_requirements.md) §3.1.

**Krav:** K6, K7. **NFR:** SEC6, SEC7, SEC8, B5.

### US-1.1 — CI-pipeline för PR-byggen
**Som** utvecklare **vill jag** att varje Pull Request automatiskt bygger båda Spring Boot-tjänsterna, kör enhetstester och statisk analys **för att** snabbt få feedback innan merge.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K6) |
| Spårbarhet | K6, NFR-SEC6, NFR-SEC7, NFR-SEC8, NFR-M2 |
| Persona | Utvecklare |

**Acceptanskriterier:**
1. **Given** en utvecklare öppnar en PR mot `main`, **when** GitHub Actions startar, **then** workflow `build.yml` kör `mvn verify` för både `core-service` och `parser-service` parallellt.
2. **Given** ett PR-bygge, **when** byggjobbet kör, **then** CodeQL (NFR-SEC7) och Dependabot-rapport (NFR-SEC6) körs och blockerar merge vid `error`-fynd.
3. **Given** ett PR-bygge, **when** koden formateras fel, **then** Spotless eller motsvarande formatter (NFR-M2) markerar checken som `failed`.
4. **Given** ett lyckat PR-bygge, **when** alla checks är gröna, **then** Docker-images publiceras till GitHub Container Registry med tagg `pr-<nr>-<sha>`.
5. **Given** en GCP-deploy från CI, **when** workflow autentiserar sig, **then** Workload Identity Federation (NFR-SEC8) används — **inga** långlivade service-account-nycklar lagras i GitHub Secrets.
6. **Given** ett PR-bygge tar > 10 minuter, **when** byggtiden mäts, **then** en GitHub Actions-cache används för Maven-beroenden så att medianbyggtid ≤ 6 minuter.

**DoD:** Workflow-fil finns under `.github/workflows/`, dokumenterad i [architecture.md](architecture.md) §6, gröna checks krävs för merge enligt branch protection.

---

### US-1.2 — Terraform-modul för basinfrastruktur
**Som** utvecklare **vill jag** att GCP-resurser (GCS-bucket, Pub/Sub-topic, Cloud Run-tjänster, IAM) och Neon-projekt provisioneras via Terraform **för att** miljöer kan återskapas reproducerbart.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K7) |
| Spårbarhet | K7, NFR-B5, ADR-006 |
| Persona | Utvecklare, Driftansvarig |

**Acceptanskriterier:**
1. **Given** ett nytt GCP-projekt, **when** `terraform apply` körs från `/terraform`, **then** GCS-bucket, Pub/Sub-topic `receipt-uploads`, DLQ-topic, två Cloud Run-tjänster och två service accounts skapas utan manuella steg.
2. **Given** Terraform-modulerna, **when** `terraform validate` körs i CI, **then** alla moduler valideras och `tflint`/`checkov` flaggar inga öppna fynd med severity ≥ `high`.
3. **Given** ett befintligt miljö-state, **when** Terraform planeras, **then** state lagras remote (GCS-bucket med versionering och lock via Cloud Storage) — aldrig lokalt.
4. **Given** en Pull Request som ändrar Terraform-kod, **when** PR öppnas, **then** CI postar `terraform plan`-utfallet som PR-kommentar.
5. **Given** Neon-projektet, **when** Terraform kör, **then** main-branch och produktionsdatabasrollen provisioneras via Neon Terraform-provider med budgetlarm aktiverat.
6. **Given** en katastrof där hela GCP-projektet förloras, **when** Terraform appliceras mot ett nytt projekt, **then** hela infrastrukturen kan återskapas på ≤ 1 timme (mätt i återhämtningstest, NFR-B5).

**DoD:** Modulerna ligger under `/terraform/modules/{gcp,neon}/`, dokumenterade i [architecture.md](architecture.md) §8, körda i CI för minst dev-miljön.

---

### US-1.3 — PR-miljö med Neon-databasbranching
**Som** utvecklare **vill jag** att varje PR får en isolerad databas och Cloud Run-deploy **för att** kunna testa migreringar och nya features mot en ren miljö utan att påverka prod.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K6) |
| Spårbarhet | K6 |
| Persona | Utvecklare |

**Acceptanskriterier:**
1. **Given** en ny PR öppnas, **when** workflow `pr-environment.yml` triggas, **then** en Neon-databasbranch skapas från `main` med suffix `pr-<nr>`.
2. **Given** PR-miljön är uppe, **when** workflow är klar, **then** PR-kommentar publiceras med URL till `core-service`, `parser-service` och Neon-branch.
3. **Given** två öppna PR:er samtidigt, **when** de deployas, **then** de använder separata Pub/Sub-topic per PR för att förhindra meddelandekrock.
4. **Given** en PR stängs eller merges, **when** workflow `pr-teardown.yml` triggas, **then** Cloud Run-revisioner, Pub/Sub-topic och Neon-branch raderas inom 5 minuter.
5. **Given** en PR-deploy som misslyckas, **when** workflow brakar, **then** felet rapporteras som PR-check med direktlänk till `get_job_logs` och Neon-branchen raderas trots felet (cleanup-step `if: always()`).
6. **Given** att Flyway-migreringar finns i PR:en, **when** PR-miljön startar, **then** migreringarna körs mot PR-databranchen automatiskt vid deploy.

**DoD:** Workflows finns och har körts grönt minst två gånger, dokumenterade i [architecture.md](architecture.md) §6.1.

---

### US-1.4 — Health- och smoke-checks efter deploy
**Som** driftansvarig **vill jag** att varje produktionsdeploy verifieras med smoke-tester **för att** trasiga releaser fångas innan användare påverkas.

| Fält | Värde |
| --- | --- |
| Prioritet | M |
| Spårbarhet | K6, NFR-A1, NFR-A2 |
| Persona | Driftansvarig |

**Acceptanskriterier:**
1. **Given** en deploy till prod-miljön, **when** `core-service`-revisionen får trafik, **then** `GET /healthz` returnerar `200 OK` med `status: UP`.
2. **Given** en grön healthcheck, **when** workflow fortsätter, **then** smoke-test kör `GET /login` och verifierar att sidan svarar `200` och innehåller CSRF-token.
3. **Given** en misslyckad smoke-check, **when** Cloud Run upptäcker fel, **then** trafiken rullas tillbaka till föregående revision (gradual rollout-config) inom 60 sekunder.
4. **Given** en deploy, **when** den lyckas, **then** Cloud Monitoring annoterar deploy-händelsen så att felgrad kan korreleras med releaser.
5. **Given** en produktionsincident, **when** team behöver veta senaste deploy, **then** `git tag prod-<datum>` finns på commit som motsvarar nuvarande revision.

**DoD:** Smoke-test finns i `.github/workflows/deploy.yml`, dokumenterad i release-runbook.

## 5. Epic 2 — Konto och autentisering <a name="epic-2"></a>

**Mål:** Säker, sessionbaserad inloggning där användaren bara ser sina egna kvitton. Motsvarar **Fas 4** + säkerhetsåtgärder i **Fas 5**.

**Krav:** K5. **NFR:** SEC1–SEC5, SEC10, D4. **ADR:** ADR-009.

### US-2.1 — Registrering med e-post och lösenord
**Som** Anna **vill jag** kunna skapa ett konto med min e-post och ett lösenord **för att** börja ladda upp kvitton.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K5) |
| Spårbarhet | K5, NFR-SEC4, NFR-SEC5, ADR-009 |
| Persona | Anna |

**Acceptanskriterier:**
1. **Given** registreringsformuläret, **when** Anna fyller i giltig e-post och ett lösenord ≥ 12 tecken, **then** kontot skapas och hon loggas in direkt med ny sessions-cookie.
2. **Given** ett lösenord som är < 12 tecken eller finns i `pwned-passwords`-listan, **when** formuläret submittas, **then** ett klarspråksfel visas under fältet och kontot skapas **inte**.
3. **Given** att lösenord sparas, **when** posten skrivs till `USERS`, **then** `password_hash` är en BCrypt-hash med kostnad ≥ 12 (NFR-SEC4) och plaintext finns aldrig kvar i loggar eller minne efter request.
4. **Given** en redan registrerad e-post, **when** någon försöker registrera samma adress, **then** systemet svarar med generiskt meddelande ("Om e-posten är ny får du en bekräftelse") för att inte avslöja kontoexistens.
5. **Given** en lyckad registrering, **when** sessionen skapas, **then** Spring Securitys sessionsregenerering körs (NFR-SEC5) och cookien sätts som `HttpOnly`, `Secure`, `SameSite=Lax`.
6. **Given** ett registreringsförsök, **when** användaren inte aktivt kryssar i samtycke för crowdsourcing, **then** `USERS.share_anonymous_data = false` (default), enligt [gdpr.md](gdpr.md) §8.1.

**DoD:** Endpoint `POST /register` med integrationstest, dokumenterad i [architecture.md](architecture.md) §9.1.

---

### US-2.2 — Inloggning med rate limiting
**Som** användare **vill jag** kunna logga in med min e-post och lösenord **för att** komma åt mitt konto, **utan att** illvilliga aktörer kan gissa sig fram via brute-force.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K5) |
| Spårbarhet | K5, NFR-SEC10 |
| Persona | Anna, Sofia |

**Acceptanskriterier:**
1. **Given** korrekta uppgifter, **when** formuläret skickas, **then** användaren omdirigeras till `/dashboard` med ny session.
2. **Given** felaktiga uppgifter, **when** formuläret skickas, **then** felmeddelandet är generiskt: "Fel e-post eller lösenord" (UX §5.2) — ingen indikation på vilket fält som var fel.
3. **Given** 5 misslyckade försök från samma IP inom 10 minuter, **when** ett sjätte försök görs, **then** anropet returnerar `429 Too Many Requests` (NFR-SEC10) och en återhämtningstid visas.
4. **Given** rate limiting triggas, **when** händelsen loggas, **then** posten skrivs till audit-loggen (NFR-D6) utan att avslöja om e-posten finns i systemet.
5. **Given** att en användare redan är inloggad, **when** hon besöker `/login`, **then** sidan redirectar till `/dashboard` automatiskt.
6. **Given** en lyckad inloggning, **when** sessionen återanvänds, **then** Spring Security regenererar sessions-ID (NFR-SEC5) för att skydda mot session fixation.

**DoD:** Integrationstest för 401, 429 och 302; rate limiter-konfiguration dokumenterad.

---

### US-2.3 — Utloggning och CSRF-skydd
**Som** användare **vill jag** kunna logga ut säkert **för att** ingen annan ska kunna fortsätta använda mitt konto från min enhet.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K5) |
| Spårbarhet | K5, NFR-SEC3 |
| Persona | Anna, Sofia, Markus |

**Acceptanskriterier:**
1. **Given** en inloggad session, **when** användaren klickar "Logga ut", **then** sessionen invalideras serverside och cookien rensas i klienten.
2. **Given** utloggningsformuläret, **when** request skickas, **then** den kräver giltig `X-XSRF-TOKEN`-header (NFR-SEC3) — GET-baserad utloggning är blockerad.
3. **Given** en utloggad session, **when** användaren navigerar tillbaka via webbläsarhistoriken, **then** skyddade sidor svarar med redirect till `/login` (sidor cachas inte via `Cache-Control: no-store`).
4. **Given** att HTMX-anrop görs från en inloggad sida, **when** request skickas, **then** `X-XSRF-TOKEN`-header inkluderas automatiskt (mönstret beskrivs i [ux-ui_vision.md](ux-ui_vision.md) §3.4).
5. **Given** en utloggning, **when** händelsen sker, **then** den loggas i audit-loggen (NFR-D6) med trace ID.

**DoD:** Endpoint `POST /logout` med test för CSRF-skydd och sessionsinvalidering.

---

### US-2.4 — Sessionshantering över flera instanser
**Som** driftansvarig **vill jag** att sessioner lagras i databasen (JDBC) **för att** Cloud Run kan skala upp till flera instanser utan att användaren loggas ut.

| Fält | Värde |
| --- | --- |
| Prioritet | M |
| Spårbarhet | K5, NFR-D4 |
| Persona | Driftansvarig |

**Acceptanskriterier:**
1. **Given** två `core-service`-instanser bakom Cloud Run, **when** en användare loggar in mot instans A och nästa request går till instans B, **then** sessionen är fortfarande giltig.
2. **Given** Spring Session JDBC, **when** sessionen skapas, **then** posten skrivs i `SPRING_SESSION`-tabellen i Neon PostgreSQL.
3. **Given** en inaktiv session i 30 dagar (NFR-D4), **when** rensningsjobbet kör dagligen, **then** sessionen raderas från databasen.
4. **Given** att en användare loggar ut, **when** request behandlas, **then** posten raderas direkt från `SPRING_SESSION`.
5. **Given** att Neon är temporärt otillgänglig, **when** session-lookup misslyckas, **then** användaren får felmeddelande "Tillfälligt problem, försök igen" och en alarm triggas (NFR-A4).

**DoD:** Integrationstest med Testcontainers, dokumenterat i [architecture.md](architecture.md) §9.1.

## 6. Epic 3 — Kvitto-uppladdning och asynkron parsing <a name="epic-3"></a>

**Mål:** Implementera grundflödet "PDF in → tolkad data ut" med asynkron arkitektur. Motsvarar **Fas 2–3** + UX i Fas 4.

**Krav:** K1, K2, K3, K9, K12. **NFR:** A3, A4, P2, P3, M1, S4. **ADR:** ADR-002, ADR-005.

### US-3.1 — PDF-uppladdning från Kivra
**Som** Anna **vill jag** kunna ladda upp en PDF-fil från Kivra via drag-and-drop **för att** registrera ett nytt kvitto.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K1) |
| Spårbarhet | K1, NFR-S4, NFR-P1 |
| Persona | Anna |

**Acceptanskriterier:**
1. **Given** uppladdningsvyn, **when** Anna släpper en PDF (≤ 10 MB) i drop-zonen, **then** filen laddas upp via `POST /api/receipts/upload` och `core-service` returnerar `202 Accepted` med `receiptId`.
2. **Given** en uppladdning, **when** `core-service` tar emot filen, **then** PDF:en sparas i privat GCS-bucket med path `gs://<bucket>/<userId>/<receiptId>.pdf`, ingen publik URL skapas.
3. **Given** en fil som inte är PDF eller är > 10 MB (NFR-S4), **when** uppladdning försöks, **then** request avvisas med `400 Bad Request` och klarspråksfel: "Filen måste vara en PDF på max 10 MB" (UX §5.2).
4. **Given** en lyckad uppladdning, **when** posten skrivs, **then** en rad i `RECEIPTS` skapas med status `PENDING`, `user_id` från sessionen och `pdf_storage_uri`.
5. **Given** att posten skapats, **when** uppladdningen är klar, **then** ett Pub/Sub-meddelande `{receiptId, gcsUri, traceId}` publiceras till topic `receipt-uploads`.
6. **Given** en duplicerad uppladdning (samma `sha256`-hash av PDF inom 24 h), **when** Anna laddar upp igen, **then** systemet visar varning "Detta kvitto är redan uppladdat" (UX §5.3) och skapar ingen ny `RECEIPTS`-post.

**DoD:** Endpoint testad med MockMvc + Testcontainers (Pub/Sub-emulator + Postgres), upplagd enligt sekvensdiagram i [architecture.md](architecture.md) §4.1.

---

### US-3.2 — Asynkron parsing via Parser Service
**Som** Anna **vill jag** att mitt uppladdade kvitto bearbetas i bakgrunden **för att** jag ska se priser och kategorisering utan att vänta i UI.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K2, K9) |
| Spårbarhet | K2, K9, NFR-A3, NFR-P2, ADR-002 |
| Persona | Anna, Markus |

**Acceptanskriterier:**
1. **Given** ett meddelande på `receipt-uploads`, **when** `parser-service` konsumerar det, **then** PDF:en hämtas från GCS och text extraheras via Apache PDFBox.
2. **Given** ett parsat kvitto, **when** datan persisteras, **then** `RECEIPT_ITEMS`-rader skrivs kopplade till `PRODUCTS` (existerande eller nya) och `RECEIPTS.status` uppdateras till `COMPLETED`.
3. **Given** ett kvitto på ≤ 5 MB, **when** parsing genomförs, **then** total bearbetningstid (från Pub/Sub-meddelande till `COMPLETED`) är < 30 sekunder p95 (NFR-P2), mätt via `receipt_processing_seconds`-metric.
4. **Given** ett parser-fel (PDF kan inte läsas), **when** undantag kastas, **then** `RECEIPTS.status = FAILED` och `failure_reason` skrivs; meddelandet ackas inte och Pub/Sub kan retrya enligt policy.
5. **Given** att samma meddelande levereras två gånger (at-least-once), **when** `parser-service` startar bearbetning, **then** den kontrollerar `RECEIPTS.status` — om `COMPLETED` ackas meddelandet utan att skriva igen (idempotens, [architecture.md](architecture.md) §10.5).
6. **Given** lyckad bearbetning av minst 95 % av 50 referenskvitton, **when** acceptanstest körs, **then** `parser_success_ratio` ≥ 0.95 (NFR-A3, kopplad till release-kriterium i [project-plan_requirements.md](project-plan_requirements.md) §4.5).

**DoD:** Integrationstest med 10 verkliga referens-PDF:er, OTel-trace täcker hela flödet (NFR-O1).

---

### US-3.3 — EAN/PLU-maskning för viktvaror
**Som** Markus **vill jag** att viktvaror (köttfärs, ost m.m.) grupperas under samma produkt **för att** prishistoriken inte ska splittras per förpackning.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K3) |
| Spårbarhet | K3, NFR-M1 |
| Persona | Markus |

**Acceptanskriterier:**
1. **Given** en EAN-13 med prefix `20`–`29`, **when** parsern processar koden, **then** vikt-/prissiffrorna maskas och endast bas-artikelnumret sparas i `PRODUCTS.article_number`.
2. **Given** två kvitton med samma viktvara men olika faktiska vikter, **when** båda är parsade, **then** de pekar på **samma** rad i `PRODUCTS` via samma `article_number`.
3. **Given** en standard-EAN (icke-viktvara, t.ex. prefix `73`), **when** parsern processar, **then** ingen maskning sker och hela streckkoden sparas.
4. **Given** en PLU-kod (lös frukt/grönt), **when** parsern identifierar den, **then** PLU-numret sparas i `PRODUCTS.article_number` utan att blandas med EAN-koder.
5. **Given** EAN-maskningslogiken, **when** enhetstester körs, **then** ≥ 10 referens-PDF:er har förväntade `article_number` (DoD Fas 2 i [project-plan_requirements.md](project-plan_requirements.md) §4.2) och kodtäckning på domänklassen är ≥ 80 % (NFR-M1).
6. **Given** ett okänt EAN-prefix, **when** parsern stöter på det, **then** den fattar ett "safe default"-beslut (ingen maskning) och loggar en `WARN` så att vi kan utöka regelverket.

**DoD:** Unit-tester med referens-PDF:er, dokumenterat i [architecture.md](architecture.md) §4.2.

---

### US-3.4 — HTMX-polling för statusåterkoppling
**Som** Anna **vill jag** se realtidsstatus ("Laddar upp", "Extraherar priser", "Klart") **för att** inte behöva ladda om sidan manuellt.

| Fält | Värde |
| --- | --- |
| Prioritet | S (K12) |
| Spårbarhet | K12, NFR-P3, ADR-005 |
| Persona | Anna |

**Acceptanskriterier:**
1. **Given** en lyckad uppladdning, **when** `core-service` svarar, **then** HTMX-fragmentet aktiverar polling mot `GET /api/receipts/{id}/status` var 2:e sekund.
2. **Given** en pollning, **when** endpoint svarar, **then** latency är < 100 ms p95 (NFR-P3) — mätt via Cloud Run-metric.
3. **Given** att status går från `PENDING` → `COMPLETED`, **when** pollingen tar emot det nya statusvärdet, **then** UI ersätter spinnern med ett resultat-fragment med antal varor och knappen "Se kvittot" (UX §2.2).
4. **Given** att status går till `FAILED`, **when** UI får det svaret, **then** ett felmeddelande visas: "Vi kunde inte läsa kvittot. Är det en PDF från Kivra?" (UX §5.2) med rapport-knapp.
5. **Given** att processen tar > 30 sekunder, **when** den passerar tröskeln, **then** UI visar fortsatt status "Det tar lite längre tid än vanligt. Du kan stänga sidan och kolla senare" (UX §5.2).
6. **Given** att pollingen pågår, **when** statusen blir `COMPLETED` eller `FAILED`, **then** HTMX slutar polla automatiskt via `hx-swap-oob` eller `hx-trigger`-uppdatering — ingen onödig last på servern.

**DoD:** Integrationstest med Playwright eller motsvarande (post-MVP), dokumenterat i UX §3.4.

---

### US-3.5 — Dead Letter Queue och felbevakning
**Som** driftansvarig **vill jag** att meddelanden som upprepat misslyckas hamnar i DLQ och larmar **för att** vi snabbt kan ingripa.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K9) |
| Spårbarhet | K9, NFR-A4 |
| Persona | Driftansvarig |

**Acceptanskriterier:**
1. **Given** ett meddelande som misslyckas 5 gånger, **when** retry-policy uttömts, **then** meddelandet flyttas till topic `receipt-uploads-dlq`.
2. **Given** ett meddelande i DLQ, **when** det landar, **then** en separat hanterare uppdaterar `RECEIPTS.status = FAILED` så att användaren ser felet i UI (UX §5.2).
3. **Given** trafik > 0 i DLQ, **when** Cloud Monitoring upptäcker det, **then** larm triggas inom 5 minuter (NFR-A4) till på-jour-kanalen.
4. **Given** ett DLQ-meddelande, **when** driftansvarig granskar det, **then** payload innehåller `receiptId`, `traceId` och `failure_reason` så att trace kan följas i Cloud Trace (NFR-O1).
5. **Given** att driftansvarig vill replaya, **when** ett skript triggas, **then** meddelandet kan flyttas tillbaka till `receipt-uploads` efter manuell verifiering.
6. **Given** att ett kvitto ligger som `FAILED`, **when** Anna ser det i UI, **then** hon kan klicka "Ladda upp igen" för att försöka på nytt.

**DoD:** DLQ konfigurerad i Terraform, larm dokumenterat i [architecture.md](architecture.md) §10.2.

## 7. Epic 4 — Personlig prishistorik och sökning <a name="epic-4"></a>

**Mål:** Användaren kan se sina egna kvitton, söka efter produkter och förstå sin egen prisutveckling. Motsvarar **Fas 2 (datamodell)** + **Fas 4–5 (UI)**.

**Krav:** K4, K12. **NFR:** P1, P4, S3. **ADR:** ADR-003, ADR-012, ADR-013.

### US-4.1 — Normaliserad datamodell för kvitton och produkter
**Som** utvecklare **vill jag** att kvitton, kvittorader och produkter lagras normaliserat i Neon PostgreSQL **för att** prishistorik per produkt kan beräknas effektivt.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K4) |
| Spårbarhet | K4, NFR-S3, ADR-003 |
| Persona | Utvecklare |

**Acceptanskriterier:**
1. **Given** Flyway-migrering V1, **when** den körs, **then** tabellerna `USERS`, `RECEIPTS`, `PRODUCTS`, `RECEIPT_ITEMS`, `GLOBAL_PRICE_POINTS` skapas enligt schema i [architecture.md](architecture.md) §5.
2. **Given** schemat, **when** `PRODUCTS.article_number` är `UK`, **then** en `INSERT` med befintligt artikelnummer återanvänder produkt-ID (upsert-mönster).
3. **Given** `RECEIPT_ITEMS`-tabellen, **when** kolumner skapas, **then** `vat_rate` finns med så att Moms-kollen (K15) kan implementeras senare.
4. **Given** `USERS`-tabellen, **when** användaren raderas, **then** `ON DELETE CASCADE` säkerställer att alla `RECEIPTS` och `RECEIPT_ITEMS` raderas (GDPR Art. 17, NFR-D2).
5. **Given** databaspoolen, **when** Hikari konfigureras, **then** max `maximumPoolSize = 10` per instans (NFR-S3).
6. **Given** en testkörning, **when** Testcontainers startar PostgreSQL, **then** alla Flyway-migreringar körs grönt och ingen rad i `GLOBAL_PRICE_POINTS` har FK till `USERS` (anonymisering, K8).

**DoD:** Flyway-migrering reviewad, ER-diagram uppdaterat i [architecture.md](architecture.md) §5.

---

### US-4.2 — Produktsökning med autocomplete
**Som** Sofia **vill jag** kunna söka efter en produkt (t.ex. "kaffe") och få förslag direkt **för att** snabbt hitta prishistoriken.

| Fält | Värde |
| --- | --- |
| Prioritet | S (K12) |
| Spårbarhet | K12, NFR-P4, ADR-012 |
| Persona | Sofia, Anna |

**Acceptanskriterier:**
1. **Given** sökfältet, **when** Sofia skriver ≥ 2 tecken, **then** HTMX skickar `GET /api/search?q=...` efter 500 ms debounce (UX §3.4).
2. **Given** sökanropet, **when** SQL körs mot `PRODUCTS.name`, **then** prefix-matchning via `ILIKE` används mot index `idx_products_name_lower` och `LIMIT 10` tillämpas.
3. **Given** sökresultatet, **when** svar returneras, **then** latency är < 200 ms p95 (NFR-P4), mätt via egen metric.
4. **Given** flera matchande produkter, **when** resultatet returneras, **then** sortering sker på popularitet (antal `RECEIPT_ITEMS`-rader) fallande.
5. **Given** ett autocomplete-svar, **when** UI renderar det, **then** listan har `role="listbox"` och pilarna fungerar med tangentbord (NFR-AC3, UX §6.3).
6. **Given** att inga produkter matchar, **when** resultatet är tomt, **then** ett tomt state visas: "Inga produkter hittades — sök bland dina varor eller den globala statistiken" (UX §5.1).

**DoD:** Integrationstest med 1 000 produkter, dokumenterat i [architecture.md](architecture.md) §12.1.

---

### US-4.3 — Produktsida med personlig prishistorik
**Som** Anna **vill jag** se hur ett pris för en specifik produkt har utvecklats för **mig** över tid **för att** förstå om en vara blivit dyrare.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K4) |
| Spårbarhet | K4 |
| Persona | Anna, Sofia |

**Acceptanskriterier:**
1. **Given** Anna klickar på en produkt från sökresultatet, **when** sidan laddas, **then** `GET /products/{id}` visar produktnamn, kategori och en linjegraf med Annas egna priser.
2. **Given** linjegrafen, **when** den renderas, **then** Y-axeln är pris per enhet och X-axeln är inköpsdatum, baserat på `RECEIPT_ITEMS` för Annas `user_id` (Row-Level Security via repository-lager).
3. **Given** att Anna har bara ett köp av produkten, **when** sidan visas, **then** empty state visas: "Bara ett köp än så länge. Ladda upp fler kvitton för att se trender" (UX §5.1).
4. **Given** att en annan användare försöker hämta `GET /products/{id}` med specifik `receiptItemId` som inte tillhör hen, **when** request behandlas, **then** ingen data läcker (filter på `user_id` i SQL).
5. **Given** att produkten har global statistik tillgänglig (`GLOBAL_PRICE_POINTS`), **when** Anna har samtyckt, **then** en andra linje visar "Globalt snittpris" (jfr [project-plan_requirements.md](project-plan_requirements.md) §3.5).
6. **Given** att inget VAT-data finns, **when** sidan renderas, **then** Moms-kollen-modulen visas inte (avhängigt US-6.1).

**DoD:** Integrationstest med två användare och verifierad RLS, dokumenterat i [ux-ui_vision.md](ux-ui_vision.md) §2.3.

---

### US-4.4 — Dashboard med månadsutgifter
**Som** Anna **vill jag** se hennes totalbelopp för månaden på dashboarden **för att** snabbt få överblick.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K4) |
| Spårbarhet | K4, NFR-P1, ADR-013 |
| Persona | Anna, Sofia |

**Acceptanskriterier:**
1. **Given** att Anna loggar in, **when** `/dashboard` laddas, **then** widget "Månadens utgifter" visar summan av `RECEIPTS.total_amount` för innevarande kalendermånad och jämför med samma datum föregående månad.
2. **Given** att inga kvitton finns, **when** dashboarden renderas, **then** empty state visas: "Välkommen! Ladda upp ditt första kvitto för att se trender" (UX §5.1).
3. **Given** att Anna har ≥ 3 kvitton, **when** dashboarden renderas, **then** även widgeten "Senaste kvittona" visar de 3 senaste kvittona med butik, datum, summa.
4. **Given** dashboardanropet, **when** sidan renderas, **then** TTFB < 500 ms p95 (NFR-P1), mätt i Cloud Run.
5. **Given** att kategori-data finns, **when** donut-grafen renderas, **then** den visar nedbrytning per produktkategori — källa för kategori beslutas i ADR-013.
6. **Given** att en användare har inaktiverat samtycke, **when** dashboarden visas, **then** inga delar av UI visar global statistik (jfr [gdpr.md](gdpr.md) §3.1).

**DoD:** UI-test för empty state och full state, dokumenterat i [ux-ui_vision.md](ux-ui_vision.md) §2.1.

## 8. Epic 5 — Crowdsourcing och global statistik <a name="epic-5"></a>

**Mål:** Bygga den anonymiserade pris-poolen och låta användaren se global prisutveckling — utan att läcka individidentitet. Motsvarar **Fas 3** + post-MVP (K14).

**Krav:** K8, K13, K14. **NFR:** D3. **ADR:** ADR-007.

### US-5.1 — Anonymiserad lagring av global prisdata
**Som** DPO **vill jag** att den globala pris-poolen är oåterkalleligt anonym **för att** GDPR inte ska gälla för dessa rader.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K8, K13) |
| Spårbarhet | K8, K13, NFR-D3, ADR-007 |
| Persona | DPO/säkerhetsgranskare |

**Acceptanskriterier:**
1. **Given** ett parsat kvitto från en användare som **samtyckt**, **when** `parser-service` skriver till `GLOBAL_PRICE_POINTS`, **then** posten innehåller endast `product_id`, `price`, `city`, `year_month` — **ingen** FK till `USERS` eller `RECEIPTS`.
2. **Given** ett kvitto, **when** ort härleds, **then** endast ort (t.ex. "Malmö") sparas — aldrig specifik butik eller postnummer.
3. **Given** datum, **when** posten skapas, **then** `year_month` sparas som `YYYY-MM` — aldrig exakt datum eller tidsstämpel.
4. **Given** att en användare **inte** samtyckt (`share_anonymous_data = false`), **when** kvittot parsas, **then** ingen rad skrivs till `GLOBAL_PRICE_POINTS` för det kvittot.
5. **Given** en användare som raderar sitt konto, **when** `ON DELETE CASCADE` körs, **then** `GLOBAL_PRICE_POINTS` påverkas inte (det är ju anonymt) — verifieras med integrationstest.
6. **Given** att en användare har < 3 köp i en specifik `(city, year_month, product_id)`-aggregat, **when** aggregat visas publikt, **then** datapunkten filtreras bort i frontend för att förhindra re-identifiering (k-anonymity ≥ 3, jfr [dpia.md](dpia.md)).

**DoD:** Integrationstest verifierar att `GLOBAL_PRICE_POINTS` saknar PII-FKs, kod-review godkänd av DPO.

---

### US-5.2 — Samtycke för crowdsourcing
**Som** Markus **vill jag** aktivt kunna ge samtycke till att dela mina priser anonymt **för att** bidra till global statistik.

| Fält | Värde |
| --- | --- |
| Prioritet | S (K13) |
| Spårbarhet | K13, ADR-007 |
| Persona | Markus |

**Acceptanskriterier:**
1. **Given** profilsidan, **when** Markus togglar "Dela mina priser anonymt", **then** en modal visar exakt vad som delas (artikel, pris, ort, månad) och vad som **inte** delas, enligt [gdpr.md](gdpr.md) §2.2.
2. **Given** att Markus bekräftar i modalen, **when** request skickas, **then** `USERS.share_anonymous_data = true` och `USERS.consent_updated_at` får aktuell tidsstämpel.
3. **Given** samtyckeshändelsen, **when** den loggas, **then** posten skrivs till audit-loggen (NFR-D6) med användarid, IP-hash och tidsstämpel.
4. **Given** att Markus återkallar samtycket, **when** han togglar av, **then** flaggan sätts till `false` direkt; tidigare bidragna prispunkter ligger kvar eftersom de är anonymiserade.
5. **Given** att Markus aldrig samtyckt, **when** han ser dashboarden, **then** inga widgets visar global statistik utan istället en infobox: "Aktivera samtycke för att se global prisdata" (UX §5.3).
6. **Given** registreringsformuläret, **when** Markus skapar konto, **then** samtyckes-toggeln är **aldrig** förkryssad ([gdpr.md](gdpr.md) §8.1).

**DoD:** Integrationstest, UX-granskning av modal-text, audit-logg verifierad.

---

### US-5.3 — Öppen statistikvy för global prisutveckling (K14)
**Som** Markus **vill jag** kunna se global prisutveckling per produkt och ort **för att** jämföra med min egen historik och bidra till transparens.

| Fält | Värde |
| --- | --- |
| Prioritet | C (K14) |
| Spårbarhet | K14 |
| Persona | Markus |

**Acceptanskriterier:**
1. **Given** Markus besöker `/statistics/products/{id}`, **when** sidan laddas, **then** en linjegraf visar `GLOBAL_PRICE_POINTS` aggregerat per `year_month` och `city`.
2. **Given** att Markus filtrerar på ort, **when** filter aktiveras, **then** grafen uppdateras via HTMX utan sidladdning.
3. **Given** en produkt med < 3 datapunkter i en cell, **when** grafen renderas, **then** den cellen visas som lucka, inte missvisande siffra (k-anonymity).
4. **Given** att Markus är utloggad, **when** han besöker statistikvyn, **then** sidan visas eftersom den är "öppen" — ingen autentisering krävs.
5. **Given** att Markus har samtyckt och har egen data, **when** sidan renderas, **then** en andra linje "Mitt pris" visas på samma graf för jämförelse.
6. **Given** datavolym (50 000 prispunkter), **when** sidan laddas, **then** TTFB < 1 sekund p95 — aggregering körs i SQL, inte i Java (jfr NFR-P1).

**DoD:** Endpoint dokumenterad i OpenAPI (NFR-M4), tester med syntetisk data.

## 9. Epic 6 — Tematiska insikter (Moms-kollen och krympflation) <a name="epic-6"></a>

**Mål:** Mervärdesvyer som driver engagemang. Klassificerade som "Could have" i [project-plan_requirements.md](project-plan_requirements.md) §2.3, post-MVP.

**Krav:** K15, K16.

### US-6.1 — Moms-kollen
**Som** Sofia **vill jag** se om min butik faktiskt sänkte priserna efter momssänkningen **för att** veta om de behållit marginalen.

| Fält | Värde |
| --- | --- |
| Prioritet | C (K15) |
| Spårbarhet | K15 |
| Persona | Sofia |

**Acceptanskriterier:**
1. **Given** Sofia har kvitton både före och efter ett konfigurerbart "moms-datum", **when** hon besöker `/insights/vat`, **then** vyn visar snittpris per produkt före och efter datumet baserat på `RECEIPT_ITEMS.vat_rate`.
2. **Given** att en produkts pris sänkts ≥ momssänkningen, **when** raden renderas, **then** en grön tumme-upp-ikon visas: "Butiken sänkte priset enligt momsen" (UX §2.4).
3. **Given** att en produkts pris är oförändrat trots momssänkning, **when** raden renderas, **then** en röd varningstriangel visas: "Butiken behöll marginalen" (UX §2.4).
4. **Given** att Sofia saknar kvitton från före datumet, **when** vyn laddas, **then** empty state visas: "Du behöver kvitton från före och efter momssänkningen för att vi ska kunna jämföra" (UX §5.1) med CTA "Ladda upp äldre kvitto".
5. **Given** att vyn beräknas, **when** SQL körs, **then** aggregering sker i en enda query med `CASE WHEN purchase_date < :momsDate` — inga N+1-anrop.
6. **Given** att Sofia vill se underlag, **when** hon klickar på en produktrad, **then** hon dirigeras till produktsidan (US-4.3) med datumfiltret förvalt.

**DoD:** Konfigurerbar `vat_change_date` via `application.yml`, integrationstest med syntetisk data.

---

### US-6.2 — Krympflations-varning
**Som** Sofia **vill jag** varnas om förpackningsstorleken minskat samtidigt som priset hållits **för att** upptäcka dolda prishöjningar.

| Fält | Värde |
| --- | --- |
| Prioritet | C (K16) |
| Spårbarhet | K16 |
| Persona | Sofia, Anna |

**Acceptanskriterier:**
1. **Given** två `RECEIPT_ITEMS` för samma `product_id` där `quantity` har minskat men `price_per_unit` är oförändrat eller högre, **when** Sofia besöker produktsidan, **then** en gul/röd `badge-warning` visar: "Förpackningen minskade från X till Y men kilopriset är högre" (UX §2.3).
2. **Given** att produktens nuvarande pris jämförs, **when** kilopris beräknas, **then** beräkningen visas tydligt i UI: gammalt pris/kilo vs nytt pris/kilo.
3. **Given** att en produkt inte har två datapunkter med olika storlekar, **when** sidan renderas, **then** varningen visas **inte** (false-positive-skydd).
4. **Given** krympflations-logiken, **when** den implementeras, **then** den är en separat domänklass `ShrinkflationDetector` med ≥ 80 % testtäckning (NFR-M1).
5. **Given** att varningen visas, **when** Sofia klickar på den, **then** en förklaring expanderar med definitionen av krympflation och varför det är relevant.
6. **Given** att skärmläsare används, **when** varningen renderas, **then** den har `role="alert"` och `aria-live="polite"` (UX §6.2).

**DoD:** Unit-tester för detektor-klassen, manuell test av UI på mobil ≤ 320 px (NFR-BR6).

## 10. Epic 7 — GDPR och användarrättigheter <a name="epic-7"></a>

**Mål:** Implementera Artiklarna 13–22 i koden så att DPIA godkänns innan publik lansering. Motsvarar **Fas 4–5** + checklistan i [gdpr.md](gdpr.md) §8.

**Krav:** K5, K8. **NFR:** D2, D3, D6. **ADR:** ADR-007.

### US-7.1 — Audit-logg för säkerhetshändelser
**Som** säkerhetsgranskare **vill jag** att inloggningar, samtyckesändringar, dataexport och radering loggas separat **för att** kunna granska efter en eventuell incident.

| Fält | Värde |
| --- | --- |
| Prioritet | M |
| Spårbarhet | K5, K8, NFR-D6 |
| Persona | DPO/säkerhetsgranskare |

**Acceptanskriterier:**
1. **Given** en lyckad inloggning, **when** händelsen sker, **then** en post skrivs i `AUDIT_LOG` med `user_id`, `event_type=LOGIN`, `ip_hash`, `timestamp`, `trace_id`.
2. **Given** en samtyckesändring, **when** användaren togglar, **then** posten skrivs med `event_type=CONSENT_CHANGED` och både gammalt och nytt värde.
3. **Given** en dataexport (US-7.2), **when** den körs, **then** `event_type=DATA_EXPORTED` med format och storlek loggas.
4. **Given** en kontoradering (US-7.4), **when** den körs, **then** `event_type=ACCOUNT_DELETED` loggas innan raden raderas från `USERS`.
5. **Given** audit-loggar, **when** retention-jobbet kör, **then** poster ≥ 1 år gamla raderas automatiskt (NFR-D6).
6. **Given** att en post i `AUDIT_LOG` skrivs, **when** den persisteras, **then** den lagras i en separat bucket eller tabell med skrivskydd för applikationen ("write-once") — manipulation måste vara spårbar.

**DoD:** Audit-logg är dokumenterad i [gdpr.md](gdpr.md) §3.1 och [dpia.md](dpia.md) §10.

---

### US-7.2 — Dataexport (Artikel 15 + 20)
**Som** Anna **vill jag** kunna ladda ned alla mina data i JSON eller CSV **för att** uppfylla min rätt till tillgång och dataportabilitet.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K8) |
| Spårbarhet | K8 ([gdpr.md](gdpr.md) §3, GDPR Art. 15, 20) |
| Persona | Anna, Markus |

**Acceptanskriterier:**
1. **Given** profilsidan, **when** Anna klickar "Exportera min data", **then** en modal låter henne välja format (JSON eller CSV).
2. **Given** Anna väljer JSON, **when** `GET /api/profile/export?format=json` körs, **then** svaret innehåller konto-data, samtyckes-history, alla `RECEIPTS` och `RECEIPT_ITEMS` som tillhör hennes `user_id`.
3. **Given** Anna väljer CSV, **when** samma endpoint anropas med `format=csv`, **then** en ZIP med separata CSV-filer per tabell returneras.
4. **Given** att exporten skapas, **when** filen levereras, **then** ingen data om andra användare läcker — verifieras med integrationstest med två användare.
5. **Given** att exporten är klar, **when** Anna får filen, **then** händelsen loggas i audit-loggen (US-7.1).
6. **Given** att exportfilen genereras, **when** den serveras, **then** `Content-Disposition: attachment` och `Cache-Control: no-store` är satta så att filen inte cachas av webbläsare eller proxies.

**DoD:** Integrationstest med två användare, dokumenterat i [gdpr.md](gdpr.md) §3.

---

### US-7.3 — Radering av konto (Artikel 17)
**Som** Anna **vill jag** kunna radera mitt konto fullständigt **för att** utöva min rätt att bli glömd.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K8) |
| Spårbarhet | K8, NFR-D2, NFR-D3, ADR-007 ([gdpr.md](gdpr.md) §3) |
| Persona | Anna |

**Acceptanskriterier:**
1. **Given** profilsidan, **when** Anna klickar "Radera mitt konto", **then** en modal kräver att hon skriver "RADERA" i ett textfält för att aktivera bekräftelseknappen.
2. **Given** dubbelbekräftelse, **when** Anna bekräftar slutligen, **then** `DELETE FROM USERS WHERE id = :userId` triggar `ON DELETE CASCADE` så att `RECEIPTS` och `RECEIPT_ITEMS` också raderas (NFR-D2).
3. **Given** att raderingen körs, **when** den slutförs, **then** ett asynkront jobb raderar alla PDF:er i GCS för användarens path (`gs://<bucket>/<userId>/*`) inom 24 h.
4. **Given** att kontot är raderat, **when** Anna försöker logga in, **then** loginflödet svarar med generiskt meddelande "Fel e-post eller lösenord" (ingen kontoexistens-läcka).
5. **Given** att `GLOBAL_PRICE_POINTS` är anonyma, **when** raderingen körs, **then** dessa rader **påverkas inte** (NFR-D3) — verifieras med integrationstest.
6. **Given** raderingen, **when** den är klar, **then** ett bekräftelsemejl skickas (post-MVP) eller motsvarande UI-bekräftelse visas, och audit-logg-posten finns (US-7.1).

**DoD:** Integrationstest med två användare, GDPR-checklista §8.3 punkt 10 är klar.

---

### US-7.4 — Återkallande av samtycke
**Som** Markus **vill jag** kunna återkalla mitt crowdsourcing-samtycke när som helst **för att** ha kontroll över min data framöver.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K8) |
| Spårbarhet | K8 (GDPR Art. 7.3) |
| Persona | Markus |

**Acceptanskriterier:**
1. **Given** att Markus tidigare samtyckt, **when** han togglar av i profilen, **then** `USERS.share_anonymous_data = false` direkt.
2. **Given** återkallandet, **when** händelsen loggas, **then** audit-loggen (US-7.1) får `event_type=CONSENT_CHANGED` med gammalt värde `true`, nytt värde `false`.
3. **Given** återkallandet, **when** framtida kvitton parsas, **then** ingen rad skrivs till `GLOBAL_PRICE_POINTS`.
4. **Given** redan delade prispunkter, **when** Markus återkallar, **then** dessa förblir i `GLOBAL_PRICE_POINTS` (de är anonyma, GDPR gäller inte) — modalen förklarar detta tydligt.
5. **Given** att Markus ångrar sig, **when** han togglar på igen, **then** flödet i US-5.2 körs på nytt och en ny audit-logg skapas.
6. **Given** rättslig grund "samtycke" enligt [gdpr.md](gdpr.md) §2.2, **when** Markus återkallar, **then** ingen försämring av övriga tjänster sker (han kan fortfarande använda hela appen).

**DoD:** Integrationstest, modaltext granskad av DPO.

## 11. Epic 8 — Designsystem och accessibility <a name="epic-8"></a>

**Mål:** Etablera en återanvändbar komponentkatalog och säkerställa WCAG 2.1 AA. Motsvarar **Fas 4** + AC-tester i Fas 5.

**Krav:** K11, K12. **NFR:** AC1–AC6, M5. **ADR:** ADR-014.

### US-8.1 — Komponentkatalog på `/dev/components`
**Som** utvecklare **vill jag** ha en intern sida som visar alla återanvändbara Thymeleaf-fragment **för att** snabbt kunna jämföra och testa UI-komponenter.

| Fält | Värde |
| --- | --- |
| Prioritet | S (K11) |
| Spårbarhet | K11, NFR-M5 |
| Persona | Utvecklare |

**Acceptanskriterier:**
1. **Given** `core-service` i dev-profil, **when** utvecklaren går till `/dev/components`, **then** sidan renderar alla fragment ur `fragments/components.html` enligt katalog i [ux-ui_vision.md](ux-ui_vision.md) §3.3.
2. **Given** routen, **when** prod-profilen är aktiv, **then** routen returnerar `404 Not Found` (säkerhet — sidan ska inte vara tillgänglig publikt).
3. **Given** att ett nytt fragment läggs till, **when** utvecklaren följer guiden i UX §9.2, **then** fragmentet syns automatiskt på `/dev/components` utan extra konfiguration.
4. **Given** att HTMX-komponenter visas, **when** utvecklaren klickar på dem, **then** de svarar utan sidladdning — interaktion testas isolerat (UX §9.2).
5. **Given** varje komponent på sidan, **when** den renderas, **then** en kort förklarande text visar avsedd användning + länk till relevant UX-sektion.
6. **Given** att sidan blir lång, **when** den scrollas, **then** en sidnav med ankarlänkar till varje kategori finns.

**DoD:** Routen aktiverad endast i dev-profil, dokumenterat i [ux-ui_vision.md](ux-ui_vision.md) §9.2.

---

### US-8.2 — WCAG 2.1 AA-konformans
**Som** användare med funktionsnedsättning **vill jag** kunna använda hela appen med tangentbord och skärmläsare **för att** ha samma åtkomst som andra användare.

| Fält | Värde |
| --- | --- |
| Prioritet | M |
| Spårbarhet | K11, NFR-AC1, NFR-AC2, NFR-AC3, NFR-AC4, NFR-AC5, NFR-AC6, ADR-014 |
| Persona | Användare med funktionsnedsättning |

**Acceptanskriterier:**
1. **Given** varje sida i appen, **when** axe-core eller pa11y körs i CI (NFR-AC4), **then** ingen `error`-nivå-violation rapporteras.
2. **Given** all text, **when** kontrasten mäts, **then** ratio ≥ 4,5:1 för normaltext och ≥ 3:1 för stor text (NFR-AC2).
3. **Given** huvudflödet (login, ladda upp, se kvitto), **when** användaren använder enbart tangentbord, **then** alla interaktiva element är nåbara via `Tab` med synlig fokus-ring (NFR-AC3, UX §6.1).
4. **Given** huvudflödet, **when** det testas med NVDA/VoiceOver (NFR-AC5), **then** alla actions kan utföras utan att skärmläsare-användaren blir blockerad — minst en manuell genomgång per release.
5. **Given** användarens system har `prefers-reduced-motion`, **when** UI renderar animationer, **then** konfetti och slide-animationer stängs av (NFR-AC6, UX §6.4).
6. **Given** modaler, **when** de öppnas, **then** de har `role="dialog"`, `aria-modal="true"`, fokus fångas inuti modalen, och Esc stänger dem (UX §6.2).

**DoD:** CI-job grönt, manuell skärmläsar-genomgång dokumenterad, extern WCAG-audit innan publik lansering (release-kriterium).

## 12. Epic 9 — Observability och drift <a name="epic-9"></a>

**Mål:** Säkerställa att vi vet när systemet brakar — och varför. Motsvarar **Fas 3** + lanseringskriterier i Fas 5.

**Krav:** K10. **NFR:** O1, O2, O3, O4, A1, A2, A4.

### US-9.1 — Distribuerad spårning ände-till-ände
**Som** driftansvarig **vill jag** att varje request följs som en sammanhängande trace genom både `core-service` och `parser-service` **för att** snabbt kunna felsöka fel i det asynkrona flödet.

| Fält | Värde |
| --- | --- |
| Prioritet | M (K10) |
| Spårbarhet | K10, NFR-O1, NFR-O2 |
| Persona | Driftansvarig |

**Acceptanskriterier:**
1. **Given** en PDF-uppladdning, **when** `core-service` tar emot request, **then** ett OTel-span skapas med `trace_id` som propageras till Pub/Sub-attribut.
2. **Given** att `parser-service` konsumerar meddelandet, **when** behandling startar, **then** ett barn-span länkas till samma `trace_id` så att hela flödet syns som en trace i GCP Trace.
3. **Given** strukturerade JSON-loggar (NFR-O2), **when** logg-rader skrivs, **then** varje rad innehåller `trace_id` och `span_id` för korrelation.
4. **Given** att en användare rapporterar fel med en `traceId`, **when** driftansvarig söker, **then** alla loggar och spans för det `trace_id` kan listas i Cloud Trace inom < 1 minut.
5. **Given** att loggar skrivs, **when** PII upptäcks (e-post, lösenord), **then** Logback-mask ersätter värdet med `[redacted]` (NFR-O5).
6. **Given** sampling, **when** trafik ökar, **then** OTel-sampler konfigureras till adaptiv (≥ 100 % i dev, ≤ 10 % i prod).

**DoD:** End-to-end-trace verifierat manuellt, dokumenterat i [architecture.md](architecture.md) §7.2.

---

### US-9.2 — Metrics och dashboards för KPI:er
**Som** driftansvarig **vill jag** ha dashboards för bearbetningstid, felgrad och latency **för att** följa upp SLO:er.

| Fält | Värde |
| --- | --- |
| Prioritet | M |
| Spårbarhet | NFR-O3, NFR-O4, NFR-O6 |
| Persona | Driftansvarig |

**Acceptanskriterier:**
1. **Given** att Micrometer är konfigurerat, **when** appen körs, **then** metrics `http_requests_total`, `receipt_processing_seconds`, `parser_success_ratio` exporteras till GCP (NFR-O3).
2. **Given** Cloud Monitoring, **when** dashboarden öppnas, **then** widgets visar p50/p95/p99 för latency per endpoint, felgrad (5xx) och DLQ-djup.
3. **Given** SLO för TTFB < 500 ms p95 (NFR-P1), **when** SLO bryts under 5-min-fönster, **then** en larmpolicy triggar (NFR-O4) till på-jour-kanalen.
4. **Given** SLO för felgrad < 1 % (NFR-A2), **when** ratio överskrids i 10 min, **then** larm går till samma kanal med direktlänk till loggar.
5. **Given** dashboards, **when** de skapas, **then** de är versionshanterade i Terraform — inte handbyggda i Cloud Monitoring UI.
6. **Given** att en utvecklare lägger till en ny metric, **when** PR mergas, **then** dokumentation uppdateras i `/observability/README.md` (eller motsvarande, NFR-M4).

**DoD:** Terraform-modul `monitoring/`, manuellt larmtest dokumenterat.

---

### US-9.3 — DLQ-larm och driftrunbook
**Som** driftansvarig **vill jag** få larm när meddelanden hamnar i DLQ **för att** snabbt kunna utreda och eventuellt replaya.

| Fält | Värde |
| --- | --- |
| Prioritet | M |
| Spårbarhet | NFR-A4 |
| Persona | Driftansvarig |

**Acceptanskriterier:**
1. **Given** Pub/Sub-topic `receipt-uploads-dlq`, **when** ett meddelande landar, **then** Cloud Monitoring-metric `num_undelivered_messages` ökar och larm triggas inom 5 min (NFR-A4).
2. **Given** larmet, **when** det skickas, **then** det innehåller länk till DLQ:n i GCP-konsolen och till runbook-sidan.
3. **Given** runbook, **when** driftansvarig öppnar den, **then** den beskriver i steg-form hur DLQ-meddelanden inspekteras, hur trace följs och hur de replay:as.
4. **Given** att ett DLQ-meddelande replayas, **when** det skickas tillbaka, **then** Cloud Monitoring-metric `dlq_replay_count` ökar och kvittostatusen uppdateras till `PENDING` igen.
5. **Given** att DLQ:n är tom efter en incident, **when** Cloud Monitoring upptäcker det, **then** ett "recovery"-event loggas för att stänga incidenten automatiskt.
6. **Given** kvartalsvis återhämtningstest (NFR-B4), **when** testet körs, **then** ett kontrollerat DLQ-fall triggas och hela run-boken körs igenom.

**DoD:** Runbook i `/docs/runbooks/dlq.md` eller motsvarande, kvartalsvis övning schemalagd.

---

> **Nästa steg:** Varje epic blir en parent-issue i GitHub. Varje user story blir en sub-issue länkad till sin epic. Issues taggas med `epic` respektive `user-story` + områdesetikett (`infra`, `auth`, `parsing`, `frontend`, `gdpr`, `observability`, etc.). När en story påbörjas i implementationsfasen skapas en PR som länkar till sub-issuet via `Closes #<n>`.
