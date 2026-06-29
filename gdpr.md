# Deep Dive: GDPR & Cookie-hantering i Matdata 2.0

## 1. Varför är Matdata 2.0 extra känsligt?
Att samla in kvittodata innebär insamling av högkänslig beteendedata. Ett kvitto visar inte bara att någon köpt "Mjölk", det visar exakt *vilken* butik (geografisk plats), *när* (tidpunkt för besök), och kan indirekt avslöja känsliga personuppgifter enligt GDPR Artikel 9 (t.ex. hälsotillstånd genom köp av laktosfritt, medicin, eller religion via kosher/halal-produkter).

## 2. GDPR-strategi och Rättslig Grund
För att få behandla data lagligt måste varje process ha en "Rättslig grund" (Legal basis). Vi delar upp plattformen i två delar:

### 2.1 Kärnfunktionen (Privat Prishistorik)
* **Ändamål:** Låta användaren se sin egen historik och ladda upp sina kvitton.
* **Rättslig grund:** *Avtal* (Article 6.1.b). Användaren skapar ett konto för att använda tjänsten. Vi måste lagra datan för att kunna leverera tjänsten.
* **Lagring av PDF:** Original-PDF:en i Google Cloud Storage bör omfattas av "Dataminimering". Behöver användaren verkligen se originalkvittot för evigt?
    * *Lösning:* Ge användaren valet: "Radera PDF automatiskt efter extrahering" eller "Spara PDF som säkerhetskopia".

### 2.2 Crowdsourcing & Global Statistik (Krav K13)
* **Ändamål:** Samla prispunkter från alla användare för att visa globala trender ("Svensk Mjölk 3% snittpris i Sverige").
* **Rättslig grund:** *Samtycke* (Consent - Article 6.1.a). Användaren måste aktivt kryssa i "Jag vill dela mina priser anonymt för att hjälpa andra". Detta får *inte* vara förkryssat.
* **Den tekniska lösningen (Anonymisering):** GDPR gäller *inte* för helt anonymiserad data. Men att ta bort namnet räcker inte. Om databasen sparar "Kvitto från ICA Nära Möllevången, 2026-06-23 09:42" med exakt vilka 34 varor som köptes, kan det gå att identifiera personen om någon råkade se dem i butiken.
    * *Teknisk implementation:* Vår `parser-service` måste "stycka upp" kvittot. När den skriver till den globala statistiken (`global_price_points`) sparar den *endast*: Artikelnummer, Pris, Ort (t.ex. "Malmö", *inte* den specifika butiken) och Vecka/Månad (*inte* exakt tidsstämpel). På så sätt frikopplas varje enskild vara från själva "inköpskorgen", vilket gör datan oåterkalleligt anonym.

## 3. Användarnas Rättigheter (Hur vi bygger det i koden)
GDPR ger användarna starka rättigheter som vi måste stödja rent arkitekturellt:

1. **Rätten att bli glömd (Radering):**
    * När en användare klickar "Radera konto" räcker det inte att sätta `is_active = false`.
    * *Lösning:* Vår databas (Neon/PostgreSQL) ska använda `ON DELETE CASCADE` på främmande nycklar (`user_id`). Tar vi bort användaren ska databasen automatiskt radera alla dennes kvitton och kvittorader. Applikationen måste också anropa GCP för att radera eventuella PDF-filer i Cloud Storage. (Den *anonyma* prisdatan i statistiken påverkas dock inte, eftersom den inte längre är kopplad till individen).
2. **Rätten till Dataportabilitet:**
    * Användaren måste kunna få ut all sin data i ett maskinläsbart format.
    * *Lösning:* En "Exportera min data"-knapp i profilen som genererar en JSON eller CSV-fil med alla deras sparade kvittorader. Detta är också en fantastisk UX-funktion ("Lås inte in min data!").

## 4. Cookie-hantering och Den "Cookie-fria" drömmen
I EU är vi vana vid gigantiska, störande Cookie-banners. Eftersom vi bygger Matdata 2.0 från grunden med modern teknik kan vi göra ett aktivt val att *minimera behovet av en banner*.

### 4.1 Nödvändiga Cookies (Undantagna från krav på banner)
Lagen (ePrivacy-direktivet) säger att cookies som är *strikt nödvändiga* för att tjänsten ska fungera inte kräver samtycke/banner, bara information i en integritetspolicy.
* **`SESSION` (Spring Session):** Krävs för inloggningen och för att veta vem användaren är. (Nödvändig).
* **`XSRF-TOKEN` (Spring Security CSRF):** Krävs för att skydda formulär mot Cross-Site Request Forgery (särskilt viktigt vid HTMX-anrop). (Nödvändig).

### 4.2 Icke-nödvändiga Cookies (Kräver Banner)
Detta är spårningsverktyg, marknadsföring och tredjepartsanalys (t.ex. Google Analytics, Meta Pixel).

### 4.3 Vår Strategi: "Zero Annoyance" (Ingen Banner!)
Eftersom Matdata 2.0 främst är ett internt verktyg för användaren (vi ska inte sälja annonser baserat på deras surfbeteende) kan vi välja bort klientside-analys helt!

* **Analys på Servern (OpenTelemetry):** Som vi specificerade i krav **K10** använder vi OpenTelemetry för observabilitet. Genom att mäta trafiken (antalet inloggningar, vilka endpoints som anropas, felmeddelanden) direkt på Spring Boot-servern och i GCP, får vi all statistik vi behöver om appens hälsa *utan* att sätta en spårningscookie i användarens webbläsare.
* **Resultat:** När en användare surfar in på Matdata 2.0 loggar de bara in. Ingen gigantisk "Acceptera alla cookies"-pop-up täcker skärmen. Detta ger en otroligt premium, snabb och ren upplevelse!

## 5. Sammanfattning av Checklistan för Byggfasen
1. [ ] **Samtyckes-kryssruta:** Måste finnas på registreringssidan för att dela anonym statistik (ur-kryssad som standard).
2. [ ] **Cronjobb för PDF-rensning:** Skapa en process i GCP/Spring som automatiskt raderar PDF-filer som är äldre än t.ex. 30 dagar, om användaren inte explicit begärt att spara dem.
3. [ ] **Integritetspolicy-sida:** Skriv en tydlig, lättläst sida (utan juridiskt fikonspråk) som förklarar vilka 2 cookies appen använder och varför de behövs för inloggningens säkerhet.
4. [ ] **Exportera-knapp:** Skapa en enkel API-endpoint som gör en `SELECT * FROM receipts` för den inloggade användaren och returnerar CSV.
