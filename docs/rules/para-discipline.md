# PARA Discipline

> **Version**: 1.5.4

Enforces strict PARA architecture compliance for file organization. Every file must belong to a Project, Area, or Resource — no loose files allowed at the workspace root.

## Scope

- **Type**: Global (all projects)
- **Priority**: 🟡 Important
- **Trigger**: Creating/moving files, organizing workspace

## Rules

### 1. No Loose Files

MUST place every file in a Project, Area, or Resource. MUST NOT create files at workspace root except approved CLI tools or config files.

### 2. Directory Mapping

| Category | Target Directory |
|:---------|:----------------|
| Active work | `Projects/[project-name]/` |
| Stable knowledge/SOPs | `Areas/` |
| Reference & learning | `Resources/` |
| Completed/cancelled | `Archive/` |
| Uncategorized input | `_inbox/` |

### 3. Project Scoping

MUST stay within the active project directory. MUST use full relative paths for cross-project references. SHOULD create shared resources in `Resources/` over cross-project dependencies.

### 4. Resource Immutability

MUST NOT modify files in `Resources/references/`. Resources are for learning, scaffolding, and installation only.

### 5. Protected Projects

MUST NOT modify `Projects/para-workspace/repo/` unless explicitly developing the PARA framework itself.

### 6. Kernel Compliance

MUST follow kernel invariants (I1–I10). MUST use `backlog.md` as canonical task store via `/backlog`. MUST NOT delete files without user approval.

### 7. VCS & Git Boundaries

MUST only `git commit`/`push` within `repo/`. MUST NOT commit `sessions/`, `docs/`, or `artifacts/` unless tracked in `repo/`. MUST NOT run git at workspace root unless updating the template repository.

## Related

- [Overview Architecture](../architecture/overview.md)
- [Governance](./governance.md) — Invariants this rule extends
- [VCS](./vcs.md) — Git boundaries in detail
- **Source**: `templates/common/agent/rules/para-discipline.md`
