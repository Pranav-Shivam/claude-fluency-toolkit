# claude-fluency-toolkit

A Claude Code plugin marketplace with one plugin — `claude-fluency` — bundling five toolkits for AI-assisted engineering workflows.

## What's inside

| Toolkit                  | What it gives you                                                                                                                                                                                                                                                                                                                                                             |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Engineering workflow     | An engineering-principles skill,`/git-commit` and `/pr-description` commands, `/review-diff` for principle-based diff review, a `/learn` command that logs gotchas, and safety hooks (session-start summary, a `Bash` pre-tool guard against destructive commands, cross-platform desktop notifications).                                                           |
| Security                 | An 11-agent audit fleet (auth, config, crypto/TLS, data exposure, database, dependencies, IaC/containers, RBAC, SAST, secrets, emoji lint) orchestrated by`/security-scan` into one severity-graded report plus a separate style/lint section.                                                                                                                              |
| Devops / knowledge graph | A knowledge-graph interface skill (`graphify` — bring your own graph engine), PR review (`pr-review`) and PR comment (`pr-comments`) skills covering GitHub/GitLab/Azure DevOps, and `/pr-setup` to check your repo's credentials before using either.                                                                                                               |
| Document generation      | `/mom <file>` turns a transcript into a structured Minutes of Meeting. `/create-pptx <file> [--template <file>]` turns a content file into a `.pptx` deck, reusing a template's header/footer/branding if given. `/adr` drafts an Architecture Decision Record from the current conversation/diff. All preserve source facts exactly and never invent what's missing. |
| Timesheet                | `/timesheet` generates ready-to-paste daily timesheet entries from git history and file-modification timestamps across your configured repos. Config-driven — no hardcoded paths, authors, or names.                                                                                                                                                                       |

See [`plugins/claude-fluency/README.md`](plugins/claude-fluency/README.md) for full command/skill reference and per-tool prerequisites, or [`plugins/claude-fluency/HOWTOUSE.md`](plugins/claude-fluency/HOWTOUSE.md) for a worked example of every command, skill, and agent — both ship with the plugin on install.

## Install

Two commands. Send each as its own message — the CLI only executes the first `/` command in a pasted block, so pasting both at once will run just the first and silently drop the second:

```text
/plugin marketplace add Pranav-Shivam/claude-fluency-toolkit
```

```text
/plugin install claude-fluency@claude-fluency-toolkit
```

Or, testing from a local clone before pushing:

```text
/plugin marketplace add ./claude-fluency-toolkit
/plugin install claude-fluency@claude-fluency-toolkit
```

### Troubleshooting: "`/plugin` isn't available in this environment"

`/plugin` only works in Claude Code CLI itself — not the VSCode/JetBrains extension chat panel, not claude.ai. If you hit that error:

1. Open real terminal (VSCode integrated terminal works fine).
2. Run `claude` to start CLI session there.
3. Run install commands above inside that session.

## Update

```text
/plugin marketplace update claude-fluency-toolkit
/plugin update claude-fluency@claude-fluency-toolkit
```

Run in real CLI terminal (see troubleshooting above) — not the VSCode/JetBrains extension chat panel.

`/plugin update` opens an interactive Plugin Manager instead of updating directly. It lands on the **Discover** tab. Navigate manually:

1. **Marketplaces** tab — select `claude-fluency-toolkit`, trigger refresh/update. Pulls latest source from your local path (or git remote) into the marketplace cache.
2. **Installed** tab — select `claude-fluency`, trigger its update action. Re-installs the plugin from the refreshed marketplace source.
3. Restart Claude Code — update doesn't take effect until restart.

## Uninstall

```text
/plugin uninstall claude-fluency@claude-fluency-toolkit
```

Then, to drop the marketplace itself:

```text
/plugin marketplace remove claude-fluency-toolkit
```

## Prerequisites

- **Engineering workflow hooks** — `jq` on `PATH` (falls back to regex extraction if absent); `bash` for the hook scripts.
- **Security fleet** — no tool is bundled; each agent uses whichever of `bandit`, `semgrep`, `pip-audit`, `safety`, `npm audit`, `trufflehog`, `gitleaks`, `detect-secrets`, `checkov`, `sslyze` are on `PATH`, and explicitly reports a coverage gap for any that are missing; `lint-agent` needs only `Grep`.
- **Devops skills** — `pr-review`/`pr-comments` need auth for whichever Git host your repo is on (GitHub, GitLab, or Azure DevOps); run `/pr-setup` to check and get the exact setup command. A graph-building implementation you supply for `graphify`.
- **Document generation** — `/mom` needs no extra setup for `.txt`/`.pdf`; `.docx` needs `pandoc`, `python-docx`, or `unzip` on `PATH`. `/create-pptx` requires `python3` with `python-pptx` installed (`pip install python-pptx`).
- **Timesheet** — `git`, `find`, `stat` on `PATH`; a `.claude/timesheet.config.json` you create listing your repos, authors, and display names.

See [`plugins/claude-fluency/README.md`](plugins/claude-fluency/README.md) for detail.

## Structure

```text
claude-fluency-toolkit/
├── .claude-plugin/marketplace.json
└── plugins/
    └── claude-fluency/
        ├── .claude-plugin/plugin.json
        ├── commands/
        ├── skills/
        ├── agents/
        ├── references/
        ├── hooks/
        ├── scripts/
        ├── README.md
        ├── HOWTOUSE.md
        └── CHANGELOG.md
```

## License

MIT — see [LICENSE](LICENSE).
