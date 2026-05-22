---
name: Docs Templates
description: Sidecar data for /docs workflow — document templates loaded just-in-time when generating docs.
source: catalog
---

# Skill: Docs Templates

> Sidecar Skill for the `/docs` workflow. Contains document templates
> that the Agent loads **only when generating documentation** (Step 6).
>
> **Pattern:** Workflow = Logic → Sidecar Skill = Data Router.

## When to Load

- `/docs new` → Step 6 (Generate Documentation): load relevant template from `references/`
- `/docs review` → NOT needed
- `/docs update` → NOT needed
- `/docs publish` → NOT needed

## References

| File | When | Purpose |
|:--|:--|:--|
| `references/architecture.md` | Project type = any | System overview & component diagram |
| `references/cli.md` | Project type = CLI Tool | Command reference and usage |
| `references/deployment.md` | Project type = Web App, Website | Prerequisites, build, deploy, env vars |
| `references/changelog.md` | No existing changelog | Version history template |
| `references/strategy.md` | Strategy creation (Step 3.5) | Vision, decisions, roadmap alignment |

> **Convention:** Data files live in `references/` (not `templates/`).

## Graph-Awareness

When generating documentation that covers code architecture or features:

> 🔍 If project has `.beads/graph/`, read `para-graph §3.3.2` for the graph-enhanced
> documentation pipeline (build → enrich → context bundle per doc).
> If no graph → proceed with source-only doc writing.

## Docs Freshness Rule

> ⛔ **Stale docs are worse than no docs — they mislead.**
> When Agent modifies code that changes a public interface, it MUST update
> the corresponding documentation in the **same session**.

### Trigger Conditions

Agent MUST check for docs staleness when ANY of these changes occur:

| Change Type | Docs to Update | Example |
|:--|:--|:--|
| API endpoint added/changed | `docs/api/` or inline JSDoc | New route `/api/webhook/sepay` |
| DB schema modified (Drizzle/Prisma) | `docs/architecture.md` or schema docs | Added `payments` table |
| Config format changed | `README.md` setup section, `env.example.txt` | New env var `SEPAY_API_KEY` |
| CLI command added/changed | `docs/cli.md` | New flag `--backup` |
| Public function signature changed | Inline JSDoc + architecture docs | `getDb()` → `getDb(platform?)` |

### Enforcement Protocol

1. **Detect:** After completing a code change, scan `docs/` for files referencing the modified entity.
2. **Update:** Modify the docs to reflect the new behavior. Keep changes minimal and factual.
3. **Log:** Add a note in `sprint-current.md` if docs update is deferred (with reason).

### Anti-Pattern

> "I'll update docs later" — Agent MUST NOT defer docs updates to a separate task
> unless the user explicitly requests it. Docs drift is the #1 cause of onboarding
> confusion in OSS projects.

## Source Verification Protocol

> ⛔ **Anti-Hallucination Guard (v1.8.6):** Every generated doc MUST pass source
> verification before it is considered complete. This is enforced in workflow Step 6.5.

### Guard Header Template

Every document file MUST include this HTML comment after the title:

```markdown
# [Document Title]

<!-- ⚠️ SOURCE-VERIFIED — Cross-referenced with [file1.ts, file2.ts, ...] on YYYY-MM-DD -->
```

The guard header serves as:
1. **Defense against attention decay** — Agent re-reads this header before editing and knows which files to re-verify.
2. **Audit trail** — Reviewers can trace which source files were checked and when.
3. **Freshness signal** — If source files change significantly after the date, docs may need re-verification.

### State Verification Rules

| Scenario | Documentation Requirement |
|:--|:--|
| Config declared + Code uses it | Document as active feature (normal) |
| Config declared + **No code uses it** | Mark: `[Planned — Not yet implemented in source]` |
| Code uses it + No explicit config | Document as runtime-derived or hardcoded |
| Feature removed from code but still in docs | **Remove or update** — stale docs are harmful |

### Verification Checklist (per doc)

| # | Check | Method |
|:--:|:--|:--|
| 1 | All `src/` paths exist | `find` or `ls` on each referenced path |
| 2 | All function names match actual exports | `grep "export.*functionName"` in source |
| 3 | All env vars exist in config or code | `grep` in `wrangler.jsonc` + source files |
| 4 | No feature described as "active" without code | `grep` binding name in `src/` — zero results = `[Planned]` |
| 5 | Guard header present with file list and date | Visual check |

