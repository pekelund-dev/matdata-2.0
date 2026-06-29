# Ordlista: Matdata 2.0

Denna ordlista samlar termer, akronymer och produktspecifika begrepp som används i förstudiens dokument. Syftet är att alla bidragsgivare ska tolka begreppen på samma sätt.

## Innehåll
- [A–E](#aE)
- [F–L](#fL)
- [M–S](#mS)
- [T–Ö](#tO)

## A–E <a name="aE"></a>

| Term | Förklaring |
| --- | --- |
| **Apache PDFBox** | Java-bibliotek för att läsa och extrahera text ur PDF-filer. Används i `parser-service`. |
| **C4-modell** | Notation av Simon Brown för att beskriva mjukvaruarkitektur i fyra nivåer: Context, Container, Component, Code. |
| **Canary-test** | Återkommande test mot en känd referens (t.ex. en sparad PDF) som larmar om resultatet ändras oavsiktligt. |
| **Cloud Run** | GCP-tjänst för att köra containrar serverless med per-request-betalning. |
| **Cloud Storage (GCS)** | GCP:s objektlagring för filer. Används i Matdata för temporär PDF-lagring. |
| **Cookie-banner** | Modal för cookie-samtycke. Matdata strävar efter att undvika behovet helt (se [gdpr.md](gdpr.md)). |
| **Core Service** | Spring Boot-applikation som driver webbgränssnittet, autentisering och API:er. |
| **Crowdsourcing** | I Matdata: aggregering av anonymiserade priser från alla samtyckande användare. |
| **DLQ (Dead Letter Queue)** | Pub/Sub-topic dit meddelanden flyttas efter ett konfigurerat antal misslyckade leveransförsök. |
| **DPIA** | Data Protection Impact Assessment enligt GDPR Artikel 35. Se [dpia.md](dpia.md). |
| **EAN (European Article Number)** | Streckkodsstandard för konsumentvaror. Matdata använder EAN-13 som primär identifierare. |
| **EAN viktvarukod** | EAN-koder med prefix 20–29 där delar av koden representerar vikt eller pris. Måste maskeras för att inte bryta prishistoriken. |
| **ePrivacy** | EU-direktiv som reglerar elektronisk kommunikation, inklusive cookies. Kompletterar GDPR. |

## F–L <a name="fL"></a>

| Term | Förklaring |
| --- | --- |
| **FAB (Floating Action Button)** | Framträdande, ofta cirkulär knapp för primär åtgärd. I Matdata: ladda upp kvitto. |
| **Fas (Fas 1–5)** | Utvecklingsfaser i [project-plan_requirements.md](project-plan_requirements.md). |
| **Flyway** | Verktyg för versionshantering av databasschema. Migreringar körs vid uppstart. |
| **Förstudie** | Detta projektdokument-set som beskriver vad som ska byggas innan implementation påbörjas. |
| **GCP (Google Cloud Platform)** | Molnplattform som hostar all infrastruktur i Matdata 2.0. |
| **GDPR** | EU-förordning för dataskydd (Regulation (EU) 2016/679). Se [gdpr.md](gdpr.md). |
| **HTMX** | JavaScript-bibliotek för att skicka AJAX-anrop och uppdatera DOM utan eget JavaScript-ramverk. |
| **IaC (Infrastructure as Code)** | Praktiken att beskriva infrastruktur i kod. Matdata använder Terraform. |
| **Idempotens** | Egenskapen att samma operation kan utföras flera gånger med samma resultat. Viktigt för Pub/Sub-meddelanden. |
| **JDBC** | Java Database Connectivity – Javas standard för databasåtkomst. |
| **Kitchen Sink** | UI-komponentkatalogen på `/dev/components`. Visar alla återanvändbara Thymeleaf-fragment. |
| **Kivra** | Svensk digital brevlåda. Levererar bland annat ICA:s digitala kvitton som PDF. |
| **Krympflation (eng. *shrinkflation*)** | Fenomenet att förpackningar minskar i innehåll medan priset behålls. Matdata varnar för detta. |

## M–S <a name="mS"></a>

| Term | Förklaring |
| --- | --- |
| **Matdata 2.0** | Projektnamnet. "2.0" anger att en första version finns, men nya versionen byggs från grunden. |
| **MCP (Model Context Protocol)** | Protokoll för att ansluta AI-agenter till externa verktyg som designsystem. |
| **Mermaid** | Textbaserad notation för diagram som renderas av GitHub. Används i arkitekturdokumentet. |
| **Moms-kollen** | Tematisk analysvy som visar om butiker fört vidare momssänkningen på livsmedel. Krav K15. |
| **Monorepo** | Repository som innehåller flera tjänster (`core-service`, `parser-service`, `terraform`, osv.). |
| **MoSCoW** | Prioriteringsmetod: Must / Should / Could / Won't have. Se [project-plan_requirements.md](project-plan_requirements.md). |
| **MVP (Minimum Viable Product)** | Minsta version som levererar värde och kan testas med användare. |
| **Neon** | Serverless PostgreSQL-leverantör med stöd för databas-branchning per Pull Request. |
| **NFR (Non-Functional Requirement)** | Krav på systemets kvalitetsegenskaper. Se [non-functional-requirements.md](non-functional-requirements.md). |
| **OAuth2** | Standard för delegerad autentisering. Matdata stödjer OAuth2 via Google. |
| **OpenTelemetry (OTel)** | Standard för distribuerad spårning, loggar och mätvärden. Exporterar till GCP Cloud Trace/Logging. |
| **Parser Service** | Spring Boot-worker som extraherar och normaliserar data ur uppladdade PDF-filer. |
| **PDPB (Privacy by Design)** | Princip om att bygga in dataskydd från start (GDPR Artikel 25). |
| **PLU (Price Look-Up code)** | Numerisk kod för obarcoderade varor, främst frukt och grönt. |
| **PR-miljö** | Per-Pull-Request-deployment med egen Cloud Run-instans, Pub/Sub-topic och Neon-databasbranch. |
| **Pub/Sub** | GCP:s meddelandekö-tjänst. Används mellan `core-service` och `parser-service`. |
| **RACI** | Ansvarsmatris: Responsible, Accountable, Consulted, Informed. |
| **Row-Level Security (RLS)** | PostgreSQL-funktion som filtrerar rader per användare på databasnivå. |
| **RPO/RTO** | Recovery Point Objective (max accepterad dataförlust) / Recovery Time Objective (max accepterad nedtid). |
| **SLA/SLO/SLI** | Service Level Agreement / Objective / Indicator. Definierar och mäter tjänstekvalitet. |
| **Spring Boot** | Java-ramverk för snabb utveckling av webbapplikationer. Matdata använder version 4.x. |
| **Spring Security** | Spring-modul för autentisering och auktorisering. |

## T–Ö <a name="tO"></a>

| Term | Förklaring |
| --- | --- |
| **Tailwind CSS** | Utility-first CSS-ramverk. Används för all styling i Matdata. |
| **Terraform** | IaC-verktyg från HashiCorp. Beskriver GCP- och Neon-resurser deklarativt. |
| **Testcontainers** | Java-bibliotek som startar Docker-containrar för integrationstester (t.ex. PostgreSQL). |
| **Thymeleaf** | Server-side templating-motor för Spring Boot. Används istället för React/Vue. |
| **Trace ID** | Unik identifierare som följer en begäran genom alla tjänster. Genereras av OpenTelemetry. |
| **VAT-rate (Momssats)** | Mervärdesskattesats. I Sverige 12 % på livsmedel (tillfälligt 6 % under momssänkningen). |
| **Workload Identity Federation** | Mekanism för att låta GitHub Actions få GCP-access utan långlivade service account-nycklar. |
| **XSRF-TOKEN** | Cookie som används för att skydda mot Cross-Site Request Forgery i Spring Security. |
| **Återhämtningstid (RTO)** | Se RPO/RTO ovan. |
| **Övergångsspår (Trace)** | Se Trace ID. |
