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

## Subsystem contracts live in `.claude/rules/`, not here

Adding a security agent, a command, a skill, or touching a hook script each has a real contract — but those contracts only matter to a session actually editing those files, so they're path-scoped rules instead of standing rules everyone pays for:

- `.claude/rules/security-agents.md` — agent frontmatter shape, checklist pairing, report schema, `security-scan` wiring, the intentional-overlap carve-out against `engineering-principles`.
- `.claude/rules/commands-and-skills.md` — command frontmatter fields, `$ARGUMENTS` handling, the skill/command boundary.
- `.claude/rules/hooks.md` — hook stdin/exit-code protocol, performance rules, `SessionStart` output budget.

These load automatically when Claude touches a matching path. If you're editing this repo and one of those areas feels underspecified, check there before guessing.

## Versioning

`plugin.json`'s `version` is the only version number in the repo. Clients skip an update when that string doesn't change, so **bump it on every user-facing change** — new command, new agent, changed behavior — and add an entry to `plugins/claude-fluency/CHANGELOG.md` in the same commit. This has not been enforced historically (the five-plugins-into-one merge and the `/adr`+`/review-diff` addition both landed without a version bump); treat that as the past, not the convention to continue.

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
