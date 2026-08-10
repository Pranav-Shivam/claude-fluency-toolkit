# timesheet-toolkit

A `/timesheet` skill that turns git commits and file-modification timestamps into
ready-to-paste daily timesheet entries — one fluent paragraph per day, no bullet points, no
file names, no hours guessing.

## What's inside

- **Skill: `timesheet`** — scans every repo in your config for the requested date range,
  filters out days with no activity, and synthesizes each remaining day into a
  `Day, DD Mon  •  8:00 hrs` entry plus a 3–6 sentence paragraph describing the work.

## Setup prerequisites

This skill is config-driven — it has no hardcoded repo paths, author names, or display
names. Before first use, create `.claude/timesheet.config.json` in your working directory
(or `~/.claude/timesheet.config.json` for a global default):

```json
{
  "repos": [
    {
      "name": "ProjectDisplayName",
      "path": "/absolute/path/to/repo",
      "authors": ["Git Author Name", "Alternate Author Name"]
    }
  ]
}
```

List as many repos as you work across. `authors` should include every git author string you
commit under in that repo (a corporate `git config` often differs from a personal one).

Requires `git`, `find`, and `stat` on `PATH` — no other tooling.

## Usage

```
/timesheet                        # current week Mon → today
/timesheet last week
/timesheet 2026-05-18 2026-05-22
/timesheet 2026-05-22
```

See the skill file for full behavior, including follow-up handling (regenerate a day, adjust
tone, add missed work, change date range).
