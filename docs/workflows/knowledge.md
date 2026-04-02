# Workflow `/knowledge` — Knowledge Items Management

> **Version**: 1.7.2 | **Last reviewed**: 2026-04-02

## Overview

Manages Knowledge Items (KI) — persistent cross-session memory for AI agents. Provides 8 operations: dashboard, create/update (user + system), audit, archive, system sync, and system defaults.

Since v1.7.2, other workflows (`/open`, `/end`, `/plan`...) use **platform-injected KI data** instead of reading `index.md` — reducing I/O and token overhead. `.para/knowledge/index.md` (12 columns + per-KI artifact listing with file links) is a **user-facing reference** only.

## Syntax

```text
/knowledge                       → 📊 Dashboard
/knowledge [topic]               → ✏️ Smart Create/Update (user KI)
/knowledge system [topic]        → 🏛️ System KI Create/Update
/knowledge system update         → 🔄 Sync system KIs from repo templates
/knowledge system defaults       → 📦 Init default system KIs
/knowledge audit                 → 🔍 Full health check
/knowledge archive [#]           → 📦 Retire a KI
/knowledge [#]                   → 🔍 View KI details
```

## Execution Flow

```text
/knowledge → Ensure .para/knowledge/ → Route action → Execute → Update index
```

### Dashboard

Scans all KIs in KI Store, calculates health, renders visual table with System KIs (`para_*`) and User KIs sections.

### Smart Create/Update

Fuzzy-matches topic against existing KIs. Match >70% → UPDATE, otherwise → CREATE. Namespace guard enforces `para_*` for system KIs only.

### System KI Sync

Scans `repo/templates/knowledge/` → compares with KI Store. Newer template → upgrade (merge-safe). New KI → prompt install.

## Governance

Rule | Description
:----|:-------------------------------------------
KR1  | Only `/knowledge` workflow can WRITE to KI Store
KR2  | User MUST confirm before any mutation
KR3  | `para_*` reserved for system KIs
KR4  | MUST NOT touch `~/.gemini/` outside `knowledge/`
KR5  | Archive instead of delete, idempotent writes
KR6  | System KIs ship from repo, sync via update

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
