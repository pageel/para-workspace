# Naming Conventions

> Agent governance rule for consistent naming across the workspace.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. File System (Files & Directories)

- **MUST** use `kebab-case` (lowercase letters separated by hyphens).
- **Rationale**: Cross-platform compatibility, URI friendliness, CLI safety.
- Examples: `user-profile.tsx` ✅, `api-service.js` ✅, `user_data.json` ❌

### 2. Source Code

| Object                | Convention         | Examples                          |
| --------------------- | ------------------ | --------------------------------- |
| Components & classes  | `PascalCase`       | `UserCard`, `AuthService`         |
| Variables & functions | `camelCase`        | `isLoading`, `calculateTotal()`   |
| Constants & env vars  | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT`, `API_BASE_URL` |

### 3. Styling & Markup

- **MUST** use `kebab-case` for CSS classes and IDs (e.g., `.btn-primary`, `#main-content`).
- **MUST** use `kebab-case` for HTML data attributes (e.g., `data-user-id`).

### 4. Metadata & Config

- **MUST** use `camelCase` for keys in `.para-workspace.yml` and project metadata.
- Example: `projectName`, `lastSync`.

### 5. Workflows & Rules

- **MUST** use `kebab-case` for workflow and rule filenames.
- Examples: `/new-project`, `naming.md`, `para-discipline.md`.

### 6. Exceptions

- Standard documentation files (`README.md`, `LICENSE`, `VERSION`, `CHANGELOG.md`) follow established uppercase conventions.
- Tool-specific config files (`package.json`, `tsconfig.json`) follow the tool's requirements.
- **Top-level Pillars & Global Areas** (`Projects`, `Areas`, `Resources`, `Learning`, `Workspace`, `Infrastructure`) **MUST** use `PascalCase` to maintain compatibility with core workflows and visual hierarchy.
