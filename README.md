# claude-fluency-toolkit

A Claude Code plugin marketplace: four independent plugins for AI-assisted engineering workflows. Install only what you need.

## Plugins

| Plugin | What it gives you |
|---|---|
| [`dev-workflow-toolkit`](plugins/dev-workflow-toolkit/README.md) | An engineering-principles skill, `/git-commit` and `/pr-description` commands, a `/learn` command that logs gotchas, and safety hooks (session-start summary, a `Bash` pre-tool guard against destructive commands, cross-platform desktop notifications). |
| [`security-scan-toolkit`](plugins/security-scan-toolkit/README.md) | A 10-agent security audit fleet (auth, config, crypto/TLS, data exposure, database, dependencies, IaC/containers, RBAC, SAST, secrets) orchestrated by `/security-scan` into one severity-graded report. |
| [`devops-companion`](plugins/devops-companion/README.md) | A knowledge-graph interface skill (`graphify` — bring your own graph engine) plus Azure DevOps PR review (`pr-review`) and PR comment (`pr-comments`) skills. |
| [`doc-generation-toolkit`](plugins/doc-generation-toolkit/README.md) | `/mom <file>` turns a transcript into a structured Minutes of Meeting. `/create-pptx <file> [--template <file>]` turns a content file into a `.pptx` deck, reusing a template's header/footer/branding if given. Both preserve source facts exactly and never invent what's missing. |

## Install

Add this marketplace, then install whichever plugins you want:

```
/plugin marketplace add <your-github-username>/claude-fluency-toolkit
/plugin install dev-workflow-toolkit@claude-fluency-toolkit
/plugin install security-scan-toolkit@claude-fluency-toolkit
/plugin install devops-companion@claude-fluency-toolkit
/plugin install doc-generation-toolkit@claude-fluency-toolkit
```

Or, testing from a local clone before pushing:

```
/plugin marketplace add ./claude-fluency-toolkit
/plugin install dev-workflow-toolkit@claude-fluency-toolkit
```

## Prerequisites by plugin

- **`dev-workflow-toolkit`** — `jq` on `PATH` for the safety hook (falls back to regex extraction if absent); `bash` for the hook scripts.
- **`security-scan-toolkit`** — no tool is bundled; each agent uses whichever of `bandit`, `semgrep`, `pip-audit`, `safety`, `npm audit`, `trufflehog`, `gitleaks`, `detect-secrets`, `checkov`, `sslyze` are on `PATH`, and explicitly reports a coverage gap for any that are missing.
- **`devops-companion`** — an Azure DevOps PAT or authenticated `az devops` CLI for `pr-review`/`pr-comments`; a graph-building implementation you supply for `graphify` (see that plugin's README).
- **`doc-generation-toolkit`** — `/mom` needs no extra setup for `.txt`/`.pdf`; `.docx` needs `pandoc`, `python-docx`, or `unzip` on `PATH`. `/create-pptx` requires `python3` with `python-pptx` installed (`pip install python-pptx`).

See each plugin's own README for detail.

## Structure

```
claude-fluency-toolkit/
├── .claude-plugin/marketplace.json
└── plugins/
    ├── dev-workflow-toolkit/
    ├── security-scan-toolkit/
    ├── devops-companion/
    └── doc-generation-toolkit/
```

## License

MIT — see [LICENSE](LICENSE).
