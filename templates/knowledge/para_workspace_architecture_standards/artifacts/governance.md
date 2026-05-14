# Governance & Extension: Kernel, Catalogs, and Agent Protocol

PARA Workspace v1.7.x uses a formalized governance layer with three tiers: Constitutional (immutable kernel), Governed (catalog-managed libraries), and Local (project-specific customizations).

## 1. The RFC Process

Significant changes to the workspace must follow the **RFC** process:

- **Location:** `docs/rfcs/accepted/`
- **Workflow:** Draft → Review (Kernel compliance) → Accept → Implement → Archive
- **Impact tiers:**
  - Invariant change → RFC + MAJOR version bump
  - Heuristic change → PR + MINOR/PATCH version bump
  - Schema change → Update templates + examples
- All changes must pass test vectors in `examples/` before release

## 2. Invariants & Heuristics

- **Invariants (I1–I11):** Hard rules — MUST NOT be violated by any agent, CLI, or workflow.
  - **Smart Archive Rule:** Never use `rm` directly to delete user-facing PARA files during updates. MUST use `archive_file` helper → `.para/archive/[version]-orphans/`.
- **Heuristics (H1–H10):** Soft rules — strongly recommended, flexible based on context.
  - **Ecosystem (H7 v1.6.0+):** Cross-project `@` prefix, ecosystem meta-projects
  - **Governed Catalogs (H9):** `VERSIONS.yml` and catalogs mandatory for all libraries
  - **Knowledge Items (H10 v1.7.0+):** KR1-KR7 lifecycle governance, system KI sync

## 3. Catalog System (v1.4.1+)

The catalog mechanism and `VERSIONS.yml` formalize how workflows, rules, and skills are introduced.

### Required Fields Per Item

Field        | Required | Description
:------------|:---------|:----------------------------------
`id`         | ✅       | Stable kebab-case identifier
`name`       | ✅       | Human-readable name
`version`    | ✅       | Semver version
`kernel_min` | ✅       | Minimum kernel version required
`kernel_max` | ❌       | Optional max kernel version
`entrypoint` | ✅       | Relative path to markdown file
`description`| ✅       | Short description

### Sync Logic

1. `para update` → pulls new repo
2. `para install` → reads catalogs, validates `kernel_min`/`kernel_max`
3. Files projected into workspace: read-only snapshot → `Resources/ai-agents/`, customizable → `.agents/`
4. Incompatible items skipped with clear warning

## 4. Agent Protocol (v1.6.2+)

### Two-Level Index System

- **Workspace level:** `.agents/rules.md` + `.agents/skills.md` — ALWAYS loaded by `/open`
- **Project level:** `Projects/<slug>/.agents/rules.md` — CONDITIONAL, gated by `agent.rules: true` in project.md

### Trigger Table Format

```markdown
Rule/Skill | Trigger                              | File              | Pri
:----------|:-------------------------------------|:------------------|:---
Name       | When this action matches             | path/to/file.md   | 🔴
```

### Proactive Trigger Protocol

**Check THEN act — never act THEN check.**

BEFORE any action that edits files, runs commands, creates artifacts, or brainstorms technical solutions:
1. Scan workspace rules trigger table
2. Scan workspace skills trigger table
3. Scan project triggers (if loaded)
4. IF match → load rule/skill BEFORE proceeding

### Agent Recovery

If rules/skills forgotten after context truncation:
- Re-read `.agents/rules.md` + `.agents/skills.md`
- Re-read project rules if `agent.rules: true`

### Anti-Token-Decay Guardrails (v1.7.13.2)

To prevent LLMs from hallucinating past critical checklists due to context truncation:
- **Phase Pre-flight HTML Locks:** Essential rule reloads are hardcoded in templates as `<!-- ⚠️ DO NOT MODIFY THIS BLOCK -->`.
- **Staged Drill-down:** Post-push operations require an explicit `> 🛑 **STOP HERE**` gate, forcing user UI consent.
- **Git Auto-Run Shield:** Auto-generated `git commit` commands must set `SafeToAutoRun: false` in agents code.

## 5. Rules Library (12 workspace rules)

Rule                    | Trigger                              | Priority
:-----------------------|:-------------------------------------|:--------
Governance              | Touching kernel/, .para/, Resources/ | 🔴 High
VCS                     | Git commit, push, merge, branch, tag | 🔴 High
Knowledge               | Creating, updating, archiving KIs    | 🔴 High
Hybrid 3-File Integrity | Reading/writing artifacts/tasks/     | 🟡 Med
Context Rules           | Loading context, starting session    | 🟡 Med
Agent Behavior          | Communication, formatting, recovery  | 🟡 Med
PARA Discipline         | Creating/moving files, organizing    | 🟡 Med
Artifact Standard       | Creating/editing artifacts, plans    | 🟢 Low
Naming                  | Creating files, directories, branches| 🟢 Low
Versioning              | Version bumps, changelog updates     | 🟢 Low
Exports Data            | Exporting data, sharing externally   | 🟢 Low
Formatting Tables       | Drawing tables, diagrams, trees      | 🟢 Low

## 6. Skills Library (2 core skills, v1.6.4+)

Skills are folder-based, standalone, English-first instruction sets:

Skill      | Trigger                                    | Structure
:----------|:-------------------------------------------|:------------------------
PARA Kit   | PARA structure, schema, kernel governance  | SKILL.md + templates/ + examples/
Formatting | Tables, diagrams, trees, visual markdown   | SKILL.md (self-contained)

Skills were promoted from rules: standalone, English-first, constraints + templates merged. Users may add project-specific skills via their project `.agents/skills/` directory.

## 7. Knowledge System Governance (v1.7.0+)

### Rules (KR1–KR7)

Rule   | Description
:------|:-------------------------------------------
KR1    | Only `/para-knowledge` workflow can create/modify KIs
KR2    | All KI operations require user confirmation
KR3    | `para_*` prefix reserved for system KIs
KR4    | Summary ≤ 800 characters
KR5    | All operations undoable (archive, not delete)
KR6    | System KIs sync from repo templates via CLI
KR7    | MUST NOT reference ephemeral files (plans, sessions, sprint) in KI metadata

### System KI Lifecycle

```text
repo/templates/knowledge/     CLI install/update       KI Store
para_workspace_*/         ─────────────────────→  ~/.gemini/antigravity/
├─ metadata.json              compare para_version    knowledge/para_*/
└─ artifacts/                 merge strategy:         ├─ metadata.json
                              template wins metadata   ├─ timestamps.json
                              union merge references   └─ artifacts/
                              keep user artifacts
```

### Platform Integration (v1.7.2)

Antigravity platform auto-injects KI summaries at session start. Workflows use injected data — no `index.md` file I/O needed. `.para/knowledge/index.md` is the user-facing reference only.
