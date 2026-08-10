# doc-generation-toolkit

Generates shareable documents from source material.

## What's inside

- **Command: `/mom <file>`** — reads a meeting transcript (`.docx`, `.pdf`, or `.txt`), extracts discussion points, decisions, action items (with owner/due date), blockers, and next steps, and outputs a clean Markdown MoM ready to share. Never invents an owner or deadline that isn't in the transcript — marks it **TBD** instead.
- **Command: `/create-pptx <content-file> [--template <template-file>]`** — reads a content file (`.docx`, `.pdf`, `.txt`, or `.md`), plans a slide outline, and generates a `.pptx` deck via `python-pptx`. If a `--template` `.pptx` is given, its slide master/layouts (fonts, colors, header/footer, logo, positioning) are reused as the design base for every slide. Never copies large paragraphs verbatim, never invents facts/metrics — only restructures what's actually in the source.

## Setup prerequisites

- **`/mom`** — `.txt`/`.pdf` transcripts work with no extra setup; `.docx` needs `pandoc` (preferred), `python-docx`, or `unzip` on `PATH` for text extraction.
- **`/create-pptx`** — requires `python3` with the `python-pptx` package installed (`pip install python-pptx`). `.docx` content files use the same extraction chain as `/mom` above; `.txt`/`.md`/`.pdf` need no extra setup. A `--template` file must itself be a `.pptx`.

## Usage

```
/mom transcripts/2026-08-10-standup.txt
/mom "Q3 Planning Call.docx"

/create-pptx project-summary.docx
/create-pptx notes/kickoff.pdf --template branding/header-footer-template.pptx
```
