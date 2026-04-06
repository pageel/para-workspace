# Knowledge Workflow Guide

> **Version**: 1.7.2 | **Last reviewed**: 2026-04-02

## Overview

`/para-knowledge` manages Knowledge Items (KIs) — persistent cross-session memory for AI agents. This guide covers all 8 operations and how the Knowledge System integrates with other workflows.

## Quick Reference

```text
/knowledge                  → Dashboard (visual table)
/knowledge [topic]          → Smart Create/Update (user KI)
/knowledge system [topic]   → System KI Create/Update
/knowledge system update    → Sync system KIs from repo
/knowledge system defaults  → Init default system KIs
/knowledge audit            → Full health check + report
/knowledge archive [#]      → Retire a KI (Smart Archive)
/knowledge [#]              → View KI details
```

## 1. Dashboard

Displays all KIs in two sections: **System KIs** (`para_*`) and **User KIs**.

Health is calculated per KI:

Health     | Condition
:----------|:-------------------------------------------
✅ Healthy | Modified <30 days, all refs valid, ≥1 artifact
⚠️ Stale   | Modified 30-90 days, OR ≥1 broken ref
🔴 Critical| Modified >90 days, OR >50% broken refs

After rendering, automatically saves `.para/knowledge/index.md` (12-column schema + per-KI artifact listing with clickable `file:///` links).

## 2. Smart Create/Update

Fuzzy-matches `[topic]` against existing KI titles. Match >70% → proposes UPDATE. Otherwise → proposes CREATE. Always requires user confirmation (KR2).

**Namespace guard (v1.7.1):** Slugs starting with `para_` trigger System KI mode. User KIs cannot use `para_` prefix.

## 3. System KI Routes

System KI         | Description
:-----------------|:-------------------------------------------
`system [topic]`  | Create/update with version alignment + template baseline
`system update`   | Scan templates → upgrade if `para_version` changed
`system defaults` | Init all default system KIs from templates (skip existing)

> Also triggered automatically by `./para install` and `./para update` CLI hooks.

## 4. Audit

Runs full health check on all KIs. Validates reference integrity, freshness, artifact count. Results saved to `.para/knowledge/reports/audit-YYYY-MM-DD.md`.

## 5. Archive

Moves KI to `knowledge/.archived/` — never deletes (KR5). Requires user confirmation (KR2).

## 6. Workflow Integration (v1.7.2)

Workflow      | Integration
:-------------|:--------------------------------------------
`/open`       | Platform-injected KI context, scope match
`/end`        | Suggests KI create/update from session
`/plan`       | Pitfall → Risks, Playbook → Phase refs
`/brainstorm` | Option F: Extract insight as KI
`/retro`      | Graduate patterns to KIs
`/learn`      | KI suggestion after lesson capture

> **v1.7.2:** Workflows use platform-injected data instead of reading `index.md` (0 file I/O).

## 7. Workspace Artifacts

```text
.para/knowledge/
├── index.md              # User-facing KI reference (auto-generated)
└── reports/
    └── audit-YYYY-MM-DD.md   # Audit trail
```

---

_See also: [Knowledge System Architecture](../architecture/knowledge-system.md) · [Knowledge Rule](../rules/knowledge.md) · [KI Schema](../../kernel/schema/ki.schema.json)_
