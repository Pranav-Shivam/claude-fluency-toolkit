---
paths:
  - "plugins/claude-fluency/commands/**"
  - "plugins/claude-fluency/skills/**"
---

# Command and skill conventions

**Commands** (`commands/<name>.md`): frontmatter needs `description`; add `argument-hint` if it takes args, `model` only to override the default (e.g. `git-commit.md` pins `haiku` — it's cheap and mechanical), `disable-model-invocation: true` only if the command must never auto-fire (currently just `/git-commit`). Any command that parses `$ARGUMENTS` must stop and ask if it's empty — never guess or invent a value. See `adr.md`/`mom.md`/`create-pptx.md`/`timesheet.md` for the pattern.

**Skills** (`skills/<name>/SKILL.md`): frontmatter is just `name` + `description` — every skill in this plugin loads by context or natural-language invocation, none are slash-triggered. If a new skill needs a fixed `/name` trigger instead, make it a command in `commands/`, not a skill with a `trigger:` field — `timesheet` used to do that and was converted to a plain command for exactly this reason.
