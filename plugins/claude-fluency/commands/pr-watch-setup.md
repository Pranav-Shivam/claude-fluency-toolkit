---
description: Set up an automatic daily/interval check for new active PRs on this Azure DevOps repo, with a desktop notification and an interactive prompt to run /pr-review.
---

No args. Run this once per repo you want watched. It never bakes credentials or paths into the plugin — everything gets written to a local, per-repo config file on this machine only.

Azure DevOps only for now (matches `pr-review`/`pr-comments`' tested coverage). If this repo's remote isn't Azure DevOps, say so and stop.

## 1. Detect the repo

```bash
git remote -v
```

Confirm the remote host contains `dev.azure.com` or `visualstudio.com`. If not, stop and tell the user this command only supports Azure DevOps right now — offer to run `/pr-setup` to check what's detected instead.

Parse `ORG` (organization) and `REPOSITORY` (repo name) from the remote URL if possible. `PROJECT` usually can't be parsed reliably from the URL — get it from `az devops configure -l` (the `project` default) or ask.

Get `REPO_ROOT` from `git rev-parse --show-toplevel`.

Confirm all four values with the user before proceeding — don't silently guess a wrong project.

## 2. Check for existing Azure DevOps auth

```bash
az account show
az devops configure -l
```

If both succeed and `organization`/`project` defaults are set, try a real call:

```bash
az repos pr list --org "<ORG>" --project "<PROJECT>" --repository "<REPOSITORY>" --status active -o none
```

If that succeeds, auth is already in place — **skip asking for a PAT**, leave `PAT=` blank in the config, and rely on the existing `az devops` login at check time.

If it fails (401/403, or `az devops login` never run), ask the user for a PAT:

> Need an Azure DevOps PAT with `Code (Read & Write)` scope. Generate one at `https://dev.azure.com/<org>/_usersSettings/tokens`, paste it here.

Never echo the PAT back, never print it in any tool output after this point.

## 3. Ask scheduling preference

Ask (AskUserQuestion or plain question) two things:
- How often to check: options like "every morning" (once daily, ask what local time) or "every N hours" (ask N, and optionally which hours to restrict to, e.g. 6am-9pm) — weekdays only or every day.
- Tell the user: if the machine is asleep/off at a scheduled time, that run is skipped — but a SessionStart hook (`pr-watch-catchup.sh`) checks staleness on every Claude Code session start and fires a catch-up check in the background if an interval was missed.

Record the numeric interval in hours as `INTERVAL_HOURS` (e.g. "every 4 hours" → `4`; "every morning"/once daily → `24`) — the catch-up hook needs this to know what counts as overdue.

Convert whatever they choose into:
- **Linux/macOS**: a 5-field cron expression, local time (crontab uses local time already, no UTC conversion needed).
- **Windows**: an interval in hours for `schtasks /sc hourly /mo <N>`, or a daily time for `/sc daily /st <HH:mm>`.

## 4. Detect OS and resolve the plugin's real script path

```bash
uname -s 2>/dev/null || echo Windows
echo "$CLAUDE_PLUGIN_ROOT"
```

`CLAUDE_PLUGIN_ROOT` is only set inside this Claude session — resolve it to a concrete absolute path now and bake that literal path into whatever scheduler entry you write (cron/Task Scheduler run outside any Claude session and won't have that variable).

## 5. Write the config file

Repo slug: lowercase, non-alphanumeric → `-`, from `REPOSITORY` (e.g. `My-Repo` → `my-repo`).

Config path (create parent dirs as needed):
- Linux/macOS: `~/.claude/claude-fluency/pr-watch/<repo-slug>.env`
- Windows: `$env:USERPROFILE\.claude\claude-fluency\pr-watch\<repo-slug>.env`

Content — this file gets `source`d as shell, so **always double-quote every value**, even ones that look safe today (a project name with a space in it will break unquoted `source`):

```
ORG="<org url, e.g. https://dev.azure.com/your-org>"
PROJECT="<project name>"
REPOSITORY="<repo name>"
REPO_ROOT="<absolute path to this repo on this machine>"
STATE_FILE="<same dir as config, filename <repo-slug>.seen>"
PAT="<pat, or leave blank if az devops auth already works>"
INTERVAL_HOURS="<numeric hours between checks, e.g. 4 or 24>"
```

`chmod 600` the file on Linux/macOS (owner-only, it may contain a PAT).

## 6. Install the scheduler entry

**Linux/macOS** — append to crontab, replacing any prior line for this same repo-slug (match on the config path in the line so re-running setup updates cleanly instead of duplicating):

```bash
CRON_LINE="<cron_expr> /usr/bin/env bash \"<resolved_plugin_root>/scripts/pr-watch-check.sh\" \"<config_path>\" >> \"<config_dir>/<repo-slug>.log\" 2>&1"
( crontab -l 2>/dev/null | grep -vF "<config_path>" ; echo "$CRON_LINE" ) | crontab -
```

Verify the daemon is actually running (`systemctl is-active cron` on Linux; `launchd` is always running on macOS, no check needed) and warn the user if it isn't.

**Windows** — create/replace a Task Scheduler task named `ClaudePRWatch-<repo-slug>`:

```powershell
schtasks /create /f /tn "ClaudePRWatch-<repo-slug>" /tr "powershell -ExecutionPolicy Bypass -File \"<resolved_plugin_root>\scripts\pr-watch-check.ps1\" -ConfigFile \"<config_path>\"" /sc <hourly|daily> /mo <N> /st <HH:mm>
```

Adjust `/sc`/`/mo`/`/st` based on what the user picked in step 3. `/f` overwrites a same-named task so re-running setup updates cleanly.

## 7. Confirm and test

Run the check script once by hand right now (with the just-written config path) so the user sees it work immediately rather than waiting until the next scheduled fire:

```bash
bash "<resolved_plugin_root>/scripts/pr-watch-check.sh" "<config_path>"
```

(or the `.ps1` equivalent on Windows). Report: config path, scheduler entry installed, that missed checks auto-catch-up on the next Claude Code session start, and that `/pr-watch-disable` removes it later.
