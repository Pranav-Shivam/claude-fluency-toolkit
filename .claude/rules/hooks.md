---
paths:
  - "plugins/claude-fluency/hooks/**"
  - "plugins/claude-fluency/scripts/**"
---

# Hook and script conventions

Any change here needs a careful read, not a quick edit — `PreToolUse` fires on every Bash call, so slow or wrong logic there taxes (or breaks) every command in the session.

Protocol, undocumented anywhere but the scripts themselves: hook JSON payload arrives on **stdin**; `jq` parses it with a regex fallback if `jq` is missing; exit code `2` blocks with a message on stderr; exit `0` passes. Prefer shell + `jq` over spawning another interpreter — same performance reasoning.

`SessionStart` output is printed into every session's context unconditionally — keep it to a handful of lines. If you need to teach the user something longer (a command reference, a new toolkit), print one pointer line to a doc, don't inline the doc itself.

Exception: the 5 numbered engineering-principles rules are inlined here on purpose, not just pointed to — they're the one thing in this plugin required to reach every session unconditionally, and a Skill can't guarantee that (Skills load only when Claude judges them contextually relevant). Don't "clean this up" into a pointer line; that would silently undo the guarantee it exists to provide. The full framework (tests, rationale, failure modes) stays in the `engineering-principles` skill — only the non-negotiable core is duplicated here.
