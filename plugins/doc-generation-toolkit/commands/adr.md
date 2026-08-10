---
description: Draft an Architecture Decision Record (ADR) capturing a decision, its alternatives, and why it was made.
argument-hint: <short decision title>
---

Argument: `$ARGUMENTS` is a short title or one-line description of the decision to record (e.g. "use Azure SQL Serverless instead of Snowflake for OLTP"). If it's empty, ask what decision this ADR is for and stop — do not invent one.

## Why this command exists

An ADR is not a status update — it's the reasoning an AI agent (or a new teammate) will need later to avoid undoing a decision it can't see the justification for. Code that looks "cleanable" or "over-engineered" out of context is sometimes that way for a specific, non-obvious reason. The ADR is where that reason lives so it survives past the conversation that produced it.

## 0. Check the decision is worth recording

Not every choice needs an ADR. Ask: does this affect system structure, a non-functional characteristic (performance, security, cost, scalability), a dependency/vendor, an interface boundary, or a construction technique — and would reversing it later be expensive? If it's a routine implementation detail with no lasting trade-off (variable naming, which utility function to call), say so and skip writing the ADR rather than manufacturing weight a small choice doesn't have.

## 1. Gather context before writing anything

Before drafting, check for and read:
- Any existing ADRs in `docs/adr/` or `docs/decisions/` (or ask where they live if this is the first one) — so numbering, format, and cross-references stay consistent, and so you don't duplicate a decision already recorded.
- The actual conversation, diff, or design discussion this ADR is being written from. Pull real constraints, numbers, and alternatives from it — don't invent trade-offs that weren't actually discussed.

When pulling from that source, extract short verbatim quotes or exact figures for the load-bearing claims (a constraint, a benchmark, a rejection reason) rather than paraphrasing from memory — a quote you can point back to is harder to drift from the source than a summary is.

If the decision's context is genuinely unclear or you weren't part of the discussion that made it, ask for a short explanation of the problem and the options considered rather than guessing at plausible-sounding ones. A fabricated alternative is worse than a missing one — it misleads the next reader into thinking more analysis happened than actually did.

## 2. Number and file it

Find the highest-numbered existing ADR in the target directory and use the next sequential number, zero-padded (e.g. `0001`, `0002`). If this is the first ADR in the repo, start at `0001` and create `docs/adr/` if it doesn't exist. Never renumber or delete an existing ADR — if this decision reverses or replaces an earlier one, say so explicitly in this new ADR's Context section and note in the old ADR that it's been superseded (append a one-line "Superseded by ADR-00XX" note at the top of the old file; don't rewrite its body).

File name: `docs/adr/00XX-kebab-case-title.md`.

## 3. Write the ADR in this exact structure

```markdown
# ADR-00XX: <Title>

## Status
Proposed | Accepted | Superseded by ADR-00YY

## Context
What problem or constraint made a decision necessary. State the forces at play — performance, cost, team size, compliance, deadline, existing system constraints — as they actually were, not as they'd ideally be. This section explains *why a decision was needed*, not what was chosen.

## Decision Drivers
The specific factors that determined the outcome, as a short list (e.g. "must stay under $X/month", "team has no prior operational experience with Y", "compliance requires data residency in Z"). Only list drivers that were actually stated or evident in the discussion — this section exists so a future reader can tell *which* forces were decisive without re-deriving them from the prose above. Omit the section if the Context above already makes the drivers obvious and repeating them would just restate it.

## Decision
The decision, stated as one clear sentence, then elaborated only as far as needed to remove ambiguity about what was actually decided.

## Alternatives Considered
For each real alternative that was discussed:
- **<Alternative>** — what it would have solved, and the specific reason it was rejected (cost, risk, complexity, timeline — whatever was the actual reason, not a generic one).

If only one option was genuinely considered, say so plainly instead of manufacturing alternatives to fill this section.

## Consequences
Both directions, honestly:
- **Positive** — what this decision makes easier, cheaper, safer, or faster.
- **Negative / accepted trade-offs** — what this decision makes harder, or what risk it knowingly accepts. Every real decision costs something; if this section is empty, look harder before finishing.

## Notes
Anything a future reader needs that doesn't fit above — links to the discussion, benchmark numbers, related ADRs, and (if known at write time) the commit SHA or PR link where this decision was implemented.
```

## 4. Rules

- Every claim in Context, Decision Drivers, Alternatives, and Consequences must trace back to something actually said or measured in the source discussion. If a number, benchmark, or constraint wasn't stated, write "not measured" or "TBD" rather than estimating one that sounds plausible.
- Keep it short. An ADR that takes ten minutes to read gets skipped by the next person who needs it. If a section is running long, that's a sign it belongs in a linked design doc, not the ADR itself.
- Status starts as `Proposed` unless the decision has already been implemented and confirmed working, in which case `Accepted` is correct immediately.
- Print the ADR in your response and, unless told otherwise, also write it to `docs/adr/00XX-kebab-case-title.md`, creating the directory if needed. Report the file path and number you assigned.
