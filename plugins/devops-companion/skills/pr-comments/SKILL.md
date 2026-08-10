---
name: pr-comments
description: Fetch and display all comments/threads on a pull request. Groups by file (inline) and PR-level, filters system-generated noise, and shows author, status, and replies. Pairs with pr-review.
---

# PR Comments

Fetches every comment thread on a pull request and presents them grouped and filtered, rather than as a flat, noisy list.

## Workflow

1. **Fetch all threads.** Pull every comment thread on the PR, including resolved/closed ones — a thread being resolved doesn't mean it's not worth seeing during review.
2. **Filter system noise.** Drop auto-generated threads (build-status updates, automated policy check comments, bot-posted "PR updated" notices) unless they contain an actual human-relevant message — the goal is signal, not a full audit log.
3. **Group by location:**
   - **Inline comments**, grouped by file, then by line — so all discussion on one file/line reads together instead of interleaved with unrelated files.
   - **PR-level comments** (not attached to a specific line) in their own section.
4. **Show per thread:** the author, the thread's current status (active/resolved/pending), the original comment, and any replies in order — a thread with a question and an unresolved reply is more actionable to surface clearly than one that reads as flat text.
5. **Surface unresolved threads first**, or mark them distinctly — these are the ones most likely to need action before merge.

## Azure DevOps

**Prerequisites:** the same PAT/CLI auth as `pr-review` — a PAT with `Code (Read)` scope is sufficient for read-only comment fetching.

**Fetching threads:**
- REST: `GET https://dev.azure.com/<org>/<project>/_apis/git/repositories/<repo>/pullrequests/<id>/threads?api-version=7.1`. Each thread includes `comments[]` (author, content, `commentType`), `status` (active/fixed/closed/pending/wontFix), and, for inline threads, a `threadContext` with the file path and line range.
- Filter out threads where every comment has `commentType: "system"` — these are Azure DevOps's own auto-generated entries (e.g. "voted on this pull request"), not human commentary.
- CLI: `az repos pr show --id <id>` doesn't return thread detail directly in most CLI versions — prefer the REST endpoint above for comment content.
