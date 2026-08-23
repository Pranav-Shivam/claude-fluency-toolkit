# Changelog

Tracks `version` in `.claude-plugin/plugin.json`. Bump it and add an entry here in the same commit as any user-facing change — see root `CLAUDE.md`.

## 0.5.1 — 2026-08-23

- Fix `notify.sh` hanging the `Stop`/`TaskCompleted` hooks on Windows and WSL: it opened a blocking `System.Windows.Forms.MessageBox` that wouldn't return until the user clicked OK, stalling the session. Both Windows-facing branches now just `echo` the message instead.

## 0.5.0 — 2026-08-22

- Replace `engineering-principles`' condensed content with the full canonical framework (6 failure modes, per-section "Rule"/"Test" lines, Signal Check).
- Fix a real gap: the skill was documented as "loaded automatically" but Skills only load when Claude judges them contextually relevant — never guaranteed. The 5 core rules are now inlined directly into the `SessionStart` hook so every session gets them unconditionally, regardless of whether the skill itself gets invoked.

## 0.4.0 — 2026-08-22

- `pr-review` and `pr-comments` now cover GitHub and GitLab, not just Azure DevOps — each with its own tested REST/CLI section (`gh`/`GH_TOKEN`, `glab`/`GITLAB_TOKEN`).
- Add `/pr-setup` — detects the repo's Git host from `git remote -v`, checks whether credentials are already configured, and states the exact command to run if not, instead of letting `pr-review`/`pr-comments` fail partway through a real PR.
- Bitbucket and other hosts explicitly documented as unsupported (no tested recipe) rather than silently assumed to work.

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
