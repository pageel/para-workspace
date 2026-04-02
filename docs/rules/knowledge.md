# Knowledge Rule — KI Operations Governance

> **Version**: 1.7.2 | **Last reviewed**: 2026-04-02

## Overview

Governance rule for Knowledge Item (KI) operations — the persistent cross-session memory system for AI agents. KI Store lives **outside** the workspace (`~/.gemini/antigravity/knowledge/`), making this rule critical for data protection.

## Scope

- **Type**: Global (entire workspace)
- **Priority**: 🔴 Critical
- **Trigger**: Creating, updating, or archiving Knowledge Items

## Hard Rules: KR1-KR6

Rule | Description
:----|:--------------------------------------------------
KR1  | Only `/knowledge` workflow (and hooks from `/end`, `/brainstorm`, `/retro`) can WRITE to KI Store
KR2  | All mutations require explicit user confirmation
KR3  | `para_*` prefix reserved for system KIs. User KIs rejected if using `para_` prefix
KR4  | MUST NOT touch `~/.gemini/` outside `knowledge/` and `knowledge/.archived/`
KR5  | All writes must be idempotent + recoverable. Archive instead of delete
KR6  | System KIs ship from repo templates, sync via `./para update` (v1.7.1)

## Soft Rules: KS1-KS5

Rule | Guideline
:----|:---------------------------------------------------
KS1  | Platform injects KI summaries at session start — agent uses injected data (0 file I/O)
KS2  | Suggest KI creation when `/end` detects new insights
KS3  | KI scope SHOULD match ecosystem structure
KS4  | Freshness review every 30 days
KS5  | Each artifact ≤200 lines, summary ≤800 chars

> **v1.7.2 change:** KS1 updated from "read KI before task" → "platform injects, agent uses directly" (0 file I/O).

## Kernel H10 — 11 Clauses

1. MUST comply with `ki.schema.json`
2. MUST have ≥1 artifact file
3. SHOULD create/update via `/knowledge` workflow
4. scope MUST be: workspace | project | ecosystem
5. Agent MUST verify KI content against current code
6. KIs with >50% broken refs MUST be updated or archived
7. summary MUST be ≤800 characters
8. System KI slugs MUST start with `para_`
9. System KIs MUST NOT be edited ad-hoc by users
10. User KIs MUST NOT use `para_` prefix
11. slug MUST match `^[a-z0-9_]{3,60}$`

## Access Control

```text
Operation   .para/knowl/  User KI   para_ KI   brain/config
READ        ✅ free       ✅ free   ✅ free    🚫
CREATE      ✅ auto       ✅ +ask   🔒 ver.    🚫
UPDATE      ✅ auto       ✅ +ask   🔒 ver.    🚫
ARCHIVE     N/A           ✅ +ask   🔒 ver.    🚫
DELETE      🚫           🚫       🚫        🚫
```

---

_See also: [Knowledge System Architecture](../architecture/knowledge-system.md) · [Knowledge Workflow](../workflows/knowledge.md) · [Heuristics H10](../../kernel/heuristics.md)_
