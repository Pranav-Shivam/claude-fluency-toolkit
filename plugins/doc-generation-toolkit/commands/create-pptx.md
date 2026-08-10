---
description: Generate a PowerPoint deck (.pptx) from a content file, optionally applying a header/footer/branding template.
argument-hint: <content-file> [--template <template-file>]
---

Argument: `$ARGUMENTS` holds the content file path, and optionally ` --template <path>` after it. Split on the literal token `--template`: everything before it (trimmed, quotes stripped) is the content file; everything after it (trimmed, quotes stripped) is the template path, if present. If the content file is missing, ask for it and stop — do not guess a path.

## 1. Read the content file

Supported: `.txt`, `.md`, `.pdf`, `.docx`. Anything else: say the format isn't supported and stop.

- **`.txt` / `.md`** — read directly.
- **`.pdf`** — read directly; if longer than 20 pages, read in successive page-range calls and concatenate before analysis — don't plan slides off only the first chunk.
- **`.docx`** — no native reader. Extract with the first method that works:
  1. `pandoc "<file>" -t plain` if `pandoc` is on `PATH`.
  2. `python3 -c "import docx; print('\n'.join(p.text for p in docx.Document('<file>').paragraphs))"` if `python-docx` is available.
  3. `unzip -p "<file>" word/document.xml` piped through a tag-stripping pass (`python3 -c "import sys,re; print(re.sub('<[^>]+>', ' ', sys.stdin.read()))"`) as a last resort — this loses table/structure fidelity, so note that in your final report if it's the method used.

  If none work, tell the user and ask them to convert to `.txt`/`.md`/`.pdf`. Don't fabricate content to work around a read failure.

## 2. Analyze before designing slides

Read the entire extracted content first. Identify:

- The overall narrative/story the source is trying to tell, and its natural sections.
- The key point(s) per section — not every sentence, the ones that matter.
- Concrete facts worth calling out: names, project names, technical terms, numbers, dates, metrics — carry these forward verbatim, never paraphrased into something looser or rounder.
- Where a table, timeline, simple chart, or basic flow diagram would communicate better than bullet text — only where the source actually contains that shape of information (a real table of numbers, a real chronological sequence, a real before/after comparison). Never invent structure the source doesn't support.

Where the source refers to a specific value but never states it — an owner, a date, a figure, a status — write **TBD** in that slot rather than inferring a plausible one. A TBD on a slide is correct; a guessed name, date, or number is a defect. If a whole planned slide would be mostly TBD, drop the slide instead and note the gap in your final report.

## 3. Plan the outline before building anything

Write out an explicit slide plan: slide number → title → the bullet points or visual element it will contain, and which source section it maps back to. Slide count should follow content density — don't force a fixed number, and don't cram unrelated points onto one slide just to hit a lower count. Every bullet on every slide must trace back to something actually present in the source; if you can't point to where it came from, cut it.

Do not lift large paragraphs verbatim — restructure into short, presentation-friendly bullets. A slide with a wall of prose has failed at this step; go back and compress it.

## 4. Set up the base presentation

Confirm `python-pptx` is importable first (`python3 -c "import pptx"`) — this is required whether or not a template was given; if it fails, tell the user to `pip install python-pptx` and stop rather than attempting generation without it.

If a template was given it must be a `.pptx` file — if the path doesn't end in `.pptx`, say so and stop rather than guessing what was meant.

- **With `--template`:** open the template itself as the base presentation (`Presentation('<template>')`), not a blank one — this carries over its slide master, theme, fonts, colors, and any header/footer/logo placeholders already defined there. Enumerate `prs.slide_layouts` to see what layouts the template actually offers, and pick the closest matching layout for each planned slide (title layout for the opening slide, a title+content layout for body slides, etc.) rather than assuming layout indices from a different template. If the template file itself contains sample/demo slides beyond its layouts, don't carry those into the output — only reuse the master/layout definitions, add your own slides on top.
- **Without `--template`:** build on a blank `Presentation()`, but still commit to one consistent look across every slide — a single font family, one accent color, consistent title placement and bullet indentation. Pick sensible neutral defaults; don't invent a "brand" that wasn't asked for.

## 5. Generate the deck

Write a Python script (using `python-pptx`) that builds the deck per your outline, then run it with `python3`. For each planned slide:

- Set the title placeholder text.
- Fill body/content placeholders with the planned bullets.
- For a planned table: add a real table shape and populate it with the actual extracted rows/columns — no placeholder or dummy rows.
- For a planned chart: add a chart shape (`python-pptx` chart module) using only the actual extracted numeric series — if the source doesn't have enough real numbers for a chart, use a table or bullets instead rather than padding a chart with invented values.
- For a planned timeline/flow diagram: `python-pptx` has no native diagram type, so represent it as a simple row or column of styled text boxes/shapes showing the sequence — keep it plain rather than attempting a complex SmartArt-style visual it can't actually produce.

Save the file alongside the content file, named `<content-file-basename>.pptx` — if a file with that exact name already exists, use `<content-file-basename>-deck.pptx` instead so nothing gets silently overwritten. If the user gave a different output location in their prompt, honor that instead.

## 6. Report back

State: the saved file path, the final slide count, and one line per slide summarizing its content. Confirm explicitly that every fact/figure in the deck traces back to the source file, and list anything left as **TBD** or any slide dropped for lack of source material. If the `.docx` fallback in step 1 lost some structure, mention that too.
