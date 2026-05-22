# Workspace Rules Index

> ⚠️ BEFORE performing any side-effect action, agent MUST scan this table
> and load matching rules FIRST. Do NOT act then check — check then act.

> Agent loads a specific rule ONLY WHEN the current action matches its trigger.
> This index is read by `/open` Step 2.5a (ALWAYS) and `/plan` Step 2.7D.

| Rule | Trigger | File | Pri |
| :-- | :-- | :-- | :-- |
| Governance | Touching kernel/, .para/, Resources/ai-agents/ — MUST NOT modify read-only | rules/governance.md | 🔴 |
| VCS | Git commit, push, merge, branch, tag, PR — MUST read before ANY git operation | rules/vcs.md | 🔴 |
| Hybrid 3-File Integrity | Reading/writing artifacts/tasks/, ad-hoc requests, running /end | rules/hybrid-3-file-integrity.md | 🟡 |
| Context Rules | Loading context, starting session, detecting project | rules/context-rules.md | 🟡 |
| Agent Behavior | Agent communication, formatting, context recovery after truncation | rules/agent-behavior.md | 🟡 |
| PARA Discipline | Creating/moving files, organizing workspace | rules/para-discipline.md | 🟡 |
| Artifact Standard | Creating/editing artifacts, plans, walkthroughs | rules/artifact-standard.md | 🟢 |
| Naming | Creating files, directories, branches, commits | rules/naming.md | 🟢 |
| Versioning | Version bumps, changelog updates, releases | rules/versioning.md | 🟢 |
| Exports Data | Exporting data, sharing files externally | rules/exports-data.md | 🟢 |
| Knowledge | Creating, updating, deleting Knowledge Items (KI operations) | rules/knowledge.md | 🔴 |
| Agent Persona | Custom conversational style and agent personality | rules/agent-persona.md | 🟡 |
| Graph-First Policy | "fix bug", "trace flow", "analyze code", "understand architecture", `/plan` design, `/brainstorm`, `/spec` — requires `.beads/graph/` | rules/graph-first-policy.md | 🔴 |
| Tool Routing | Choosing between native API tools, bash commands, and MCP tools — specificity wins heuristic | rules/tool-routing.md | 🟢 |

