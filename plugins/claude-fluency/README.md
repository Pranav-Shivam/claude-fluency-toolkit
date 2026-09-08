# claude-fluency

One plugin, seven toolkits: engineering principles + safety hooks, a security audit fleet, devops/knowledge-graph skills, document generation, timesheet generation, prompt engineering, and writing style.

See [`HOWTOUSE.md`](HOWTOUSE.md) for a runnable example of every command, skill, and agent listed below.

## What's inside

### Engineering workflow

- **Skill: `engineering-principles`** — five principles (clarify before building, lean code, bounded edits, outcome-oriented execution, verify and recover) plus six named failure modes, each with a concrete test/rule. The 5 core rules are injected into every session unconditionally by the `SessionStart` hook (skills only load when Claude judges them relevant, which isn't a guarantee); the full framework with tests, tables, and failure-mode detail lives in this skill for on-demand loading.
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
- **Command: `/pr-setup`** — detects your repo's Git host (GitHub, GitLab, Azure DevOps) from `git remote -v` and checks whether the credentials `pr-review`/`pr-comments` need are already in place, telling you the exact command to run if not. Run once per repo before the two skills below.
- **Skill: `pr-review`** — end-to-end PR review: layered walkthrough, health score, severity-graded findings with fix prompts. Findings come from 4 parallel specialized subagents (bugs, security, architecture, quality/tests) merged and deduped, and `dismiss <finding>` saves false-positives/accepted exceptions to a per-repo memory file so future reviews of that repo stay quieter. Shows results in chat first; posts nothing until confirmed. Covers GitHub, GitLab, and Azure DevOps.
- **Skill: `pr-comments`** — fetches and groups PR comment threads (inline by file/line, PR-level separately), filtering system noise. Same platform coverage as `pr-review`.
- **Command: `/pr-watch-setup`** — Azure DevOps only. Schedules a recurring check (cron on Linux/macOS, Task Scheduler on Windows) for new active PRs on the current repo, desktop-notifies, and opens an interactive terminal offering to run `/pr-review` for whichever PRs you approve. Everything (org/project/repo/PAT) is written to a per-repo, per-machine config file — nothing is baked into the plugin.
- **Command: `/pr-watch-disable`** — removes the scheduler entry (and optionally the config) for the current repo.

### Document generation

- **Command: `/mom <file>`** — reads a meeting transcript (`.docx`, `.pdf`, or `.txt`) and outputs a clean Markdown MoM (discussion points, decisions, action items with owner/due date, blockers, next steps). Marks unstated owner/deadline **TBD** instead of inventing one.
- **Command: `/create-pptx <content-file> [--template <template-file>]`** — plans a slide outline and generates a `.pptx` deck via `python-pptx`. A `--template` `.pptx` supplies the design base (fonts, colors, header/footer, logo). Never copies large paragraphs verbatim or invents facts.
- **Command: `/adr <short decision title>`** — drafts a Nygard-style ADR from the current conversation/diff, auto-numbers it against `docs/adr/`, and writes `docs/adr/00XX-kebab-case-title.md`. Marks unstated figures **TBD**.

### Timesheet

- **Command: `/timesheet [last week | YYYY-MM-DD [YYYY-MM-DD]]`** — scans every repo in your config for the requested date range, filters out inactive days, and synthesizes each remaining day into a `Day, DD Mon  •  8:00 hrs` entry plus a 3–6 sentence paragraph.

### Prompt engineering

- **Command: `/prompt-master <rough idea>`** — turns a rough idea into one paste-ready prompt for a named target tool (Claude/Claude Code, GPT-5.x, reasoning-native models, Cursor/Windsurf/Cline, Midjourney/SD/DALL-E, ComfyUI), or breaks down/adapts/simplifies/splits an existing prompt. Confirms the target tool, asks at most 3 clarifying questions, silently fixes vague verbs/missing success criteria/no output format, strips pasted credentials before writing anything. Reference templates (RTF, CO-STAR, RISEN, CRISPE, few-shot, file-scope, agent-brief, visual, image-edit, ComfyUI, decompiler) load one at a time from `references/prompt-master-templates.md` — never the whole file.

### Writing style

- **Command: `/humanize [text or file]`** — rewrites AI-generated or AI-assisted writing (prose, docs, README/markdown, email, chat, commit messages, code comments/docstrings) so it reads like a person wrote it, by cutting mechanical vocabulary, hedge-stacking, and repetitive rhythm. Scoped to writing quality only — explicitly will not evade AI-detection classifiers (Turnitin/GPTZero/etc.) or strip watermark/provenance metadata, never fabricates a human backstory, never degrades content to fake imperfection. Shows a summary (or diff, for code) of what changed so nothing substantive shifts unnoticed. Auto-fires on phrases like "make this sound less like ChatGPT," not just the slash form. Tell-list lives in `references/humanize-ai-tells.md`.

## Setup prerequisites

- **Engineering workflow hooks** — `jq` on `PATH` (safety hook falls back to regex if absent); `bash` (POSIX-ish, not `sh`); for notifications, `notify-send` (Linux), AppleScript/`osascript` (macOS, built in), or `powershell.exe` reachable from WSL/Git Bash (Windows). The force-push block requires a literal `--yes-i-mean-it` flag as a deliberate friction point — adjust the sentinel in `scripts/pre-tool-safety.sh` if needed. The `rm -rf` check allowlists common temp/build dirs (`/tmp`, `node_modules`, `dist`, `build`, `.cache`, `__pycache__`, `.next`, `venv`, `.venv`).
- **`/security-scan`** — none of the external scanning tools are bundled; each agent runs whichever of its tools are on `PATH` and states a coverage gap if one is missing. For full coverage install: `bandit`, `semgrep` (SAST); `pip-audit`, `safety` (Python deps), `npm`/`yarn`/`pnpm audit` (Node deps); `trufflehog`, `gitleaks`, `detect-secrets` (secrets); `checkov` (IaC/container); `sslyze` (live TLS checks).
- **`pr-review` / `pr-comments`** — cover GitHub, GitLab, and Azure DevOps, each with its own tested REST/CLI section in the skill files. None of the credentials are included — run `/pr-setup` to check what's already configured and get the exact command for what's missing (`gh auth login`, `glab auth login`, or an Azure DevOps PAT + `az devops configure`). Bitbucket and other hosts have no tested recipe yet.
- **`/pr-watch-setup`** — needs `az` CLI on `PATH` and either an existing `az devops` login or a PAT you provide during setup (`Code (Read & Write)` scope). Linux/macOS use system `cron` (must be running — `systemctl is-active cron` / `launchd` is always on for macOS) and, for the terminal it opens, one of `gnome-terminal`/`x-terminal-emulator`/`xterm` (Linux) or Terminal.app/iTerm2 (macOS). Windows uses `schtasks` and opens a new `powershell` window — less battle-tested than the Linux/macOS path.
- **`graphify`** — no dependency by itself, but produces nothing until connected to a real graph-building implementation.
- **`/mom`** — `.txt`/`.pdf` need no setup; `.docx` needs `pandoc` (preferred), `python-docx`, or `unzip` on `PATH`.
- **`/create-pptx`** — requires `python3` with `python-pptx` (`pip install python-pptx`). `.docx` uses the same extraction chain as `/mom`.
- **`/adr`** — no extra setup; writable `docs/adr/` directory (created automatically if missing).
- **`/prompt-master`** — no extra setup or credentials; reads `references/prompt-master-templates.md` from the plugin tree on demand.
- **`/humanize`** — no extra setup or credentials; reads `references/humanize-ai-tells.md` from the plugin tree on demand.
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

/pr-setup
/pr-watch-setup
/pr-watch-disable

/mom transcripts/2026-08-10-standup.txt
/create-pptx notes/kickoff.pdf --template branding/header-footer-template.pptx
/adr use Azure SQL Serverless instead of Snowflake for OLTP

/timesheet
/timesheet last week

/prompt-master write a Cursor prompt to fix a null-check bug in auth.ts

/humanize this reads like ChatGPT wrote it, make it sound like a person
```
