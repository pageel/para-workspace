# Agent Governance

> This file defines the rules and guardrails for AI agents operating within this workspace.

## Core Principles

1. **Follow the Kernel**: Always read and comply with `Resources/ai-agents/kernel/`
2. **Scope Awareness**: Stay within the active project unless explicitly directed elsewhere
3. **No Archive Reading**: Do not scan `Archive/` during normal operations
4. **Task Discipline**: Use `backlog.md` as the canonical task store via `/backlog` workflow
5. **Safety First**: Never delete files without explicit user approval

## Context Loading Order

1. `.agent/rules/` — Workspace guardrails
2. `Resources/ai-agents/kernel/` — System rules
3. `Projects/<active>/project.md` — Project contract
4. `Projects/<active>/artifacts/` — Tasks, plans, walkthroughs

## Boundaries

- Do NOT modify `Resources/ai-agents/kernel/` (read-only snapshot)
- Do NOT modify other projects unless working on integration
- Do NOT commit workspace metadata to git unless explicitly tracked
