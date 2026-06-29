# Arkitekturdokument: Matdata 2.0

| Metadata | |
| --- | --- |
| Version | 1.0 |
| Senast uppdaterad | 2026-06-29 |
| Status | Förstudie klar för granskning |
| Plats i dokumentationen | Teknisk arkitektur. Läses efter [prestudy.md](prestudy.md). |

> Detta är arkitekturdokumentet. För kravmatris se [project-plan_requirements.md](project-plan_requirements.md). För icke-funktionella krav (prestanda, säkerhet, accessibility) se [non-functional-requirements.md](non-functional-requirements.md). Övriga dokument är listade i [README.md](README.md).

## Innehåll
- [1. Översikt och vision](#oversikt)
- [2. Teknisk stack och designval](#stack)
- [3. Systemarkitektur (C4-modell)](#c4)
- [4. Kärnflöden och databearbetning](#flode)
- [5. Databasmodell](#databas)
- [6. CI/CD, deployment och testmiljöer](#cicd)
- [7. Säkerhet och observabilitet](#sakerhet)
- [8. Infrastruktur som kod (IaC)](#iac)
- [9. Autentisering och auktorisering](#auth)
- [10. Felhantering och resiliens](#resiliens)
- [11. Secrets och miljövariabler](#secrets)
- [12. Sökarkitektur](#sok)
- [13. Backup och katastrofåterställning](#backup)
- [14. Monorepo-struktur](#monorepo)

## 1. Översikt och vision <a name="oversikt"></a>
Matdata 2.0 är en webbapplikation designad för att hjälpa konsumenter att spåra sina matkostnader på detaljnivå. Genom att ladda upp digitala PDF-kvitton, primärt från ICA via Kivra, extraherar systemet automatiskt artikelnummer (EAN/PLU), produktnamn och priser.

Systemet bygger på en modern, händelsestyrd arkitektur, anpassad för att köras serverless i Google Cloud Platform (GCP). Genom att separera användargränssnitt från tunga beräkningar garanteras hög prestanda och kostnadseffektivitet. Projektet fungerar som en referensimplementation för modern Java, molninfrastruktur och DevOps-praktiker.

## 2. Teknisk stack och designval <a name="stack"></a>

### 2.1 Backend (distribuerad arkitektur)
Systemet är uppdelat i två separata Spring Boot-applikationer för att optimera resursanvändning och möjliggöra oberoende skalning.

* **Språk:** Java 26 med fokus på Virtual Threads, Pattern Matching och Records.
* **Core Service (web/API):** En Spring Boot 4.x-applikation som hanterar användargränssnitt (Thymeleaf), inloggning, databasfrågor och filuppladdningar. Den konfigureras för låg minnesförbrukning och snabb responstid.
* **Parser Service (worker):** En separat Spring Boot 4.x-applikation dedikerad till tunga operationer. Använder Apache PDFBox för textextraktion och tilldelas mer CPU/RAM för att snabbt kunna bearbeta PDF-filer i bakgrunden.
* **Meddelandekö:** Google Cloud Pub/Sub används för asynkron kommunikation mellan de två tjänsterna.
* **Observabilitet:** OpenTelemetry (OTel) används för distribuerad spårning, loggar och mätvärden över båda tjänsterna.

### 2.2 Frontend (användargränssnitt)
* **Templating:** Thymeleaf för server-side rendering (SSR).
* **Interaktivitet:** HTMX för dynamiska DOM-uppdateringar via asynkrona anrop.
* **Styling:** Tailwind CSS för snabb, responsiv design.
* **Diagrambibliotek:** Beslut pågår (se ADR-011 i [open-decisions.md](open-decisions.md)).

### 2.3 Data och lagring
* **Databas:** Neon (serverless PostgreSQL) med stöd för branchning av databaser i test- och PR-miljöer.
* **Migrering:** Flyway för databasschema-versionering.
* **Objektlagring:** Google Cloud Storage för uppladdade PDF-kvitton. Lifecycle policy raderar PDF:er efter 30 dagar by default (se ADR-008 i [open-decisions.md](open-decisions.md) och [non-functional-requirements.md](non-functional-requirements.md) NFR-D1).

## 3. Systemarkitektur (C4-modell) <a name="c4"></a>

### 3.1 Nivå 1: Systemkontext
Visar hur systemets huvudsakliga komponenter och omvärlden interagerar.

```mermaid
graph TD
    User([Användare]) -->|Interagerar via webbläsare| CoreApp[Core Service<br/>Web och API]
    Kivra([Kivra / ICA]) -.->|Levererar digitala kvitton| User

    CoreApp -->|Sparar filer| GCS[(GCP Cloud Storage)]
    CoreApp -->|Skickar event| PubSub[[GCP Pub/Sub]]
    PubSub -->|Triggar| ParserApp[Parser Service<br/>Bakgrunds-worker]

    CoreApp -->|Läser/Skriver| DB[(Neon PostgreSQL)]
    ParserApp -->|Skriver analyserat data| DB
```

### 3.2 Nivå 2: Container-arkitektur
Visar den interna uppbyggnaden av de två tjänsterna och hur OpenTelemetry syr ihop övervakningen mellan dem.

```mermaid
graph TD
    subgraph Core Service (Cloud Run)
        Web[Webblager<br/>Thymeleaf och HTMX]
        Security[Säkerhet och Auth]
        ServiceCore[Core Service Logic]
        Publisher[Pub/Sub Publisher]
    end

    subgraph Parser Service (Cloud Run)
        Subscriber[Pub/Sub Subscriber]
        Parser[PDF Parser<br/>Apache PDFBox]
        ServiceParser[Parser Service Logic]
    end

    DB[(Neon PostgreSQL)]
    GCS[(Cloud Storage)]
    OTel[OpenTelemetry<br/>Collector]

    Web --> Security
    Security --> ServiceCore
    ServiceCore --> Publisher
    ServiceCore --> DB
    ServiceCore --> GCS

    Publisher -.->|Skickar 'ReceiptUploaded' event| Subscriber

    Subscriber --> ServiceParser
    ServiceParser --> Parser
    ServiceParser --> DB

    ServiceCore -.->|Spårning/Loggar| OTel
    ServiceParser -.->|Spårning/Loggar| OTel
```

### 3.3 Nivå 3: Komponenter i Core Service
Visar de viktigaste komponenterna inuti `core-service` och deras ansvar.

```mermaid
graph TD
    subgraph "Core Service"
        Controllers[Controllers<br/>Web, API, Auth, Profile]
        UploadService[ReceiptUploadService]
        ReceiptService[ReceiptQueryService]
        SearchService[ProductSearchService]
        ProfileService[UserProfileService]
        ExportService[DataExportService<br/>GDPR rättigheter]
        Repo[(Repositories<br/>Spring Data JPA)]
        StorageAdapter[GcsStorageAdapter]
        PubSubAdapter[PubSubPublisherAdapter]
    end

    Controllers --> UploadService
    Controllers --> ReceiptService
    Controllers --> SearchService
    Controllers --> ProfileService
    Controllers --> ExportService

    UploadService --> Repo
    UploadService --> StorageAdapter
    UploadService --> PubSubAdapter
    ReceiptService --> Repo
    SearchService --> Repo
    ProfileService --> Repo
    ExportService --> Repo
```

### 3.4 Nivå 3: Komponenter i Parser Service
Visar Parser Service uppdelad i mottagning, parsing och persistens.

```mermaid
graph TD
    subgraph "Parser Service"
        Listener[ReceiptUploadedListener<br/>Pub/Sub subscriber]
        Orchestrator[ReceiptParsingOrchestrator]
        Strategy[ParserStrategySelector<br/>Plugin-arkitektur K20]
        IcaParser[IcaReceiptParser]
        EanService[EanNormalizationService]
        ReceiptWriter[ReceiptPersistenceService]
        StatsWriter[AnonymousStatsPublisher]
        Repo[(Repositories<br/>Spring Data JPA)]
    end

    Listener --> Orchestrator
    Orchestrator --> Strategy
    Strategy --> IcaParser
    IcaParser --> EanService
    Orchestrator --> ReceiptWriter
    Orchestrator --> StatsWriter
    ReceiptWriter --> Repo
    StatsWriter --> Repo
```

## 4. Kärnflöden och databearbetning <a name="flode"></a>

### 4.1 Flöde: Asynkron uppladdning och bearbetning
Eftersom parsningen är asynkron får användaren ett direkt svar från gränssnittet, medan bearbetningen sker i bakgrunden.

```mermaid
sequenceDiagram
    actor User as Användare
    participant UI as Webbläsare (HTMX)
    participant Core as Core Service
    participant GCS as Cloud Storage
    participant PubSub as GCP Pub/Sub
    participant Worker as Parser Service
    participant DB as Neon DB (PostgreSQL)

    User->>UI: Klickar 'Ladda upp'
    UI->>Core: POST /api/receipts/upload

    Core->>GCS: Sparar PDF i privat bucket
    GCS-->>Core: Sökväg gs://...

    Core->>DB: Skapar kvitto-post (status: PENDING)
    Core->>PubSub: Publicerar event {receiptId, gcsUri, traceId}
    Core-->>UI: Returnerar svar: "Kvitto bearbetas..." (HTMX-polling startar)

    PubSub->>Worker: Pushar meddelande till worker
    Worker->>GCS: Laddar ner PDF
    Worker->>Worker: Extraherar text via PDFBox
    Worker->>DB: Skapar produkter, kvittorader och globala prispunkter
    Worker->>DB: Uppdaterar kvitto-post (status: COMPLETED)

    UI->>Core: Polling via HTMX (var 2:e sekund)
    Core-->>UI: Status COMPLETED + HTML-fragment med resultat
    UI->>User: Uppdaterar skärmen med priser
```

### 4.2 Domänlogik: Hantering av viktvaror och EAN
Ett vanligt problem vid parsing av kvitton är så kallade viktvaror eller butikspackade varor, till exempel köttfärs eller ost. Dessa använder ofta EAN-13-koder där vikt eller pris är inbakat i själva streckkoden, ofta med prefix 20–29.

* **Problemet:** Om hela streckkoden sparas som `article_number` blir varje enskilt paket kött en ny produkt i systemet. Då slutar prishistoriken fungera.
* **Lösningen i Parser Service:** Parsern måste identifiera om en EAN-kod är en viktvarukod. Om ja ska parsern maskera de siffror som representerar vikt eller pris och endast returnera det basartikelnummer som unikt identifierar varan.

## 5. Databasmodell <a name="databas"></a>

Databasen använder artificiella primärnycklar (UUID `id`). För att hantera det asynkrona flödet har tabellen `RECEIPTS` en statuskolumn (`PENDING`, `COMPLETED`, `FAILED`) samt tidsstämplar för spårbarhet och felhantering.

`RECEIPT_ITEMS` inkluderar `vat_rate` så att tematiska analysvyer som "Moms-kollen" (krav K15) kan beräkna effekten av momsförändringar. `PRODUCTS` har `created_at` och `updated_at` för auditbarhet och för att kunna upptäcka nya produkter över tid.

```mermaid
erDiagram
    USERS ||--o{ RECEIPTS : "äger"
    RECEIPTS ||--|{ RECEIPT_ITEMS : "innehåller"
    PRODUCTS ||--o{ RECEIPT_ITEMS : "refereras av"
    PRODUCTS ||--o{ GLOBAL_PRICE_POINTS : "har prispunkter"

    USERS {
        UUID id PK
        varchar email "Unik"
        varchar password_hash "NULL om OAuth2-inloggning"
        varchar oauth_provider "NULL, eller 'google'"
        varchar oauth_subject "Google subject-ID, NULL om lokal inloggning"
        boolean share_anonymous_data "Samtycke crowdsourcing"
        timestamp consent_updated_at "Tidsstämpel för senaste samtyckesval"
        timestamp created_at
    }

    RECEIPTS {
        UUID id PK
        UUID user_id FK
        varchar status "PENDING, COMPLETED, FAILED"
        varchar store_name
        varchar store_city "Ort, används till anonym statistik"
        date purchase_date
        decimal total_amount
        varchar pdf_storage_uri
        boolean retain_pdf "Användarval: behåll PDF efter 30 dagar"
        timestamp created_at
        timestamp updated_at
    }

    PRODUCTS {
        UUID id PK
        varchar article_number "Indexerad UK (EAN, PLU eller Base-EAN)"
        varchar name
        varchar category
        timestamp created_at
        timestamp updated_at
    }

    RECEIPT_ITEMS {
        UUID id PK
        UUID receipt_id FK
        UUID product_id FK
        decimal quantity
        decimal price_per_unit
        decimal discount
        decimal vat_rate "Momssats i procent, för Moms-kollen (K15)"
    }

    GLOBAL_PRICE_POINTS {
        UUID id PK
        UUID product_id FK
        decimal price
        varchar city "Ort, ej specifik butik (t.ex. Malmö)"
        varchar year_month "YYYY-MM, aldrig exakt datum"
    }
```

Aggregeringen i `GLOBAL_PRICE_POINTS` använder ort och månad. Beslutet är dokumenterat i ADR-007 i [open-decisions.md](open-decisions.md) och underbyggt i [dpia.md](dpia.md).

## 6. CI/CD, deployment och testmiljöer <a name="cicd"></a>

Vi tillämpar total automatisering via GitHub Actions. Eftersom lösningen ligger i ett monorepo med två tjänster, `core-service` och `parser-service`, bygger pipelinen båda.

### 6.1 Dynamiska PR-miljöer (preview environments)
För varje Pull Request upprättas automatiskt en isolerad testmiljö.

**Flödet för en PR:**
1. **Neon DB-branching:** GitHub Actions anropar Neon och skapar en isolerad branch av huvuddatabasen.
2. **Bygg och deploy:** Både Core Service och Parser Service byggs som Docker-images och driftsätts på Cloud Run med unika PR-specifika URL:er. De kopplas samman med ett unikt PR-Pub/Sub-topic för att förhindra krockar med produktionsdata.
3. **Teardown:** När PR:en stängs raderas de två Cloud Run-instanserna, Pub/Sub-topicet och databasbranchen automatiskt.

### 6.2 Säkerhetsåtgärder i pipeline
* Beroendescanning via Dependabot eller Renovate (NFR-SEC6).
* Statisk kodanalys via GitHub CodeQL (NFR-SEC7).
* Hemligheter via Workload Identity Federation (NFR-SEC8).
* Container-scanning av byggda images.

## 7. Säkerhet och observabilitet <a name="sakerhet"></a>

### 7.1 Autentisering och datasegregation
* Inloggning hanteras via Spring Security. Detaljer i avsnitt 9.
* Row-Level Security säkerställer att databasanrop som hämtar eller modifierar kvitton är strikt bundna till den inloggade användarens `user_id`.

### 7.2 Observabilitet
I en distribuerad arkitektur är övervakning extra kritiskt. Mätbara mål samlas i [non-functional-requirements.md](non-functional-requirements.md) avsnitt 6.

* **Distribuerad spårning:** När ett uppladdningsanrop träffar `core-service` skapas ett `trace_id`. Detta ID inkluderas i Pub/Sub-meddelandet och plockas upp av `parser-service`, så att hela flödet kan följas i samma trace.
* **Loggar och metrics:** Båda tjänsterna skickar strukturerade loggar och mätvärden kontinuerligt för larm, felsökning och kapacitetsuppföljning.
* **PII-filtrering:** Loggarna ska inte innehålla e-postadresser, lösenord eller hela kvittoinnehåll. Logback-masker används.

## 8. Infrastruktur som kod (IaC) <a name="iac"></a>

All infrastruktur hanteras via **Terraform**.

### 8.1 Resurser som hanteras av Terraform
* **Google Cloud Platform (GCP):**
    * **Cloud Storage:** Bucket för PDF-kvitton (privat, lifecycle policy för 30 dagars retention).
    * **Cloud Pub/Sub:** Topic `receipt-uploads`, subscriptions och en separat Dead Letter Queue.
    * **Cloud Run:** Två separata tjänster. `core-service` konfigureras för snabb responstid och `parser-service` för bakgrundsbearbetning via Pub/Sub.
    * **IAM:** Separata service accounts för varje tjänst. Workload Identity Federation för GitHub Actions.
    * **Cloud Monitoring:** Larmpolicyer kopplade till SLO:er i [non-functional-requirements.md](non-functional-requirements.md).
* **Neon (databas):**
    * Provisionering av projekt, produktionsbranch och roller via Neons Terraform-provider.
    * Budgetlarm för storage och compute hours.

## 9. Autentisering och auktorisering <a name="auth"></a>

Autentiseringsstrategin är beslutad i ADR-009 i [open-decisions.md](open-decisions.md). **Lokal autentisering** används i MVP, och **OAuth2 via Google** läggs till som kompletterande inloggningsväg i en senare iteration. Datamodellen i avsnitt 5 är förberedd för båda.

### 9.1 MVP: lokal autentisering (e-post och lösenord)
* Spring Security form login används för inloggning och utloggning.
* Lösenord lagras som BCrypt-hashar i `USERS.password_hash` med kostnad ≥ 12 (NFR-SEC4).
* Sessioner lagras via JDBC i PostgreSQL så att flera instanser av `core-service` kan dela sessionsstatus.
* Sessions-cookien är `HttpOnly`, `Secure`, `SameSite=Lax`.
* Sessionsregenerering körs efter inloggning (NFR-SEC5).
* Rate limiting på autentiseringsendpoints (NFR-SEC10).
* Återställning av lösenord sker via e-postlänk; aktiveras post-MVP (se ADR-015 i [open-decisions.md](open-decisions.md)).

### 9.2 Post-MVP: OAuth2 via Google
* Spring Security OAuth2 Client används tillsammans med `spring-boot-starter-oauth2-client`.
* Google är initial identitetsleverantör.
* Inga lösenord lagras lokalt när användaren loggar in via Google.
* En användarpost skapas automatiskt första gången någon loggar in via Google.

### 9.3 Jämförelse mellan alternativen

| Alternativ | Fördelar | Nackdelar |
| --- | --- | --- |
| Lokal autentisering (MVP) | Full kontroll över inloggningsflöde, fungerar utan extern identitetsleverantör och är enkel att anpassa för egna kontoregler | Kräver hantering av lösenord, reset-flöden och större säkerhetsansvar |
| OAuth2 via Google (post-MVP) | Snabb onboarding, inga lokala lösenord och lägre friktion för användare med Google-konto | Beroende av extern leverantör, mer OAuth-konfiguration och mindre lämpligt för användare utan Google-konto |

### 9.4 Auktorisering och dataskydd
* `USERS`-tabellen stödjer båda inloggningsmodellerna genom nullable-fält för `password_hash`, `oauth_provider` och `oauth_subject`.
* Alla databasanrop ska vara bundna till autentiserad användares `user_id` via Row-Level Security eller motsvarande skydd i datalagret.
* Eventuella framtida administrativa funktioner ska separeras från vanliga användarroller.
* Audit-loggar för samtycke och inloggningshändelser, se [non-functional-requirements.md](non-functional-requirements.md) NFR-D6.

## 10. Felhantering och resiliens <a name="resiliens"></a>

Systemet är designat för att tolerera fel i den asynkrona parserkedjan utan att användaren förlorar insyn i vad som hänt.

### 10.1 Parser Service kraschar mitt i jobb
Om `parser-service` kraschar mitt under bearbetningen hinner meddelandet inte ackas i Pub/Sub. När ack-deadline löper ut levereras meddelandet igen. Ack-deadline är konfigurerbar och är som standard 10 minuter. Kvitto-postens status ligger kvar som `PENDING` tills en ny bearbetning lyckas eller processen flyttas till DLQ.

### 10.2 Dead Letter Queue (DLQ)
Efter ett konfigurerat antal misslyckade försök, exempelvis 5, flyttas meddelandet till topicet `receipt-uploads-dlq` för manuell inspektion och felsökning. DLQ-trafik > 0 ska larma inom 5 min (NFR-A4).

### 10.3 Synligt fel för användaren
När ett meddelande hamnar i DLQ ska en separat hanterare uppdatera kvittot till status `FAILED`. På så sätt ser användaren i gränssnittet att bearbetningen inte lyckades och att kvittot behöver laddas upp på nytt eller granskas manuellt.

### 10.4 Städning i Cloud Storage
Om parsning misslyckas permanent ska den uppladdade PDF-filen till slut rensas bort av ett schemalagt jobb, så att lagringen inte växer okontrollerat. Default lifecycle policy raderar PDF efter 30 dagar (NFR-D1).

### 10.5 Idempotens
För att undvika dubbletter måste parsern alltid kontrollera om ett kvitto redan har status `COMPLETED` innan bearbetning påbörjas. Om kvittot redan är klart ska meddelandet betraktas som redan hanterat.

## 11. Secrets och miljövariabler <a name="secrets"></a>

### 11.1 Lokal utveckling
* Lokalt används en `.env`-fil som **aldrig** committas och därför ska ligga i `.gitignore`.
* Spring Boot läser in filen via `spring.config.import=optional:file:.env[.properties]`.
* Utvecklare fyller själva i lokala värden för databas, GCP och vald autentiseringsmetod.

### 11.2 CI/CD
* GitHub Secrets används för känsliga värden i pipelines.
* GCP-access i GitHub Actions ska ske via Workload Identity Federation så att långlivade service account-nycklar inte behöver lagras.
* Miljövariabler injiceras vid build eller deploy till respektive Cloud Run-tjänst.

### 11.3 Miljövariabler

| Variabel | Beskrivning |
| --- | --- |
| `SPRING_PROFILES_ACTIVE` | Aktiv Spring-profil, till exempel `local`, `dev`, `pr` eller `prod`. |
| `DATABASE_URL` | JDBC- eller Postgres-anslutningssträng till Neon/PostgreSQL. |
| `DATABASE_USERNAME` | Databasanvändare. |
| `DATABASE_PASSWORD` | Databaslösenord. |
| `GCP_PROJECT_ID` | GCP-projektets ID. |
| `GCS_BUCKET_NAME` | Bucket för uppladdade PDF-kvitton. |
| `PUBSUB_TOPIC_RECEIPT_UPLOADS` | Topic för nya uppladdade kvitton. |
| `PUBSUB_SUBSCRIPTION_RECEIPT_UPLOADS` | Subscription som `parser-service` konsumerar från. |
| `PUBSUB_TOPIC_RECEIPT_UPLOADS_DLQ` | Topic för meddelanden som gått till DLQ. |
| `GOOGLE_CLIENT_ID` | OAuth2-klient-ID för Google-inloggning. Krävs endast om OAuth2 används (post-MVP). |
| `GOOGLE_CLIENT_SECRET` | OAuth2-klienthemlighet för Google-inloggning. Krävs endast om OAuth2 används (post-MVP). |
| `APP_BASE_URL` | Bas-URL för callback-URL:er, länkar och eventuella e-postflöden. |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Endpoint för export av tracing och metrics via OpenTelemetry. |
| `PDF_RETENTION_DAYS` | Antal dagar PDF lagras innan automatisk radering. Default 30. |

## 12. Sökarkitektur <a name="sok"></a>

Användaren ska kunna söka fram produkter via autocomplete (UX-vision avsnitt 2.3). NFR-P4 sätter latenskrav till < 200 ms p95.

### 12.1 MVP-implementation
* Backendendpoint: `GET /api/search?q=...`.
* Frågan körs mot `PRODUCTS.name` med PostgreSQL `ILIKE`-prefix-sök, kompletterat med `LIMIT 10` och sortering på popularitet (antal `RECEIPT_ITEMS` per produkt).
* Index: `CREATE INDEX idx_products_name_lower ON PRODUCTS (LOWER(name) text_pattern_ops);` för effektiv prefix-sök.
* Resultat returneras som ett Thymeleaf-fragment och renderas i autocomplete-listan via HTMX.

### 12.2 Skalningsväg (post-MVP)
Om dataset eller latenskrav växer utvärderas `pg_trgm` för fuzzy-matchning och därefter eventuellt en dedikerad sökmotor (se ADR-012 i [open-decisions.md](open-decisions.md)).

## 13. Backup och katastrofåterställning <a name="backup"></a>

* **Databas:** Neon tar dagliga snapshots med 14 dagars retention (NFR-D8). RPO ≤ 24 h, RTO ≤ 4 h (NFR-B1, NFR-B2).
* **Cloud Storage:** Originalkvittot betraktas som icke-kritisk data. Användaren uppmanas behålla original i Kivra (NFR-B3).
* **Infrastruktur:** Hela miljön kan återskapas från Terraform i ny GCP/Neon-instans (NFR-B5).
* **Återhämtningstest:** Minst en lyckad återhämtning från snapshot per kvartal (NFR-B4).

## 14. Monorepo-struktur <a name="monorepo"></a>

Reponamnet på GitHub är `matdata-monorepo` (se ADR-010 i [open-decisions.md](open-decisions.md)).

```text
matdata-monorepo/
├── core-service/          # Spring Boot Web/API-tjänst
├── parser-service/        # Spring Boot Worker-tjänst
├── terraform/             # All infrastruktur som kod
│   ├── main.tf
│   ├── variables.tf
│   └── modules/
│       ├── gcp/
│       └── neon/
├── documentation/         # Projektdokumentation (denna förstudie + framtida tekniska dokument)
└── .github/
    └── workflows/         # CI/CD-pipelines
```
