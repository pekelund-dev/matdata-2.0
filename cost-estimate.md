# Kostnadsuppskattning: Matdata 2.0

**Version:** 1.0
**Senast uppdaterad:** 2026-06-29
**Status:** Förstudie klar för granskning

Detta dokument beskriver förväntade kostnader för Matdata 2.0 under MVP-fasen och de första 12 månaderna efter lansering. Siffrorna är uppskattade utifrån offentliga prislistor som gäller per Q2 2026 och förutsätter region `europe-west1` (Belgien) eller motsvarande närliggande EU-region för dataresidens.

> **Disclaimer:** Faktiska priser kan avvika. Detta dokument är ett underlag för budgetering och uppdateras minst en gång per kvartal. Alla siffror är i SEK och utan moms om inget annat anges.

## Innehåll
- [1. Antaganden om trafik och volym](#antaganden)
- [2. Kostnadsuppskattning per tjänst](#per-tjanst)
- [3. Total uppskattning för MVP](#total-mvp)
- [4. Skalning till 5 000 användare](#skalning)
- [5. Engångskostnader](#engangskostnader)
- [6. Kostnadskontroll och larm](#kontroll)
- [7. Open Source och övrigt](#oss)

## 1. Antaganden om trafik och volym <a name="antaganden"></a>

| Scenario | Aktiva användare/mån | Kvitton/användare/mån | Totala kvitton/mån | PDF-storlek/snitt |
| --- | --- | --- | --- | --- |
| MVP (intern testning) | 5 | 20 | 100 | 150 KB |
| Tidiga användare | 50 | 15 | 750 | 150 KB |
| Lansering | 500 | 10 | 5 000 | 150 KB |
| Tillväxt (12 mån) | 5 000 | 8 | 40 000 | 150 KB |

Varje kvitto antas ge:
* En PDF-fil i Cloud Storage.
* Ett Pub/Sub-meddelande.
* En Parser Service-exekvering (~3 sek CPU och 512 MB RAM).
* Ca 25 rader i `RECEIPT_ITEMS`.
* Ca 25 rader i `GLOBAL_PRICE_POINTS` (om samtycke).

## 2. Kostnadsuppskattning per tjänst <a name="per-tjanst"></a>

### 2.1 Google Cloud Run
Cloud Run prissätts per CPU-vCPU-sekund och GiB-RAM-sekund. Generös free tier (180 000 vCPU-sek + 360 000 GiB-sek per månad).

| Scenario | Cloud Run (core) | Cloud Run (parser) | Total Cloud Run |
| --- | --- | --- | --- |
| MVP | Free tier täcker | Free tier täcker | 0 kr |
| Tidiga användare | Free tier täcker | Free tier täcker | 0 kr |
| Lansering | ~50 kr | ~30 kr | ~80 kr |
| Tillväxt | ~400 kr | ~250 kr | ~650 kr |

### 2.2 Cloud Storage (PDF-lagring)
Standard-bucket i regionen `europe-west1`. ~0,02 USD per GB och månad. Lifecycle policy raderar PDF:er efter 30 dagar (se [non-functional-requirements.md](non-functional-requirements.md) NFR-D1).

| Scenario | Lagrad PDF-volym | Månadskostnad |
| --- | --- | --- |
| MVP | 15 MB | < 1 kr |
| Tidiga användare | 110 MB | < 1 kr |
| Lansering | 750 MB | ~2 kr |
| Tillväxt | 6 GB | ~15 kr |

### 2.3 Google Cloud Pub/Sub
Pub/Sub: 10 GB inkluderat per månad, därefter ~40 öre per GB. Meddelandestorlek bedöms < 1 KB.

| Scenario | Antal meddelanden | Datavolym | Månadskostnad |
| --- | --- | --- | --- |
| MVP | 100 | < 1 MB | 0 kr |
| Tidiga användare | 750 | < 1 MB | 0 kr |
| Lansering | 5 000 | ~5 MB | 0 kr |
| Tillväxt | 40 000 | ~40 MB | 0 kr |

### 2.4 Neon (serverless PostgreSQL)

Neon erbjuder en gratis tier (0,5 GB storage, 191,9 compute hours/mån) och betalplaner från ~19 USD/mån (Launch) som ger 10 GB och autoscaling.

| Scenario | Plan | Storage | Compute hours | Månadskostnad |
| --- | --- | --- | --- | --- |
| MVP | Free | < 100 MB | Låg, < free tier | 0 kr |
| Tidiga användare | Free | < 500 MB | < free tier | 0 kr |
| Lansering | Launch | ~1 GB | Måttlig | ~210 kr (≈ 19 USD) |
| Tillväxt | Scale | ~5 GB | Hög | ~750 kr (≈ 69 USD) |

PR-miljöer skapar databasbranchar. Free tier räcker så länge endast en eller två PR är öppna samtidigt. Om CI/CD-kostnaden blir märkbar: konfigurera kortare branch-livslängd eller dela en testdatabas.

### 2.5 Cloud Logging, Cloud Trace, Cloud Monitoring
GCP:s observabilitetsstack har generös free tier (50 GB Cloud Logging per projekt/mån).

| Scenario | Loggvolym | Månadskostnad |
| --- | --- | --- |
| MVP | < 1 GB | 0 kr |
| Tidiga användare | < 5 GB | 0 kr |
| Lansering | ~10 GB | 0 kr |
| Tillväxt | ~40 GB | 0 kr (under fri tier 50 GB) |

### 2.6 Domän, certifikat och e-post

| Post | Kostnad |
| --- | --- |
| Domän (.se) | ~120 kr/år |
| SSL/TLS | 0 kr (Google-hanterat) |
| Transaktionell e-post (t.ex. Brevo, Resend) | 0 kr för MVP, ~50 kr/mån vid lansering |

### 2.7 GitHub Actions
Free tier täcker fullt ut i public-repo. För private-repo finns gratis kvot (2 000 min/mån för Pro).

## 3. Total uppskattning för MVP <a name="total-mvp"></a>

| Scenario | Månadskostnad (uppskattning) | Årskostnad |
| --- | --- | --- |
| MVP (intern testning) | < 25 kr | ~300 kr |
| Tidiga användare (50 anv) | ~50 kr | ~600 kr |
| Lansering (500 anv) | ~350 kr | ~4 200 kr |

MVP-fasen är extremt kostnadseffektiv tack vare alla gratisnivåer. Den verkliga kostnaden vid lansering avgörs nästan helt av Neons betalplan, som blir nödvändig så snart databasen passerar 0,5 GB eller traffiken når en nivå där free tier:s compute-timmar tar slut.

## 4. Skalning till 5 000 användare <a name="skalning"></a>

Vid 5 000 aktiva användare bedöms månadskostnaden hamna kring 1 500–2 000 kr exkl. moms.

| Post | Månadskostnad |
| --- | --- |
| Cloud Run | ~650 kr |
| Cloud Storage | ~15 kr |
| Pub/Sub | ~10 kr |
| Neon (Scale) | ~750 kr |
| Loggar och observability | ~50 kr |
| E-post | ~150 kr |
| Övrigt (DNS, domän) | ~10 kr |
| **Summa** | **~1 635 kr/mån** |

Denna nivå förutsätter att OCR/Vision-API (krav K17) inte är aktiverat. Om K17 aktiveras tillkommer ~1,50 USD per 1 000 dokument vid Google Cloud Vision OCR, vilket vid 40 000 kvitton/mån blir ~60 USD = ~650 kr/mån.

## 5. Engångskostnader <a name="engangskostnader"></a>

| Post | Uppskattning |
| --- | --- |
| Externa designtimmar (om aktuellt) | 0–10 000 kr |
| Penetrationstest före publik lansering | 15 000–40 000 kr |
| Juridisk granskning av integritetspolicy och villkor | 5 000–10 000 kr |
| Logotyp och varumärke | 0–5 000 kr |

För en hobbyversion eller fullt självgjord version är samtliga engångskostnader 0 kr. För en publik lansering bör penetrationstest och juridisk granskning planeras in.

## 6. Kostnadskontroll och larm <a name="kontroll"></a>

* **GCP budgetlarm:** Sätts till 90 % och 100 % av månadsbudgeten. Larmkanal: e-post.
* **Neon notifikationer:** Aktiveras för storage- och compute-tröskelvärden.
* **Cloud Run max instanser:** Konfigureras (`--max-instances`) för att hindra runaway-skala.
* **Pub/Sub flow control:** Begränsa antal samtidiga meddelanden för att undvika loopar.
* **Lifecycle på Cloud Storage:** Automatisk radering av PDF efter 30 dagar.

Se [risk-register.md](risk-register.md) post **E1** för riskbeskrivningen.

## 7. Open Source och övrigt <a name="oss"></a>

Inga betalda licenser används i MVP. Samtliga ramverk (Spring Boot, Apache PDFBox, Tailwind CSS, HTMX, Thymeleaf) är öppen källkod under tillåtande licenser (Apache 2.0, MIT eller motsvarande).

Om vi i framtiden introducerar betalda komponenter (t.ex. en plats för "Senaste nytt om matpriser" via en datatjänst) ska kostnaderna uppdateras i detta dokument.
