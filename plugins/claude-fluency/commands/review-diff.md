---
description: Review a diff (yours, a teammate's, or another AI's) against the engineering-principles skill — architecture consistency, scope, and hidden risk, not style.
argument-hint: "[base-branch] (defaults to the repo's default branch)"
model: sonnet
---

## Why this command exists

The `engineering-principles` skill in this plugin shapes how Claude *writes* code. This command is the other half: a structured way to check code *after* it's written — yours, a teammate's, or another AI's — against the same five principles, plus architectural consistency the writer may not have had context for. This is the review a senior engineer runs on a PR they didn't write, not a linter. It is not a style/lint pass — skip anything a formatter or linter would already catch.

## 1. Get the diff

Argument: `$ARGUMENTS` is an optional base branch/ref to diff against. If empty, determine the repo's default branch — try `main` first, fall back to `git symbolic-ref refs/remotes/origin/HEAD` or `master`.

Run `git diff <base>...HEAD` and `git log <base>...HEAD --oneline`. If there's no diff, say so and stop.

## 2. Build context before judging anything

Before flagging anything, look at what surrounds the diff, not just the diff itself:

- Read the full file(s) touched, not just the changed hunks — a change that looks fine in isolation can violate a pattern established elsewhere in the same file.
- Check for a `CLAUDE.md`, `docs/adr/`, or architecture doc in the repo and read anything relevant to the area touched. A change that looks like over-engineering or under-engineering out of context is sometimes deliberate — don't flag a pattern as wrong without checking whether it was a documented decision first.
- If a function or block being modified looks unusual (deliberately verbose error handling, an odd retry count, a seemingly redundant check), check git blame / commit history for it before assuming it's a mistake. Code that looks removable sometimes exists because of a past incident — removing it silently is the exact failure mode this command exists to catch.
- Note whether the diff touches a higher-risk area — auth, payments, secrets/config, a database migration, a public API contract, or a permissions/access-control check. These areas get closer reading in step 3, not because the rest doesn't matter, but because the cost of a miss there is disproportionate to its size in the diff.

## 3. Review against these dimensions

For each, report only what you actually found — an empty section is a fine and honest result, not a failure to find something. Tag each finding **High** / **Medium** / **Low** confidence (see step 4) — this is what keeps a thorough review from drowning the one real issue under a pile of maybes.

**Scope creep** — Does every changed line trace to an actual requirement (the PR description, linked ticket, or commit messages)? Flag refactors, renames, or "while I'm here" changes bundled into a diff that claims to do something narrower.

**Architectural consistency** — Does this change follow the same patterns (layering, error handling, naming, module boundaries) already established in the surrounding code, or does it introduce a parallel way of doing something the codebase already does elsewhere? Flag duplicated logic that could have reused an existing utility/service.

**Silently undone reasoning** — Does this diff remove, simplify, or "clean up" something that git history or an ADR suggests was deliberate? This is the highest-value thing this command checks for and the easiest for a fast review to miss.

**Phantom or unverified APIs** — For any new library/framework call, is the signature used actually correct for the version in this repo's lockfile/manifest, not just plausible-looking? Spot-check anything unfamiliar rather than assuming it compiles because it reads correctly.

**Bounded edits** — Is the diff sized appropriately to the task, or does it touch far more than the stated change requires? Note if it looks like it should have been split into multiple smaller changes.

**Verification** — Does the diff include or update tests for the behavior it changes? If tests exist, are they meaningful (actually exercise the changed behavior) rather than just present? Note if verification is claimed in the PR description but not evidenced in the diff.

**Security-adjacent risk and blast radius** — Anything touching auth, secrets, input handling, permissions, or a database query that looks worth a closer look. For anything flagged here, state the blast radius in one line — what's actually exposed or broken if this specific line is wrong (e.g. "a missing tenant-ID filter here would let one org read another's rows," not just "this looks risky"). A concrete blast radius is what separates a real finding from a vague unease; if you can't state one, the finding probably belongs at Low confidence or not at all. This is a lightweight pass, not a substitute for `/security-scan` — flag it and recommend that command for anything that looks non-trivial here.

## 4. Confidence, not just presence

An unfiltered review that reports every maybe-issue trains reviewers to skim past all of it, including the one finding that matters. Before including a finding, ask whether you could point to the specific line, pattern, or history that supports it:

- **High** — backed by something concrete you can cite: a contradicted ADR/commit, a lockfile version that doesn't match the API used, a test that doesn't actually cover the changed branch.
- **Medium** — a real pattern deviation or plausible risk, but you're inferring intent rather than citing a source for it.
- **Low** — worth a mention, but closer to a stylistic preference or a hunch than something you'd block a merge on.

Default to omitting a Low-confidence item entirely unless it's cheap to fix and worth a passing note — don't pad a section to look thorough.

## 5. Report format

```markdown
# Diff Review — <base>...HEAD

## Summary
1-2 sentences: what this diff does and overall impression (clean / needs discussion / needs changes).

## Findings

### Scope creep
- [Confidence] ...or "None found — every change traces to the stated intent."

### Architectural consistency
- [Confidence] ...

### Silently undone reasoning
- [Confidence] ...

### Phantom or unverified APIs
- [Confidence] ...

### Bounded edits
- [Confidence] ...

### Verification
- [Confidence] ...

### Security-adjacent risk and blast radius
- [Confidence] ... (blast radius: ...) — or "None flagged — run /security-scan for full coverage if this touches a sensitive area."

## Recommendation
Merge as-is / merge with minor follow-ups / needs changes before merge — with the one or two things that actually matter most (normally the High-confidence findings), not a restated list of every bullet above.
```

Do not soften a real finding to be polite, and do not manufacture a finding to make the review look thorough — an honest "this is clean" is a valid and useful outcome.
