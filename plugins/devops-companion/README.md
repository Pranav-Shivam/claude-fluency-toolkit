# devops-companion

Knowledge-graph navigation and Azure DevOps PR review/comment skills.

## What's inside

- **Skill: `graphify`** — defines the interface and expected output (`GRAPH_REPORT.md`, an HTML visualization, a JSON export) for turning a codebase into a knowledge graph with community detection. **The actual graph-building engine is not included** — this skill specifies the contract (scan → extract relationships → detect communities → identify hubs → emit outputs); plug in your own AST/static-analysis tooling or graph library to satisfy it.
- **Skill: `pr-review`** — end-to-end PR review: layered walkthrough, health score, severity-graded findings with fix prompts. Shows results in chat first; posts nothing until confirmed.
- **Skill: `pr-comments`** — fetches and groups PR comment threads (inline by file/line, PR-level separately), filtering system noise.

## Setup prerequisites

- **`pr-review` and `pr-comments`** are written generically but include an "Azure DevOps" section with the actual REST/CLI calls, since that's the platform this plugin was drafted against. Using them against a real PR requires an Azure DevOps Personal Access Token (`Code (Read)` for comments, `Code (Read & Write)` for posting review output) or an authenticated `az devops` CLI. **No credentials or org config are included** — set these up yourself.
- If you're on a different PR platform (GitHub, GitLab, Bitbucket), the workflow sections of both skills are platform-agnostic — swap the Azure DevOps section for the equivalent API calls on your platform.
- **`graphify`** has no external dependency by itself, but produces nothing useful until you connect it to a real graph-building implementation (see the skill's implementation note).
