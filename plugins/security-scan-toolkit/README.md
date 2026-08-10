# security-scan-toolkit

A 10-agent security audit fleet orchestrated by `/security-scan`. Each agent owns one domain, reads a matching checklist in `references/`, and reports findings as `{file, line, severity, issue, recommendation}`. The orchestrator fans out to all 10 in parallel, deduplicates overlapping findings, grades severity consistently, and produces one report grouped by severity.

## Agents

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

## Setup prerequisites

None of the external scanning tools are bundled — each agent runs whichever of its tools are on `PATH` and explicitly states a coverage gap in its findings if a tool is missing, rather than silently substituting a lighter check. For full coverage, install what's relevant to your stack:

- `bandit`, `semgrep` (SAST)
- `pip-audit`, `safety` (Python deps), `npm`/`yarn`/`pnpm audit` (Node deps — usually already available with the package manager)
- `trufflehog`, `gitleaks`, `detect-secrets` (secrets, including git history)
- `checkov` (IaC/container)
- `sslyze` (live TLS checks — only used if a project endpoint is documented)

## Usage

```
/security-scan
```

Runs the full fleet against the current repo and returns one consolidated report grouped by severity (critical/high/medium/low).

## Note on scope

The source material this plugin was drafted from described "10 security subagents" but listed 11 agent names, including an `emoji-agent` (flags emoji characters in code, with extra scrutiny for emoji inside SQL strings or cloud-service queries due to encoding risk). That's a style/lint concern, not a security concern, so it was left out of this plugin. If you want it back, it fits better as a standalone lint-toolkit plugin than inside a security fleet.
