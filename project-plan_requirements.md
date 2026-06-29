# Projektplan & Kravmatris: Matdata 2.0

## 1. Introduktion och Syfte
Detta dokument fungerar som styrdokument för utvecklingen av Matdata 2.0. Innan kod skrivs etablerar vi här exakt *vad* som ska byggas (kravmatris) och i *vilken ordning* det ska byggas (roadmap).

Syftet är att bibehålla fokus på Minimum Viable Product (MVP) och säkerställa att kompetensutvecklingsmålen inom Java 26, Spring Boot 4, GCP och Terraform uppnås systematiskt, samtidigt som vi framtidssäkrar plattformen för global prisstatistik.

## 2. Kravmatris (MoSCoW)
Metoden MoSCoW används för att tydliggöra prioriteringar för första versionen (MVP) av systemet.

### 🔴 M - Must Have (Kritiska krav för MVP)
*Systemet saknar värde utan dessa.*
* **K1:** Applikationen måste kunna ta emot en uppladdad PDF-fil (ICA-kvitto via Kivra).
* **K2:** Systemet måste kunna extrahera text från PDF:en via Apache PDFBox.
* **K3:** Systemet måste kunna identifiera rot-artikelnummer (EAN/PLU) och hantera eller maskera viktvaror så att de grupperas korrekt.
* **K4:** Data måste sparas i en normaliserad relationsdatabas (Neon PostgreSQL).
* **K5:** En användare måste kunna logga in säkert och *endast* se sina egna kvitton (Row-Level Security / Spring Security).
* **K6:** CI/CD-pipeline via GitHub Actions måste finnas på plats från dag 1, inklusive PR-miljöer med databasbranchning.
* **K7:** Infrastruktur måste provisioneras via Terraform (IaC).
* **K8 (Privacy by Design):** Datamodellen och arkitekturen måste från start designas för att strikt separera personligt knutna kvitton från global prisdata, så att vi undviker framtida GDPR-hinder.

### 🟡 S - Should Have (Viktiga, men appen överlever initialt utan)
*Starkt rekommenderade för en bra arkitektur och UX.*
* **K9:** Uppdelning i två mikrotjänster (`core-service` och `parser-service`) som kommunicerar asynkront via GCP Pub/Sub.
* **K10:** Observabilitet via OpenTelemetry (traces och loggar exporterade till GCP).
* **K11:** UI-komponentkatalog (Kitchen Sink) uppsatt på en specifik intern route (`/dev/components`) med Thymeleaf-fragment.
* **K12:** HTMX-polling för kvitto-uppladdning så att användaren ser status "Bearbetas..." utan sidladdning.
* **K13 (Crowdsourcing-motor):** Logik i `parser-service` som automatiskt tvättar och sparar inkommande kvittopriser till en anonymiserad global pris-pool oberoende av användaren.

### 🟢 C - Could Have (Bonusfunktioner, bra för backlog)
*Kan läggas till om tid eller budget tillåter.*
* **K14:** En öppen statistikvy där användare kan se global prisutveckling på varor baserat på aggregerad data.
* **K15:** Analysvyn "Moms-kollen" för att jämföra priser före och efter ett specifikt datum.
* **K16:** Detektions- och varningssystem för krympflation om förpackningsstorlek minskar men priset förblir detsamma.
* **K17:** Stöd för papperskvitton via OCR, till exempel Google Cloud Vision API eller Gemini Vision.
* **K20:** Stöd för ytterligare butiksformat (Coop, Hemköp, Willys) via ett plugin-baserat parser-system.

### ⚪ W - Won't Have (Ligger utanför scopet för denna fas)
*Aktivt bortvalda för att hålla projektet hanterbart.*
* **K18:** Integration direkt mot Kivras eller bankernas API:er (Open Banking).
* **K19:** Dedikerade native iOS- och Android-appar (webb eller PWA räcker).

## 3. Utvecklingsfaser (Roadmap)
För att inte bygga för mycket på en gång delas projektet in i logiska faser. Varje fas ska resultera i fungerande, deployad kod.

### Fas 1: Grunden (Infrastruktur & Miljö)
*Mål: Ett tomt "Hello World"-projekt som deployas automatiskt.*
1. Skapa GitHub-repo (`matdata-monorepo`).
2. Sätt upp Terraform-projekt (`/terraform`) och provisionera GCS-bucket, Pub/Sub-topic och Neon-databasprojekt.
3. Generera en tom Spring Boot 4-applikation (Java 26).
4. Sätt upp GitHub Actions som kompilerar koden, bygger Docker-image och driftsätter till Cloud Run. Konfigurera Neon DB-branching för PR:er.

### Fas 2: Teknisk Spike (PDF, Domänlogik & Anonymisering)
*Mål: Bevisa att vi faktiskt kan läsa datan och modellera den säkert.*
1. Implementera databasschemat via Flyway. **Viktigt:** Skapa separata tabeller eller strukturer för användarens egna kvittorader (`receipt_items`) och den globala anonymiserade prisdatan (`global_price_points`).
2. Bygg isolerad Java-logik med Apache PDFBox för att ladda in en ICA-PDF.
3. Skriv enhetstester med regex och domänlogik som bevisar att vi kan skala bort vikten från viktvarors streckkoder.

### Fas 3: Core Backend & Asynkront flöde
*Mål: Få arkitekturen med Pub/Sub att fungera.*
1. Separera projektet i `core-service` och `parser-service`.
2. Integrera OpenTelemetry (OTel) i båda tjänsterna.
3. Skapa API-endpoint i `core-service` för att ladda upp fil -> spara i GCS -> skicka meddelande till Pub/Sub.
4. Låt `parser-service` konsumera Pub/Sub-meddelandet, ladda ner PDF från GCS och parsa datan.
5. Spara både det personliga kvittot som knyts till användaren **och** den anonyma globala pris-poolen.

### Fas 4: Frontend & Design System
*Mål: Ge applikationen ett ansikte med Thymeleaf och Tailwind.*
1. Ta in AI-genererad Tailwind-kod från Stitch och bryt isär den i återanvändbara Thymeleaf-fragment (cards, buttons, tables).
2. Skapa den dolda `/dev/components`-routen.
3. Bygg upp dashboard-vyn.
4. Bygg sökfunktionen och kvitto-uppladdningen med HTMX.
5. Sätt upp Spring Security för inloggning och utloggning.

### Fas 5: Polering & Lansering av MVP
*Mål: Verifiera att allt hänger ihop och är redo för dagligt bruk.*
1. Implementera Row-Level Security-kontroller i databaslagret.
2. Bygg produktdetalj-vyn med prishistorikgrafer, eventuellt med en graf-linje för "Ditt pris" och en linje för "Globalt snittpris".
3. Testning med riktiga kvitton.
4. Säkerställ loggning och larm i GCP.

## 4. Teststrategi

### 4.1 Enhetstester (Unit Tests)
* JUnit 5 och Mockito används som standardramverk.
* Fokus ligger särskilt på Parser Service-domänlogik, till exempel EAN-maskning och logik för viktvaror.
* Målsättningen är att all affärskritisk business logic ska vara täckt av enhetstester.

### 4.2 Integrationstester
* Spring Boot Test och Testcontainers används för integrationstester.
* PostgreSQL körs i container för att verifiera repository-lager, Flyway-migreringar och Pub/Sub-integration.
* Neon DB-branching används för PR-miljöer där mer realistiska verifieringar behövs mot delad molninfrastruktur.

### 4.3 End-to-end-tester
* För MVP prioriteras manuell testning med riktiga ICA- och Kivra-PDF:er i PR-miljön.
* Automatiserade end-to-end-tester kan införas efter MVP, exempelvis med Playwright.

### 4.4 Parser-versionshantering och extensibilitet
* Parsern bör utformas med ett strategi- eller pluginmönster så att nya butiksformat kan läggas till utan att befintliga parsers behöver modifieras.
* Varje parser ska identifieras med butik och formatversion, så att layoutförändringar hos ICA eller framtida aktörer som Coop, Hemköp och Willys kan hanteras kontrollerat.

### 4.5 Övervakning av PDF-layoutförändringar
* En canary-test bör övervägas som körs veckovis mot en lagrad referens-PDF.
* Om parsingresultatet förändras utan avsedd kodändring ska testet larma, så att layoutändringar i käll-PDF:er upptäcks tidigt.
