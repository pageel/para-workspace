# para-graph Skill — Reference

> **Version**: 2.3.0

## Overview

**para-graph** is the Centralized Graph Intelligence Router for PARA Workspace. It provides the standardized graph enrichment workflow, memory curation workflow, and workflow integration snippets for `/plan`, `/docs`, `/brainstorm`, and `/spec`.

## Triggers

Trigger | Example
:---|:---
Mentions of code graph | "enrich graph", "analyze code graph"
Executing workflows | `/plan`, `/docs`, `/brainstorm`, `/spec`
Memory curation | "curate memory", "push memory"

## Enrichment Workflow

1. **Query Graph**: Use `graph_query` to list nodes or filter by type/name.
2. **Identify Important Nodes**: Use `graph_god_nodes` to find the most connected nodes.
3. **Read Source Code**: Read implementation using `view_file` to understand node logic.
4. **Write Enrichment**: Use `graph_enrich` to write semantic metadata (`summary`, `complexity`, `domainConcepts`).
5. **Agentic Edge Resolution**: Inject missing relationships (especially for weekly typed languages like Bash or dynamic binding frameworks) using `graph_add_edges`.

## Memory Workflow (Compact Memory)

- **Push Raw Memory**: Use `memory_push` for important decisions or rules (Lossless Restatement).
- **Retrieve Context**: Use `memory_search` to query existing memories.
- **Curate Memory**: Use `memory_curate` to summarize and cluster related slices.

## Workflow Integration Router

Graph intelligence is integrated into these workflows:
- **/plan**: Phase 0 Architecture Context Gathering.
- **/docs**: Content Enrichment Pipeline.
- **/brainstorm**: Codebase Understanding.
- **/spec**: Requirements Traceability.

If the graph is unavailable, the Agent gracefully falls back to source-only context (using standard native/bash search tools).

## Sync

Location | Role | Updated by
:---|:---|:---
`repo/templates/common/agents/skills/para-graph/` | Source of Truth | Developer (git push)
`Resources/ai-agents/skills/para-graph/` | Read-only (I9) | `para install` / `update`
`.agents/skills/para-graph/` | Active copy | `para install` / `update`

---

_See also: [PARA Kit Skill](./para-kit.md) · [Full SKILL.md](../../templates/common/agents/skills/para-graph/SKILL.md)_
