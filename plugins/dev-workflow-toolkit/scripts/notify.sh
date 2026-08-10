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
    elif command -v powershell.exe >/dev/null 2>&1; then
      # WSL without notify-send: bounce through Windows via powershell.exe.
      powershell.exe -c "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('$MSG')" 2>/dev/null || echo "$MSG"
    else
      echo "$MSG"
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    powershell.exe -c "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('$MSG')" 2>/dev/null || echo "$MSG"
    ;;
  *)
    echo "$MSG"
    ;;
esac
