---
name: timesheet
description: >
  Generates daily timesheet entries from git history and file modification timestamps
  across one or more configured repos. Output matches timesheet comment format
  (Day, DD Mon • 8:00 hrs + paragraph). Trigger: /timesheet
trigger: /timesheet
---

# /timesheet

Generates timesheet entries by scanning git commits and file modification timestamps
across every repo listed in your config. Output is ready to paste into your timesheet tool.

**Config required before first use.** This skill reads repo paths, author names, and
display names from a config file — nothing about your repos or identity is hardcoded.
See [Config](#config) below.

## Usage

```
/timesheet                        # current week Mon → today
/timesheet last week              # Mon–Fri of previous week
/timesheet 2026-05-18 2026-05-22  # explicit start end (YYYY-MM-DD)
/timesheet 2026-05-22             # single day
```

---

## Config

Look for `.claude/timesheet.config.json` in the current working directory first, then
`~/.claude/timesheet.config.json`. If neither exists, stop and ask the user to create one,
showing them this template:

```json
{
  "repos": [
    {
      "name": "ProjectDisplayName",
      "path": "/absolute/path/to/repo",
      "authors": ["Git Author Name", "Alternate Author Name"]
    }
  ]
}
```

- `name` — how this repo is referred to in the generated paragraph.
- `path` — absolute path to the repo's working directory.
- `authors` — every git author string this person has committed under in that repo (handles
  cases where a corporate git config differs from a personal one, e.g. `"Jane Doe (ADM)"`).

Any number of repos may be listed. Every phase below runs once per configured repo, not
against a fixed count.

---

## Execution Protocol — follow every phase in order.

---

### Phase 1 — Parse Date Range

**1.1 Parse args from user message**

Supported forms:
- No args → current week: Monday of the current ISO week through today
- `last week` → Monday through Friday of the previous ISO week
- `YYYY-MM-DD YYYY-MM-DD` → explicit inclusive range
- `YYYY-MM-DD` → single day only

Compute `START_DATE` and `END_DATE` as `YYYY-MM-DD` strings.

```python
from datetime import date, timedelta
today = date.today()
monday = today - timedelta(days=today.weekday())
# current week default:
start = monday
end = today
```

**1.2 Build day list**

List every calendar day from `START_DATE` to `END_DATE` inclusive (skip nothing — include
weekends if they fall in range; the data will just be empty for those days and they are
omitted from output).

---

### Phase 2 — Collect Raw Data Per Day

For each day `D` in the day list, and for each repo `R` in the config's `repos` list, run
all of the following. Capture output.

**2.1 Git log for day D, repo R** (repeat per author string in `R.authors`)

```bash
git -C "R.path" log \
  --after="D 00:00:00" --before="D 23:59:59" \
  --author="AUTHOR" \
  --format="%h %s" \
  --no-merges
```

**2.2 Files modified or created on day D, repo R**

```bash
find "R.path" \
  -not -path '*/.git/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/venv/*' \
  -not -path '*/__pycache__/*' \
  -not -name '*.pyc' \
  -not -name '*.lock' \
  -type f \
  \( \( -newermt "D 00:00:00" ! -newermt "D+1 00:00:00" \) \
     -o \( -newerct "D 00:00:00" ! -newerct "D+1 00:00:00" \) \) \
  -printf "%TH:%TM %p\n" | sort -u
```

Where `D+1` is the next calendar day. The `-newermt` check catches writes; `-newerct` catches
file creation (ctime is set at creation and never reset by git operations).

**2.3 Untracked files with timestamp on day D, repo R**

These are files not yet added to git. `git ls-files --others` lists them; `stat` gives their
timestamps.

```bash
git -C "R.path" ls-files --others --exclude-standard \
  | while IFS= read -r f; do
      fp="R.path/$f"
      ts=$(stat -c "%y" "$fp" 2>/dev/null | cut -c1-10)
      [ "$ts" = "D" ] && echo "$fp"
    done | sort
```

Merge untracked results with Phase 2.2's find results — dedup by path. Use untracked-file
paths to supplement signal extraction in Phase 4.1.

**2.4 Merge commits for day D, repo R** (context only)

```bash
git -C "R.path" log \
  --after="D 00:00:00" --before="D 23:59:59" \
  --merges \
  --format="%h %s"
```

---

### Phase 3 — Filter Empty Days

Skip any day D where, across every configured repo, ALL of the following are true:
- Git log (Phase 2.1) = empty
- Modified/created files (Phase 2.2) = empty (or only `.claude/` settings files)
- Untracked files (Phase 2.3) = empty

Do not output skipped days at all.

---

### Phase 4 — Synthesize Each Day

For each non-empty day, synthesize one timesheet entry.

**4.1 Signal extraction**

From the raw data, extract the meaningful signals:

From git commits (all configured repos, no-merge):
- Feature work: `feat(...)` prefixes → what was added
- Bug fixes: `fix(...)` → what was fixed
- Refactors: `refactor(...)` → what was restructured
- Security/auth work → auth debugging, JWT, RBAC, etc.
- File patterns in modified files: presence of `load-tests/`, `docs/`, `scripts/`,
  `migration/` folders

From modified files (supplement or fill gaps when commit messages are sparse) — treat these
as generic signals and adapt to whatever directory structure the repo actually has:
- Test/load-test directories → performance / load testing
- Research or design-doc directories → research / investigation / planning
- Script/automation directories → scripting / automation
- Migration directories → data migration work
- Auth-related paths or filenames → auth work
- Caching-layer paths → caching
- Frontend feature/component directories → frontend feature or component work
- `.claude/settings` → tooling config (suppress from timesheet)

**4.2 Writing rules**

Write one fluent paragraph (3–6 sentences). Combine signals across all repos coherently.

Rules:
- Lead with the most significant work of the day
- Use past tense, professional tone
- Name the actual feature/area worked on (e.g., "lead status logic", "caching layer",
  "SITE_NAME field")
- Do NOT use bullet points — prose only
- Do NOT mention file names or line numbers
- Do NOT mention Claude, tooling, or `.claude/` settings activity
- Do NOT say "8 hours" or any hours estimate — that comes from the format line only
- Mention a repo only if it had activity that day; refer to each repo by its configured
  `name`, not its folder or path
- Merge commit messages are context only — don't say "merged PR #NNN" in the paragraph;
  describe the work itself

**4.3 Output format (match exactly)**

```
Day, DD Mon  •  8:00 hrs
[paragraph]
```

Example:
```
Mon, 18 May  •  8:00 hrs
Refactored lead status logic in LeadDetail to remove redundant auto-assignment of the "Assigned" status, simplifying the state machine. Worked on common form components (StyledDatePicker, StyledTextInput) to standardise input styling across the application. Merged the PR preserving Awarded fields with warning indicators on status change. Documented the custom domain go-live process and configuration steps.
```

Day format: `Mon` / `Tue` / `Wed` / `Thu` / `Fri` / `Sat` / `Sun`
Month format: `Jan` / `Feb` / `Mar` / `Apr` / `May` / `Jun` / `Jul` / `Aug` / `Sep` / `Oct` /
`Nov` / `Dec`

---

### Phase 5 — Display Output

Show all entries in order, separated by a blank line. No headers, no markdown, no code blocks
around the output — plain text only so it can be copy-pasted directly into the timesheet tool.

After showing entries, print one line:
```
[N days generated. Copy entries above into the timesheet comment field.]
```

---

### Phase 6 — Handle Follow-up

If user asks to **regenerate a specific day**: re-run Phase 2 for that day only and rewrite.
If user asks to **adjust the tone or length**: revise the paragraphs accordingly.
If user asks to **add missing work**: incorporate the user-provided context and re-emit that
day's entry.
If user asks to **change date range**: re-run from Phase 1.

---

## Error Recovery

| Situation | Action |
|---|---|
| No config file found | Stop and show the config template from [Config](#config); do not guess paths |
| Repo path in config not found | Note "Repo not found: [path]" and continue with the other configured repos |
| `git` command fails | Note failure inline, continue with file timestamps only |
| `find` command fails | Note failure inline, continue with git data only |
| All sources empty for a day | Skip that day silently |
| Date parse failure | Stop and ask user: "Could not parse date range from: [input]. Use YYYY-MM-DD YYYY-MM-DD." |
