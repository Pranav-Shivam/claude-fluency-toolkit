# Changelog

Tracks `version` in `.claude-plugin/plugin.json`. Bump it and add an entry here in the same commit as any user-facing change — see root `CLAUDE.md`.

## 0.3.0 — 2026-08-22

- Convert `timesheet` from a skill with a `trigger: /timesheet` field into a real command (`commands/timesheet.md`) — it was always invoked as a slash command, never loaded contextually like the other four skills.
- Add path-scoped rules (`.claude/rules/security-agents.md`, `commands-and-skills.md`, `hooks.md`) so subsystem-specific contracts stop living entirely in root `CLAUDE.md`.
- `SessionStart` now prints a one-line command index pointing to `HOWTOUSE.md` instead of only git status.
- Add this changelog.

## 0.2.0 — 2026-08-22

- Add root `CLAUDE.md` documenting agent/command/skill contracts, hook protocol, and the one-plugin-vs-several tradeoff.
- Move `HOWTOUSE.md` into `plugins/claude-fluency/` so it ships on `/plugin install` — it previously sat at the repo root, invisible to anyone who hadn't browsed GitHub before installing.

## 0.1.0 — 2026-08-11

- Baseline: five separate toolkits (engineering workflow, security fleet, devops/knowledge-graph, document generation, timesheet) merged into one `claude-fluency` plugin under a single marketplace entry.
