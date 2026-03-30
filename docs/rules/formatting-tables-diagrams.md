# Rule: Formatting Tables & Diagrams

> **Rule version:** 1.0.0 (v1.6.4) | **Last reviewed:** 2026-03-30  
> **Priority:** 🟢 Standard | **Source:** Governed catalog

## Overview

The `formatting-tables-diagrams` rule defines how AI agents format tables, diagrams, and tree listings in Markdown. Applies to **all** artifacts: plans, brainstorms, backlogs, docs, session logs.

### Why this rule exists

1. **AI agents produce misaligned tables** — columns too long, pipes (`|`) misaligned, source code unreadable.
2. **Ugly ASCII art** — using `+-|` instead of Unicode box-drawing (`┌─┐│└┘`) makes diagrams hard to read.
3. **Consistency** — without standards, every table/diagram looks different.

### When is this rule loaded?

Triggered via `.agent/rules.md` when the agent:

| Trigger | Operation |
|:--------|:----------|
| Creates/edits markdown tables | Plans, backlogs, docs, brainstorms |
| Draws architecture diagrams | Architecture docs, decision records |
| Displays directory structure | Tree listings in README, docs |
| Compares multiple options | Options comparison, evaluation tables |

---

## 4 Rule Sections

### §1. Markdown Tables

| Rule | Explanation |
|:-----|:-----------|
| Pad columns | All cells in the same column must have **equal width** |
| Cell width ≤ 60 chars | Longer cells → shorten or split into rows |
| 3-4 columns ideal | Max 5-6 columns; more → restructure |
| Left-align (`:--`) | Better readability than center/right |
| Emoji OK | Uniform pixel width in rendered view |

### §2. Box Diagrams

Use **Unicode box-drawing characters** inside `` ```text `` code blocks.

4 built-in templates: Hierarchy, Stacked Layers, Flow, Sequence.

### §3. Tree Listings

Use `├── └── │` inside `` ```text `` code blocks.

### §4. Comparison Tables

Max 3-4 options as columns with standardized status icons (✅ ❌ 🟡 🔴 🟢 🚀 🔄).

---

## Loading

- **Token cost:** ~800 tokens (single file, no dependencies)
- **Mechanism:** On-demand via `.agent/rules.md` trigger index
- **Frequency:** When creating tables, diagrams, or tree listings

## Quick Checklist

- [ ] All table columns padded to equal width?
- [ ] No cell exceeds 60 characters?
- [ ] Table has > 5 columns? → Consider reducing.
- [ ] Diagrams inside code blocks (`text`)?
- [ ] Diagrams use Unicode box-drawing (`┌─┐│└┘`)?
- [ ] Trees use `├── └── │`?

---

_Last updated: 2026-03-30 — v1.0.0_
