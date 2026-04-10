---
name: Brainstorm Templates
description: Sidecar data for /brainstorm workflow — Decision and Research document templates loaded just-in-time.
source: catalog
---

# Skill: Brainstorm Templates

> Sidecar Skill for the `/brainstorm` workflow. Contains document templates
> that the Agent loads **only when saving structured output** (Step 4).
>
> **Pattern:** Workflow = Logic → Sidecar Skill = Data Router.
> The `/brainstorm` workflow instructs the Agent to read this skill at save time.

## When to Load

- `/brainstorm` → Step 4 (Save Structured Output): load `references/templates/decision.md` (always)
- `/brainstorm` → Step 4 (Research extraction): load `references/templates/research.md` (if user consents)
- Steps 1-3 → NOT needed (no templates)
- Step 5 → NOT needed (no templates)

## References

| File | When | Purpose |
|:--|:--|:--|
| `references/templates/decision.md` | Step 4 — File 1 (always) | Document structure for brainstorm decisions |
| `references/templates/research.md` | Step 4 — File 2 (user consent) | Document structure for extracted research |

> **Convention:** Data files live in `references/` (not `templates/` at skill root).
> This follows the Sidecar Skill convention formalized in v1.7.6.3.

## Extract Paradigm (v1.7.12)

When Step 4 triggers Research extraction:

1. **Brainstorm file is KEPT INTACT** — never modified or split.
2. **Research file is a NEW document** — created via COPY + TRANSFORM from brainstorm content.
3. **User consent is MANDATORY** — Agent must ask before creating File 2.
4. **Threshold:** ≥ 500 lines OR ≥ 5 refinement rounds.
