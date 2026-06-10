---
description: Macro Assessor to check structural drift against Kernel Specs
source: catalog
---

# /para-audit [action]

> **Workspace Version:** 1.6.2 (Unified Agent Index)

Strict workspace macro-assessor. Two modes: full structural audit against Kernel Specs (I1-I11), or post-update compliance check with version-aware suggestions.

## Actions

| Action | Description |
| :-- | :-- |
| _(default)_ | Full-scan: structural drift against Kernel Specs (I1-I11) |
| `update` | Post-update: changelog-driven schema, template & rules check |

---

## 📐 Action: full-scan (default)

Full structural audit against Kernel Specs. This is the **only** workflow allowed to full-scan `invariants.md`.

> **Constraint:** Read `.para-workspace.yml` at the workspace root to resolve the user's preferred language.
> Resolution priority:
> 1. If `language` is a map: 
>    - chat language = `language.chat` (fallback: `language.default` -> "en")
>    - thinking language = `language.thinking` (fallback: `language.default` -> "en")
>    - artifacts language = `language.artifacts` (fallback: `language.default` -> "en")
> 2. If `language` is a string: chat & thinking & artifacts language = `language`
> 3. If `language` is undefined, look for `preferences.language` (legacy)
> 4. Default ultimate fallback: "en"
> All output (chat response) MUST be translated to the chat language, all internal reasoning (<thought>) MUST be written in the thinking language, and all generated files in artifacts/ (plans, tasks, qa) MUST follow the artifacts language.

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

### 6. Quarantine Test Evidence

// turbo

```bash
if [[ -f "project.md" ]] && [[ -d "artifacts/tests" ]]; then mkdir -p artifacts/tests/tmp; for f in artifacts/tests/*; do if [[ -e "$f" && "$f" != "artifacts/tests/tmp" ]]; then mv "$f" "artifacts/tests/tmp/$(basename "$f").bak" 2>/dev/null || true; fi; done; fi
```

---

## 🔄 Action: update

Post-update compliance check. Run after `./para update` to detect version-specific changes and suggest cleanup.

> **Constraint:** Read `.para-workspace.yml` at the workspace root to resolve the user's preferred language.
> Resolution priority:
> 1. If `language` is a map: 
>    - chat language = `language.chat` (fallback: `language.default` -> "en")
>    - thinking language = `language.thinking` (fallback: `language.default` -> "en")
>    - artifacts language = `language.artifacts` (fallback: `language.default` -> "en")
> 2. If `language` is a string: chat & thinking & artifacts language = `language`
> 3. If `language` is undefined, look for `preferences.language` (legacy)
> 4. Default ultimate fallback: "en"
> All output (chat response) MUST be translated to the chat language, all internal reasoning (<thought>) MUST be written in the thinking language, and all generated files in artifacts/ (plans, tasks, qa) MUST follow the artifacts language.

> **Required Skill:** Load `.agents/skills/para-audit/SKILL.md` before executing checks.
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
cat Resources/references/para-workspace/CHANGELOG.md
```

Read **only** the CHANGELOG.md section for the new version (search for `## [VERSION]`). Extract:

- **Breaking Changes** section → mandatory user action items
- **Templates** table rows → template compliance checks needed
- **Rules** table rows → rules index checks needed
- **Workflows** table rows → informational (already synced by `./para update`)

Build a **check list** from the changelog. Examples of checks that may be generated:

| Changelog Signal | Generated Check |
| :-- | :-- |
| Template `backlog.md` changed | Check all projects' backlog.md for new sections |
| Template `done.md` changed | Check all projects' done.md for new structure |
| Rule `hybrid-3-file-integrity.md` updated | Check `.agents/rules.md` index if `agent.rules: true` |
| New schema field added | Check all `project.md` YAML frontmatter |

### 3. Check Project Schema Compliance

For each project in `Projects/` that has a `project.md`:

// turbo

1. Read `project.md` YAML frontmatter.
2. Compare against expected fields from `kernel/schema/project.schema.json`.
3. Flag missing fields with suggested default values:
   - `agent` missing → suggest `agent: { rules: true }` if `.agents/rules/` exists
   - `has_rules` present → suggest migration to `agent` map (v1.6.2+)
   - `downstream` missing → suggest `[]`
   - `active_plan` missing → suggest `""`
   - `type` missing → suggest `standard` (v1.6.0+)
4. **Ecosystem consistency check (v1.6.0+, updated v1.7.6):**
   - If `type: ecosystem` or `type: meta-project` → verify `satellites` array exists and is non-empty
   - If `ecosystem` field exists → verify the referenced meta-project exists in `Projects/`
   - Cross-reference: for each satellite in ecosystem/meta-project's `satellites` list, check that the satellite project has `ecosystem: [name]`
   - If `active_plan` starts with `@` → verify the referenced ecosystem exists and the plan file is accessible
   - **Meta-project specific:** If `type: meta-project` → verify `repo/` directory also exists (must have both code and satellites)
5. Record findings.

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

### 5. Check Agent Index Consistency

For each project where `project.md` has `agent.rules: true` (or legacy `has_rules: true`):

// turbo

1. Check if `.agents/rules.md` (rules index) exists.
   - `agent.rules: true` but no `.agents/rules.md` → warn.
2. If `.agents/rules.md` exists:
   - Extract listed rule filenames.
   - Compare with actual files in `.agents/rules/` (excluding `catalog.yml`).
   - Flag: rules in index but missing on disk, rules on disk but not in index.
3. Reverse check: `.agents/rules.md` exists but `agent.rules` is missing → suggest adding.

For each project where `project.md` has `agent.skills: true`:

1. Check if `.agents/skills.md` (skills index) exists.
   - `agent.skills: true` but no `.agents/skills.md` → warn.
2. If `.agents/skills.md` exists:
   - Extract listed skill names.
   - Compare with actual directories in `.agents/skills/`.
   - Flag: skills in index but missing on disk, skills on disk but not in index.

**Legacy migration check:**
- `has_rules` field present → suggest migrating to `agent` map (v1.6.2+).

### 5.5. Check Guard Headers Coverage (C6)

// turbo

Verify protected files have inline guard headers per `hybrid-3-file-integrity.md` C6:

```bash
echo "=== Guard Coverage ==="
echo "Kernel:" && grep -rL "⚠️" Resources/ai-agents/kernel/*.md Resources/ai-agents/kernel/schema/*.md Resources/ai-agents/kernel/examples/tasks/*.md 2>/dev/null | head -5
echo "Rules:" && grep -rL "⚠️" .agents/rules/*.md 2>/dev/null | head -5
echo "Tasks:" && for p in Projects/*/artifacts/tasks; do grep -rL "⚠️" "$p"/*.md 2>/dev/null; done | head -10
```

- **Kernel files** without `<!-- ⚠️ READ-ONLY SNAPSHOT -->` → warn
- **Rules files** without `<!-- ⚠️ GOVERNED -->` → warn
- **Task files** without any `<!-- ⚠️ -->` guard → suggest adding (migration from pre-v1.5.4)

### 5.6. Knowledge Items Health Check (CONDITIONAL)

// turbo

> **Gate:** Only if `.para/knowledge/index.md` exists.

```bash
# Check if KI system is configured
test -f .para/knowledge/index.md && echo "KI_SYSTEM=true" || echo "KI_SYSTEM=false"
```

**IF KI_SYSTEM=true:**

1. Read `.para/knowledge/index.md` → extract KI count and slugs.
2. For each KI slug, validate against `ki.schema.json` rules:
   - Summary ≤ 800 chars (H10.10)
   - Has ≥1 artifact file (H10.2)
   - Slug matches `^[a-z0-9_]{3,60}$` (H10.11)
   - `owner: para` → slug starts with `para_` (H10.8)
3. Check reference integrity (broken file paths).
4. Check staleness (last modified >90 days).
5. Report in audit:

```
📚 KNOWLEDGE ITEMS:
| Slug              | Health | Summary | Refs   | Last Modified |
| :---------------- | :----- | :------ | :----- | :------------ |
| para_workspace_*  | ✅     | 623/800 | 9/9 ✅ | 2026-04-01    |
```

**IF KI_SYSTEM=false** → Skip.

### 5.7. Check Legacy Files

// turbo

Check if any legacy files that were renamed or deprecated still exist in the workspace using the `para-audit` skill:

```bash
if [ -f ".agents/skills/para-audit/scripts/check-legacy.sh" ]; then
  bash .agents/skills/para-audit/scripts/check-legacy.sh
else
  # Fallback if the skill is not installed or staged yet
  if [ -f ".agents/workflows/config.md" ]; then
    echo "FOUND|.agents/workflows/config.md|rm|Renamed to para-config.md in v1.9.0"
  else
    echo "CLEAN"
  fi
fi
```

### 6. Generate Post-Update Report

Display an inline report (do NOT create a separate file — this is a quick check, not a full audit):

```
📋 POST-UPDATE AUDIT: v[OLD] → v[NEW]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 CHANGELOG: [summary of key changes]

📐 PROJECT SCHEMA:
| Project   | Field       | Status     | Suggested Action              |
| --------- | ----------- | ---------- | ----------------------------- |
| project-a | agent       | ❌ Missing | Add `agent: { rules: true }`  |
| project-b | has_rules   | ⚠️ Legacy | Migrate to `agent` map        |
| project-c | ✅ OK       |            |                               |

📋 BACKLOG TEMPLATE:
| Project   | Issue                     | Suggested Action         |
| --------- | ------------------------- | ------------------------ |
| project-a | Missing Completed section | Run `/backlog clean`     |
| project-a | Done items in active table| Run `/backlog clean`     |

🔒 RULES INDEX:
| Project   | Issue                     | Suggested Action         |
| --------- | ------------------------- | ------------------------ |
| project-a | rules.md ≠ disk           | Update `.agents/rules.md` |

🗑️ LEGACY FILES:
| File | Status | Suggested Action |
| :--- | :--- | :--- |
| .agents/workflows/config.md | ⚠️ Legacy | Run 'rm .agents/workflows/config.md' |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 SUGGESTED ACTIONS:
1. [actionable items, ask user to confirm]
```

If there are auto-fixable items (e.g., adding missing fields with clear defaults), ask the user if they want to apply fixes automatically.

### 7. Quarantine Test Evidence

// turbo

```bash
if [[ -f "project.md" ]] && [[ -d "artifacts/tests" ]]; then mkdir -p artifacts/tests/tmp; for f in artifacts/tests/*; do if [[ -e "$f" && "$f" != "artifacts/tests/tmp" ]]; then mv "$f" "artifacts/tests/tmp/$(basename "$f").bak" 2>/dev/null || true; fi; done; fi
```

---

## Related

- `/para-rule` — Rule management (CRUD logic)
- `/para-workflow` — Workflow management (CRUD logic)
- `/para` — Master workspace controller
- `/update` — Safe workspace update (suggest running `/para-audit update` after)
