# Naming Conventions

Standardized naming patterns for the Pageel Workspace to ensure consistency, readability, and machine-friendliness.

## 1. File System (Files & Directories)

- **Pattern**: `kebab-case`
- **Rule**: All files and directories MUST use lowercase letters separated by hyphens.
- **Why**: Ensures cross-platform compatibility, URI friendliness, and CLI safety.
- **Examples**:
  - `user-profile.tsx` (Correct)
  - `UserProfile.tsx` (Incorrect)
  - `api-service.js` (Correct)
  - `user_data.json` (Incorrect - use hyphens)

## 2. Source Code

### Components & classes

- **Pattern**: `PascalCase`
- **Rule**: React/Astro components, Classes, and Types/Interfaces.
- **Examples**:
  - `export const UserCard = () => ...`
  - `class AuthService { ... }`
  - `interface UserProfile { ... }`

### Variables & Functions

- **Pattern**: `camelCase`
- **Rule**: Standard variables, local state, function names, and properties.
- **Examples**:
  - `const isLoading = true`
  - `function calculateTotal() { ... }`
  - `const [userList, setUserList] = useState([])`

### Constants & Environment Variables

- **Pattern**: `UPPER_SNAKE_CASE`
- **Rule**: Global constants, configuration values, and `.env` keys.
- **Examples**:
  - `export const MAX_RETRY_COUNT = 5`
  - `const API_BASE_URL = 'https://api.example.com'`
  - `PUBLIC_ANALYTICS_ID`

## 3. Styling & Markup

### CSS Classes & IDs

- **Pattern**: `kebab-case`
- **Rule**: Use lowercase letters and hyphens.
- **Examples**: `.btn-primary`, `#main-content`, `.card--active`

### HTML Attributes (Data Attributes)

- **Pattern**: `kebab-case`
- **Examples**: `data-user-id`, `data-is-active`

## 4. Metadata & Intelligence

### Project Metadata (`metadata.json`)

- **Pattern**: `camelCase` for keys.
- **Examples**: `"projectName": "para-workspace"`, `"lastSync": "2026-02-09"`

### Workflows & Rules

- **Pattern**: `kebab-case`
- **Examples**: `/new-project`, `naming.md`, `para-discipline.md`

## 5. Exceptions

- **README.md** and other standard documentation files (e.g., **LICENSE**, **VERSION**, **CHANGELOG.md**) follow their specific uppercase conventions.
- Files required by specific tools (e.g., `package.json`, `tsconfig.json`, `.pageelrc.json`) follow the tool's requirements.
