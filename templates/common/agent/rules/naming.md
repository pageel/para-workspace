# Naming Conventions

> **Workspace Version:** 1.4.x (PARA Architecture)

Standardized naming patterns to ensure consistency, readability, and machine-friendliness across the PARA Workspace.

## 1. File System (Files & Directories)

- **Pattern**: `kebab-case`
- **Rule**: All files and directories MUST use lowercase letters separated by hyphens.
- **Why**: Ensures cross-platform compatibility, URI friendliness, and CLI safety.
- **Examples**:
  - `user-profile.tsx` (Correct)
  - `api-service.js` (Correct)
  - `user_data.json` (Incorrect - use hyphens)

## 2. Source Code

### Components & Classes

- **Pattern**: `PascalCase`
- **Rule**: React/Astro components, Classes, and Types/Interfaces.
- **Examples**: `UserCard`, `AuthService`, `UserProfile`.

### Variables & Functions

- **Pattern**: `camelCase`
- **Rule**: Standard variables, local state, function names, and properties.
- **Examples**: `isLoading`, `calculateTotal()`.

### Constants & Environment Variables

- **Pattern**: `UPPER_SNAKE_CASE`
- **Rule**: Global constants, configuration values, and `.env` keys.
- **Examples**: `MAX_RETRY_COUNT`, `API_BASE_URL`.

## 3. Styling & Markup

### CSS Classes & IDs

- **Pattern**: `kebab-case`
- **Rule**: Use lowercase letters and hyphens (e.g., `.btn-primary`, `#main-content`).

### HTML Data Attributes

- **Pattern**: `kebab-case` (e.g., `data-user-id`).

## 4. Metadata & Intelligence

### Project Metadata (`metadata.json`)

- **Pattern**: `camelCase` for keys.
- **Example**: `"projectName": "para-workspace"`.

### Workflows & Rules

- **Pattern**: `kebab-case`.
- **Examples**: `/new-project`, `naming.md`, `para-discipline.md`.

## 5. Exceptions

- Standard documentation files (**README.md**, **LICENSE**, **VERSION**, **CHANGELOG.md**) follow their specific uppercase conventions.
- Tool-specific config files (e.g., `package.json`, `tsconfig.json`) follow the tool's requirements.
