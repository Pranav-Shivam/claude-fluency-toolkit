# Gotchas

## 2026-08-26

- When debugging a plugin script error, check the mtime of the failing artifact against the fix commit + cache update time before assuming the bug is still live — the installed copy lives at `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`, separate from the repo, and `pr-watch-check.sh`'s launcher is written fresh to `/tmp/pr-watch-launcher.*.sh` on every cron run, so a stale leftover file in `/tmp` from before a fix can look like an ongoing failure when it's actually just the last bad run's output sitting there.
