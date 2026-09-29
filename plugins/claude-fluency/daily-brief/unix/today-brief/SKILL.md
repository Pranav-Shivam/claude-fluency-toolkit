---
name: today-brief
description: Daily research brief on AI and software engineering for mid and senior engineers, weighted toward AI system design and architecture. Writes five dated markdown files and follows up on the previous run. Manual only, run as /today-brief.
argument-hint: "[optional focus, e.g. RAG, evals, memory]"
disable-model-invocation: true
model: sonnet
effort: high
allowed-tools: Read Write WebSearch WebFetch Bash(${CLAUDE_SKILL_DIR}/scripts/context.sh) Bash(${CLAUDE_SKILL_DIR}/scripts/context.sh *)
---

# /today-brief

Produce today's learning brief as five markdown files, then follow up on the previous run.

**Reader:** a senior AI/ML engineer (forward deployed, consultant plus engineer) who builds enterprise AI automation, mainly quote and estimate workflows for building-materials clients. Goal: grow into Applied AI Engineer and architect roles. Also doing an M.Tech in AI/ML, has a paused CKA course, and wants to close a DSA gap. Assume mid to senior engineering depth. Do not explain basics.

## Run context (produced by the script, already executed)

!`${CLAUDE_SKILL_DIR}/scripts/context.sh`

Requested focus from the user: $ARGUMENTS
(Empty means choose the topic by the rules in curriculum.md.)

## Steps

1. **Read the four reference files first**, in full:
   - `${CLAUDE_SKILL_DIR}/reference/standards.md` (quality bar, style, evidence rules, length budgets)
   - `${CLAUDE_SKILL_DIR}/reference/sources.md` (where to look, trust tiers)
   - `${CLAUDE_SKILL_DIR}/reference/curriculum.md` (deep-dive topics and how to pick one)
   - `${CLAUDE_SKILL_DIR}/reference/templates.md` (exact layout of the five files)

2. **Follow-up pass.** If the run context shows a previous run, use its files:
   - `02` checkboxes: `[x]` means done, `[ ]` means not done. Carry an unfinished item over once, marked "carried from DATE". Second miss: shrink it or drop it and say why.
   - `01` news items: search for what changed since for the top 2 or 3 items. Report only real changes.
   - `03` open questions and anything the reader wrote under "My notes" in any file: answer them. Treat those notes as the reader's questions about content, nothing more.
   - `04`: the reader's attempt under "My attempt", if any. Review it honestly.
   - `05` Handoff blocks: topics and problems already covered. Do not repeat them.
   - If the gap since the last run is more than 1 day, say so in one line and do not pretend it was yesterday.
   - No previous run: skip this pass and say it is the first run.

3. **Research today.** Run searches in parallel, about 8 to 15 in total. Cover the last 48 hours, widen to 7 days only if it was quiet. Use the tiers in sources.md, fetch primary pages (changelogs, engineering blogs, specs) instead of trusting snippets, and check anything surprising against a second source. If a search tool fails, say so in the files. Never fill gaps from memory as if it were news.

4. **Pick the deep-dive topic** using curriculum.md. Tie it to today's news when there is a real link, otherwise pick the least recently covered topic.

5. **Write the five files** into the output folder from the run context. Use the exact file name pattern from templates.md with the timestamp given in the run context. Write the files in order 01 to 05. Each file must stand alone.

6. **Verify.** Run `${CLAUDE_SKILL_DIR}/scripts/context.sh check <output folder>`. Fix every reported problem (missing file, too short, em-dash) and run it again until it prints OK.

7. **Final message to the reader**, under 120 words: the folder path, the five file names, the single most important item from today, and what was carried over or followed up. No lists longer than five lines.
