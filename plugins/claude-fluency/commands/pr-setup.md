---
description: Detect which Git host this repo uses (GitHub, GitLab, Azure DevOps, or unsupported) and check whether the credentials pr-review/pr-comments need are already in place.
---

No args. Run this once per repo before using `/pr-review`, `pr-comments`, or asking Claude to review/fetch a PR — it tells you exactly what's missing instead of letting those skills fail partway through a real PR.

## 1. Detect the platform

Run `git remote -v` (or ask for the remote URL if there's no git repo / no remote configured — do not guess). Match the remote host:

| Remote host contains | Platform |
|---|---|
| `github.com` (or a GitHub Enterprise host if the user names one) | GitHub |
| `gitlab.com` (or a self-hosted GitLab host) | GitLab |
| `dev.azure.com` or `visualstudio.com` | Azure DevOps |
| anything else (`bitbucket.org`, self-hosted Gitea/Gerrit, etc.) | Unsupported — see step 4 |

If there are multiple remotes, ask which one is the PR remote rather than assuming `origin`.

## 2. Check for existing credentials

Run the check for the detected platform only — don't run all three.

**GitHub:**
```bash
gh auth status
```
If `gh` isn't installed, or the above fails, check for `GH_TOKEN`/`GITHUB_TOKEN` in the environment instead of failing outright — either is sufficient.

**GitLab:**
```bash
glab auth status
```
Same fallback: check for `GITLAB_TOKEN` in the environment if `glab` isn't installed or isn't authenticated.

**Azure DevOps:**
```bash
az account show
az devops configure -l
```
The second command lists configured defaults (`organization`, `project`) — if it's empty, auth may exist but the org/project defaults don't, which will make every PR reference need to be fully qualified.

## 3. Report clearly

State the detected platform, then one of:

- **Ready** — credentials found. Name what was found (e.g. "gh CLI authenticated as \<user\>") and that `/pr-review`/`pr-comments` should work against this repo.
- **Not ready** — nothing found. Give the exact command to run, not a general pointer:
  - GitHub: `gh auth login` (interactive), or set `GH_TOKEN` to a token with `repo` scope.
  - GitLab: `glab auth login`, or set `GITLAB_TOKEN` to a token with `api` scope.
  - Azure DevOps: a PAT with `Code (Read & Write)` scope, then `az devops configure --defaults organization=<org> project=<project>`, or set the PAT via `az devops login`.

Never fabricate a "found" result — if a command errors or its output is ambiguous, report it as not-ready and show the actual error, not a guess.

## 4. Unsupported platform

If the remote doesn't match GitHub, GitLab, or Azure DevOps: say plainly that `pr-review`/`pr-comments` have no tested recipe for this platform yet (see the "Other platforms" section in either skill file). Offer to adapt the GitHub/GitLab REST pattern on the spot if the user wants to proceed anyway, but label the result unverified.
