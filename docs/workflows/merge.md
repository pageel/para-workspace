# /merge Workflow

> **Version**: 1.5.0

The `/merge` workflow intelligently merges a user's customized workflow with the latest version from the governed catalog. It preserves user modifications while injecting new improvements.

## Commands

```
/merge open       # Merge local /open with catalog version
/merge backlog    # Merge local /backlog with catalog version
```

## Merge Flow

```
Load both files → Semantic analysis → Intelligent merge → Backup & apply → Verify
```

### 1. Load Context

Reads both the local (`.agent/workflows/[target].md`) and catalog versions of the workflow.

### 2. Semantic Analysis

- **Identify Customizations**: User-specific steps, variables, project logic
- **Identify Updates**: New features, improved prompts from catalog
- **Identify Deprecations**: Old CLI flags, legacy paths

### 3. Intelligent Merge Strategy

| Action       | Description                                                   |
| :----------- | :------------------------------------------------------------ |
| **Preserve** | Keep all user variables, custom steps, project-specific logic |
| **Inject**   | Add new catalog sections that don't conflict with user intent |
| **Update**   | Upgrade deprecated syntax to new standards                    |

### 4. Apply

Creates a `.bak` backup, writes merged content, and displays a summary of preserved/injected/upgraded sections for user confirmation.

## Related

- [/install Workflow](./install.md) — Install with conflict resolution
- [Workflow Documentation](../workflows.md) — Workflow catalog

---

_Added in v1.5.0_
