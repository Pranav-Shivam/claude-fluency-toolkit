#!/usr/bin/env bash
# Helper for the /today-brief skill.
#   context.sh            build the run context and create today's folder
#   context.sh check DIR  verify the five files exist and follow the style rules
# Always exits 0 so a hiccup here never aborts the skill.

BASE="${TODAY_BRIEF_DIR:-$HOME/today-brief}"
MAX_BYTES=7000
mode="${1:-context}"

if [ "$mode" = "check" ]; then
  dir="${2:-$BASE/$(date +%F)}"
  echo "Checking: $dir"
  problems=0
  for n in 01 02 03 04 05; do
    f=$(ls -1 "$dir"/${n}-*.md 2>/dev/null | sort | tail -1)
    if [ -z "$f" ]; then
      echo "MISSING: section $n"; problems=1; continue
    fi
    size=$(wc -c < "$f")
    if [ "$size" -lt 500 ]; then
      echo "TOO SHORT ($size bytes): $(basename "$f")"; problems=1
    fi
    if ! head -1 "$f" | grep -q '^---$'; then
      echo "NO FRONTMATTER: $(basename "$f")"; problems=1
    fi
  done
  dashes=$(grep -n $'\xe2\x80\x94' "$dir"/*.md 2>/dev/null)
  if [ -n "$dashes" ]; then
    echo "EM-DASH FOUND (replace with comma, colon or period):"
    echo "$dashes" | head -20
    problems=1
  fi
  [ "$problems" -eq 0 ] && echo "OK"
  exit 0
fi

today=$(date +%F)
stamp=$(date +%H%M)
outdir="$BASE/$today"
mkdir -p "$outdir"

echo "- Today: $(date +%A), $today, local time $(date +%H:%M) $(date +%Z)"
echo "- Timestamp for file names: $stamp"
echo "- Output folder (already created): $outdir"

# Earlier run today?
today_files=$(ls -1 "$outdir"/*.md 2>/dev/null)
if [ -n "$today_files" ]; then
  echo "- A run already happened today. Existing files (do not repeat their topics):"
  echo "$today_files" | sed 's/^/    /'
  last05=$(ls -1 "$outdir"/05-*.md 2>/dev/null | sort | tail -1)
  if [ -n "$last05" ]; then
    echo; echo "### Earlier run today: handoff"
    sed -n '/^## Handoff/,$p' "$last05" | head -40
  fi
fi

# Previous runs (folders before today)
prev_dirs=$(ls -1 "$BASE" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' | awk -v t="$today" '$0 < t' | sort | tail -7)
prev=$(echo "$prev_dirs" | tail -1)

if [ -z "$prev" ]; then
  echo "- Previous run: none found. This is the first run."
  exit 0
fi

gap=$(( ( $(date -d "$today" +%s 2>/dev/null) - $(date -d "$prev" +%s 2>/dev/null) ) / 86400 )) 2>/dev/null
echo "- Previous run: $prev (${gap:-?} day(s) ago)"

echo; echo "## Previous run files ($prev), newest set only"
for n in 01 02 03 04 05; do
  f=$(ls -1 "$BASE/$prev"/${n}-*.md 2>/dev/null | sort | tail -1)
  [ -z "$f" ] && continue
  echo; echo "### $(basename "$f")"
  head -c "$MAX_BYTES" "$f"
  [ "$(wc -c < "$f")" -gt "$MAX_BYTES" ] && echo; [ "$(wc -c < "$f")" -gt "$MAX_BYTES" ] && echo "[truncated]"
done

older=$(echo "$prev_dirs" | grep -v "^$prev$")
if [ -n "$older" ]; then
  echo; echo "## Handoff blocks from earlier days (topics already covered, avoid repeating)"
  for d in $older; do
    f=$(ls -1 "$BASE/$d"/05-*.md 2>/dev/null | sort | tail -1)
    [ -z "$f" ] && continue
    echo; echo "### $d"
    sed -n '/^## Handoff/,$p' "$f" | head -30
  done
fi
exit 0
