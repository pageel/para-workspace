# PARA Discipline

> Agent governance rule for strict PARA architecture compliance.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. No Loose Files

- **MUST** place every file in a **Project**, **Area**, or **Resource**.
- **MUST NOT** create files directly in the workspace root (except approved CLI tools or core config like `.para-workspace.yml`).

### 2. Directory Mapping

| Category              | Target Directory           |
| --------------------- | -------------------------- |
| Active work           | `Projects/[project-name]/` |
| Stable knowledge/SOPs | `Areas/`                   |
| Reference & learning  | `Resources/`               |
| Completed/cancelled   | `Archive/`                 |
| Uncategorized input   | `_inbox/`                  |

### 3. Project Scoping

- **MUST** stay within the active project directory when working on it.
- **MUST** use full relative paths for cross-project references.
- **SHOULD** prefer creating shared resources in `Resources/` over cross-project file dependencies.

### 4. Resource Immutability

- **MUST NOT** modify files in `Resources/references/` — these are read-only catalog sources.
- **MUST NOT** write local customizations back to the governed catalog source.
- Resources are for learning, scaffolding, and installation only.

### 5. Protected Projects

- **MUST NOT** modify files inside `Projects/para-workspace/repo/` unless the user explicitly states they are performing development on the PARA framework itself.
- **MUST NOT** apply global changes that might side-effect the core framework without a direct command.

### 6. Kernel Compliance

- **MUST** follow the kernel invariants (I1–I10) defined in the governance framework.
- **MUST** use `backlog.md` as the canonical task store via the `/backlog` workflow.
- **MUST NOT** delete files without explicit user approval.

### 7. VCS & Git Boundaries

- **MUST** only perform `git commit`/`git push` within the `repo/` directory of a project.
- **MUST NOT** commit `sessions/`, `docs/`, or `artifacts/` to git unless they are explicitly tracked within `repo/`.
- **MUST NOT** run git commands at the workspace root unless specifically updating the `para-workspace` template repository itself.
