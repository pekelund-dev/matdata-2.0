# UI/UX Vision: Matdata 2.0

## 1. Designfilosofi
* **Mobile-First:** Eftersom användare förmodligen kollar sina matkostnader på språng eller i soffan måste gränssnittet designas för mobilskärmar först. Breda tabeller undviks till förmån för kort och grafer som skalar ner snyggt.
* **App-känsla utan JavaScript-ramverk:** Genom att använda **HTMX** kommer sidbyten och formulärinskickningar, som att söka eller ladda upp kvitto, att ske utan att hela sidan laddas om. Detta ger känslan av en modern Single Page Application (SPA), fast vi renderar HTML via Thymeleaf.
* **Tydligt och luftigt:** Vi använder **Tailwind CSS** med en neutral färgpalett, till exempel mycket vitt, ljusgrått och accentfärger i mjukt grönt för "bra eller billigt" och rött för "dyrt", för att minska kognitiv belastning.

## 2. Kärnvyer och Informationsarkitektur

### 2.1 Dashboard (Hem-vyn)
Detta är det första användaren ser efter inloggning. Fokus ligger på "här och nu" snarare än all historik.

**Intressanta widgets att visa här:**
* **Månadens utgifter:** En stor siffra som visar totalbeloppet hittills denna månad, jämfört med samma datum förra månaden, till exempel "3 450 kr" med en liten grön pil nedåt "↓ -5 %".
* **Kategorinedbrytning (donut-graf):** Visar visuellt var pengarna går, till exempel 30 % mejeri, 25 % kött och fågel, 15 % grönsaker och 10 % godis eller snacks.
* **Senaste kvittona:** En horisontell scroll-lista med de tre senaste uppladdningarna.
* **Ditt personliga inflationsindex:** En unik funktion. Eftersom vi vet exakt vilka varor användaren köper ofta kan vi visa: *"Din standardkorg har blivit 3 % dyrare de senaste 6 månaderna"*.

### 2.2 Kvitto-uppladdningen (Den asynkrona upplevelsen)
Eftersom vår arkitektur skickar PDF:en till en bakgrunds-worker måste UX:en spegla detta snyggt.

* **Drag and drop eller välj fil:** En stor, tydlig ruta för att ladda upp PDF från Kivra.
* **Realtids-feedback (via HTMX-polling):**
    1. Användaren laddar upp.
    2. Rutan byts direkt ut mot en laddspinner: *"Laddar upp till molnet..."*
    3. Spinnern ändrar text när Pub/Sub jobbar: *"Extraherar EAN-koder och priser..."*
    4. Klart. En snygg konfettianimation i CSS och en sammanfattning: *"Kvitto från ICA Maxi analyserat! 34 varor hittades. Klicka här för att se detaljer."*

### 2.3 Produktsök & Prishistorik (Hjärtat i appen)
När användaren letar efter en specifik vara, till exempel "Blandfärs".

* **Sök med auto-complete:** När användaren skriver "färs" skickar HTMX direkt en sökning till databasen och visar förslag, exempelvis Svensk Nötfärs 12 % eller Blandfärs 500 g, i en rullgardinsmeny direkt under sökfältet.
* **Produktsidan:**
    * **Linjegraf:** Visar prisets utveckling över tid.
    * **Varningsflagg för krympflation:** Om systemet ser att EAN-koden är densamma, men vikten plötsligt gått från 500 g till 450 g och priset är detsamma, visas en tydlig varningsikon: *"Varning: Förpackningsstorleken har minskat, vilket ger ett högre kilopris!"*
    * **Bästa köpmånad:** Historisk data kan visa, om användaren laddat upp data länge, *"Du brukar köpa denna billigast i januari"*.

### 2.4 Kvitto-detaljvy
När man klickar på ett specifikt historiskt kvitto.
* Istället för en tråkig lista visas kvittot rad för rad, men varje rad har en färgkodning:
    * Grön prick: "Du köpte denna billigare än ditt snittpris."
    * Röd prick: "Du betalade mer än vanligt för denna."
* Denna vy gör det roligt att se vilka klipp man gjorde på just den inköpsrundan.

### 2.5 Tematiska analysvyer (t.ex. "Moms-kollen")
Systemet bör ha stöd för tillfälliga eller tematiska vyer baserade på aktuella händelser i samhället för att driva engagemang. Ett perfekt exempel för appens lansering är den nyliga momssänkningen på livsmedel.

* **Effekten av momssänkningen:** En dedikerad insiktsvy där användaren får svar på frågan *"Sänkte min butik verkligen priserna?"*
    * Vyn jämför snittpriset på användarens 20 vanligaste varor *före* ett specifikt datum, när momsen sänktes, mot priset *efter*.
    * **Tydlig visuell feedback:**
        * Tumme upp (grön): *"ICA Maxi sänkte priset på kaffe med exakt motsvarande moms."*
        * Varningstriangel (röd): *"Varning! Priset på Prästost är oförändrat sedan momssänkningen – butiken har behållit marginalen."*
* **Framtidssäkring:** Även om denna specifika vy fasas ut när momssänkningen blivit det nya normala etablerar den ett tekniskt och designmässigt mönster för att snabbt kunna bygga nya kampanjvyer i framtiden.

## 3. UI-komponenter (Tailwind & HTMX-exempel)
För att hålla utvecklingen snabb bör vi bygga återanvändbara Thymeleaf-fragment.

* **Stat-card (statistikkort):** Runda hörn, subtil skugga och stor tydlig siffra. Används på dashboarden.
* **HTMX-sökfält:** Sökrutan använder hx-get="/api/search" och hx-trigger="keyup changed delay:500ms" så att sökningen sker mjukt en halv sekund efter att användaren slutat skriva.

## 4. Gamification (För framtiden)
För att få användaren att *vilja* ladda upp kvitton kan man lägga in små belöningselement:
* **Månadens sparare:** "Du köpte 80 % av dina varor på extrapris denna månad!"
* **Miljöhjälte (om data finns):** "Du minskade ditt inköp av rött kött med 15 % jämfört med förra månaden."


## 5. Design System & Prompter

### 5.1 Navigationsstruktur och Vyer
Eftersom vi bygger "Mobile-First" används ett klassiskt app-upplägg med en **bottennavigation** (Bottom Navigation Bar) på mobil, som övergår till en **sidomeny** (Sidebar) på desktop.

#### Huvudvyer (Kopplade till navigationen)
1. **📊 Översikt (Dashboard):** Startskärmen. Innehåller widgets (Månadens utgift, Moms-kollen, Senaste kvitton).
2. **🔍 Sök & Jämför:** För att söka fram specifika produkter, se prishistorik och krympflationsvarningar.
3. **🧾 Kvitton:** En listvy över alla uppladdade kvitton. Klickar man på ett kvitto kommer man till en detaljvy.
4. **👤 Profil/Inställningar:** Hantera konto, exportera data.

#### Flytande Huvudåtgärd (FAB – Floating Action Button)
* **➕ Ladda upp kvitto:** En framträdande knapp (ofta centrerad i bottenmenyn) som öppnar en modal eller bottom-sheet för att ladda upp PDF.

---

### 5.2 Komponentkatalog (Design System)
För att appen ska kännas enhetlig måste vi ha en katalog av återanvändbara Thymeleaf-fragment. Dessa är byggstenarna:

* **Typografi & Färger:**
    * Bakgrund: Mycket ljus grå (`bg-gray-50`).
    * Kort & Tabeller: Rent vita (`bg-white`) med subtila skuggor (`shadow-sm`) och rundade hörn (`rounded-xl` eller `rounded-2xl`).
    * Semantiska färger: Mjuk grön för prissänkning eller bra (`text-emerald-600`, `bg-emerald-50`), mjuk röd för prisökning eller dåligt (`text-rose-600`, `bg-rose-50`).
* **Kort (Cards):**
    * *Stat Card:* För "Månadens utgifter".
    * *Item Card:* För enskilda varor i en lista.
* **Datapresentation:**
    * *Tabeller:* Moderna, luftiga tabeller för struktur (utan Excel-känsla).
    * *Diagram:* Behållare för Chart.js-grafer.
* **Knappar:** Primary (fylld), Secondary (kantlinje), Ghost (endast text eller ikon).
* **Badges/Etiketter:** Små piller-formade taggar, till exempel "Krympflation!", "-5 %".
* **Formulär:** Sökfält med förstorningsglas, drag-and-drop-ruta för filuppladdning.
* **Feedback & Modaler:**
    * *Toasts/Notiser:* Små flytande meddelanden för framgång eller fel, till exempel "Kvitto uppladdat".
    * *Modaler/Pop-ups:* För bekräftelser, till exempel "Är du säker på att du vill radera?" med en mörk overlay bakom.

---

### 5.3 Prompter för AI-designverktyg (Stitch / v0)

*Instruktion: Använd dessa prompter i sekvens i ditt designverktyg. Genom att börja med basen och sedan bygga vyer utifrån den får du ett mycket mer konsekvent resultat.*

#### Prompt 1: Grundläggande layout (App Shell)
**Syfte:** Skapa skalet som alla andra vyer ska leva inuti.

> **Prompt:**
> "Create an application shell for a mobile-first web app called 'Matdata'. The tech stack I will use later is Thymeleaf and HTMX, so please generate ONLY plain HTML with Tailwind CSS utility classes. No React, no Vue.
>
> **Design Guidelines:**
> - Background: `bg-gray-50`.
> - Use a clean, modern, airy aesthetic with rounded corners (`rounded-2xl` for large elements) and subtle shadows (`shadow-sm`).
> - Primary color should be a modern indigo or slate.
>
> **Layout Requirements:**
> - Mobile: A fixed Bottom Navigation Bar with 4 icons (Home, Search, Receipts, Profile) and a prominent 'floating' Upload button in the middle.
> - Desktop: The bottom nav should transform into a left-side vertical sidebar.
> - A top header containing the app title and a user avatar.
> - A main content area in the middle. Please fill the content area with a placeholder text saying 'Content goes here'."

#### Prompt 2: Komponentkatalogen (Kitchen Sink)
**Syfte:** Få alla knappar, kort, tabeller, input-fält, modaler och notiser designade i samma stil.

> **Prompt:**
> "Based on the aesthetic of the app shell, create a 'Component Catalog' page inside the main content area. This will serve as my design system. Generate plain HTML with Tailwind CSS.
>
> Please include the following elements, clearly separated by headings:
> 1. **Typography:** H1, H2, H3 and paragraph text.
> 2. **Buttons:** Primary (filled), Secondary (outline), and Danger. All should have nice hover states.
> 3. **Badges:** Small rounded pills for status. I need a 'Success/Cheaper' badge (green tones), a 'Danger/More Expensive' badge (red tones), and a 'Warning' badge.
> 4. **Inputs:** A clean search bar with a search icon inside it, and a standard text input.
> 5. **Cards:** A 'Stat Card' (showing a title like 'Total Month', a big number, and a small trend indicator like '+2%').
> 6. **List Item:** A row component for a grocery item showing the item name, weight, and price aligned to the right.
> 7. **Data Table:** A clean, modern table for displaying structured data. Use ample padding (`p-4`), a subtle background color for the header row (`bg-gray-50`), very light borders between rows (`border-b border-gray-100`), and a subtle hover effect on rows. Wrap the entire table inside a white card with rounded corners and a shadow.
> 8. **Chart Container:** A container card designed to hold a data chart. Include a title area, a large gray placeholder box representing the chart area, and a custom legend area below it.
> 9. **Modals & Overlays:** A standard confirmation modal dialog (white card, rounded corners, shadow) appearing to float over a semi-transparent dark overlay (`bg-black/50`). Include a title, warning text, and 'Cancel'/'Confirm' buttons.
> 10. **Toasts/Notifications:** A small floating snackbar/toast notification positioned at the bottom, with a success icon, the text 'Receipt successfully uploaded', and a close 'x' button."

#### Prompt 3: Dashboard & Moms-kollen
**Syfte:** Skapa startskärmen baserat på UX-visionerna i avsnitt 2.

> **Prompt:**
> "Now, replace the content area with the 'Dashboard' view. Use the components we defined earlier. Generate plain HTML with Tailwind CSS.
>
> **The Dashboard needs the following sections, stacking vertically on mobile:**
> 1. A welcome message 'Hej [Name]!'.
> 2. Two 'Stat Cards' side by side (or stacked on very small screens): One for 'Månadens utgifter' (Month's expenses) and one for 'Ditt Inflationsindex' (Your inflation index).
> 3. A special thematic card called 'Moms-kollen' (The VAT Checker). This card should have a slightly different, attention-grabbing background (maybe a very subtle gradient). Inside it, show a quick summary like 'ICA Maxi has lowered prices on 15 of your top 20 items'. Add a button saying 'Se hela analysen'.
> 4. A 'Senaste kvittona' (Recent receipts) section. Show a simple list of 3 receipt items (Store name, Date, Total Amount)."

#### Prompt 4: Sök och Prishistorik (Detaljvy produkt)
**Syfte:** Designa vyn där man ser prishistorik för en specifik vara och krympflationsvarningen.

> **Prompt:**
> "Create a 'Product Detail' view for a specific grocery item (e.g., 'Svensk Blandfärs 500g'). Generate plain HTML with Tailwind CSS.
>
> **Elements needed:**
> 1. A prominent back button at the top.
> 2. The Product Name as a large heading, with the current best price below it.
> 3. A 'Shrinkflation Warning' banner (using amber/yellow colors and an alert icon). The text should say 'Varning: Förpackningen har minskat från 500g till 450g men priset är detsamma.'
> 4. Place the 'Chart Container' component here (for the price history graph).
> 5. Place the 'Data Table' component below the chart to display the historical purchases of this item in detail (Columns: Date, Store, Quantity, Price). Use the green/red badges in the Price column to indicate if it was a good deal."

#### Prompt 5: Kvitto-uppladdning (Asynkrona statusar)
**Syfte:** Få HTML för uppladdningsrutan i dess olika HTMX-tillstånd.

> **Prompt:**
> "Finally, I need the UI for the Receipt Upload modal/area. Since I am using HTMX to poll the server, I need three distinct UI states. Please provide the HTML/Tailwind for all three states, stacked on top of each other so I can see them.
>
> **State 1: Upload Prompt.** A drag-and-drop zone with a dashed border, an upload icon, and text saying 'Välj PDF-kvitto från Kivra'.
> **State 2: Processing (Loading).** The dashed box is replaced by a centered loading spinner (you can use an SVG or Tailwind animation) and the text 'Extraherar priser...'.
> **State 3: Success.** A green checkmark icon, confetti-like aesthetic (just visually happy), and text saying 'Klart! 34 varor sparade.' with a button 'Se kvittot'."

---

### 5.4 Arbetsflöde och Implementation

#### 5.4.1 Integration via MCP (Model Context Protocol)
Istället för att manuellt klippa och klistra ut HTML från designverktyg (som Stitch eller v0) används kodningsagenter (t.ex. GitHub Copilot, Cursor eller Cline) anslutna via MCP.

**Arbetsgång:**
1. Generera designen i Stitch med prompterna ovan.
2. I din lokala IDE ber du agenten: *"Läs in UI:t för Dashboarden från Stitch via din MCP-anslutning."*
3. Ge direktivet: *"Konvertera HTML-koden till Thymeleaf. Lägg layout-skalet i `layout.html`, extrahera alla återanvändbara komponenter (kort, knappar) till `fragments/components.html` och skapa vyn `dashboard.html`."*
4. Agenten gör grovjobbet och mappar automatiskt in korrekta Tailwind-klasser och Thymeleaf-taggar (`th:fragment`, `th:replace`).

#### 5.4.2 Levande komponentöversikt ("Kitchen Sink")
För att bibehålla kontrollen över designsystemet byggs "Prompt 2" in som en levande vy i applikationen under utvecklingstiden.

* **Route:** En specifik kontroller-endpoint, till exempel `GET /dev/styleguide` eller `/dev/components`. Denna route låses ner eller tas bort i produktionsmiljön.
* **Syfte:** Vyn importerar och renderar *alla* Thymeleaf-fragment från `components.html` på en lång scrollbar sida.
* **Fördel:** Du kan visuellt inspektera hur alla knappar, tabeller och pop-ups renderas lokalt i den sanna Java-miljön. Det gör det också extremt smidigt att testa HTMX-interaktioner, till exempel klicka på "Visa Toast", isolerat innan de integreras i mer komplex affärslogik.
