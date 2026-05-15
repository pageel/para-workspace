# Para-Graph MCP Integration Reference

> **Version:** 1.0.0
> **Last reviewed:** 2026-05-15
> **Project:** para-workspace
> **Scope:** Cross-cutting reference — how para-graph MCP tools are consumed by catalog artifacts

---

## Overview

The `para-graph` MCP server provides 11 tools for code-knowledge graph operations and persistent memory management. These tools are integrated across the PARA Workspace ecosystem to provide architectural intelligence, cross-session memory, and codebase-aware decision-making.

This document maps every tool to every **catalog-governed** workspace artifact (workflow, skill, rule) as defined in `VERSIONS.yml`.

---

## Tool Catalog (11 Tools)

### Graph Tools (8)

| # | Tool | Purpose | Category |
|:--|:--|:--|:--|
| 1 | `graph_query` | Query graph nodes with filters (type, name pattern) | Discovery |
| 2 | `graph_god_nodes` | Find most connected nodes — architectural hot spots | Discovery |
| 3 | `graph_context_bundle` | Get comprehensive context: source + callers + callees + tests | Deep Analysis |
| 4 | `graph_edges` | Get all edges (CALLS, IMPORTS_FROM) connected to a node | Dependency |
| 5 | `graph_impact_analysis` | Analyze upstream/downstream affected nodes for a change | Impact |
| 6 | `graph_expand_node` | Get only source code for a specific node | Read |
| 7 | `graph_enrich` | Write semantic enrichment (summary, complexity, concepts) | Maintenance |
| 8 | `graph_add_edges` | Batch inject edges for weak AST languages (Bash) | Maintenance |

### Memory Tools (3)

| # | Tool | Purpose | Category |
|:--|:--|:--|:--|
| 9 | `memory_search` | Search past decisions, patterns, and friction points | Retrieval |
| 10 | `memory_push` | Persist events (decisions, summaries, insights) to project memory | Write |
| 11 | `memory_curate` | Consolidate raw memory events into semantic slices | Maintenance |

---

## Master Integration Matrix

### Catalog Workflows (13 of 30 in VERSIONS.yml)

| Tool | brainstorm | plan | spec | docs | end | open | qa | retro | verify | logs | learn |
|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|
| `graph_query` | ✅ §2 | ✅ §0.5 | ✅ §0.5 | ✅ §0.5 | — | — | ✅ §0.5 | — | — | — | — |
| `graph_god_nodes` | ✅ §2 | ✅ §0.5 | ✅ §0.5 | ✅ §0.5 | — | — | ✅ §0.5 | — | — | — | — |
| `graph_context_bundle` | ✅ §2,3 | ✅ §0.5 | ✅ §0.5 | ✅ §0.5 | — | — | ✅ §0.5 | — | — | — | — |
| `graph_edges` | ✅ §2 | ✅ §0.5 | ✅ §0.5 | ✅ §0.5 | — | — | — | — | — | — | — |
| `graph_impact_analysis` | ✅ §2 | ✅ §0.5 | ✅ §0.5 | ✅ §0.5 | — | — | ✅ §0.5 | — | ✅ §2.5 | — | — |
| `graph_expand_node` | — | — | — | — | — | — | — | — | — | — | — |
| `graph_enrich` | — | ✅ §0.5 | — | — | — | — | ✅ §0.5 | — | — | — | — |
| `graph_add_edges` | — | — | — | — | — | — | — | — | — | — | — |
| `memory_search` | ✅ §2,3 | ✅ §2.5 | ✅ §1 | ✅ §2 | ✅ §4.8 | ✅ §3.6 | ✅ §0 | ✅ §0 | — | ✅ §3 | — |
| `memory_push` | ✅ §2,4.5 | ✅ §11.5 | ✅ §11.5 | ✅ §8.5 | ✅ §4.8 | — | ✅ §10.5 | ✅ §5.5 | — | — | ✅ §4.3 |
| `memory_curate` | ✅ §4.5 | ✅ §11.5 | ✅ §11.5 | ✅ §8.5 | ✅ §4.8 | — | ✅ §10.5 | ✅ §5.5 | — | — | — |
| **Total** | **8** | **9** | **8** | **8** | **3** | **1** | **8** | **3** | **1** | **1** | **1** |

#### Catalog workflows without para-graph reference (17)

`backlog`, `backup`, `config`, `inbox`, `install`, `merge`, `new-project`, `para`, `para-audit`, `para-knowledge`, `para-rule`, `para-skill`, `para-workflow`, `push`, `release`, `update`, `write`

> **Note:** `/open` reads `.beads/graph/memory-slices.jsonl` AND calls `memory_search` via MCP for active cross-session context injection at session start.

### Catalog Skills (4 of 13 in VERSIONS.yml)

| Tool | plan | docs | brainstorm | harness |
|:--|:--|:--|:--|:--|
| `graph_query` | — | — | — | — |
| `graph_god_nodes` | — | — | — | — |
| `graph_context_bundle` | — | — | — | ✅ |
| `graph_edges` | — | — | — | — |
| `graph_impact_analysis` | — | — | — | — |
| `graph_expand_node` | — | — | — | — |
| `graph_enrich` | — | — | — | — |
| `graph_add_edges` | — | — | — | — |
| `memory_search` | — | — | — | — |
| `memory_push` | — | — | — | — |
| `memory_curate` | — | — | — | — |
| **Total** | **0** | **0** | **0** | **1** |

> **Note:** `plan`, `docs`, `brainstorm` skills are sidecar data (templates). Graph integration logic lives in their parent workflows, not in the skill files themselves. The `spec` and `qa` skills contain graph router sections but reference tools indirectly.

#### Catalog skills without para-graph reference (9)

`para-kit`, `formatting`, `page-map`, `para-skill`, `write`, `spec`, `qa`, `tdd`, `logs`

### Catalog Rules (0 of 11 in VERSIONS.yml)

No catalog-governed rules directly reference para-graph MCP tool names.

> **Note:** Graph-related rules (`graph-first-policy`, `tool-routing`) exist in the workspace but are **user-created** (not in `VERSIONS.yml`). They are excluded from this catalog report.

---

## Per-Tool Deep Dive

### `graph_query` — 5 catalog workflows

The most widely used discovery tool. Used as the entry point in every graph pipeline to locate relevant nodes before deep analysis.

**Pattern:** Always called first in a graph pipeline → results feed into `context_bundle` and `impact_analysis`.

### `graph_god_nodes` — 5 catalog workflows

Identifies architectural hot spots (most connected nodes). Critical for risk assessment in planning and brainstorming.

**Pattern:** Called alongside `graph_query` in discovery phase → results inform which nodes to analyze deeply.

### `graph_context_bundle` — 5 catalog workflows, 1 catalog skill

The "all-in-one" deep analysis tool. Returns source code + callers + callees + tests in a single call, replacing multiple `view_file` calls.

**Pattern:** Called on specific nodes identified by `graph_query`/`graph_god_nodes` → used to verify architectural feasibility.

### `graph_impact_analysis` — 6 catalog workflows

Maps upstream/downstream blast radius. Essential for scope definition (spec), risk assessment (plan), architecture documentation (docs), and verification coverage (verify).

**Pattern:** Called on target nodes before making change decisions → results inform risk sections and boundary definitions.

### `graph_edges` — 4 catalog workflows

Verifies dependency assumptions by showing direct CALLS and IMPORTS_FROM relationships.

**Pattern:** Used to validate proposed changes won't break callers → complements `impact_analysis` with precise edge data.

### `graph_enrich` — 2 catalog workflows

Writes semantic metadata (summary, complexity, domain concepts) to graph nodes. Maintenance-oriented.

**Pattern:** Called after graph analysis to persist human-readable summaries → improves future `graph_query` results.

### `memory_search` — 7 catalog workflows

Cross-session knowledge retrieval. Prevents re-debating resolved decisions and re-discovering known patterns.

**Pattern:** Called early in workflow (before main action) → results ground the session in prior knowledge.

### `memory_push` — 7 catalog workflows

Persists decisions, summaries, and insights for future sessions.

**Pattern:** Called at workflow completion → captures session outcomes for future `memory_search`.

### `memory_curate` — 6 catalog workflows

Consolidates raw memory events into semantic slices. Runs automatically after `memory_push`.

**Pattern:** Always called after `memory_push` → keeps memory store clean and queryable.

### `graph_expand_node` — 0 catalog references

**Status:** Unused across all catalog artifacts. Redundant with `graph_context_bundle` which includes source code.

**Recommendation:** Keep in tool catalog for edge cases where only source code is needed without caller/callee overhead.

### `graph_add_edges` — 0 catalog references

**Status:** Not referenced in any catalog artifact. Specialized for languages with weak AST linking (Bash).

**Recommendation:** Keep as-is. Not suitable for general workflow integration.

---

## Workflow Activation Pattern

All graph-aware catalog workflows follow a consistent activation pattern:

```
┌─────────────────────────────────────────────┐
│  Pre-flight (Step 0)                        │
│  ├── Load Project Sidecar Skill             │
│  ├── Load Workspace Indices                 │
│  └── Load Project Indices                   │
├─────────────────────────────────────────────┤
│  Graph Pipeline (Step 0.5, if --graph)      │
│  ├── 1. Build Graph                         │
│  ├── 2. Discovery: graph_query + god_nodes  │
│  ├── 3. Deep: context_bundle + edges        │
│  ├── 4. Impact: impact_analysis             │
│  └── 5. Inject into session context         │
├─────────────────────────────────────────────┤
│  Context Gathering (Step 1+)                │
│  ├── memory_search (past decisions)         │
│  └── Project-specific context               │
├─────────────────────────────────────────────┤
│  Main Workflow Logic                        │
│  └── (varies per workflow)                  │
├─────────────────────────────────────────────┤
│  Memory Persistence (Final Step)            │
│  ├── memory_push (session outcomes)         │
│  └── memory_curate (auto-consolidate)       │
└─────────────────────────────────────────────┘
```

---

## Coverage Summary

| Category | Catalog Total | With para-graph | Coverage |
|:--|:--|:--|:--|
| Workflows | 30 | 13 | 43% |
| Skills | 13 | 1 | 8% |
| Rules | 11 | 0 | 0% |

> **Design intent:** para-graph integration is concentrated in **knowledge-producing workflows** (brainstorm, plan, spec, docs, qa) and **session lifecycle** (end). Administrative workflows (backlog, push, config) don't need graph intelligence.

---

_Updated: 2026-05-15_
