# Knowledge Item (KI) Authoring Guidelines

When creating or updating a Knowledge Item (KI) artifact, the Agent MUST adhere to the following architectural and OSS standards:

## 1. OSS English-First Governance (CRITICAL)
- **All KI artifacts MUST be written in English.** This ensures the knowledge can be shared, reviewed, and utilized by global open-source contributors or agents running in different locale configurations.
- Even if the user requests the KI in another language, the internal `.md` file content MUST be English. You may translate the summary in chat, but the persisted file must be English.

## 2. Path Sanitization & Relative Paths (CRITICAL)
- **NEVER hardcode absolute personal paths** (e.g., `/home/username/projects/workspace/...` or `/Users/name/...`).
- **Use generic or relative paths** instead. Examples:
  - `~/.beads/graph/`
  - `$WORKSPACE_ROOT/Projects/para-graph/`
  - `./repo/src/`
- This prevents leaking the user's local directory structure into the OSS repository and ensures the KI is portable across environments.

## 3. Domain-Driven Chunking (Token Optimization)
- **Do NOT create monolithic KIs.** A single KI should not contain exhaustive information covering multiple distinct topics (e.g., mixing database schema, workflow steps, and MCP tool definitions).
- **Chunk by Domain:** Split broad topics into highly focused KIs.
  - Example: Instead of `para_graph_documentation`, use `para_graph_architecture`, `para_graph_mcp_tools`, and `para_graph_workflows`.
- This optimizes the Context Budget. When an agent searches for "how to use graph_query", it only loads the lightweight `mcp_tools` KI instead of a massive monolithic file.

## 4. "Cheatsheet" Format
- KIs are for AI Agents, not humans reading novels.
- Use bullet points, clear headings, markdown tables, and code snippets.
- Use explicit examples to prevent hallucination (e.g., showing exact JSON arguments for a tool).
