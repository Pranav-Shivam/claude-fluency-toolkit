---
name: pr-comments
description: Fetch and display all comments/threads on a pull request. Groups by file (inline) and PR-level, filters system-generated noise, and shows author, status, and replies. Pairs with pr-review.
---

# PR Comments

Fetches every comment thread on a pull request and presents them grouped and filtered, rather than as a flat, noisy list.

## Workflow

1. **Resolve the PR.** Take a PR id or a PR URL and resolve it to org/project/repository/id before fetching. If the reference is ambiguous, say so rather than guessing at a repo — fetching the wrong PR's comments silently is worse than asking.
2. **Fetch all threads.** Pull every comment thread on the PR, including resolved/closed ones — a thread being resolved doesn't mean it's not worth seeing during review. Follow pagination if the API returns a partial page; a truncated comment list looks identical to a quiet PR.
3. **Filter system noise.** Drop threads where every comment was machine-authored — build-status updates, policy-check results, "PR updated" notices, vote-change entries. Keep the thread if any comment in it is human-authored, even when the first one isn't: people reply to bot threads. The goal is signal, not a full audit log.
4. **Group by location:**
   - **Inline comments**, grouped by file, then ascending by line — so all discussion on one file/line reads together instead of interleaved with unrelated files.
   - **PR-level comments** (not attached to a specific line) in their own section.
5. **Show per thread:** the author, the thread's current status (active/resolved/pending), the original comment, and any replies in order, indented under the comment they answer. A thread with an open question and an unanswered reply should read as an open question, not as flat text — keep the reply structure visible instead of concatenating a thread into one block.
6. **Surface unresolved threads first**, or mark them distinctly — these are the ones most likely to need action before merge. Close with a one-line count of unresolved vs. total threads so the reader knows how much is outstanding without recounting.

## Azure DevOps

**Prerequisites:** the same PAT/CLI auth as `pr-review` — a PAT with `Code (Read)` scope is sufficient for read-only comment fetching.

**Fetching threads:**
- REST: `GET https://dev.azure.com/<org>/<project>/_apis/git/repositories/<repo>/pullrequests/<id>/threads?api-version=7.1`. Each thread includes `comments[]` (author, content, `commentType`), `status` (active/fixed/closed/pending/wontFix), and, for inline threads, a `threadContext` with the file path and line range.
- Filter out threads where every comment has `commentType: "system"` — these are Azure DevOps's own auto-generated entries (e.g. "voted on this pull request"), not human commentary. A thread with a mix of `system` and `text` comments is a real discussion; keep it.
- Map the Azure DevOps `status` values onto the three display states in step 5: `active` and `pending` are unresolved, `fixed` and `closed` are resolved, `wontFix` is resolved but worth marking distinctly — it means the reviewer's point was acknowledged and declined, which reads differently from a fix.
- Web PR URLs have the form `https://dev.azure.com/<org>/<project>/_git/<repo>/pullrequest/<id>` — parse org, project, repo, and id straight out of it rather than asking the user to restate them.
- CLI: `az repos pr show --id <id>` doesn't return thread detail directly in most CLI versions — prefer the REST endpoint above for comment content.

## GitHub

**Prerequisites:** the `gh` CLI, authenticated (`gh auth login`), or a token with `repo` scope in `GH_TOKEN`/`GITHUB_TOKEN`. Run `/pr-setup` first if unsure whether either is in place.

**Fetching threads:**
- CLI: `gh api repos/<owner>/<repo>/pulls/<number>/comments` for inline review comments, `gh api repos/<owner>/<repo>/issues/<number>/comments` for PR-level (top-level) comments — GitHub splits these into two endpoints, unlike Azure DevOps's single threads list.
- REST equivalents: `GET /repos/<owner>/<repo>/pulls/<number>/comments` and `GET /repos/<owner>/<repo>/issues/<number>/comments`. Both paginate — follow `Link` headers, don't assume one page is everything.
- GitHub doesn't expose a `commentType: system` flag the way Azure DevOps does; filter out entries whose `user.type` is `Bot` instead.
- Inline comments carry `path` and `line` (or `original_line` if the diff has since changed) — group by these the same way as the Azure DevOps `threadContext`.
- Resolved/unresolved status for review threads isn't in the REST comments payload — fetching it requires the GraphQL API (`reviewThreads.isResolved`); if GraphQL access isn't set up, fall back to presenting all inline comments unmarked rather than guessing at resolution state.

## GitLab

**Prerequisites:** the `glab` CLI, authenticated (`glab auth login`), or a personal access token with `api` scope in `GITLAB_TOKEN`.

**Fetching threads:**
- CLI: `glab mr note --list <id>` or `glab api projects/<project_id>/merge_requests/<iid>/discussions`.
- REST: `GET https://<host>/api/v4/projects/<project_id>/merge_requests/<iid>/discussions`. Each discussion has a `notes[]` array; a discussion's `resolved` field (present when the discussion is resolvable) maps directly onto the resolved/unresolved split in step 5 — no separate lookup needed, unlike GitHub.
- Filter out notes where `system: true` — GitLab marks its own auto-generated entries (status changes, label additions) with this flag explicitly, which is cleaner than either Azure DevOps or GitHub.

## Other platforms

Same caveat as `pr-review`: Bitbucket and self-hosted trackers aren't wired up here. Adapt the GitHub/GitLab REST pattern if you need one, and treat the result as unverified until tested against a real PR.
