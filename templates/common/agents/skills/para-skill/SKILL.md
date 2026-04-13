---
name: para-skill
description: "Governance skill for creating and validating PARA workspace skills via the Co-Author engine. Use when running /para-skill add or /para-skill validate to enforce naming conventions, quality standards, size constraints, and sidecar architecture patterns."
---

# PARA Skill — Governance & Co-Author Engine

> **Version:** 1.0.0 | **Kernel min:** 1.7.6 | **Type:** Governance Skill
> **Companion workflow:** `/para-skill` (`workflows/para-skill.md`)

This skill governs the quality standards, naming conventions, and creation framework
for all AI Agent skills within a PARA Workspace. It serves as the **Sidecar companion**
to the `/para-skill` workflow — the workflow handles step-by-step logic, while this
skill provides the governance rules and data resources the workflow needs.

---

## 1. Co-Author Principles

When the `/para-skill add` workflow is invoked, Agent MUST follow these principles:

1. **Draft-First, Not Interview-First.** Scan context silently (project.md, rules, existing skills),
   then present a complete draft for user review. Do NOT ask individual questions one by one.
2. **Quality Gate Before User Review.** Self-check the draft against the Quality Checklist (§3 Router)
   BEFORE presenting to the user. Never show a draft that violates D1-D4, C1-C2, or W1-W3.
3. **Respect Project DNA.** If the project has custom rules (naming, language, conventions),
   the skill MUST reflect those constraints — not generic boilerplate.

## 2. Skill Quality Standards

### Naming Convention

| Element | Rule | Example |
| :-- | :-- | :-- |
| Directory | `kebab-case`, matches skill purpose | `page-map/` |
| Entry file | Always `SKILL.md` (uppercase) | `SKILL.md` |
| Frontmatter | MUST have `description` field | `description: ...` |

### Structure Convention

```
.agents/skills/[name]/
├── SKILL.md              ← Entry point (MUST exist)
├── scripts/              ← Optional helper scripts
└── references/           ← Optional data files, templates
```

### Size Constraint

- SKILL.md SHOULD be under **500 lines** (Kernel Heuristic).
- If content exceeds 500 lines, split into `SKILL.md` (core) + `references/` (data).

## 3. Resource Router

> Agent reads this table to locate data files needed by the `/para-skill` workflow.

| Resource | Relative Path | Description |
| :-- | :-- | :-- |
| Quality Checklist | `references/skill-quality-checklist.md` | Validation checklist (D1-D4, C1-C2, W1-W3) |
| Project Profile Tmpl | `references/templates/project-profile.md` | Template for project DNA skills |
| Tool Skill Tmpl | `references/templates/tool-skill.md` | Template for utility/automation skills |

**Path resolution:** All paths are relative to this skill's directory (`.agents/skills/para-skill/`).

Agent MUST use the Router Table above to find resources, NOT hardcoded paths or legacy
`workflows/para-skill/` locations (which no longer exist).

## 4. Validation Rules

When running `/para-skill validate [name]`, check each criterion and fix failures before proceeding:

| Check | How to Verify | Fix |
| :-- | :-- | :-- |
| Frontmatter valid | YAML `description` field present in `SKILL.md` | Add `description: "..."` to frontmatter |
| Under 500 lines | Count lines in `SKILL.md` | Split heavy content to `references/` |
| Actionable content | Body contains instructions, not just metadata | Add workflow steps or guidance |
| No placeholders | Search for `[TBD]`, `TODO`, `FIXME` | Replace with real content or remove |
| Specific trigger | Description enables index matching | Add explicit "Use when..." clause |

If validation fails → fix the issue → re-run `/para-skill validate [name]`.

## 6. Integration with `/plan` (v1.7.12)

When `/plan create` Step 5 (Design Architecture) involves creating a **new Sidecar Skill**:

1. Agent MUST load this skill (`para-skill/SKILL.md`) to get structure standards (§2).
2. The plan MUST include the Sidecar directory tree in its Architecture Overview:
   ```
   skills/[name]/
   ├── SKILL.md              ← Router + When to Load
   └── references/           ← Data files (templates, checklists)
   ```
3. The plan MUST include tasks for:
   - Creating `SKILL.md` with Router Table
   - Creating data files in `references/`
   - Registering trigger in `skills.md` workspace index
   - Adding entry to `skills/catalog.yml`
