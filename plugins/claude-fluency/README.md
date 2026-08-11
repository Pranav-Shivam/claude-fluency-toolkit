# claude-fluency

One plugin, five toolkits: engineering principles + safety hooks, a security audit fleet, devops/knowledge-graph skills, document generation, and timesheet generation.

## What's inside

### Engineering workflow

- **Skill: `engineering-principles`** — five principles (clarify before building, lean code, bounded edits, outcome-oriented execution, verify and recover) plus common failure modes. Loaded automatically as context; no invocation needed.
- **Command: `/git-commit`** — reads the staged diff and drafts a Conventional Commits message. Runs on Haiku, model-invocation disabled (must be explicitly called).
- **Command: `/pr-description`** — diffs against the default branch and drafts a PR description (What changed / Why / Testing).
- **Command: `/review-diff [base-branch]`** — reviews a diff against `engineering-principles`: scope creep, architectural consistency, silently undone reasoning, phantom APIs, bounded edits, verification, and security-adjacent risk with blast radius. Tags each finding High/Medium/Low confidence.
- **Command: `/learn`** — reviews the session for non-obvious lessons and appends them to `docs/gotchas.md`.
- **Hooks:**
  - `SessionStart` → prints current branch, uncommitted file count, last commit, stash count.
  - `PreToolUse` (matcher: `Bash`) → blocks a fixed set of high-risk shell patterns (`rm -rf` outside temp/build paths, unconfirmed force pushes, `DROP TABLE`/`DROP DATABASE`, `git reset --hard`, `.env` overwrite redirects) before they execute.
  - `Stop` / `TaskCompleted` → cross-platform desktop notification.

### Security

- **Command: `/security-scan`** — an 11-agent audit fleet. Each agent owns one domain, reads a matching checklist in `references/`, and reports findings. 10 security agents report `{file, line, severity, issue, recommendation}`; `lint-agent` reports `{file, line, category, note}`. Runs all 11 in parallel, deduplicates and severity-grades the security findings, and produces one report grouped by severity — `lint-agent`'s style findings get their own section.

| Agent | Domain |
|---|---|
| `auth-agent` | Authentication — sessions, tokens, MFA, password handling, bypass paths |
| `config-agent` | Configuration, CORS, security headers, middleware |
| `crypto-tls-agent` | Cryptography and TLS, including live `sslyze` checks against a documented endpoint |
| `data-agent` | Sensitive data exposure — logs, API responses, client-side storage |
| `database-agent` | Database connection security, injection, privilege scope |
| `deps-agent` | Dependency CVEs via `pip-audit`/`safety`/`npm audit` |
| `iac-container-agent` | Dockerfiles, orchestration manifests, CI/CD via `checkov` |
| `rbac-agent` | RBAC and object-level authorization |
| `sast-agent` | Static analysis via `bandit`/`semgrep` plus manual pattern review |
| `secrets-agent` | Hardcoded credentials, including git history, via `trufflehog`/`gitleaks`/`detect-secrets` |
| `lint-agent` | Emoji hygiene — style concern, reported separately from severity-graded findings |

### Devops / knowledge graph

- **Skill: `graphify`** — defines the interface and expected output (`GRAPH_REPORT.md`, an HTML visualization, a JSON export) for turning a codebase into a knowledge graph with community detection. **The actual graph-building engine is not included** — plug in your own AST/static-analysis tooling or graph library.
- **Skill: `pr-review`** — end-to-end PR review: layered walkthrough, health score, severity-graded findings with fix prompts. Shows results in chat first; posts nothing until confirmed.
- **Skill: `pr-comments`** — fetches and groups PR comment threads (inline by file/line, PR-level separately), filtering system noise.

### Document generation

- **Command: `/mom <file>`** — reads a meeting transcript (`.docx`, `.pdf`, or `.txt`) and outputs a clean Markdown MoM (discussion points, decisions, action items with owner/due date, blockers, next steps). Marks unstated owner/deadline **TBD** instead of inventing one.
- **Command: `/create-pptx <content-file> [--template <template-file>]`** — plans a slide outline and generates a `.pptx` deck via `python-pptx`. A `--template` `.pptx` supplies the design base (fonts, colors, header/footer, logo). Never copies large paragraphs verbatim or invents facts.
- **Command: `/adr <short decision title>`** — drafts a Nygard-style ADR from the current conversation/diff, auto-numbers it against `docs/adr/`, and writes `docs/adr/00XX-kebab-case-title.md`. Marks unstated figures **TBD**.

### Timesheet

- **Skill: `timesheet`** — scans every repo in your config for the requested date range, filters out inactive days, and synthesizes each remaining day into a `Day, DD Mon  •  8:00 hrs` entry plus a 3–6 sentence paragraph.

## Setup prerequisites

- **Engineering workflow hooks** — `jq` on `PATH` (safety hook falls back to regex if absent); `bash` (POSIX-ish, not `sh`); for notifications, `notify-send` (Linux), AppleScript/`osascript` (macOS, built in), or `powershell.exe` reachable from WSL/Git Bash (Windows). The force-push block requires a literal `--yes-i-mean-it` flag as a deliberate friction point — adjust the sentinel in `scripts/pre-tool-safety.sh` if needed. The `rm -rf` check allowlists common temp/build dirs (`/tmp`, `node_modules`, `dist`, `build`, `.cache`, `__pycache__`, `.next`, `venv`, `.venv`).
- **`/security-scan`** — none of the external scanning tools are bundled; each agent runs whichever of its tools are on `PATH` and states a coverage gap if one is missing. For full coverage install: `bandit`, `semgrep` (SAST); `pip-audit`, `safety` (Python deps), `npm`/`yarn`/`pnpm audit` (Node deps); `trufflehog`, `gitleaks`, `detect-secrets` (secrets); `checkov` (IaC/container); `sslyze` (live TLS checks).
- **`pr-review` / `pr-comments`** — written generically but include an Azure DevOps section with actual REST/CLI calls. Requires an Azure DevOps PAT (`Code (Read)` for comments, `Code (Read & Write)` for posting) or authenticated `az devops` CLI — not included. On another platform (GitHub/GitLab/Bitbucket), swap the Azure DevOps section for the equivalent API calls.
- **`graphify`** — no dependency by itself, but produces nothing until connected to a real graph-building implementation.
- **`/mom`** — `.txt`/`.pdf` need no setup; `.docx` needs `pandoc` (preferred), `python-docx`, or `unzip` on `PATH`.
- **`/create-pptx`** — requires `python3` with `python-pptx` (`pip install python-pptx`). `.docx` uses the same extraction chain as `/mom`.
- **`/adr`** — no extra setup; writable `docs/adr/` directory (created automatically if missing).
- **`timesheet`** — config-driven, no hardcoded paths. Create `.claude/timesheet.config.json` (or `~/.claude/timesheet.config.json` for a global default):

```json
{
  "repos": [
    {
      "name": "ProjectDisplayName",
      "path": "/absolute/path/to/repo",
      "authors": ["Git Author Name", "Alternate Author Name"]
    }
  ]
}
```

Requires `git`, `find`, and `stat` on `PATH` — no other tooling.

## Usage

```
/git-commit
/pr-description
/review-diff main
/learn

/security-scan

/mom transcripts/2026-08-10-standup.txt
/create-pptx notes/kickoff.pdf --template branding/header-footer-template.pptx
/adr use Azure SQL Serverless instead of Snowflake for OLTP

/timesheet
/timesheet last week
```
