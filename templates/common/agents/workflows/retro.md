---
description: Conduct a project retrospective before archiving
source: catalog
---

# /retro [project-name]

> **Workspace Version:** 1.5.0 (Governed Libraries)

Conduct a project retrospective before archiving to `Archive/`.

## Steps

### 0. Agent Indices Pre-flight

// turbo

Re-read `.agents/rules.md` to ensure rules context is loaded (guard against context truncation).

> 🔍 **Memory-Assisted Retro:** IF project has `.beads/graph/` directory, use `memory_search` to retrieve all past session summaries, architecture decisions, and friction points for the project. This feeds Step 1 (Goals Assessment) and Step 2 (Learnings) with comprehensive historical context.

### 1. Review Goals & Progress

// turbo

Read `Projects/[project-name]/project.md` and evaluate:

- Were the original goals met?
- Was the Definition of Done (DoD) satisfied?
- Was the deadline met?

**Data Sources (Hybrid 3-File):**

1. **`artifacts/tasks/done.md`** — **Primary input**. Read this file for the complete list of completed tasks with dates. Use this to calculate:
   - Total tasks completed
   - Velocity (tasks per week)
   - Phase-by-phase completion timeline
2. **`artifacts/tasks/backlog.md`** — Check remaining incomplete items.
3. **`project.md` active_plan** — If a plan exists, cross-reference done.md task IDs against the plan's phase mapping to calculate per-phase completion %.

> 🛡️ **Convention:** Use `done.md` as the authoritative source for completion data instead of scanning session logs. This is faster, more accurate, and token-efficient.

### 2. Summarize Learnings

Facilitate a structured reflection:

| Category | Prompt |
| :-- | :-- |
| **What went well** | Practices, tools, or decisions that were effective |
| **Challenges** | Obstacles encountered and how they were addressed |
| **Improvements** | What would be done differently next time |

### 3. Export Reusable Assets

Identify and extract reusable artifacts:

- Move generic code snippets to `Resources/references/code/snippets/`.
- Add new patterns to `Resources/references/code/patterns/`.
- Capture key learnings via `/learn` workflow.

### 4. Graduate Beads to Rules

Review recurring knowledge points ("Beads") from session logs:

- If a bead appears 3+ times, propose graduating it to an official Rule in `.agents/rules/`.

### 4.5. Graduate Insights to Knowledge Items

1. **Cross-project patterns** → scope: `workspace`
2. **Non-obvious gotchas** → purpose: `pitfall`
3. **Proven procedures** → purpose: `playbook`

If candidates found:

```
💡 KNOWLEDGE GRADUATION
Insights from [project-name] that could persist as KIs:
- [Topic 1] — cross-project pattern (scope: workspace)
- [Topic 2] — non-obvious gotcha (purpose: pitfall)

Graduate to KI? Run `/para-knowledge [topic]` (Y/N/Later)
```

> **System KI hint:** If the pattern relates to PARA Workspace governance,
> architecture, or cross-project infrastructure, suggest
> `/para-knowledge system [topic]` for governed system KI lifecycle.

### 5. Record Retrospective

Create `Projects/[project-name]/sessions/RETROSPECTIVE.md`:

```markdown
# Retrospective: [Project Name]

## Metadata

- **Duration**: [Start Date] → [End Date]
- **Status at Archiving**: [Completed/Cancelled/Paused]
- **Final Version**: [version]

## Goals Assessment

- [Goal 1]: ✅ Met / ❌ Not Met
- [Goal 2]: ✅ Met / ❌ Not Met

## What Went Well

- [Item]

## Challenges

- [Item]

## Key Learnings

- [Item]

## Exported Assets

- [List of files moved to Resources/]
```

### 5.5. Graph Memory Push (CONDITIONAL)

> **Gate:** Only trigger if project has `.beads/graph/` directory.

1. Check graph availability:
   ```bash
   test -d "Projects/[project-name]/.beads/graph" && echo "✅ Graph Memory available" || echo "⏭️ No graph — skip memory push"
   ```

2. **IF graph exists:**
   Push the retrospective summary via MCP `memory_push`:
   - **kind:** `retro-summary`
   - **content:** Key learnings + exported assets + goals assessment summary
   - **sessionId:** `YYYY-MM-DD-retro-[project-name]`
   - **metadata:** `{ "status": "[Completed/Cancelled/Paused]", "learnings": N, "assets_exported": N }`

3. **Curate memory:** After pushing, call `memory_curate(projectName)` to consolidate all project memory events into final semantic slices before archival.

4. **IF no graph** → Skip silently.

### 6. Archive Project

// turbo

```bash
mv Projects/[project-name] Archive/[project-name]
echo "📦 Project archived to Archive/[project-name]/"
```

## Related

- `/end` — End session and log progress
- `/learn` — Capture lessons into Areas/Learning
- `/para-rule` — Graduate beads to rules
- `/backlog` — Final backlog review before archiving
