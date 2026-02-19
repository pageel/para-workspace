# Data Export Rule

> **Workspace Version:** 1.4.x (PARA Architecture)

Guidelines for exporting data (CSV, XLSX, PDF, etc.) to ensure consistency and prevent workspace clutter.

## 📁 Target Directory

- **All exported files** MUST be saved in the `_inbox/` directory at the workspace root.
- Do NOT save exports directly in the workspace root or project directories.

## 🏷️ File Naming

- Use lowercase alphanumeric characters and hyphens only (`kebab-case`).
- **Standard format**: `[content-type]-[date-or-id].[ext]`
- Example: `product-list.xlsx`, `revenue-report-2025.csv`.

## 📄 Formats & Encoding

- **CSV**: Prefer `CSV UTF-8 with BOM` for maximum compatibility with localized characters (Vietnamese/Unicode).
- **Excel**: Prefer `.xlsx` or `.xls` (Excel XML) based on user preference.
- **Reporting**: Always inform the USER of the exact path where the file was generated.

## 🛠️ Post-Export Actions

- Provide the full absolute path to the file.
- If necessary, provide brief instructions on how to open or process the file (e.g., if using special encodings).
