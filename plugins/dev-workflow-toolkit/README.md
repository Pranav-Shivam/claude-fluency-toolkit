# dev-workflow-toolkit

Engineering principles, safety hooks, and commit/PR/learning commands for AI-assisted development.

## What's inside

- **Skill: `engineering-principles`** — five principles (clarify before building, lean code, bounded edits, outcome-oriented execution, verify and recover) plus common failure modes. Loaded automatically as context; no invocation needed.
- **Command: `/git-commit`** — reads the staged diff and drafts a Conventional Commits message. Runs on Haiku, model-invocation disabled (must be explicitly called).
- **Command: `/pr-description`** — diffs against the default branch and drafts a PR description (What changed / Why / Testing).
- **Command: `/learn`** — reviews the session for non-obvious lessons and appends them to `docs/gotchas.md`.
- **Hooks:**
  - `SessionStart` → prints current branch, uncommitted file count, last commit, stash count.
  - `PreToolUse` (matcher: `Bash`) → blocks a fixed set of high-risk shell patterns (`rm -rf` outside temp/build paths, unconfirmed force pushes, `DROP TABLE`/`DROP DATABASE`, `git reset --hard`, `.env` overwrite redirects) before they execute.
  - `Stop` / `TaskCompleted` → cross-platform desktop notification.

## Setup prerequisites

- `jq` on `PATH` — the safety hook uses it to parse the tool-call JSON payload; falls back to a regex extraction if absent, but `jq` is more reliable.
- `bash` (the hook scripts are POSIX-ish bash, not `sh`).
- For notifications: `notify-send` (Linux), AppleScript/`osascript` (macOS — built in), or `powershell.exe` reachable from WSL/Git Bash on Windows.

## Notes

- The force-push block requires a `--yes-i-mean-it` flag literally present in the command to pass through — this is a deliberate friction point, not a real git flag. Adjust the sentinel string in `scripts/pre-tool-safety.sh` if you want different wording.
- The `rm -rf` check allowlists common temp/build directory names (`/tmp`, `node_modules`, `dist`, `build`, `.cache`, `__pycache__`, `.next`, `venv`, `.venv`). Extend the pattern in the script if your stack uses different conventions.
