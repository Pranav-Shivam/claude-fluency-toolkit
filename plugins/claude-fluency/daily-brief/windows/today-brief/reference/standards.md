# Quality standards

## Audience
Mid to senior engineer moving toward AI system design and architecture. Assume they know HTTP, queues, databases, Kubernetes basics, transformer basics and vector search basics. Define a term only if it is new this year. Spend words on trade-offs, failure modes, decision criteria and numbers.

## Style
- Plain, human wording. Short sentences. No hype words, no filler openers, no "in today's fast-moving landscape".
- No em-dashes anywhere. Use a comma, colon, period or parentheses.
- Numbers and specifics lead: versions, prices, limits, context sizes, latencies, dates, benchmark names with scores. An adjective is never a substitute for a number.
- Absolute dates (2026-09-29), never "yesterday" or "recently".
- Say "I could not confirm this" instead of guessing. Say "quiet day" instead of padding with recycled news.
- Paraphrase sources. A direct quote must be under 15 words and there is at most one per source. Never reproduce lyrics, long passages or paywalled text.

## Evidence labels (used in file 01 and wherever a claim drives a decision)
- **Confirmed**: stated on a primary source (vendor docs, changelog, official blog, spec, paper, repo release).
- **Reported**: credible secondary source, primary not found. Name the source.
- **Unverified**: single weak source, rumor, or social post. Keep it out of the main items unless it is important, and label it.

Numbers from vendor marketing, listicles and SEO blogs (cost multipliers, "accuracy gains", "10,000-agent" claims) are Unverified unless a primary source or reproducible benchmark backs them. Do not repeat them as fact.

## Depth rules for architecture content
- Every design recommendation names the alternative and when it wins.
- Every component has a responsibility and a contract (inputs, outputs, failure behavior).
- Every "best practice" comes with the failure it prevents.
- Worked examples label assumed numbers as assumptions.
- Prefer the smallest architecture that meets the requirement. Say when a workflow beats an agent.

## Length budgets (words, excluding code and tables)
- 01 whats-new: 600 to 900
- 02 follow-up-and-focus: 400 to 700
- 03 architecture-deep-dive: 1100 to 1600
- 04 practice: 400 to 650
- 05 reading-and-handoff: 200 to 400

## Files
- Each file starts with YAML frontmatter and stands alone.
- Links are full URLs to the page used, not to home pages.
- Mermaid diagrams must be valid: simple `flowchart LR` or `sequenceDiagram`, quoted labels when they contain punctuation.
