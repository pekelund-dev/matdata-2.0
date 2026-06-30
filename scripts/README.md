# scripts/

Helper scripts for administering the Matdata 2.0 repo. The scripts are intended to be run **locally** on your machine, not in CI.

## `create-github-issues.sh`

Creates GitHub issues (epics) and sub-issues (user stories) based on [user-stories.md](../user-stories.md) by calling your local installation of [`gh`](https://cli.github.com/).

### What the script does
1. **Labels** — ensures that the following labels exist in the target repo (creates those that are missing, does not touch those that exist):
   - `epic`, `user-story`
   - `prio:must`, `prio:should`, `prio:could`
   - `area:infra`, `area:auth`, `area:parsing`, `area:frontend`, `area:gdpr`, `area:observability`, `area:crowdsource`, `area:insights`, `area:design-a11y`
2. **Epics** — creates 9 parent issues, one per epic (Epic 1–9), with label `epic` + the relevant `area:*`.
3. **Sub-issues** — creates 31 issues, one per user story (US-1.1 … US-9.3), with labels `user-story`, priority and area. Each story is linked as a sub-issue under its epic via GitHub's `sub_issues` API.

The script is **idempotent**: if run twice, no duplicates are created — existing issues are skipped (matched on exact title).

### Prerequisites
* `gh` ≥ 2.40, signed in: `gh auth status`
* `jq` (to handle issue IDs when linking sub-issues)
* Write permissions on issues and labels in the target repo

### Usage

```bash
# 1. Dry-run (default) — shows what WOULD be created, without touching GitHub
./scripts/create-github-issues.sh

# 2. For real
./scripts/create-github-issues.sh --apply

# 3. Different target repo
./scripts/create-github-issues.sh --apply -R pekelund-dev/matdata-2.0

# 4. Help
./scripts/create-github-issues.sh --help
```

### Variables
| Variable | Default | Purpose |
| --- | --- | --- |
| `REPO` | `pekelund-dev/matdata-2.0` | Target repo. Can also be set via `-R` / `--repo`. |

### Sub-issues API
The script uses GitHub's `POST /repos/{owner}/{repo}/issues/{issue_number}/sub_issues` endpoint. If the endpoint is not available on your repo (sub-issues require the feature to be enabled) the script falls back to adding a comment with `Parent epic: #<n>` on the sub-issue so that the relationship is still visible.

### Troubleshooting
* **\"gh is not signed in\"** → run `gh auth login` (choose `github.com`, `HTTPS`, `Login with web browser`).
* **\"Cannot see the repo\"** → verify with `gh repo view <owner>/<repo>` and that the token has the `repo` scope.
* **Issues do not show up in the UI** → labels are created asynchronously by GitHub; refresh the issue view after a few seconds.
* **Skipping already-created** → the script compares exact titles. If you have already manually created an epic with the same title, it is skipped. If you want to force a re-creation, you must first close or rename the existing one.

### Source and bug reports
The script is at `scripts/create-github-issues.sh`. Improvements are welcome via PR.
