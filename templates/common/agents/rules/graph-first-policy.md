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
| 🥇 1st | `graph_query` + `graph_edges` + `graph_god_nodes` | Locate entities, map dependencies, or identify core central entrypoints (God Nodes) |
| 🥈 2nd | `graph_context_bundle` + `graph_expand_node` | Retrieve full details, adjacent entities, callers, callees, or specs for a specific node |
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
- At the end of a plan phase or coding session, Agent **MUST** actively review completed tasks to extract new reusable insights (lessons, gotchas, or decisions) and use the `insight_push` tool to save them in the project graph database.
- Agent **SHOULD** use the `insight_validate` tool to verify the semantic consistency and format of the insights before saving.

### 4. Transparency

- Agent **SHOULD** mention the graph edges or nodes found in the reasoning before calling `replace_file_content`.
- Agent **MUST** explicitly state in its response that `para-graph` was utilized to map out connections before applying any fix.

### 5. Graceful Degradation

- If the MCP server is unavailable or graph data is stale (`metadata.json` older than 7 days), Agent **MAY** fall back to standard file I/O with a warning to the user.
- Agent **SHOULD** suggest running `/para-graph build` to refresh the graph after the task is complete.

### 6. Mandatory CSA Compliance Verification

- Before submitting code changes or completing a plan phase, Agent **MUST** run `npx para-graph audit csa --project .` to verify that code-specification double-binding coverage is >= 90.0% and no dangling spec links exist.
- If the audit fails, Agent **MUST** run `npx para-graph fix csa --project .` (or use the `graph_fix_csa` MCP tool) to auto-heal references before proceeding.

### 7. Mandatory Physical Drift & Junk File Verification

- Before proposing or executing a git commit or staging files, the Agent **MUST** verify the physical integrity of the project directory structure using the `project_snapshot` and `project_diff` MCP tools.
- Agent **MUST** compare the list of physical file modifications/additions against the active Plan File Inventory.
- Any file detected in the diff that is not registered in the active Plan phase's file inventory or covered by `.gitignore` **MUST NOT** be ignored:
  - **Temporary/Scratch Files**: Propose deleting them immediately (e.g., helper scripts, logs).
  - **Personal Configs/States**: Propose adding them to `.gitignore`.
  - **Missing Planned Entities**: Halt the commit process, report the omission, and update the plan file first before proceeding.
- Agent **MUST** obtain explicit user confirmation before bypass or proceeding with the git commit.

## Related

- Skill: `para-graph` — Centralized Graph Intelligence Router with enrichment workflow and workflow integration snippets.
- Workflow: `/para-graph build` — Rebuilds the Code-Knowledge Graph for a project.
