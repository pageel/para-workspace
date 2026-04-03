# Data Export Rule

> **Version**: 1.5.4

Ensures exported files (CSV, XLSX, PDF, etc.) are saved to the correct location, named consistently, and use proper encoding for Unicode/international characters.

## Scope

- **Type**: Global (all projects)
- **Priority**: 🟢 Standard
- **Trigger**: Exporting data, sharing files externally

## Rules

### 1. Target Directory

MUST save all exported files to `_inbox/` at the workspace root. MUST NOT save exports at workspace root or inside project directories.

### 2. File Naming

MUST use `kebab-case`. MUST follow format: `[content-type]-[date-or-id].[ext]`.

✅ `product-list.xlsx`, `revenue-report-2025.csv` · ❌ `ProductList.xlsx`, `report final v2.csv`

### 3. Formats & Encoding

SHOULD prefer CSV UTF-8 with BOM for maximum Unicode compatibility. SHOULD prefer `.xlsx` for Excel based on user preference. MUST inform user of the exact file path.

### 4. Post-Export Actions

MUST provide the full path to the exported file. SHOULD provide brief instructions for special encodings.

## Related

- [PARA Discipline](./para-discipline.md) — `_inbox/` directory mapping
- [Naming Conventions](./naming.md) — kebab-case convention
- **Source**: `templates/common/agents/rules/exports-data.md`
