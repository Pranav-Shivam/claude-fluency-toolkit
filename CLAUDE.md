# claude-fluency-toolkit

Marketplace repo, one plugin (`claude-fluency`) at `plugins/claude-fluency/`. Read this before adding or restructuring anything — most of what breaks here breaks silently (no CI, no tests, prose-only files).

## Map

```
.claude-plugin/marketplace.json          marketplace + plugin list
plugins/claude-fluency/
  .claude-plugin/plugin.json             plugin manifest (name, version, description, author)
  commands/*.md                          8 slash commands
  skills/<name>/SKILL.md                 5 skills (auto-loaded or invoked by name)
  agents/*-agent.md                      11-agent security fleet, fanned out by /security-scan
  references/*-agent-checklist.md        1:1 checklist per security agent
  hooks/hooks.json + scripts/*.sh        SessionStart, PreToolUse(Bash), Stop, TaskCompleted
  README.md, HOWTOUSE.md                 ship with the plugin — end-user facing
README.md                                repo landing page (GitHub only, does not ship)
```

**Directory contract**: `commands/`, `skills/`, `agents/`, `hooks/` must sit at the plugin root (next to `.claude-plugin/`), never inside it. The loader auto-discovers by folder name and location — no manifest entry needed per command/skill/agent. **Editing `marketplace.json` or `plugin.json` is only required for a new plugin entry or a version bump** — never for adding a command/skill/agent to the existing tree.

## Adding a new security agent

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

<!--
RATIONALE: security fleet overlap is intentional, engineering-principles' "no duplication" rule is not.
sast-agent and database-agent both flag injection; crypto-tls/auth/secrets all touch JWT/key handling.
That's cross-checking by design (see each agent's "stay in your lane" paragraph), not the kind of
duplication engineering-principles tells you to cut. If you're trimming "redundant" agents to satisfy
that skill, you're applying it to the wrong layer — the skill governs application code, not the
audit fleet's deliberate redundancy.
-->

## Adding a command or skill

Commands (`commands/<name>.md`): frontmatter needs `description`; add `argument-hint` if it takes args, `model` only to override the default (e.g. `git-commit.md` pins `haiku` — it's cheap and mechanical), `disable-model-invocation: true` only if the command must never auto-fire (currently just `/git-commit`). Any command that parses `$ARGUMENTS` must stop and ask if it's empty — never guess or invent a value. See `adr.md`/`mom.md`/`create-pptx.md` for the pattern.

Skills (`skills/<name>/SKILL.md`): frontmatter is just `name` + `description` unless the skill is slash-invoked, in which case add `trigger: /<name>` (only `timesheet` does this today — it's a one-off exception, not a pattern to copy onto the other four skills, which load by context/natural language).

`references/` is a security-fleet-only convention. Commands and skills keep everything inline in their own file; don't split them out just because the agents do.

## Hooks

Any change to `hooks/hooks.json` or `scripts/*.sh` needs a careful read, not a quick edit — `PreToolUse` fires on every Bash call, so slow or wrong logic there taxes (or breaks) every command in the session. Protocol, undocumented anywhere but the script itself: hook JSON payload arrives on **stdin**, `jq` parses it with a regex fallback if `jq` is missing, exit code `2` blocks with a message on stderr, exit `0` passes. Prefer shell + `jq` over spawning another interpreter — same performance reasoning.

## Versioning

`plugin.json`'s `version` is the only version number in the repo. Clients skip an update when that string doesn't change, so **bump it on every user-facing change** — new command, new agent, changed behavior. This has not been enforced historically (the five-plugins-into-one merge and the `/adr`+`/review-diff` addition both landed without a version bump); treat that as the past, not the convention to continue.

Before committing a structural change, sanity-check it locally:
```
claude plugin validate .
/plugin marketplace add ./
/plugin install claude-fluency@claude-fluency-toolkit
```

## One plugin vs. several

<!--
RATIONALE: bundled into one plugin (2026-08, commit 8296636) to cut install friction — five
separate `/plugin install` calls felt like too much ceremony for one person's toolkit. Real cost:
anyone who only wants /timesheet also gets the 11-agent security fleet, the global Bash safety
hook, and the session-start banner, with no way to opt out short of a full uninstall. No well-starred
marketplace repo surveyed bundles unrelated domains this way — the common patterns are many small
plugins (wshobson/agents, trailofbits/skills-curated) or a handful grouped by coherent role
(LerianStudio/ring's 4 plugins-by-team). The schema already supports a middle path without moving
a single file: `strict: false` in plugin.json plus per-entry `source` subdirectories lets
marketplace.json register multiple plugin entries against this same tree. Revisit before adding a
sixth unrelated toolkit — don't just keep bundling by default.
-->

Current state: one marketplace entry, one plugin, five unrelated toolkits (engineering workflow, security, devops, document generation, timesheet). This was a deliberate tradeoff, not an oversight — see the comment above for the reasoning and the documented way out.

## Documentation

`README.md` (root, GitHub-only), `plugins/claude-fluency/README.md` (ships with install), and `plugins/claude-fluency/HOWTOUSE.md` (ships with install) cover overlapping ground on purpose — root `README.md` is the pitch, the plugin `README.md` is the reference, `HOWTOUSE.md` is the worked-example walkthrough. If you're updating command behavior, check whether the change shows up in more than one of these before you call it done — don't let them drift apart, but don't collapse them into one file either.

## Dogfooding

`/learn` writes to `docs/gotchas.md`; `/adr` writes to `docs/adr/`. Use them on this repo's own development — a toolkit that doesn't use its own tools is a bad advertisement for them.

## What "done" means here

No CI, no test harness — every command/agent/skill is a prose file with no automated way to check it works. "Verify before claiming done" (`engineering-principles` principle 5) means, concretely: install the plugin from a local marketplace add in a scratch project and actually run the new/changed command, skill, or agent before calling the change finished.
