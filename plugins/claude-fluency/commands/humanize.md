---
description: Rewrites AI-generated or AI-assisted writing — prose, docs, README/markdown files, emails, Slack/chat messages, commit messages, code comments and docstrings, anything — so it reads like a person actually wrote it, by cutting the mechanical tics, over-hedged phrasing, and repetitive rhythm typical of LLM output. Trigger this whenever the user runs /humanize, or asks to "humanize this," "de-AI-ify this," "make this sound less like ChatGPT/an AI wrote it," "make this sound more natural," "this reads like a robot," or hands over a chunk of text/code/docs and asks Claude to make it sound human — regardless of file type. Also worth offering proactively right after Claude itself drafts a long piece of prose (email, README, report) if the user has used this command before or has said natural-sounding output matters to them. Improves writing quality and voice only — see Scope below for what it deliberately will not do.
argument-hint: [text, file, or nothing — if nothing, ask what to rewrite]
---

Argument: `$ARGUMENTS` is the text to rewrite, or a path to it. If it's empty and nothing else in the conversation is the obvious target (e.g. a piece Claude just drafted), ask what to rewrite and stop — do not guess.

# Humanize

Turns stiff, obviously-AI-sounding writing into something that reads like an actual person wrote it — without changing what it says, what it means, or (for code) what it does.

## Scope — read this first

This command fixes *writing quality*: the tics, rhythms, and phrasing that make text sound like it came out of an LLM. It is not a tool for defeating AI-detection classifiers (GPTZero, Turnitin, Originality.ai, Copyleaks, etc.), and it does not touch watermarks or provenance metadata (SynthID, C2PA, EXIF). Those are different problems with a different purpose — evading a system built specifically to flag AI-authorship — and that's not what this command is for.

Two hard rules that follow from that, apply them even if a user asks otherwise:

1. **Never fabricate a human backstory.** Don't invent personal anecdotes, credentials, experience, or first-person claims ("when I worked at...", "in my experience...") that the user didn't actually provide. That's not humanizing, it's lying about authorship.
2. **Never degrade content to fake imperfection.** Don't introduce factual errors, remove load-bearing caveats/disclaimers, or insert typos to seem more "authentically human." If a detector-evasion request comes in explicitly (e.g. "make sure this passes Turnitin"), say plainly that's outside what this command does, and offer the writing-quality version instead.

Everything below is about making genuinely better, more natural writing — which as a side effect also reads as less obviously AI-generated, because the underlying problems (formulaic structure, hedge-stacking, generic vocabulary) are actual writing weaknesses, not just detector bait.

## Process

1. **Identify the content type** — prose/doc, email, markdown/README, commit message, or code (comments/docstrings only). This changes what "sounds human" means; a good commit message and a good email have nothing in common structurally.
2. **Read `references/humanize-ai-tells.md`** for the specific vocabulary, punctuation habits, and structural patterns to hunt for. Don't just delete flagged words — understand *why* each one reads as mechanical (see "What human writing actually looks like" below) so the rewrite is a genuine improvement, not a synonym swap.
3. **Rewrite**, following the content-type notes below. Preserve completely: factual claims, required disclaimers, technical accuracy, the user's actual intent and stance, and — for code — exact behavior.
4. **Show what changed.** Don't just hand back a wall of new text; briefly flag the kinds of things you changed (e.g. "cut three throat-clearing intros, varied sentence length in paragraph 2, dropped the em-dash habit") so the user can verify nothing substantive shifted. For code, make clear that only comments/docstrings/naming changed and logic is untouched — a diff view is ideal here.
5. **Ask before going further** if the target tone is ambiguous (more casual vs. more formal, keep specific phrases the user likes, etc.) rather than guessing.

## What human writing actually looks like

Don't treat this as a find-and-replace on banned words — that just produces different mechanical writing. The underlying principles:

- **Sentence length varies naturally.** AI writing tends toward a steady medium length, sentence after sentence. Real writing has short punchy sentences next to longer ones, because emphasis works that way.
- **People front-load the point.** AI writing often opens with a throat-clearing setup ("In today's fast-paced world, X has become increasingly important...") before getting to the actual point. Humans usually just say the thing.
- **Not everything is a triad.** "Fast, reliable, and scalable" — AI writing reaches for the rule-of-three constantly. Real writing gives one thing, or two, or a messy list of four, as often as exactly three.
- **Hedging is used for real uncertainty, not as a tic.** AI writing hedges reflexively ("it's worth noting that," "it's important to remember," "generally speaking") even when there's nothing uncertain being said. Cut the hedge unless it's doing real work.
- **Not every list wants to be bullets.** AI defaults to bulleting anything with more than one item. People write "there are three things to check: X, Y, and Z" as a sentence all the time.
- **Contractions, sentence fragments, and starting a sentence with "And" or "But" are normal.** Formal-by-default is itself a tell.
- **Opinions and uncertainty sound like actual opinions and uncertainty** — not manufactured on-the-one-hand/on-the-other-hand balance where no real ambivalence exists.

## Content-type specific notes

### Code — comments, docstrings, commit messages
- Touch **only** comments, docstrings, commit messages, and (if explicitly asked) identifier naming style. Never alter logic, control flow, or behavior — this isn't a refactor.
- AI-written comments tend to narrate the obvious ("// increment counter" above `counter++`) or over-explain — commenting every line rather than only the non-obvious logic is itself a tell. Cut comments that just restate the code (including ones that restate the function/variable name in prose, e.g. "// This function calculates the total" above `calculateTotal()`); keep/rewrite the ones that explain *why*, not *what*.
- AI docstrings often list every parameter with padded boilerplate even for a two-line function. Match the comment density to what the code actually needs.
- Commit messages: AI defaults to a very recognizable shape ("This commit adds X, which improves Y by doing Z") or a narrative changelog-essay body ("In this commit, improvements were made to..."). Real commit messages are terser, imperative-mood, and specific ("fix off-by-one in pagination cursor"), and explain *why* the change was made rather than mechanically restating the diff. Watch for passive/nominalized phrasing ("Improvements were made to X" instead of "Fix X"), and for emoji-prefixed commits (Gitmoji-style) showing up by default when the repo's own history doesn't use that convention.
- Confirm to the user explicitly that behavior is unchanged — ideally show a diff, not just the new file.

### Documents, README, markdown
- Kill the AI heading/section reflex: not every doc needs "## Overview," "## Key Features," "## Conclusion" as boilerplate scaffolding if the content doesn't actually call for it.
- Watch for the "Not only does X, but it also Y" construction and emoji-decorated headers — both common AI tells.
- Keep the doc's actual technical content (steps, commands, file paths) exact — this is a style pass, not a rewrite of substance.

### Email / chat messages
- AI emails over-structure short messages (greeting paragraph, body paragraph, summary paragraph, sign-off) for things that would be two sentences from a person.
- "I hope this email/message finds you well" as an opener, and "kindly let me know" / "please don't hesitate to reach out" as closers, are close to hard AI signatures at this point — cut them rather than soften them.
- Cut the reflexive closing recap ("To summarize, I wanted to...") on anything short enough that summarizing it is redundant.
- In chat specifically, watch for restating the question before answering it ("Great question! To answer whether X, let's first look at...") — a person just answers.
- Match register to what the user actually writes like elsewhere if you have context on that (e.g. from earlier in the conversation) — don't impose a generic "professional" voice if their real voice is more casual. A tone that would fit "any situation" equally well is itself a tell; real email is calibrated to the specific relationship.

### General prose / reports / essays
- This is where the vocabulary and structure patterns in `references/humanize-ai-tells.md` matter most — read it before rewriting anything substantial.
- Vary paragraph length and structure, not just sentence length; AI prose often gives every paragraph the same topic-sentence-then-three-supporting-points shape.

## Reference

`references/humanize-ai-tells.md` (plugin root) — a working list of overused words, transition phrases, punctuation habits, and structural patterns typical of LLM output. Read it as part of step 2 above. If you notice a pattern in the user's specific text that isn't in the list, use your judgment — the list is a starting point, not exhaustive.
