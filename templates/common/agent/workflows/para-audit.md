---
description: Macro Assessor to check structural drift against Kernel Specs
source: catalog
---

# /para-audit [action]

> **Workspace Version:** 1.5.3 (Hot Lane)

Strict workspace macro-assessor. Two modes: full structural audit against Kernel Specs (I1-I11), or post-update compliance check with version-aware suggestions.

## Actions

| Action      | Description                                                  |
| :---------- | :----------------------------------------------------------- |
| _(default)_ | Full-scan: structural drift against Kernel Specs (I1-I11)    |
| `update`    | Post-update: changelog-driven schema, template & rules check |

---

## 📐 Action: full-scan (default)

Full structural audit against Kernel Specs. This is the **only** workflow allowed to full-scan `invariants.md`.

> **Constraint:** Read `.para-workspace.yml` at the workspace root to get the user's preferred language from `preferences.language` (e.g., `vi` for Vietnamese). **All output and the final report MUST be translated to this language.**

### 1. Full-scan Kernel Spec (Allowed Exception)

// turbo

```bash
cat Resources/ai-agents/kernel/invariants.md
```

Read the 11 invariants (I1-I11) to understand the strict structural rules of the workspace.

### 2. Check File System Structure (I1, I8)

// turbo

```bash
ls -la
```

Verify that there are no loose files at the workspace root (except `.para-workspace.yml`, `README.md`, `para`, etc.). Check that the top-level directories match `Projects/`, `Areas/`, `Resources/`, `Archive/`. Note any undocumented files or folders.

### 3. Check Active Projects (I4, I2)

For each active project inside `Projects/`:

1. Check if `project.md` exists.
2. Check if `backlog.md` exists and has items in "In Progress" or "ToDo". If empty or missing, flag the project as potentially inactive.

### 4. Delegate to Package Managers for Libraries

Use the built-in listing commands of the workflow and rule managers to check for inconsistencies.

// turbo

```bash
/para-rule list
/para-workflow list
```

Identify any untracked or misaligned rules and workflows.

### 5. Create Audit Report

Generate a detailed `audit-report-YYYY-MM-DD.md` in `Areas/Workspace/audits/` summarizing:

- **Structural Integrity:** Which Invariants passed/failed.
- **Drift Detected:** Loose files, missing structures, inactive projects.
- **Library Status:** Outdated or untracked rules/workflows.
- **Remediation Plan:** Next steps to fix the issues, potentially using `/para-rule standardize` or manual cleanup.

---

## 🔄 Action: update

Post-update compliance check. Run after `./para update` to detect version-specific changes and suggest cleanup.

> **Constraint:** Read `.para-workspace.yml` for preferred language. All output MUST be translated.

> **Trigger:** Agent or `/update` workflow SHOULD suggest running this after a successful `./para update`.

### 1. Detect Version Change

// turbo

```bash
cat .para-workspace.yml | grep kernel_version
tail -5 .para/audit.log
```

1. Read `kernel_version` from `.para-workspace.yml` → current version.
2. Read last 5 lines of `.para/audit.log` → find the previous version (from the last `install` entry before this one).
3. If no version change detected → report "Already up to date" and stop.

### 2. Read Changelog (Token-Optimized)

// turbo

```bash
cat Resources/references/para-workspace/docs/changelog/v[VERSION].md
```

Read **only** the changelog for the new version. Extract:

- **Breaking Changes** section → mandatory user action items
- **Templates** table rows → template compliance checks needed
- **Rules** table rows → rules index checks needed
- **Workflows** table rows → informational (already synced by `./para update`)

Build a **check list** from the changelog. Examples of checks that may be generated:

| Changelog Signal                          | Generated Check                                    |
| :---------------------------------------- | :------------------------------------------------- |
| Template `backlog.md` changed             | Check all projects' backlog.md for new sections    |
| Template `done.md` changed                | Check all projects' done.md for new structure      |
| Rule `hybrid-3-file-integrity.md` updated | Check `.agent/rules.md` index if `has_rules: true` |
| New schema field added                    | Check all `project.md` YAML frontmatter            |

### 3. Check Project Schema Compliance

For each project in `Projects/` that has a `project.md`:

// turbo

1. Read `project.md` YAML frontmatter.
2. Compare against expected fields from `kernel/schema/project.schema.json`.
3. Flag missing fields with suggested default values:
   - `has_rules` missing → suggest `true` if `.agent/rules/` exists, `false` otherwise
   - `downstream` missing → suggest `[]`
   - `active_plan` missing → suggest `""`
4. Record findings.

### 4. Check Backlog Template Compliance

For each project with `artifacts/tasks/backlog.md`:

// turbo

1. Check for `✅ Completed (Archived)` section → if missing, suggest adding it.
2. Check Summary table categories:
   - Required: `Active Items`, `✅ Done`, `🔴 High`, `🟡 Medium`, `🟢 Low`, `✅ Archived`
   - Flag missing categories.
3. Check if any items in active tables have status `✅ Done` → suggest running `/backlog clean`.
4. If project has `artifacts/tasks/done.md`:
   - Check if done.md has plan-grouped structure (## Plan: ...) → if flat/date-grouped, suggest restructuring.

### 5. Check Rules Index Consistency

For each project where `project.md` has `has_rules: true`:

// turbo

1. Check if `.agent/rules.md` (rules index) exists.
   - `has_rules: true` but no `.agent/rules.md` → warn.
2. If `.agent/rules.md` exists:
   - Extract listed rule filenames.
   - Compare with actual files in `.agent/rules/` (excluding `catalog.yml`).
   - Flag: rules in index but missing on disk, rules on disk but not in index.
3. Reverse check: `.agent/rules.md` exists but `has_rules` is missing/false → suggest setting `true`.

### 6. Generate Post-Update Report

Display an inline report (do NOT create a separate file — this is a quick check, not a full audit):

```
📋 POST-UPDATE AUDIT: v[OLD] → v[NEW]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 CHANGELOG: [summary of key changes]

📐 PROJECT SCHEMA:
| Project   | Field       | Status     | Suggested Action         |
| --------- | ----------- | ---------- | ------------------------ |
| project-a | has_rules   | ❌ Missing | Add `has_rules: true`    |
| project-b | ✅ OK       |            |                          |

📋 BACKLOG TEMPLATE:
| Project   | Issue                     | Suggested Action         |
| --------- | ------------------------- | ------------------------ |
| project-a | Missing Completed section | Run `/backlog clean`     |
| project-a | Done items in active table| Run `/backlog clean`     |

🔒 RULES INDEX:
| Project   | Issue                     | Suggested Action         |
| --------- | ------------------------- | ------------------------ |
| project-a | rules.md ≠ disk           | Update `.agent/rules.md` |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 SUGGESTED ACTIONS:
1. [actionable items, ask user to confirm]
```

If there are auto-fixable items (e.g., adding missing fields with clear defaults), ask the user if they want to apply fixes automatically.

---

## Related

- `/para-rule` — Rule management (CRUD logic)
- `/para-workflow` — Workflow management (CRUD logic)
- `/para` — Master workspace controller
- `/update` — Safe workspace update (suggest running `/para-audit update` after)
