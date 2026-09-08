# AI writing tells — reference list

A working list of vocabulary, phrasing, and structural habits that read as mechanically AI-generated. Use this as a checklist while rewriting, not a rigid banned-word filter — the goal is writing that's actually better, not writing that just avoids these specific strings.

**Read this before flagging anything:** most words on this list are ordinary in professional/technical writing on their own. `robust error handling`, `seamless integration`, `crucial dependency` are decades-old real engineering jargon, not AI tells by themselves. What's actually diagnostic is **clustering** — three or more of these in a paragraph, or the same structural pattern repeated across sections. A single instance is not evidence. Don't strip a word just because it's on this list; strip it when the passage is stacking several of them.

## Overused vocabulary

Words that show up constantly in AI output relative to how often people actually use them in speech or casual/professional writing — flag on clustering, not single use:

delve, boast/boasts, underscore/underscores, tapestry, testament (to), leverage (as a verb), robust, seamless(ly), streamline(d), unlock, elevate, foster, navigate (metaphorically), landscape (metaphorically, e.g. "the evolving landscape of..."), realm, journey (metaphorically), holistic, multifaceted, nuanced, intricate, meticulous(ly), comprehensive, myriad, plethora, paramount, pivotal, crucial (overused as filler rather than meaning something is truly critical), invaluable, game-changer/game-changing, cutting-edge, state-of-the-art (as filler), unprecedented, transformative, dynamic (as vague filler), synergy/synergize, empower(ing), harness (as a verb), embark (on), endeavor, unpack (metaphorically), shed light on, spearhead, facilitate, elucidate, encompass, catalyze, juxtapose, unravel, epitomize, conceptualize, galvanize, bolster, garner, cultivate, resonate, discern, illuminate (metaphorical), amplify, hone, craft (as a vague verb, e.g. "carefully crafted"), tailor (verb), bespoke, enduring, profound, unwavering, compelling, scalable, optimize/optimizing, paradigm shift, unlock the potential of, hold promise, transformative power, excitingly (as a sentence opener).

`delve` is the anchor word most lists lead with, but it peaked in the GPT-4 era (2023–mid-2024) and has faded some since — worth flagging, no longer uniquely diagnostic on its own.

## Copula avoidance — a pattern, not a word list

The single highest-leverage tell, and the most concrete finding worth watching for: AI writing routinely avoids the plain verb "is/are" in favor of a dressier stand-in — `serves as`, `stands as`, `functions as`, `operates as`, `represents (a)`, `acts as`. "X serves as a testament to Y" is almost always just "X shows Y." Ask, every time you see one of these, whether the plain copula loses anything. Usually it doesn't.

## Overused transitions and hedges

- "It's important to note that..." / "It's worth noting that..." / "It's important to remember that..." / "It should be considered..." / "It is worth mentioning..."
- "Moreover," / "Furthermore," / "Additionally," used to open sentence after sentence
- "In today's fast-paced/ever-evolving/digital world..."
- "When it comes to X..."
- "At the end of the day..."
- "Generally speaking," / "Broadly speaking,"
- "Needless to say,"
- "That being said," / "With that said,"
- "In conclusion," / "To sum up," / "In summary," as a rote closing formula rather than because a summary genuinely adds something
- "Not only X, but also Y"
- "It's not X, it's Y" / "It's not just about X — it's about Y" (negative parallelism / contrastive dismissal) — arguably more diagnostic than the rule-of-three; well-documented as growing sharply in AI-influenced corporate writing
- "Whether you're A or B, ..." (false-choice framing opener)
- "This is where X comes in" / "Here's the thing" / "The result?" (rhetorical-question-as-transition) / "Great question!"
- "Picture this" / "Imagine a world where..." / "Ever wondered...?" (narrative-hook openers)
- "Studies have shown..." / "Research suggests..." / "Experts agree..." used without an actual citation — vague-authority hedge
- "The key is to find balance" / "finding the right balance" (pseudo-insight closer)
- "cannot be overstated" — widely cited across sources, though no single authoritative study; treat as commonly cited, not confirmed
- "at its core..." as a definitional opener
- "boils down to" — weaker sourcing, include with lower confidence

## Structural patterns

- **The rule-of-three reflex.** Constantly listing exactly three items/adjectives ("fast, reliable, and secure") regardless of whether three is actually the right number.
- **Elegant variation.** Cycling through near-synonyms to avoid repeating a noun ("the company... the firm... the organization... the enterprise") where a human would just repeat the plain word. A real, checkable pattern — repetition is often more natural than variation for its own sake.
- **Uniform paragraph shape.** Every paragraph structured as topic sentence → three supporting points → mini-conclusion, repeated identically throughout a piece.
- **Metronome rhythm.** Not just uniform sentence *length* but identical clausal shape — subject-verb-object, subject-verb-object, subject-verb-object, sentence after sentence. The fix is varying how a sentence is built, not just how long it is.
- **Reflexive bulleting**, especially the **"bold term: explanation" list format** — every bullet opens `**Term**: definition sentence`, applied uniformly down the list. This specific visual signature is more recognizable and more catchable than plain over-bulleting.
- **Manufactured balance.** "On one hand... on the other hand..." framing applied even when there isn't genuine ambivalence, just to seem balanced.
- **Throat-clearing openers.** A full paragraph — or even just one sentence — of context/setup before getting to the actual point, when the point could just open the piece. Try deleting the opening sentence of a paragraph; if the paragraph still works, it wasn't doing anything.
- **Recap closings.** Restating what was just said ("To summarize, we covered...") on pieces short enough that the recap adds nothing.
- **Over-scaffolded headers.** Adding "## Overview / ## Key Points / ## Conclusion" boilerplate section structure to short pieces that don't need it. Watch for headers with no body content before the next subheading, and skipped heading levels — both markdown-specific tells relevant to docs/README work.
- **The "praise, then generic challenges, then vague optimism" shape.** A section that opens praising the subject, pivots to unspecific "challenges" or "considerations," and closes with generic forward-looking optimism — common in AI-written "About/Overview" sections.
- **Restating the question before answering it.** Chat-specific tell — "Great question! To answer whether X, let's first look at..." instead of just answering.
- **Title Case Headers For Everything**, or the inverse — decorating headers with emoji as a substitute for actually engaging content underneath.

## Punctuation and formatting habits

- **Em dash overuse is a real pattern but no longer a universal cross-model signal** — model behavior on this has been shifting fast (some newer model releases were tuned to use fewer, others more). What's more durable than raw frequency: AI em dashes tend to be *additive/explanatory* — bolting on a clause a comma or period would carry just as well — rather than the sharp interruption or aside a human reaches for. Flag the pattern (an explanatory clause every sentence or two), not a raw count.
- Bolding **random phrases** for emphasis throughout a paragraph rather than reserving bold for genuinely key terms.
- Semicolons used more than a person would naturally use them in the register being written in.
- Numbered "key takeaways" lists tacked onto the end of things that didn't ask for one.
- Inconsistent smart/curly quotation marks mixed into otherwise plain text, and Title Case misapplied mid-sentence or to headers inconsistently.
- Ellipses overuse — weaker sourcing than the rest of this section, but worth a light check.

## Model-specific notes

Text of unknown origin is the normal case for this command, so don't lean on any single model's fingerprint as a detector — these drift within months as models get retuned, and the patterns above (copula avoidance, negative parallelism, clustering) are the durable core. Treat the following as directional color, not a lookup table:

- **ChatGPT/GPT family** — heavier reliance on bulleted lists even when prose was the natural fit; drama-opener transitions ("This changes everything"); negative parallelism used heavily.
- **Claude** — tends toward flowing paragraphs over bullets; still prone to the `delve`/`tapestry`/`landscape`/`testament` vocabulary family and "In today's fast-paced world" absent explicit style instruction.
- **Gemini** — reportedly favors passive-acknowledgment hedges ("it is important to note," "it should be considered") more than other families, plus filler "might."
- **Grok** — most stylistically divergent; casual/internet register, tends to avoid the corporate-hedging vocabulary above, so the standard checklist under-flags it.

## What to do instead

For each tell you catch, don't just delete or synonym-swap it — ask what a person would actually write there. Often that's simpler and shorter than the AI version, not just different vocabulary wearing the same sentence shape.

Concrete techniques beyond word-swapping:

- **Read the rewrite aloud (mentally).** Repeated sentence openers and metronome rhythm are much easier to catch by ear than by eye.
- **Swap the most abstract claim in each section for a specific one.** AI prose stays in the abstract ("teams often struggle with..."); the fix is a specific instance, number, or named case.
- **Vary clause shape, not just sentence length.** Lead with a subordinate clause sometimes, lead with the verb sometimes, drop in a fragment occasionally.
- **Let a plain noun repeat instead of cycling synonyms.** Countermeasure to elegant variation — three "the function"s in a row reads more natural than "the function... the method... the routine."
- **Cut the throat-clearing opening sentence and see if the paragraph still works.** It usually does — the second sentence was the real opener.
- **Prefer the plain copula.** "X is Y" over "X serves as/stands as/functions as Y" — the single highest-leverage fix on this whole list.
- **Use an em dash the way a person would: for a sharp aside or interruption, sparingly** — not to bolt an explanatory clause onto every other sentence.

If it still sounds like it's performing "clear, organized writing" rather than just communicating, it needs another pass.
