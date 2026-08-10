---
description: Generate Minutes of Meeting from a transcript file (.docx, .pdf, or .txt).
argument-hint: <file>
---

Argument: `$ARGUMENTS` is the path to a meeting transcript file. If it's empty, ask for the file path and stop — do not guess a path.

## 1. Resolve and read the transcript

Check the file extension:

- **`.txt`** — read it directly.
- **`.pdf`** — read it directly (the PDF reader handles up to 20 pages per call; if the transcript is longer, read it in successive page ranges and concatenate before analysis — don't analyze only the first chunk).
- **`.docx`** — there is no native reader for this format. Extract plain text using the first method that works, in this order:
  1. `pandoc "<file>" -t plain` if `pandoc` is on `PATH`.
  2. `python3 -c "import docx; print('\n'.join(p.text for p in docx.Document('<file>').paragraphs))"` if the `python-docx` package is available.
  3. Raw XML fallback: `unzip -p "<file>" word/document.xml`, then strip XML tags to recover the text (e.g. pipe through `python3 -c "import sys,re; print(re.sub('<[^>]+>', ' ', sys.stdin.read()))"`). This loses some structure (tables, speaker labels may run together) — note that in the output if it's the only method that worked.

  If none of the three work, tell the user their `.docx` couldn't be read and ask them to re-save it as `.txt` or `.pdf`. Do not fabricate a transcript to work around a read failure.

Any other extension: say the format isn't supported (only `.docx`, `.pdf`, `.txt`) and stop.

## 2. Extract, don't invent

Read the full transcript before writing anything. Identify:

- Key discussion points — what topics were actually discussed, in enough detail to be useful without re-reading the transcript.
- Decisions that were explicitly made or agreed to.
- Action items, each with an owner and a due date/timeline if the transcript states one.
- Blockers, risks, or open questions raised but not resolved.
- Follow-ups or next steps mentioned for after the meeting.

If an action item's owner or deadline is not stated or is genuinely ambiguous in the transcript, write **TBD** — never infer or guess a name or date that isn't actually there. The same applies anywhere else the transcript refers to a specific value without stating it (a figure, a system name, a target date): **TBD** is the correct answer, a plausible guess is a defect. Preserve people's names, project names, technical terms, and dates exactly as they appear in the transcript; don't paraphrase a proper noun or a specific figure.

Strip filler, small talk, repetition, and back-and-forth that didn't lead to a point, decision, or action — the MoM should read as the substance of the meeting, not a transcript summary of the conversation's flow.

## 3. Output format

Print the MoM directly in your response as clean Markdown, ready to paste into an email or doc and share as-is — no meta-commentary about how it was generated, no "here is your MoM" preamble. Don't write it to a file unless the user asked for one; if they did, save it next to the transcript as `<transcript-basename>-mom.md` and state the path.

Use exactly these sections, in this order:

```markdown
# Minutes of Meeting — <title/date if stated in transcript, else omit line>

## Meeting Summary
2-4 sentences: what the meeting was about and its overall outcome.

## Key Discussion Points
- Point — brief context
- ...

## Decisions Made
- Decision — brief context on why/how it was decided, if stated
- ...

## Action Items

| Action | Owner | Due Date |
|---|---|---|
| ... | Name or **TBD** | Date or **TBD** |

## Open Questions / Blockers
- ...

## Next Steps
- ...
```

Omit a section entirely (don't leave an empty header) if the transcript genuinely contains nothing for it — e.g. no blockers were raised. Keep the whole document concise: every line should carry information a participant would actually need, not restate something already covered elsewhere in the MoM.
