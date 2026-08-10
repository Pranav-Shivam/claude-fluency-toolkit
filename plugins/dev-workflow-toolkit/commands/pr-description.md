---
description: Generate a PR description from the diff against the base branch.
model: sonnet
---

Determine the repo's default branch: try `main` first. If `git rev-parse --verify main` fails, fall back to `git symbolic-ref refs/remotes/origin/HEAD` (or `master` if that also fails).

Run `git diff <default-branch>...HEAD` and read the full output, along with `git log <default-branch>...HEAD --oneline` for commit context.

Write a PR description with exactly these sections:

```markdown
## What changed

A concise summary of the actual change set — what files/areas were touched and what behavior is different now. Group related changes; don't list every file.

## Why

The motivation for the change, inferred from the commits, diff content, and any linked context available in the branch. If the motivation isn't evident from the diff, say what's unclear rather than guessing at business context.

## Testing

How this was or should be verified — existing tests run, new tests added, manual steps to confirm the change works. If no verification is evident in the diff, say so explicitly rather than inventing a testing story.
```

Base everything on what's actually in the diff and commit log. Do not invent features, edge cases, or testing steps that aren't evidenced by the changes.
