# Data Protection Impact Assessment (DPIA): Matdata 2.0

**Version:** 1.0
**Senast uppdaterad:** 2026-06-29
**Status:** Förstudie klar för granskning
**Ansvarig:** Dataskyddsansvarig (DPO eller motsvarande)

Detta dokument utgör en Data Protection Impact Assessment enligt GDPR Artikel 35. En DPIA krävs när behandlingen sannolikt leder till en hög risk för fysiska personers rättigheter och friheter, vilket är fallet eftersom Matdata 2.0 hanterar data som indirekt kan avslöja känsliga uppgifter enligt Artikel 9 (t.ex. hälsotillstånd genom köp av laktosfritt eller religion via halal-/kosher-produkter).

DPIA-dokumentet kompletterar [gdpr.md](gdpr.md) (strategin) och [risk-register.md](risk-register.md) (riskhanteringen). Tekniska detaljer i [architecture.md](architecture.md) och [non-functional-requirements.md](non-functional-requirements.md) refereras där det är relevant.

## Innehåll
- [1. Behandling och syften](#behandling)
- [2. Personuppgiftskategorier](#kategorier)
- [3. Rättslig grund](#rattslig-grund)
- [4. Mottagare och tredje parter](#mottagare)
- [5. Tredjelandsöverföringar](#tredjeland)
- [6. Lagringstid](#lagring)
- [7. Riskbedömning](#risker)
- [8. Mitigerande åtgärder](#mitigerande)
- [9. Användarrättigheter (komplett tabell)](#rattigheter)
- [10. Incidenthanteringsprocess](#incident)
- [11. Slutsats och beslut](#slutsats)
- [12. Revisionshistorik](#historik)

## 1. Behandling och syften <a name="behandling"></a>

Matdata 2.0 behandlar uppgifter i tre tydligt åtskilda processer:

1. **Kontohantering och inloggning** — för att leverera tjänsten.
2. **Kvittohantering (personlig prishistorik)** — för att låta användaren spåra sina utgifter.
3. **Anonymiserad statistik (crowdsourcing)** — för att producera global prisstatistik. Frikopplad från användaren.

Sektionerna nedan ska läsas mot dessa tre processer.

## 2. Personuppgiftskategorier <a name="kategorier"></a>

| Kategori | Exempel på data | Process | Känslighet |
| --- | --- | --- | --- |
| Identifierare | E-postadress, OAuth subject-ID | Kontohantering | Normal |
| Autentiseringsdata | Lösenordshash (BCrypt) | Kontohantering | Hög |
| Tekniska data | IP-adress (loggar), session-cookie, user-agent | Kontohantering | Normal |
| Inköpsdata (personlig) | Butik, datum, artikelnummer, produktnamn, pris, kvantitet | Kvittohantering | Hög (kan röja Art. 9-data) |
| Originalkvitto | PDF som laddats upp | Kvittohantering | Hög |
| Samtyckesregistreringar | Tidpunkt och valda alternativ för delning | Alla | Normal |
| Aggregerad statistik | Artikelnummer, pris, ort, månad | Crowdsourcing | Anonymiserad (omfattas inte av GDPR) |

Inga särskilda kategorier av personuppgifter (Art. 9) samlas in *medvetet*. Vissa varor på ett kvitto kan dock implicit avslöja sådan information. Detta är skälet till denna DPIA.

## 3. Rättslig grund <a name="rattslig-grund"></a>

| Process | Rättslig grund | Hänvisning |
| --- | --- | --- |
| Kontohantering och inloggning | Avtal (Art. 6.1.b) | Användaren skapar konto för att nyttja tjänsten |
| Kvittohantering | Avtal (Art. 6.1.b) | Tjänstens kärnfunktion |
| Crowdsourcing/global statistik | Samtycke (Art. 6.1.a) | Aktivt samtycke krävs (kryssruta, ej förvald) |
| Säkerhetsloggar | Berättigat intresse (Art. 6.1.f) | Skydd mot missbruk, intrångsdetektion |
| Audit-loggar för samtycke | Rättslig förpliktelse (Art. 6.1.c) | GDPR Art. 7.1 (bevisbörda) |

## 4. Mottagare och tredje parter <a name="mottagare"></a>

Inga personuppgifter delas med tredje part för marknadsföring eller försäljning. Personuppgiftsbiträden:

| Personuppgiftsbiträde | Behandling | Avtal | Säte |
| --- | --- | --- | --- |
| Google Cloud Platform (GCP) | Hosting, lagring, Pub/Sub, observability | DPA via Google Cloud avtal | EU (Belgien) |
| Neon Inc. | Databas (PostgreSQL) | DPA via Neons standardavtal | EU-region väljs |
| Brevo / Resend (e-post) | Transaktionell e-post (efter MVP) | DPA enligt leverantörens villkor | EU |
| Google (OAuth) | Inloggning om OAuth2 väljs | Inloggning, ingen permanent datadelning utöver subject-ID | EU/Globalt |

## 5. Tredjelandsöverföringar <a name="tredjeland"></a>

* All primär datalagring sker i EU-regioner (Cloud Run, Cloud Storage, Pub/Sub, Neon).
* Google-konton för OAuth2 hanteras av Google i deras globala infrastruktur. För användare som väljer OAuth2-inloggning kan transitering till tredjeland förekomma.
* GCP omfattas av EU–US Data Privacy Framework och Standard Contractual Clauses (SCC).

## 6. Lagringstid <a name="lagring"></a>

Sammanfattas här. Fullständig retention-tabell finns i [non-functional-requirements.md](non-functional-requirements.md) avsnitt 5.

| Datatyp | Lagringstid | Trigger för radering |
| --- | --- | --- |
| Konto + e-post | Tills användaren raderar | Användaråtgärd, automatisk efter 24 mån inaktivitet |
| Lösenordshash | Tills användaren raderar | Användaråtgärd |
| Personliga kvittorader | Tills användaren raderar | Användaråtgärd (ON DELETE CASCADE) |
| Original-PDF | 30 dagar (default) eller tills användaren raderar | Cronjobb + användaråtgärd |
| Anonymiserad statistik | Permanent | Påverkas ej av kontoradering (är inte personuppgift) |
| Audit-loggar för samtycke | 1 år | Schemalagd radering |
| Allmänna loggar | 30 dagar | Standard i Cloud Logging |

## 7. Riskbedömning <a name="risker"></a>

Riskerna grupperas i tre dimensioner: konfidentialitet, integritet och tillgänglighet. Skala enligt [risk-register.md](risk-register.md).

| ID | Risk | Sannolikhet | Konsekvens | Risknivå |
| --- | --- | --- | --- | --- |
| DPIA-R1 | Obehörig läser annan användares kvitton | Låg | Hög | Medel |
| DPIA-R2 | Anonymiseringen är otillräcklig och kan reverseras | Låg | Hög | Medel |
| DPIA-R3 | PDF i Cloud Storage exponeras via felaktig ACL | Låg | Hög | Medel |
| DPIA-R4 | Användare uppfattar inte samtyckes-omfattning | Medel | Hög | Hög |
| DPIA-R5 | Glömsk användare lagrar känsliga PDF:er längre än önskat | Medel | Medel | Medel |
| DPIA-R6 | Profilering uppstår oavsiktligt (varukorgsanalys per användare) | Låg | Medel | Låg |
| DPIA-R7 | Incident upptäcks ej i tid för 72 h-rapportering | Medel | Hög | Hög |
| DPIA-R8 | Loggar innehåller PII (e-postadress, IP) i klartext | Medel | Medel | Medel |
| DPIA-R9 | Användare kan inte exportera all sin data | Låg | Medel | Låg |
| DPIA-R10 | Användare kan inte få sina uppgifter raderade snabbt nog | Låg | Medel | Låg |

## 8. Mitigerande åtgärder <a name="mitigerande"></a>

| Risk-ID | Åtgärd | Var implementeras |
| --- | --- | --- |
| DPIA-R1 | Row-Level Security i PostgreSQL + verifikation att alla repository-anrop är knutna till `user_id` | [architecture.md](architecture.md) avsnitt 7.1 |
| DPIA-R2 | Anonymisering aggregeras till `ort` + `månad`, aldrig exakt butik eller tidpunkt; testfall i parser-suite | [architecture.md](architecture.md) avsnitt 5 |
| DPIA-R3 | Privat Cloud Storage-bucket, åtkomst endast via signed URLs eller service account; IaC granskar policy | [architecture.md](architecture.md) avsnitt 8 |
| DPIA-R4 | UX-text granskas, samtycke är aldrig förvalt, separat "Hjälp" som förklarar konsekvensen | [gdpr.md](gdpr.md) avsnitt 5 |
| DPIA-R5 | Default 30 dagars lagring av PDF + tydligt val vid uppladdning | [non-functional-requirements.md](non-functional-requirements.md) NFR-D1 |
| DPIA-R6 | Ingen automatisk profilering. Insiktsfunktioner som inflationsindex är aggregerade och visas endast för användaren själv. | [architecture.md](architecture.md) avsnitt 5 |
| DPIA-R7 | Larm i Cloud Monitoring, dokumenterad process (avsnitt 10 nedan) | Detta dokument |
| DPIA-R8 | Logback-mask för e-post och lösenord; PII-granskning i kodgranskning | [non-functional-requirements.md](non-functional-requirements.md) NFR-O5 |
| DPIA-R9 | Exportfunktion (JSON eller CSV) finns från MVP | [gdpr.md](gdpr.md) avsnitt 3 |
| DPIA-R10 | Radera-knapp använder `ON DELETE CASCADE` och raderar PDF:er i samma transaktion eller via asynkront jobb med audit-logg | [gdpr.md](gdpr.md) avsnitt 3 |

## 9. Användarrättigheter (komplett tabell) <a name="rattigheter"></a>

GDPR ger åtta huvudsakliga rättigheter (Art. 13–22). Matrisen visar hur Matdata 2.0 hanterar var och en.

| Rättighet | Artikel | Hur Matdata 2.0 stödjer den |
| --- | --- | --- |
| Rätt till information | Art. 13, 14 | Integritetspolicy publiceras vid registrering. Visas även i `/profile/privacy`. |
| Rätt till tillgång | Art. 15 | "Exportera min data" producerar JSON/CSV. Innehåller även loggar över samtycke. |
| Rätt till rättelse | Art. 16 | Användaren kan redigera profil och e-postadress i `/profile`. Kvittorader kan korrigeras manuellt om felaktiga (planerat efter MVP). |
| Rätt till radering ("rätten att bli glömd") | Art. 17 | "Radera mitt konto" raderar konto + kvitton (ON DELETE CASCADE) + PDF:er. Anonym statistik kvarstår. |
| Rätt till begränsning av behandling | Art. 18 | Användaren kan dra tillbaka samtycke för crowdsourcing när som helst. Inaktivera kontot (avregistrera utan radering) erbjuds efter MVP. |
| Rätt till dataportabilitet | Art. 20 | Samma exportfunktion som rätten till tillgång. Format: JSON och CSV. |
| Rätt att invända | Art. 21 | Berättigat intresse används endast för säkerhetsloggar. Invändning hanteras manuellt. |
| Rättigheter rörande automatiserat beslutsfattande | Art. 22 | Matdata 2.0 fattar inga automatiserade beslut med juridisk eller liknande effekt. |

## 10. Incidenthanteringsprocess <a name="incident"></a>

Vid en personuppgiftsincident (GDPR Art. 33–34) följer Matdata 2.0 denna process:

1. **Upptäckt:** Incident identifieras via larm (Cloud Monitoring), manuell rapport från användare eller säkerhetspartner. Tid noteras.
2. **Kategorisering:** Inom 4 timmar bestäms typ (konfidentialitet, integritet, tillgänglighet), omfattning och berörda kategorier.
3. **Begränsning:** Sårbarhet stängs (rollback, patch, blockering). Forensisk insamling av relevanta loggar.
4. **Bedömning av risk för berörda:** Bedömning av om incidenten "sannolikt medför en risk" eller "sannolikt medför en hög risk" enligt Art. 33–34.
5. **Anmälan till IMY:** Om risken bedöms som sannolik, anmäls incidenten till Integritetsskyddsmyndigheten inom 72 timmar från upptäckt. Mall för anmälan förbereds inför MVP-lansering.
6. **Informera berörda:** Vid hög risk informeras användare utan onödigt dröjsmål, i klarspråk.
7. **Postmortem:** Incident dokumenteras, rotorsak analyseras, åtgärder läggs in i [risk-register.md](risk-register.md) och i issue-tracker.

Kontaktlista uppdateras inför MVP-lansering. Tills dess är ensam ansvarig kontaktperson projektägaren.

## 11. Slutsats och beslut <a name="slutsats"></a>

Denna DPIA visar att behandlingen i Matdata 2.0 **kan genomföras** under förutsättning att:

* Alla mitigerande åtgärder i avsnitt 8 är implementerade innan publik lansering.
* Samtyckes-flödet för crowdsourcing är testat och granskat.
* Incidenthanteringsprocessen är dokumenterad och kontaktlista är aktuell.
* Anonymiseringslogiken har enhetstester och kodgranskas av minst en oberoende granskare.
* Användarrättigheterna i avsnitt 9 har funktionalitet på plats senast vid publik lansering.

**Behov av förhandssamråd med IMY:** Bedöms inte vara nödvändigt baserat på den planerade arkitekturen, eftersom riskerna mitigieras till acceptabel nivå. Bedömningen revideras om scopet utökas (t.ex. om hälsodata samlas in explicit eller om profilering aktiveras).

## 12. Revisionshistorik <a name="historik"></a>

| Version | Datum | Beskrivning |
| --- | --- | --- |
| 1.0 | 2026-06-29 | Initial DPIA upprättad som del av förstudien. |
