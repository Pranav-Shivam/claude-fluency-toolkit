# Templates — `/prompt-master`

Load one template. Never the whole file.

| Template | Use for |
|---|---|
| A — RTF | Simple one-shot tasks |
| B — CO-STAR | Business writing, documents, marketing |
| C — RISEN | Multi-step projects with a sequence |
| D — CRISPE | Creative work, brand voice |
| E — Few-shot | Format-sensitive output |
| F — File scope | Cursor, Windsurf, Copilot, Cline |
| G — Agent brief | Claude Code, Devin, autonomous agents |
| H — Visual | Midjourney, DALL-E, SD, Sora, Runway |
| I — Image edit | Modifying an existing image |
| J — ComfyUI | Node-based image workflows |
| K — Decompiler | Breaking down, adapting, or splitting an existing prompt |

---

## A — RTF

```
Role: [who the AI is, one sentence]
Task: [precise verb + what to produce]
Format: [exact shape and length]
```

## B — CO-STAR

```
Context: [background needed to understand the situation]
Objective: [the goal, what success looks like]
Style: [formal / conversational / technical / narrative]
Tone: [authoritative / empathetic / urgent / neutral]
Audience: [who reads it, their level]
Response: [format, length, structure]
```

## C — RISEN

```
Role: [expert identity]
Instructions: [the task in plain terms]
Steps:
  1. [first action]
  2. [second action]
End Goal: [what the output must achieve]
Narrowing: [scope limits, what to exclude]
```

## D — CRISPE

```
Capacity: [expertise required]
Role: [persona]
Insight: [background insight shaping the response]
Statement: [the task]
Personality: [tone and style]
Experiment: [ask for N variants]
```

## E — Few-shot

```
[Task instruction]

<examples>
  <example><input>[in 1]</input><output>[out 1]</output></example>
  <example><input>[in 2]</input><output>[out 2]</output></example>
</examples>

Apply this exact pattern to: [actual input]
```

2 to 5 examples. Include an edge case, not just easy ones. Switch to few-shot after correcting the same formatting issue twice.

## F — File scope

```
File: [exact/path/to/file.ext]
Function: [exact name]

Current behavior: [what it does now]
Desired change: [what it should do]

Scope: only modify [function/section]. Do NOT touch: [list]
Constraints: [language and version, no new dependencies, preserve type signatures]
Done when: [exact condition confirming success]
```

## G — Agent brief

```
## Objective
[One sentence. Add why if it affects approach.]

## Context
[What exists now: files, current behavior, stack, what was tried and failed]

## Target state
[What done looks like. Binary where possible.]

## Scope
Work only in: [files and directories]
Do NOT touch: [.env, lockfiles, configs, anything outside scope]

## Constraints
[Stack version, conventions, no new dependencies without asking]
Only make changes directly requested. No extra features, abstractions, or files.

## Acceptance criteria
- [ ] [binary check]
- [ ] [binary check]

## Stop conditions
Stop and ask before: deleting any file, adding any dependency, changing schema or migrations, touching anything outside Scope, or after two failed attempts at the same error.

## Progress
After each step output: done — [what] — [files affected]
```

Optional session strategy block for Claude Code: new session / continue / subagent for file-heavy research / compact first.

## H — Visual

```
Subject: [specific, not vague]
Action: [what the subject is doing]
Setting: [where]
Style: [photorealistic / cinematic / anime / vector]
Mood: [dramatic / serene / eerie]
Lighting: [golden hour / studio / neon / overcast]
Palette: [dominant colors]
Composition: [wide / close-up / aerial / Dutch angle]
Aspect ratio: [16:9 / 1:1 / 9:16]
Negative: [blurry, watermark, extra fingers, distortion, text overlay]
```

Midjourney takes comma-separated descriptors with `--ar --style --v` at the end, not prose. Stable Diffusion uses `(word:1.3)` weights, CFG 7 to 12, negative prompt mandatory. DALL-E takes prose, add "no text in the image" unless text is wanted. Video: add camera movement, duration, cut style.

## I — Image edit

Tell the user to attach the reference image before sending. Build the prompt around the delta only.

```
Reference image: [attached]
Keep exactly the same: [everything that must not change]
Change: [the specific edit]
How much: [subtle / moderate / significant]
Style consistency: match the reference's style, lighting, and mood
Negative: [what not to introduce]
```

Midjourney uses `--cref` for character, `--sref` for style. Stable Diffusion needs img2img with denoise 0.3 to 0.6.

## J — ComfyUI

Ask which checkpoint is loaded first. Always output two separate blocks, never merged.

```
POSITIVE: [subject], [style], [mood], [lighting], [composition], [quality terms]
NEGATIVE: [blurry, low quality, watermark, extra limbs, bad anatomy, oversaturated]

CHECKPOINT: [model]
SAMPLER: Euler a
CFG: 7
STEPS: 20-30
RESOLUTION: [divisible by 64]
```

SD 1.5 wants under 75 tokens per block with weight syntax. SDXL handles longer and more natural language. Flux responds well to plain natural language.

## K — Decompiler

Four modes. Detect which one is wanted.

**Break down** — explain what each part does, then list weaknesses, then give a fixed version.

**Adapt** — ask which tool it came from and which it's going to. Output: original, adapted version, then a short list of what changed and why.

**Simplify** — cut redundancy without losing meaning. Show the before and after word count.

**Split** — say how many things the prompt is doing, then output that many sequential prompt blocks with a note on what feeds into what.
