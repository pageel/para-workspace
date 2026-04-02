---
description: Knowledge Item governance — create, update, delete KI operations
trigger: always_on
glob: .para/knowledge/*
---

# Knowledge Rules

<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->

> Agent governance rule for Knowledge Item (KI) operations.
> Priority: 🔴 Critical

## Scope

- [x] Global (applies to entire workspace)

## Rules

### KR1. Write Gate

- **MUST** only write to KI Store via `/knowledge` workflow.
- **Allowed hooks**: `/end`, `/brainstorm`, `/retro` MAY suggest KI creation.
- **MUST NOT** create or modify KIs outside these entry points.

### KR2. User Approval

- **MUST** obtain explicit user confirmation before any KI mutation.
- **MUST NOT** auto-create KIs silently.
- **MUST NOT** update KIs without user awareness.
- Operations: CREATE, UPDATE, ARCHIVE all require `+ask`.
- DELETE is **prohibited** — use ARCHIVE instead.

### KR3. Namespace Separation

- System KIs (`owner: para`) slug **MUST** start with `para_` prefix.
- System KIs **MUST** only be updated via `/knowledge system` or version alignment.
- User KIs **MUST NOT** use the `para_` prefix.
- Agent **MUST** reject user KI creation if slug starts with `para_`.
- All slugs **MUST** match `^[a-z0-9_]{3,60}$` — no path separators.

### KR4. Zone Boundary

- **MUST NOT** touch `~/.gemini/` outside `knowledge/` and `knowledge/.archived/`.
- `brain/`, `config`, and other system directories are **FORBIDDEN**.
- Slug **MUST** be validated before any I/O — reject path traversal attempts.

### KR5. Recoverability

- All writes **MUST** be idempotent and recoverable.
- **MUST** archive instead of delete — never use `rm -rf` on KI directories.
- CREATE **MUST** check for slug collision before `mkdir`.
- If slug already exists → route to UPDATE, do NOT silently overwrite.

### KR6. System KI Governed Lifecycle (v1.7.1)

- System KIs **MUST** ship from `repo/templates/knowledge/` (source of truth).
- `./para update` **SHOULD** sync system KIs via `/knowledge system update` logic.
- `./para install` **SHOULD** init system KI defaults from templates.
- System KI update **MUST** use merge strategy: template wins, user refs preserved.
- System KI archive **MUST** only occur when deprecated by template removal.

## Access Control Matrix

| Operation       | User KI        | System KI (para_*)      | Gate                  |
|:----------------|:---------------|:------------------------|:----------------------|
| READ            | ✅ Free        | ✅ Free                 | Any workflow          |
| CREATE          | +ask, no para_ | +ask, version aligned   | /knowledge [system]   |
| UPDATE content  | +ask           | +ask, version check     | /knowledge [system]   |
| UPDATE refs     | +ask           | ✅ Merge-safe           | /knowledge [system]   |
| UPGRADE version | N/A            | Template sync only      | /knowledge system update |
| ARCHIVE         | +ask           | Deprecated by template  | /knowledge            |
| DELETE          | 🚫 Blocked    | 🚫 Blocked             | —                     |

## Related

- `kernel/schema/ki.schema.json` — KI metadata schema
- `kernel/heuristics.md` H10 — Knowledge Items heuristic
- `.agents/workflows/knowledge.md` — Primary workflow
