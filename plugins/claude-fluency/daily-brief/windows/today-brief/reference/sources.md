# Sources and trust tiers

Search for what changed in the last 48 hours. Fetch the primary page, do not rely on snippets.

## Tier 1: primary (can support "Confirmed")
- Vendor engineering blogs, release notes and changelogs: Anthropic (news, engineering, docs release notes, Claude Code changelog), OpenAI, Google DeepMind and Google Cloud, Meta AI, Microsoft, AWS Machine Learning blog, NVIDIA.
- Specs and protocol repos: Model Context Protocol spec and changelog, OpenTelemetry GenAI semantic conventions, A2A and agent protocol repos.
- Framework and infra release pages on GitHub: LangGraph, LlamaIndex, vLLM, SGLang, Ollama, pgvector, Qdrant, Temporal, Kubernetes.
- Papers: arXiv (cs.AI, cs.CL, cs.SE, cs.IR), conference pages. Use the abstract plus the method and evaluation sections, not the press coverage.

## Tier 2: practitioners (can support "Reported", and good for framing)
- Simon Willison, Latent Space, Hamel Husain, Eugene Yan, Chip Huyen, Lilian Weng, The Pragmatic Engineer, Martin Fowler, InfoQ, Thoughtworks Technology Radar.
- Hacker News front page and top comments, for community reaction and counterarguments, never as the source of a fact.

## Tier 3: aggregators and marketing (context only, never the sole source)
- Newsletters that rewrite other people's news, SEO explainers, vendor comparison pages, "top 10" lists.

## Query habits
- One query per topic, 3 to 6 words, add the month and year for news.
- Suggested daily sweep (run in parallel): new model or API releases, agent framework and MCP updates, evals and observability tooling, security incidents involving agents or prompt injection, one infrastructure or data architecture item, one notable paper.
- When a claim is surprising, find the primary source or mark it Unverified.
- If two sources disagree, show both and say which you trust and why.
