---
description: Write a Conventional Commits-style message from the currently staged diff.
model: haiku
disable-model-invocation: true
---

Run `git diff --staged` and read the full output.

If there is no staged diff, say so and stop — do not fabricate a commit message for an empty diff.

Otherwise, write a commit message in Conventional Commits format:

```
type(scope): short summary in imperative mood

- what changed
- why it changed, if not obvious from the change itself
```

Rules:
- `type` is one of `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`, `build`, `ci` — pick the one that best matches the actual diff.
- `scope` is the module, directory, or component touched — omit it only if the change is truly repo-wide.
- The summary line is imperative ("add", not "added" or "adds"), lowercase after the colon, no trailing period, under ~72 characters.
- The bullet body describes only what is actually present in the diff. Never invent changes, motivations, or context that isn't visible in the diff itself.
- If the diff spans clearly unrelated concerns, say so instead of forcing one message over it, and suggest splitting the commit.

Output only the commit message — no preamble, no explanation of what you did.
