# Tool Routing

> **Version**: 1.8.4

Heuristic guide for AI Agent tool selection across Native API, Bash commands, and MCP tools. Ensures safety, structure, and token efficiency.

## Scope

- **Type**: Global (all projects)
- **Priority**: 🟢 Standard
- **Trigger**: Selecting tools during execution (Native API, Bash commands, MCP servers)

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

**Exception:** When composing 3+ operations into a single pipeline, Bash wins regardless of specificity (token optimization).

### 3. Native Tools — Use for File Manipulation

Use native API tools when:
- Reading a file to understand or edit its content.
- Listing a directory for structured output.
- Searching for a pattern when precise line matches with context are needed.
- Editing or creating files (native tools have built-in conflict detection).

### 4. Bash Commands — Use for Batch & OS Operations

Use `run_command` with bash when:
- Batching multiple commands into a single script to reduce tool call count (token optimization).
- Pipeline composition (e.g. `grep ... | head -n 5`, `ls -t ... | head -3`).
- Operations that native tools cannot express (e.g. `git status`, `stat`, `find`, `wc`).
- Workflow steps tagged `// turbo`.

### 5. MCP Tools — Use for Domain-Specific Intelligence

Use MCP tools when:
- A connected MCP server provides specialized operations.
- The task requires cross-entity reasoning (dependency analysis, impact assessment, semantic search).
- Native/Bash tools would require multiple calls to reconstruct context.

### 6. Anti-Pattern — Absolute Prohibition

**MUST NOT** create rules that absolutely prohibit bash commands (`ls`, `cat`, `grep`). Composition and pipelines reduce tool call overhead by 30-50%.

## Related

- [Context Rules](./context-rules.md)
- **Source**: `templates/common/agents/rules/tool-routing.md`
