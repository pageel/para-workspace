# Naming Conventions

> **Version**: 1.5.4

Standardizes naming across the workspace — file system, source code, CSS, and metadata. Goal: consistency, cross-platform compatibility, and readability for both humans and AI.

## Scope

- **Type**: Global (all projects)
- **Priority**: 🟢 Standard
- **Trigger**: Creating files, directories, branches, commits

## Rules

### 1. File System

MUST use `kebab-case` (lowercase, hyphens). Cross-platform safe, URI friendly, CLI safe.

✅ `user-profile.tsx`, `api-service.js` · ❌ `user_data.json`, `UserProfile.tsx`

### 2. Source Code

| Object | Convention | Examples |
|:-------|:-----------|:--------|
| Components & classes | `PascalCase` | `UserCard`, `AuthService` |
| Variables & functions | `camelCase` | `isLoading`, `calculateTotal()` |
| Constants & env vars | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT`, `API_BASE_URL` |

### 3. Styling & Markup

MUST use `kebab-case` for CSS classes/IDs (`.btn-primary`, `#main-content`) and HTML data attributes (`data-user-id`).

### 4. Metadata & Config

MUST use `camelCase` for keys in `.para-workspace.yml` and project metadata (`projectName`, `lastSync`).

### 5. Workflows & Rules

MUST use `kebab-case` for filenames: `/new-project`, `naming.md`, `para-discipline.md`.

### 6. Exceptions

- Standard docs: `README.md`, `LICENSE`, `VERSION`, `CHANGELOG.md` (uppercase convention)
- Tool configs: `package.json`, `tsconfig.json` (tool requirements)
- Top-level Pillars: `Projects`, `Areas`, `Resources`, `Archive` (PascalCase for visual hierarchy)

## Quick Reference

```
File          → kebab-case
Component     → PascalCase
Variable      → camelCase
Constant      → UPPER_SNAKE_CASE
CSS class     → kebab-case
Config key    → camelCase
Pillar folder → PascalCase
```

## Related

- [PARA Discipline](./para-discipline.md) — File organization
- [VCS](./vcs.md) — Commit message conventions
- **Source**: `templates/common/agent/rules/naming.md`
