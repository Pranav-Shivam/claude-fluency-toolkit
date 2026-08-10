#!/usr/bin/env bash
# PreToolUse safety gate for Bash tool calls.
# Reads the hook JSON payload from stdin, inspects tool_input.command, and
# blocks (exit 2) on a set of high-risk shell patterns. Anything else passes
# through untouched (exit 0).
set -euo pipefail

INPUT="$(cat)"

if command -v jq >/dev/null 2>&1; then
  CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')"
else
  # jq missing: fall back to a best-effort extraction so the hook still runs.
  CMD="$(printf '%s' "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n1 | sed -E 's/.*"command"[[:space:]]*:[[:space:]]*"(.*)"/\1/')"
fi

[ -z "$CMD" ] && exit 0

block() {
  echo "BLOCKED by pre-tool-safety hook: $1" >&2
  exit 2
}

# rm -rf outside an obvious temp/build path
if echo "$CMD" | grep -Eq '\brm\s+(-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*|-[a-zA-Z]*f[a-zA-Z]*r[a-zA-Z]*)\b'; then
  if ! echo "$CMD" | grep -Eq '(/tmp|/var/tmp|node_modules|dist|build|\.cache|__pycache__|\.next|\.venv|venv)(/|["'"'"']|\s|$)'; then
    block "rm -rf outside an obvious temp/build path — confirm target manually"
  fi
fi

# git push --force / --force-with-lease without an explicit confirmation flag
if echo "$CMD" | grep -Eq '\bgit\s+push\b.*(--force\b|--force-with-lease\b|-f\b)'; then
  if ! echo "$CMD" | grep -q -- '--yes-i-mean-it'; then
    block "force push requires explicit --yes-i-mean-it confirmation flag"
  fi
fi

# DROP TABLE / DROP DATABASE
if echo "$CMD" | grep -Eiq '\bdrop\s+(table|database|schema)\b'; then
  block "destructive SQL DROP statement"
fi

# git reset --hard
if echo "$CMD" | grep -Eq '\bgit\s+reset\b.*--hard\b'; then
  block "git reset --hard discards uncommitted work"
fi

# redirect that truncates/overwrites a .env file
if echo "$CMD" | grep -Eq '>\s*[^>]*\.env([^A-Za-z0-9._-]|$)'; then
  block "redirect would overwrite a .env file"
fi

exit 0
