#!/usr/bin/env bash
# Cross-platform desktop notification. Detects the OS and dispatches to the
# right mechanism instead of assuming one platform's tool is present.
set -uo pipefail

MSG="${1:-Claude Code notification}"

case "$(uname -s)" in
  Darwin)
    osascript -e "display notification \"$MSG\" with title \"Claude Code\"" 2>/dev/null || echo "$MSG"
    ;;
  Linux)
    if command -v notify-send >/dev/null 2>&1; then
      notify-send "Claude Code" "$MSG"
    else
      echo "$MSG"
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    echo "$MSG"
    ;;
  *)
    echo "$MSG"
    ;;
esac
