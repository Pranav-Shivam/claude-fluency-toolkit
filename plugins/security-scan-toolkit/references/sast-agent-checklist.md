# SAST checklist

- No `subprocess`/`os.system`/shell-invoking call is built from unsanitized user input (command injection).
- No unsafe deserialization: `pickle.loads` on untrusted data, `yaml.load` without `SafeLoader`, or `eval`/`exec` on external input.
- File paths built from user input are validated/normalized to prevent path traversal (`../` sequences reaching filesystem calls).
- Server-side requests to a client-supplied URL are validated against an allowlist or otherwise guarded against SSRF.
- Template rendering doesn't pass unsanitized user input into a context that allows template injection.
- Regular expressions built from or matched against user input don't create a catastrophic-backtracking (ReDoS) risk on attacker-controlled length input.
- Static analyzer findings have been individually triaged against the actual surrounding code — false positives are excluded from the report, not passed through blindly.
- Findings that clearly belong to another domain agent (secrets, RBAC, auth) are not duplicated here unless they're a distinct pattern-level catch.
- Tool coverage gaps are stated explicitly when `bandit`/`semgrep` aren't installed, rather than silently substituting a lighter manual pass.
