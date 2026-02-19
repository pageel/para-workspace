# PARA Discipline

As a workspace agent, you must strictly follow the PARA architecture.

## 1. No Loose Files

- Every file must belong to a **Project**, an **Area**, or a **Resource**.
- Do not create files directly in the workspace root (except for approved CLI tools or core config).

## 2. Directory Mapping

- **Active Work**: Place in `Projects/<project-name>/`.
- **Infrastructure & Standards**: Place in `Areas/`.
- **Reference & Learning**: Place in `Resources/`.
- **Completed Work**: Move to `Archive/`.

## 3. Project Scoping

- When working on a project, stay within its directory.
- Cross-project references must be handled via full paths or as resources.

## 4. Resource Immutability

- **Read-Only Resources**: Files located in `Resources/` (specifically under `ai-agents/workflows/` or `ai-agents/rules/`) are treated as a **Catalog**.
- **No Reverse Sync**: When a user installs or references a resource, any local customizations (e.g., in `.agent/workflows/`) must **NEVER** be written back to the source in `Resources/` unless explicitly requested.
- **Reference only**: Use resources for learning, scaffolding, or installation. Do not modify the original templates during a regular project task.

## 5. Protected Projects

- **Framework Protection**: The `para-workspace` project is the source of truth for the workspace standards.
- **Explicit Instruction**: Do not modify any files inside `Projects/para-workspace/repo/` unless the user explicitly states they are performing development on the PARA framework itself.
- **Safety**: Avoid applying global changes that might side-effect the core framework without a direct command.

## 6. VCS & Git Boundaries

- **The `repo/` Folder**: This is the primary Git repository for the project.
- **Git Operations**: You MUST ONLY consider `git commit` or `git push` if there are changes within the `repo/` directory.
- **Local Metadata**: Changes in `docs/`, `sessions/`, or `artifacts/` are project management metadata. These SHOULD NOT be committed or pushed unless they are explicitly tracked within the `repo/` (e.g., `repo/docs/`).
- **Safety**: Never run Git commands at the project root or workspace root unless specifically updating the `para-workspace` template repository itself.
