---
description: Conduct a project retrospective before archiving
source: catalog
---

# /retro [project-name]

> **Workspace Version:** 1.5.0 (Governed Libraries)

Conduct a project retrospective before archiving to `Archive/`.

## Steps

### 1. Review Goals

// turbo

Read `Projects/[project-name]/project.md` and evaluate:

- Were the original goals met?
- Was the Definition of Done (DoD) satisfied?
- Was the deadline met?

### 2. Summarize Learnings

Facilitate a structured reflection:

| Category           | Prompt                                             |
| :----------------- | :------------------------------------------------- |
| **What went well** | Practices, tools, or decisions that were effective |
| **Challenges**     | Obstacles encountered and how they were addressed  |
| **Improvements**   | What would be done differently next time           |

### 3. Export Reusable Assets

Identify and extract reusable artifacts:

- Move generic code snippets to `Resources/references/code/snippets/`.
- Add new patterns to `Resources/references/code/patterns/`.
- Capture key learnings via `/learn` workflow.

### 4. Graduate Beads to Rules

Review recurring knowledge points ("Beads") from session logs:

- If a bead appears 3+ times, propose graduating it to an official Rule in `.agent/rules/`.

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
