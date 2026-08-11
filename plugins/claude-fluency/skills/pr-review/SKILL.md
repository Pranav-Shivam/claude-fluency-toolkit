---
name: pr-review
description: End-to-end pull-request review. Produces a layered walkthrough, a PR health score, and severity-graded findings with agent-ready fix prompts. Shows everything in chat first — nothing posts to the PR until you confirm.
---

# PR Review

Reviews a pull request end to end and presents the result in chat before touching the PR itself. Nothing is posted — no comments, no status update — until you explicitly confirm you want it posted.

## Workflow

1. **Fetch the PR.** Get the diff, the file list, the PR description, and existing comment threads (pairs well with a comment-fetching skill if one is configured).
2. **Layered walkthrough.** Don't review file-by-file in diff order — group the changes into logical layers (e.g. "data model changes," "API surface," "UI," "tests") and walk through each layer in the order a reviewer would actually want to understand it: what changed structurally first, then the details.
3. **PR health score.** Produce a short scorecard covering: test coverage of the change (are new/changed code paths covered by new or existing tests?), scope discipline (does the diff match what the PR description claims, or has scope crept?), and risk (blast radius if this change is wrong — how many callers/consumers does the changed code have?).
4. **Severity-graded findings.** List concrete findings — bugs, missed edge cases, style/convention deviations, security concerns — each graded (critical/high/medium/low) and each paired with a short, self-contained "fix prompt": a paragraph specific enough that an agent (or the PR author) could act on it directly without needing to re-read the whole review.
5. **Present in chat, wait for confirmation.** Show the full walkthrough, score, and findings in the conversation. Do not post anything to the PR platform until you're told to. If asked to post, post only what was shown and confirmed — don't regenerate a different version at post time.
6. **Optional diagrams.** For PRs with non-trivial structural change (new component relationships, a changed data flow), a small Mermaid diagram alongside the walkthrough can clarify the shape of the change faster than prose. Include one only when it earns its place — not on every PR.

## Azure DevOps

The steps above are platform-agnostic. This section covers the Azure DevOps-specific plumbing to actually fetch and post.

**Prerequisites:** an Azure DevOps Personal Access Token (PAT) with `Code (Read & Write)` scope, or the `az devops` CLI authenticated (`az login` + `az devops configure --defaults organization=<your-org> project=<your-project>`). Neither is included with this plugin — set one of these up yourself before using this skill against a real PR.

**Fetching a PR:**
- REST: `GET https://dev.azure.com/<org>/<project>/_apis/git/repositories/<repo>/pullrequests/<id>?api-version=7.1` for metadata, and the `/iterations/<iterationId>/changes` and `/threads` endpoints for the diff and existing comments.
- CLI: `az repos pr show --id <id>` and `az repos pr diff` (if available in your CLI version) as a lighter-weight alternative to raw REST calls.

**Posting a status or comment (only after confirmation):**
- REST: `POST` to `.../pullrequests/<id>/threads?api-version=7.1` for a new comment thread, or `PATCH .../pullrequests/<id>?api-version=7.1` to update PR status/labels.
- Always confirm the target `repositoryId` and `pullRequestId` resolved correctly before posting — posting to the wrong PR because of a mis-parsed URL is a much worse failure than not posting at all.
