# Rule Layers & Trigger Index Architecture

> **Version**: 1.6.2 | **Last reviewed**: 2026-03-24

## Overview

Rules are `.md` files that govern AI Agent **behavior** — boundaries, priorities, and discipline. Unlike Workflows (execution steps), Rules define constraints the agent must follow.

Three key properties:

1. **Layered** — Kernel → Global → Project
2. **Progressive Disclosure** — load only when needed, never all at once
3. **Trigger Index** — lightweight tables mapping actions to rule/skill files with priority levels
4. **Context Recovery** — Defense-in-Depth guardrails against context truncation
5. **Proactive Trigger Check** (v1.6.2) — scan triggers BEFORE any side-effect

## Rule Layers

```
┌─────────────────────────────────────────────┐
│ Layer 1: KERNEL (Immutable)                  │
│ Resources/ai-agents/kernel/invariants.md     │
│ → 11 invariants (I1-I11), read only by audit │
├──────────────────────────────────────────────┤
│ Layer 2: GOVERNED RULES (Global, from repo)  │
│ .agents/rules/*.md                            │
│ → 10 rules, synced via ./para install/update │
│ → Apply to ALL projects in workspace         │
├──────────────────────────────────────────────┤
│ Layer 3: PROJECT RULES (Per-project)         │
│ Projects/<name>/.agents/rules/*.md            │
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

- **Location:** `Projects/<name>/.agents/rules/`
- **Not synced from repo** — user-created via `/para-rule add`
- **Supplement** global rules, never override

## Trigger Index (Two-Tier Progressive Disclosure)

The system uses **index files** so the agent knows which rules AND skills exist and when to load them:

**Tier 1a: Workspace Rules Index** (`.agents/rules.md`) — ALWAYS READ

```markdown
| Rule                    | Trigger                                           | File                             | Pri |
| :---------------------- | :------------------------------------------------ | :------------------------------- | :-- |
| Governance              | Touching kernel/, .para/ — MUST NOT modify        | rules/governance.md              | 🔴  |
| VCS                     | Git commit, push, merge, branch, tag, PR          | rules/vcs.md                     | 🔴  |
| ...                     | ...                                               | ...                              | 🟢  |
```

**Tier 1b: Workspace Skills Index** (`.agents/skills.md`) — ALWAYS READ (v1.6.2+)

```markdown
| Rule          | Trigger                              | File             | Pri |
| :------------ | :----------------------------------- | :--------------- | :-- |
| Code Style    | Editing src/, writing new components | code-style.md    | �   |
| Deploy Safety | Deploying, editing CI/CD configs     | deploy-safety.md | �   |

## File Guards

| File pattern       | MUST re-read     | Reason                        |
| :----------------- | :--------------- | :---------------------------- |
| `CHANGELOG.md`     | code-style.md    | Must follow commit convention |
| `deploy/`, `.env*` | deploy-safety.md | Safety checks before deploy   |
```

> **File Guards** (v1.5.4): Optional section in project `rules.md`. Extends the global guards from `agent-behavior.md` §4. Agent reads both global + project guards during Context Recovery.

### Loading Flow (v1.6.2)

```
/open
  ↓
Step 2.5a: Read .agents/rules.md (workspace rules index) — ALWAYS
  → Memorize triggers (do NOT read rule files)
  ↓
Step 2.5b: Read .agents/skills.md (workspace skills index) — ALWAYS (v1.6.2+)
  → Memorize skill triggers
  ↓
Step 2.5c: agent.rules / agent.skills / has_rules?
  → YES → Read project indices
  → NO  → Skip (workspace indices still loaded)
  ↓
Coding session: agent about to edit repo/
  → Proactive Trigger Check → Match: "Editing repo/" → load dogfooding-policy.md → comply
```

### `agent` Map in project.md (v1.6.2+)

```yaml
agent:
  rules: true    # Gate for /open Step 2.5c (project rules)
  skills: true   # Gate for /open Step 2.5c (project skills)
```

- `agent.rules: true` → `/open` reads project rules index
- `agent.skills: true` → `/open` reads project skills index
- `has_rules: true` → backward compat fallback (deprecated)
- `/para-audit update` Step 5 checks consistency between `agent` map and actual files

## Workflow Coverage

| Workflow      | Rules Index           | Skills Index           | Pre-flight             | Detail                                                        |
| :------------ | :-------------------- | :--------------------- | :--------------------- | :------------------------------------------------------------ |
| `/open`       | ✅ Step 2.5a (ALWAYS) | ✅ Step 2.5b (ALWAYS)  | — (IS the loader)      | Workspace: always. Project: if `agent.*: true`                |
| `/plan`       | ✅ Step 2.7 D1-D2     | ✅ Step 2.7 D3          | ✅ Step 0 (v1.6.2)     | D1: workspace. D2: project rules. D3: project skills          |
| `/docs`       | ✅ Step 0             | ✅ Step 0              | ✅ Step 0 (v1.6.2)     | Re-reads rules + skills before doc generation                  |
| `/push`       | ✅ Step 0             | ✅ Step 0              | ✅ Step 0 (v1.6.2)     | Re-reads before git operations                                 |
| `/release`    | ✅ Step 0             | ✅ Step 0              | ✅ Step 0 (v1.6.2)     | Re-reads before release                                        |
| `/end`        | ✅ Step 0             | ✅ Step 0              | ✅ Step 0 (v1.6.2)     | Re-reads before session sync                                   |
| `/backlog`    | ✅ Step 0             | ✅ Step 0              | ✅ Step 0 (v1.6.2)     | Re-reads before backlog mutation                               |
| `/retro`      | ✅ Step 0             | ✅ Step 0              | ✅ Step 0 (v1.6.2)     | Re-reads before archive                                        |
| `/para-audit` | —                     | —                      | —                      | Agent index consistency check (rules + skills vs disk)         |
| `/para-rule`  | —                     | —                      | —                      | CRUD rule management                                           |

## References

- **Rule:** `context-rules.md` Rule #4 — Agent Index Loading protocol
- **Workflow:** `/open` Step 2.5a/2.5b/2.5c, `/plan` Step 2.7 D1/D2/D3
- **Docs:** [Project Rules](../reference/project-rules.md)

---

_Published from `docs/architecture/rule-layers.md` — v1.6.2 (FEAT-53: Unified Agent Index)_
