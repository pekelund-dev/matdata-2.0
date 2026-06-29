# scripts/

Hjälpskript för administration av Matdata 2.0-repot. Skripten är tänkta att köras **lokalt** på din maskin, inte i CI.

## `create-github-issues.sh`

Skapar GitHub-issues (epics) och sub-issues (user stories) baserat på [user-stories.md](../user-stories.md) genom att kalla din lokala installation av [`gh`](https://cli.github.com/).

### Vad skriptet gör
1. **Labels** — säkerställer att följande labels finns i target-repot (skapar de som saknas, rör inte de som finns):
   - `epic`, `user-story`
   - `prio:must`, `prio:should`, `prio:could`
   - `area:infra`, `area:auth`, `area:parsing`, `area:frontend`, `area:gdpr`, `area:observability`, `area:crowdsource`, `area:insights`, `area:design-a11y`
2. **Epics** — skapar 9 parent-issues, en per epic (Epic 1–9), med label `epic` + relevant `area:*`.
3. **Sub-issues** — skapar 31 issues, en per user story (US-1.1 … US-9.3), med labels `user-story`, prioritet och area. Varje story länkas som sub-issue under sin epic via GitHubs `sub_issues`-API.

Skriptet är **idempotent**: körs det två gånger skapas inga dubbletter — befintliga issues hoppas över (matchat på exakt titel).

### Förkrav
* `gh` ≥ 2.40, inloggad: `gh auth status`
* `jq` (för att hantera issue-ID:n vid sub-issue-länkning)
* Skrivrättigheter på issues och labels i target-repot

### Användning

```bash
# 1. Dry-run (default) — visar vad som SKULLE skapas, utan att röra GitHub
./scripts/create-github-issues.sh

# 2. På riktigt
./scripts/create-github-issues.sh --apply

# 3. Annat target-repo
./scripts/create-github-issues.sh --apply -R pekelund-dev/matdata-2.0

# 4. Hjälp
./scripts/create-github-issues.sh --help
```

### Variabler
| Variabel | Default | Syfte |
| --- | --- | --- |
| `REPO` | `pekelund-dev/matdata-2.0` | Target-repo. Kan också sättas via `-R` / `--repo`. |

### Sub-issues API
Skriptet använder GitHubs `POST /repos/{owner}/{repo}/issues/{issue_number}/sub_issues`-endpoint. Om endpointen inte är tillgänglig på ditt repo (sub-issues kräver att funktionen är aktiverad) faller skriptet tillbaka på att lägga till en kommentar med `Parent epic: #<n>` på sub-issuet så att kopplingen ändå syns.

### Felsökning
* **"gh är inte inloggad"** → kör `gh auth login` (välj `github.com`, `HTTPS`, `Login with web browser`).
* **"Kan inte se repot"** → verifiera `gh repo view <owner>/<repo>` och att tokenen har `repo`-scope.
* **Issues syns inte i UI:t** → labels skapas asynkront av GitHub; uppdatera issue-vyn efter några sekunder.
* **Hoppa över redan skapade** → skriptet jämför exakta titlar. Om du redan har skapat en epic manuellt med samma titel hoppas den över. Vill du tvinga ny-skapning får du först stänga eller döpa om den befintliga.

### Källkod och felrapporter
Skriptet ligger i `scripts/create-github-issues.sh`. Förbättringar välkomnas via PR.
