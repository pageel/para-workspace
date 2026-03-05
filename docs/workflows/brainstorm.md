# /brainstorm Workflow

> **Version**: 1.5.0

The `/brainstorm` workflow provides collaborative ideation for exploring problem spaces, evaluating solutions, and clarifying thinking before committing to a formal implementation plan.

## Commands

```
/brainstorm [project-name] [topic]
```

## Brainstorm Flow

```
Context → Ideation (3-5 options) → Refinement → Save → Choose next action
```

### 1. Context Gathering

Reads existing seeds (`.beads/seeds.md`) and previous brainstorm outputs from `artifacts/para-decisions/`. Asks the user to elaborate on the problem.

### 2. Ideation & Exploration

Generates 3-5 distinct approaches, each with concept, pros, and cons/risks.

### 3. Refinement

Collaborates with the user to eliminate, combine, and drill down into the most promising approach.

### 4. Save Structured Output

Saves to `artifacts/para-decisions/brainstorm-[topic]-[date].md` with a standard template: Problem Statement, Options Evaluated, Decision, Next Steps.

### 5. Choose Next Action

Five exit paths:

| Option         | When to use                    | Destination                         |
| -------------- | ------------------------------ | ----------------------------------- |
| **A. Seeds**   | Idea needs more incubation     | `.beads/seeds.md`                   |
| **B. Plan**    | Ready for implementation       | `/plan` (auto-discovers brainstorm) |
| **C. Backlog** | Simple isolated tasks          | `/backlog`                          |
| **D. Doc**     | Analysis worth preserving      | `docs/` + Doc Index                 |
| **E. Learn**   | Reusable cross-project insight | `/learn` → `Areas/Learning/`        |

## Integration with `/plan`

When `/plan` runs, Step 2.5 automatically checks for recent brainstorm outputs:

```bash
ls -t artifacts/para-decisions/brainstorm-*.md | head -1
```

If found, the plan uses the brainstorm's Options and Decision sections as baseline context — no duplicate analysis needed.

## Related

- [Workflow Documentation](../workflows.md) — Workflow catalog and philosophy
- [Planning Guide](../planning.md) — `/plan` workflow details

---

_Added in v1.5.0_
