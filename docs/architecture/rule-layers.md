# Rule Layers & Trigger Index Architecture

> **Version**: 1.5.3 | **Last reviewed**: 2026-03-13

## Overview

Rules are `.md` files that govern AI Agent **behavior** — boundaries, priorities, and discipline. Unlike Workflows (execution steps), Rules define constraints the agent must follow.

Three key properties:

1. **Layered** — Kernel → Global → Project
2. **Progressive Disclosure** — load only when needed, never all at once
3. **Trigger Index** — lightweight table mapping actions to rule files

## Rule Layers

```
┌─────────────────────────────────────────────┐
│ Layer 1: KERNEL (Immutable)                  │
│ Resources/ai-agents/kernel/invariants.md     │
│ → 11 invariants (I1-I11), read only by audit │
├──────────────────────────────────────────────┤
│ Layer 2: GOVERNED RULES (Global, from repo)  │
│ .agent/rules/*.md                            │
│ → 10 rules, synced via ./para install/update │
│ → Apply to ALL projects in workspace         │
├──────────────────────────────────────────────┤
│ Layer 3: PROJECT RULES (Per-project)         │
│ Projects/<name>/.agent/rules/*.md            │
│ → Custom rules, supplement (not override)    │
│ → Declared via rules.md trigger index        │
└──────────────────────────────────────────────┘
```

### Layer 1: Kernel

- **File:** `invariants.md` — 11 hard rules, change requires RFC + MAJOR bump
- **Read by:** Only `/para-audit` (full-scan) — the sole workflow allowed to read the full kernel

### Layer 2: Governed Rules (Global)

Synced from `catalog.yml` by `./para install` or `./para update`.

| Rule                         | Purpose                                           | Loaded when                |
| :--------------------------- | :------------------------------------------------ | :------------------------- |
| `agent-behavior.md`          | Communication, language, noise reduction          | Always (lightweight)       |
| `governance.md`              | Kernel boundaries — restrict system modifications | Touching kernel/ or .para/ |
| `context-rules.md`           | Context loading order + trigger index protocol    | Every session              |
| `hybrid-3-file-integrity.md` | Hot Lane + compress-not-delete + /end sync        | Operating on tasks/        |
| `para-discipline.md`         | PARA classification enforcement                   | Creating/moving files      |
| `artifact-standard.md`       | Document format standards                         | Creating artifacts         |
| `naming.md`                  | File/branch/commit naming                         | Creating new files         |
| `vcs.md`                     | Git best practices                                | Committing/pushing         |
| `versioning.md`              | SemVer policy                                     | Version bumps              |
| `exports-data.md`            | Data export safety                                | Exporting/sharing          |

### Layer 3: Project Rules

- **Location:** `Projects/<name>/.agent/rules/`
- **Not synced from repo** — user-created via `/para-rule add`
- **Supplement** global rules, never override

## Trigger Index (Progressive Disclosure)

Each project MAY provide a `rules.md` index at `Projects/<name>/.agent/rules.md`:

```markdown
| Rule              | Trigger                                   | File                 |
| :---------------- | :---------------------------------------- | :------------------- |
| Dogfooding Policy | Editing repo/, syncing files to workspace | dogfooding-policy.md |
| Maintenance       | Version bumps, writing docs/changelog     | maintenance.md       |
```

### Loading Flow

```
/open Step 2.5: Read rules.md index (~5 lines) → memorize triggers
    ↓
Coding session: agent about to edit repo/
    → Match: "Editing repo/" → load dogfooding-policy.md → comply
    ↓
Agent about to commit
    → No trigger match → skip → save tokens
```

### `has_rules` Gate in project.md

```yaml
has_rules: true # Gate for /open Step 2.5 and /plan Step 2.7D
```

- `true` → `/open` reads rules index, `/plan` reads constraints
- `false` or missing → skip entirely (zero I/O cost)
- `/para-audit update` Step 5 checks consistency between `has_rules` and actual files

## Workflow Coverage

| Workflow      | Reads rules index? | Detail                                                       |
| :------------ | :----------------- | :----------------------------------------------------------- |
| `/open`       | ✅ Step 2.5        | Reads index → memorize triggers → load on-demand             |
| `/plan`       | ✅ Step 2.7D + 8.5 | Phase D: constraints for design. Step 8.5: rule impact check |
| `/para-audit` | ✅ Step 5 (update) | Consistency check: `has_rules` vs index vs disk              |
| `/para-rule`  | ✅ Core            | CRUD rule management                                         |

## References

- **Rule:** `context-rules.md` Rule #4 — Progressive Disclosure protocol
- **Workflow:** `/open` Step 2.5, `/plan` Step 2.7D
- **Docs:** [Project Rules](../reference/project-rules.md)

---

_Published from `docs/architecture/rule-layers.md` (Vietnamese internal) — v1.5.3_
