#!/usr/bin/env bash
# create-github-issues.sh
# ---------------------------------------------------------------------------
# Skapar GitHub-issues (epics) och sub-issues (user stories) för Matdata 2.0
# baserat på user-stories.md.
#
# Skriptet kallar din LOKALA installation av `gh` (GitHub CLI). Det skapar
# inga issues förrän du kört det med --apply. Utan --apply körs en dry-run
# som bara skriver ut vad som SKULLE skapas.
#
# Användning:
#   ./scripts/create-github-issues.sh                 # dry-run (default)
#   ./scripts/create-github-issues.sh --apply         # skapar issues på riktigt
#   ./scripts/create-github-issues.sh --apply -R owner/repo
#
# Förkrav:
#   * gh >= 2.40 installerad och inloggad: `gh auth status`
#   * Behörighet att skapa issues och labels i target-repot
#   * `jq` (för att hantera issue-nummer i sub-issue-länkningen)
#   * Skriptet är idempotent: existerande issues uppdateras inte, bara hoppas
#     över.
# ---------------------------------------------------------------------------
set -euo pipefail

# ---------------- Konfiguration ----------------
DEFAULT_REPO="pekelund-dev/matdata-2.0"
REPO="${REPO:-$DEFAULT_REPO}"
APPLY=0

usage() {
  cat <<'EOF'
Användning: create-github-issues.sh [OPTIONS]

Options:
  --apply                Skapa issues på riktigt (default: dry-run).
  -R, --repo OWNER/REPO  Target-repo (default: pekelund-dev/matdata-2.0).
  -h, --help             Visa den här hjälpen.

Skriptet är idempotent — om en epic eller user story redan finns som issue
(matchad på titel) hoppas den över.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=1; shift ;;
    -R|--repo) REPO="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Okänt argument: $1" >&2; usage; exit 2 ;;
  esac
done

# ---------------- Hjälpfunktioner ----------------
# Logg-funktionerna skriver till stderr så att stdout enbart innehåller
# issue-nummer (vilket vissa funktioner returnerar via command substitution).
log()  { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }
warn() { printf '[%s] WARN: %s\n' "$(date +%H:%M:%S)" "$*" >&2; }
die()  { printf '[%s] ERROR: %s\n' "$(date +%H:%M:%S)" "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Saknad kommandorad: $1"
}

require_cmd gh
require_cmd jq

if (( APPLY == 1 )); then
  gh auth status >/dev/null 2>&1 || die "gh är inte inloggad. Kör: gh auth login"
  # Verifiera att repot finns och att vi har skrivrättigheter
  gh repo view "$REPO" >/dev/null 2>&1 || die "Kan inte se repot $REPO via gh"
fi

if (( APPLY == 0 )); then
  log "DRY-RUN — inga issues eller labels skapas. Kör med --apply för att utföra."
else
  log "APPLY — kommer skapa issues och labels i $REPO"
fi

# ---------------- Labels ----------------
# Format: namn|färg(hex utan #)|beskrivning
LABELS=(
  "epic|8B5CF6|Parent issue som grupperar en uppsättning user stories."
  "user-story|3B82F6|Implementerbar user story med Given/When/Then-AC."
  "prio:must|B91C1C|MoSCoW Must — krävs för MVP."
  "prio:should|D97706|MoSCoW Should — viktigt men inte blockerande."
  "prio:could|65A30D|MoSCoW Could — post-MVP."
  "area:infra|0F766E|Infrastruktur, IaC, CI/CD, deploy."
  "area:auth|6D28D9|Autentisering, sessioner, lösenord."
  "area:parsing|0369A1|PDF-parsing, Pub/Sub, async-flöden."
  "area:frontend|DB2777|UI, Thymeleaf, HTMX, Tailwind."
  "area:gdpr|166534|GDPR, samtycke, dataexport, radering, audit."
  "area:observability|7C2D12|OTel, metrics, larm, runbooks."
  "area:crowdsource|1D4ED8|Global pris-pool, anonymisering."
  "area:insights|9D174D|Tematiska vyer (Moms-kollen, krympflation)."
  "area:design-a11y|4D7C0F|Designsystem, komponentkatalog, WCAG."
)

ensure_label() {
  local name="$1" color="$2" desc="$3"
  if (( APPLY == 0 )); then
    log "[dry-run] skulle säkerställa label: $name (#$color)"
    return 0
  fi
  if gh label list -R "$REPO" --limit 200 --json name --jq '.[].name' | grep -Fxq "$name"; then
    log "label finns redan: $name"
  else
    gh label create "$name" --color "$color" --description "$desc" -R "$REPO" >/dev/null
    log "skapade label: $name"
  fi
}

log "=== Steg 1/3: säkerställ labels ==="
for entry in "${LABELS[@]}"; do
  IFS='|' read -r name color desc <<<"$entry"
  ensure_label "$name" "$color" "$desc"
done

# ---------------- Issue-hjälpare ----------------

# Hitta issue-nummer för exakt titel. Skriver issue-nummer på stdout om hittad,
# annars tom sträng.
find_issue_number_by_title() {
  local title="$1"
  if (( APPLY == 0 )); then
    printf ''
    return 0
  fi
  gh issue list -R "$REPO" --state all --limit 500 \
    --search "in:title \"$title\"" \
    --json number,title \
    --jq ".[] | select(.title == \"$title\") | .number" \
    | head -n1
}

# Skapa eller hoppa över issue. Skriver issue-nummer på stdout.
# Args: title, body, label1, label2, ...
create_issue_if_missing() {
  local title="$1"; shift
  local body="$1"; shift
  local labels=("$@")
  local existing
  existing="$(find_issue_number_by_title "$title")"
  if [[ -n "$existing" ]]; then
    log "issue finns redan (#$existing): $title"
    printf '%s\n' "$existing"
    return 0
  fi
  if (( APPLY == 0 )); then
    log "[dry-run] skulle skapa issue: $title  [labels: ${labels[*]}]"
    printf '\n'  # Tomt issue-nummer i dry-run
    return 0
  fi
  local label_args=()
  for l in "${labels[@]}"; do
    label_args+=( --label "$l" )
  done
  local url num
  url="$(gh issue create -R "$REPO" --title "$title" --body "$body" "${label_args[@]}")"
  num="${url##*/}"
  log "skapade issue #$num: $title"
  printf '%s\n' "$num"
}

# Länka sub-issue till parent via GitHub:s sub-issues API.
# Kräver att både parent och child finns. No-op vid dry-run.
link_sub_issue() {
  local parent_num="$1" child_num="$2"
  if (( APPLY == 0 )) || [[ -z "$parent_num" || -z "$child_num" ]]; then
    log "[dry-run] skulle länka sub-issue #$child_num under parent #$parent_num"
    return 0
  fi
  local owner repo child_id
  owner="${REPO%%/*}"
  repo="${REPO##*/}"
  # Sub-issues API kräver child-issuets internt id, inte issue-nummer
  child_id="$(gh api "repos/$owner/$repo/issues/$child_num" --jq '.id')"
  if gh api -X POST "repos/$owner/$repo/issues/$parent_num/sub_issues" \
      -f sub_issue_id="$child_id" >/dev/null 2>&1; then
    log "länkade #$child_num som sub-issue till #$parent_num"
  else
    warn "kunde inte länka #$child_num under #$parent_num (sub-issues API kanske inte är aktiverat). Lägger till parent-referens i bodyn istället."
    gh issue comment "$child_num" -R "$REPO" \
      --body "Parent epic: #$parent_num" >/dev/null || true
  fi
}

# ---------------- Innehåll: epics och user stories ----------------
#
# Varje epic har: titel, area-label, kort beskrivning.
# Varje user story har: id, titel, prio, area, body (markdown).
#
# Body är medvetet kort — full Given/When/Then-AC finns i user-stories.md och
# länkas från issuet, men de viktigaste punkterna återges i bodyn så att
# issuet är meningsfullt även standalone.

# Hjälpare: skriver story-body i ett HEREDOC-vänligt format.
story_body() {
  local id="$1" persona="$2" want="$3" why="$4" prio="$5" trace="$6"
  shift 6
  local acs=("$@")
  local body
  body="**Som** $persona **vill jag** $want **för att** $why.

**Story-ID:** $id
**Prioritet:** $prio
**Spårbarhet:** $trace

### Acceptanskriterier (Given/When/Then)
"
  local i=1
  for ac in "${acs[@]}"; do
    body+="${i}. $ac
"
    i=$((i+1))
  done
  body+="
### Definition of Done
Se DoD-checklista i [user-stories.md §1.3](../blob/main/user-stories.md#13-definition-of-done-story-nivå) plus story-specifika punkter under $id i [user-stories.md](../blob/main/user-stories.md).
"
  printf '%s' "$body"
}

epic_body() {
  local epic_id="$1" goal="$2" krav="$3" nfr="$4" phase="$5" stories="$6"
  cat <<EOF
**Epic $epic_id**

**Mål:** $goal

**Primära K-krav:** $krav
**NFR:** $nfr
**Fas:** $phase

### Ingående user stories
$stories

### Källa
Se [user-stories.md](../blob/main/user-stories.md) för fullständiga acceptanskriterier, DoD och spårbarhetsmatris.
EOF
}

# ---------------- Steg 2/3: skapa epics ----------------
log "=== Steg 2/3: skapa epic-issues ==="

declare -A EPIC_NUM  # epic_id -> issue-nummer

create_epic() {
  local epic_id="$1" title="$2" area_label="$3" body="$4"
  local num
  num="$(create_issue_if_missing "$title" "$body" "epic" "$area_label")"
  EPIC_NUM["$epic_id"]="$num"
}

create_epic "1" "[Epic 1] Infrastruktur och DevOps-grund" "area:infra" "$(epic_body \
  "1 — Infrastruktur och DevOps-grund" \
  "Innan en enda affärsfunktion implementeras ska repo, CI/CD, IaC och säkerhetsskanning vara på plats så att varje PR genererar en isolerad, körbar miljö." \
  "K6, K7" \
  "NFR-SEC6, SEC7, SEC8, B5" \
  "Fas 1" \
  "- US-1.1 CI-pipeline för PR-byggen
- US-1.2 Terraform-modul för basinfrastruktur
- US-1.3 PR-miljö med Neon-databasbranching
- US-1.4 Health- och smoke-checks efter deploy")"

create_epic "2" "[Epic 2] Konto och autentisering" "area:auth" "$(epic_body \
  "2 — Konto och autentisering" \
  "Säker, sessionbaserad inloggning där användaren bara ser sina egna kvitton." \
  "K5" \
  "NFR-SEC1–SEC5, SEC10, D4" \
  "Fas 4–5" \
  "- US-2.1 Registrering med e-post och lösenord
- US-2.2 Inloggning med rate limiting
- US-2.3 Utloggning och CSRF-skydd
- US-2.4 Sessionshantering över flera instanser")"

create_epic "3" "[Epic 3] Kvitto-uppladdning och asynkron parsing" "area:parsing" "$(epic_body \
  "3 — Kvitto-uppladdning och asynkron parsing" \
  "Implementera grundflödet 'PDF in → tolkad data ut' med asynkron arkitektur via Pub/Sub." \
  "K1, K2, K3, K9, K12" \
  "NFR-A3, A4, P2, P3, M1, S4" \
  "Fas 2–4" \
  "- US-3.1 PDF-uppladdning från Kivra
- US-3.2 Asynkron parsing via Parser Service
- US-3.3 EAN/PLU-maskning för viktvaror
- US-3.4 HTMX-polling för statusåterkoppling
- US-3.5 Dead Letter Queue och felbevakning")"

create_epic "4" "[Epic 4] Personlig prishistorik och sökning" "area:frontend" "$(epic_body \
  "4 — Personlig prishistorik och sökning" \
  "Användaren kan se sina egna kvitton, söka efter produkter och förstå sin egen prisutveckling." \
  "K4, K12" \
  "NFR-P1, P4, S3" \
  "Fas 2 (datamodell) + Fas 4–5 (UI)" \
  "- US-4.1 Normaliserad datamodell för kvitton och produkter
- US-4.2 Produktsökning med autocomplete
- US-4.3 Produktsida med personlig prishistorik
- US-4.4 Dashboard med månadsutgifter")"

create_epic "5" "[Epic 5] Crowdsourcing och global statistik" "area:crowdsource" "$(epic_body \
  "5 — Crowdsourcing och global statistik" \
  "Bygga den anonymiserade pris-poolen och låta användaren se global prisutveckling — utan att läcka individidentitet." \
  "K8, K13, K14" \
  "NFR-D3" \
  "Fas 3 + post-MVP" \
  "- US-5.1 Anonymiserad lagring av global prisdata
- US-5.2 Samtycke för crowdsourcing
- US-5.3 Öppen statistikvy för global prisutveckling")"

create_epic "6" "[Epic 6] Tematiska insikter (Moms-kollen och krympflation)" "area:insights" "$(epic_body \
  "6 — Tematiska insikter (Moms-kollen och krympflation)" \
  "Mervärdesvyer som driver engagemang. Klassificerade som 'Could have', post-MVP." \
  "K15, K16" \
  "—" \
  "Post-MVP (C)" \
  "- US-6.1 Moms-kollen
- US-6.2 Krympflations-varning")"

create_epic "7" "[Epic 7] GDPR och användarrättigheter" "area:gdpr" "$(epic_body \
  "7 — GDPR och användarrättigheter" \
  "Implementera Artiklarna 13–22 i koden så att DPIA godkänns innan publik lansering." \
  "K5, K8" \
  "NFR-D2, D3, D6" \
  "Fas 4–5" \
  "- US-7.1 Audit-logg för säkerhetshändelser
- US-7.2 Dataexport (Artikel 15 + 20)
- US-7.3 Radering av konto (Artikel 17)
- US-7.4 Återkallande av samtycke")"

create_epic "8" "[Epic 8] Designsystem och accessibility" "area:design-a11y" "$(epic_body \
  "8 — Designsystem och accessibility" \
  "Etablera en återanvändbar komponentkatalog och säkerställa WCAG 2.1 AA." \
  "K11, K12" \
  "NFR-AC1–AC6, M5" \
  "Fas 4 + AC-tester i Fas 5" \
  "- US-8.1 Komponentkatalog på /dev/components
- US-8.2 WCAG 2.1 AA-konformans")"

create_epic "9" "[Epic 9] Observability och drift" "area:observability" "$(epic_body \
  "9 — Observability och drift" \
  "Säkerställa att vi vet när systemet brakar — och varför." \
  "K10" \
  "NFR-O1, O2, O3, O4, A1, A2, A4" \
  "Fas 3 + lanseringskriterier i Fas 5" \
  "- US-9.1 Distribuerad spårning ände-till-ände
- US-9.2 Metrics och dashboards för KPI:er
- US-9.3 DLQ-larm och driftrunbook")"

# ---------------- Steg 3/3: skapa user stories som sub-issues ----------------
log "=== Steg 3/3: skapa user stories som sub-issues ==="

create_story() {
  local epic_id="$1" story_id="$2" short_title="$3" prio_label="$4" area_label="$5" body="$6"
  local title="$story_id $short_title"
  local parent_num="${EPIC_NUM[$epic_id]:-}"
  local num
  num="$(create_issue_if_missing "$title" "$body" "user-story" "$prio_label" "$area_label")"
  if (( APPLY == 0 )); then
    log "[dry-run]   ↳ skulle länkas som sub-issue under Epic $epic_id"
    return 0
  fi
  if [[ -n "$num" && -n "$parent_num" ]]; then
    link_sub_issue "$parent_num" "$num"
  fi
}

# ---- Epic 1 stories ----
create_story "1" "US-1.1" "CI-pipeline för PR-byggen" "prio:must" "area:infra" "$(story_body \
  "US-1.1" \
  "utvecklare" \
  "att varje Pull Request automatiskt bygger båda Spring Boot-tjänsterna, kör enhetstester och statisk analys" \
  "snabbt få feedback innan merge" \
  "Must (K6)" \
  "K6, NFR-SEC6, NFR-SEC7, NFR-SEC8, NFR-M2" \
  "**Given** en utvecklare öppnar en PR mot main, **when** GitHub Actions startar, **then** workflow build.yml kör mvn verify för både core-service och parser-service parallellt." \
  "**Given** ett PR-bygge, **when** byggjobbet kör, **then** CodeQL (NFR-SEC7) och Dependabot-rapport (NFR-SEC6) körs och blockerar merge vid error-fynd." \
  "**Given** ett PR-bygge, **when** koden formateras fel, **then** Spotless eller motsvarande formatter (NFR-M2) markerar checken som failed." \
  "**Given** ett lyckat PR-bygge, **when** alla checks är gröna, **then** Docker-images publiceras till GitHub Container Registry med tagg pr-<nr>-<sha>." \
  "**Given** en GCP-deploy från CI, **when** workflow autentiserar sig, **then** Workload Identity Federation (NFR-SEC8) används — **inga** långlivade service-account-nycklar lagras i GitHub Secrets." \
  "**Given** ett PR-bygge tar > 10 minuter, **when** byggtiden mäts, **then** en GitHub Actions-cache används för Maven-beroenden så att medianbyggtid ≤ 6 minuter.")"

create_story "1" "US-1.2" "Terraform-modul för basinfrastruktur" "prio:must" "area:infra" "$(story_body \
  "US-1.2" \
  "utvecklare" \
  "att GCP-resurser (GCS-bucket, Pub/Sub-topic, Cloud Run-tjänster, IAM) och Neon-projekt provisioneras via Terraform" \
  "miljöer kan återskapas reproducerbart" \
  "Must (K7)" \
  "K7, NFR-B5, ADR-006" \
  "**Given** ett nytt GCP-projekt, **when** terraform apply körs från /terraform, **then** GCS-bucket, Pub/Sub-topic receipt-uploads, DLQ-topic, två Cloud Run-tjänster och två service accounts skapas utan manuella steg." \
  "**Given** Terraform-modulerna, **when** terraform validate körs i CI, **then** alla moduler valideras och tflint/checkov flaggar inga öppna fynd med severity ≥ high." \
  "**Given** ett befintligt miljö-state, **when** Terraform planeras, **then** state lagras remote (GCS-bucket med versionering och lock via Cloud Storage) — aldrig lokalt." \
  "**Given** en Pull Request som ändrar Terraform-kod, **when** PR öppnas, **then** CI postar terraform plan-utfallet som PR-kommentar." \
  "**Given** Neon-projektet, **when** Terraform kör, **then** main-branch och produktionsdatabasrollen provisioneras via Neon Terraform-provider med budgetlarm aktiverat." \
  "**Given** en katastrof där hela GCP-projektet förloras, **when** Terraform appliceras mot ett nytt projekt, **then** hela infrastrukturen kan återskapas på ≤ 1 timme (NFR-B5).")"

create_story "1" "US-1.3" "PR-miljö med Neon-databasbranching" "prio:must" "area:infra" "$(story_body \
  "US-1.3" \
  "utvecklare" \
  "att varje PR får en isolerad databas och Cloud Run-deploy" \
  "kunna testa migreringar och nya features mot en ren miljö utan att påverka prod" \
  "Must (K6)" \
  "K6" \
  "**Given** en ny PR öppnas, **when** workflow pr-environment.yml triggas, **then** en Neon-databasbranch skapas från main med suffix pr-<nr>." \
  "**Given** PR-miljön är uppe, **when** workflow är klar, **then** PR-kommentar publiceras med URL till core-service, parser-service och Neon-branch." \
  "**Given** två öppna PR:er samtidigt, **when** de deployas, **then** de använder separata Pub/Sub-topic per PR för att förhindra meddelandekrock." \
  "**Given** en PR stängs eller merges, **when** workflow pr-teardown.yml triggas, **then** Cloud Run-revisioner, Pub/Sub-topic och Neon-branch raderas inom 5 minuter." \
  "**Given** en PR-deploy som misslyckas, **when** workflow brakar, **then** felet rapporteras som PR-check med direktlänk till get_job_logs och Neon-branchen raderas trots felet (cleanup-step if: always())." \
  "**Given** att Flyway-migreringar finns i PR:en, **when** PR-miljön startar, **then** migreringarna körs mot PR-databranchen automatiskt vid deploy.")"

create_story "1" "US-1.4" "Health- och smoke-checks efter deploy" "prio:must" "area:infra" "$(story_body \
  "US-1.4" \
  "driftansvarig" \
  "att varje produktionsdeploy verifieras med smoke-tester" \
  "trasiga releaser fångas innan användare påverkas" \
  "Must" \
  "K6, NFR-A1, NFR-A2" \
  "**Given** en deploy till prod-miljön, **when** core-service-revisionen får trafik, **then** GET /healthz returnerar 200 OK med status: UP." \
  "**Given** en grön healthcheck, **when** workflow fortsätter, **then** smoke-test kör GET /login och verifierar att sidan svarar 200 och innehåller CSRF-token." \
  "**Given** en misslyckad smoke-check, **when** Cloud Run upptäcker fel, **then** trafiken rullas tillbaka till föregående revision (gradual rollout-config) inom 60 sekunder." \
  "**Given** en deploy, **when** den lyckas, **then** Cloud Monitoring annoterar deploy-händelsen så att felgrad kan korreleras med releaser." \
  "**Given** en produktionsincident, **when** team behöver veta senaste deploy, **then** git tag prod-<datum> finns på commit som motsvarar nuvarande revision.")"

# ---- Epic 2 stories ----
create_story "2" "US-2.1" "Registrering med e-post och lösenord" "prio:must" "area:auth" "$(story_body \
  "US-2.1" \
  "Anna" \
  "kunna skapa ett konto med min e-post och ett lösenord" \
  "börja ladda upp kvitton" \
  "Must (K5)" \
  "K5, NFR-SEC4, NFR-SEC5, ADR-009" \
  "**Given** registreringsformuläret, **when** Anna fyller i giltig e-post och ett lösenord ≥ 12 tecken, **then** kontot skapas och hon loggas in direkt med ny sessions-cookie." \
  "**Given** ett lösenord som är < 12 tecken eller finns i pwned-passwords-listan, **when** formuläret submittas, **then** ett klarspråksfel visas under fältet och kontot skapas **inte**." \
  "**Given** att lösenord sparas, **when** posten skrivs till USERS, **then** password_hash är en BCrypt-hash med kostnad ≥ 12 (NFR-SEC4) och plaintext finns aldrig kvar i loggar eller minne efter request." \
  "**Given** en redan registrerad e-post, **when** någon försöker registrera samma adress, **then** systemet svarar med generiskt meddelande för att inte avslöja kontoexistens." \
  "**Given** en lyckad registrering, **when** sessionen skapas, **then** Spring Securitys sessionsregenerering körs (NFR-SEC5) och cookien sätts som HttpOnly, Secure, SameSite=Lax." \
  "**Given** ett registreringsförsök, **when** användaren inte aktivt kryssar i samtycke för crowdsourcing, **then** USERS.share_anonymous_data = false (default).")"

create_story "2" "US-2.2" "Inloggning med rate limiting" "prio:must" "area:auth" "$(story_body \
  "US-2.2" \
  "användare" \
  "kunna logga in med min e-post och lösenord" \
  "komma åt mitt konto utan att illvilliga aktörer kan brute-force:a sig in" \
  "Must (K5)" \
  "K5, NFR-SEC10" \
  "**Given** korrekta uppgifter, **when** formuläret skickas, **then** användaren omdirigeras till /dashboard med ny session." \
  "**Given** felaktiga uppgifter, **when** formuläret skickas, **then** felmeddelandet är generiskt: 'Fel e-post eller lösenord' — ingen indikation på vilket fält som var fel." \
  "**Given** 5 misslyckade försök från samma IP inom 10 minuter, **when** ett sjätte försök görs, **then** anropet returnerar 429 Too Many Requests (NFR-SEC10) och en återhämtningstid visas." \
  "**Given** rate limiting triggas, **when** händelsen loggas, **then** posten skrivs till audit-loggen (NFR-D6) utan att avslöja om e-posten finns i systemet." \
  "**Given** att en användare redan är inloggad, **when** hon besöker /login, **then** sidan redirectar till /dashboard automatiskt." \
  "**Given** en lyckad inloggning, **when** sessionen återanvänds, **then** Spring Security regenererar sessions-ID (NFR-SEC5) för att skydda mot session fixation.")"

create_story "2" "US-2.3" "Utloggning och CSRF-skydd" "prio:must" "area:auth" "$(story_body \
  "US-2.3" \
  "användare" \
  "kunna logga ut säkert" \
  "ingen annan ska kunna fortsätta använda mitt konto från min enhet" \
  "Must (K5)" \
  "K5, NFR-SEC3" \
  "**Given** en inloggad session, **when** användaren klickar 'Logga ut', **then** sessionen invalideras serverside och cookien rensas i klienten." \
  "**Given** utloggningsformuläret, **when** request skickas, **then** den kräver giltig X-XSRF-TOKEN-header (NFR-SEC3) — GET-baserad utloggning är blockerad." \
  "**Given** en utloggad session, **when** användaren navigerar tillbaka via webbläsarhistoriken, **then** skyddade sidor svarar med redirect till /login (Cache-Control: no-store)." \
  "**Given** att HTMX-anrop görs från en inloggad sida, **when** request skickas, **then** X-XSRF-TOKEN-header inkluderas automatiskt." \
  "**Given** en utloggning, **when** händelsen sker, **then** den loggas i audit-loggen (NFR-D6) med trace ID.")"

create_story "2" "US-2.4" "Sessionshantering över flera instanser" "prio:must" "area:auth" "$(story_body \
  "US-2.4" \
  "driftansvarig" \
  "att sessioner lagras i databasen (JDBC)" \
  "Cloud Run kan skala upp till flera instanser utan att användaren loggas ut" \
  "Must" \
  "K5, NFR-D4" \
  "**Given** två core-service-instanser bakom Cloud Run, **when** en användare loggar in mot instans A och nästa request går till instans B, **then** sessionen är fortfarande giltig." \
  "**Given** Spring Session JDBC, **when** sessionen skapas, **then** posten skrivs i SPRING_SESSION-tabellen i Neon PostgreSQL." \
  "**Given** en inaktiv session i 30 dagar (NFR-D4), **when** rensningsjobbet kör dagligen, **then** sessionen raderas från databasen." \
  "**Given** att en användare loggar ut, **when** request behandlas, **then** posten raderas direkt från SPRING_SESSION." \
  "**Given** att Neon är temporärt otillgänglig, **when** session-lookup misslyckas, **then** användaren får felmeddelande och en alarm triggas (NFR-A4).")"

# ---- Epic 3 stories ----
create_story "3" "US-3.1" "PDF-uppladdning från Kivra" "prio:must" "area:parsing" "$(story_body \
  "US-3.1" \
  "Anna" \
  "kunna ladda upp en PDF-fil från Kivra via drag-and-drop" \
  "registrera ett nytt kvitto" \
  "Must (K1)" \
  "K1, NFR-S4, NFR-P1" \
  "**Given** uppladdningsvyn, **when** Anna släpper en PDF (≤ 10 MB) i drop-zonen, **then** filen laddas upp via POST /api/receipts/upload och core-service returnerar 202 Accepted med receiptId." \
  "**Given** en uppladdning, **when** core-service tar emot filen, **then** PDF:en sparas i privat GCS-bucket med path gs://<bucket>/<userId>/<receiptId>.pdf — ingen publik URL skapas." \
  "**Given** en fil som inte är PDF eller är > 10 MB (NFR-S4), **when** uppladdning försöks, **then** request avvisas med 400 Bad Request och klarspråksfel." \
  "**Given** en lyckad uppladdning, **when** posten skrivs, **then** en rad i RECEIPTS skapas med status PENDING, user_id från sessionen och pdf_storage_uri." \
  "**Given** att posten skapats, **when** uppladdningen är klar, **then** ett Pub/Sub-meddelande {receiptId, gcsUri, traceId} publiceras till topic receipt-uploads." \
  "**Given** en duplicerad uppladdning (samma sha256-hash av PDF inom 24 h), **when** Anna laddar upp igen, **then** systemet visar varning och skapar ingen ny RECEIPTS-post.")"

create_story "3" "US-3.2" "Asynkron parsing via Parser Service" "prio:must" "area:parsing" "$(story_body \
  "US-3.2" \
  "Anna" \
  "att mitt uppladdade kvitto bearbetas i bakgrunden" \
  "jag ska se priser och kategorisering utan att vänta i UI" \
  "Must (K2, K9)" \
  "K2, K9, NFR-A3, NFR-P2, ADR-002" \
  "**Given** ett meddelande på receipt-uploads, **when** parser-service konsumerar det, **then** PDF:en hämtas från GCS och text extraheras via Apache PDFBox." \
  "**Given** ett parsat kvitto, **when** datan persisteras, **then** RECEIPT_ITEMS-rader skrivs kopplade till PRODUCTS (existerande eller nya) och RECEIPTS.status uppdateras till COMPLETED." \
  "**Given** ett kvitto på ≤ 5 MB, **when** parsing genomförs, **then** total bearbetningstid är < 30 sekunder p95 (NFR-P2), mätt via receipt_processing_seconds-metric." \
  "**Given** ett parser-fel (PDF kan inte läsas), **when** undantag kastas, **then** RECEIPTS.status = FAILED och failure_reason skrivs; meddelandet ackas inte och Pub/Sub kan retrya." \
  "**Given** at-least-once-leverans, **when** parser-service startar bearbetning, **then** den kontrollerar RECEIPTS.status — om COMPLETED ackas meddelandet utan att skriva igen (idempotens)." \
  "**Given** lyckad bearbetning av minst 95 % av 50 referenskvitton, **when** acceptanstest körs, **then** parser_success_ratio ≥ 0.95 (NFR-A3).")"

create_story "3" "US-3.3" "EAN/PLU-maskning för viktvaror" "prio:must" "area:parsing" "$(story_body \
  "US-3.3" \
  "Markus" \
  "att viktvaror (köttfärs, ost m.m.) grupperas under samma produkt" \
  "prishistoriken inte ska splittras per förpackning" \
  "Must (K3)" \
  "K3, NFR-M1" \
  "**Given** en EAN-13 med prefix 20–29, **when** parsern processar koden, **then** vikt-/prissiffrorna maskas och endast bas-artikelnumret sparas i PRODUCTS.article_number." \
  "**Given** två kvitton med samma viktvara men olika faktiska vikter, **when** båda är parsade, **then** de pekar på **samma** rad i PRODUCTS via samma article_number." \
  "**Given** en standard-EAN (icke-viktvara), **when** parsern processar, **then** ingen maskning sker och hela streckkoden sparas." \
  "**Given** en PLU-kod (lös frukt/grönt), **when** parsern identifierar den, **then** PLU-numret sparas i PRODUCTS.article_number utan att blandas med EAN-koder." \
  "**Given** EAN-maskningslogiken, **when** enhetstester körs, **then** ≥ 10 referens-PDF:er har förväntade article_number och kodtäckning på domänklassen är ≥ 80 % (NFR-M1)." \
  "**Given** ett okänt EAN-prefix, **when** parsern stöter på det, **then** den fattar ett 'safe default'-beslut (ingen maskning) och loggar en WARN.")"

create_story "3" "US-3.4" "HTMX-polling för statusåterkoppling" "prio:should" "area:parsing" "$(story_body \
  "US-3.4" \
  "Anna" \
  "se realtidsstatus ('Laddar upp', 'Extraherar priser', 'Klart')" \
  "inte behöva ladda om sidan manuellt" \
  "Should (K12)" \
  "K12, NFR-P3, ADR-005" \
  "**Given** en lyckad uppladdning, **when** core-service svarar, **then** HTMX-fragmentet aktiverar polling mot GET /api/receipts/{id}/status var 2:e sekund." \
  "**Given** en pollning, **when** endpoint svarar, **then** latency är < 100 ms p95 (NFR-P3) — mätt via Cloud Run-metric." \
  "**Given** att status går från PENDING → COMPLETED, **when** pollingen tar emot det nya statusvärdet, **then** UI ersätter spinnern med ett resultat-fragment." \
  "**Given** att status går till FAILED, **when** UI får det svaret, **then** ett felmeddelande visas med rapport-knapp." \
  "**Given** att processen tar > 30 sekunder, **when** den passerar tröskeln, **then** UI visar fortsatt status om att det tar längre tid." \
  "**Given** att pollingen pågår, **when** statusen blir COMPLETED eller FAILED, **then** HTMX slutar polla automatiskt.")"

create_story "3" "US-3.5" "Dead Letter Queue och felbevakning" "prio:must" "area:parsing" "$(story_body \
  "US-3.5" \
  "driftansvarig" \
  "att meddelanden som upprepat misslyckas hamnar i DLQ och larmar" \
  "vi snabbt kan ingripa" \
  "Must (K9)" \
  "K9, NFR-A4" \
  "**Given** ett meddelande som misslyckas 5 gånger, **when** retry-policy uttömts, **then** meddelandet flyttas till topic receipt-uploads-dlq." \
  "**Given** ett meddelande i DLQ, **when** det landar, **then** en separat hanterare uppdaterar RECEIPTS.status = FAILED så att användaren ser felet i UI." \
  "**Given** trafik > 0 i DLQ, **when** Cloud Monitoring upptäcker det, **then** larm triggas inom 5 minuter (NFR-A4) till på-jour-kanalen." \
  "**Given** ett DLQ-meddelande, **when** driftansvarig granskar det, **then** payload innehåller receiptId, traceId och failure_reason så att trace kan följas i Cloud Trace (NFR-O1)." \
  "**Given** att driftansvarig vill replaya, **when** ett skript triggas, **then** meddelandet kan flyttas tillbaka till receipt-uploads efter manuell verifiering." \
  "**Given** att ett kvitto ligger som FAILED, **when** Anna ser det i UI, **then** hon kan klicka 'Ladda upp igen' för att försöka på nytt.")"

# ---- Epic 4 stories ----
create_story "4" "US-4.1" "Normaliserad datamodell för kvitton och produkter" "prio:must" "area:parsing" "$(story_body \
  "US-4.1" \
  "utvecklare" \
  "att kvitton, kvittorader och produkter lagras normaliserat i Neon PostgreSQL" \
  "prishistorik per produkt kan beräknas effektivt" \
  "Must (K4)" \
  "K4, NFR-S3, ADR-003" \
  "**Given** Flyway-migrering V1, **when** den körs, **then** tabellerna USERS, RECEIPTS, PRODUCTS, RECEIPT_ITEMS, GLOBAL_PRICE_POINTS skapas enligt schema." \
  "**Given** schemat, **when** PRODUCTS.article_number är UK, **then** en INSERT med befintligt artikelnummer återanvänder produkt-ID (upsert-mönster)." \
  "**Given** RECEIPT_ITEMS-tabellen, **when** kolumner skapas, **then** vat_rate finns med så att Moms-kollen (K15) kan implementeras senare." \
  "**Given** USERS-tabellen, **when** användaren raderas, **then** ON DELETE CASCADE säkerställer att alla RECEIPTS och RECEIPT_ITEMS raderas (GDPR Art. 17, NFR-D2)." \
  "**Given** databaspoolen, **when** Hikari konfigureras, **then** max maximumPoolSize = 10 per instans (NFR-S3)." \
  "**Given** en testkörning, **when** Testcontainers startar PostgreSQL, **then** alla Flyway-migreringar körs grönt och ingen rad i GLOBAL_PRICE_POINTS har FK till USERS (anonymisering, K8).")"

create_story "4" "US-4.2" "Produktsökning med autocomplete" "prio:should" "area:frontend" "$(story_body \
  "US-4.2" \
  "Sofia" \
  "kunna söka efter en produkt (t.ex. 'kaffe') och få förslag direkt" \
  "snabbt hitta prishistoriken" \
  "Should (K12)" \
  "K12, NFR-P4, ADR-012" \
  "**Given** sökfältet, **when** Sofia skriver ≥ 2 tecken, **then** HTMX skickar GET /api/search?q=... efter 500 ms debounce." \
  "**Given** sökanropet, **when** SQL körs mot PRODUCTS.name, **then** prefix-matchning via ILIKE används mot index idx_products_name_lower och LIMIT 10 tillämpas." \
  "**Given** sökresultatet, **when** svar returneras, **then** latency är < 200 ms p95 (NFR-P4), mätt via egen metric." \
  "**Given** flera matchande produkter, **when** resultatet returneras, **then** sortering sker på popularitet (antal RECEIPT_ITEMS-rader) fallande." \
  "**Given** ett autocomplete-svar, **when** UI renderar det, **then** listan har role='listbox' och pilarna fungerar med tangentbord (NFR-AC3)." \
  "**Given** att inga produkter matchar, **when** resultatet är tomt, **then** ett tomt state visas med hjälpsam text.")"

create_story "4" "US-4.3" "Produktsida med personlig prishistorik" "prio:must" "area:frontend" "$(story_body \
  "US-4.3" \
  "Anna" \
  "se hur ett pris för en specifik produkt har utvecklats för **mig** över tid" \
  "förstå om en vara blivit dyrare" \
  "Must (K4)" \
  "K4" \
  "**Given** Anna klickar på en produkt från sökresultatet, **when** sidan laddas, **then** GET /products/{id} visar produktnamn, kategori och en linjegraf med Annas egna priser." \
  "**Given** linjegrafen, **when** den renderas, **then** Y-axeln är pris per enhet och X-axeln är inköpsdatum, baserat på RECEIPT_ITEMS för Annas user_id (Row-Level Security via repository-lager)." \
  "**Given** att Anna har bara ett köp av produkten, **when** sidan visas, **then** empty state visas: 'Bara ett köp än så länge. Ladda upp fler kvitton för att se trender'." \
  "**Given** att en annan användare försöker hämta GET /products/{id} med receiptItemId som inte tillhör hen, **when** request behandlas, **then** ingen data läcker (filter på user_id i SQL)." \
  "**Given** att produkten har global statistik tillgänglig (GLOBAL_PRICE_POINTS), **when** Anna har samtyckt, **then** en andra linje visar 'Globalt snittpris'." \
  "**Given** att inget VAT-data finns, **when** sidan renderas, **then** Moms-kollen-modulen visas inte (avhängigt US-6.1).")"

create_story "4" "US-4.4" "Dashboard med månadsutgifter" "prio:must" "area:frontend" "$(story_body \
  "US-4.4" \
  "Anna" \
  "se hennes totalbelopp för månaden på dashboarden" \
  "snabbt få överblick" \
  "Must (K4)" \
  "K4, NFR-P1, ADR-013" \
  "**Given** att Anna loggar in, **when** /dashboard laddas, **then** widget 'Månadens utgifter' visar summan av RECEIPTS.total_amount för innevarande kalendermånad och jämför med samma datum föregående månad." \
  "**Given** att inga kvitton finns, **when** dashboarden renderas, **then** empty state visas: 'Välkommen! Ladda upp ditt första kvitto för att se trender'." \
  "**Given** att Anna har ≥ 3 kvitton, **when** dashboarden renderas, **then** widgeten 'Senaste kvittona' visar de 3 senaste kvittona med butik, datum, summa." \
  "**Given** dashboardanropet, **when** sidan renderas, **then** TTFB < 500 ms p95 (NFR-P1), mätt i Cloud Run." \
  "**Given** att kategori-data finns, **when** donut-grafen renderas, **then** den visar nedbrytning per produktkategori — källa för kategori beslutas i ADR-013." \
  "**Given** att en användare har inaktiverat samtycke, **when** dashboarden visas, **then** inga delar av UI visar global statistik.")"

# ---- Epic 5 stories ----
create_story "5" "US-5.1" "Anonymiserad lagring av global prisdata" "prio:must" "area:crowdsource" "$(story_body \
  "US-5.1" \
  "DPO" \
  "att den globala pris-poolen är oåterkalleligt anonym" \
  "GDPR inte ska gälla för dessa rader" \
  "Must (K8, K13)" \
  "K8, K13, NFR-D3, ADR-007" \
  "**Given** ett parsat kvitto från en användare som **samtyckt**, **when** parser-service skriver till GLOBAL_PRICE_POINTS, **then** posten innehåller endast product_id, price, city, year_month — **ingen** FK till USERS eller RECEIPTS." \
  "**Given** ett kvitto, **when** ort härleds, **then** endast ort (t.ex. 'Malmö') sparas — aldrig specifik butik eller postnummer." \
  "**Given** datum, **when** posten skapas, **then** year_month sparas som YYYY-MM — aldrig exakt datum eller tidsstämpel." \
  "**Given** att en användare **inte** samtyckt (share_anonymous_data = false), **when** kvittot parsas, **then** ingen rad skrivs till GLOBAL_PRICE_POINTS för det kvittot." \
  "**Given** en användare som raderar sitt konto, **when** ON DELETE CASCADE körs, **then** GLOBAL_PRICE_POINTS påverkas inte (det är ju anonymt) — verifieras med integrationstest." \
  "**Given** att en användare har < 3 köp i en specifik (city, year_month, product_id)-aggregat, **when** aggregat visas publikt, **then** datapunkten filtreras bort i frontend (k-anonymity ≥ 3).")"

create_story "5" "US-5.2" "Samtycke för crowdsourcing" "prio:should" "area:gdpr" "$(story_body \
  "US-5.2" \
  "Markus" \
  "aktivt kunna ge samtycke till att dela mina priser anonymt" \
  "bidra till global statistik" \
  "Should (K13)" \
  "K13, ADR-007" \
  "**Given** profilsidan, **when** Markus togglar 'Dela mina priser anonymt', **then** en modal visar exakt vad som delas (artikel, pris, ort, månad) och vad som **inte** delas." \
  "**Given** att Markus bekräftar i modalen, **when** request skickas, **then** USERS.share_anonymous_data = true och USERS.consent_updated_at får aktuell tidsstämpel." \
  "**Given** samtyckeshändelsen, **when** den loggas, **then** posten skrivs till audit-loggen (NFR-D6) med användarid, IP-hash och tidsstämpel." \
  "**Given** att Markus återkallar samtycket, **when** han togglar av, **then** flaggan sätts till false direkt; tidigare bidragna prispunkter ligger kvar eftersom de är anonymiserade." \
  "**Given** att Markus aldrig samtyckt, **when** han ser dashboarden, **then** inga widgets visar global statistik utan istället en infobox: 'Aktivera samtycke för att se global prisdata'." \
  "**Given** registreringsformuläret, **when** Markus skapar konto, **then** samtyckes-toggeln är **aldrig** förkryssad.")"

create_story "5" "US-5.3" "Öppen statistikvy för global prisutveckling" "prio:could" "area:crowdsource" "$(story_body \
  "US-5.3" \
  "Markus" \
  "kunna se global prisutveckling per produkt och ort" \
  "jämföra med min egen historik och bidra till transparens" \
  "Could (K14)" \
  "K14" \
  "**Given** Markus besöker /statistics/products/{id}, **when** sidan laddas, **then** en linjegraf visar GLOBAL_PRICE_POINTS aggregerat per year_month och city." \
  "**Given** att Markus filtrerar på ort, **when** filter aktiveras, **then** grafen uppdateras via HTMX utan sidladdning." \
  "**Given** en produkt med < 3 datapunkter i en cell, **when** grafen renderas, **then** den cellen visas som lucka, inte missvisande siffra (k-anonymity)." \
  "**Given** att Markus är utloggad, **when** han besöker statistikvyn, **then** sidan visas eftersom den är 'öppen' — ingen autentisering krävs." \
  "**Given** att Markus har samtyckt och har egen data, **when** sidan renderas, **then** en andra linje 'Mitt pris' visas på samma graf för jämförelse." \
  "**Given** datavolym (50 000 prispunkter), **when** sidan laddas, **then** TTFB < 1 sekund p95 — aggregering körs i SQL, inte i Java.")"

# ---- Epic 6 stories ----
create_story "6" "US-6.1" "Moms-kollen" "prio:could" "area:insights" "$(story_body \
  "US-6.1" \
  "Sofia" \
  "se om min butik faktiskt sänkte priserna efter momssänkningen" \
  "veta om de behållit marginalen" \
  "Could (K15)" \
  "K15" \
  "**Given** Sofia har kvitton både före och efter ett konfigurerbart 'moms-datum', **when** hon besöker /insights/vat, **then** vyn visar snittpris per produkt före och efter datumet baserat på RECEIPT_ITEMS.vat_rate." \
  "**Given** att en produkts pris sänkts ≥ momssänkningen, **when** raden renderas, **then** en grön tumme-upp-ikon visas: 'Butiken sänkte priset enligt momsen'." \
  "**Given** att en produkts pris är oförändrat trots momssänkning, **when** raden renderas, **then** en röd varningstriangel visas: 'Butiken behöll marginalen'." \
  "**Given** att Sofia saknar kvitton från före datumet, **when** vyn laddas, **then** empty state visas med CTA 'Ladda upp äldre kvitto'." \
  "**Given** att vyn beräknas, **when** SQL körs, **then** aggregering sker i en enda query med CASE WHEN purchase_date < :momsDate — inga N+1-anrop." \
  "**Given** att Sofia vill se underlag, **when** hon klickar på en produktrad, **then** hon dirigeras till produktsidan (US-4.3) med datumfiltret förvalt.")"

create_story "6" "US-6.2" "Krympflations-varning" "prio:could" "area:insights" "$(story_body \
  "US-6.2" \
  "Sofia" \
  "varnas om förpackningsstorleken minskat samtidigt som priset hållits" \
  "upptäcka dolda prishöjningar" \
  "Could (K16)" \
  "K16" \
  "**Given** två RECEIPT_ITEMS för samma product_id där quantity har minskat men price_per_unit är oförändrat eller högre, **when** Sofia besöker produktsidan, **then** en gul/röd badge-warning visar: 'Förpackningen minskade från X till Y men kilopriset är högre'." \
  "**Given** att produktens nuvarande pris jämförs, **when** kilopris beräknas, **then** beräkningen visas tydligt i UI: gammalt pris/kilo vs nytt pris/kilo." \
  "**Given** att en produkt inte har två datapunkter med olika storlekar, **when** sidan renderas, **then** varningen visas **inte** (false-positive-skydd)." \
  "**Given** krympflations-logiken, **when** den implementeras, **then** den är en separat domänklass ShrinkflationDetector med ≥ 80 % testtäckning (NFR-M1)." \
  "**Given** att varningen visas, **when** Sofia klickar på den, **then** en förklaring expanderar med definitionen av krympflation och varför det är relevant." \
  "**Given** att skärmläsare används, **when** varningen renderas, **then** den har role='alert' och aria-live='polite'.")"

# ---- Epic 7 stories ----
create_story "7" "US-7.1" "Audit-logg för säkerhetshändelser" "prio:must" "area:gdpr" "$(story_body \
  "US-7.1" \
  "säkerhetsgranskare" \
  "att inloggningar, samtyckesändringar, dataexport och radering loggas separat" \
  "kunna granska efter en eventuell incident" \
  "Must" \
  "K5, K8, NFR-D6" \
  "**Given** en lyckad inloggning, **when** händelsen sker, **then** en post skrivs i AUDIT_LOG med user_id, event_type=LOGIN, ip_hash, timestamp, trace_id." \
  "**Given** en samtyckesändring, **when** användaren togglar, **then** posten skrivs med event_type=CONSENT_CHANGED och både gammalt och nytt värde." \
  "**Given** en dataexport (US-7.2), **when** den körs, **then** event_type=DATA_EXPORTED med format och storlek loggas." \
  "**Given** en kontoradering (US-7.4), **when** den körs, **then** event_type=ACCOUNT_DELETED loggas innan raden raderas från USERS." \
  "**Given** audit-loggar, **when** retention-jobbet kör, **then** poster ≥ 1 år gamla raderas automatiskt (NFR-D6)." \
  "**Given** att en post i AUDIT_LOG skrivs, **when** den persisteras, **then** den lagras i en separat bucket eller tabell med skrivskydd för applikationen ('write-once') — manipulation måste vara spårbar.")"

create_story "7" "US-7.2" "Dataexport (Artikel 15 + 20)" "prio:must" "area:gdpr" "$(story_body \
  "US-7.2" \
  "Anna" \
  "kunna ladda ned alla mina data i JSON eller CSV" \
  "uppfylla min rätt till tillgång och dataportabilitet" \
  "Must (K8)" \
  "K8, GDPR Art. 15, 20" \
  "**Given** profilsidan, **when** Anna klickar 'Exportera min data', **then** en modal låter henne välja format (JSON eller CSV)." \
  "**Given** Anna väljer JSON, **when** GET /api/profile/export?format=json körs, **then** svaret innehåller konto-data, samtyckes-history, alla RECEIPTS och RECEIPT_ITEMS som tillhör hennes user_id." \
  "**Given** Anna väljer CSV, **when** samma endpoint anropas med format=csv, **then** en ZIP med separata CSV-filer per tabell returneras." \
  "**Given** att exporten skapas, **when** filen levereras, **then** ingen data om andra användare läcker — verifieras med integrationstest med två användare." \
  "**Given** att exporten är klar, **when** Anna får filen, **then** händelsen loggas i audit-loggen (US-7.1)." \
  "**Given** att exportfilen genereras, **when** den serveras, **then** Content-Disposition: attachment och Cache-Control: no-store är satta så att filen inte cachas av webbläsare eller proxies.")"

create_story "7" "US-7.3" "Radering av konto (Artikel 17)" "prio:must" "area:gdpr" "$(story_body \
  "US-7.3" \
  "Anna" \
  "kunna radera mitt konto fullständigt" \
  "utöva min rätt att bli glömd" \
  "Must (K8)" \
  "K8, NFR-D2, NFR-D3, ADR-007" \
  "**Given** profilsidan, **when** Anna klickar 'Radera mitt konto', **then** en modal kräver att hon skriver 'RADERA' i ett textfält för att aktivera bekräftelseknappen." \
  "**Given** dubbelbekräftelse, **when** Anna bekräftar slutligen, **then** DELETE FROM USERS WHERE id = :userId triggar ON DELETE CASCADE så att RECEIPTS och RECEIPT_ITEMS också raderas (NFR-D2)." \
  "**Given** att raderingen körs, **when** den slutförs, **then** ett asynkront jobb raderar alla PDF:er i GCS för användarens path (gs://<bucket>/<userId>/*) inom 24 h." \
  "**Given** att kontot är raderat, **when** Anna försöker logga in, **then** loginflödet svarar med generiskt meddelande 'Fel e-post eller lösenord' (ingen kontoexistens-läcka)." \
  "**Given** att GLOBAL_PRICE_POINTS är anonyma, **when** raderingen körs, **then** dessa rader **påverkas inte** (NFR-D3) — verifieras med integrationstest." \
  "**Given** raderingen, **when** den är klar, **then** ett bekräftelsemejl skickas (post-MVP) eller motsvarande UI-bekräftelse visas, och audit-logg-posten finns (US-7.1).")"

create_story "7" "US-7.4" "Återkallande av samtycke" "prio:must" "area:gdpr" "$(story_body \
  "US-7.4" \
  "Markus" \
  "kunna återkalla mitt crowdsourcing-samtycke när som helst" \
  "ha kontroll över min data framöver" \
  "Must (K8)" \
  "K8, GDPR Art. 7.3" \
  "**Given** att Markus tidigare samtyckt, **when** han togglar av i profilen, **then** USERS.share_anonymous_data = false direkt." \
  "**Given** återkallandet, **when** händelsen loggas, **then** audit-loggen (US-7.1) får event_type=CONSENT_CHANGED med gammalt värde true, nytt värde false." \
  "**Given** återkallandet, **when** framtida kvitton parsas, **then** ingen rad skrivs till GLOBAL_PRICE_POINTS." \
  "**Given** redan delade prispunkter, **when** Markus återkallar, **then** dessa förblir i GLOBAL_PRICE_POINTS (de är anonyma) — modalen förklarar detta tydligt." \
  "**Given** att Markus ångrar sig, **when** han togglar på igen, **then** flödet i US-5.2 körs på nytt och en ny audit-logg skapas." \
  "**Given** rättslig grund 'samtycke', **when** Markus återkallar, **then** ingen försämring av övriga tjänster sker (han kan fortfarande använda hela appen).")"

# ---- Epic 8 stories ----
create_story "8" "US-8.1" "Komponentkatalog på /dev/components" "prio:should" "area:design-a11y" "$(story_body \
  "US-8.1" \
  "utvecklare" \
  "ha en intern sida som visar alla återanvändbara Thymeleaf-fragment" \
  "snabbt kunna jämföra och testa UI-komponenter" \
  "Should (K11)" \
  "K11, NFR-M5" \
  "**Given** core-service i dev-profil, **when** utvecklaren går till /dev/components, **then** sidan renderar alla fragment ur fragments/components.html." \
  "**Given** routen, **when** prod-profilen är aktiv, **then** routen returnerar 404 Not Found (säkerhet)." \
  "**Given** att ett nytt fragment läggs till, **when** utvecklaren följer guiden, **then** fragmentet syns automatiskt på /dev/components utan extra konfiguration." \
  "**Given** att HTMX-komponenter visas, **when** utvecklaren klickar på dem, **then** de svarar utan sidladdning — interaktion testas isolerat." \
  "**Given** varje komponent på sidan, **when** den renderas, **then** en kort förklarande text visar avsedd användning + länk till relevant UX-sektion." \
  "**Given** att sidan blir lång, **when** den scrollas, **then** en sidnav med ankarlänkar till varje kategori finns.")"

create_story "8" "US-8.2" "WCAG 2.1 AA-konformans" "prio:must" "area:design-a11y" "$(story_body \
  "US-8.2" \
  "användare med funktionsnedsättning" \
  "kunna använda hela appen med tangentbord och skärmläsare" \
  "ha samma åtkomst som andra användare" \
  "Must" \
  "K11, NFR-AC1, AC2, AC3, AC4, AC5, AC6, ADR-014" \
  "**Given** varje sida i appen, **when** axe-core eller pa11y körs i CI (NFR-AC4), **then** ingen error-nivå-violation rapporteras." \
  "**Given** all text, **when** kontrasten mäts, **then** ratio ≥ 4,5:1 för normaltext och ≥ 3:1 för stor text (NFR-AC2)." \
  "**Given** huvudflödet (login, ladda upp, se kvitto), **when** användaren använder enbart tangentbord, **then** alla interaktiva element är nåbara via Tab med synlig fokus-ring (NFR-AC3)." \
  "**Given** huvudflödet, **when** det testas med NVDA/VoiceOver (NFR-AC5), **then** alla actions kan utföras utan att skärmläsare-användaren blir blockerad — minst en manuell genomgång per release." \
  "**Given** användarens system har prefers-reduced-motion, **when** UI renderar animationer, **then** konfetti och slide-animationer stängs av (NFR-AC6)." \
  "**Given** modaler, **when** de öppnas, **then** de har role='dialog', aria-modal='true', fokus fångas inuti modalen, och Esc stänger dem.")"

# ---- Epic 9 stories ----
create_story "9" "US-9.1" "Distribuerad spårning ände-till-ände" "prio:must" "area:observability" "$(story_body \
  "US-9.1" \
  "driftansvarig" \
  "att varje request följs som en sammanhängande trace genom både core-service och parser-service" \
  "snabbt kunna felsöka fel i det asynkrona flödet" \
  "Must (K10)" \
  "K10, NFR-O1, NFR-O2" \
  "**Given** en PDF-uppladdning, **when** core-service tar emot request, **then** ett OTel-span skapas med trace_id som propageras till Pub/Sub-attribut." \
  "**Given** att parser-service konsumerar meddelandet, **when** behandling startar, **then** ett barn-span länkas till samma trace_id så att hela flödet syns som en trace i GCP Trace." \
  "**Given** strukturerade JSON-loggar (NFR-O2), **when** logg-rader skrivs, **then** varje rad innehåller trace_id och span_id för korrelation." \
  "**Given** att en användare rapporterar fel med en traceId, **when** driftansvarig söker, **then** alla loggar och spans för det trace_id kan listas i Cloud Trace inom < 1 minut." \
  "**Given** att loggar skrivs, **when** PII upptäcks (e-post, lösenord), **then** Logback-mask ersätter värdet med [redacted] (NFR-O5)." \
  "**Given** sampling, **when** trafik ökar, **then** OTel-sampler konfigureras till adaptiv (≥ 100 % i dev, ≤ 10 % i prod).")"

create_story "9" "US-9.2" "Metrics och dashboards för KPI:er" "prio:must" "area:observability" "$(story_body \
  "US-9.2" \
  "driftansvarig" \
  "ha dashboards för bearbetningstid, felgrad och latency" \
  "följa upp SLO:er" \
  "Must" \
  "NFR-O3, NFR-O4, NFR-O6" \
  "**Given** att Micrometer är konfigurerat, **when** appen körs, **then** metrics http_requests_total, receipt_processing_seconds, parser_success_ratio exporteras till GCP (NFR-O3)." \
  "**Given** Cloud Monitoring, **when** dashboarden öppnas, **then** widgets visar p50/p95/p99 för latency per endpoint, felgrad (5xx) och DLQ-djup." \
  "**Given** SLO för TTFB < 500 ms p95 (NFR-P1), **when** SLO bryts under 5-min-fönster, **then** en larmpolicy triggar (NFR-O4) till på-jour-kanalen." \
  "**Given** SLO för felgrad < 1 % (NFR-A2), **when** ratio överskrids i 10 min, **then** larm går till samma kanal med direktlänk till loggar." \
  "**Given** dashboards, **when** de skapas, **then** de är versionshanterade i Terraform — inte handbyggda i Cloud Monitoring UI." \
  "**Given** att en utvecklare lägger till en ny metric, **when** PR mergas, **then** dokumentation uppdateras i /observability/README.md (eller motsvarande, NFR-M4).")"

create_story "9" "US-9.3" "DLQ-larm och driftrunbook" "prio:must" "area:observability" "$(story_body \
  "US-9.3" \
  "driftansvarig" \
  "få larm när meddelanden hamnar i DLQ" \
  "snabbt kunna utreda och eventuellt replaya" \
  "Must" \
  "NFR-A4" \
  "**Given** Pub/Sub-topic receipt-uploads-dlq, **when** ett meddelande landar, **then** Cloud Monitoring-metric num_undelivered_messages ökar och larm triggas inom 5 min (NFR-A4)." \
  "**Given** larmet, **when** det skickas, **then** det innehåller länk till DLQ:n i GCP-konsolen och till runbook-sidan." \
  "**Given** runbook, **when** driftansvarig öppnar den, **then** den beskriver i steg-form hur DLQ-meddelanden inspekteras, hur trace följs och hur de replay:as." \
  "**Given** att ett DLQ-meddelande replayas, **when** det skickas tillbaka, **then** Cloud Monitoring-metric dlq_replay_count ökar och kvittostatusen uppdateras till PENDING igen." \
  "**Given** att DLQ:n är tom efter en incident, **when** Cloud Monitoring upptäcker det, **then** ett 'recovery'-event loggas för att stänga incidenten automatiskt." \
  "**Given** kvartalsvis återhämtningstest (NFR-B4), **when** testet körs, **then** ett kontrollerat DLQ-fall triggas och hela run-boken körs igenom.")"

log "=== Klart ==="
if (( APPLY == 0 )); then
  log "Dry-run färdig. Kör med --apply för att skapa issues på riktigt:"
  log "    ./scripts/create-github-issues.sh --apply"
else
  log "Skapade epics och sub-issues i $REPO."
fi
