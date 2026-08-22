---
paths:
  - "plugins/claude-fluency/agents/**"
  - "plugins/claude-fluency/references/**"
  - "plugins/claude-fluency/commands/security-scan.md"
---

# Security agent fleet — contract

Fixed contract, not a suggestion — copy an existing agent (`auth-agent.md` is a clean template):

```yaml
name: <x>-agent
tools: [Bash, Read, Grep, Glob]
model: sonnet
permissionMode: plan
```

Required body parts, in order:
1. One-sentence role statement.
2. "Before starting, read `references/<name>-agent-checklist.md`" — and create that checklist file (8–15 terse bullets, `# <Domain> checklist` heading). No agent ships without its matching reference.
3. A "Stay in your lane" paragraph naming which other agents own adjacent findings. This is what stops the orchestrator from silently dropping overlap as a duplicate — skip it and your findings get eaten.
4. Closing report schema, copied verbatim: `{file, line, severity, issue, recommendation}`. (`lint-agent` is the one intentional exception: `{file, line, category, note}` — it flags style, not vulnerabilities.)
5. **Wire the new agent into `commands/security-scan.md`.** Dropping a file into `agents/` does not get it fanned out — the orchestrator's agent list is hardcoded there.

## Overlap is intentional here, nowhere else

`sast-agent` and `database-agent` both flag injection; `crypto-tls-agent`/`auth-agent`/`secrets-agent` all touch JWT/key handling. That's cross-checking by design (see each agent's "stay in your lane" paragraph), not the kind of duplication the `engineering-principles` skill tells you to cut. If you're trimming "redundant" agents to satisfy that skill, you're applying it to the wrong layer — it governs application code, not this fleet's deliberate redundancy.

`references/*-agent-checklist.md` is a security-fleet-only convention — commands and skills elsewhere in the plugin keep everything inline and don't get a matching reference file.
