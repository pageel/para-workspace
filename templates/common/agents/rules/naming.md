---
description: Naming conventions for files, directories, branches, and commits
trigger: manual
glob:
---

# Naming Conventions

<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->

> Agent governance rule for consistent naming across the workspace.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. File System (Files & Directories)

- **MUST** use `kebab-case` (lowercase letters separated by hyphens).
- **Rationale**: Cross-platform compatibility, URI friendliness, CLI safety.
- Examples: `user-profile.tsx` ✅, `api-service.js` ✅, `user_data.json` ❌

### 2. Source Code

| Object | Convention | Examples |
| -- | -- | -- |
| Components & classes | `PascalCase` | `UserCard`, `AuthService` |
| Variables & functions | `camelCase` | `isLoading`, `calculateTotal()` |
| Constants & env vars | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT`, `API_BASE_URL` |

### 3. Styling & Markup

- **MUST** use `kebab-case` for CSS classes and IDs (e.g., `.btn-primary`, `#main-content`).
- **MUST** use `kebab-case` for HTML data attributes (e.g., `data-user-id`).

### 4. Metadata & Config

- **MUST** use `camelCase` for keys in `.para-workspace.yml` and project metadata.
- Example: `projectName`, `lastSync`.

### 5. Workflows & Rules

- **MUST** use `kebab-case` for workflow and rule filenames.
- Examples: `/new-project`, `naming.md`, `para-discipline.md`.

### 6. Artifacts (Plans, Brainstorms, Tasks)

- **MUST** use `kebab-case`.
- **Generic Principle**: Filenames MUST logically include the artifact **type**, **date**, and **topic**.
- **Date in filenames**: **MUST** use `YYYY-MM-DD` (ISO 8601) for natural sorting. Example: `brainstorm-2026-04-13-topic.md`.
- **Date in content**: **SHOULD** read `preferences.date_format` from `.para-workspace.yml` for display dates (e.g., headers, metadata). Default: `YYYY-MM-DD` if not configured.
- **Exception**: Specific naming formats (e.g., whether to include version numbers or wildcard tokens) are defined inside individual workflow templates and sidecars (e.g., `detail-plan.md` or `/brainstorm`). This rule only enforces generic principles.

### 7. VCS (Branches & Commits)

- **Branches MUST** use `kebab-case` and include a category prefix (e.g., `feature/`, `bugfix/`, `hotfix/`, `release/`).
- **Commits MUST** follow Conventional Commits (e.g., `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `chore:`).

### 8. Backlog IDs

- **MUST** use an uppercase prefix followed by a hyphen and a number.
- **Prefixes**: `FEAT-[N]`, `BUG-[N]`, `IDEA-[N]`, or domain-specific acronyms (e.g., `AUTH-[N]`).
- **Forbidden**: Do not use ad-hoc string hashes or purely numeric IDs.

### 9. Exceptions

- Standard documentation files (`README.md`, `LICENSE`, `VERSION`, `CHANGELOG.md`) follow established uppercase conventions.
- Tool-specific config files (`package.json`, `tsconfig.json`) follow the tool's requirements.
- **Top-level Pillars & Global Areas** (`Projects`, `Areas`, `Resources`, `Learning`, `Workspace`, `Infrastructure`) **MUST** use `PascalCase` to maintain compatibility with core workflows and visual hierarchy.
