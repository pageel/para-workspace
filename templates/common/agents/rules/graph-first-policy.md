---
description: Graph-first codebase investigation policy using para-graph MCP tools
trigger: always_on
glob:
---

<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->

# Rule: Graph-First Investigation Policy

> Agent MUST prioritize graph-based code analysis using `para-graph` MCP tools before performing direct file I/O operations or assuming architecture flow.

## Scope

- [x] Global (applies to all projects with graph data)

## Precondition

- Rule ONLY applies when `.beads/graph/metadata.json` exists for the active project.
- If no graph data exists, Agent SHOULD suggest running `/para-graph build` first, then proceed with standard file I/O.

## Triggers

### Investigative (Code)
- When the user asks to "fix bug", "trace flow", "analyze code", "understand architecture", or similar investigative tasks.
- Before making logic edits to any source files that have internal dependencies or imported components.

### Planning & Design (Architecture)
- Before designing architecture in `/plan create` (Step 5: Design Architecture).
- Before analyzing codebase in `/brainstorm` (exploring technical decisions).
- Before surfacing assumptions in `/spec` (defining scope and boundaries).

## Constraints

### 1. Escalation Ladder (Graph → File → Search)

Agent MUST follow this priority order when investigating code:

| Priority | Tool | When to use |
|:--|:--|:--|
| 🥇 1st | `graph_query` + `graph_edges` | Locate entities, map dependencies, understand call graph |
| 🥈 2nd | `graph_context_bundle` | Get full context (source + callers + callees + tests) for a specific entity |
| 🥉 3rd | `view_file` | Read exact implementation AFTER graph has identified the target |
| 4th | `grep_search` | Only when entity is not in graph (new/unindexed code) |

**MUST NOT** skip to `view_file` or `grep_search` if a graph query can answer the question.

### 2. Mandatory Graph Querying

- Agent **MUST** use `graph_query` to locate target components or functions first.
- Agent **MUST** use `graph_edges` to analyze the target's dependencies and dependants (caller/callee relationships).
- Agent **SHOULD** use `graph_impact_analysis` before refactoring to understand blast radius.

### 3. Mandatory Insight & Memory Search

- Before creating a plan (`/plan`), designing a specification (`/spec`), evaluating options (`/brainstorm`), or executing code refactoring/bug fixes (`/vibecode` or general coding), Agent **MUST** run `insight_search` and `memory_search` using keywords related to the affected components and tech stack (e.g., `d1`, `sqlite`, `transaction`, `auth`, `migration`, `sepay`).
- **Purpose:** Search for historically archived lessons (`lesson`), risks (`risk`), decisions (`decision`), gotchas (`gotcha`), and design patterns (`pattern`) to apply or avoid repeating past mistakes.
- Agent **MUST NOT** design new solutions or modify code related to database structures, API routes, or core logic without executing this knowledge query step first.

### 4. Transparency

- Agent **SHOULD** mention the graph edges or nodes found in the reasoning before calling `replace_file_content`.
- Agent **MUST** explicitly state in its response that `para-graph` was utilized to map out connections before applying any fix.

### 5. Graceful Degradation

- If the MCP server is unavailable or graph data is stale (`metadata.json` older than 7 days), Agent **MAY** fall back to standard file I/O with a warning to the user.
- Agent **SHOULD** suggest running `/para-graph build` to refresh the graph after the task is complete.

## Related

- Skill: `para-graph` — Centralized Graph Intelligence Router with enrichment workflow and workflow integration snippets.
- Workflow: `/para-graph build` — Rebuilds the Code-Knowledge Graph for a project.
