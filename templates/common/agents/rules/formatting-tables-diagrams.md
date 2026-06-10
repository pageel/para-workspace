---
description: Formatting standards for tables, diagrams, and visual markdown elements
trigger: manual
glob:
---

<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->

# Formatting Templates — Tables & Diagrams

> Formatting rules for AI Agents when creating tables and diagrams in markdown.
> Prevents column misalignment, ensures readability in both source and rendered view.
> Applies to ALL artifacts: plans, brainstorms, docs, backlogs.


## 1. Markdown Tables

### Rules

- **PAD COLUMNS** — all cells in the same column must have the same width (pad with spaces).
- **Cell width limit** — max ~50-60 characters. Longer → shorten or split into rows.
- **Reduce columns** — 3-4 columns ideal, 5-6 max.
- **Emoji OK** — uniform pixel width in rendered view.
- **Left-align** — use `:--` for readability.

### Template

```markdown
| Field          | Type             | Description                   |
|:---------------|:-----------------|:------------------------------|
| `name`         | string           | Project name                  |
| `status`       | enum             | active, archived, completed   |
| `ecosystem`    | string \| null   | Parent ecosystem slug         |
```

### Anti-pattern (WRONG)

```markdown
| # | Task | Workflow | Very long change description that exceeds 80 characters and makes pipes misalign completely | Output |
|:--|:-----|:---------|:-----|:-------|
```

→ The "change" column is 80+ characters, pipes are completely misaligned.


## 2. Box Diagrams

### Rules

- Use **Unicode box-drawing characters** inside `` ```text `` code blocks.
- Do NOT use plain ASCII (`+-|`) — ugly, hard to read.
- Monospace fonts handle Unicode uniformly → alignment works.

### Common Characters

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
│  Layer 3 (top)                       │
│  Description line                    │
├──────────────────────────────────────┤
│  Layer 2 (middle)                    │
│  Description line                    │
├──────────────────────────────────────┤
│  Layer 1 (bottom)                    │
│  Description line                    │
└──────────────────────────────────────┘
```

### Template — Flow

```text
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Step 1  │────▶│  Step 2  │────▶│  Step 3  │
└──────────┘     └──────────┘     └──────────┘
```

### Template — Sequence

```text
Client              Server              Database
  │                    │                    │
  │── request ────────▶│                    │
  │                    │── query ──────────▶│
  │                    │◀── result ─────────│
  │◀── response ───────│                    │
```


## 3. Tree Listings

### Rules

- Use standard tree characters: `├── └── │`
- Place inside `` ```text `` code blocks.

### Template

```text
root/
├── folder-a/
│   ├── file-1.md
│   └── file-2.md
├── folder-b/
│   └── file-3.md
└── file-4.md
```


## 4. Comparison Tables (Multiple Options)

### Template — 3-4 Options

```markdown
| Criteria        | Option A        | Option B       | Option C       |
|:----------------|:----------------|:---------------|:---------------|
| **Cost**        | $0              | $5/mo          | $20/mo         |
| **Effort**      | 1 day           | 3 days         | 2 weeks        |
| **Scale**       | ~50 users       | ∞              | ∞              |
| **Self-host**   | ❌               | ✅              | ✅              |
```

### Status Icons

```text
✅ Yes / Done / Good
❌ No / Missing
🟡 Medium / Partial
🔴 High / Critical
🟢 Low / Good
📅 Planned
🚀 ToDo
🔄 In Progress
```


## Quick Checklist

- [ ] All columns in the table padded to the same width?
- [ ] No cell exceeds 60 characters?
- [ ] Table has more than 5 columns? → Consider reducing.
- [ ] Diagrams inside code blocks (`text`)?
- [ ] Diagrams use Unicode box-drawing (`┌─┐│└┘`)?
- [ ] Trees use `├── └── │`?
