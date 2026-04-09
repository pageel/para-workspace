# /brainstorm Workflow

> **Version**: 1.7.10

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

Reads existing seeds (`.beads/seeds.md`) and previous brainstorm outputs from `artifacts/para-decisions/`. Runs a **Soft Dump** script that force-loads `.agents/rules.md` and `.agents/skills.md` into context (Anti-Cognitive-Bypass, v1.7.10). Asks the user to elaborate on the problem.

### 2. Ideation & Exploration

Generates 3-5 distinct approaches, each with concept, pros, and cons/risks.

### 3. Refinement

Collaborates with the user to eliminate, combine, and drill down into the most promising approach.

### 4. Save Structured Output

**Dual Output** — evaluates output size before saving:

| Brainstorm Size | Output |
|:--|:--|
| **Small** (≤80 lines, ≤2 options) | 1 file: `brainstorm-[YYYY-MM-DD]-[topic].md` in `para-decisions/` |
| **Large** (>80 lines, ≥3 options, data tables) | 2 files: Decision in `para-decisions/` + Research in `docs/researches/` |

**Naming convention** (v1.7.7):

```
{type}-{YYYY-MM-DD}-{topic-slug}.md
```

- `type`: `brainstorm` or `decision`
- Date ALWAYS right after type prefix (enables chronological sort)
- `topic-slug`: kebab-case, ≤5 words

> **All output goes to `artifacts/para-decisions/`** — the `brainstorms/` directory was consolidated in v1.7.7.

### 5. Choose Next Action

Seven exit paths:

| Option | When to use | Destination |
|:--|:--|:--|
| **A. Seeds** | Idea needs more incubation | `.beads/seeds.md` |
| **B. Plan** | Ready for implementation | `/plan` (auto-discovers brainstorm) |
| **C. Backlog** | Simple isolated tasks | `/backlog` |
| **D. Doc** | Analysis worth preserving | `docs/` + Doc Index |
| **E. Learn** | Reusable cross-project insight | `/learn` → `Areas/Learning/` |
| **F. Knowledge** | Persistent KI | `/para-knowledge` |
| **G. Research** | Standalone research document | `docs/researches/` |

## Integration with `/plan`

When `/plan` runs, Step 2.5 automatically checks for recent brainstorm outputs:

```bash
ls -t artifacts/para-decisions/brainstorm-*.md | head -1
```

If found, the plan uses the brainstorm's Options and Decision sections as baseline context — no duplicate analysis needed.

## Related

- [Workflow Documentation](../reference/workflows.md) — Workflow catalog and philosophy
- [Planning Guide](../guides/planning.md) — `/plan` workflow details

---

_Added in v1.5.0. Updated in v1.7.10 (Cognitive Bypass Fix — Soft Dump payload in Step 1)._
