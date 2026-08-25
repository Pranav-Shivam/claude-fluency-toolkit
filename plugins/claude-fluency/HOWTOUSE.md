# How to Use — claude-fluency

One plugin, every command/skill/agent listed below with a runnable example. Install first (see [README.md](README.md)):

```text
/plugin marketplace add Pranav-Shivam/claude-fluency-toolkit
/plugin install claude-fluency@claude-fluency-toolkit
```

---

## Commands

### `/git-commit`

Reads your **staged** diff and drafts a Conventional Commits message. Runs on Haiku, must be called explicitly (no args).

```text
git add src/auth/session.ts
/git-commit
```

Output:
```
fix(auth): reject expired refresh tokens on renewal

Renewal endpoint accepted tokens past expiry due to `<=` comparison
instead of `<`, letting a session outlive its intended TTL.
```

### `/pr-description`

No args — diffs your branch against the repo's default branch (`main`, falling back to `origin/HEAD` or `master`) and drafts a PR description.

```text
/pr-description
```

Produces a `## What changed / Why / Testing` write-up ready to paste into a GitHub/Azure DevOps PR.

### `/review-diff [base-branch]`

Reviews a diff against the `engineering-principles` skill: scope creep, architecture consistency, silently-undone reasoning, phantom APIs, bounded edits, verification, and security-adjacent risk with blast radius. Defaults to the default branch if no arg given.

```text
/review-diff
/review-diff develop
```

Each finding is tagged High/Medium/Low confidence — low-signal noise is dropped rather than padded in.

### `/learn`

No args. Reviews the current session for non-obvious lessons (library gotchas, wrong assumptions that cost time, undocumented config quirks) and appends them to `docs/gotchas.md`.

```text
/learn
```

Run this at the end of a session where something surprising happened — not every session needs it.

### `/security-scan`

No args. Orchestrates the 11-agent audit fleet (`auth`, `config`, `crypto-tls`, `data`, `database`, `deps`, `iac-container`, `rbac`, `sast`, `secrets`, `lint`) in parallel against the current repo.

```text
/security-scan
```

Returns one report grouped by severity (critical/high/medium/low), plus a separate style/lint section for emoji hygiene. Each agent states a coverage gap explicitly if its underlying tool (`bandit`, `semgrep`, `trufflehog`, `checkov`, etc.) isn't on `PATH` — see [README prerequisites](README.md#prerequisites).

### `/mom <file>`

Turns a meeting transcript (`.docx`, `.pdf`, `.txt`) into a Minutes of Meeting doc: discussion points, decisions, action items (owner + due date), blockers, next steps.

```text
/mom transcripts/2026-08-10-standup.txt
/mom "Q3 Planning Call.docx"
```

Any owner/deadline not actually stated in the transcript is marked **TBD** — never invented.

### `/create-pptx <content-file> [--template <template-file>]`

Reads a content file (`.docx`, `.pdf`, `.txt`, `.md`), plans a slide outline, and builds a `.pptx` via `python-pptx`. Requires `python3` + `pip install python-pptx`.

```text
/create-pptx project-summary.docx
/create-pptx notes/kickoff.pdf --template branding/header-footer-template.pptx
```

With `--template`, the template's slide master (fonts, colors, header/footer, logo) becomes the design base for every generated slide. Never copies large paragraphs verbatim or invents metrics.

### `/adr <short decision title>`

Drafts a Nygard-style Architecture Decision Record from the current conversation/diff/design discussion. Auto-numbers against existing ADRs in `docs/adr/`.

```text
/adr use Azure SQL Serverless instead of Snowflake for OLTP
```

Writes `docs/adr/0007-use-azure-sql-serverless-instead-of-snowflake-for-oltp.md` (Status, Context, Decision Drivers, Decision, Alternatives Considered, Consequences, Notes). Only fires for decisions with real architectural weight — skips routine implementation details, and marks unstated figures **TBD** rather than fabricating them.

### `/timesheet [last week | YYYY-MM-DD [YYYY-MM-DD]]`

Generates daily timesheet entries from git history + file-modification timestamps across the repos listed in `.claude/timesheet.config.json` (see [README](README.md#prerequisites) for the config shape).

```text
/timesheet                        # current week, Mon → today
/timesheet last week              # Mon–Fri of previous week
/timesheet 2026-05-18 2026-05-22  # explicit start/end
/timesheet 2026-05-22             # single day
```

Output, one entry per active day:
```
Mon, 18 May  •  8:00 hrs
Refactored lead status logic in LeadDetail to remove redundant
auto-assignment of the "Assigned" status...
```

Follow-ups work conversationally: *"regenerate Tuesday, mention the migration script"*, *"make it terser"*, *"extend to Friday"*.

### `/pr-setup`

Run once per repo before `/pr-review` or `pr-comments`. Detects whether your repo is on GitHub, GitLab, or Azure DevOps from `git remote -v`, checks whether you're already authenticated, and if not, tells you the exact command to run — never a vague "set up credentials first."

```text
/pr-setup
```

```
Detected: GitHub (origin → github.com/acme/widgets)
Not ready — gh CLI not authenticated, GH_TOKEN not set.
Run: gh auth login
```

### `/pr-watch-setup`

Azure DevOps only. Run once per repo to get notified when new PRs open — schedules a recurring check (cron on Linux/macOS, Task Scheduler on Windows), desktop-notifies on new activity, and opens a terminal offering to run `/pr-review` for whichever PRs you approve. Nothing is baked into the plugin: org/project/repo/PAT get written to a per-repo config file on your machine during this interactive setup.

```text
/pr-watch-setup
```

Walks through: confirm org/project/repo detected from `git remote -v`, checks for existing `az devops` auth (asks for a PAT only if that fails), asks how often to check, then installs the scheduler entry and runs one check immediately so you see it work.

Full step-by-step with dummy values for every prompt: [docs/pr-watch-setup-guide.md](../../docs/pr-watch-setup-guide.md).

### `/pr-watch-disable`

```text
/pr-watch-disable
```

Removes the scheduler entry for the current repo, and optionally its config file.

---

## Skills

Skills load automatically when relevant, or can be invoked directly by name.

### `engineering-principles`

The 5 core rules print at the start of every session automatically (via the `SessionStart` hook) — no invocation needed for those. This skill itself holds the full framework (tests, rationale, six named failure modes) for whenever Claude loads it on demand. `/review-diff` and code-review workflows check against it explicitly.

### `graphify`

Turns a folder into a navigable knowledge graph — nodes (files/functions/classes), edges (imports/calls/references), clustered into communities.

```text
/graphify src/
```

or naturally: *"build a knowledge graph of this repo's `services/` folder"*

Outputs `GRAPH_REPORT.md` (node/edge counts, communities, hub nodes), an interactive HTML visualization, and a JSON export. **Note:** this skill defines the contract, not a graph-building engine — wire it to your own AST/static-analysis tooling first.

### `pr-review`

End-to-end PR review: layered walkthrough (grouped by "data model," "API surface," "UI," "tests" — not diff order), a health scorecard (test coverage / scope discipline / risk), and severity-graded findings each paired with an agent-ready fix prompt. Findings are generated by 4 parallel subagents (bugs, security, architecture, quality/tests) and merged. Supports GitHub, GitLab, and Azure DevOps out of the box — run `/pr-setup` first if you haven't confirmed credentials are in place.

```text
Review PR #482
```

or, for Azure DevOps: `Review https://dev.azure.com/myorg/myproj/_git/myrepo/pullrequest/482`

Shows everything in chat first — nothing is posted to the PR until you explicitly say to post it. If a finding doesn't apply here (team convention, known false-positive), say `dismiss <finding>` — it's saved to a per-repo memory file and won't be re-flagged in future reviews of that same repo.

### `pr-comments`

Fetches and groups every comment thread on a PR (inline by file/line, PR-level separately), filters out bot/system noise, and surfaces unresolved threads first. Same GitHub/GitLab/Azure DevOps coverage as `pr-review`.

```text
Show me the comments on PR #482
```

Pairs naturally with `pr-review` — fetch the discussion, then review the code.

---

## Security agents (fan-out from `/security-scan`)

Not called directly — `/security-scan` dispatches all 11 in parallel. Listed here so you know what each one is actually checking:

| Agent | What it looks for | Example finding |
|---|---|---|
| `auth-agent` | Session/token handling, MFA, password storage, bypass paths | "Refresh token accepted after expiry — `<=` vs `<`" |
| `config-agent` | CORS, security headers, middleware config | "CORS allows `*` with credentials on `/api/*`" |
| `crypto-tls-agent` | Crypto primitives, live TLS config (via `sslyze` if an endpoint is documented) | "TLS 1.0 still enabled on `api.example.com`" |
| `data-agent` | Sensitive data in logs, API responses, client storage | "SSN logged in plaintext on payment webhook" |
| `database-agent` | Injection, connection security, privilege scope | "Raw string interpolation in SQL WHERE clause" |
| `deps-agent` | Dependency CVEs (`pip-audit`/`safety`/`npm audit`) | "CVE-2024-XXXX in `lodash@4.17.15`" |
| `iac-container-agent` | Dockerfiles, manifests, CI/CD (via `checkov`) | "Container runs as root; no `USER` directive" |
| `rbac-agent` | RBAC, object-level authorization | "Endpoint checks role but not resource ownership" |
| `sast-agent` | Static analysis (`bandit`/`semgrep`) + manual review | "`eval()` on user-controlled input" |
| `secrets-agent` | Hardcoded creds, incl. git history (`trufflehog`/`gitleaks`) | "AWS key committed in `config.py`, commit `a1b2c3d`" |
| `lint-agent` | Emoji hygiene (style only, reported separately) | "Emoji in commit message, line 3" |

---

## Hooks (automatic, no invocation)

- **`SessionStart`** — prints current branch, uncommitted file count, last commit, stash count when a session opens.
- **`PreToolUse` (Bash)** — blocks `rm -rf` outside temp/build dirs, unconfirmed force-pushes, `DROP TABLE`/`DROP DATABASE`, `git reset --hard`, and `.env` overwrite redirects before they run. Force-push needs a literal `--yes-i-mean-it` flag to pass through — a deliberate friction point, not a real git flag.
- **`Stop` / `TaskCompleted`** — desktop notification when Claude finishes a turn or task.

---

## Quick reference

| Want to... | Use |
|---|---|
| Commit staged changes | `/git-commit` |
| Write a PR description | `/pr-description` |
| Review a diff for principle violations | `/review-diff [base-branch]` |
| Log a session gotcha | `/learn` |
| Full security audit | `/security-scan` |
| Turn a transcript into MoM | `/mom <file>` |
| Build a slide deck | `/create-pptx <file> [--template <file>]` |
| Record an architecture decision | `/adr <title>` |
| Map a codebase visually | `/graphify <path>` |
| Check PR credentials for this repo | `/pr-setup` |
| Review a PR end-to-end | "Review PR #<id>" (pr-review skill) |
| Read PR discussion threads | "Show comments on PR #<id>" (pr-comments skill) |
| Generate today's timesheet line | `/timesheet` |
