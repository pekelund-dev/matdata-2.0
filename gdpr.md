# Deep Dive: GDPR och cookie-hantering i Matdata 2.0

| Metadata | |
| --- | --- |
| Version | 1.0 |
| Senast uppdaterad | 2026-06-29 |
| Status | Förstudie klar för granskning |
| Plats i dokumentationen | Dataskydd och cookie-strategi. Kompletteras av [dpia.md](dpia.md). |

> Detta dokument beskriver strategin. För fullständig Data Protection Impact Assessment, se [dpia.md](dpia.md). För övriga dokument, se [README.md](README.md).

## Innehåll
- [1. Varför är Matdata 2.0 extra känsligt?](#kanslighet)
- [2. GDPR-strategi och rättslig grund](#rattslig-grund)
- [3. Användarnas rättigheter (hur vi bygger det i koden)](#rattigheter)
- [4. Retention och dataminimering](#retention)
- [5. Cookie-hantering och den "cookie-fria" drömmen](#cookies)
- [6. Incidenthantering](#incident)
- [7. Personuppgiftsbiträden och DPA](#biträden)
- [8. Sammanfattning av checklistan för byggfasen](#checklista)

## 1. Varför är Matdata 2.0 extra känsligt? <a name="kanslighet"></a>

Att samla in kvittodata innebär insamling av högkänslig beteendedata. Ett kvitto visar inte bara att någon köpt "Mjölk", det visar exakt *vilken* butik (geografisk plats), *när* (tidpunkt för besök), och kan indirekt avslöja känsliga personuppgifter enligt GDPR Artikel 9 (t.ex. hälsotillstånd genom köp av laktosfritt, medicin, eller religion via kosher/halal-produkter).

Det är skälet till att en formell DPIA upprättats. Se [dpia.md](dpia.md).

## 2. GDPR-strategi och rättslig grund <a name="rattslig-grund"></a>

För att få behandla data lagligt måste varje process ha en "Rättslig grund" (Legal basis). Vi delar upp plattformen i två delar:

### 2.1 Kärnfunktionen (privat prishistorik)
* **Ändamål:** Låta användaren se sin egen historik och ladda upp sina kvitton.
* **Rättslig grund:** *Avtal* (Artikel 6.1.b). Användaren skapar ett konto för att använda tjänsten. Vi måste lagra datan för att kunna leverera tjänsten.
* **Lagring av PDF:** Original-PDF:en i Google Cloud Storage bör omfattas av "Dataminimering". Behöver användaren verkligen se originalkvittot för evigt?
    * *Lösning:* Default raderas PDF efter 30 dagar (se ADR-008 i [open-decisions.md](open-decisions.md)). Användaren kan välja att behålla en specifik PDF längre direkt vid uppladdning.

### 2.2 Crowdsourcing och global statistik (krav K13)
* **Ändamål:** Samla prispunkter från alla användare för att visa globala trender ("Svensk Mjölk 3% snittpris i Sverige").
* **Rättslig grund:** *Samtycke* (Consent - Artikel 6.1.a). Användaren måste aktivt kryssa i "Jag vill dela mina priser anonymt för att hjälpa andra". Detta får *inte* vara förkryssat.
* **Den tekniska lösningen (anonymisering):** GDPR gäller *inte* för helt anonymiserad data. Men att ta bort namnet räcker inte. Om databasen sparar "Kvitto från ICA Nära Möllevången, 2026-06-23 09:42" med exakt vilka 34 varor som köptes, kan det gå att identifiera personen om någon råkade se dem i butiken.
    * *Teknisk implementation:* Vår `parser-service` måste "stycka upp" kvittot. När den skriver till den globala statistiken (`global_price_points`) sparar den *endast*: artikelnummer, pris, ort (t.ex. "Malmö", *inte* den specifika butiken) och **år-månad** (`YYYY-MM`, *inte* exakt tidsstämpel). På så sätt frikopplas varje enskild vara från själva "inköpskorgen", vilket gör datan oåterkalleligt anonym.
    * Granulariteten är beslutad i ADR-007 i [open-decisions.md](open-decisions.md).

## 3. Användarnas rättigheter (hur vi bygger det i koden) <a name="rattigheter"></a>

GDPR ger användarna åtta huvudsakliga rättigheter (Artiklarna 13–22). Tabellen sammanfattar dem och hänvisar till var de hanteras i Matdata 2.0. Fullständig matris finns även i [dpia.md](dpia.md) avsnitt 9.

| Rättighet | Artikel | Implementation i Matdata 2.0 |
| --- | --- | --- |
| **Rätt till information** | 13, 14 | Integritetspolicy visas vid registrering och alltid via `/profile/privacy`. Skriven i klarspråk. |
| **Rätt till tillgång** | 15 | "Exportera min data" producerar JSON eller CSV med konto, samtycken och alla kvitton. |
| **Rätt till rättelse** | 16 | Användaren kan redigera profil och e-post i `/profile`. Korrigering av enskilda kvittorader planeras post-MVP. |
| **Rätt till radering ("rätten att bli glömd")** | 17 | "Radera mitt konto". Använder `ON DELETE CASCADE` + raderar PDF:er i Cloud Storage. Den anonyma prisdatan i `global_price_points` påverkas inte, eftersom den inte längre är kopplad till individen. |
| **Rätt till begränsning av behandling** | 18 | Användaren kan dra tillbaka samtycke för crowdsourcing när som helst. Inaktivering av konto (utan radering) erbjuds post-MVP. |
| **Rätt till dataportabilitet** | 20 | Samma exportfunktion som rätten till tillgång. Format: JSON och CSV. |
| **Rätt att invända** | 21 | Berättigat intresse används endast för säkerhetsloggar. Invändning hanteras manuellt via support. |
| **Rättigheter rörande automatiserat beslutsfattande** | 22 | Matdata 2.0 fattar inga automatiserade beslut med juridisk eller liknande effekt. |

### 3.1 Praktiska designval
* **Radering:** `ON DELETE CASCADE` på FK till `USERS`. Asynkront jobb raderar tillhörande objekt i Cloud Storage. Audit-logg skapas (NFR-D6 i [non-functional-requirements.md](non-functional-requirements.md)).
* **Export:** Endpoint `GET /api/profile/export?format=json|csv`. Standardiserad och versionerad output.
* **Samtycke:** Tidsstämpel sparas (`USERS.consent_updated_at`) tillsammans med valt alternativ. Spår över återkallat samtycke loggas i audit-loggen.

## 4. Retention och dataminimering <a name="retention"></a>

| Datatyp | Lagringstid | Trigger för radering | Källa |
| --- | --- | --- | --- |
| Konto + e-post | Tills användaren raderar | Användaråtgärd, automatiskt efter 24 mån inaktivitet | [non-functional-requirements.md](non-functional-requirements.md) NFR-D2 |
| Lösenordshash | Tills användaren raderar | Användaråtgärd | NFR-D2 |
| Personliga kvittorader | Tills användaren raderar | Användaråtgärd (ON DELETE CASCADE) | NFR-D2 |
| Original-PDF | 30 dagar (default) eller tills användaren raderar | Cronjobb + användaråtgärd | NFR-D1 |
| Anonymiserad statistik | Permanent | Påverkas ej av kontoradering | NFR-D3 |
| Audit-loggar | 1 år | Schemalagd radering | NFR-D6 |
| Allmänna loggar | 30 dagar | Cloud Logging default | NFR-D5 |
| Sessioner | 30 dagar inaktivitet | Daglig rensning | NFR-D4 |

## 5. Cookie-hantering och den "cookie-fria" drömmen <a name="cookies"></a>

I EU är vi vana vid gigantiska, störande Cookie-banners. Eftersom vi bygger Matdata 2.0 från grunden med modern teknik kan vi göra ett aktivt val att *minimera behovet av en banner*.

### 5.1 Nödvändiga cookies (undantagna från krav på banner)
Lagen (ePrivacy-direktivet) säger att cookies som är *strikt nödvändiga* för att tjänsten ska fungera inte kräver samtycke/banner, bara information i en integritetspolicy.

* **`SESSION` (Spring Session):** Krävs för inloggningen och för att veta vem användaren är. (Nödvändig).
* **`XSRF-TOKEN` (Spring Security CSRF):** Krävs för att skydda formulär mot Cross-Site Request Forgery (särskilt viktigt vid HTMX-anrop). (Nödvändig).

### 5.2 Icke-nödvändiga cookies (kräver banner)
Detta är spårningsverktyg, marknadsföring och tredjepartsanalys (t.ex. Google Analytics, Meta Pixel).

### 5.3 Vår strategi: "Zero Annoyance" (ingen banner)
Eftersom Matdata 2.0 främst är ett internt verktyg för användaren (vi ska inte sälja annonser baserat på deras surfbeteende) kan vi välja bort klientside-analys helt.

* **Analys på servern (OpenTelemetry):** Som vi specificerade i krav **K10** använder vi OpenTelemetry för observabilitet. Genom att mäta trafiken (antalet inloggningar, vilka endpoints som anropas, felmeddelanden) direkt på Spring Boot-servern och i GCP, får vi all statistik vi behöver om appens hälsa *utan* att sätta en spårningscookie i användarens webbläsare.
* **Resultat:** När en användare surfar in på Matdata 2.0 loggar de bara in. Ingen gigantisk "Acceptera alla cookies"-pop-up täcker skärmen. Detta ger en otroligt premium, snabb och ren upplevelse.

### 5.4 OAuth via Google (post-MVP)
När Google OAuth2 aktiveras (se ADR-009 i [open-decisions.md](open-decisions.md)) skickas användaren till `accounts.google.com` för inloggning. Eftersom det är en tydlig användaråtgärd (klick på "Logga in med Google") krävs inget eget cookie-samtycke. Integritetspolicyn ska dock tydligt informera om att Google blir personuppgiftsbiträde för OAuth-flödet.

## 6. Incidenthantering <a name="incident"></a>

GDPR Artikel 33 kräver att personuppgiftsincidenter rapporteras till Integritetsskyddsmyndigheten (IMY) inom **72 timmar** från upptäckt. Vid hög risk för enskildas rättigheter måste även berörda informeras (Artikel 34).

Full beskrivning av incidenthanteringsprocessen finns i [dpia.md](dpia.md) avsnitt 10. Sammanfattat:

1. **Upptäckt** via larm, intern rapport eller extern signal.
2. **Kategorisering** inom 4 timmar.
3. **Begränsning** av exponering.
4. **Riskbedömning** för enskilda.
5. **IMY-anmälan** inom 72 timmar om risken bedöms som sannolik.
6. **Information till berörda** vid hög risk.
7. **Postmortem** dokumenteras och åtgärder läggs in i [risk-register.md](risk-register.md).

## 7. Personuppgiftsbiträden och DPA <a name="biträden"></a>

| Personuppgiftsbiträde | Behandling | Säte | Avtal |
| --- | --- | --- | --- |
| Google Cloud Platform | Hosting, lagring, Pub/Sub, observability | EU-region (Belgien) | Google Cloud DPA |
| Neon Inc. | Databas (PostgreSQL) | EU-region väljs | Neons standard-DPA |
| E-postleverantör (Brevo/Resend, post-MVP) | Transaktionell e-post | EU | Leverantörens DPA |
| Google (OAuth, post-MVP) | Identitet vid OAuth2-inloggning | Globalt | Användarens egen relation + Google OAuth DPA |

Tredjelandsöverföringar bedöms i [dpia.md](dpia.md) avsnitt 5.

## 8. Sammanfattning av checklistan för byggfasen <a name="checklista"></a>

Följande punkter måste vara klara innan publik lansering:

### 8.1 Samtycke och rättslig grund
1. [ ] **Samtyckes-kryssruta:** Måste finnas på registreringssidan och i profilen för att dela anonym statistik. Aldrig förkryssad.
2. [ ] **Samtyckesregister:** Tidsstämpel och valt alternativ sparas i `USERS`. Återkallat samtycke loggas i audit-loggen.
3. [ ] **Rättslig grund per behandling:** Dokumenterad i [dpia.md](dpia.md) avsnitt 3.

### 8.2 Retention och dataminimering
4. [ ] **Cronjobb för PDF-rensning:** Skapa en process i GCP/Spring som automatiskt raderar PDF-filer som är äldre än 30 dagar, om användaren inte explicit begärt att spara dem.
5. [ ] **Lifecycle policy på Cloud Storage:** Backupskydd för cronjobbet.
6. [ ] **Cronjobb för session-rensning:** Default 30 dagars inaktivitet.
7. [ ] **Cronjobb för audit-loggar:** Default 1 års retention.

### 8.3 Användarrättigheter (Artiklarna 13–22)
8. [ ] **Integritetspolicy-sida:** Skriv en tydlig, lättläst sida (utan juridiskt fikonspråk) som förklarar vilka 2 cookies appen använder och varför de behövs för inloggningens säkerhet.
9. [ ] **Exportera-knapp:** Skapa en API-endpoint som returnerar konto + kvitton som JSON eller CSV.
10. [ ] **Radera-flöde:** Knapp i profilen som triggar full radering (ON DELETE CASCADE + PDF-radering).
11. [ ] **Rättelse-flöde:** Användaren kan redigera profil och e-post i `/profile`.
12. [ ] **Återkallande av samtycke:** Toggla i profilen som tar bort samtycke för crowdsourcing.

### 8.4 Säkerhet och loggning
13. [ ] **PII-mask i loggar:** Logback-mask för e-postadresser och lösenord. Granskning av all kod som loggar.
14. [ ] **Audit-loggar:** Inloggning, samtyckesändringar, dataexport och radering loggas separat (NFR-D6).
15. [ ] **Incidentprocess:** Mall för IMY-anmälan och kontaktlista uppdaterade.
16. [ ] **DPIA-revision:** [dpia.md](dpia.md) granskas innan publik lansering och därefter årligen.
