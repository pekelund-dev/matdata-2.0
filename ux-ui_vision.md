# UI/UX-vision: Matdata 2.0

| Metadata | |
| --- | --- |
| Version | 1.0 |
| Senast uppdaterad | 2026-06-29 |
| Status | Förstudie klar för granskning |
| Plats i dokumentationen | Användarcentrerad design och designsystem. |

> Detta dokument beskriver designvisionen och tillhörande personas, användarresor och designsystem. För övriga dokument, se [README.md](README.md).

## Innehåll
- [1. Designfilosofi och personas](#filosofi)
- [2. Kärnvyer och informationsarkitektur](#vyer)
- [3. Designsystem och komponentkatalog](#designsystem)
- [4. Användarresor (user journeys)](#resor)
- [5. Empty states, fel och edge cases](#states)
- [6. Accessibility (WCAG 2.1 AA)](#accessibility)
- [7. Gamification (för framtiden)](#gamification)
- [8. AI-prompter för designverktyg](#prompts)
- [9. Arbetsflöde och implementation](#workflow)

## 1. Designfilosofi och personas <a name="filosofi"></a>

### 1.1 Designfilosofi
* **Mobile-First:** Eftersom användare förmodligen kollar sina matkostnader på språng eller i soffan måste gränssnittet designas för mobilskärmar först. Breda tabeller undviks till förmån för kort och grafer som skalar ner snyggt.
* **App-känsla utan JavaScript-ramverk:** Genom att använda **HTMX** sker sidbyten och formulärinskickningar (söka, ladda upp kvitto) utan att hela sidan laddas om. Detta ger känslan av en modern Single Page Application (SPA), fast vi renderar HTML via Thymeleaf (se ADR-005 i [open-decisions.md](open-decisions.md)).
* **Tydligt och luftigt:** Vi använder **Tailwind CSS** med en neutral färgpalett: mycket vitt, ljusgrått och accentfärger i mjukt grönt för \"bra eller billigt\" och rött för \"dyrt\", för att minska kognitiv belastning.
* **Performance-first:** TTFB < 500 ms (p95) och HTMX-svar < 100 ms (p95), se [non-functional-requirements.md](non-functional-requirements.md) NFR-P1 och NFR-P3.
* **Privacy-first:** Inga cookie-banners, ingen klientsideanalys, ingen extern spårning. Se [gdpr.md](gdpr.md) avsnitt 5.3 (\"Zero Annoyance\").

### 1.2 Designprinciper
| Princip | Vad det betyder i praktiken |
| --- | --- |
| **Datatransparens** | Användaren ska alltid förstå vad som händer med deras data. Tydliga indikatorer på vad som är personligt vs. anonymiserat. |
| **Återkoppling** | Varje åtgärd ger omedelbar visuell återkoppling. Asynkrona processer (PDF-parsning) visar tydlig progress. |
| **Minimal kognitiv last** | En primär åtgärd per vy. Inga gömda menyer på första nivån. |
| **Felförlåtelse** | Destruktiva åtgärder (radering) kräver bekräftelse. Möjlighet att ångra inom rimlig tid. |
| **Konsekvens** | Samma mönster för samma syfte. Färgkodning och ikoner är konsekventa i hela appen. |

### 1.3 Inkludering
* WCAG 2.1 AA-konformans (NFR-AC1).
* Stöd för skärmläsare (NVDA, VoiceOver) på huvudflödena.
* Respekt för `prefers-reduced-motion` (NFR-AC6) — konfetti-animation stängs då av.

### 1.4 Tonalitet och språk
* Svenska som primärspråk (NFR-I2). Klarspråk utan jargong.
* Vänlig, hjälpsam ton — som en kunnig vän, inte en bank.
* Inga moralpekpinnar (\"du borde köpa billigare\"). Faktabaserat: *\"Den här veckan kostade din standardkorg X kr.\"*

### 1.5 Personas
Tre primära personas guidar designen.

#### Persona 1 — Anna, 38, projektledare
> *\"Jag har 2 barn och tycker priserna i mataffären känns ologiska. Jag vill se vad jag faktiskt betalar för varor jag köper varje vecka, så jag kan välja en annan butik om det skiljer mycket.\"*

* **Beteende:** Laddar upp kvitton från Kivra på söndagskvällen efter veckostorhandling.
* **Mål:** Se totalkostnad per månad, jämföra månader, se prisutveckling på \"standardkorgen\".
* **Frustrationer:** ICA:s app visar inte historiska priser. Klagar på \"dolda prishöjningar\".
* **Tekniknivå:** Hög. Använder bankappar dagligen.

#### Persona 2 — Markus, 29, utvecklare
> *\"Jag är intresserad av data och optimering. Jag vill ha kontroll på min ekonomi ner på radnivå och bidra till öppen statistik som motverkar grumliga prishöjningar.\"*

* **Beteende:** Tidig adopter. Laddar upp varje kvitto direkt. Aktiverar crowdsourcing.
* **Mål:** Råddata via exportfunktion. Visualisera trender. Bidra till global statistik.
* **Frustrationer:** Slutna ekosystem (butiksappar). Datainlåsning.
* **Tekniknivå:** Mycket hög.

#### Persona 3 — Sofia, 52, ekonomichef i hushållet
> *\"Jag vill se till att vi inte slösar pengar. Om Coop är billigare på mejeri men ICA på frukt, vill jag veta det.\"*

* **Beteende:** Sporadisk uppladdning, främst när hon undrar över en specifik prisförändring.
* **Mål:** Få svar på enkla frågor: \"Har den här varan blivit dyrare?\"
* **Frustrationer:** Komplicerade gränssnitt. Dataspårning utan tydligt värde tillbaka.
* **Tekniknivå:** Medel. Mobil först.

### 1.6 Anti-persona
Användare vi *inte* designar för i MVP:
* Företag som vill spåra inköp för bokföring (annat verktyg).
* Användare som vill ha bankintegration / Open Banking (K18, Won't have).
* Användare utanför Sverige (NFR-I2 — endast svenska i MVP).

## 2. Kärnvyer och informationsarkitektur <a name="vyer"></a>

### 2.1 Dashboard (hem-vyn)
Detta är det första användaren ser efter inloggning. Fokus ligger på \"här och nu\" snarare än all historik.

**Widgets:**
* **Månadens utgifter:** Stor siffra med totalbeloppet hittills denna månad, jämfört med samma datum förra månaden (t.ex. \"3 450 kr ↓ -5 %\").
* **Kategorinedbrytning (donut-graf):** Visar visuellt var pengarna går (t.ex. 30 % mejeri, 25 % kött och fågel, 15 % grönsaker, 10 % godis eller snacks). Datakällan beslutas i ADR-013 (se [open-decisions.md](open-decisions.md)).
* **Senaste kvittona:** En horisontell scroll-lista med de tre senaste uppladdningarna.
* **Ditt personliga inflationsindex:** Eftersom vi vet exakt vilka varor användaren köper ofta kan vi visa: *\"Din standardkorg har blivit 3 % dyrare de senaste 6 månaderna.\"*

**Empty state:** Om användaren ännu inte laddat upp något kvitto, visas en illustration och tydlig CTA \"Ladda upp ditt första kvitto\".

### 2.2 Kvitto-uppladdningen (asynkron upplevelse, K12)
Eftersom arkitekturen skickar PDF:en till en bakgrunds-worker måste UX:en spegla detta snyggt.

* **Drag and drop eller välj fil:** Stor, tydlig ruta för att ladda upp PDF från Kivra. Max 10 MB (NFR-S4).
* **Realtids-feedback (via HTMX-polling, K12):**
    1. Användaren laddar upp.
    2. Rutan byts direkt ut mot en laddspinner: *\"Laddar upp till molnet…\"*
    3. Spinnern ändrar text när Pub/Sub jobbar: *\"Extraherar EAN-koder och priser…\"*
    4. Klart: En subtil bekräftelseanimation (respekterar `prefers-reduced-motion`) och en sammanfattning: *\"Kvitto från ICA Maxi analyserat! 34 varor hittades. Klicka för att se detaljer.\"*
* **Fel:** Om parsning misslyckas visas tydligt felmeddelande: *\"Vi kunde inte läsa kvittot. Kontrollera att det är en PDF från Kivra och försök igen.\"* Med möjlighet att rapportera felet.

### 2.3 Produktsök och prishistorik (hjärtat i appen)
När användaren letar efter en specifik vara, till exempel \"Blandfärs\".

* **Sök med auto-complete (K12, NFR-P4):** När användaren skriver \"färs\" skickar HTMX direkt en sökning till databasen och visar förslag (t.ex. Svensk Nötfärs 12 %, Blandfärs 500 g) i en rullgardinsmeny direkt under sökfältet. Mål: < 200 ms p95.
* **Produktsidan:**
    * **Linjegraf:** Visar prisets utveckling över tid.
    * **Varningsflagg för krympflation (K16):** Om systemet ser att EAN-koden är densamma men vikten plötsligt gått från 500 g till 450 g och priset är detsamma, visas en tydlig varningsikon: *\"Varning: Förpackningsstorleken har minskat, vilket ger ett högre kilopris!\"*
    * **Bästa köpmånad:** Historisk data kan visa, om användaren laddat upp data länge: *\"Du brukar köpa denna billigast i januari.\"*

### 2.4 Tematiska analysvyer (\"Moms-kollen\", K14, K15)
Systemet bör ha stöd för tillfälliga eller tematiska vyer baserade på aktuella händelser i samhället för att driva engagemang. Ett perfekt exempel för appens lansering är momssänkningen på livsmedel.

* **Effekten av momssänkningen:** En dedikerad insiktsvy där användaren får svar på frågan *\"Sänkte min butik verkligen priserna?\"*
    * Vyn jämför snittpriset på användarens 20 vanligaste varor *före* ett specifikt datum (när momsen sänktes) mot priset *efter*.
    * **Tydlig visuell feedback:**
        * Tumme upp (grön): *\"ICA Maxi sänkte priset på kaffe med exakt motsvarande moms.\"*
        * Varningstriangel (röd): *\"Varning! Priset på Prästost är oförändrat sedan momssänkningen — butiken har behållit marginalen.\"*
* **Framtidssäkring:** Även om denna specifika vy fasas ut när momssänkningen blivit det nya normala etablerar den ett tekniskt och designmässigt mönster för att snabbt kunna bygga nya kampanjvyer i framtiden.

### 2.5 Profil och inställningar
Hantering av konto, samtycke och data.

* **Profilinformation:** Namn, e-post (möjlighet att redigera).
* **Samtyckesinställningar:** Toggla för crowdsourcing — tydligt om-knapp, aldrig förkryssad i registreringen. Se [gdpr.md](gdpr.md) avsnitt 8.1.
* **Cookies:** Informativ ruta som visar de 2 nödvändiga cookies (SESSION och XSRF-TOKEN) och förklarar varför de behövs (NFR-D5, [gdpr.md](gdpr.md) avsnitt 5).
* **Exportera mina data:** Knapp som genererar JSON eller CSV med alla användarens data (GDPR Art. 15 och 20).
* **Radera mitt konto:** Knapp som triggar full radering (GDPR Art. 17). Kräver dubbel bekräftelse.

### 2.6 Kvitto-detaljvy
När man klickar på ett specifikt historiskt kvitto.

* Istället för en tråkig lista visas kvittot rad för rad, med färgkodning per rad:
    * Grön prick: \"Du köpte denna billigare än ditt snittpris.\"
    * Röd prick: \"Du betalade mer än vanligt för denna.\"
* Möjlighet att se den ursprungliga PDF:en (om den fortfarande är sparad — default 30 dagar, ADR-008).
* Knapp \"Behåll PDF\" för att opta-in att inte få den raderad (NFR-D1).

## 3. Designsystem och komponentkatalog <a name="designsystem"></a>

### 3.1 Navigationsstruktur
Eftersom vi bygger \"Mobile-First\" används ett klassiskt app-upplägg med en **bottennavigation** (Bottom Navigation Bar) på mobil, som övergår till en **sidomeny** (Sidebar) på desktop.

**Huvudvyer (kopplade till navigationen):**
1. **Översikt (dashboard):** Startskärmen. Innehåller widgets (månadens utgift, Moms-kollen, senaste kvitton).
2. **Sök och jämför:** För att söka fram specifika produkter, se prishistorik och krympflationsvarningar.
3. **Kvitton:** En listvy över alla uppladdade kvitton. Klickar man på ett kvitto kommer man till en detaljvy.
4. **Profil/inställningar:** Hantera konto, samtycke, exportera data, radera konto.

**Flytande huvudåtgärd (FAB):**
* **Ladda upp kvitto:** En framträdande knapp (centrerad i bottenmenyn) som öppnar en modal eller bottom-sheet för att ladda upp PDF.

### 3.2 Typografi och färger
* Bakgrund: Mycket ljus grå (`bg-gray-50`).
* Kort och tabeller: Rent vita (`bg-white`) med subtila skuggor (`shadow-sm`) och rundade hörn (`rounded-xl` eller `rounded-2xl`).
* Semantiska färger:
    * Mjuk grön för prissänkning eller bra (`text-emerald-600`, `bg-emerald-50`).
    * Mjuk röd för prisökning eller dåligt (`text-rose-600`, `bg-rose-50`).
* **Färgkontrast:** Alla textfärger ska uppnå ≥ 4,5:1 mot bakgrund för normaltext (NFR-AC2).

### 3.3 Komponentkatalog (Thymeleaf-fragment)
För att appen ska kännas enhetlig måste vi ha en katalog av återanvändbara Thymeleaf-fragment (K11). Komponenterna renderas i `/dev/components` (se avsnitt 9.2).

| Kategori | Komponent | Användning |
| --- | --- | --- |
| **Kort** | `stat-card` | Stor siffra + trend (\"Månadens utgifter\") |
| | `item-card` | Enskild vara i lista |
| | `chart-card` | Container för Chart.js-graf |
| **Knappar** | `btn-primary` | Huvudåtgärd (fylld) |
| | `btn-secondary` | Sekundär (kantlinje) |
| | `btn-ghost` | Tertiär (endast text/ikon) |
| | `btn-danger` | Destruktiv åtgärd (radering) |
| **Etiketter** | `badge-success` | \"-5 %\" (grön) |
| | `badge-danger` | \"+12 %\" (röd) |
| | `badge-warning` | \"Krympflation!\" (gul/röd) |
| **Datapresentation** | `table` | Modern, luftig tabell |
| | `chart-line` | Linjegraf för prishistorik |
| | `chart-donut` | Donut för kategorinedbrytning |
| **Formulär** | `search-input` | Sökfält med ikon |
| | `file-drop` | Drag-and-drop för uppladdning |
| **Feedback** | `toast-success` | Flytande \"Kvitto uppladdat\" |
| | `toast-error` | Flytande felmeddelande |
| | `modal-confirm` | Bekräftelsemodal med overlay |
| **HTMX-fragment** | `hx-loader` | Spinner för asynkrona laddningar |
| | `hx-result` | Container för HTMX-svar |

### 3.4 HTMX-mönster
* **Sök:** `hx-get=\"/api/search\"` och `hx-trigger=\"keyup changed delay:500ms\"` så att sökningen sker en halv sekund efter att användaren slutat skriva.
* **Polling vid uppladdning:** `hx-get=\"/api/receipts/{id}/status\"` med `hx-trigger=\"every 2s\"` tills statusen är `COMPLETED`.
* **CSRF:** Alla HTMX-anrop måste skicka `X-XSRF-TOKEN`-header (NFR-SEC3).

## 4. Användarresor (user journeys) <a name="resor"></a>

### 4.1 Resa: \"Första gången användare\"
**Persona:** Anna (38, projektledare).

1. **Upptäckt:** Hittar appen via en blogg om hushållsekonomi.
2. **Registrering:** Klickar \"Skapa konto\". Anger e-post och lösenord. **Samtycke** för crowdsourcing är inte förkryssat (se [gdpr.md](gdpr.md) avsnitt 8.1).
3. **Onboarding:** Välkomstvy förklarar i 3 steg hur appen funkar.
4. **Första uppladdningen:** Öppnar Kivra på mobilen, exporterar ICA-kvitto som PDF, laddar upp via Matdata.
5. **Vänteläge:** Ser HTMX-spinner: \"Extraherar priser…\" (max 30 s p95, NFR-P2).
6. **Bekräftelse:** \"34 varor hittades.\" Klickar för att se sitt första kvitto.
7. **Dashboard:** Dashboard visar fortfarande \"Ladda upp fler kvitton för att se trender\" tills minst 3 kvitton finns.

### 4.2 Resa: \"Jag undrar varför kaffet kostar mer\"
**Persona:** Sofia (52).

1. **Trigger:** Sofia tycker kaffet känns dyrt.
2. **Sök:** Klickar på söksymbolen och skriver \"kaffe\". HTMX visar autocomplete-förslag direkt.
3. **Produktsida:** Väljer sitt vanliga kaffe. Ser linjegraf: pris stigit 12 % över 6 månader.
4. **Krympflations-varning:** Ser tydligt: *\"Förpackningen minskade från 500 g till 450 g i mars.\"*
5. **Slutsats:** Sofia delar resultatet med sin partner. Bestämmer sig för att testa annat märke nästa gång.

### 4.3 Resa: \"Aktivera crowdsourcing\"
**Persona:** Markus (29, utvecklare).

1. **Trigger:** Markus läste om K13 i appens dokumentation.
2. **Profil:** Går till `/profile`.
3. **Samtycke:** Togglar \"Dela mina priser anonymt för att hjälpa andra\".
4. **Bekräftelse:** Modal som tydligt förklarar vad som delas (artikelnummer, pris, ort, månad) och vad som *inte* delas (specifik butik, exakt tid, kvittots inköpskorg). Se [gdpr.md](gdpr.md) avsnitt 2.2.
5. **Klart:** Toast: \"Tack! Dina framtida kvitton bidrar nu till global statistik.\"

### 4.4 Resa: \"Radera mitt konto\" (GDPR Art. 17)
**Persona:** Anna, men nu med nytt jobb och vill inte längre använda Matdata.

1. **Profil:** Går till `/profile`.
2. **Knapp \"Radera mitt konto\":** Tydligt placerad längst ned, röd.
3. **Bekräftelse 1:** Modal förklarar vad som händer (konto + kvitton raderas, anonym statistik finns kvar enligt ADR-007). Användaren måste skriva \"RADERA\" för att bekräfta.
4. **Bekräftelse 2:** Slutmodal: \"Är du säker?\"
5. **Genomförande:** Systemet kör `ON DELETE CASCADE`, raderar PDF:er i Cloud Storage, skriver till audit-loggen.
6. **Bekräftelse på mejl:** Mejl skickas med bekräftelse på radering.

### 4.5 Resa: \"Exportera mina data\" (GDPR Art. 15 + 20)
1. Profil → \"Exportera min data\".
2. Välj format: JSON eller CSV.
3. Spara filen (download i webbläsaren).

## 5. Empty states, fel och edge cases <a name="states"></a>

Tydliga empty states och felhantering är avgörande för upplevelsen. Varje vy ska ha en tydlig empty state, en laddnings-state och en fel-state.

### 5.1 Empty states

| Vy | Empty state-meddelande | CTA |
| --- | --- | --- |
| Dashboard | \"Välkommen! Ladda upp ditt första kvitto för att se trender.\" | \"Ladda upp kvitto\" |
| Kvitton | \"Inga kvitton än. Det går snabbt att börja!\" | \"Ladda upp kvitto\" |
| Sök | \"Sök bland dina varor eller den globala statistiken.\" | (söksuggestions) |
| Produktdetalj | \"Bara ett köp än så länge. Ladda upp fler kvitton för att se trender.\" | — |
| Moms-kollen | \"Du behöver kvitton från före och efter momssänkningen för att vi ska kunna jämföra.\" | \"Ladda upp äldre kvitto\" |

### 5.2 Fel-states

| Fel | Visning | Användarens åtgärd |
| --- | --- | --- |
| Nätverksfel | Toast: \"Det gick inte att kontakta servern. Försök igen.\" | Retry-knapp |
| PDF kunde inte läsas | Toast + felruta: \"Vi kunde inte läsa kvittot. Är det en PDF från Kivra?\" | \"Försök igen\" eller \"Rapportera\" |
| Ogiltig PDF-storlek (> 10 MB) | Felmeddelande direkt i uppladdningsrutan: \"PDF är för stor (max 10 MB).\" | Ladda upp annan fil |
| Parsing tar > 30 s | Status: \"Det tar lite längre tid än vanligt. Du kan stänga sidan och kolla senare.\" | — |
| Inloggning misslyckas | Felmeddelande under formuläret: \"Fel e-post eller lösenord.\" Rate limiting efter 5 försök (NFR-SEC10). | Återställ lösenord (post-MVP) |
| Sessionen har gått ut | Auto-redirect till login med toast: \"Du behöver logga in igen.\" | Logga in |
| 404 (sida finns inte) | Egen 404-sida med länk till dashboard | \"Tillbaka till start\" |
| 500 (serverfel) | Egen 500-sida med kontaktlänk | \"Försök igen om en stund\" |

### 5.3 Edge cases
* **Kvitto utan datum:** Om PDF saknar inköpsdatum, prompta användaren att ange det manuellt.
* **Kvitto med duplicerat innehåll:** Systemet upptäcker dubblettuppladdning baserat på filhash. Visar \"Detta kvitto är redan uppladdat.\"
* **Användare med 0 samtycke:** Crowdsourcing-vyer (K14) visar en informationsruta som förklarar varför ingen data syns för dem och hur de kan aktivera samtycke.
* **Långsam nätverksanslutning:** Skeleton screens (placeholder-block med animation) under inläsning av dashboard.

## 6. Accessibility (WCAG 2.1 AA) <a name="accessibility"></a>

Matdata 2.0 ska uppfylla WCAG 2.1 AA (NFR-AC1). Detta avsnitt beskriver de praktiska riktlinjerna.

### 6.1 Generella krav
* **Semantisk HTML:** Använd korrekt elementtyp (`<button>`, `<nav>`, `<main>`, `<article>`) istället för generiska `<div>` (NFR-AC4).
* **Landmark-struktur:** Varje sida har korrekt `<header>`, `<main>`, `<nav>`, `<footer>`.
* **Skip links:** Hopp till huvudinnehåll-länk högst upp på varje sida.
* **Tangentbordsnavigering:** Alla interaktiva element ska kunna nås och aktiveras med tangentbord (NFR-AC3). Tab-ordningen ska vara logisk.
* **Fokusindikator:** Tydlig synlig fokus-ring (`focus-visible` med tjock ring i kontrastfärg).
* **Färgkontrast:** ≥ 4,5:1 för normaltext, ≥ 3:1 för stor text (NFR-AC2).

### 6.2 Skärmläsare
* Alla bilder har `alt`-attribut. Dekorativa bilder har `alt=\"\"`.
* Ikoner med funktion har `aria-label` (t.ex. `<button aria-label=\"Stäng modal\">×</button>`).
* Formulärfält har associerade `<label>`-element.
* Felmeddelanden använder `aria-live=\"polite\"` så att skärmläsare läser upp dem.
* Modaler använder `role=\"dialog\"` och `aria-modal=\"true\"`.
* Manuellt test med NVDA eller VoiceOver för huvudflöden (NFR-AC5).

### 6.3 HTMX-tillgänglighet
* Vid HTMX-uppdateringar: använd `hx-swap-oob=\"true\"` för att uppdatera ARIA live-regioner.
* Spinners ska ha `role=\"status\"` och `aria-live=\"polite\"`.
* Auto-complete-listor använder `role=\"listbox\"` och pilarna ska kunna navigeras med tangentbord.

### 6.4 Rörelse och animation
* Konfetti- och slide-animationer respekterar `prefers-reduced-motion` (NFR-AC6).
* Inga animationer som blinkar mer än 3 gånger per sekund (epilepsi-skydd).

### 6.5 Test och verifiering
* `axe-core` eller `pa11y` körs i CI (NFR-AC4). Verktygsval beslutas i ADR-014 ([open-decisions.md](open-decisions.md)).
* Manuell granskning av huvudflöden med skärmläsare innan publik lansering.
* WCAG-audit av extern part innan lansering.

## 7. Gamification (för framtiden) <a name="gamification"></a>

För att få användaren att *vilja* ladda upp kvitton kan man lägga in små belöningselement (post-MVP):

* **Månadens sparare:** \"Du köpte 80 % av dina varor på extrapris denna månad!\"
* **Miljöhjälte (om data finns):** \"Du minskade ditt inköp av rött kött med 15 % jämfört med förra månaden.\"
* **Streaks:** Antal månader i rad med uppladdade kvitton.
* **Crowdsourcing-bidrag:** \"Du har bidragit med 234 prispunkter till global statistik.\"

**Viktigt:** Inga gamification-element får skapa press eller manipulera användaren. De ska vara informativa, inte tvingande.

## 8. AI-prompter för designverktyg <a name="prompts"></a>

*Instruktion: Använd dessa prompter i sekvens i ditt designverktyg (Stitch, v0 eller motsvarande). Genom att börja med basen och bygga vyer utifrån den får du ett konsekvent resultat.*

### 8.1 Prompt 1: Grundläggande layout (app shell)
**Syfte:** Skapa skalet som alla andra vyer ska leva inuti.

> *Create an application shell for a mobile-first web app called 'Matdata'. The tech stack I will use later is Thymeleaf and HTMX, so please generate ONLY plain HTML with Tailwind CSS utility classes. No React, no Vue.*
>
> *Design Guidelines:*
> *- Background: `bg-gray-50`.*
> *- Use a clean, modern, airy aesthetic with rounded corners (`rounded-2xl` for large elements) and subtle shadows (`shadow-sm`).*
> *- Primary color should be a modern indigo or slate.*
>
> *Layout Requirements:*
> *- Mobile: A fixed Bottom Navigation Bar with 4 icons (Home, Search, Receipts, Profile) and a prominent 'floating' Upload button in the middle.*
> *- Desktop: The bottom nav should transform into a left-side vertical sidebar.*
> *- A top header containing the app title and a user avatar.*
> *- A main content area in the middle. Please fill the content area with a placeholder text saying 'Content goes here'.*

### 8.2 Prompt 2: Komponentkatalogen (kitchen sink)
**Syfte:** Få alla knappar, kort, tabeller, input-fält, modaler och notiser designade i samma stil.

> *Based on the aesthetic of the app shell, create a 'Component Catalog' page inside the main content area. This will serve as my design system. Generate plain HTML with Tailwind CSS.*
>
> *Please include the following elements, clearly separated by headings:*
> *1. Typography: H1, H2, H3 and paragraph text.*
> *2. Buttons: Primary (filled), Secondary (outline), and Danger. All should have nice hover states.*
> *3. Badges: Small rounded pills for status. I need a 'Success/Cheaper' badge (green tones), a 'Danger/More Expensive' badge (red tones), and a 'Warning' badge.*
> *4. Inputs: A clean search bar with a search icon inside it, and a standard text input.*
> *5. Cards: A 'Stat Card' (showing a title like 'Total Month', a big number, and a small trend indicator like '+2%').*
> *6. List Item: A row component for a grocery item showing the item name, weight, and price aligned to the right.*
> *7. Data Table: A clean, modern table for displaying structured data. Use ample padding (`p-4`), a subtle background color for the header row (`bg-gray-50`), very light borders between rows (`border-b border-gray-100`), and a subtle hover effect on rows. Wrap the entire table inside a white card with rounded corners and a shadow.*
> *8. Chart Container: A container card designed to hold a data chart. Include a title area, a large gray placeholder box representing the chart area, and a custom legend area below it.*
> *9. Modals & Overlays: A standard confirmation modal dialog (white card, rounded corners, shadow) appearing to float over a semi-transparent dark overlay (`bg-black/50`). Include a title, warning text, and 'Cancel'/'Confirm' buttons.*
> *10. Toasts/Notifications: A small floating snackbar/toast notification positioned at the bottom, with a success icon, the text 'Receipt successfully uploaded', and a close 'x' button.*

### 8.3 Prompt 3: Dashboard och Moms-kollen
**Syfte:** Skapa startskärmen baserat på UX-visionerna i [avsnitt 2](#vyer).

> *Now, replace the content area with the 'Dashboard' view. Use the components we defined earlier. Generate plain HTML with Tailwind CSS.*
>
> *The Dashboard needs the following sections, stacking vertically on mobile:*
> *1. A welcome message 'Hej [Name]!'.*
> *2. Two 'Stat Cards' side by side (or stacked on very small screens): One for 'Månadens utgifter' (Month's expenses) and one for 'Ditt Inflationsindex' (Your inflation index).*
> *3. A special thematic card called 'Moms-kollen' (The VAT Checker). This card should have a slightly different, attention-grabbing background (maybe a very subtle gradient). Inside it, show a quick summary like 'ICA Maxi has lowered prices on 15 of your top 20 items'. Add a button saying 'Se hela analysen'.*
> *4. A 'Senaste kvittona' (Recent receipts) section. Show a simple list of 3 receipt items (Store name, Date, Total Amount).*

### 8.4 Prompt 4: Sök och prishistorik (detaljvy produkt)
**Syfte:** Designa vyn där man ser prishistorik för en specifik vara och krympflationsvarningen.

> *Create a 'Product Detail' view for a specific grocery item (e.g., 'Svensk Blandfärs 500g'). Generate plain HTML with Tailwind CSS.*
>
> *Elements needed:*
> *1. A prominent back button at the top.*
> *2. The Product Name as a large heading, with the current best price below it.*
> *3. A 'Shrinkflation Warning' banner (using amber/yellow colors and an alert icon). The text should say 'Varning: Förpackningen har minskat från 500g till 450g men priset är detsamma.'*
> *4. Place the 'Chart Container' component here (for the price history graph).*
> *5. Place the 'Data Table' component below the chart to display the historical purchases of this item in detail (Columns: Date, Store, Quantity, Price). Use the green/red badges in the Price column to indicate if it was a good deal.*

### 8.5 Prompt 5: Kvitto-uppladdning (asynkrona statusar)
**Syfte:** Få HTML för uppladdningsrutan i dess olika HTMX-tillstånd.

> *Finally, I need the UI for the Receipt Upload modal/area. Since I am using HTMX to poll the server, I need three distinct UI states. Please provide the HTML/Tailwind for all three states, stacked on top of each other so I can see them.*
>
> *State 1: Upload Prompt. A drag-and-drop zone with a dashed border, an upload icon, and text saying 'Välj PDF-kvitto från Kivra'.*
> *State 2: Processing (Loading). The dashed box is replaced by a centered loading spinner (you can use an SVG or Tailwind animation) and the text 'Extraherar priser...'.*
> *State 3: Success. A green checkmark icon, confetti-like aesthetic (just visually happy), and text saying 'Klart! 34 varor sparade.' with a button 'Se kvittot'.*

## 9. Arbetsflöde och implementation <a name="workflow"></a>

### 9.1 Integration via MCP (Model Context Protocol)
Istället för att manuellt klippa och klistra ut HTML från designverktyg (Stitch, v0) används kodningsagenter (GitHub Copilot, Cursor, Cline) anslutna via MCP.

**Arbetsgång:**
1. Generera designen i Stitch med prompterna i [avsnitt 8](#prompts).
2. I din lokala IDE ber du agenten: *\"Läs in UI:t för Dashboarden från Stitch via din MCP-anslutning.\"*
3. Ge direktivet: *\"Konvertera HTML-koden till Thymeleaf. Lägg layout-skalet i `layout.html`, extrahera alla återanvändbara komponenter (kort, knappar) till `fragments/components.html` och skapa vyn `dashboard.html`.\"*
4. Agenten gör grovjobbet och mappar automatiskt in korrekta Tailwind-klasser och Thymeleaf-taggar (`th:fragment`, `th:replace`).

### 9.2 Levande komponentöversikt (\"Kitchen Sink\", K11)
För att bibehålla kontrollen över designsystemet byggs \"Prompt 2\" in som en levande vy i applikationen under utvecklingstiden.

* **Route:** En specifik kontroller-endpoint, `GET /dev/components`. Denna route låses ner eller tas bort i produktionsmiljön.
* **Syfte:** Vyn importerar och renderar *alla* Thymeleaf-fragment från `components.html` på en lång scrollbar sida.
* **Fördel:** Du kan visuellt inspektera hur alla knappar, tabeller och pop-ups renderas lokalt i den sanna Java-miljön. Det gör det också extremt smidigt att testa HTMX-interaktioner (klicka på \"Visa Toast\") isolerat innan de integreras i mer komplex affärslogik.

### 9.3 Designgranskning innan implementation
Innan en ny vy implementeras ska följande checklist genomgås:

* [ ] Empty state är designad (se [avsnitt 5.1](#states)).
* [ ] Fel-state är designad (se [avsnitt 5.2](#states)).
* [ ] Vyn fungerar på mobil (320 px och uppåt, NFR-BR6).
* [ ] Färgkontrast verifierad (NFR-AC2).
* [ ] Tangentbordsnavigering testad (NFR-AC3).
* [ ] Skärmläsar-genomgång gjord på huvudflödet (NFR-AC5, för publika sidor).
* [ ] Komponenter återanvänds från `/dev/components` istället för att duplicera.
* [ ] HTMX-mönster följer [avsnitt 3.4](#designsystem).

### 9.4 Designbeslut som väntar
Följande designbeslut är öppna och behöver fattas innan Fas 4 startar (se [open-decisions.md](open-decisions.md)):

* **ADR-011:** Val av chart-bibliotek (Chart.js, ECharts eller server-side SVG).
* **ADR-013:** Källa för produktkategorier (för donut-grafen på dashboarden).
* **ADR-014:** Verktyg för accessibility-tester.
