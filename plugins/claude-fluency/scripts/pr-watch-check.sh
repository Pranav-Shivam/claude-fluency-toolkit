#!/usr/bin/env bash
# Checks one Azure DevOps repo for new active PRs, notifies, and offers /pr-review.
# Invoked by cron (Linux/macOS) with the path to a config file written by /pr-watch-setup.
# Never run directly with untrusted config paths — it sources the file as shell.
set -uo pipefail

CONFIG_FILE="${1:?usage: pr-watch-check.sh <config-file>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "[pr-watch] config file not found: $CONFIG_FILE" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$CONFIG_FILE"

: "${ORG:?ORG missing in config}"
: "${PROJECT:?PROJECT missing in config}"
: "${REPOSITORY:?REPOSITORY missing in config}"
: "${STATE_FILE:?STATE_FILE missing in config}"
: "${REPO_ROOT:?REPO_ROOT missing in config}"

# cron has no desktop session env on Linux — wire up whatever X session is running for this user
if [ "$(uname -s)" = "Linux" ]; then
  export DISPLAY="${DISPLAY:-:0}"
  export XAUTHORITY="${XAUTHORITY:-$(find "/run/user/$(id -u)" -maxdepth 1 -iname '*auth*' 2>/dev/null | head -1)}"
  export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
fi

mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"

if [ -n "${PAT:-}" ]; then
  export AZURE_DEVOPS_EXT_PAT="$PAT"
fi

PR_JSON="$(az repos pr list \
  --org "$ORG" --project "$PROJECT" --repository "$REPOSITORY" \
  --status active \
  --query "[].{id:pullRequestId,title:title}" \
  -o json 2>/dev/null || echo "[]")"

ACTIVE_IDS="$(echo "$PR_JSON" | python3 -c "import json,sys; print('\n'.join(str(p['id']) for p in json.load(sys.stdin)))" 2>/dev/null || true)"
[ -z "$ACTIVE_IDS" ] && exit 0

NEW_LINES=""
while IFS= read -r id; do
  [ -z "$id" ] && continue
  if ! grep -qx "$id" "$STATE_FILE"; then
    TITLE="$(echo "$PR_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(next((p['title'] for p in d if str(p['id'])=='$id'), ''))" 2>/dev/null)"
    URL="${ORG%/}/${PROJECT}/_git/${REPOSITORY}/pullrequest/${id}"
    NEW_LINES="${NEW_LINES}PR #${id}: ${TITLE}\n  ${URL}\n"
  fi
done <<< "$ACTIVE_IDS"
[ -z "$NEW_LINES" ] && exit 0

echo "$ACTIVE_IDS" > "$STATE_FILE"
COUNT="$(printf '%b' "$NEW_LINES" | grep -c "^PR #" || true)"

"${SCRIPT_DIR}/notify.sh" "${COUNT} new PR(s) on ${REPOSITORY} — opening terminal for review"

PROMPT="$(printf '%s new PR(s) opened on %s (org %s, project %s):\n\n%bAsk me which PR number(s) to review, or all, or skip. For each I approve, run /pr-review <pr_url> <PAT>, reading PAT from the PAT= line in %s — never print the PAT.' \
  "$COUNT" "$REPOSITORY" "$ORG" "$PROJECT" "$NEW_LINES" "$CONFIG_FILE")"

LAUNCHER="$(mktemp /tmp/pr-watch-launcher.XXXXXX.sh)"
cat > "$LAUNCHER" <<EOF
#!/usr/bin/env bash
[ -f "\$HOME/.bashrc" ] && source "\$HOME/.bashrc" 2>/dev/null || true
export PATH="\$HOME/.local/bin:\$PATH"
cd "${REPO_ROOT}"
CLAUDE_BIN="\$(command -v claude 2>/dev/null || echo claude)"
"\${CLAUDE_BIN}" "$(printf '%s' "$PROMPT" | sed 's/"/\\"/g')"
exec bash
EOF
chmod +x "$LAUNCHER"

case "$(uname -s)" in
  Darwin)
    if osascript -e 'tell application "iTerm2" to version' &>/dev/null 2>&1; then
      osascript -e "tell application \"iTerm2\" to create window with default profile command \"bash '${LAUNCHER}'\"" 2>/dev/null
    else
      osascript -e "tell application \"Terminal\" to do script \"bash '${LAUNCHER}'\"" -e 'tell application "Terminal" to activate' 2>/dev/null
    fi
    ;;
  Linux)
    if command -v gnome-terminal &>/dev/null; then
      gnome-terminal -- bash -c "bash '${LAUNCHER}'; exec bash" &
    elif command -v x-terminal-emulator &>/dev/null; then
      x-terminal-emulator -e bash "${LAUNCHER}" &
    elif command -v xterm &>/dev/null; then
      xterm -e bash "${LAUNCHER}" &
    else
      echo "[pr-watch] No GUI terminal found — run manually: bash ${LAUNCHER}" >&2
    fi
    ;;
  *)
    echo "[pr-watch] Unrecognized OS — run manually: bash ${LAUNCHER}" >&2
    ;;
esac
