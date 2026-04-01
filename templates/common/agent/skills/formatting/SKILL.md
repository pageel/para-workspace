---
name: Formatting Tables & Diagrams
description: Templates and patterns for tables, diagrams, trees, and visual markdown — loaded on demand when formatting artifacts.
source: catalog
---

# Skill: Formatting

> Formatting standards, constraints, and reusable templates for AI Agents
> when creating tables, diagrams, trees, and other visual markdown elements.
>
> Applies to ALL artifacts: plans, backlogs, brainstorms, docs, session logs.

---

## 1. Markdown Tables

### Constraints

| ID | Rule                     | Detail                                             |
|:---|:-------------------------|:---------------------------------------------------|
| C1 | Pad columns              | All cells in the same column MUST have equal width  |
| C2 | Cell width limit         | Max ~50-60 characters per cell                      |
| C3 | Column count             | 3-4 ideal, 5-6 max. More than 6 → restructure      |
| C4 | Alignment                | Left-align with `:--` for readability               |
| C5 | Long URLs                | Use reference links `[text][ref]` for URLs > 40 ch  |

### Template — Data Table

```markdown
| Field          | Type           | Description                  |
|:---------------|:---------------|:-----------------------------|
| `name`         | string         | Project name                 |
| `status`       | enum           | active, archived, completed  |
| `ecosystem`    | string \| null | Parent ecosystem slug        |
```

### Template — Archived Items (Plan-based)

Group completed items by plan. Use reference links for file paths.

```markdown
| Plan                       | IDs                           |
|:---------------------------|:------------------------------|
| `Initial MVP (v1.0)`       | FT-01→05, BUG-01→03          |
| [Migration Plan v2][ref1]  | MG-01→08, BUG-10, BUG-11     |
| [Hotfix Plan][ref2]         | BUG-12                        |

[ref1]: ../plans/done/migration-v2.md
[ref2]: ../plans/done/hotfix-login.md
```

### Anti-patterns

```markdown
<!-- WRONG: cell > 60 chars, pipes misaligned -->
| # | Task | Very long description that goes past eighty chars | Out |
|:--|:-----|:--------------------------------------------------|:----|

<!-- WRONG: inline URL bloats cell width -->
| [Some Long Plan Name](../plans/done/very-long-name.md) | IDs |

<!-- RIGHT: reference link keeps cell short -->
| [Some Long Plan Name][ref1] | IDs |
```

---

## 2. Box Diagrams

### Constraints

- MUST use Unicode box-drawing characters (see table below)
- MUST NOT use plain ASCII (`+-|`)
- MUST place inside `` ```text `` code blocks

### Character Reference

```text
Corners:    ┌  ┐  └  ┘
Lines:      ─  │
Junctions:  ├  ┤  ┬  ┴  ┼
Arrows:     ▼  ▲  ►  ◄  →  ←
Double:     ╔  ╗  ╚  ╝  ║  ═
```

### Template — Hierarchy

```text
┌─────────────────┐
│  Parent Box     │
└───────┬─────────┘
        │
    ┌───┼───┐
    ▼   ▼   ▼
┌─────┐ ┌─────┐ ┌─────┐
│ A   │ │ B   │ │ C   │
└─────┘ └─────┘ └─────┘
```

### Template — Stacked Layers

```text
┌──────────────────────────────────────┐
│  Layer 3 — Description              │
├──────────────────────────────────────┤
│  Layer 2 — Description              │
├──────────────────────────────────────┤
│  Layer 1 — Description              │
└──────────────────────────────────────┘
```

### Template — Flow (Linear)

```text
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Step 1  │────▶│  Step 2  │────▶│  Step 3  │
└──────────┘     └──────────┘     └──────────┘
```

### Template — Flow (Branching)

```text
                ┌──────────┐
           ┌───▶│  Path A  │
┌────────┐ │    └──────────┘
│ Decide │─┤
└────────┘ │    ┌──────────┐
           └───▶│  Path B  │
                └──────────┘
```

### Template — Sequence Diagram

```text
Client              Server              Database
  │                    │                    │
  │── request ────────▶│                    │
  │                    │── query ──────────▶│
  │                    │◀── result ─────────│
  │◀── response ───────│                    │
```

---

## 3. Tree Listings

### Constraints

- Use standard tree characters: `├──` `└──` `│`
- Place inside `` ```text `` code blocks
- Directories end with `/`

### Template — Project Structure

```text
project-slug/
├── project.md
├── repo/
│   ├── src/
│   └── package.json
├── sessions/
│   └── 2026-03-30.md
├── artifacts/
│   ├── tasks/
│   │   ├── backlog.md
│   │   ├── sprint-current.md
│   │   └── done.md
│   └── plans/
│       └── done/
└── docs/
```

---

## 4. Comparison Tables

### Template — Options Comparison

```markdown
| Criteria      | Option A  | Option B | Option C |
|:--------------|:----------|:---------|:---------|
| **Cost**      | $0        | $5/mo    | $20/mo   |
| **Effort**    | 1 day     | 3 days   | 2 weeks  |
| **Scale**     | ~50 users | ∞        | ∞        |
| **Self-host** | ❌        | ✅       | ✅       |
```

### Template — Feature Matrix

```markdown
| Feature        | v1.0 | v2.0 | Planned |
|:---------------|:-----|:-----|:--------|
| Auth modes     | 1    | 3    | —       |
| SSR            | ❌   | ✅   | —       |
| Multi-tenant   | ❌   | ✅   | —       |
| Plugin system  | ❌   | ❌   | ✅      |
```

---

## 5. Status Icons

Standard icons for use across all artifacts:

```text
✅ Yes / Done / Good        ❌ No / Missing
🟡 Medium / Partial         🔴 High / Critical
🟢 Low / Good               📅 Planned
🚀 ToDo                     🔄 In Progress
⏳ Pending                  📊 Evaluated
```

---

## Quick Checklist

Before finalizing any visual markdown element:

- [ ] All table columns padded to equal width?
- [ ] No cell exceeds 60 characters?
- [ ] Table has ≤ 5 columns? (6 max)
- [ ] Long URLs use reference links `[text][ref]`?
- [ ] Diagrams inside `text` code blocks?
- [ ] Diagrams use Unicode box-drawing (not ASCII)?
- [ ] Trees use `├── └── │` characters?
