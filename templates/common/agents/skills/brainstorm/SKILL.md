---
name: Brainstorm Templates
description: Sidecar data for /brainstorm workflow — Brainstorm (open), Decision (finalized), and Research document templates loaded just-in-time.
source: catalog
---

# Skill: Brainstorm Templates

> Sidecar Skill for the `/brainstorm` workflow. Contains document templates
> that the Agent loads **only when saving structured output** (Step 4).
>
> **Pattern:** Workflow = Logic → Sidecar Skill = Data Router.
> The `/brainstorm` workflow instructs the Agent to read this skill at save time.

## When to Load

- `/brainstorm` → Step 4 (Open brainstorm): load `references/templates/brainstorm.md`
- `/brainstorm` → Step 4 (Finalized decision): load `references/templates/decision.md`
- `/brainstorm` → Step 4 (Research extraction): load `references/templates/research.md` (if user consents)
- Steps 1-3 → NOT needed (no templates)
- Step 5 → NOT needed (no templates)

## References

| File | When | Purpose |
|:--|:--|:--|
| `references/templates/brainstorm.md` | Step 4 — Open exploration | Living document for ongoing research, appendable across sessions |
| `references/templates/decision.md` | Step 4 — Finalized decision | Frozen document for concluded brainstorms with chosen option |
| `references/templates/research.md` | Step 4 — File 2 (user consent) | Document structure for extracted research |

> **Convention:** Data files live in `references/` (not `templates/` at skill root).
> This follows the Sidecar Skill convention formalized in v1.7.6.3.

## Naming Conventions

| Type | Directory | Filename Pattern | Has Date Prefix |
|:--|:--|:--|:--|
| Open Brainstorm | `artifacts/brainstorms/` | `brainstorm-[topic-slug].md` | ❌ No date — living document |
| Decision | `artifacts/para-decisions/` | `brainstorm-[YYYY-MM-DD]-[topic-slug].md` | ✅ Yes — point-in-time snapshot |

## Lifecycle

```
brainstorms/brainstorm-[topic].md (Open, append across sessions)
        │
        ▼  When user finalizes a decision
para-decisions/brainstorm-YYYY-MM-DD-[topic].md (Frozen, cross-refs brainstorm)
```

- Agent MAY append new entries to an Open brainstorm without creating a new file.
- When promoting to Decision, Agent MUST create a NEW file in `para-decisions/` — NOT move the brainstorm.
- The brainstorm file STAYS in `brainstorms/` as historical record.

## Extract Paradigm (v1.7.12)

When Step 4 triggers Research extraction:

1. **Brainstorm file is KEPT INTACT** — never modified or split.
2. **Research file is a NEW document** — created via COPY + TRANSFORM from brainstorm content.
3. **User consent is MANDATORY** — Agent must ask before creating File 2.
4. **Threshold:** ≥ 500 lines OR ≥ 5 refinement rounds.

## Graph-Awareness

When brainstorming about code architecture or implementation:

> 🔍 If project has `.beads/graph/`, read `para-graph §3.3.3` for codebase
> understanding pipeline (query structure → context bundle → informed discussion).
> If no graph → proceed with source-only brainstorming.
