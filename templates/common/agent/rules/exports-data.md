# Data Export Rule

> Agent governance rule for data export consistency and safety.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. Target Directory

- **MUST** save all exported files (CSV, XLSX, PDF, etc.) to the `_inbox/` directory at the workspace root.
- **MUST NOT** save exports directly in the workspace root or inside project directories.

### 2. File Naming

- **MUST** use `kebab-case` (lowercase alphanumeric and hyphens only).
- **MUST** follow the format: `[content-type]-[date-or-id].[ext]`
- Examples: `product-list.xlsx`, `revenue-report-2025.csv`.

### 3. Formats & Encoding

- **SHOULD** prefer `CSV UTF-8 with BOM` for maximum compatibility with localized characters (Vietnamese/Unicode).
- **SHOULD** prefer `.xlsx` format for Excel files based on user preference.
- **MUST** inform the user of the exact path where the file was generated.

### 4. Post-Export Actions

- **MUST** provide the full path to the exported file.
- **SHOULD** provide brief instructions on how to open or process the file if using special encodings.
