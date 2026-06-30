#!/usr/bin/env bash
# create-github-issues.sh
# ---------------------------------------------------------------------------
# Creates GitHub issues (epics) and sub-issues (user stories) for Matdata 2.0
# based on user-stories.md.
#
# The script calls your LOCAL installation of `gh` (GitHub CLI). It creates
# no issues until you have run it with --apply. Without --apply a dry-run is
# performed that only prints what WOULD be created.
#
# Usage:
#   ./scripts/create-github-issues.sh                 # dry-run (default)
#   ./scripts/create-github-issues.sh --apply         # creates issues for real
#   ./scripts/create-github-issues.sh --apply -R owner/repo
#
# Prerequisites:
#   * gh >= 2.40 installed and signed in: `gh auth status`
#   * Permission to create issues and labels in the target repo
#   * `jq` (to handle issue numbers when linking sub-issues)
#   * The script is idempotent: existing issues are not updated, just
#     skipped.
# ---------------------------------------------------------------------------
set -euo pipefail

# ---------------- Configuration ----------------
DEFAULT_REPO="pekelund-dev/matdata-2.0"
REPO="${REPO:-$DEFAULT_REPO}"
APPLY=0

usage() {
  cat <<'EOF'
Usage: create-github-issues.sh [OPTIONS]

Options:
  --apply                Create issues for real (default: dry-run).
  -R, --repo OWNER/REPO  Target repo (default: pekelund-dev/matdata-2.0).
  -h, --help             Show this help.

The script is idempotent — if an epic or user story already exists as an
issue (matched on title) it is skipped.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=1; shift ;;
    -R|--repo) REPO="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

# ---------------- Helper functions ----------------
# The log functions write to stderr so that stdout only contains issue
# numbers (which some functions return via command substitution).
log()  { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }
warn() { printf '[%s] WARN: %s\n' "$(date +%H:%M:%S)" "$*" >&2; }
die()  { printf '[%s] ERROR: %s\n' "$(date +%H:%M:%S)" "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

require_cmd gh
require_cmd jq

if (( APPLY == 1 )); then
  gh auth status >/dev/null 2>&1 || die "gh is not signed in. Run: gh auth login"
  # Verify that the repo exists and that we have write permissions
  gh repo view "$REPO" >/dev/null 2>&1 || die "Cannot see repo $REPO via gh"
fi

if (( APPLY == 0 )); then
  log "DRY-RUN — no issues or labels are created. Run with --apply to execute."
else
  log "APPLY — will create issues and labels in $REPO"
fi

# ---------------- Labels ----------------
# Format: name|colour(hex without #)|description
LABELS=(
  "epic|8B5CF6|Parent issue that groups a set of user stories."
  "user-story|3B82F6|Implementable user story with Given/When/Then ACs."
  "prio:must|B91C1C|MoSCoW Must — required for the MVP."
  "prio:should|D97706|MoSCoW Should — important but not blocking."
  "prio:could|65A30D|MoSCoW Could — post-MVP."
  "area:infra|0F766E|Infrastructure, IaC, CI/CD, deployment."
  "area:auth|6D28D9|Authentication, sessions, passwords."
  "area:parsing|0369A1|PDF parsing, Pub/Sub, async flows."
  "area:frontend|DB2777|UI, Thymeleaf, HTMX, Tailwind."
  "area:gdpr|166534|GDPR, consent, data export, deletion, audit."
  "area:observability|7C2D12|OTel, metrics, alerts, runbooks."
  "area:crowdsource|1D4ED8|Global price pool, anonymisation."
  "area:insights|9D174D|Thematic views (Moms-kollen, shrinkflation)."
  "area:design-a11y|4D7C0F|Design system, component catalogue, WCAG."
)

ensure_label() {
  local name="$1" color="$2" desc="$3"
  if (( APPLY == 0 )); then
    log "[dry-run] would ensure label: $name (#$color)"
    return 0
  fi
  if gh label list -R "$REPO" --limit 200 --json name --jq '.[].name' | grep -Fxq "$name"; then
    log "label already exists: $name"
  else
    gh label create "$name" --color "$color" --description "$desc" -R "$REPO" >/dev/null
    log "created label: $name"
  fi
}

log "=== Step 1/3: ensure labels ==="
for entry in "${LABELS[@]}"; do
  IFS='|' read -r name color desc <<<"$entry"
  ensure_label "$name" "$color" "$desc"
done

# ---------------- Issue helpers ----------------

# Find issue number for an exact title. Writes the issue number to stdout if
# found, otherwise an empty string.
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

# Create or skip an issue. Writes the issue number to stdout.
# Args: title, body, label1, label2, ...
create_issue_if_missing() {
  local title="$1"; shift
  local body="$1"; shift
  local labels=("$@")
  local existing
  existing="$(find_issue_number_by_title "$title")"
  if [[ -n "$existing" ]]; then
    log "issue already exists (#$existing): $title"
    printf '%s\n' "$existing"
    return 0
  fi
  if (( APPLY == 0 )); then
    log "[dry-run] would create issue: $title  [labels: ${labels[*]}]"
    printf '\n'  # Empty issue number in dry-run
    return 0
  fi
  local label_args=()
  for l in "${labels[@]}"; do
    label_args+=( --label "$l" )
  done
  local url num
  url="$(gh issue create -R "$REPO" --title "$title" --body "$body" "${label_args[@]}")"
  num="${url##*/}"
  log "created issue #$num: $title"
  printf '%s\n' "$num"
}

# Link a sub-issue to a parent via GitHub's sub-issues API.
# Requires that both parent and child exist. No-op in dry-run.
link_sub_issue() {
  local parent_num="$1" child_num="$2"
  if (( APPLY == 0 )) || [[ -z "$parent_num" || -z "$child_num" ]]; then
    log "[dry-run] would link sub-issue #$child_num under parent #$parent_num"
    return 0
  fi
  local owner repo child_id
  owner="${REPO%%/*}"
  repo="${REPO##*/}"
  # The sub-issues API requires the child issue's internal id, not the issue number
  child_id="$(gh api "repos/$owner/$repo/issues/$child_num" --jq '.id')"
  if gh api -X POST "repos/$owner/$repo/issues/$parent_num/sub_issues" \
      -f sub_issue_id="$child_id" >/dev/null 2>&1; then
    log "linked #$child_num as sub-issue to #$parent_num"
  else
    warn "could not link #$child_num under #$parent_num (sub-issues API may not be enabled). Adding parent reference in the body instead."
    gh issue comment "$child_num" -R "$REPO" \
      --body "Parent epic: #$parent_num" >/dev/null || true
  fi
}

# ---------------- Content: epics and user stories ----------------
#
# Each epic has: title, area label, short description.
# Each user story has: id, title, prio, area, body (markdown).
#
# The body is deliberately short — the full Given/When/Then ACs are in
# user-stories.md and are linked from the issue, but the key points are
# repeated in the body so that the issue is meaningful even standalone.

# Helper: writes the story body in a HEREDOC-friendly format.
story_body() {
  local id="$1" persona="$2" want="$3" why="$4" prio="$5" trace="$6"
  shift 6
  local acs=("$@")
  local body
  body="**As** $persona **I want** $want **so that** $why.

**Story ID:** $id
**Priority:** $prio
**Traceability:** $trace

### Acceptance criteria (Given/When/Then)
"
  local i=1
  for ac in "${acs[@]}"; do
    body+="${i}. $ac
"
    i=$((i+1))
  done
  body+="
### Definition of Done
See the DoD checklist in [user-stories.md §1.3](../blob/main/user-stories.md#13-definition-of-done-story-level) plus the story-specific items under $id in [user-stories.md](../blob/main/user-stories.md).
"
  printf '%s' "$body"
}

epic_body() {
  local epic_id="$1" goal="$2" krav="$3" nfr="$4" phase="$5" stories="$6"
  cat <<EOF
**Epic $epic_id**

**Goal:** $goal

**Primary K-requirements:** $krav
**NFR:** $nfr
**Phase:** $phase

### Included user stories
$stories

### Source
See [user-stories.md](../blob/main/user-stories.md) for the full acceptance criteria, DoD and traceability matrix.
EOF
}

# ---------------- Step 2/3: create epics ----------------
log "=== Step 2/3: create epic issues ==="

declare -A EPIC_NUM  # epic_id -> issue number

create_epic() {
  local epic_id="$1" title="$2" area_label="$3" body="$4"
  local num
  num="$(create_issue_if_missing "$title" "$body" "epic" "$area_label")"
  EPIC_NUM["$epic_id"]="$num"
}

create_epic "1" "[Epic 1] Infrastructure and DevOps foundation" "area:infra" "$(epic_body \
  "1 — Infrastructure and DevOps foundation" \
  "Before a single business feature is implemented, the repo, CI/CD, IaC and security scanning must be in place so that every PR generates an isolated, runnable environment." \
  "K6, K7" \
  "NFR-SEC6, SEC7, SEC8, B5" \
  "Phase 1" \
  "- US-1.1 CI pipeline for PR builds
- US-1.2 Terraform module for base infrastructure
- US-1.3 PR environment with Neon database branching
- US-1.4 Health and smoke checks after deployment")"

create_epic "2" "[Epic 2] Account and authentication" "area:auth" "$(epic_body \
  "2 — Account and authentication" \
  "Secure, session-based sign-in where the user sees only their own receipts." \
  "K5" \
  "NFR-SEC1–SEC5, SEC10, D4" \
  "Phase 4–5" \
  "- US-2.1 Registration with e-mail and password
- US-2.2 Sign-in with rate limiting
- US-2.3 Sign-out and CSRF protection
- US-2.4 Session management across multiple instances")"

create_epic "3" "[Epic 3] Receipt upload and asynchronous parsing" "area:parsing" "$(epic_body \
  "3 — Receipt upload and asynchronous parsing" \
  "Implement the core flow 'PDF in → parsed data out' with an asynchronous architecture via Pub/Sub." \
  "K1, K2, K3, K9, K12" \
  "NFR-A3, A4, P2, P3, M1, S4" \
  "Phase 2–4" \
  "- US-3.1 PDF upload from Kivra
- US-3.2 Asynchronous parsing via the Parser Service
- US-3.3 EAN/PLU masking for weight items
- US-3.4 HTMX polling for status feedback
- US-3.5 Dead Letter Queue and failure monitoring")"

create_epic "4" "[Epic 4] Personal price history and search" "area:frontend" "$(epic_body \
  "4 — Personal price history and search" \
  "The user can see their own receipts, search for products and understand their own price development." \
  "K4, K12" \
  "NFR-P1, P4, S3" \
  "Phase 2 (data model) + Phase 4–5 (UI)" \
  "- US-4.1 Normalised data model for receipts and products
- US-4.2 Product search with autocomplete
- US-4.3 Product page with personal price history
- US-4.4 Dashboard with monthly expenses")"

create_epic "5" "[Epic 5] Crowdsourcing and global statistics" "area:crowdsource" "$(epic_body \
  "5 — Crowdsourcing and global statistics" \
  "Build the anonymised price pool and let the user see global price development — without leaking individual identity." \
  "K8, K13, K14" \
  "NFR-D3" \
  "Phase 3 + post-MVP" \
  "- US-5.1 Anonymised storage of global price data
- US-5.2 Consent for crowdsourcing
- US-5.3 Open statistics view of global price development")"

create_epic "6" "[Epic 6] Thematic insights (Moms-kollen and shrinkflation)" "area:insights" "$(epic_body \
  "6 — Thematic insights (Moms-kollen and shrinkflation)" \
  "Value-added views that drive engagement. Classified as 'Could have', post-MVP." \
  "K15, K16" \
  "—" \
  "Post-MVP (C)" \
  "- US-6.1 Moms-kollen
- US-6.2 Shrinkflation warning")"

create_epic "7" "[Epic 7] GDPR and user rights" "area:gdpr" "$(epic_body \
  "7 — GDPR and user rights" \
  "Implement Articles 13–22 in the code so that the DPIA is approved before the public launch." \
  "K5, K8" \
  "NFR-D2, D3, D6" \
  "Phase 4–5" \
  "- US-7.1 Audit log for security events
- US-7.2 Data export (Article 15 + 20)
- US-7.3 Account deletion (Article 17)
- US-7.4 Consent withdrawal")"

create_epic "8" "[Epic 8] Design system and accessibility" "area:design-a11y" "$(epic_body \
  "8 — Design system and accessibility" \
  "Establish a reusable component catalogue and ensure WCAG 2.1 AA." \
  "K11, K12" \
  "NFR-AC1–AC6, M5" \
  "Phase 4 + AC tests in Phase 5" \
  "- US-8.1 Component catalogue at /dev/components
- US-8.2 WCAG 2.1 AA conformance")"

create_epic "9" "[Epic 9] Observability and operations" "area:observability" "$(epic_body \
  "9 — Observability and operations" \
  "Ensure that we know when the system breaks — and why." \
  "K10" \
  "NFR-O1, O2, O3, O4, A1, A2, A4" \
  "Phase 3 + launch criteria in Phase 5" \
  "- US-9.1 Distributed tracing end-to-end
- US-9.2 Metrics and dashboards for KPIs
- US-9.3 DLQ alerts and operations runbook")"

# ---------------- Step 3/3: create user stories as sub-issues ----------------
log "=== Step 3/3: create user stories as sub-issues ==="

create_story() {
  local epic_id="$1" story_id="$2" short_title="$3" prio_label="$4" area_label="$5" body="$6"
  local title="$story_id $short_title"
  local parent_num="${EPIC_NUM[$epic_id]:-}"
  local num
  num="$(create_issue_if_missing "$title" "$body" "user-story" "$prio_label" "$area_label")"
  if (( APPLY == 0 )); then
    log "[dry-run]   ↳ would be linked as sub-issue under Epic $epic_id"
    return 0
  fi
  if [[ -n "$num" && -n "$parent_num" ]]; then
    link_sub_issue "$parent_num" "$num"
  fi
}

# ---- Epic 1 stories ----
create_story "1" "US-1.1" "CI pipeline for PR builds" "prio:must" "area:infra" "$(story_body \
  "US-1.1" \
  "developer" \
  "every Pull Request to automatically build both Spring Boot services, run unit tests and static analysis" \
  "I can get fast feedback before merging" \
  "Must (K6)" \
  "K6, NFR-SEC6, NFR-SEC7, NFR-SEC8, NFR-M2" \
  "**Given** a developer opens a PR against main, **when** GitHub Actions starts, **then** the workflow build.yml runs mvn verify for both core-service and parser-service in parallel." \
  "**Given** a PR build, **when** the build job runs, **then** CodeQL (NFR-SEC7) and the Dependabot report (NFR-SEC6) are run and block merge on error-level findings." \
  "**Given** a PR build, **when** the code is formatted incorrectly, **then** Spotless or an equivalent formatter (NFR-M2) marks the check as failed." \
  "**Given** a successful PR build, **when** all checks are green, **then** Docker images are published to the GitHub Container Registry with the tag pr-<nr>-<sha>." \
  "**Given** a GCP deploy from CI, **when** the workflow authenticates, **then** Workload Identity Federation (NFR-SEC8) is used — **no** long-lived service-account keys are stored in GitHub Secrets." \
  "**Given** a PR build takes > 10 minutes, **when** the build time is measured, **then** a GitHub Actions cache is used for Maven dependencies so that the median build time is ≤ 6 minutes.")"

create_story "1" "US-1.2" "Terraform module for base infrastructure" "prio:must" "area:infra" "$(story_body \
  "US-1.2" \
  "developer" \
  "GCP resources (GCS bucket, Pub/Sub topic, Cloud Run services, IAM) and the Neon project to be provisioned via Terraform" \
  "environments can be recreated reproducibly" \
  "Must (K7)" \
  "K7, NFR-B5, ADR-006" \
  "**Given** a new GCP project, **when** terraform apply is run from /terraform, **then** a GCS bucket, the Pub/Sub topic receipt-uploads, the DLQ topic, two Cloud Run services and two service accounts are created without manual steps." \
  "**Given** the Terraform modules, **when** terraform validate is run in CI, **then** all modules are validated and tflint/checkov flag no open findings with severity ≥ high." \
  "**Given** an existing environment state, **when** Terraform is planned, **then** the state is stored remotely (GCS bucket with versioning and locking via Cloud Storage) — never locally." \
  "**Given** a Pull Request that changes Terraform code, **when** the PR is opened, **then** CI posts the terraform plan output as a PR comment." \
  "**Given** the Neon project, **when** Terraform runs, **then** the main branch and the production database role are provisioned via the Neon Terraform provider with a budget alert enabled." \
  "**Given** a disaster where the whole GCP project is lost, **when** Terraform is applied against a new project, **then** the entire infrastructure can be recreated in ≤ 1 hour (NFR-B5).")"

create_story "1" "US-1.3" "PR environment with Neon database branching" "prio:must" "area:infra" "$(story_body \
  "US-1.3" \
  "developer" \
  "every PR to get an isolated database and Cloud Run deployment" \
  "I can test migrations and new features against a clean environment without affecting prod" \
  "Must (K6)" \
  "K6" \
  "**Given** a new PR is opened, **when** the workflow pr-environment.yml is triggered, **then** a Neon database branch is created from main with the suffix pr-<nr>." \
  "**Given** the PR environment is up, **when** the workflow is done, **then** a PR comment is published with URLs to core-service, parser-service and the Neon branch." \
  "**Given** two open PRs at the same time, **when** they are deployed, **then** they use separate Pub/Sub topics per PR to prevent message collisions." \
  "**Given** a PR is closed or merged, **when** the workflow pr-teardown.yml is triggered, **then** the Cloud Run revisions, Pub/Sub topics and Neon branch are deleted within 5 minutes." \
  "**Given** a PR deployment that fails, **when** the workflow breaks, **then** the error is reported as a PR check with a direct link to get_job_logs and the Neon branch is deleted despite the failure (cleanup-step if: always())." \
  "**Given** Flyway migrations are present in the PR, **when** the PR environment starts, **then** the migrations are run against the PR database branch automatically on deploy.")"

create_story "1" "US-1.4" "Health and smoke checks after deployment" "prio:must" "area:infra" "$(story_body \
  "US-1.4" \
  "operations engineer" \
  "every production deployment to be verified with smoke tests" \
  "broken releases are caught before users are affected" \
  "Must" \
  "K6, NFR-A1, NFR-A2" \
  "**Given** a deployment to the prod environment, **when** the core-service revision gets traffic, **then** GET /healthz returns 200 OK with status: UP." \
  "**Given** a green health check, **when** the workflow continues, **then** the smoke test runs GET /login and verifies that the page responds 200 and contains a CSRF token." \
  "**Given** a failed smoke check, **when** Cloud Run detects the failure, **then** traffic is rolled back to the previous revision (gradual rollout config) within 60 seconds." \
  "**Given** a deployment, **when** it succeeds, **then** Cloud Monitoring annotates the deployment event so that the error rate can be correlated with releases." \
  "**Given** a production incident, **when** the team needs to know the latest deployment, **then** the git tag prod-<date> is on the commit that corresponds to the current revision.")"

# ---- Epic 2 stories ----
create_story "2" "US-2.1" "Registration with e-mail and password" "prio:must" "area:auth" "$(story_body \
  "US-2.1" \
  "Anna" \
  "to be able to create an account with my e-mail and a password" \
  "I can start uploading receipts" \
  "Must (K5)" \
  "K5, NFR-SEC4, NFR-SEC5, ADR-009" \
  "**Given** the registration form, **when** Anna fills in a valid e-mail and a password ≥ 12 characters, **then** the account is created and she is signed in immediately with a new session cookie." \
  "**Given** a password that is < 12 characters or is in the pwned-passwords list, **when** the form is submitted, **then** a plain-language error is shown under the field and the account is **not** created." \
  "**Given** that passwords are stored, **when** the row is written to USERS, **then** password_hash is a BCrypt hash with cost ≥ 12 (NFR-SEC4) and the plaintext never remains in logs or memory after the request." \
  "**Given** an already-registered e-mail, **when** someone tries to register the same address, **then** the system replies with a generic message to avoid leaking account existence." \
  "**Given** a successful registration, **when** the session is created, **then** Spring Security's session regeneration is run (NFR-SEC5) and the cookie is set as HttpOnly, Secure, SameSite=Lax." \
  "**Given** a registration attempt, **when** the user does not actively tick the consent for crowdsourcing, **then** USERS.share_anonymous_data = false (default).")"

create_story "2" "US-2.2" "Sign-in with rate limiting" "prio:must" "area:auth" "$(story_body \
  "US-2.2" \
  "user" \
  "to be able to sign in with my e-mail and password" \
  "I can access my account without malicious actors being able to brute-force their way in" \
  "Must (K5)" \
  "K5, NFR-SEC10" \
  "**Given** correct credentials, **when** the form is submitted, **then** the user is redirected to /dashboard with a new session." \
  "**Given** incorrect credentials, **when** the form is submitted, **then** the error message is generic: 'Wrong e-mail or password' — no indication of which field was wrong." \
  "**Given** 5 failed attempts from the same IP within 10 minutes, **when** a sixth attempt is made, **then** the call returns 429 Too Many Requests (NFR-SEC10) and a recovery time is shown." \
  "**Given** rate limiting is triggered, **when** the event is logged, **then** the entry is written to the audit log (NFR-D6) without leaking whether the e-mail exists in the system." \
  "**Given** that a user is already signed in, **when** she visits /login, **then** the page redirects to /dashboard automatically." \
  "**Given** a successful sign-in, **when** the session is reused, **then** Spring Security regenerates the session ID (NFR-SEC5) to protect against session fixation.")"

create_story "2" "US-2.3" "Sign-out and CSRF protection" "prio:must" "area:auth" "$(story_body \
  "US-2.3" \
  "user" \
  "to be able to sign out securely" \
  "no one else can keep using my account from my device" \
  "Must (K5)" \
  "K5, NFR-SEC3" \
  "**Given** a signed-in session, **when** the user clicks 'Sign out', **then** the session is invalidated server-side and the cookie is cleared in the client." \
  "**Given** the sign-out form, **when** the request is sent, **then** it requires a valid X-XSRF-TOKEN header (NFR-SEC3) — GET-based sign-out is blocked." \
  "**Given** a signed-out session, **when** the user navigates back via the browser history, **then** protected pages respond with a redirect to /login (Cache-Control: no-store)." \
  "**Given** that HTMX calls are made from a signed-in page, **when** the request is sent, **then** the X-XSRF-TOKEN header is included automatically." \
  "**Given** a sign-out, **when** the event happens, **then** it is logged in the audit log (NFR-D6) with the trace ID.")"

create_story "2" "US-2.4" "Session management across multiple instances" "prio:must" "area:auth" "$(story_body \
  "US-2.4" \
  "operations engineer" \
  "sessions to be stored in the database (JDBC)" \
  "Cloud Run can scale up to multiple instances without signing the user out" \
  "Must" \
  "K5, NFR-D4" \
  "**Given** two core-service instances behind Cloud Run, **when** a user signs in against instance A and the next request goes to instance B, **then** the session is still valid." \
  "**Given** Spring Session JDBC, **when** the session is created, **then** the entry is written to the SPRING_SESSION table in Neon PostgreSQL." \
  "**Given** an inactive session for 30 days (NFR-D4), **when** the cleanup job runs daily, **then** the session is removed from the database." \
  "**Given** that a user signs out, **when** the request is handled, **then** the entry is deleted immediately from SPRING_SESSION." \
  "**Given** that Neon is temporarily unavailable, **when** the session lookup fails, **then** the user gets an error message and an alert is triggered (NFR-A4).")"

# ---- Epic 3 stories ----
create_story "3" "US-3.1" "PDF upload from Kivra" "prio:must" "area:parsing" "$(story_body \
  "US-3.1" \
  "Anna" \
  "to be able to upload a PDF file from Kivra via drag-and-drop" \
  "I can register a new receipt" \
  "Must (K1)" \
  "K1, NFR-S4, NFR-P1" \
  "**Given** the upload view, **when** Anna drops a PDF (≤ 10 MB) in the drop zone, **then** the file is uploaded via POST /api/receipts/upload and core-service returns 202 Accepted with receiptId." \
  "**Given** an upload, **when** core-service receives the file, **then** the PDF is saved in a private GCS bucket with the path gs://<bucket>/<userId>/<receiptId>.pdf — no public URL is created." \
  "**Given** a file that is not a PDF or is > 10 MB (NFR-S4), **when** an upload is attempted, **then** the request is rejected with 400 Bad Request and a plain-language error." \
  "**Given** a successful upload, **when** the row is written, **then** a row in RECEIPTS is created with status PENDING, user_id from the session and pdf_storage_uri." \
  "**Given** that the row has been created, **when** the upload is done, **then** a Pub/Sub message {receiptId, gcsUri, traceId} is published to the topic receipt-uploads." \
  "**Given** a duplicate upload (same sha256 hash of the PDF within 24 h), **when** Anna uploads again, **then** the system shows a warning and creates no new RECEIPTS row.")"

create_story "3" "US-3.2" "Asynchronous parsing via the Parser Service" "prio:must" "area:parsing" "$(story_body \
  "US-3.2" \
  "Anna" \
  "my uploaded receipt to be processed in the background" \
  "I see prices and categorisation without waiting in the UI" \
  "Must (K2, K9)" \
  "K2, K9, NFR-A3, NFR-P2, ADR-002" \
  "**Given** a message on receipt-uploads, **when** parser-service consumes it, **then** the PDF is fetched from GCS and text is extracted via Apache PDFBox." \
  "**Given** a parsed receipt, **when** the data is persisted, **then** RECEIPT_ITEMS rows are written linked to PRODUCTS (existing or new) and RECEIPTS.status is updated to COMPLETED." \
  "**Given** a receipt of ≤ 5 MB, **when** parsing is performed, **then** the total processing time is < 30 seconds p95 (NFR-P2), measured via the receipt_processing_seconds metric." \
  "**Given** a parser error (PDF cannot be read), **when** an exception is thrown, **then** RECEIPTS.status = FAILED and failure_reason is written; the message is not acked and Pub/Sub can retry." \
  "**Given** at-least-once delivery, **when** parser-service starts processing, **then** it checks RECEIPTS.status — if COMPLETED the message is acked without re-writing (idempotency)." \
  "**Given** successful processing of at least 95 % of 50 reference receipts, **when** the acceptance test is run, **then** parser_success_ratio ≥ 0.95 (NFR-A3).")"

create_story "3" "US-3.3" "EAN/PLU masking for weight items" "prio:must" "area:parsing" "$(story_body \
  "US-3.3" \
  "Markus" \
  "weight items (mince, cheese etc.) to be grouped under the same product" \
  "the price history is not split per package" \
  "Must (K3)" \
  "K3, NFR-M1" \
  "**Given** an EAN-13 with prefix 20–29, **when** the parser processes the code, **then** the weight/price digits are masked and only the base article number is stored in PRODUCTS.article_number." \
  "**Given** two receipts with the same weight item but different actual weights, **when** both are parsed, **then** they point to the **same** row in PRODUCTS via the same article_number." \
  "**Given** a standard EAN (non-weight item), **when** the parser processes it, **then** no masking is done and the entire barcode is stored." \
  "**Given** a PLU code (loose fruit/vegetables), **when** the parser identifies it, **then** the PLU number is stored in PRODUCTS.article_number without being mixed with EAN codes." \
  "**Given** the EAN masking logic, **when** unit tests are run, **then** ≥ 10 reference PDFs have the expected article_number and code coverage on the domain class is ≥ 80 % (NFR-M1)." \
  "**Given** an unknown EAN prefix, **when** the parser encounters it, **then** it makes a 'safe default' decision (no masking) and logs a WARN.")"

create_story "3" "US-3.4" "HTMX polling for status feedback" "prio:should" "area:parsing" "$(story_body \
  "US-3.4" \
  "Anna" \
  "to see real-time status ('Uploading', 'Extracting prices', 'Done')" \
  "I do not have to reload the page manually" \
  "Should (K12)" \
  "K12, NFR-P3, ADR-005" \
  "**Given** a successful upload, **when** core-service responds, **then** the HTMX fragment activates polling against GET /api/receipts/{id}/status every 2 seconds." \
  "**Given** a poll, **when** the endpoint responds, **then** the latency is < 100 ms p95 (NFR-P3) — measured via Cloud Run metric." \
  "**Given** that status goes from PENDING → COMPLETED, **when** the polling receives the new status value, **then** the UI replaces the spinner with a result fragment." \
  "**Given** that status goes to FAILED, **when** the UI receives that response, **then** an error message is shown with a report button." \
  "**Given** that the process takes > 30 seconds, **when** it passes the threshold, **then** the UI shows continued status that it is taking longer." \
  "**Given** that polling is in progress, **when** the status becomes COMPLETED or FAILED, **then** HTMX stops polling automatically.")"

create_story "3" "US-3.5" "Dead Letter Queue and failure monitoring" "prio:must" "area:parsing" "$(story_body \
  "US-3.5" \
  "operations engineer" \
  "messages that fail repeatedly to end up in the DLQ and trigger an alert" \
  "we can intervene quickly" \
  "Must (K9)" \
  "K9, NFR-A4" \
  "**Given** a message that fails 5 times, **when** the retry policy is exhausted, **then** the message is moved to the topic receipt-uploads-dlq." \
  "**Given** a message in the DLQ, **when** it lands, **then** a separate handler updates RECEIPTS.status = FAILED so that the user sees the error in the UI." \
  "**Given** traffic > 0 in the DLQ, **when** Cloud Monitoring detects it, **then** an alert is triggered within 5 minutes (NFR-A4) to the on-call channel." \
  "**Given** a DLQ message, **when** the operations engineer reviews it, **then** the payload contains receiptId, traceId and failure_reason so that the trace can be followed in Cloud Trace (NFR-O1)." \
  "**Given** that the operations engineer wants to replay, **when** a script is triggered, **then** the message can be moved back to receipt-uploads after manual verification." \
  "**Given** that a receipt is in FAILED state, **when** Anna sees it in the UI, **then** she can click 'Upload again' to try again.")"

# ---- Epic 4 stories ----
create_story "4" "US-4.1" "Normalised data model for receipts and products" "prio:must" "area:parsing" "$(story_body \
  "US-4.1" \
  "developer" \
  "receipts, receipt rows and products to be stored normalised in Neon PostgreSQL" \
  "price history per product can be calculated efficiently" \
  "Must (K4)" \
  "K4, NFR-S3, ADR-003" \
  "**Given** Flyway migration V1, **when** it is run, **then** the tables USERS, RECEIPTS, PRODUCTS, RECEIPT_ITEMS, GLOBAL_PRICE_POINTS are created per the schema." \
  "**Given** the schema, **when** PRODUCTS.article_number is UK, **then** an INSERT with an existing article number reuses the product ID (upsert pattern)." \
  "**Given** the RECEIPT_ITEMS table, **when** columns are created, **then** vat_rate is included so that Moms-kollen (K15) can be implemented later." \
  "**Given** the USERS table, **when** the user is deleted, **then** ON DELETE CASCADE ensures that all RECEIPTS and RECEIPT_ITEMS are deleted (GDPR Art. 17, NFR-D2)." \
  "**Given** the database pool, **when** Hikari is configured, **then** maximumPoolSize = 10 per instance (NFR-S3)." \
  "**Given** a test run, **when** Testcontainers starts PostgreSQL, **then** all Flyway migrations are run green and no row in GLOBAL_PRICE_POINTS has an FK to USERS (anonymisation, K8).")"

create_story "4" "US-4.2" "Product search with autocomplete" "prio:should" "area:frontend" "$(story_body \
  "US-4.2" \
  "Sofia" \
  "to be able to search for a product (e.g. 'coffee') and get suggestions immediately" \
  "I can quickly find the price history" \
  "Should (K12)" \
  "K12, NFR-P4, ADR-012" \
  "**Given** the search field, **when** Sofia types ≥ 2 characters, **then** HTMX sends GET /api/search?q=... after a 500 ms debounce." \
  "**Given** the search call, **when** SQL is run against PRODUCTS.name, **then** prefix matching via ILIKE is used against the index idx_products_name_lower and LIMIT 10 is applied." \
  "**Given** the search result, **when** the response is returned, **then** the latency is < 200 ms p95 (NFR-P4), measured via a dedicated metric." \
  "**Given** several matching products, **when** the result is returned, **then** sorting is done by popularity (number of RECEIPT_ITEMS rows) descending." \
  "**Given** an autocomplete response, **when** the UI renders it, **then** the list has role='listbox' and the arrow keys work with the keyboard (NFR-AC3)." \
  "**Given** that no products match, **when** the result is empty, **then** an empty state is shown with helpful text.")"

create_story "4" "US-4.3" "Product page with personal price history" "prio:must" "area:frontend" "$(story_body \
  "US-4.3" \
  "Anna" \
  "to see how the price of a specific product has developed for **me** over time" \
  "I can understand whether an item has become more expensive" \
  "Must (K4)" \
  "K4" \
  "**Given** Anna clicks on a product from the search results, **when** the page loads, **then** GET /products/{id} shows the product name, category and a line chart with Anna's own prices." \
  "**Given** the line chart, **when** it is rendered, **then** the Y-axis is price per unit and the X-axis is purchase date, based on RECEIPT_ITEMS for Anna's user_id (Row-Level Security via the repository layer)." \
  "**Given** that Anna has only one purchase of the product, **when** the page is shown, **then** an empty state is shown: 'Only one purchase so far. Upload more receipts to see trends'." \
  "**Given** that another user tries to fetch GET /products/{id} with a receiptItemId that does not belong to them, **when** the request is handled, **then** no data leaks (filter on user_id in SQL)." \
  "**Given** that the product has global statistics available (GLOBAL_PRICE_POINTS), **when** Anna has consented, **then** a second line shows 'Global average price'." \
  "**Given** that no VAT data exists, **when** the page is rendered, **then** the Moms-kollen module is not shown (depends on US-6.1).")"

create_story "4" "US-4.4" "Dashboard with monthly expenses" "prio:must" "area:frontend" "$(story_body \
  "US-4.4" \
  "Anna" \
  "to see her monthly total on the dashboard" \
  "I can get a quick overview" \
  "Must (K4)" \
  "K4, NFR-P1, ADR-013" \
  "**Given** that Anna signs in, **when** /dashboard loads, **then** the widget 'Month's expenses' shows the sum of RECEIPTS.total_amount for the current calendar month and compares with the same date the previous month." \
  "**Given** that no receipts exist, **when** the dashboard is rendered, **then** an empty state is shown: 'Welcome! Upload your first receipt to see trends'." \
  "**Given** that Anna has ≥ 3 receipts, **when** the dashboard is rendered, **then** the widget 'Latest receipts' shows the 3 most recent receipts with store, date, total." \
  "**Given** the dashboard call, **when** the page is rendered, **then** TTFB < 500 ms p95 (NFR-P1), measured in Cloud Run." \
  "**Given** that category data exists, **when** the donut chart is rendered, **then** it shows a breakdown per product category — the source for the category is decided in ADR-013." \
  "**Given** that a user has disabled consent, **when** the dashboard is shown, **then** no parts of the UI show global statistics.")"

# ---- Epic 5 stories ----
create_story "5" "US-5.1" "Anonymised storage of global price data" "prio:must" "area:crowdsource" "$(story_body \
  "US-5.1" \
  "DPO" \
  "the global price pool to be irreversibly anonymous" \
  "GDPR should not apply to these rows" \
  "Must (K8, K13)" \
  "K8, K13, NFR-D3, ADR-007" \
  "**Given** a parsed receipt from a user who has **consented**, **when** parser-service writes to GLOBAL_PRICE_POINTS, **then** the row contains only product_id, price, city, year_month — **no** FK to USERS or RECEIPTS." \
  "**Given** a receipt, **when** the city is derived, **then** only the city (e.g. 'Malmö') is stored — never a specific store or postcode." \
  "**Given** the date, **when** the row is created, **then** year_month is stored as YYYY-MM — never an exact date or timestamp." \
  "**Given** that a user has **not** consented (share_anonymous_data = false), **when** the receipt is parsed, **then** no row is written to GLOBAL_PRICE_POINTS for that receipt." \
  "**Given** a user who deletes their account, **when** ON DELETE CASCADE is run, **then** GLOBAL_PRICE_POINTS is not affected (it is anonymous after all) — verified with an integration test." \
  "**Given** that a user has < 3 purchases in a specific (city, year_month, product_id) aggregate, **when** the aggregate is shown publicly, **then** the data point is filtered out in the frontend (k-anonymity ≥ 3).")"

create_story "5" "US-5.2" "Consent for crowdsourcing" "prio:should" "area:gdpr" "$(story_body \
  "US-5.2" \
  "Markus" \
  "to actively be able to give consent to share my prices anonymously" \
  "I can contribute to global statistics" \
  "Should (K13)" \
  "K13, ADR-007" \
  "**Given** the profile page, **when** Markus toggles 'Share my prices anonymously', **then** a modal shows exactly what is shared (article, price, city, month) and what is **not** shared." \
  "**Given** that Markus confirms in the modal, **when** the request is sent, **then** USERS.share_anonymous_data = true and USERS.consent_updated_at gets the current timestamp." \
  "**Given** the consent event, **when** it is logged, **then** the entry is written to the audit log (NFR-D6) with user id, IP hash and timestamp." \
  "**Given** that Markus withdraws his consent, **when** he toggles off, **then** the flag is set to false immediately; previously contributed price points remain because they are anonymised." \
  "**Given** that Markus has never consented, **when** he sees the dashboard, **then** no widgets show global statistics, instead an info box: 'Enable consent to see global price data'." \
  "**Given** the registration form, **when** Markus creates an account, **then** the consent toggle is **never** pre-ticked.")"

create_story "5" "US-5.3" "Open statistics view for global price development" "prio:could" "area:crowdsource" "$(story_body \
  "US-5.3" \
  "Markus" \
  "to be able to see global price development per product and city" \
  "I can compare with my own history and contribute to transparency" \
  "Could (K14)" \
  "K14" \
  "**Given** Markus visits /statistics/products/{id}, **when** the page loads, **then** a line chart shows GLOBAL_PRICE_POINTS aggregated per year_month and city." \
  "**Given** that Markus filters on city, **when** the filter is activated, **then** the chart updates via HTMX without a page reload." \
  "**Given** a product with < 3 data points in a cell, **when** the chart is rendered, **then** that cell is shown as a gap, not a misleading number (k-anonymity)." \
  "**Given** that Markus is signed out, **when** he visits the statistics view, **then** the page is shown because it is 'open' — no authentication is required." \
  "**Given** that Markus has consented and has his own data, **when** the page is rendered, **then** a second line 'My price' is shown on the same chart for comparison." \
  "**Given** the data volume (50,000 price points), **when** the page loads, **then** TTFB < 1 second p95 — aggregation is run in SQL, not in Java.")"

# ---- Epic 6 stories ----
create_story "6" "US-6.1" "Moms-kollen" "prio:could" "area:insights" "$(story_body \
  "US-6.1" \
  "Sofia" \
  "to see whether my store really lowered the prices after the VAT reduction" \
  "I know whether they kept the margin" \
  "Could (K15)" \
  "K15" \
  "**Given** Sofia has receipts both before and after a configurable 'VAT date', **when** she visits /insights/vat, **then** the view shows the average price per product before and after the date based on RECEIPT_ITEMS.vat_rate." \
  "**Given** that a product's price has decreased ≥ the VAT reduction, **when** the row is rendered, **then** a green thumbs-up icon is shown: 'The store lowered the price per the VAT'." \
  "**Given** that a product's price is unchanged despite the VAT reduction, **when** the row is rendered, **then** a red warning triangle is shown: 'The store kept the margin'." \
  "**Given** that Sofia lacks receipts from before the date, **when** the view loads, **then** an empty state is shown with the CTA 'Upload older receipt'." \
  "**Given** that the view is calculated, **when** SQL is run, **then** the aggregation happens in a single query with CASE WHEN purchase_date < :momsDate — no N+1 calls." \
  "**Given** that Sofia wants to see the underlying data, **when** she clicks on a product row, **then** she is directed to the product page (US-4.3) with the date filter pre-selected.")"

create_story "6" "US-6.2" "Shrinkflation warning" "prio:could" "area:insights" "$(story_body \
  "US-6.2" \
  "Sofia" \
  "to be warned if the package size has decreased while the price has been held" \
  "I can discover hidden price increases" \
  "Could (K16)" \
  "K16" \
  "**Given** two RECEIPT_ITEMS for the same product_id where quantity has decreased but price_per_unit is unchanged or higher, **when** Sofia visits the product page, **then** a yellow/red badge-warning shows: 'The package decreased from X to Y but the per-kilo price is higher'." \
  "**Given** that the product's current price is compared, **when** the per-kilo price is calculated, **then** the calculation is shown clearly in the UI: old price/kilo vs new price/kilo." \
  "**Given** that a product does not have two data points with different sizes, **when** the page is rendered, **then** the warning is **not** shown (false-positive protection)." \
  "**Given** the shrinkflation logic, **when** it is implemented, **then** it is a separate domain class ShrinkflationDetector with ≥ 80 % test coverage (NFR-M1)." \
  "**Given** that the warning is shown, **when** Sofia clicks on it, **then** an explanation expands with the definition of shrinkflation and why it is relevant." \
  "**Given** that screen readers are used, **when** the warning is rendered, **then** it has role='alert' and aria-live='polite'.")"

# ---- Epic 7 stories ----
create_story "7" "US-7.1" "Audit log for security events" "prio:must" "area:gdpr" "$(story_body \
  "US-7.1" \
  "security reviewer" \
  "sign-ins, consent changes, data exports and deletions to be logged separately" \
  "I can audit after a possible incident" \
  "Must" \
  "K5, K8, NFR-D6" \
  "**Given** a successful sign-in, **when** the event happens, **then** an entry is written in AUDIT_LOG with user_id, event_type=LOGIN, ip_hash, timestamp, trace_id." \
  "**Given** a consent change, **when** the user toggles, **then** the entry is written with event_type=CONSENT_CHANGED and both the old and the new value." \
  "**Given** a data export (US-7.2), **when** it runs, **then** event_type=DATA_EXPORTED with the format and the size is logged." \
  "**Given** an account deletion (US-7.4), **when** it runs, **then** event_type=ACCOUNT_DELETED is logged before the row is deleted from USERS." \
  "**Given** audit logs, **when** the retention job runs, **then** entries ≥ 1 year old are deleted automatically (NFR-D6)." \
  "**Given** that an entry in AUDIT_LOG is written, **when** it is persisted, **then** it is stored in a separate bucket or table with write protection for the application ('write-once') — tampering must be traceable.")"

create_story "7" "US-7.2" "Data export (Article 15 + 20)" "prio:must" "area:gdpr" "$(story_body \
  "US-7.2" \
  "Anna" \
  "to be able to download all my data in JSON or CSV" \
  "I exercise my right of access and data portability" \
  "Must (K8)" \
  "K8, GDPR Art. 15, 20" \
  "**Given** the profile page, **when** Anna clicks 'Export my data', **then** a modal lets her choose the format (JSON or CSV)." \
  "**Given** Anna chooses JSON, **when** GET /api/profile/export?format=json is run, **then** the response contains account data, consent history, all RECEIPTS and RECEIPT_ITEMS that belong to her user_id." \
  "**Given** Anna chooses CSV, **when** the same endpoint is called with format=csv, **then** a ZIP with separate CSV files per table is returned." \
  "**Given** that the export is created, **when** the file is delivered, **then** no data about other users leaks — verified with an integration test with two users." \
  "**Given** that the export is done, **when** Anna gets the file, **then** the event is logged in the audit log (US-7.1)." \
  "**Given** that the export file is generated, **when** it is served, **then** Content-Disposition: attachment and Cache-Control: no-store are set so that the file is not cached by browsers or proxies.")"

create_story "7" "US-7.3" "Account deletion (Article 17)" "prio:must" "area:gdpr" "$(story_body \
  "US-7.3" \
  "Anna" \
  "to be able to delete my account completely" \
  "I exercise my right to be forgotten" \
  "Must (K8)" \
  "K8, NFR-D2, NFR-D3, ADR-007" \
  "**Given** the profile page, **when** Anna clicks 'Delete my account', **then** a modal requires her to type 'DELETE' in a text field to activate the confirmation button." \
  "**Given** double confirmation, **when** Anna confirms finally, **then** DELETE FROM USERS WHERE id = :userId triggers ON DELETE CASCADE so that RECEIPTS and RECEIPT_ITEMS are also deleted (NFR-D2)." \
  "**Given** that the deletion is run, **when** it completes, **then** an asynchronous job deletes all PDFs in GCS for the user's path (gs://<bucket>/<userId>/*) within 24 h." \
  "**Given** that the account is deleted, **when** Anna tries to sign in, **then** the sign-in flow responds with the generic message 'Wrong e-mail or password' (no account-existence leak)." \
  "**Given** that GLOBAL_PRICE_POINTS are anonymous, **when** the deletion is run, **then** these rows are **not affected** (NFR-D3) — verified with an integration test." \
  "**Given** the deletion, **when** it is done, **then** a confirmation e-mail is sent (post-MVP) or an equivalent UI confirmation is shown, and the audit log entry exists (US-7.1).")"

create_story "7" "US-7.4" "Consent withdrawal" "prio:must" "area:gdpr" "$(story_body \
  "US-7.4" \
  "Markus" \
  "to be able to withdraw my crowdsourcing consent at any time" \
  "I have control over my data going forward" \
  "Must (K8)" \
  "K8, GDPR Art. 7.3" \
  "**Given** that Markus has previously consented, **when** he toggles off in the profile, **then** USERS.share_anonymous_data = false immediately." \
  "**Given** the withdrawal, **when** the event is logged, **then** the audit log (US-7.1) gets event_type=CONSENT_CHANGED with old value true, new value false." \
  "**Given** the withdrawal, **when** future receipts are parsed, **then** no row is written to GLOBAL_PRICE_POINTS." \
  "**Given** already-shared price points, **when** Markus withdraws, **then** these remain in GLOBAL_PRICE_POINTS (they are anonymous) — the modal explains this clearly." \
  "**Given** that Markus changes his mind, **when** he toggles on again, **then** the flow in US-5.2 runs again and a new audit log entry is created." \
  "**Given** the legal basis 'consent', **when** Markus withdraws, **then** no degradation of other services happens (he can still use the entire app).")"

# ---- Epic 8 stories ----
create_story "8" "US-8.1" "Component catalogue at /dev/components" "prio:should" "area:design-a11y" "$(story_body \
  "US-8.1" \
  "developer" \
  "to have an internal page that shows all reusable Thymeleaf fragments" \
  "I can quickly compare and test UI components" \
  "Should (K11)" \
  "K11, NFR-M5" \
  "**Given** core-service in the dev profile, **when** the developer goes to /dev/components, **then** the page renders all fragments from fragments/components.html." \
  "**Given** the route, **when** the prod profile is active, **then** the route returns 404 Not Found (security)." \
  "**Given** that a new fragment is added, **when** the developer follows the guide, **then** the fragment shows up automatically on /dev/components without extra configuration." \
  "**Given** that HTMX components are shown, **when** the developer clicks on them, **then** they respond without a page reload — the interaction is tested in isolation." \
  "**Given** each component on the page, **when** it is rendered, **then** a short explanatory text shows the intended use + a link to the relevant UX section." \
  "**Given** that the page becomes long, **when** it is scrolled, **then** a side nav with anchor links to each category exists.")"

create_story "8" "US-8.2" "WCAG 2.1 AA conformance" "prio:must" "area:design-a11y" "$(story_body \
  "US-8.2" \
  "user with a disability" \
  "to be able to use the entire app with keyboard and screen reader" \
  "I have the same access as other users" \
  "Must" \
  "K11, NFR-AC1, AC2, AC3, AC4, AC5, AC6, ADR-014" \
  "**Given** every page in the app, **when** axe-core or pa11y is run in CI (NFR-AC4), **then** no error-level violation is reported." \
  "**Given** all text, **when** the contrast is measured, **then** the ratio is ≥ 4.5:1 for normal text and ≥ 3:1 for large text (NFR-AC2)." \
  "**Given** the main flow (sign-in, upload, view receipt), **when** the user uses only the keyboard, **then** all interactive elements are reachable via Tab with a visible focus ring (NFR-AC3)." \
  "**Given** the main flow, **when** it is tested with NVDA/VoiceOver (NFR-AC5), **then** all actions can be performed without the screen-reader user becoming blocked — at least one manual walkthrough per release." \
  "**Given** the user's system has prefers-reduced-motion, **when** the UI renders animations, **then** confetti and slide animations are turned off (NFR-AC6)." \
  "**Given** modals, **when** they open, **then** they have role='dialog', aria-modal='true', focus is trapped inside the modal, and Esc closes them.")"

# ---- Epic 9 stories ----
create_story "9" "US-9.1" "Distributed tracing end-to-end" "prio:must" "area:observability" "$(story_body \
  "US-9.1" \
  "operations engineer" \
  "every request to be followed as a coherent trace through both core-service and parser-service" \
  "I can quickly troubleshoot errors in the asynchronous flow" \
  "Must (K10)" \
  "K10, NFR-O1, NFR-O2" \
  "**Given** a PDF upload, **when** core-service receives the request, **then** an OTel span is created with a trace_id that is propagated to the Pub/Sub attributes." \
  "**Given** that parser-service consumes the message, **when** processing starts, **then** a child span is linked to the same trace_id so that the whole flow is visible as a trace in GCP Trace." \
  "**Given** structured JSON logs (NFR-O2), **when** log rows are written, **then** every row contains trace_id and span_id for correlation." \
  "**Given** that a user reports an error with a traceId, **when** the operations engineer searches, **then** all logs and spans for that trace_id can be listed in Cloud Trace within < 1 minute." \
  "**Given** that logs are written, **when** PII is detected (e-mail, password), **then** the Logback mask replaces the value with [redacted] (NFR-O5)." \
  "**Given** sampling, **when** traffic increases, **then** the OTel sampler is configured to adaptive (≥ 100 % in dev, ≤ 10 % in prod).")"

create_story "9" "US-9.2" "Metrics and dashboards for KPIs" "prio:must" "area:observability" "$(story_body \
  "US-9.2" \
  "operations engineer" \
  "to have dashboards for processing time, error rate and latency" \
  "I can follow up on SLOs" \
  "Must" \
  "NFR-O3, NFR-O4, NFR-O6" \
  "**Given** that Micrometer is configured, **when** the app runs, **then** the metrics http_requests_total, receipt_processing_seconds, parser_success_ratio are exported to GCP (NFR-O3)." \
  "**Given** Cloud Monitoring, **when** the dashboard is opened, **then** widgets show p50/p95/p99 for latency per endpoint, error rate (5xx) and DLQ depth." \
  "**Given** an SLO of TTFB < 500 ms p95 (NFR-P1), **when** the SLO is breached during a 5-min window, **then** an alert policy fires (NFR-O4) to the on-call channel." \
  "**Given** an SLO of error rate < 1 % (NFR-A2), **when** the ratio is exceeded for 10 minutes, **then** an alert goes to the same channel with a direct link to the logs." \
  "**Given** dashboards, **when** they are created, **then** they are version-controlled in Terraform — not hand-built in the Cloud Monitoring UI." \
  "**Given** that a developer adds a new metric, **when** the PR is merged, **then** documentation is updated in /observability/README.md (or equivalent, NFR-M4).")"

create_story "9" "US-9.3" "DLQ alerts and operations runbook" "prio:must" "area:observability" "$(story_body \
  "US-9.3" \
  "operations engineer" \
  "to get an alert when messages end up in the DLQ" \
  "I can quickly investigate and possibly replay" \
  "Must" \
  "NFR-A4" \
  "**Given** the Pub/Sub topic receipt-uploads-dlq, **when** a message lands, **then** the Cloud Monitoring metric num_undelivered_messages increases and an alert is triggered within 5 min (NFR-A4)." \
  "**Given** the alert, **when** it is sent, **then** it contains a link to the DLQ in the GCP console and to the runbook page." \
  "**Given** the runbook, **when** the operations engineer opens it, **then** it describes step by step how DLQ messages are inspected, how the trace is followed and how they are replayed." \
  "**Given** that a DLQ message is replayed, **when** it is sent back, **then** the Cloud Monitoring metric dlq_replay_count increases and the receipt status is updated to PENDING again." \
  "**Given** that the DLQ is empty after an incident, **when** Cloud Monitoring detects it, **then** a 'recovery' event is logged to close the incident automatically." \
  "**Given** quarterly recovery test (NFR-B4), **when** the test is run, **then** a controlled DLQ failure is triggered and the whole runbook is run through.")"

log "=== Done ==="
if (( APPLY == 0 )); then
  log "Dry-run finished. Run with --apply to create issues for real:"
  log "    ./scripts/create-github-issues.sh --apply"
else
  log "Created epics and sub-issues in $REPO."
fi
