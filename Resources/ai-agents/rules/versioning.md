# Versioning Rule

This rule defines how versions are managed across all projects in this workspace.

## 1. Version Format

- Use **Semantic Versioning (SemVer)**: `MAJOR.MINOR.PATCH`.
- Each project maintains its own version independently.
- The **source of truth** for a project's current version is its `CHANGELOG.md` (latest entry) or `package.json` (if applicable).

## 2. Increment Policy

| Level     | When to use                                                         | Example           |
| :-------- | :------------------------------------------------------------------ | :---------------- |
| **PATCH** | Bug fixes, documentation updates, small features, dependency bumps. | `X.Y.1` → `X.Y.2` |
| **MINOR** | Significant new features, architectural changes, new workflows.     | `X.3.Z` → `X.4.0` |
| **MAJOR** | Breaking changes, incompatible API or structure changes.            | `1.Y.Z` → `2.0.0` |

## 3. User Approval (CRITICAL)

- **PATCH**: Agent MAY increment autonomously when the change is clearly a patch (bug fix, docs, small feature).
- **MINOR**: Agent MUST propose the version bump and **wait for user confirmation** before applying. Present the rationale in the session log or conversation.
- **MAJOR**: Agent MUST present a **full implementation plan** and get explicit approval. MAJOR bumps should align with the project's roadmap.

## 4. Version Synchronization

- When bumping a version, update **ALL** locations where the version appears:
  - `CHANGELOG.md` (add new entry at the top)
  - `package.json` (if applicable)
  - UI elements (footers, badges, headers)
  - `README.md` badges (if applicable)
- Use `grep -rn "X.Y.Z" src/` to find all occurrences before committing.

## 5. CHANGELOG Convention

- Follow [Keep a Changelog](https://keepachangelog.com/) format.
- Group changes under: `Added`, `Changed`, `Fixed`, `Removed`.
- Always include the date: `## [X.Y.Z] - YYYY-MM-DD`.

## 6. Cross-Project Version References

- When a **core project** (e.g., `para-workspace`) releases a new version, dependent projects (e.g., `website-paraworkspace`) should sync relevant information but maintain **their own independent version history**.
- Use a "Core Sync" note in the CHANGELOG to document which core version was synced.
