---
name: graphify
description: Builds a knowledge graph (HTML + JSON + report) from a codebase folder, with community detection, so large codebases can be navigated by structure instead of raw grep.
---

# Graphify

Turns a folder of code (or docs, or any structured text) into a navigable knowledge graph: nodes for meaningful entities (files, functions, classes, modules — whatever unit fits the input), edges for real relationships between them (imports, calls, references, inheritance), and clusters for communities of related nodes so the graph reads as a map, not a hairball.

**Implementation note:** this skill defines the interface and expected output shape — it does not include a graph-building engine. Wire it up to your own static-analysis/AST tooling, a call-graph extractor, or an LLM-driven relationship extractor, depending on what fits your stack. Treat the workflow below as the contract to satisfy, not literal code to run as-is.

## Workflow

1. **Scan.** Walk the target folder and enumerate the units that will become nodes. For code, this is usually one node per file plus one node per top-level function/class/module; for docs, one node per document or section.
2. **Extract relationships.** For each node, find its real edges to other nodes — imports, function calls, class inheritance, references to another doc/section. Prefer static analysis (AST parsing, import resolution) over text search where the language tooling supports it; fall back to reference-pattern matching where it doesn't.
3. **Detect communities.** Run a community-detection pass (e.g. Louvain or a similar modularity-based method) over the edge graph to group nodes into clusters that are more internally connected than externally connected. Label each cluster with a short, human-readable name based on its dominant nodes.
4. **Identify hub nodes.** Rank nodes by edge count. Nodes with disproportionately high edge counts ("god nodes") are worth calling out explicitly — they're usually the places where a change has the widest blast radius.
5. **Emit outputs:**
   - `GRAPH_REPORT.md` — a human-readable summary: node/edge counts, the list of detected communities with their member nodes, the top hub nodes and their edge counts, and any structural observations (isolated nodes, unusually dense clusters, cross-community edges that look like layering violations).
   - An HTML visualization — an interactive node/edge graph, colored by community, that can be opened directly in a browser.
   - A JSON export — the raw graph as `nodes` (stable id, source path, kind, community id, edge count) and `edges` (source id, target id, relationship kind), so runs can be diffed against each other or consumed by other tooling. Keep node ids stable across runs — derive them from the source path plus symbol name, not from iteration order — or diffing between runs is meaningless.
6. **Support incremental updates.** Re-running against a folder that changed only slightly should be cheaper than a full rebuild. Use the previous JSON export as the cache: compare file hashes or mtimes to find changed files, drop and recompute the nodes and outgoing edges for those files only, then merge back into the cached graph. Community detection and hub ranking are global properties, so re-run those over the merged graph rather than trying to patch them. Fall back to a full rebuild when there's no prior export, when the analysis tooling can't scope to a file subset, or when the changed set is large enough that the merge costs more than a rescan.

## When to use this over grep

Grep finds text matches. It doesn't tell you which files are structurally central, which modules cluster together, or what the blast radius of a change to one file actually is. Reach for the graph when a question is about *structure* — "what depends on this," "what's the architecture here," "where would this change ripple" — and reach for grep when the question is about a specific string or symbol you already know the name of.
