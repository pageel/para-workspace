# Formatting Skill — Reference

> **Version**: 1.1.0 | **Last reviewed**: 2026-04-02

## Overview

**Formatting** is an on-demand skill providing templates and constraints for tables, box diagrams, tree listings, and other visual markdown elements. Ensures consistent visual quality across all artifact outputs.

## Triggers

Trigger                    | Example
:--------------------------|:----------------------------------------
Creating plans, backlogs   | `/plan`, `/backlog`
Writing documentation      | `/docs`, internal docs
Creating brainstorm output | `/brainstorm`
Session logs               | `/end`
Any output with tables     | Diagrams, feature matrix, comparison

## Constraints

### Tables

ID  | Rule                     | Detail
:---|:-------------------------|:---------------------------------------------------
C1  | Pad columns              | All cells in the same column MUST have equal width
C2  | Cell width limit         | Max ~50-60 characters per cell
C3  | Column count             | 3-4 ideal, 5-6 max. More than 6 → restructure
C4  | Alignment                | Left-align with `:--` for readability
C5  | Long URLs                | Use reference links `[text][ref]` for URLs > 40 ch

**No outer border:** Tables use no leading/trailing pipes.

### Box Diagrams

- MUST use Unicode box-drawing characters (`┌ ┐ └ ┘ ─ │ ├ ┤`)
- MUST NOT use plain ASCII (`+-|`)
- MUST place inside `` ```text `` code blocks
- MUST NOT wrap entire diagram in outer border box (v1.1.0)

### Tree Listings

- Use standard tree characters: `├──` `└──` `│`
- Place inside `` ```text `` code blocks
- Directories end with `/`

## Quick Checklist

- [ ] All table columns padded to equal width?
- [ ] No cell exceeds 60 characters?
- [ ] Table has ≤ 5 columns? (6 max)
- [ ] No outer border wrapping diagram?
- [ ] Diagrams inside `text` code blocks?
- [ ] Diagrams use Unicode box-drawing (not ASCII)?
- [ ] Trees use `├── └── │` characters?

## Structure

```text
.agents/skills/formatting/
└── SKILL.md              # Single file — constraints + templates
```

## Sync

Location                                  | Role           | Updated by
:-----------------------------------------|:---------------|:-------------------------
`repo/templates/common/agent/skills/`     | Source of Truth | Developer (git push)
`Resources/ai-agents/skills/formatting/`  | Read-only (I9) | `para install` / `update`
`.agents/skills/formatting/`               | Active copy    | `para install` / `update`

---

_See also: [PARA Kit Skill](./para-kit.md) · [Full SKILL.md](../../templates/common/agent/skills/formatting/SKILL.md)_
