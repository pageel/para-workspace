# Global Versioning Rule

This rule defines the standardized versioning logic for the entire PARA Workspace and all its embedded projects.

## 1. Scope & Precedence

- **Global Applicability**: This rule applies to the workspace itself and every project in `Projects/` by default.
- **Project Overrides**: If a specific project has its own `rules/versioning.md` or versioning instructions in `project.md`, those specific rules take precedence over this global one.

## 2. Version Format (SemVer)

- Format: `MAJOR.MINOR.PATCH` (e.g., `1.4.2`).
- Location: Workspace root uses `VERSION` file. Projects use their respective `project.md` YAML or specific version tracking.

## 3. Increment Policy Details

- **PATCH** (`x.y.PATCH`): Bug fixes, internal refactoring, minor documentation, and small features that don't change the user-facing contract.
- **MINOR** (`x.MINOR.z`): New features, significant enhancements, or non-breaking structural changes.
- **MAJOR** (`MAJOR.y.z`): Breaking changes, major architectural shifts, or complete redesigns.
  - **MANDATORY**: A MAJOR update MUST have a formal **Implementation Plan** (e.g., in `artifacts/plans/`) and be explicitly aligned with the project's **Roadmap** (e.g., in `README.md`).

## 4. Propose & Approve Protocol (CRITICAL)

The Agent MUST NOT choose or apply a new version number arbitrarily for any release level increase:

1.  **Analyze**: Determine the suggested scope (Patch, Minor, or Major).
2.  **Propose**: Suggest the **exact next version number** in the conversation/session log.
    - _Example_: "I recommend incrementing the version to `1.3.3` for these bug fixes."
3.  **Approve**: Wait for the USER to explicitly say "OK", "Approve", or similar before updating the version files/metadata.
4.  **Minor/Major Jumps**: Any jump to a new Minor (e.g., `1.3.x` -> `1.4.0`) or Major version **MANDATORILY** requires user confirmation before the change is applied.
