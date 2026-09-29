#!/usr/bin/env bash
# SessionStart hook: install/refresh the /today-brief skill into ~/.claude/skills/
# using the variant for this OS (unix = Linux/macOS, windows = Git Bash on Windows).
# Silent unless it installs or updates. Never overwrites a skill the user made themselves.
set -uo pipefail

ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*) VARIANT=windows ;;
  *) VARIANT=unix ;;
esac

SRC="$ROOT/daily-brief/$VARIANT/today-brief"
DEST="$HOME/.claude/skills/today-brief"
MARKER="$DEST/.installed-by-claude-fluency"

[ -d "$SRC" ] || exit 0
if [ -d "$DEST" ] && [ ! -f "$MARKER" ]; then
  exit 0  # user-owned skill of the same name
fi
if [ -f "$MARKER" ] && diff -rq --exclude=.installed-by-claude-fluency "$SRC" "$DEST" >/dev/null 2>&1; then
  exit 0  # already current
fi

mkdir -p "$HOME/.claude/skills" || exit 0
rm -rf "$DEST"
cp -r "$SRC" "$DEST" || exit 0
[ -f "$DEST/scripts/context.sh" ] && chmod +x "$DEST/scripts/context.sh"
echo "$VARIANT" > "$MARKER"

echo "[CLAUDE-FLUENCY] Installed /today-brief ($VARIANT) to $DEST — restart Claude Code to use it."
if [ "$VARIANT" = windows ]; then
  echo "[CLAUDE-FLUENCY] If /today-brief says PowerShell is unavailable, set env CLAUDE_CODE_USE_POWERSHELL_TOOL=1 in ~/.claude/settings.json."
fi
