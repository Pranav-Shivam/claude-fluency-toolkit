# Secrets detection checklist

- No hardcoded API key, password, or token in current source files.
- Git history has been scanned, not just the working tree — a secret removed in a later commit is still exposed to anyone with repo access.
- `.env` or other credential files are not tracked in git, even if a `.gitignore` entry for them was added later.
- Hits are triaged against obvious placeholders/examples (`sk-xxxx`, `changeme`, `<your-api-key>`) — placeholders aren't reported as findings, but realistic-looking test fixtures are checked for accidental real credentials.
- CI/CD pipeline configs don't print secrets to build logs.
- Docker Compose files and Kubernetes manifests don't hardcode secrets as plain environment variable values.
- README files and code comments don't contain example credentials that are actually live.
- Log files, fixtures, or sample data checked into the repo don't contain real captured credentials or tokens.
- Exported API-client collections (Postman, Insomnia) committed to the repo don't embed live auth headers or keys.
- Any confirmed live secret is flagged for rotation, not just removal — deleting it from the current tree doesn't invalidate it.
- Secret-scanning coverage gaps are stated explicitly when `trufflehog`/`gitleaks`/`detect-secrets` aren't installed.
