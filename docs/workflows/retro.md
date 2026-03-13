# /retro Workflow

> **Version**: 1.5.2

The `/retro` workflow conducts a structured project retrospective before archiving to `Archive/`. It captures lessons learned, extracts reusable assets, and graduates recurring knowledge into official rules.

## Commands

```
/retro [project-name]
```

## Retrospective Flow

```
Review goals → Summarize learnings → Export assets → Graduate beads → Record → Archive
```

### 1. Review Goals

Reads `project.md` and evaluates: Were goals met? Was DoD satisfied? Was deadline met?

> **Hybrid 3-File Integration**: Reads `artifacts/tasks/done.md` as the exclusive primary data source to automatically calculate final timeline metrics and phase-by-phase completion velocity instead of scanning scattered session logs.

### 2. Summarize Learnings

Structured reflection across three dimensions:

| Category           | Prompt                                |
| :----------------- | :------------------------------------ |
| **What went well** | Effective practices, tools, decisions |
| **Challenges**     | Obstacles and how they were addressed |
| **Improvements**   | What to do differently next time      |

### 3. Export Reusable Assets

- Move generic code snippets to `Resources/references/code/snippets/`
- Add patterns to `Resources/references/code/patterns/`
- Capture key learnings via `/learn`

### 4. Graduate Beads to Rules

Reviews recurring knowledge points from session logs. If a bead appears 3+ times, proposes graduating it to an official Rule in `.agent/rules/`.

### 5. Record Retrospective

Creates `sessions/RETROSPECTIVE.md` with metadata, goal assessment, learnings, and exported assets.

### 6. Archive Project

Moves the entire project directory to `Archive/[project-name]`.

## Related

- [/end Workflow](./end.md) — End session and log progress
- [Workflow Documentation](../reference/workflows.md) — Workflow catalog

---

_Updated in v1.5.1 (Integrated Hybrid 3-File done.md source)_
