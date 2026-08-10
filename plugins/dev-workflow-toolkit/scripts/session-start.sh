#!/usr/bin/env bash
# SessionStart hook: print a quick orientation snapshot of the repo.
set -uo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[SESSION START] Not inside a git repository."
  exit 0
fi

BRANCH="$(git branch --show-current 2>/dev/null || echo "detached HEAD")"
UNCOMMITTED="$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
LAST_COMMIT="$(git log -1 --pretty=format:'%h %s' 2>/dev/null || echo "no commits yet")"
STASH_COUNT="$(git stash list 2>/dev/null | wc -l | tr -d ' ')"

echo "[SESSION START]"
echo "Branch: $BRANCH"
echo "Uncommitted changes: $UNCOMMITTED files"
echo "Last commit: $LAST_COMMIT"
echo "Stashed: $STASH_COUNT entries"
