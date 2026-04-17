---
name: Harness Guards
description: >
  Centralized guard catalog and auto-scan protocol for generating context-aware
  safety guards across plans, workflows, and artifacts. Loaded just-in-time.
source: catalog
---

# Skill: Harness Guards

> Centralized skill for generating and managing safety guards (harness comments)
> across all PARA artifacts that contain phased progression or protected content.
>
> **Pattern:** Sidecar Skill — this skill contains NO executable logic, only data resources.

## When to Load

- `/plan create` → Step 8.5 (before writing plan): load `references/guard-catalog.md` + `references/scan-protocol.md`
- Creating or editing artifacts with phases/progression: load `references/guard-catalog.md`
- Writing workflow steps that need safety gates: load `references/guard-catalog.md`

## References

| File | When | Purpose |
|:--|:--|:--|
| `references/guard-catalog.md` | Always when this skill is triggered | Classification of all guard types with syntax and placement rules |
| `references/scan-protocol.md` | `/plan create` Step 8.5 or when generating guards for a new artifact | Protocol for scanning project rules/skills to generate context-aware guards |

> **Convention:** Data files live in `references/` (not `templates/`).
> This follows the Sidecar Skill convention formalized in v1.7.6.3.

## Key Principles

1. **Skill = Data only.** Guard generation logic belongs in the workflow, not here.
2. **Proactive Trigger Check** in `agent-behavior.md` enforces loading this skill before side-effects.
3. **Auto-Scan Protocol** reads project DNA (rules + skills indices) to produce project-specific guards instead of generic ones.
4. **Progressive enforcement:** If Agent consistently ignores guards → escalate to a dedicated Rule file.
