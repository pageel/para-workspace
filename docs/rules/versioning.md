# Versioning Rule

> **Version**: 1.5.4

Governs version management — when the agent may autonomously bump versions, when it must ask, and how to keep all version locations synchronized.

## Scope

- **Type**: Global (all projects)
- **Priority**: 🟢 Standard
- **Trigger**: Version bumps, changelog updates, releases

## Rules

### 1. Version Format

MUST use Semantic Versioning (`MAJOR.MINOR.PATCH`). MUST label current version in `project.md` frontmatter or `.para-workspace.yml`.

### 2. Agent Autonomy Levels

| Level | Permission | Example |
|:------|:-----------|:--------|
| **PATCH** | Agent MAY increment autonomously | Bug fix, typo |
| **MINOR** | Agent MUST ask user | New feature |
| **MAJOR** | Agent MUST present full plan | Breaking change |

### 3. Approval Gate (CRITICAL)

MUST NOT increment MINOR or MAJOR without explicit user approval. SHOULD propose bumps in session log and wait for confirmation. MUST default to PATCH until a release milestone is approved.

### 4. Synchronization

When bumping a version, MUST update ALL locations:

| Location | File |
|:---------|:-----|
| Changelog | `CHANGELOG.md` (new entry at top) |
| Version file | `VERSION` (if exists at repo root) |
| Project contract | `project.md` frontmatter |
| Package config | `package.json` version (if applicable) |
| UI elements | Footers, badges (if applicable) |

### 5. Governed Library Items

MUST NOT change `kernel_min`/`kernel_max` in `catalog.yml` without understanding compatibility. SHOULD increment item `version` when content changes significantly.

## Related

- [Governance](./governance.md) — Kernel version constraints
- [VCS](./vcs.md) — Git tagging safety
- Full policy: [`VERSIONING.md`](../../VERSIONING.md)
- **Source**: `templates/common/agent/rules/versioning.md`
