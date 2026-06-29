# Förstudie: Matdata 2.0

**Smarta inköp, prishistorik och global statistik via digitala kvitton**

| Metadata | |
| --- | --- |
| Version | 1.0 |
| Senast uppdaterad | 2026-06-29 |
| Status | Förstudie klar för granskning |
| Plats i dokumentationen | Övergripande visionsdokument. Början för nya läsare. |

> Detta är det övergripande förstudiedokumentet. För övriga dokument, se [README.md](README.md).

## Innehåll
- [1. Inledning](#inledning)
- [2. Målgrupp och personas](#malgrupp)
- [3. Koncept och kärnfunktionalitet (MVP)](#koncept)
- [4. Teknisk lösning och arkitektur](#teknisk)
- [5. Konkurrensanalys](#konkurrens)
- [6. Risker och utmaningar](#risker)
- [7. Framgångskriterier och nyckeltal](#framgang)
- [8. Avgränsningar och beroenden](#avgransningar)
- [9. Nästa steg](#nasta)

## 1. Inledning <a name="inledning"></a>

### 1.1 Bakgrund
I takt med ökade levnadsomkostnader och fluktuerande matpriser har konsumenters behov av att ha kontroll över sina dagligvaruinköp ökat kraftigt. Matdata 2.0 föds ur viljan att ta kontroll över dessa kostnader genom att samla in och analysera kvittoinformation.

### 1.2 Syfte
Projektet har ett dubbelt syfte:
1. **Produktmässigt:** Att bygga en plattform där användare kan ladda upp digitala kvitton för att automatiskt extrahera prisdata, spåra utgifter över tid och (med aktivt samtycke) bidra till en global, helt anonymiserad prisstatistik för att motverka "krympflation" och dolda prishöjningar.
2. **Kompetensutveckling:** Att fungera som ett verkligt projekt för att djupdyka i och tillämpa modernaste möjliga teknologier: Java 26, Spring Boot 4, händelsestyrd arkitektur (GCP Pub/Sub), OpenTelemetry och Terraform.

### 1.3 Mål
Att definiera kärnfunktionalitet, en tydlig och kostnadseffektiv teknisk arkitektur med "Privacy by Design" i grunden, samt en plan för en MVP (Minimum Viable Product). Den fullständiga arkitekturen beskrivs i [architecture.md](architecture.md) och kraven i [project-plan_requirements.md](project-plan_requirements.md).

## 2. Målgrupp och personas <a name="malgrupp"></a>

* **Prismedvetna konsumenter och dataentusiaster:** Individer som gillar att budgetera och visualisera sin ekonomi ner på radnivå.
* **Samhällsmedvetna konsumenter:** Personer som vill bidra till "Moms-kollen" och öppen prisstatistik.
* **Utvecklaren (primär användare initialt):** Byggd för att lösa ett eget problem och samtidigt fungera som en robust, banbrytande referensarkitektur för framtida projekt.

Detaljerade personas (Anna, Markus, Sofia) finns i [ux-ui_vision.md](ux-ui_vision.md) avsnitt 1.5.

## 3. Koncept och kärnfunktionalitet (MVP) <a name="koncept"></a>

För att snabbt och effektivt kunna testa hypotesen avgränsas MVP:n enligt MoSCoW-metoden i [project-plan_requirements.md](project-plan_requirements.md):

1. **Inmatning (PDF-fokus):** I fas 1 hanteras endast digitala PDF-kvitton från ICA via Kivra. Detta ger exakt data och eliminerar felkällor från traditionell OCR.
2. **Asynkron dataextraktion:** Användaren får direkt feedback i gränssnittet (via HTMX-polling) medan en bakgrundsprocess extraherar butik, datum, artikelnummer (inklusive logik för att maskera viktvaror), namn och pris.
3. **Insikter och UI:** Sökfunktion, "Moms-kollen" och varningar för krympflation. En "cookie-fri" upplevelse utan störande banners.
4. **Anonymisering (crowdsourcing):** Systemet sparar en kopia av prisdatan helt frånkopplad från användaren och tidpunkten, redo för framtida globala prisjämförelser.

## 4. Teknisk lösning och arkitektur <a name="teknisk"></a>

Projektet följer en **händelsestyrd, distribuerad arkitektur** anpassad för Google Cloud Platform (GCP). Fullständig arkitekturbeskrivning, diagram och datamodell finns i [architecture.md](architecture.md). Icke-funktionella krav (prestanda, säkerhet, accessibility) finns i [non-functional-requirements.md](non-functional-requirements.md).

### 4.1 Backend (två tjänster)
* **Språk och ramverk:** Java 26 och Spring Boot 4.x.
* **Core Service:** Hanterar inloggning, databasanrop och det HTMX-drivna webbgränssnittet (Thymeleaf, Tailwind CSS).
* **Parser Service:** En separat worker-tjänst för tunga operationer (Apache PDFBox).
* **Meddelandekö:** Google Cloud Pub/Sub sköter den asynkrona kommunikationen mellan Core och Parser.

### 4.2 Databas och infrastruktur (IaC)
* **Databas:** Neon (serverless PostgreSQL) som skalar till noll och möjliggör databas-branchning för varje Pull Request (PR-miljöer).
* **Hostning:** Google Cloud Run (serverless).
* **Filsystem:** Google Cloud Storage (GCS) för temporär PDF-lagring med strikta sekretessregler.
* **Infrastruktur som kod:** Hela miljön sätts upp och hanteras deklarativt via **Terraform**.

### 4.3 Observabilitet och CI/CD
* **OpenTelemetry (OTel):** Distribuerad spårning över båda mikrotjänsterna, loggar och metrics exporteras direkt till GCP (Cloud Trace/Logging) — eliminerar behovet av Google Analytics på klientsidan.
* **CI/CD:** GitHub Actions för automatisk testning, byggnation av Docker-images, provisionering av test-databaser och driftsättning via Workload Identity Federation.

## 5. Konkurrensanalys <a name="konkurrens"></a>

* **Matpriskollen:** Starka på erbjudanden, men sämre på att spåra historiska individuella inköp.
* **Butikernas egna appar (ICA, Coop):** Låsta till sina egna system och visar ogärna prishistorik som pekar på prisökningar.
* **Ekonomiappar (Tink, Zuper):** Fångar totalsumman via banken, men saknar kvittots radnivå-data.
* **Matdata 2.0:s unika fördel:** Radnivå-analys, krympflations-varningar och total transparens med användarens data (enkel export, tydlig radering).

## 6. Risker och utmaningar <a name="risker"></a>

De största riskerna sammanfattas här. Fullständigt riskregister med sannolikhet, konsekvens, mitigering och ägare finns i [risk-register.md](risk-register.md).

* **T1 — Externa format:** ICA/Kivra kan ändra layouten på sina PDF-kvitton, vilket direkt skulle få parsningen att gå sönder. Mitigeras med versionerad parser och canary-tester.
* **T2 — Komplexitet i EAN-hantering:** Streckkoder för viktvaror inkorporerar pris/vikt, vilket kräver noggrann logik i parsningen för att inte bryta prishistoriken. Hanteras via enhetstester i Fas 2.
* **S1 — Sekretess (GDPR):** Hantering av inköpsdata är känsligt. "Rätten att bli glömd" och separation mellan personlig historik och global statistik måste vara stensäker från dag ett (Privacy by Design). Se [gdpr.md](gdpr.md) och [dpia.md](dpia.md).
* **V2 — Begränsad butikstäckning:** Endast ICA-stöd vid lansering. Plugin-arkitektur (krav K20) ska minska beroendet på sikt.
* **O1 — Single developer:** Risk för flaskhalsar och kunskapssilos. Mitigeras genom denna förstudie och ADR-light i [open-decisions.md](open-decisions.md).

## 7. Framgångskriterier och nyckeltal <a name="framgang"></a>

MVP-fasen bedöms som lyckad när följande mätbara mål uppnåtts. Kriterierna ska gå att bekräfta med data, inte med subjektiva omdömen.

### 7.1 Produktmässiga framgångskriterier
* Minst **50 unika användare** har skapat ett konto inom 3 månader efter publik lansering.
* Minst **20 av dessa användare** har laddat upp 5 kvitton eller fler.
* Genomsnittlig parsing-träffsäkerhet på ICA-kvitton är **≥ 95 %** mätt mot manuell verifiering av referenskvitton.
* Tid från PDF-uppladdning till färdig parsing är **< 30 sekunder (p95)**. Se [non-functional-requirements.md](non-functional-requirements.md) NFR-P2.

### 7.2 Tekniska framgångskriterier
* **CI/CD-pipeline fungerar** för båda tjänsterna med PR-miljöer (krav K6).
* **OpenTelemetry-traces täcker** hela uppladdningsflödet ände-till-ände (krav K10, NFR-O1).
* **Driftsavbrott** för `core-service` under MVP-perioden är **mindre än 1 %** mätt över 3 månader (NFR-A1, mer generös tröskel än publik tjänst).
* **Inga GDPR-incidenter** kopplade till Matdata 2.0.

### 7.3 Lärandemål
* Praktisk erfarenhet av Java 26 (Virtual Threads, Pattern Matching) och Spring Boot 4.x.
* Praktisk erfarenhet av distribuerad spårning med OpenTelemetry mot GCP.
* Praktisk erfarenhet av Terraform mot GCP och Neon.
* Praktisk erfarenhet av Neons databas-branchning per PR.
* Dokumenterad referensarkitektur som kan återanvändas i framtida projekt.

## 8. Avgränsningar och beroenden <a name="avgransningar"></a>

* **Geografi:** MVP riktas mot svenska användare och svenska butiker. Internationalisering hanteras enligt [non-functional-requirements.md](non-functional-requirements.md) avsnitt 9.
* **Plattform:** Endast webbapplikation. Native iOS/Android är "Won't have" (krav K19).
* **Inmatning:** Endast digitala PDF-kvitton från ICA via Kivra i MVP. OCR (K17) och övriga kedjor (K20) ligger i Could-have.
* **Beroenden mot tredje part:** Kivra (PDF-leverans), Google (GCP), Neon (databas). Risker dokumenterade i [risk-register.md](risk-register.md) avsnitt "Leverantörs- och beroenderisker".
* **Budget:** MVP ska kunna drivas inom ramen för leverantörernas gratisplaner. Detaljerad uppskattning i [cost-estimate.md](cost-estimate.md).

## 9. Nästa steg <a name="nasta"></a>

Följ den upprättade **Projektplanen och Roadmapen** i [project-plan_requirements.md](project-plan_requirements.md), med start i *Fas 1: Grunden (Infrastruktur & Miljö)* där repo sätts upp och Terraform konfigureras.

Innan Fas 1 startar bör följande granskningar och bekräftelser ske:

1. **Granskning av förstudien** av samtliga intressenter.
2. **Acceptans av riskregister** ([risk-register.md](risk-register.md)) inklusive utpekade ägare.
3. **Bekräftelse av kostnadsestimat** ([cost-estimate.md](cost-estimate.md)) och budget.
4. **Säkerställ att samtliga öppna ADR** ([open-decisions.md](open-decisions.md)) som måste beslutas innan Fas 4 är schemalagda.
5. **Bekräftelse av GDPR-strategi och DPIA** ([gdpr.md](gdpr.md), [dpia.md](dpia.md)).
