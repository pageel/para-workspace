---
description: Heuristic guide for AI Agent tool selection — native, bash, and MCP tools
trigger: always_on
glob:
---

<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->

# Tool Routing

> **Workspace Version:** 1.8.4

Heuristic guide for AI Agent tool selection across three tool layers: Native API, Bash commands, and MCP servers. This is a **recommendation**, not a prohibition.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. Three-Layer Tool Model

Agent has access to three categories of tools, each with distinct strengths:

| Layer | Tools | Strength | Weakness |
|:--|:--|:--|:--|
| **Native API** | `view_file`, `list_dir`, `grep_search`, `replace_file_content`, `write_to_file` | Structured output, conflict detection, platform-auditable | Single-file scope, no composition |
| **Bash** | `run_command` (`grep`, `cat`, `ls`, `git`, `find`, etc.) | Pipeline composition, batch operations, OS-level access | Unstructured output, no edit safety |
| **MCP** | `mcp_*` tools from connected MCP servers | Domain-specific intelligence, semantic context, cross-entity reasoning | Requires server availability, data freshness |

### 2. Routing Priority — Specificity Wins

When multiple tools can accomplish the same task, **prefer the most specific tool**:

```
MCP (domain-specific) → Native API (structured) → Bash (general-purpose)
```

**Rationale:** A domain-specific MCP tool (e.g., `graph_query` for code analysis) provides richer context than a generic `grep_search`, which in turn provides better structure than a raw `grep` command.

**Exception:** When composing 3+ operations into a single pipeline, Bash wins regardless of specificity (token optimization).

### 3. Native Tools — Use for File Manipulation

**SHOULD** use native API tools when:

- Reading a file to **understand or edit** its content (syntax awareness, line numbers)
- Listing a directory for **structured output** (file size, type)
- Searching for a pattern when you need **precise line matches** with context
- Editing or creating files (native tools have built-in conflict detection)

**Rationale:** Native tools provide structured JSON output, are auditable by the platform, and have better error handling.

### 4. Bash Commands — Use for Batch & OS Operations

**SHOULD** use `run_command` with bash when:

- **Batching multiple commands** into a single script to reduce tool call count (token optimization)
- Pipeline composition: `grep ... | head -n 5`, `ls -t ... | head -3`
- Operations that native tools cannot express: `git status`, `stat`, `find`, `wc`
- Workflow steps tagged `// turbo` — these are designed to auto-run as bash

**Rationale:** Bash piping and composition reduce tool call overhead by 30-50%. Workflows use bash by design for batch context gathering.

### 5. MCP Tools — Use for Domain-Specific Intelligence

**SHOULD** use MCP tools when:

- A connected MCP server provides **specialized operations** for the task domain
- The task requires **cross-entity reasoning** (e.g., dependency analysis, impact assessment, semantic search)
- Native/Bash tools would require **multiple calls** to reconstruct context that one MCP call provides
- The MCP tool returns **enriched data** (summaries, relationships, metadata) beyond raw file content

**MUST** check MCP tool availability before falling back to generic tools for domain tasks.

**Rationale:** MCP tools encapsulate domain logic (code graphs, CMS operations, cloud APIs) that would otherwise require multi-step manual reconstruction.

### 6. Decision Matrix

| Scenario | Recommended Tool | Rationale |
|:--|:--|:--|
| Read 1 file to understand code | `view_file` | Line numbers, syntax context |
| Read 5+ files to gather context quickly | `run_command` (bash) | 1 tool call instead of 5 |
| Find a specific pattern | `grep_search` | Structured JSON output |
| Compose grep + head + cat pipeline | `run_command` (bash) | Pipeline composition |
| List directory contents | `list_dir` | Structured (size, type) |
| List files sorted by time | `run_command` (`ls -t`) | list_dir does not support time sorting |
| Edit a file | `replace_file_content` | Conflict detection, diff output |
| Create a new file | `write_to_file` | Platform tracking |
| Git operations | `run_command` | No native git tool available |
| Read file in workflow `// turbo` step | `run_command` (bash) | By design — auto-run safe |
| Trace code dependencies | MCP `graph_edges` | Semantic cross-file relationships |
| Analyze impact of a change | MCP `graph_impact_analysis` | Upstream/downstream traversal |
| Get entity context + callers | MCP `graph_context_bundle` | All-in-one vs 5+ view_file calls |
| Query code entities by name | MCP `graph_query` | Structured node search vs grep guessing |

### 7. MCP Availability Guard

Before using MCP tools, Agent **SHOULD** verify:

1. **Server connected:** The MCP server is listed in active connections
2. **Data exists:** Required data files exist (e.g., `.beads/graph/metadata.json` for para-graph)
3. **Data freshness:** Data is not stale (project-specific rules may define staleness thresholds)

If any check fails → fall back to Native/Bash with a warning to the user suggesting how to set up or refresh the MCP data.

### 8. Anti-Pattern — Absolute Prohibition

**MUST NOT** create rules that absolutely prohibit bash commands (`ls`, `cat`, `grep`). Reasons:

- PARA workflows use bash **by design** for batch operations
- Prohibition breaks performance of `/open`, `/end`, `/brainstorm` (increases latency 3-4x)
- The correct principle is **heuristic routing**, not prohibition

> **Context:** Discovered in [cross-agent-telemetry-review (2026-04-14)](../../docs/researches/process/research-cross-agent-telemetry-review-2026-04-14.md) §5.7 — Agent confabulated "CRITICAL INSTRUCTION 1" absolutely prohibiting bash, leading to incorrect narrative.

### 9. CLI Commands vs Platform Workflows Boundary

To prevent system conflicts and execution errors, Agent **MUST** maintain a strict boundary between Terminal CLI Commands and Platform Workflows (Slash Commands):

- **Slash Commands (Workflows)**: Platform-specific commands starting with a slash `/` (e.g., `/open`, `/plan`, `/staging`, `/brainstorm`).
  - **Environment**: Executed exclusively via the chat UI/interaction interface.
  - **Constraint**: **MUST NOT** be executed as terminal scripts. Recommendation to the user must use the slash format (e.g., "Use `/staging`...").
- **CLI Commands (Terminal)**: Local command-line interface scripts starting with `./para` (e.g., `./para status`, `./para update`, `./para install`).
  - **Environment**: Executed exclusively inside the terminal shell using `run_command`.
  - **Constraint**: **MUST NOT** run workflows via the CLI script (e.g., executing `./para staging`, `./para open`, `./para brainstorm` via terminal is strictly prohibited and will trigger a CLI guard error).

## Related

- [Antigravity System Prompt Analysis](../../docs/researches/analysis/research-antigravity-system-prompt-2026-04-14.md) — Recommendation #1
- [cross-agent-telemetry-review](../../docs/researches/process/research-cross-agent-telemetry-review-2026-04-14.md) — Original case study
