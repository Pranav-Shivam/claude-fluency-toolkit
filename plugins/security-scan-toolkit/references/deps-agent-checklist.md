# Dependency security checklist

- Every dependency manifest present in the repo (Python, Node, or otherwise) has been checked, not just the first one found.
- `pip-audit`/`safety` (Python) and `npm audit`/`yarn audit`/`pnpm audit` (Node) results have been reviewed, not just skimmed for a pass/fail count.
- Each reported CVE has been cross-checked against whether the vulnerable code path is actually reachable from how this project uses the package.
- Lockfiles are present and committed (`package-lock.json`, `poetry.lock`, `requirements.txt` pinned versions) so builds are reproducible and auditable.
- No dependency is pulled from an unpinned `git+https://` reference or a floating tag that could change contents without notice.
- Transitive dependencies with known CVEs are flagged even when the direct dependency itself is clean.
- Packages that are multiple major versions behind or unmaintained for years are flagged as a lower-severity supply-chain risk, even absent a specific CVE.
- No dependency was added from an unfamiliar or unverified registry/source outside the standard package index for its ecosystem.
- Build/CI steps don't install dependencies with disabled integrity checks (e.g. `--no-verify`, checksum verification turned off).
