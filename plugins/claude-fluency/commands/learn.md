---
description: Append non-obvious lessons from this session to docs/gotchas.md.
---

Review this session for anything that was non-obvious, surprising, or cost real time to figure out — a gotcha in a library, an unexpected system behavior, a wrong assumption that had to be corrected, a config quirk that isn't documented anywhere else.

Read `docs/gotchas.md` first if it exists, so you don't re-record something already there. If it doesn't exist, create it with a top-level `# Gotchas` heading.

Append at the end of the file, under a heading for today's date — get the date from `date +%Y-%m-%d` rather than guessing it. If a heading for today is already present, add bullets under it instead of opening a second one:

```markdown
## YYYY-MM-DD

- One or two sentences per gotcha. State the surprising fact and the fix or workaround. No preamble, no restating the obvious.
```

Skip anything already recorded in `docs/gotchas.md`, documented elsewhere in the repo, obvious from reading the code, or specific to this one session with no future relevance. If nothing from this session actually qualifies, say so and don't write an entry just to have written one.
