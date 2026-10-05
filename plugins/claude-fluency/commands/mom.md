---
description: Generate client-safe Minutes of Meeting from a transcript file (.docx, .pdf, .txt, .vtt, .srt), with a private review block.
argument-hint: <file> [brief] [internal] [followup] [docx]
---

Argument: `$ARGUMENTS` is the path to a meeting transcript (or AI-generated meeting recap) file, optionally followed by one or more switches: `brief`, `internal`, `followup`, `docx`. If no file path is given, ask for it and stop — do not guess a path.

The MoM goes directly to external stakeholders — it must be accurate, neutral, and professional. If the user supplied context in the conversation (their name/company, client company, attendee list, glossary of correct spellings), use it for rule 7 below.

## 1. Resolve and read the input

Check the file extension:

- **`.txt`, `.vtt`, `.srt`** — read it directly.
- **`.pdf`** — read it directly (the PDF reader handles up to 20 pages per call; if the transcript is longer, read it in successive page ranges and concatenate before analysis — don't analyze only the first chunk).
- **`.docx`** — there is no native reader for this format. Extract plain text using the first method that works, in this order:
  1. `pandoc "<file>" -t plain` if `pandoc` is on `PATH`.
  2. `python3 -c "import docx; print('\n'.join(p.text for p in docx.Document('<file>').paragraphs))"` if the `python-docx` package is available.
  3. Raw XML fallback: `unzip -p "<file>" word/document.xml`, then strip XML tags to recover the text (e.g. pipe through `python3 -c "import sys,re; print(re.sub('<[^>]+>', ' ', sys.stdin.read()))"`). This loses some structure (tables, speaker labels may run together) — flag that in the Review block if it's the only method that worked.

  If none of the three work, tell the user their `.docx` couldn't be read and ask them to re-save it as `.txt` or `.pdf`. Do not fabricate a transcript to work around a read failure.

Any other extension: say the format isn't supported (only `.docx`, `.pdf`, `.txt`, `.vtt`, `.srt`) and stop.

Read ALL of it before writing anything. If the input is an AI-generated recap rather than a raw transcript, treat it as a secondary source: strip its citation tags, and treat any owner or date it labels "inferred," "implied," or "not explicitly assigned" as TBD.

## 2. Accuracy rules — these override everything else

1. **Extract, don't invent.** Every name, number, date, system name, and commitment must be directly traceable to the input. If it isn't stated, write **TBD**. A plausible guess is worse than TBD — it creates false accountability.
2. **Action item owners.** An owner is a name only if the input explicitly assigns the work to that person or they clearly volunteered. "The team," "development team," or an inferred owner → TBD. Show the owner's organization in parentheses when the input makes it clear (e.g. "Alex (ClientCo)").
3. **Due dates.** A date appears only if stated. Relative dates ("next Friday," "end of sprint") → resolve only if the meeting date is in the input; otherwise keep the exact wording. Never calculate from today's date.
4. **Decisions vs. suggestions.** Do not promote a suggestion, hope, or "we should look at this" into a decision. Preserve hedging language ("agreed to review," "may need to"). A decision is only something the group explicitly agreed to do or not do.
5. **Action items vs. completed work vs. unassigned concerns.** Action item: someone was asked or agreed to do something not yet done. Completed work: belongs in Discussion, not the action table. Unassigned concern: goes under Open Items, never in the action table with a guessed owner.
6. **Attribution.** Attribute a statement to a named person only if the input does. If speaker labels are missing or ambiguous, describe the point without naming a speaker.
7. **Names and terms.** Keep names, technical terms, figures, and dates exactly as they appear. If a name or term appears in multiple spellings, use the one from the user's supplied context; if it doesn't match anything, use the most frequent spelling and flag it in the Review block.
8. **Contradictions.** If a figure, date, or fact contradicts itself across the input (e.g. "5%" vs. "15%"), do not silently pick one. Note both and flag it.
9. **Tense.** Past tense throughout: "The team discussed…," "It was agreed that…".
10. **No repetition.** Each fact appears once, in the section where it fits best.

## 3. Client-safe writing rules

- Write neutrally and factually: describe what was observed, requested, or agreed — never assign blame. ✓ "Variance increased on larger quantities during testing." ✗ "The dev team broke the calculation logic."
- Never remove a substantive issue, risk, or concern the client raised. Soften the tone, never the substance.
- Leave out internal-only material: side conversations, jokes, venting, opinions about individuals, speculation about motives, internal pricing or staffing talk. Note the omission in the Review block without repeating the content.
- No filler, pleasantries, small talk, preamble ("Here are the minutes…"), or commentary about how the document was produced.

## 4. Output format

Print the MoM directly in your response as plain Markdown, ready to paste into an email. No citation tags, no emoji in the MoM itself. ~1 page for a ≤30-minute call, up to 2 pages for longer calls. Professional but not stiff; active voice where possible. Use exactly this structure and skip any section with nothing in it (no empty header):

```markdown
**Subject:** MoM — <meeting title> — <date if stated>

# Minutes of Meeting — <title, date if stated>
**Date:** <date and time if stated>
**Attendees:** <Name (Company), … — only names identifiable from input>
**Absent / Apologies:** <if mentioned>
**Meeting called by:** <if stated>

## Meeting Summary
2–4 sentences: what the meeting was about and the overall outcome.

## Key Discussion Topics

### 1. <Short, specific topic headline>
2–4 sentences: what was raised, by whom (if stated), the concern or context, and where the discussion landed.

## Decisions & Agreements
- What was explicitly agreed, with one line of context if stated.

## Action Items

| # | Action | Owner | Due Date | Context |
|---|--------|-------|----------|---------|
| 1 | <Specific, verb-led task> | Name (Org) or TBD | Date or TBD | Why it matters / what it unblocks |

## Open Items
- Concerns, questions, blockers, or risks raised that no one took ownership of.

## Chat Notes
- Substantive meeting-chat items only: test results, data, links, commitments made in chat.

## Next Steps
- Only what the input says happens after the meeting.
```

One `###` block per distinct topic, in discussion order unless a logical grouping is clearly better. If no due dates were established, add one line below the action table: *"No due dates were established during this meeting."* Keep actions specific and verb-led ("Review the pricing model and identify missing optimization logic", not "Look into pricing").

## 5. Review before sending — for the user only, not part of the MoM

After the MoM, add a separator line and a **Review before sending** block, max 8 bullets, each prefixed `⚠️`. Only items that need attention before sending:

- Action items with TBD owners — suggest an assignee only if the context makes it obvious, framed as a suggestion.
- Names, figures, or dates that were unclear, multiply spelled, or possible transcription errors.
- Anything that sounded like a commitment from the user's side worth double-checking.
- Sensitive or internal-only content omitted or softened (describe the topic area, don't repeat the content).
- Contradictions in the input.
- Inaudible, garbled, or missing sections where substance may have been lost.

If there is genuinely nothing to flag, write: "Nothing to flag — ready to send."

Before outputting, silently self-check: every owner, fact, figure, and date traces to the input; no fact repeats across sections; nothing in the MoM the client shouldn't read; past tense throughout; actions are specific; the Meeting Summary alone gives a useful picture.

## 6. Switches

Apply any switches given after the file path (they combine, e.g. `followup docx`, `internal brief`):

- **`brief`** — Meeting Summary + Decisions & Agreements + Action Items only.
- **`internal`** — no client-safe softening; include candid context, risks, internal opinions. Put `INTERNAL — NOT FOR DISTRIBUTION` at the top.
- **`followup`** — after the MoM and Review block, draft a 3–5 line cover email for sending the MoM to attendees: professional, warm, a one-line summary, and a request to flag corrections within 24 hours.
- **`docx`** — also write the MoM (without the Review block) next to the transcript as `<transcript-basename>-mom.docx` via `pandoc -f markdown -o`. If `pandoc` isn't on `PATH`, say so and write `<transcript-basename>-mom.md` instead. State the path either way.

Without `docx`, don't write a file unless the user asked for one; if they did, save it next to the transcript as `<transcript-basename>-mom.md` and state the path.
