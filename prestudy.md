# Förstudie: Matdata 2.0

**Smarta inköp, prishistorik och global statistik via digitala kvitton**

## 1. Inledning

### 1.1 Bakgrund
I takt med ökade levnadsomkostnader och fluktuerande matpriser har konsumenters behov av att ha kontroll över sina dagligvaruinköp ökat kraftigt. Matdata 2.0 föds ur viljan att ta kontroll över dessa kostnader genom att samla in och analysera kvittoinformation.

### 1.2 Syfte
Projektet har ett dubbelt syfte:
1. **Produktmässigt:** Att bygga en plattform där användare kan ladda upp digitala kvitton för att automatiskt extrahera prisdata, spåra utgifter över tid och (med aktivt samtycke) bidra till en global, helt anonymiserad prisstatistik för att motverka "krympflation" och dolda prishöjningar.
2. **Kompetensutveckling:** Att fungera som ett verkligt projekt för att djupdyka i och tillämpa modernaste möjliga teknologier: Java 26, Spring Boot 4, händelsestyrd arkitektur (GCP Pub/Sub), OpenTelemetry och Terraform.

### 1.3 Mål
Att definiera kärnfunktionalitet, en tydlig och kostnadseffektiv teknisk arkitektur med "Privacy by Design" i grunden, samt en plan för en MVP (Minimum Viable Product).

## 2. Målgrupp
* **Prismedvetna konsumenter & Data-entusiaster:** Individer som gillar att budgetera och visualisera sin ekonomi ner på radnivå.
* **Samhällsmedvetna konsumenter:** Personer som vill bidra till "Moms-kollen" och öppen prisstatistik.
* **Utvecklaren (Primär användare initialt):** Byggd för att lösa ett eget problem och samtidigt fungera som en robust, banbrytande referensarkitektur för framtida projekt.

## 3. Koncept och Kärnfunktionalitet (MVP)
För att snabbt och effektivt kunna testa hypotesen avgränsas MVP:n enligt MoSCoW-metoden i projektplanen:
1. **Inmatning (PDF-fokus):** I fas 1 hanteras endast digitala PDF-kvitton från ICA via Kivra. Detta ger exakt data och eliminerar felkällor från traditionell OCR.
2. **Asynkron Dataextraktion:** Användaren får direkt feedback i gränssnittet (via HTMX-polling) medan en bakgrundsprocess extraherar butik, datum, artikelnummer (inklusive logik för att maskera viktvaror), namn och pris.
3. **Insikter & UI:** Sökfunktion, "Moms-kollen" och varningar för Krympflation. En "cookie-fri" upplevelse utan störande banners.
4. **Anonymisering (Crowdsourcing):** Systemet sparar en kopia av prisdatan helt frånkopplad från användaren och tidpunkten, redo för framtida globala prisjämförelser.

## 4. Teknisk Lösning och Arkitektur
Projektet följer en **händelsestyrd, distribuerad arkitektur** anpassad för Google Cloud Platform (GCP).

### 4.1 Backend (Två tjänster)
* **Språk & Ramverk:** Java 26 och Spring Boot 4.x.
* **Core Service:** Hanterar inloggning, databasanrop och det HTMX-drivna webbgränssnittet (Thymeleaf, Tailwind CSS).
* **Parser Service:** En separat worker-tjänst för tunga operationer (Apache PDFBox).
* **Meddelandekö:** Google Cloud Pub/Sub sköter den asynkrona kommunikationen mellan Core och Parser.

### 4.2 Databas och Infrastruktur (IaC)
* **Databas:** Neon (Serverless PostgreSQL) som skalar till noll och möjliggör databas-branchning för varje Pull Request (PR-miljöer).
* **Hostning:** Google Cloud Run (Serverless).
* **Filsystem:** Google Cloud Storage (GCS) för temporär PDF-lagring med strikta sekretessregler.
* **Infrastruktur som Kod:** Hela miljön sätts upp och hanteras deklarativt via **Terraform**.

### 4.3 Observabilitet och CI/CD
* **OpenTelemetry (OTel):** Distribuerad spårning över båda mikrotjänsterna, loggar och metrics exporteras direkt till GCP (Cloud Trace/Logging) – eliminerar behovet av Google Analytics på klientsidan.
* **CI/CD:** GitHub Actions för automatisk testning, byggnation av Docker-images, provisionering av test-databaser och driftsättning via Workload Identity Federation.

## 5. Konkurrensanalys
* **Matpriskollen:** Starka på erbjudanden, men sämre på att spåra historiska individuella inköp.
* **Butikernas egna appar (ICA, Coop):** Låsta till sina egna system och visar ogärna prishistorik som pekar på prisökningar.
* **Ekonomiappar (Tink, Zuper):** Fångar totalsumman via banken, men saknar kvittots radnivå-data.
* **Matdata 2.0:s Unika Fördel:** Radnivå-analys, krympflations-varningar och total transparens med användarens data (enkel export, tydlig radering).

## 6. Risker och Utmaningar
* **Beroende av externa format:** ICA/Kivra kan ändra layouten på sina PDF-kvitton, vilket direkt skulle få parsningen att gå sönder.
* **Komplexitet i EAN-hantering:** Streckkoder för viktvaror inkorporerar pris/vikt, vilket kräver noggrann logik i parsningen för att inte bryta prishistoriken.
* **Sekretess (GDPR):** Hantering av inköpsdata är känsligt. "Rätten att bli glömd" och separation mellan personlig historik och global statistik måste vara stensäker från dag ett (Privacy by Design).

## 7. Nästa Steg
Följ den upprättade **Projektplanen och Roadmapen**, med start i *Fas 1: Grunden (Infrastruktur & Miljö)* där repo sätts upp och Terraform konfigureras.
