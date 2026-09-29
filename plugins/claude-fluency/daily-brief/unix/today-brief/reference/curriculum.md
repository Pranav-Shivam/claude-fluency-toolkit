# Deep-dive curriculum (file 03)

Pick one topic per run. Selection order:
1. The reader's requested focus, if any (match it to the closest topic below).
2. The topic most affected by a Confirmed item in today's news.
3. The least recently covered topic, judged from the Handoff blocks.
Never repeat a topic within 10 runs unless the reader asks. A follow-up run may go deeper on a sub-topic of an earlier one if the reader's notes ask for it.

## Topics
1. Agent loop and harness design: control flow, stop conditions, step budgets, state between steps
2. Tool interface design and MCP: contracts, idempotency, permissions, error shapes, versioning
3. Memory architecture: working, episodic, semantic, procedural tiers, write policy, forgetting, governance
4. RAG retrieval architecture: chunking, hybrid search, reranking, freshness, permission-aware retrieval
5. GraphRAG, knowledge graphs and ontologies: when a graph beats vectors, build cost, update strategy
6. Context engineering: budgeting, compaction, prompt caching, ordering, long-context vs retrieval
7. Orchestration patterns: single agent vs multi-agent, planner-executor-reviewer, handoffs, fan-out
8. Evals: datasets, LLM-as-judge calibration, regression gates, online vs offline, trajectory evals
9. LLMOps release loop: prompt and model versioning, canary, rollback, model migration, drift
10. Guardrails and security: prompt injection, tool-call-layer policy, least privilege, sandboxing, data exfiltration paths
11. Observability: trace design, span schema, cost attribution, replay, debugging non-determinism
12. Cost and latency engineering: model routing and cascades, caching, batching, token budgets, streaming
13. Human-in-the-loop design: approval gates, escalation, confidence thresholds, audit trails
14. Reliability: retries, idempotency, durable execution, queues, timeouts, partial failure
15. Document extraction pipelines: parsing, structured output, validation, fallbacks, human review queues
16. Multi-tenancy, isolation and governance for enterprise deployments
17. Model selection, fine-tuning and distillation: decision framework, when not to fine-tune
18. Long-running and background agents: persistence, resumability, scheduling, notifications
19. Enterprise system integration: ERP, CRM and quoting systems, connectors, schema drift, sync vs event
20. Data architecture for AI: OLTP and OLAP split, feature and vector stores, lineage, freshness
21. Deployment topology on Kubernetes: GPU vs API, autoscaling, gateways, secrets, network policy
22. Agent UX and failure communication: partial results, explanations, correction loops

## Depth
Write as a design review, not a tutorial. The reader should finish able to whiteboard the design, defend three trade-offs, and name the top failure modes. Include one applied scenario: an enterprise quote/estimate automation workflow (PDF and email intake, extraction, pricing rules, approval, ERP write-back). Label assumed numbers as assumptions and keep client names out.
