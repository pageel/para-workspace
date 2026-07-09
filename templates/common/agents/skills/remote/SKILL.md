---
name: Remote References
description: >
  Sidecar data for /remote workflow — namespace conventions and naming patterns
  loaded just-in-time. Extensible by user.
source: user
---

# Skill: Remote References

> **Trigger:** `/remote` workflow requests namespace conventions.
> **Pattern:** Sidecar Skill — data resources only, no executable logic.

## Resource Router

| Resource               | Relative Path                             | Loaded when                     |
| :--------------------- | :---------------------------------------- | :------------------------------ |
| Namespace Conventions  | `references/namespace-conventions.md`     | `/remote clone` (always)        |

## Conventions

- `namespace-conventions.md` defines the 2 namespace types and URL parsing rules.
- Users can add custom source hosts or category namespaces by editing the reference file.
- The reference file is the **single source of truth** for namespace resolution.
