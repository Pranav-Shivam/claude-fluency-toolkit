# `/mom` — no install needed

This is the same skill as the `/mom` command in the Claude Code plugin, packaged as one paste-in block for the regular [claude.ai](https://claude.ai) chat or desktop/mobile app — no terminal, no plugin, no install. It works fully here because `/mom` only ever needed one file (your transcript) — and claude.ai lets you attach a file to a message directly, so there's no capability gap versus the CLI version.

## How to use it (pick one)

**Option A — Claude Project (best if you run meetings often):**
1. Go to [claude.ai](https://claude.ai) → **Projects** → **Create project**.
2. Open **Set custom instructions**, paste the box below, save.
3. In any chat inside that project, attach your transcript file (the paperclip/`+` icon) and send — even with no message text, it'll produce the MoM.

**Option B — One-off, any chat:**
1. Start a new chat.
2. Paste the box below as your first message.
3. Attach your transcript file (`.docx`, `.pdf`, or `.txt`) to that same message, or paste the transcript text directly under the instructions if you don't have a file. Send.

---

## Copy everything below this line

```
I'm going to give you a meeting transcript — either as an attached file
(.docx, .pdf, or .txt) or pasted as text below these instructions. Turn it
into a clean Minutes of Meeting document.

## Read the whole transcript first
Read everything before writing anything. Identify:
- Key discussion points — what topics were actually discussed, in enough
  detail that someone reading only the MoM understands what happened,
  without needing to go back to the transcript.
- Decisions that were explicitly made or agreed to.
- Action items, each with an owner and a due date if the transcript states
  one.
- Blockers, risks, or open questions that were raised but not resolved.
- Follow-ups or next steps mentioned for after the meeting.

## Extract, don't invent
If an action item's owner or deadline isn't stated, or is genuinely
ambiguous, write TBD — never guess a name or date that isn't actually
there. Same for any other specific detail the transcript doesn't actually
state (a figure, a system name, a target date) — TBD is correct, a
plausible-sounding guess is a mistake. Keep people's names, project names,
technical terms, and dates exactly as they appear — don't paraphrase a
proper noun or a specific number.

Strip out filler, small talk, repetition, and back-and-forth that didn't
lead anywhere — the MoM should read as the substance of the meeting, not a
blow-by-blow of how the conversation flowed.

## Output format
Print the MoM directly as clean Markdown, ready to paste into an email or
doc — no "here is your MoM" preamble, no commentary about how you produced
it. Use exactly these sections, in this order, and skip any section
entirely (no empty header) if the transcript genuinely has nothing for it:

# Minutes of Meeting — <title/date if the transcript states one, otherwise
  omit this line>

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
| ... | Name or TBD | Date or TBD |

## Open Questions / Blockers
- ...

## Next Steps
- ...

Keep the whole document concise — every line should carry information a
participant would actually need, not restate something already covered
elsewhere in the same document.

---

Understood the above? If yes, wait for the transcript (attached file, or
pasted text right after this) and produce the MoM per the format above —
don't ask me to confirm first, just do it.
```

---

If you have several meetings a week, Option A saves you re-pasting this every time. That's the whole thing — nothing else to install.
