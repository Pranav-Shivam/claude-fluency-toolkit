# `/timesheet` — no install needed (manual-input version)

**Read this part first — it's a real limitation, not a formality.** The real `/timesheet` command scans your actual git commit history and file-modification timestamps across your repos automatically — it needs a terminal with `git` and file access to do that, so it genuinely can't run inside the plain claude.ai chat. There's no way around that gap for the automatic part.

What *can* work with no install: you tell it what you worked on each day, in your own words, and it writes it up in the exact same polished format the real command produces — same rules (no bullet points, past tense, no hour estimates in the paragraph, no file names or Claude/tooling mentions). You're doing the "scan git log" step yourself, by remembering, instead of Claude doing it automatically.

## How to use it (pick one)

**Option A — Claude Project (best if you fill this in daily/weekly):**
1. Go to [claude.ai](https://claude.ai) → **Projects** → **Create project**.
2. Open **Set custom instructions**, paste the box below, save.
3. Each time, open a new chat in that project and just tell it what you worked on.

**Option B — One-off, any chat:**
1. Start a new chat, paste the box below as your first message.
2. Underneath it, tell it what you did — see the "What to tell it" section for the fastest way to do this.

## A shortcut that gets you closer to the real thing

If you use a graphical git tool (GitHub Desktop, GitKraken, the Source Control tab in VS Code, Sourcetree) rather than a terminal, you likely already see a list of your commit messages with dates, with zero command-line typing required. Copy that list and paste it in along with what you tell it — the more of your actual commit messages you can hand over, the closer the write-up gets to what the automatic version would produce.

---

## Copy everything below this line

```
I want you to write my daily timesheet entries. I'll tell you, in my own
words, what I worked on for one or more days — plain description, or
pasted commit messages/notes if I have them, doesn't need to be organized.
Turn that into polished timesheet entries, one per day, in this exact
format:

Day, DD Mon  •  8:00 hrs
[one paragraph, 3-6 sentences]

Day format: Mon/Tue/Wed/Thu/Fri/Sat/Sun. Month format: Jan/Feb/Mar/Apr/May/
Jun/Jul/Aug/Sep/Oct/Nov/Dec.

Example of the target style:
Mon, 18 May  •  8:00 hrs
Refactored lead status logic in LeadDetail to remove redundant
auto-assignment of the "Assigned" status, simplifying the state machine.
Worked on common form components to standardise input styling across the
application. Merged the PR preserving Awarded fields with warning
indicators on status change. Documented the custom domain go-live process
and configuration steps.

## Writing rules
- Lead with the most significant work of that day.
- Past tense, professional tone.
- Name the actual feature/area worked on (e.g. "lead status logic",
  "caching layer") — pull real names from what I tell you, don't invent
  generic-sounding ones.
- Prose only — no bullet points, no headers.
- Don't mention specific file names or line numbers.
- Don't mention Claude, AI tools, or any tooling/config work — that's not
  billable client-facing work.
- Don't restate "8 hours" or any hour estimate inside the paragraph itself
  — that only ever appears in the header line, always as 8:00 hrs regardless
  of what I actually worked, unless I tell you a different number.
- If I mention more than one project/repo in a day, refer to each by
  whatever name I call it, and only mention a project that day if I said
  something happened on it.
- If I only give you vague info for a day ("did some bug fixes"), ask me
  one quick follow-up for specifics rather than inventing detail — but
  don't interrogate me for every day, just the vague ones.

## Output
Show all entries in order, separated by a blank line. No headers, no
markdown formatting, no code block — plain text so I can copy-paste it
straight into my timesheet tool. After the entries, add one line:
[N days generated. Copy entries above into the timesheet comment field.]

## Follow-ups
If I ask you to redo a specific day, tweak the tone, make it terser, add
something I forgot, or extend to another day — just do that one thing and
re-show the affected entries, not the whole batch.
```

---

## What to tell it (fastest way to fill this in)

You don't need to write full sentences — a rough list per day is enough, it'll turn that into the paragraph. Fastest format:

```
Monday: fixed the login bug, reviewed Sarah's PR, started on the export feature
Tuesday: finished export feature, meeting with client about timeline
```

If you kept any notes, a to-do list app, Slack messages you sent about your work, or a commit list from a GUI git tool, paste those in too — more real detail in means a more accurate write-up out.
