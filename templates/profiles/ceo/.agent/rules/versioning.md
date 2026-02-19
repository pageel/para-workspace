# Versioning Rule

> **Workspace Version:** 1.4.x (PARA Architecture)

Standard policy for managing versions across the PARA Workspace framework and individual projects.

## 1. Version Format

- Adhere to **Semantic Versioning (SemVer)**: `MAJOR.MINOR.PATCH`.
- The current version SHOULD be clearly labeled in the project's contract or relevant configuration files.

## 2. Increment Policy

- **PATCH increments** (e.g., `X.Y.Z` -> `X.Y.Z+1`): Use for bug fixes, documentation clarity, and minor refinements.
- **MINOR increments** (e.g., `X.Y.Z` -> `X.Y+1.0`): Use for significant new features, new core workflows, or architectural refinements.
- **MAJOR increments** (e.g., `X.Y.Z` -> `X+1.0.0`): Reserved for breaking structural changes or complete system overhauls.

## 3. Governance & Approval (CRITICAL)

- **Minor/Major Jumps**: AI agents MUST NOT increment the MINOR or MAJOR version without explicit approval from the USER.
- **Proposal**: If significant improvements warrant a version jump, propose it in the current Session Log and wait for user confirmation.
- **Default Action**: Continue incrementing the **PATCH** number until a release milestone is approved.

## 4. Synchronization

Every version bump MUST involve updating all relevant version labels across workflows, rules, and documentation to ensure internal consistency throughout the workspace.
