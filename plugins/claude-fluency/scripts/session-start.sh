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
echo "[ENGINEERING PRINCIPLES — non-negotiable this session]"
echo "1. Clarify before building: state assumptions, ask once if ambiguous, never guess forward."
echo "2. Lean code: implement exactly what was asked, no speculative abstraction."
echo "3. Bounded edits: every changed line traces to the stated requirement."
echo "4. Outcome-oriented: define a verifiable end-state before starting non-trivial work."
echo "5. Verify before done: run the build/tests — an unverified fix is a hypothesis, not a fix."
echo "Full framework + failure modes (session memory decay, phantom APIs, pushback capitulation...): Skill 'engineering-principles'."
echo "[CLAUDE-FLUENCY] Commands: /git-commit /pr-description /review-diff /learn /security-scan /pr-setup /pr-watch-setup /pr-watch-disable /mom /create-pptx /adr /timesheet — see HOWTOUSE.md for examples."

REPO_SLUG="$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-')"
if [ -n "$REPO_SLUG" ] && [ ! -f "$HOME/.claude/claude-fluency/pr-watch/${REPO_SLUG}.env" ]; then
  echo "[CLAUDE-FLUENCY] No PR watch configured for this repo — run /pr-watch-setup to get notified of new PRs automatically."
fi
