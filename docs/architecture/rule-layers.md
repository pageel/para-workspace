# Rule Layers & Trigger Index Architecture

> **Version**: 1.5.3 | **Last reviewed**: 2026-03-15

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

## Trigger Index (Two-Tier Progressive Disclosure)

The system uses **two index files** so the agent knows which rules exist and when to load them:

**Tier 1: Workspace Rules Index** (`.agent/rules.md`) — ALWAYS READ

```markdown
| Rule                    | Trigger                                           | File                             |
| :---------------------- | :------------------------------------------------ | :------------------------------- |
| Governance              | Touching kernel/, .para/, or system files         | rules/governance.md              |
| Hybrid 3-File Integrity | Reading/writing artifacts/tasks/, ad-hoc requests | rules/hybrid-3-file-integrity.md |
| ...                     | ...                                               | ...                              |
```

**Tier 2: Project Rules Index** (`Projects/<name>/.agent/rules.md`) — CONDITIONAL

```markdown
| Rule              | Trigger                                   | File                 |
| :---------------- | :---------------------------------------- | :------------------- |
| Dogfooding Policy | Editing repo/, syncing files to workspace | dogfooding-policy.md |
| Maintenance       | Version bumps, writing docs/changelog     | maintenance.md       |
```

### Loading Flow (Two-Tier)

```
/open
  ↓
Step 2.5a: Read .agent/rules.md (workspace index) — ALWAYS
  → Memorize 10 triggers (do NOT read rule files)
  ↓
Step 2.5b: has_rules: true?
  → YES → Read Projects/<name>/.agent/rules.md (project index)
  → NO  → Skip (only project rules skipped, workspace rules already loaded)
  ↓
Coding session: agent about to edit repo/
  → Match: "Editing repo/" → load dogfooding-policy.md → comply
  ↓
Agent receives ad-hoc request "remove download button"
  → Match: "ad-hoc requests" → load hybrid-3-file-integrity.md → log hot lane first
```

### `has_rules` Gate in project.md

```yaml
has_rules: true # Gate for /open Step 2.5b (project rules only)
```

- `true` → `/open` reads project rules index
- `false` or missing → skip project rules (workspace rules still loaded)
- `/para-audit update` Step 5 checks consistency between `has_rules` and actual files

## Workflow Coverage

| Workflow      | Workspace Index       | Project Index              | Detail                                                          |
| :------------ | :-------------------- | :------------------------- | :-------------------------------------------------------------- |
| `/open`       | ✅ Step 2.5a (ALWAYS) | ✅ Step 2.5b (conditional) | Workspace: always. Project: if `has_rules: true`                |
| `/plan`       | ✅ Step 2.7 D1        | ✅ Step 2.7 D2 + Step 8.5  | D1: workspace constraints. D2: project constraints. 8.5: impact |
| `/para-audit` | —                     | ✅ Step 5 (update)         | Consistency check: `has_rules` vs index vs disk                 |
| `/para-rule`  | —                     | ✅ Core                    | CRUD rule management                                            |

## References

- **Rule:** `context-rules.md` Rule #4 — Two-Tier Progressive Disclosure protocol
- **Workflow:** `/open` Step 2.5a/2.5b, `/plan` Step 2.7 D1/D2
- **Docs:** [Project Rules](../reference/project-rules.md)

---

_Published from `docs/architecture/rule-layers.md` (Vietnamese internal) — v1.5.3 (BUG-17: Two-Tier Rule Gate)_
