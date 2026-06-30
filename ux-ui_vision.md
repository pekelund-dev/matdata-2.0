# UI/UX vision: Matdata 2.0

| Metadata | |
| --- | --- |
| Version | 1.0 |
| Last updated | 2026-06-29 |
| Status | Pre-study ready for review |
| Place in the documentation | User-centred design and the design system. |

> This document describes the design vision and the associated personas, user journeys and design system. For other documents see [README.md](README.md).

## Contents
- [1. Design philosophy and personas](#philosophy)
- [2. Core views and information architecture](#views)
- [3. Design system and component catalogue](#designsystem)
- [4. User journeys](#journeys)
- [5. Empty states, errors and edge cases](#states)
- [6. Accessibility (WCAG 2.1 AA)](#accessibility)
- [7. Gamification (for the future)](#gamification)
- [8. AI prompts for design tools](#prompts)
- [9. Workflow and implementation](#workflow)

## 1. Design philosophy and personas <a name="philosophy"></a>

### 1.1 Design philosophy
* **Mobile-First:** Because users will probably check their grocery costs on the go or on the sofa, the interface must be designed for mobile screens first. Wide tables are avoided in favour of cards and graphs that scale down nicely.
* **App feel without a JavaScript framework:** By using **HTMX**, page transitions and form submissions (search, upload receipt) happen without reloading the whole page. This gives the feel of a modern Single Page Application (SPA), even though we render HTML via Thymeleaf (see ADR-005 in [open-decisions.md](open-decisions.md)).
* **Clear and airy:** We use **Tailwind CSS** with a neutral colour palette: lots of white, light grey and accent colours in soft green for \"good or cheap\" and red for \"expensive\", to reduce cognitive load.
* **Performance-first:** TTFB < 500 ms (p95) and HTMX responses < 100 ms (p95), see [non-functional-requirements.md](non-functional-requirements.md) NFR-P1 and NFR-P3.
* **Privacy-first:** No cookie banners, no client-side analytics, no external tracking. See [gdpr.md](gdpr.md) section 5.3 (\"Zero Annoyance\").

### 1.2 Design principles
| Principle | What it means in practice |
| --- | --- |
| **Data transparency** | The user should always understand what is happening with their data. Clear indicators of what is personal vs. anonymised. |
| **Feedback** | Every action gives immediate visual feedback. Asynchronous processes (PDF parsing) show clear progress. |
| **Minimal cognitive load** | One primary action per view. No hidden menus at the first level. |
| **Forgiveness for mistakes** | Destructive actions (deletion) require confirmation. Ability to undo within a reasonable time. |
| **Consistency** | The same pattern for the same purpose. Colour coding and icons are consistent throughout the app. |

### 1.3 Inclusion
* WCAG 2.1 AA conformance (NFR-AC1).
* Support for screen readers (NVDA, VoiceOver) on the main flows.
* Respect for `prefers-reduced-motion` (NFR-AC6) — confetti animation is turned off then.

### 1.4 Tone and language
* Swedish as the primary language (NFR-I2). Plain language without jargon.
* Friendly, helpful tone — like a knowledgeable friend, not a bank.
* No moralising (\"you should buy cheaper\"). Fact-based: *\"This week your standard basket cost X kr.\"*

### 1.5 Personas
Three primary personas guide the design.

#### Persona 1 — Anna, 38, project manager
> *\"I have 2 children and feel the prices in the grocery store seem illogical. I want to see what I actually pay for the items I buy every week, so I can choose a different store if there is a big difference.\"*

* **Behaviour:** Uploads receipts from Kivra on Sunday evening after the weekly shop.
* **Goals:** See total cost per month, compare months, see price development on the \"standard basket\".
* **Frustrations:** ICA's app does not show historical prices. Complains about \"hidden price increases\".
* **Tech level:** High. Uses banking apps daily.

#### Persona 2 — Markus, 29, developer
> *\"I am interested in data and optimisation. I want full control of my finances down to the line level and contribute to open statistics that counter murky price increases.\"*

* **Behaviour:** Early adopter. Uploads every receipt immediately. Enables crowdsourcing.
* **Goals:** Raw data via the export function. Visualise trends. Contribute to global statistics.
* **Frustrations:** Closed ecosystems (store apps). Data lock-in.
* **Tech level:** Very high.

#### Persona 3 — Sofia, 52, household CFO
> *\"I want to make sure we are not wasting money. If Coop is cheaper on dairy but ICA on fruit, I want to know.\"*

* **Behaviour:** Sporadic uploads, mainly when she wonders about a specific price change.
* **Goals:** Get answers to simple questions: \"Has this item become more expensive?\"
* **Frustrations:** Complicated interfaces. Data tracking without clear value in return.
* **Tech level:** Medium. Mobile first.

### 1.6 Anti-persona
Users we are *not* designing for in the MVP:
* Companies that want to track purchases for accounting (a different tool).
* Users who want bank integration / Open Banking (K18, Won't have).
* Users outside Sweden (NFR-I2 — Swedish only in the MVP).

## 2. Core views and information architecture <a name="views"></a>

### 2.1 Dashboard (the home view)
This is the first thing the user sees after sign-in. The focus is on \"here and now\" rather than all the history.

**Widgets:**
* **Month's expenses:** Large number with the total so far this month, compared with the same date last month (e.g. \"3 450 kr ↓ -5 %\").
* **Category breakdown (donut chart):** Visually shows where the money goes (e.g. 30 % dairy, 25 % meat and poultry, 15 % vegetables, 10 % sweets or snacks). The data source is decided in ADR-013 (see [open-decisions.md](open-decisions.md)).
* **Latest receipts:** A horizontal scroll list with the three most recent uploads.
* **Your personal inflation index:** Because we know exactly which items the user buys often, we can show: *\"Your standard basket has become 3 % more expensive over the last 6 months.\"*

**Empty state:** If the user has not yet uploaded any receipt, an illustration and a clear CTA \"Upload your first receipt\" are shown.

### 2.2 The receipt upload (asynchronous experience, K12)
Because the architecture sends the PDF to a background worker, the UX must reflect this nicely.

* **Drag-and-drop or choose file:** Large, clear box for uploading the PDF from Kivra. Max 10 MB (NFR-S4).
* **Real-time feedback (via HTMX polling, K12):**
    1. The user uploads.
    2. The box is replaced immediately by a loading spinner: *\"Uploading to the cloud…\"*
    3. The spinner changes text when Pub/Sub is working: *\"Extracting EAN codes and prices…\"*
    4. Done: A subtle confirmation animation (respects `prefers-reduced-motion`) and a summary: *\"Receipt from ICA Maxi analysed! 34 items found. Click to see the details.\"*
* **Error:** If parsing fails, a clear error message is shown: *\"We could not read the receipt. Check that it is a PDF from Kivra and try again.\"* With the option to report the error.

### 2.3 Product search and price history (the heart of the app)
When the user is looking for a specific item, for example \"mince\".

* **Search with autocomplete (K12, NFR-P4):** When the user types \"min\", HTMX immediately sends a search to the database and shows suggestions (e.g. Swedish beef mince 12 %, mixed mince 500 g) in a dropdown directly under the search field. Target: < 200 ms p95.
* **Product page:**
    * **Line chart:** Shows the price development over time.
    * **Shrinkflation warning flag (K16):** If the system sees that the EAN code is the same but the weight has suddenly gone from 500 g to 450 g and the price is the same, a clear warning icon is shown: *\"Warning: The package size has decreased, which means a higher price per kilo!\"*
    * **Best month to buy:** If the user has uploaded data for a long time, historical data can show: *\"You usually buy this most cheaply in January.\"*

### 2.4 Thematic analysis views (\"Moms-kollen\", K15)
The system should support temporary or thematic views based on current events in society to drive engagement. A perfect example for the app's launch is the VAT reduction on food.

* **The effect of the VAT reduction:** A dedicated insight view where the user gets an answer to the question *\"Did my store really lower the prices?\"*
    * The view compares the average price of the user's 20 most common items *before* a specific date (when the VAT was reduced) with the price *after*.
    * **Clear visual feedback:**
        * Thumbs up (green): *\"ICA Maxi lowered the price of coffee by exactly the equivalent of the VAT.\"*
        * Warning triangle (red): *\"Warning! The price of Prästost cheese has not changed since the VAT reduction — the store has kept the margin.\"*
* **Future-proofing:** Even though this specific view will be phased out when the VAT reduction becomes the new normal, it establishes a technical and design pattern for quickly building new campaign views in the future.

### 2.5 Profile and settings
Management of the account, consent and data.

* **Profile information:** Name, e-mail address (with the option to edit).
* **Consent settings:** Toggle for crowdsourcing — a clear on-button, never pre-ticked at registration. See [gdpr.md](gdpr.md) section 8.1.
* **Cookies:** Informative box that shows the 2 necessary cookies (SESSION and XSRF-TOKEN) and explains why they are needed (NFR-D5, [gdpr.md](gdpr.md) section 5).
* **Export my data:** Button that generates JSON or CSV with all the user's data (GDPR Art. 15 and 20).
* **Delete my account:** Button that triggers full deletion (GDPR Art. 17). Requires double confirmation.

### 2.6 Receipt detail view
When you click on a specific historical receipt.

* Instead of a boring list, the receipt is shown line by line, with colour coding per line:
    * Green dot: \"You bought this cheaper than your average price.\"
    * Red dot: \"You paid more than usual for this.\"
* Possibility to view the original PDF (if it is still saved — default 30 days, ADR-008).
* Button \"Keep PDF\" to opt in to not having it deleted (NFR-D1).

## 3. Design system and component catalogue <a name="designsystem"></a>

### 3.1 Navigation structure
Because we build \"Mobile-First\", a classic app layout is used with a **bottom navigation** (Bottom Navigation Bar) on mobile, which becomes a **sidebar** on desktop.

**Main views (linked to the navigation):**
1. **Overview (dashboard):** The start screen. Contains widgets (month's expense, Moms-kollen, latest receipts).
2. **Search and compare:** To find specific products, see price history and shrinkflation warnings.
3. **Receipts:** A list view of all uploaded receipts. Clicking on a receipt takes you to a detail view.
4. **Profile/settings:** Manage the account, consent, export data, delete the account.

**Floating main action (FAB):**
* **Upload receipt:** A prominent button (centred in the bottom menu) that opens a modal or bottom sheet for uploading a PDF.

### 3.2 Typography and colours
* Background: Very light grey (`bg-gray-50`).
* Cards and tables: Pure white (`bg-white`) with subtle shadows (`shadow-sm`) and rounded corners (`rounded-xl` or `rounded-2xl`).
* Semantic colours:
    * Soft green for price reductions or good (`text-emerald-600`, `bg-emerald-50`).
    * Soft red for price increases or bad (`text-rose-600`, `bg-rose-50`).
* **Colour contrast:** All text colours must reach ≥ 4.5:1 against the background for normal text (NFR-AC2).

### 3.3 Component catalogue (Thymeleaf fragments)
For the app to feel uniform we need a catalogue of reusable Thymeleaf fragments (K11). The components are rendered in `/dev/components` (see section 9.2).

| Category | Component | Use |
| --- | --- | --- |
| **Cards** | `stat-card` | Large number + trend (\"Month's expenses\") |
| | `item-card` | A single item in a list |
| | `chart-card` | Container for a Chart.js chart |
| **Buttons** | `btn-primary` | Main action (filled) |
| | `btn-secondary` | Secondary (outline) |
| | `btn-ghost` | Tertiary (text/icon only) |
| | `btn-danger` | Destructive action (deletion) |
| **Labels** | `badge-success` | \"-5 %\" (green) |
| | `badge-danger` | \"+12 %\" (red) |
| | `badge-warning` | \"Shrinkflation!\" (yellow/red) |
| **Data presentation** | `table` | Modern, airy table |
| | `chart-line` | Line chart for price history |
| | `chart-donut` | Donut for category breakdown |
| **Forms** | `search-input` | Search field with icon |
| | `file-drop` | Drag-and-drop for upload |
| **Feedback** | `toast-success` | Floating \"Receipt uploaded\" |
| | `toast-error` | Floating error message |
| | `modal-confirm` | Confirmation modal with overlay |
| **HTMX fragments** | `hx-loader` | Spinner for asynchronous loads |
| | `hx-result` | Container for HTMX responses |

### 3.4 HTMX patterns
* **Search:** `hx-get=\"/api/search\"` and `hx-trigger=\"keyup changed delay:500ms\"` so that the search happens half a second after the user stops typing.
* **Polling during upload:** `hx-get=\"/api/receipts/{id}/status\"` with `hx-trigger=\"every 2s\"` until the status is `COMPLETED`.
* **CSRF:** All HTMX calls must send the `X-XSRF-TOKEN` header (NFR-SEC3).

## 4. User journeys <a name="journeys"></a>

### 4.1 Journey: \"First-time user\"
**Persona:** Anna (38, project manager).

1. **Discovery:** Finds the app via a blog about household finances.
2. **Registration:** Clicks \"Create account\". Enters e-mail and password. **Consent** for crowdsourcing is not pre-ticked (see [gdpr.md](gdpr.md) section 8.1).
3. **Onboarding:** A welcome view explains in 3 steps how the app works.
4. **First upload:** Opens Kivra on the phone, exports the ICA receipt as a PDF, uploads via Matdata.
5. **Waiting state:** Sees an HTMX spinner: \"Extracting prices…\" (max 30 s p95, NFR-P2).
6. **Confirmation:** \"34 items found.\" Clicks to see her first receipt.
7. **Dashboard:** The dashboard still shows \"Upload more receipts to see trends\" until at least 3 receipts are available.

### 4.2 Journey: \"I wonder why the coffee costs more\"
**Persona:** Sofia (52).

1. **Trigger:** Sofia thinks the coffee feels expensive.
2. **Search:** Clicks on the search icon and types \"coffee\". HTMX shows autocomplete suggestions immediately.
3. **Product page:** Selects her usual coffee. Sees a line chart: price has risen 12 % over 6 months.
4. **Shrinkflation warning:** Sees clearly: *\"The package decreased from 500 g to 450 g in March.\"*
5. **Conclusion:** Sofia shares the result with her partner. Decides to try another brand next time.

### 4.3 Journey: \"Enable crowdsourcing\"
**Persona:** Markus (29, developer).

1. **Trigger:** Markus read about K13 in the app's documentation.
2. **Profile:** Goes to `/profile`.
3. **Consent:** Toggles \"Share my prices anonymously to help others\".
4. **Confirmation:** A modal clearly explains what is shared (article number, price, city, month) and what is *not* shared (specific store, exact time, the receipt's shopping basket). See [gdpr.md](gdpr.md) section 2.2.
5. **Done:** Toast: \"Thanks! Your future receipts now contribute to global statistics.\"

### 4.4 Journey: \"Delete my account\" (GDPR Art. 17)
**Persona:** Anna, but now with a new job and she no longer wants to use Matdata.

1. **Profile:** Goes to `/profile`.
2. **Button \"Delete my account\":** Clearly placed at the bottom, red.
3. **Confirmation 1:** A modal explains what happens (account + receipts are deleted, anonymous statistics remain per ADR-007). The user must type \"DELETE\" to confirm.
4. **Confirmation 2:** Final modal: \"Are you sure?\"
5. **Execution:** The system runs `ON DELETE CASCADE`, deletes PDFs in Cloud Storage, writes to the audit log.
6. **Confirmation by e-mail:** An e-mail is sent confirming the deletion.

### 4.5 Journey: \"Export my data\" (GDPR Art. 15 + 20)
1. Profile → \"Export my data\".
2. Choose format: JSON or CSV.
3. Save the file (download in the browser).

## 5. Empty states, errors and edge cases <a name="states"></a>

Clear empty states and error handling are crucial for the experience. Every view should have a clear empty state, a loading state and an error state.

### 5.1 Empty states

| View | Empty state message | CTA |
| --- | --- | --- |
| Dashboard | \"Welcome! Upload your first receipt to see trends.\" | \"Upload receipt\" |
| Receipts | \"No receipts yet. It is quick to get started!\" | \"Upload receipt\" |
| Search | \"Search among your items or the global statistics.\" | (search suggestions) |
| Product detail | \"Only one purchase so far. Upload more receipts to see trends.\" | — |
| Moms-kollen | \"You need receipts from before and after the VAT reduction so we can compare.\" | \"Upload older receipt\" |

### 5.2 Error states

| Error | Display | User action |
| --- | --- | --- |
| Network error | Toast: \"Could not reach the server. Try again.\" | Retry button |
| PDF could not be read | Toast + error box: \"We could not read the receipt. Is it a PDF from Kivra?\" | \"Try again\" or \"Report\" |
| Invalid PDF size (> 10 MB) | Error message directly in the upload box: \"PDF is too large (max 10 MB).\" | Upload a different file |
| Parsing takes > 30 s | Status: \"This is taking a little longer than usual. You can close the page and check back later.\" | — |
| Sign-in fails | Error message under the form: \"Wrong e-mail or password.\" Rate limiting after 5 attempts (NFR-SEC10). | Reset password (post-MVP) |
| Session has expired | Auto-redirect to sign-in with toast: \"You need to sign in again.\" | Sign in |
| 404 (page does not exist) | Custom 404 page with a link to the dashboard | \"Back to home\" |
| 500 (server error) | Custom 500 page with a contact link | \"Try again in a moment\" |

### 5.3 Edge cases
* **Receipt without a date:** If the PDF lacks a purchase date, prompt the user to enter it manually.
* **Receipt with duplicate content:** The system detects a duplicate upload based on the file hash. Shows \"This receipt has already been uploaded.\"
* **User with 0 consents:** Crowdsourcing views (K14) show an info box that explains why no data is shown for them and how they can enable consent.
* **Slow network connection:** Skeleton screens (placeholder blocks with animation) while the dashboard loads.

## 6. Accessibility (WCAG 2.1 AA) <a name="accessibility"></a>

Matdata 2.0 must meet WCAG 2.1 AA (NFR-AC1). This section describes the practical guidelines.

### 6.1 General requirements
* **Semantic HTML:** Use the correct element type (`<button>`, `<nav>`, `<main>`, `<article>`) instead of a generic `<div>` (NFR-AC4).
* **Landmark structure:** Every page has a correct `<header>`, `<main>`, `<nav>`, `<footer>`.
* **Skip links:** A skip-to-main-content link at the top of every page.
* **Keyboard navigation:** All interactive elements must be reachable and operable with the keyboard (NFR-AC3). The tab order must be logical.
* **Focus indicator:** Clear visible focus ring (`focus-visible` with a thick ring in a contrast colour).
* **Colour contrast:** ≥ 4.5:1 for normal text, ≥ 3:1 for large text (NFR-AC2).

### 6.2 Screen readers
* All images have an `alt` attribute. Decorative images have `alt=\"\"`.
* Icons with a function have an `aria-label` (e.g. `<button aria-label=\"Close modal\">×</button>`).
* Form fields have associated `<label>` elements.
* Error messages use `aria-live=\"polite\"` so that screen readers read them out.
* Modals use `role=\"dialog\"` and `aria-modal=\"true\"`.
* Manual test with NVDA or VoiceOver for the main flows (NFR-AC5).

### 6.3 HTMX accessibility
* On HTMX updates: use `hx-swap-oob=\"true\"` to update ARIA live regions.
* Spinners should have `role=\"status\"` and `aria-live=\"polite\"`.
* Autocomplete lists use `role=\"listbox\"` and the arrow keys should be able to navigate with the keyboard.

### 6.4 Motion and animation
* Confetti and slide animations respect `prefers-reduced-motion` (NFR-AC6).
* No animations that flash more than 3 times per second (epilepsy protection).

### 6.5 Testing and verification
* `axe-core` or `pa11y` is run in CI (NFR-AC4). The tool choice is decided in ADR-014 ([open-decisions.md](open-decisions.md)).
* Manual review of the main flows with a screen reader before the public launch.
* WCAG audit by an external party before launch.

## 7. Gamification (for the future) <a name="gamification"></a>

To get the user to *want* to upload receipts, small reward elements can be added (post-MVP):

* **Saver of the month:** \"You bought 80 % of your items at a special offer this month!\"
* **Eco hero (if data is available):** \"You reduced your purchase of red meat by 15 % compared with last month.\"
* **Streaks:** Number of months in a row with uploaded receipts.
* **Crowdsourcing contribution:** \"You have contributed 234 price points to global statistics.\"

**Important:** No gamification element may create pressure or manipulate the user. They must be informative, not coercive.

## 8. AI prompts for design tools <a name="prompts"></a>

*Instruction: Use these prompts in sequence in your design tool (Stitch, v0 or equivalent). By starting with the base and building views on top of it you get a consistent result.*

### 8.1 Prompt 1: Foundational layout (app shell)
**Purpose:** Create the shell that all other views must live inside.

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

### 8.2 Prompt 2: The component catalogue (kitchen sink)
**Purpose:** Get all buttons, cards, tables, input fields, modals and notifications designed in the same style.

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

### 8.3 Prompt 3: Dashboard and Moms-kollen
**Purpose:** Create the start screen based on the UX visions in [section 2](#views).

> *Now, replace the content area with the 'Dashboard' view. Use the components we defined earlier. Generate plain HTML with Tailwind CSS.*
>
> *The Dashboard needs the following sections, stacking vertically on mobile:*
> *1. A welcome message 'Hej [Name]!'.*
> *2. Two 'Stat Cards' side by side (or stacked on very small screens): One for 'Månadens utgifter' (Month's expenses) and one for 'Ditt Inflationsindex' (Your inflation index).*
> *3. A special thematic card called 'Moms-kollen' (The VAT Checker). This card should have a slightly different, attention-grabbing background (maybe a very subtle gradient). Inside it, show a quick summary like 'ICA Maxi has lowered prices on 15 of your top 20 items'. Add a button saying 'Se hela analysen'.*
> *4. A 'Senaste kvittona' (Recent receipts) section. Show a simple list of 3 receipt items (Store name, Date, Total Amount).*

### 8.4 Prompt 4: Search and price history (product detail view)
**Purpose:** Design the view where you see the price history for a specific item and the shrinkflation warning.

> *Create a 'Product Detail' view for a specific grocery item (e.g., 'Svensk Blandfärs 500g'). Generate plain HTML with Tailwind CSS.*
>
> *Elements needed:*
> *1. A prominent back button at the top.*
> *2. The Product Name as a large heading, with the current best price below it.*
> *3. A 'Shrinkflation Warning' banner (using amber/yellow colors and an alert icon). The text should say 'Varning: Förpackningen har minskat från 500g till 450g men priset är detsamma.'*
> *4. Place the 'Chart Container' component here (for the price history graph).*
> *5. Place the 'Data Table' component below the chart to display the historical purchases of this item in detail (Columns: Date, Store, Quantity, Price). Use the green/red badges in the Price column to indicate if it was a good deal.*

### 8.5 Prompt 5: Receipt upload (asynchronous statuses)
**Purpose:** Get the HTML for the upload box in its different HTMX states.

> *Finally, I need the UI for the Receipt Upload modal/area. Since I am using HTMX to poll the server, I need three distinct UI states. Please provide the HTML/Tailwind for all three states, stacked on top of each other so I can see them.*
>
> *State 1: Upload Prompt. A drag-and-drop zone with a dashed border, an upload icon, and text saying 'Välj PDF-kvitto från Kivra'.*
> *State 2: Processing (Loading). The dashed box is replaced by a centered loading spinner (you can use an SVG or Tailwind animation) and the text 'Extraherar priser...'.*
> *State 3: Success. A green checkmark icon, confetti-like aesthetic (just visually happy), and text saying 'Klart! 34 varor sparade.' with a button 'Se kvittot'.*

## 9. Workflow and implementation <a name="workflow"></a>

### 9.1 Integration via MCP (Model Context Protocol)
Instead of manually cutting and pasting HTML out of design tools (Stitch, v0), coding agents (GitHub Copilot, Cursor, Cline) connected via MCP are used.

**Workflow:**
1. Generate the design in Stitch with the prompts in [section 8](#prompts).
2. In your local IDE, ask the agent: *\"Read in the UI for the Dashboard from Stitch via your MCP connection.\"*
3. Give the directive: *\"Convert the HTML code to Thymeleaf. Put the layout shell in `layout.html`, extract all reusable components (cards, buttons) to `fragments/components.html` and create the view `dashboard.html`.\"*
4. The agent does the heavy lifting and automatically maps in the correct Tailwind classes and Thymeleaf tags (`th:fragment`, `th:replace`).

### 9.2 Live component overview (\"Kitchen Sink\", K11)
To keep control of the design system, \"Prompt 2\" is built in as a live view in the application during development.

* **Route:** A specific controller endpoint, `GET /dev/components`. This route is locked down or removed in the production environment.
* **Purpose:** The view imports and renders *all* Thymeleaf fragments from `components.html` on one long scrollable page.
* **Benefit:** You can visually inspect how all buttons, tables and pop-ups render locally in the true Java environment. It also makes it extremely easy to test HTMX interactions (\"click to show toast\") in isolation before they are integrated into more complex business logic.

### 9.3 Design review before implementation
Before a new view is implemented, the following checklist must be gone through:

* [ ] Empty state is designed (see [section 5.1](#states)).
* [ ] Error state is designed (see [section 5.2](#states)).
* [ ] The view works on mobile (320 px and up, NFR-BR6).
* [ ] Colour contrast verified (NFR-AC2).
* [ ] Keyboard navigation tested (NFR-AC3).
* [ ] Screen reader walkthrough done on the main flow (NFR-AC5, for public pages).
* [ ] Components are reused from `/dev/components` instead of duplicated.
* [ ] HTMX patterns follow [section 3.4](#designsystem).

### 9.4 Design decisions pending
The following design decisions are open and need to be made before Phase 4 starts (see [open-decisions.md](open-decisions.md)):

* **ADR-011:** Choice of charting library (Chart.js, ECharts or server-side SVG).
* **ADR-013:** Source for product categories (for the donut chart on the dashboard).
* **ADR-014:** Tooling for accessibility tests.
