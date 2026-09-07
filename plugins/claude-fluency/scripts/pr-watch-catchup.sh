#!/usr/bin/env bash
# SessionStart hook: catch up any pr-watch check missed because the machine was
# asleep/off at its scheduled cron/Task Scheduler time. Runs once per Claude Code
# session start, cross-platform (bash under git-bash on Windows too).
#
# Staleness = time since STATE_FILE was last touched (pr-watch-check.sh touches
# it on every run, hit or miss) vs. that repo's INTERVAL_HOURS. Self-limiting:
# once a catch-up run fires, STATE_FILE's mtime resets, so it won't re-fire
# again until another full interval has actually passed.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WATCH_DIR="$HOME/.claude/claude-fluency/pr-watch"
[ -d "$WATCH_DIR" ] || exit 0

now="$(date +%s)"

for config in "$WATCH_DIR"/*.env; do
  [ -f "$config" ] || continue
  (
    # shellcheck disable=SC1090
    source "$config"
    : "${STATE_FILE:?}"
    interval_hours="${INTERVAL_HOURS:-4}"
    if [ -f "$STATE_FILE" ]; then
      last="$(stat -c %Y "$STATE_FILE" 2>/dev/null || stat -f %m "$STATE_FILE" 2>/dev/null || echo 0)"
    else
      last=0
    fi
    age=$(( now - last ))
    threshold=$(( interval_hours * 3600 ))
    if [ "$age" -ge "$threshold" ]; then
      nohup "${SCRIPT_DIR}/pr-watch-check.sh" "$config" >> "${config%.env}.log" 2>&1 &
    fi
  )
done
exit 0
