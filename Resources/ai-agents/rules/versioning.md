# Versioning Rule

This rule defines how versions are managed in this workspace.

## 1. Version Format

- Use Semantic Versioning (SemVer): `MAJOR.MINOR.PATCH`.
- Current release branch: `1.3.4 (Full Sync)`.

## 2. Increment Policy

- **PATCH increments** (`1.3.1` -> `1.3.2`): Used for bug fixes, documentation updates, and small features.
- **MINOR increments** (`1.3.4 (Full Sync)` -> `1.4.0`): Used for significant new features or architectural changes.
- **MAJOR increments**: Used for breaking changes.

## 3. User Approval (CRITICAL)

- Do NOT increment the **MINOR** version (e.g., jumping from `1.3.4 (Full Sync)` to `1.4.0`) without explicit approval from the USER.
- If significant features are added, propose the jump to `1.4.0` in the session log and wait for user confirmation.
- Until approval is granted, continue incrementing the **PATCH** number (e.g., `1.3.2`, `1.3.3`, etc.).
