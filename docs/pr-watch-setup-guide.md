# pr-watch-setup — generic walkthrough

`/pr-watch-setup` runs interactively. It asks a fixed sequence of questions, then
writes a per-repo config and installs a scheduler entry. Nothing is baked into
the plugin — everything lands in `~/.claude/claude-fluency/pr-watch/<repo-slug>.env`
on the machine it was run on.

Azure DevOps only. If `git remote -v` doesn't show `dev.azure.com` or
`visualstudio.com`, the command stops.

## Step-by-step with dummy values

### 1. Repo detection

Command runs `git remote -v` and `git rev-parse --show-toplevel`, then parses:

| Field | Example (dummy) | Notes |
|---|---|---|
| `ORG` | `https://dev.azure.com/your-org` | parsed from remote URL |
| `PROJECT` | `Your Project Name` | usually NOT parseable from URL — comes from `az devops configure -l` defaults, or asked directly |
| `REPOSITORY` | `your-repo` | parsed from remote URL |
| `REPO_ROOT` | `/home/<user>/path/to/your-repo` | from `git rev-parse --show-toplevel` |

You'll be asked to confirm these before continuing — say yes, or correct them.

### 2. Auth check

Command runs:

```bash
az account show
az devops configure -l
az repos pr list --org "<ORG>" --project "<PROJECT>" --repository "<REPOSITORY>" --status active -o none
```

- If all three succeed → auth already works, **no PAT is asked for**, `PAT=` is left blank in the config, and the scheduled check reuses your existing `az devops` login.
- If any fail (401/403, or you've never run `az devops login`) → you'll be prompted for a PAT:
  - Scope needed: **Code (Read & Write)**
  - Generate at: `https://dev.azure.com/<org>/_usersSettings/tokens`
  - Dummy value when asked: paste the real PAT string, e.g. `abcd1234...` (never share this one — it's a secret, treat it like a password)

### 3. Scheduling questions

You'll get two questions:

**Q: How often check for new PRs?**
- "Every morning" → pick a local time, e.g. dummy answer `8:00 AM`
- "Every N hours" → pick N and optionally a window, e.g. dummy answer `every 4 hours, 8am-8pm`

**Q: Which days?**
- "Every day" or "Weekdays only" — dummy answer: `Weekdays only`

Example real answer given previously: *"from 8AM, every 4 hours: 8, 12, 4, 8, 12, 4, 8 so on"* → resolves to cron `0 */4 * * 1-5` (fires at 00:00, 04:00, 08:00, 12:00, 16:00, 20:00, Mon–Fri).

You'll then be asked to confirm the final cron expression and told: **if the machine is asleep/off at a fire time, that run is skipped — but a SessionStart hook (`pr-watch-catchup.sh`) checks staleness on every Claude Code session start and runs a catch-up check in the background if an interval was missed.**

The interval you pick is also recorded as `INTERVAL_HOURS` in the config (e.g. `4`, or `24` for "every morning") — that's what the catch-up hook compares elapsed time against.

### 4. OS + plugin path resolution

Command runs:

```bash
uname -s
echo "$CLAUDE_PLUGIN_ROOT"
```

`CLAUDE_PLUGIN_ROOT` is only set inside a live Claude session — cron/Task Scheduler
run outside one, so the command resolves it to a real absolute path and bakes
that literal path into the scheduler entry. Dummy value seen in practice:

```
/home/<user>/.claude/plugins/cache/claude-fluency-toolkit/claude-fluency/<version>
```

(there can be multiple copies on disk — marketplace cache, plugin data dir,
your own toolkit source checkout; the **cache** path matching your currently
installed plugin version is the one that gets used at cron-fire time.)

### 5. Config file written

Repo slug = lowercase `REPOSITORY`, non-alphanumeric chars → `-`.
Dummy example: `your-repo` → `your-repo`.

Path: `~/.claude/claude-fluency/pr-watch/<repo-slug>.env`, `chmod 600`.

Dummy file content:

```bash
ORG="https://dev.azure.com/your-org"
PROJECT="Your Project Name"
REPOSITORY="your-repo"
REPO_ROOT="/home/<user>/path/to/your-repo"
STATE_FILE="/home/<user>/.claude/claude-fluency/pr-watch/your-repo.seen"
PAT=""
INTERVAL_HOURS="4"
```

Every value is double-quoted, even ones that look safe — a project name with a
space (like `Your Project Name`) breaks unquoted `source`.

### 6. Scheduler entry installed

**Linux/macOS** — appended to crontab, replacing any prior line for the same
config path (so re-running setup updates instead of duplicating):

```bash
0 */4 * * 1-5 /usr/bin/env bash "<plugin_root>/scripts/pr-watch-check.sh" "<config_path>" >> "<config_dir>/<repo-slug>.log" 2>&1
```

Verified afterward with `systemctl is-active cron` (Linux) — should print `active`.

**Windows** — Task Scheduler task named `ClaudePRWatch-<repo-slug>`:

```powershell
schtasks /create /f /tn "ClaudePRWatch-your-repo" /tr "powershell -ExecutionPolicy Bypass -File \"<plugin_root>\scripts\pr-watch-check.ps1\" -ConfigFile \"<config_path>\"" /sc hourly /mo 4
```

### 7. Confirm + one-shot test

Command runs the check script once, by hand, right away:

```bash
bash "<plugin_root>/scripts/pr-watch-check.sh" "<config_path>"
```

Exit code `0` with no errors = setup good. Reported back to you: config path,
scheduler entry installed, and that `/pr-watch-disable` removes it later.

## What happens after setup (no action needed)

- Scheduler fires on the cron/task schedule
- Script diffs live active PRs against `STATE_FILE` (`<repo-slug>.seen`)
- New PR found → desktop notification + opens an interactive terminal offering
  `/pr-review` for whichever PRs you approve
- Everything logged to `<repo-slug>.log` next to the config
- **Catch-up:** every Claude Code session start runs `pr-watch-catchup.sh`
  (a plugin SessionStart hook). It checks each configured repo's `STATE_FILE`
  mtime against `INTERVAL_HOURS`; if a scheduled check was missed (machine
  asleep/off at fire time), it runs `pr-watch-check.sh` for that repo
  immediately, in the background. Self-limiting — running it resets the
  mtime, so it won't fire again until another full interval has passed.

## Undo

Run `/pr-watch-disable` — removes the scheduler entry for the repo, and
optionally the config file too.
