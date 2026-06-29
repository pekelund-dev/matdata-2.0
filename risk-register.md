# Riskregister: Matdata 2.0

**Version:** 1.0
**Senast uppdaterad:** 2026-06-29
**Status:** Förstudie klar för granskning

Detta dokument samlar identifierade risker i Matdata 2.0. Riskerna kategoriseras, bedöms och får en mitigeringsplan med tydlig ägare. Registret revideras inför varje fasövergång (se [project-plan_requirements.md](project-plan_requirements.md)).

## Innehåll
- [Skala och definitioner](#skala-och-definitioner)
- [Hur registret används](#hur-registret-anvands)
- [Risköversikt (matris)](#riskoversikt)
- [Tekniska risker (T)](#tekniska-risker)
- [Verksamhets- och produktrisker (V)](#verksamhetsrisker)
- [Säkerhets- och GDPR-risker (S)](#sakerhetsrisker)
- [Leverantörs- och beroenderisker (L)](#leverantorsrisker)
- [Operationella risker (O)](#operationella-risker)
- [Ekonomiska risker (E)](#ekonomiska-risker)

## Skala och definitioner <a name="skala-och-definitioner"></a>

**Sannolikhet:**
* **Hög (H):** Troligt att inträffa under MVP-fasen.
* **Medel (M):** Kan inträffa, men är inte sannolikt på kort sikt.
* **Låg (L):** Osannolikt under MVP-fasen.

**Konsekvens:**
* **Hög (H):** Hotar leverans, brand eller juridisk efterlevnad.
* **Medel (M):** Försenar leverans eller försämrar användarupplevelsen avsevärt.
* **Låg (L):** Hanterbar, krävs ändå mitigering för att inte växa.

**Risknivå (kombination):**

| Sannolikhet \\ Konsekvens | Låg | Medel | Hög |
| --- | --- | --- | --- |
| **Hög** | Medel | Hög | Kritisk |
| **Medel** | Låg | Medel | Hög |
| **Låg** | Låg | Låg | Medel |

## Hur registret används <a name="hur-registret-anvands"></a>

* Varje risk har ett unikt ID (`T1`, `V1`, osv.) och refereras därifrån i kod, kommentarer och dokumentation.
* Ägare ansvarar för att övervaka triggern, exekvera mitigeringen och föreslå statusändringar.
* Vid varje fasstart (`Fas 1`–`Fas 5`) gås registret igenom och status uppdateras.
* Risker som inträffar flyttas till `Realiserad` och får en rapport i en sektion `Incidenter` (skapas vid behov).

## Risköversikt <a name="riskoversikt"></a>

| ID | Risk | Sannolikhet | Konsekvens | Risknivå | Ägare | Status |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | ICA/Kivra ändrar PDF-layout | Hög | Hög | Kritisk | Parser-utvecklare | Aktiv |
| T2 | Komplex EAN-logik för viktvaror | Hög | Medel | Hög | Parser-utvecklare | Aktiv |
| T3 | OpenTelemetry-konfiguration mot GCP fungerar inte som väntat | Medel | Medel | Medel | Plattformsägare | Aktiv |
| T4 | Neon-branchning per PR introducerar oväntade kostnader eller fördröjningar | Medel | Medel | Medel | Plattformsägare | Aktiv |
| T5 | Java 26 / Spring Boot 4.x introducerar oväntade buggar (relativt nya versioner) | Medel | Medel | Medel | Lead developer | Aktiv |
| T6 | Pub/Sub-meddelanden levereras flera gånger eller utanför ordning | Hög | Låg | Medel | Parser-utvecklare | Aktiv |
| V1 | Användare laddar upp få kvitton och datavolymen blir för liten för att ge insikt | Medel | Hög | Hög | Produktägare | Aktiv |
| V2 | Endast ICA-stöd vid lansering begränsar målgruppen | Hög | Medel | Hög | Produktägare | Aktiv |
| V3 | Krav K15 ("Moms-kollen") blir irrelevant när momssänkningen normaliseras | Hög | Låg | Medel | Produktägare | Aktiv |
| S1 | Personuppgifter exponeras via felaktig anonymisering | Låg | Hög | Medel | Dataskyddsansvarig | Aktiv |
| S2 | Inloggningsflöde innehåller sårbarhet (t.ex. sessionhijack) | Låg | Hög | Medel | Säkerhetsansvarig | Aktiv |
| S3 | Användare ger samtycke utan att förstå vad som delas | Medel | Hög | Hög | Dataskyddsansvarig | Aktiv |
| S4 | Incident utan beredskap att rapportera inom 72 h (GDPR Art. 33) | Medel | Hög | Hög | Dataskyddsansvarig | Aktiv |
| L1 | Kivra ändrar sina villkor eller blockerar nedladdning av kvitton | Låg | Hög | Medel | Produktägare | Aktiv |
| L2 | Neon avvecklar gratisplaner eller höjer priser kraftigt | Låg | Medel | Låg | Plattformsägare | Aktiv |
| L3 | GCP höjer priser eller drar in tjänster (t.ex. Pub/Sub) | Låg | Medel | Låg | Plattformsägare | Aktiv |
| O1 | Endast en utvecklare (key person) på projektet | Hög | Hög | Kritisk | Projektägare | Aktiv |
| O2 | Driftsavbrott på Cloud Run eller Neon utan automatisk failover | Medel | Medel | Medel | Plattformsägare | Aktiv |
| O3 | Säkerhetspatch eller brådskande Spring-uppdatering missas | Medel | Medel | Medel | Lead developer | Aktiv |
| E1 | Molnkostnader skenar i samband med trafiktopp eller felkonfiguration | Medel | Medel | Medel | Plattformsägare | Aktiv |
| E2 | OCR/Vision API (K17) blir dyrare än förväntat när det aktiveras | Låg | Medel | Låg | Produktägare | Aktiv |

## Tekniska risker (T) <a name="tekniska-risker"></a>

### T1 — ICA/Kivra ändrar PDF-layout
* **Beskrivning:** Parsern är hårt knuten till ICA:s nuvarande PDF-layout. Layoutändringar bryter parsningen utan förvarning.
* **Trigger:** Plötslig ökning av kvitton i status `FAILED`, eller canary-testet (avsnitt 6.5 i projektplanen) larmar.
* **Mitigering:**
    * Versionera parsern med tydlig butik + format-version (krav i projektplan 6.4).
    * Schemalagd canary-test mot referens-PDF varje vecka (projektplan 6.5).
    * Larmregel i GCP Cloud Monitoring som triggar när failure-andelen passerar tröskel.
    * Återhämtningsplan: snabb hotfix-process där en uppdaterad parser kan deployas inom 24 h utan att gå via vanlig release-cykel.
* **Restrisk:** Användare upplever att enstaka kvitton inte processas under tiden patch tas fram.

### T2 — Komplex EAN-logik för viktvaror
* **Beskrivning:** EAN-koder med prefix 20–29 innehåller vikt/pris i koden. Felaktig maskning bryter prishistoriken eller skapar dubbletter.
* **Trigger:** Tester misslyckas, eller produktkatalogen i databasen växer onaturligt snabbt med "likadana" produkter.
* **Mitigering:**
    * Omfattande enhetstester med kända EAN-exempel (Fas 2, krav K3).
    * Migrering: möjlighet att i efterhand normalisera produkter om felaktig logik upptäckts (manuellt skript via DBA-roll).
    * Dokumenterad referenstabell över hanterade prefix.
* **Restrisk:** Nya butiker (K20) kan introducera nya prefix-konventioner.

### T3 — OpenTelemetry-konfiguration mot GCP fungerar inte som väntat
* **Beskrivning:** OTel-export till GCP Cloud Trace/Logging kräver korrekt konfiguration. Misslyckande gör att vi tappar observabilitet i produktion.
* **Trigger:** Saknade traces eller loggar i Cloud Trace efter deployment.
* **Mitigering:**
    * Integrationstest som verifierar att en lokal trace exporteras till en stub.
    * Tidigt smoke-test i Fas 3 i en dedikerad miljö.
    * Backup-logging via Cloud Logging direkt så att vi i värsta fall har strukturerade loggar.

### T4 — Neon-branchning per PR introducerar oväntade kostnader eller fördröjningar
* **Beskrivning:** Per-PR-branchning är nytt och kan introducera långa väntetider eller höga kostnader.
* **Trigger:** PR-jobb tar > 5 min på databasprovisionering, eller månadskostnaden överstiger budget i [cost-estimate.md](cost-estimate.md).
* **Mitigering:**
    * Sätt tydliga kostnadslarm i Neon-projektet.
    * Möjlighet att fall-back till delad test-databas under stora trafiktoppar.
    * Automatisk teardown vid PR-stängning (krav i Fas 1).

### T5 — Java 26 / Spring Boot 4.x introducerar oväntade buggar
* **Beskrivning:** Båda versionerna är nya och har mindre community-erfarenhet bakom sig.
* **Trigger:** Buggar i ramverken som blockerar utvecklingen.
* **Mitigering:**
    * Pin-version av varje beroende. Eskalering till nästa minor först efter att den varit ute > 1 månad.
    * Bevaka Spring-bloggen och changelog.
    * Möjlighet att backporta till Java 25/Spring 3.x i värsta fall.

### T6 — Pub/Sub levererar dubbletter eller meddelanden ur ordning
* **Beskrivning:** GCP Pub/Sub garanterar minst en leverans, inte exakt en. Dubbletter kan orsaka dubbel parsning.
* **Trigger:** Dubbletter av kvitton i databasen.
* **Mitigering:**
    * Idempotenskrav i `parser-service` (arkitektur 10.5).
    * Status-check (PENDING/COMPLETED) innan bearbetning startar.
    * `receipt_id` används som idempotency key.

## Verksamhets- och produktrisker (V) <a name="verksamhetsrisker"></a>

### V1 — Liten datavolym ger låga insikter
* **Beskrivning:** För att insikter (inflationsindex, krympflation, globala priser) ska bli meningsfulla krävs en kritisk massa av kvitton.
* **Trigger:** Användare upplever dashboarden som tom efter onboarding.
* **Mitigering:**
    * UX-designa "tomma tillstånd" som uppmuntrar uppladdning (se [ux-ui_vision.md](ux-ui_vision.md) avsnitt om tomma tillstånd).
    * Importguide som låter användaren ladda upp flera kvitton i taget vid första onboardingen.
    * Visa globala priser som referens när användarens egen data är liten.

### V2 — Endast ICA-stöd begränsar målgruppen
* **Beskrivning:** Tre av fyra svenska hushåll handlar i fler kedjor än ICA. Stöd för endast ICA via Kivra exkluderar majoriteten.
* **Trigger:** Användarundersökning visar att avhopp sker eftersom "min butik stöds inte".
* **Mitigering:**
    * Plugin-arkitekturen (K20) prioriteras tidigt i backloggen efter MVP.
    * Tydlig kommunikation: "Idag: ICA. På väg: Coop, Hemköp, Willys."
    * Acceptera scopet under MVP — bättre att lansera med en butik som fungerar perfekt.

### V3 — Moms-kollen blir irrelevant
* **Beskrivning:** Krav K15 är knutet till en specifik samhällsfråga (momssänkningen). När frågan svalnar tappar funktionen relevans.
* **Trigger:** Användning av "Moms-kollen" sjunker över tid.
* **Mitigering:**
    * Bygg "Moms-kollen" som mall för tematiska vyer (se [ux-ui_vision.md](ux-ui_vision.md) avsnitt 2.5).
    * Planera kommande tematiska kampanjer (t.ex. säsongsvariation, högtider, helgveckor).

## Säkerhets- och GDPR-risker (S) <a name="sakerhetsrisker"></a>

### S1 — Felaktig anonymisering läcker personuppgifter
* **Beskrivning:** "Anonymiserad" data kan i värsta fall avanonymiseras om granulariteten är för fin (t.ex. exakt butik och exakt tidpunkt).
* **Trigger:** Säkerhetsgranskning, eller anmälan från användare eller IMY.
* **Mitigering:**
    * Strikt separation i datamodellen (Privacy by Design, K8).
    * Aggregering till ort + månad (arkitektur avsnitt 5).
    * Kodgranskning av all kod som skriver till `GLOBAL_PRICE_POINTS`.
    * Se [dpia.md](dpia.md) för fullständig analys.

### S2 — Inloggningsflöde sårbart
* **Beskrivning:** Spring Security är robust men felkonfiguration kan introducera sårbarheter (sessionhijack, missad CSRF, svaga lösenord).
* **Trigger:** Penetrationstest hittar brister, eller incident i loggar (många misslyckade inloggningar från samma IP).
* **Mitigering:**
    * Använd Spring Securitys standardkonfiguration så långt som möjligt.
    * BCrypt för lösenord, sessionsregenerering efter inloggning, HTTPS via Cloud Run.
    * Säkerhetstester i CI (se [non-functional-requirements.md](non-functional-requirements.md)).

### S3 — Användare ger samtycke utan att förstå
* **Beskrivning:** Om samtyckes-flödet är otydligt blir samtycket inte giltigt enligt GDPR.
* **Trigger:** Användartester visar förvirring, eller IMY-klagomål.
* **Mitigering:**
    * UX-text granskas av juridik och vanlig användare.
    * Samtycke är aldrig förkryssat (GDPR-checklista i [gdpr.md](gdpr.md)).
    * Möjlighet att dra tillbaka samtycke när som helst i profilen.

### S4 — Saknad beredskap för incidenter
* **Beskrivning:** GDPR Artikel 33 kräver att personuppgiftsincidenter rapporteras till IMY inom 72 timmar.
* **Trigger:** Incident inträffar utan att rutin finns.
* **Mitigering:**
    * Dokumentera incidenthanteringsprocess (delprocess i [dpia.md](dpia.md)).
    * Larm i GCP Cloud Monitoring för anomalier (många failade requests, datalek-mönster).
    * Kontaktlista och mall för IMY-anmälan finns färdig.

## Leverantörs- och beroenderisker (L) <a name="leverantorsrisker"></a>

### L1 — Kivra ändrar villkor eller blockerar kvitton
* **Beskrivning:** Kivra är ett externt företag och kan begränsa nedladdning av kvitton.
* **Trigger:** Användare rapporterar att de inte kan ladda ner kvitton.
* **Mitigering:**
    * MVP är användardriven uppladdning, inte automatisk integration. Risken är därmed på Kivras användare, inte oss.
    * Reservplan: stöd för OCR av papperskvitton (K17) öppnar alternativ inmatning.

### L2 — Neon ändrar prisplan eller avvecklar gratis-nivå
* **Beskrivning:** Neon är relativt ungt företag.
* **Trigger:** Prishöjning eller mejl om förändrade villkor.
* **Mitigering:**
    * All Postgres-användning är standard. Migration till Cloud SQL eller Supabase är möjlig.
    * Terraform-providern abstraherar provisioneringen.

### L3 — GCP höjer priser eller drar in tjänster
* **Beskrivning:** Mindre sannolikt, men möjligt särskilt för nyare tjänster.
* **Trigger:** GCP-meddelande eller prisförändring.
* **Mitigering:**
    * Pub/Sub, Cloud Run och Cloud Storage är välimplementerade standarder.
    * Möjligt att byta plattform med rimlig insats om allt går via Terraform.

## Operationella risker (O) <a name="operationella-risker"></a>

### O1 — Single developer (key person dependency)
* **Beskrivning:** Endast en utvecklare på projektet. Sjukdom eller bortavaro stoppar all utveckling.
* **Trigger:** Projektledaren blir otillgänglig.
* **Mitigering:**
    * Förstudien (detta dokumentset) är skriven så att en ny utvecklare snabbt kan komma in.
    * All kod, infra och dokumentation finns publikt i Git.
    * ADR-light i [open-decisions.md](open-decisions.md) bevarar resonemang bakom beslut.

### O2 — Driftsavbrott på Cloud Run eller Neon
* **Beskrivning:** Inga SLA-garantier i MVP-fasen.
* **Trigger:** Användare rapporterar att tjänsten är nere.
* **Mitigering:**
    * Multi-zon hantering ingår i Cloud Runs grunddrift.
    * Neon-snapshot frekvens beskrivs i [non-functional-requirements.md](non-functional-requirements.md).
    * Statussida vid större avbrott (Could-have efter MVP).

### O3 — Säkerhetspatch missas
* **Beskrivning:** Spring-, Java- eller container-CVE missas.
* **Trigger:** Dependabot-larm ignoreras eller passar förbi.
* **Mitigering:**
    * Dependabot eller Renovate aktiverat på repo (krav i Fas 1, läggs till i checklistan).
    * Säkerhetsuppdateringar prioriteras före nya features.

## Ekonomiska risker (E) <a name="ekonomiska-risker"></a>

### E1 — Molnkostnader skenar
* **Beskrivning:** Felkonfigurerad autoscaling eller loop kan generera höga räkningar.
* **Trigger:** Månadsfaktura överstiger budget med > 50 %.
* **Mitigering:**
    * Budgetlarm i GCP (90 % och 100 % av månadsbudget enligt [cost-estimate.md](cost-estimate.md)).
    * Tak (`maxScale`) på Cloud Run-instanser.
    * Pub/Sub-meddelanden filtreras så att DLQ inte kan loopa.

### E2 — OCR/Vision API blir dyrare än förväntat
* **Beskrivning:** K17 (OCR) är prissatt per dokument och kan bli dyrt vid skala.
* **Trigger:** K17 implementeras och kostnaden överstiger budget.
* **Mitigering:**
    * K17 är "Could have" och aktiveras inte i MVP.
    * När K17 aktiveras: testa på liten volym först, kostnadslarm.
    * Möjlighet att skifta mellan Google Vision och Gemini Vision beroende på pris/prestanda.
