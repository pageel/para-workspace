# Governance & Extension: Kernel, Catalogs, and Agent Protocol

PARA Workspace v1.6.x uses a formalized governance layer with three tiers: Constitutional (immutable kernel), Governed (catalog-managed libraries), and Local (project-specific customizations).

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
- **Heuristics (H1–H9):** Soft rules — strongly recommended, flexible based on context.
  - **Ecosystem (H7 v1.6.0+):** Cross-project `@` prefix, ecosystem meta-projects
  - **Governed Catalogs (H9):** `catalog.yml` mandatory for all libraries

## 3. Catalog System (v1.4.1+)

The `catalog.yml` mechanism formalizes how workflows, rules, and skills are introduced.

### Required Fields Per Item

| Field        | Required | Description                        |
|:-------------|:---------|:-----------------------------------|
| `id`         | ✅       | Stable kebab-case identifier       |
| `name`       | ✅       | Human-readable name                |
| `version`    | ✅       | Semver version                     |
| `kernel_min` | ✅       | Minimum kernel version required    |
| `kernel_max` | ❌       | Optional max kernel version        |
| `entrypoint` | ✅       | Relative path to markdown file     |
| `description`| ✅       | Short description                  |

### Sync Logic

1. `para update` → pulls new repo
2. `para install` → reads catalogs, validates `kernel_min`/`kernel_max`
3. Files projected into workspace: read-only snapshot → `Resources/ai-agents/`, customizable → `.agent/`
4. Incompatible items skipped with clear warning

## 4. Agent Protocol (v1.6.2+)

### Two-Level Index System

- **Workspace level:** `.agent/rules.md` + `.agent/skills.md` — ALWAYS loaded by `/open`
- **Project level:** `Projects/<slug>/.agent/rules.md` — CONDITIONAL, gated by `agent.rules: true` in project.md

### Trigger Table Format

```markdown
| Rule/Skill | Trigger                              | File              | Pri |
|:-----------|:-------------------------------------|:------------------|:----|
| Name       | When this action matches             | path/to/file.md   | 🔴  |
```

### Proactive Trigger Protocol

**Check THEN act — never act THEN check.**

BEFORE any side-effect action:
1. Scan workspace rules trigger table
2. Scan workspace skills trigger table
3. Scan project triggers (if loaded)
4. IF match → load rule/skill BEFORE proceeding

### Agent Recovery

If rules/skills forgotten after context truncation:
- Re-read `.agent/rules.md` + `.agent/skills.md`
- Re-read project rules if `agent.rules: true`

## 5. Rules Library (10 workspace rules)

| Rule                    | Trigger                              | Priority |
|:------------------------|:-------------------------------------|:---------|
| Governance              | Touching kernel/, .para/, Resources/ | 🔴 High  |
| VCS                     | Git commit, push, merge, branch, tag | 🔴 High  |
| Hybrid 3-File Integrity | Reading/writing artifacts/tasks/     | 🟡 Med   |
| Context Rules           | Loading context, starting session    | 🟡 Med   |
| Agent Behavior          | Communication, formatting, recovery  | 🟡 Med   |
| PARA Discipline         | Creating/moving files, organizing    | 🟡 Med   |
| Artifact Standard       | Creating/editing artifacts, plans    | 🟢 Low   |
| Naming                  | Creating files, directories, branches| 🟢 Low   |
| Versioning              | Version bumps, changelog updates     | 🟢 Low   |
| Exports Data            | Exporting data, sharing externally   | 🟢 Low   |

## 6. Skills Library (3 skills, v1.6.4+)

Skills are folder-based, standalone, English-first instruction sets:

| Skill      | Trigger                                    | Structure                |
|:-----------|:-------------------------------------------|:-------------------------|
| PARA Kit   | PARA structure, schema, kernel governance  | SKILL.md + templates/ + examples/ |
| Formatting | Tables, diagrams, trees, visual markdown   | SKILL.md (self-contained) |
| Page Map   | Website visual structure, PAGE_MAP.md      | SKILL.md (self-contained) |

Skills were promoted from rules (experiment from pageel-cms dogfooding, v1.6.4). Key difference: rules are constraint-focused (do/don't), skills are capability-focused (how-to + templates).
