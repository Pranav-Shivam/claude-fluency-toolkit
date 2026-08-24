---
description: Remove the scheduled PR-watch check installed by /pr-watch-setup for this repo.
---

No args. Undoes `/pr-watch-setup` for the current repo.

## 1. Find the config

Repo slug from `git rev-parse --show-toplevel` + repo name, same rule `/pr-watch-setup` used (lowercase, non-alphanumeric → `-`).

Check for:
- Linux/macOS: `~/.claude/claude-fluency/pr-watch/<repo-slug>.env`
- Windows: `$env:USERPROFILE\.claude\claude-fluency\pr-watch\<repo-slug>.env`

If it doesn't exist, list whatever configs *do* exist in that directory and ask which one, or report nothing is set up for this repo.

## 2. Remove the scheduler entry

**Linux/macOS**:

```bash
crontab -l 2>/dev/null | grep -vF "<config_path>" | crontab -
```

**Windows**:

```powershell
schtasks /delete /tn "ClaudePRWatch-<repo-slug>" /f
```

Confirm the entry is actually gone (`crontab -l` / `schtasks /query /tn ...`) rather than assuming the command succeeded.

## 3. Offer to delete the config and state file

Ask before deleting — the config may contain a PAT the user wants to keep for something else. If they confirm, remove both the `.env` and its `.seen` state file. Otherwise leave them and just report they're now orphaned but harmless (nothing schedules against them anymore).

## 4. Report

State what was removed (scheduler entry, config, state file) and confirm no further checks will run for this repo.
