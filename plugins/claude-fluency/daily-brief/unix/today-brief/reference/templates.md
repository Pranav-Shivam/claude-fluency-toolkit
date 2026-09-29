# File templates

File name pattern inside the output folder: `NN-slug_HHMM.md` using the timestamp from the run context.
- `01-whats-new_HHMM.md`
- `02-follow-up-and-focus_HHMM.md`
- `03-architecture-deep-dive_HHMM.md`
- `04-practice_HHMM.md`
- `05-reading-and-handoff_HHMM.md`

Every file starts with this frontmatter (fill it in):

```
---
date: YYYY-MM-DD
time: HH:MM
section: 01-whats-new
generated_by: /today-brief (sonnet)
---
```

## 01 What's new
```
# What's new: {Weekday, D Month YYYY}

**Signal today:** one sentence on the change that matters most for AI system design.

## Items (max 5, ranked by impact on architecture decisions)

### 1. {Plain headline with the key number}
- **What changed:** 1 to 3 sentences of facts: versions, prices, limits, dates.
- **Evidence:** Confirmed | Reported | Unverified, then the link(s)
- **Layer:** orchestration | tools and MCP | memory and retrieval | evals and LLMOps | guardrails and security | cost and latency | data and infra | model
- **So what:** what a design review should do differently, with the trade-off.
- **Act on it:** Now | This month | Watch | Ignore, plus one concrete step.

(repeat for each item)

## Skipped as noise
2 to 4 one-line items and why they do not matter.

## Sources
Full URLs used.
```
Quiet day: fewer items, and say so in "Signal today".

## 02 Follow-up and focus
```
# Follow-up and focus

## Follow-up from {previous run date}   (omit on the first run; note the gap if more than 1 day)
- **Focus items:** each one with status (done, carried, dropped) and one line on the next step
- **News updates:** only real changes to earlier items, with links
- **Your notes answered:** answers to questions the reader wrote, quoted by topic not verbatim
- **Open design question:** answer one open question from the previous file 03

## Focus today
Three items, each 20 to 60 minutes, at least one hands-on:
- [ ] **{Title}** (30 min). Why: ... Do this: concrete action. Done when: observable check.

## My notes
(leave this section empty for the reader)
```

## 03 Architecture deep dive
```
# Architecture deep dive: {Topic}

**Layer:** ...  **Level:** senior  **Builds on:** {earlier topic or "standalone"}

## The problem
One paragraph: what breaks in production without this.

## Reference architecture
{mermaid diagram}
Walk through each component: responsibility and contract (inputs, outputs, failure behavior).

## Decisions and trade-offs
| Decision | Option A | Option B | Pick A when / Pick B when |

## Failure modes
| Failure | Symptom you would see | Mitigation |

## Evaluation and observability
What to measure, where to instrument, thresholds if a primary source supports them.

## Cost and latency levers
Ranked by impact, with rough magnitudes labelled as assumptions where not sourced.

## Apply it: enterprise quote/estimate automation
One worked scenario with concrete components and assumed numbers.

## What is changing now
Link to today's news if relevant, otherwise the current state of the art with dates.

## Design review questions
Five questions a staff engineer would ask.

## Open questions
2 or 3 questions for the next run to answer.

## My notes
(leave this section empty for the reader)

## Sources
```

## 04 Practice
```
# Practice: {Problem name}

## Yesterday's problem: approach   (omit on the first run)
Approach, complexity, the common mistake, and a review of the reader's attempt if one was pasted.

## Today's problem
Statement, constraints, two examples. Difficulty: Easy | Medium | Hard. Pattern: ... Time box: ... Target complexity: ...

<details><summary>Hint 1</summary>...</details>
<details><summary>Hint 2</summary>...</details>
<details><summary>Hint 3</summary>...</details>

## Where this pattern shows up in AI systems
Two or three concrete places (for example LRU eviction in a semantic cache, topological sort in a task DAG).

## Stretch
A harder variant, or a small build exercise.

## My attempt
(leave this section empty for the reader; paste code or notes)
```
No full solution today. It comes in tomorrow's file.

## 05 Reading and handoff
```
# Reading and handoff

## Read (max 3)
- **{Title}** ({source}, ~N min): link. What to look for: 2 lines. Why it is worth the time.

## Watch list
Things to re-check, each with a re-check date.

## Handoff
- run: YYYY-MM-DD HHMM
- topic_covered: {topic}
- layer: {layer}
- dsa_problem: {name} | {pattern}
- news_items: {short headlines, semicolon separated}
- open_threads: {questions or items to follow up}
- carried_over_focus: {items or none}
```
The Handoff block must stay at the bottom of file 05 and keep the `- key: value` shape, because the next run and the helper script read it.
