# security-scan-toolkit

An 11-agent audit fleet orchestrated by `/security-scan`. Each agent owns one domain, reads a matching checklist in `references/`, and reports findings. The 10 security agents report `{file, line, severity, issue, recommendation}`; `lint-agent` reports `{file, line, category, note}`. The orchestrator fans out to all 11 in parallel, deduplicates and severity-grades the 10 security agents' findings, and produces one report grouped by severity — with `lint-agent`'s style findings in their own section, never folded into a severity bucket.

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
| `lint-agent` | Emoji hygiene — style concern, reported separately from severity-graded findings |

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

Runs the full fleet against the current repo and returns one consolidated report grouped by severity (critical/high/medium/low), plus a separate Style/Lint section from `lint-agent`.
