# Versioning Rule

> Agent governance rule for version management.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. Version Format

- **MUST** use Semantic Versioning (`MAJOR.MINOR.PATCH`) for all projects and the workspace.
- **MUST** clearly label the current version in `project.md` (frontmatter) or `.para-workspace.yml`.

### 2. Agent Autonomy Levels

| Level     | Agent Permission                     |
| --------- | ------------------------------------ |
| **PATCH** | Agent MAY increment autonomously     |
| **MINOR** | Agent MUST ask user for approval     |
| **MAJOR** | Agent MUST present a full plan first |

### 3. Approval Gate (CRITICAL)

- **MUST NOT** increment MINOR or MAJOR version without explicit user approval.
- **SHOULD** propose version bumps in the current session log and wait for confirmation.
- **MUST** default to PATCH increments until a release milestone is approved by the user.

### 4. Synchronization

When bumping a version, **MUST** update ALL relevant locations:

- `CHANGELOG.md` (new entry at top)
- `VERSION` file (if repo root)
- `project.md` frontmatter (if project)
- `package.json` version field (if applicable)
- UI elements: footers, badges (if applicable)

### 5. Governed Library Items

- **MUST NOT** change `kernel_min` or `kernel_max` in `catalog.yml` without understanding compatibility implications.
- **SHOULD** increment item `version` in `catalog.yml` when the item's content changes significantly.

## Reference

For the full versioning policy (kernel tracks, build convention, compatibility matrix), see [`VERSIONING.md`](../../Projects/para-workspace/repo/VERSIONING.md) in the repo root.
