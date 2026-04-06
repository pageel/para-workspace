# Workflow `/para-knowledge` — Knowledge Items Management

> **Version**: 1.7.5 | **Last reviewed**: 2026-04-06

## Overview

Manages Knowledge Items (KI) — persistent cross-session memory for AI agents. Provides 8 operations: dashboard, create/update (user + system), audit, archive, system sync, and system defaults.

Since v1.7.2, other workflows (`/open`, `/end`, `/plan`...) use **platform-injected KI data** instead of reading `index.md` — reducing I/O and token overhead. `.para/knowledge/index.md` (12 columns + per-KI artifact listing with file links) is a **user-facing reference** only.

## Syntax

```text
/para-knowledge                       → 📊 Dashboard
/para-knowledge [topic]               → ✏️ Smart Create/Update (user KI)
/para-knowledge system [topic]        → 🏛️ System KI Create/Update
/para-knowledge system update         → 🔄 Sync system KIs from repo templates
/para-knowledge system defaults       → 📦 Init default system KIs
/para-knowledge audit                 → 🔍 Full health check
/para-knowledge archive [#]           → 📦 Retire a KI
/para-knowledge [#]                   → 🔍 View KI details
```

## Execution Flow

```text
/para-knowledge → Ensure .para/knowledge/ → Route action → Execute → Update index
```

### Dashboard

Scans all KIs in KI Store, calculates health, renders visual table with System KIs (`para_*`) and User KIs sections.

### Smart Create/Update

Fuzzy-matches topic against existing KIs. Match >70% → UPDATE, otherwise → CREATE. Namespace guard enforces `para_*` for system KIs only.

**Slug naming convention** (v1.7.3):
- Project-specific: `project_{project_name}` (e.g., `project_my_app`)
- Topic/domain: descriptive slug (e.g., `astro_migration_patterns`)
- System: `para_{domain}_{topic}` (reserved, enforced by KR3)

### System KI Sync

Scans `repo/templates/knowledge/` → compares with KI Store using dual-gate (v1.7.3): version comparison + content hash comparison. Newer or changed template → upgrade (merge-safe). New KI → prompt install.

## Governance

Rule | Description
:----|:-------------------------------------------
KR1  | Only `/para-knowledge` workflow can WRITE to KI Store
KR2  | User MUST confirm before any mutation
KR3  | `para_*` reserved for system KIs
KR4  | MUST NOT touch `~/.gemini/` outside `knowledge/`
KR5  | Archive instead of delete, idempotent writes
KR6  | System KIs ship from repo, sync via update
KR7  | No ephemeral file paths in KI references (v1.7.5)

## Workflow Integration

Workflow      | Integration
:-------------|:--------------------------------------------
`/open`       | Platform-injected KI context, scope match (v1.7.2)
`/end`        | Suggests KI create/update from platform data (v1.7.2)
`/plan`       | Pitfall KIs → Risks, Playbook KIs → Phase tasks (v1.7.2)
`/brainstorm` | Option F: Extract insight as KI
`/retro`      | Graduation ritual: patterns → KI
`/learn`      | Lesson → KI suggestion (v1.7.2)
`/para-audit` | KI health in macro audit

---

_See also: [Knowledge System Architecture](../architecture/knowledge-system.md) · [Knowledge Rule](../rules/knowledge.md) · [KI Schema](../../kernel/schema/ki.schema.json)_
