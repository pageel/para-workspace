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

- **MUST** only write to KI Store via `/para-knowledge` workflow.
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
- System KIs **MUST** only be updated via `/para-knowledge system` or version alignment.
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

- Core workspace System KIs **MUST** ship from workspace kernel templates, while tool-specific System KIs **MUST** ship from their respective tool repo templates (e.g., `repo/templates/knowledge/`).
- `./para update` **SHOULD** only sync core workspace system KIs (e.g., `para_workspace_*`) via `/para-knowledge system update` logic.
- Tool-specific system KIs (e.g., `para_graph_*`) **MUST NOT** be synchronized via `./para update`. Instead, they **MUST** be synchronized using the tool's own update command: `para install-tool <tool-name> --update` (or `--sync` during local development).
- `./para install` **SHOULD** only init core workspace system KI defaults.
- System KI update **MUST** use merge strategy: template wins, user refs preserved.
- System KI archive **MUST** only occur when deprecated by template removal.

### KR7. Ephemeral Reference Ban (v1.7.5)

- **MUST NOT** add ephemeral file paths to KI `references` array.
- Ephemeral paths include:
  - `artifacts/plans/*.md` (archived after completion)
  - `artifacts/tasks/sprint-current.md` (hot lane, changes frequently)
  - `sessions/*.md` (daily logs, high churn)
  - Any file expected to be moved, archived, or deleted
- **MUST** only reference durable files:
  - `project.md`, `.para-workspace.yml` (project config)
  - `.agents/rules/*.md`, `.agents/skills/*.md` (governed libraries)
  - Source code files (`src/`, `repo/`) with stable paths
  - `conversation_id` references (platform-managed)
- **Rationale:** Ephemeral refs become `BROKEN_REF` when source files are archived, degrading KI health scores and traceability.

### KR8. Template Sync on Change

- **MANDATORY**: When making changes to the API interfaces, directory structures, MCP tools, or system workflows, the Agent **MUST** synchronize and update the corresponding source knowledge templates (located in `repo/templates/knowledge/` or `repo/templates/`) before concluding the development plan (last Phase).
- **Rationale**: Prevents Agent knowledge from becoming stale or out-of-sync with tool changes, ensuring the subsequent session loads the correct context without requiring manual user reminders.

## Access Control Matrix

| Operation | User KI | System KI (para_*) | Gate |
| :-- | :-- | :-- | :-- |
| READ | ✅ Free | ✅ Free | Any workflow |
| CREATE | +ask, no para_ | +ask, version aligned | /para-knowledge [system] |
| UPDATE content | +ask | +ask, version check | /para-knowledge [system] |
| UPDATE refs | +ask | ✅ Merge-safe | /para-knowledge [system] |
| UPGRADE version | N/A | Template sync only | /para-knowledge system update |
| ARCHIVE | +ask | Deprecated by template | /para-knowledge |
| DELETE | 🚫 Blocked | 🚫 Blocked | — |

## Related

- `kernel/schema/ki.schema.json` — KI metadata schema
- `kernel/heuristics.md` H10 — Knowledge Items heuristic
- `.agents/workflows/para-knowledge.md` — Primary workflow
