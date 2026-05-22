# Graph-First Investigation Policy

> **Version**: 1.8.10

Enforces that agents must prioritize code analysis using `para-graph` MCP tools before performing direct file I/O operations or assuming architecture flow.

## Scope

- **Type**: Global (all projects with graph data)
- **Priority**: 🔴 Critical
- **Trigger**: Investigative tasks ("fix bug", "trace flow", "analyze code", "understand architecture"), planning in `/plan create`, `/brainstorm`, or `/spec` when `.beads/graph/` exists

## Precondition

- The rule applies only when `.beads/graph/metadata.json` exists for the active project.
- If no graph data exists, the Agent should suggest running `/para-graph build` first.

## Rules

### 1. Escalation Ladder (Graph → File → Search)

Agent MUST follow this priority order when investigating code:

| Priority | Tool | When to use |
|:--|:--|:--|
| 🥇 1st | `graph_query` + `graph_edges` | Locate entities, map dependencies, understand call graph |
| 🥈 2nd | `graph_context_bundle` | Get full context (source + callers + callees + tests) for a specific entity |
| 🥉 3rd | `view_file` | Read exact implementation AFTER graph has identified the target |
| 4th | `grep_search` | Only when entity is not in graph (new/unindexed code) |

### 2. Mandatory Graph Querying

- Must use `graph_query` to locate target components or functions first.
- Must use `graph_edges` to analyze caller/callee relationships.
- Should use `graph_impact_analysis` before refactoring to understand blast radius.

### 3. Transparency

- Must mention the graph edges or nodes found in the reasoning before calling `replace_file_content`.
- Must explicitly state in the response that `para-graph` was utilized to map connections before applying any fix.

### 4. Graceful Degradation

- If the MCP server is unavailable or graph data is stale (> 7 days), Agent may fall back to standard file I/O with a warning.
- Agent should suggest running `/para-graph build` to refresh the graph after the task is complete.

## Related

- [para-graph Skill](../skills/para-graph.md)
- **Source**: `templates/common/agents/rules/graph-first-policy.md`
