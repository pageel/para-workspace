---
description: Stage workspace artifacts (workflows, skills, rules) into a project's repo/templates for release preparation. Logs changes to sprint-current for downstream plan creation.
source: user
---

# /staging [project] [--dry-run]

> **Workspace Version:** 1.8.7

Export workspace-level artifacts (workflows, skills, rules) that have been modified or created into a specific project's `repo/templates/` directory. This bridges the gap between **workspace iteration** (where agents improve workflows daily) and **project release cycles** (where changes are versioned, cataloged, and published).

## Why This Workflow Exists

> **Problem:** Workflows, skills, and rules are iterated rapidly in the workspace `.agents/` directory, but the source-of-truth templates live in a project repo (e.g., `para-workspace/repo/templates/`). Without a staging step, changes accumulate in the workspace without being synced to the distributable template repo — creating drift and forgotten improvements.
> **Solution:** A one-command staging workflow that copies changed files, logs what was staged, and creates a sprint task so the next `/open` session knows to plan a proper release.

## Arguments

| Argument | Required | Description |
|:--|:--|:--|
| `[project]` | Yes | Target project name (e.g., `para-workspace`). Must have `repo/templates/` directory. |
| `--dry-run` | No | Preview what would be staged without copying files or logging tasks. |
| `--track` | No | Detect workspace changes in the current session and log them to sprint-current.md without copying files. |
| `--commit` | No | Create a local Git commit for the staged templates automatically in the project's repository (without pushing). |

## Steps

### Step 0. Pre-flight & Validation

// turbo

1. **Resolve target project:** Verify `Projects/[project]/repo/templates/` exists.
2. **Read project contract:** Load `Projects/[project]/project.md` to verify project type and template structure.
3. **Load Staging Template (Sidecar Skill):**
   - Check if `.agents/skills/staging/projects/[project].md` exists.
   - **If found:** Load the project-specific template (custom path mappings, exclusions, post-stage notes).
   - **If not found:** Load `.agents/skills/staging/projects/default.md` (generic convention-based mapping).
   - The loaded template defines: Path Mappings, Exclusions, and Post-Stage Notes.
5. **OSS English-First Guard:** Read the OSS English-First rules (such as `oss_english_first_governance.md`) and scan the files targeted for staging to ensure they contain no non-English text or locale-specific markers in their configuration content (excluding dedicated wiki/docs translations). If any localization drift is detected, STOP and prompt the user for translation/corrections before executing copying.
6. **Identify Tracked Files (if --track is set):** If `--track` is provided, automatically detect untracked or modified files under `.agents/` directory by running `git status`. No manual plan file creation is required. These files represent the current session scope to be logged.

### Step 1. Diff Detection (Workspace vs Templates)

// turbo

Using the **Template Root** and **Path Mappings** from the loaded Staging Template, compare workspace artifacts against the project's template copies. Apply **Exclusions** to filter.

The Agent MUST:
1. Read `TEMPLATE_ROOT` from the loaded template.
2. Build full paths as: `Projects/[project]/{TEMPLATE_ROOT}/{destination}`.
3. For each row in Path Mappings, run `diff -rq` between workspace source and computed destination.
4. Exclude patterns from the Exclusions table via `grep -v`.

> ⚡ **Track-Only Mode Bypass:** If `--track` is provided, skip directory-wide diffing. Identify the changed workspace files under `.agents/` and verify their status. Skip copying entirely, as this mode only updates `sprint-current.md` for later review.

```bash
# Variables resolved from loaded template:
# TEMPLATE_ROOT="repo/templates/common/agents"  (para-workspace)
# TEMPLATE_ROOT="repo/templates/agents"          (para-graph)
BASE="Projects/[project]/$TEMPLATE_ROOT"

echo "=== WORKFLOWS ==="
diff -rq .agents/workflows/ "$BASE/workflows/" 2>/dev/null \
  | grep -v catalog.yml  # + any exclusions from template

echo "=== RULES ==="
diff -rq .agents/rules/ "$BASE/rules/" 2>/dev/null

echo "=== SKILLS ==="
for skill_dir in .agents/skills/*/; do
  skill_name=$(basename "$skill_dir")
  if [ -d "$BASE/skills/$skill_name/" ]; then
    diff -rq "$skill_dir" "$BASE/skills/$skill_name/" 2>/dev/null
  else
    echo "NEW: $skill_name (not in templates)"
  fi
done
```

> **Note:** If the template uses single-file mappings (like `para-graph`), Agent compares only the listed files instead of full directories.

### Step 2. Interactive Selection

1. Present the diff results as a **Staging Manifest**:

```
📦 STAGING MANIFEST: [project]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Type     | File              | Status       |
| -------- | ----------------- | ------------ |
| Workflow | qa.md             | 🔄 Modified  |
| Skill    | qa/SKILL.md       | 🔄 Modified  |
| Workflow | staging.md        | 🆕 New       |
| Rule     | tool-routing.md   | ✅ In sync   |
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

2. **Ask user:** "Stage all modified/new items? Or select specific items? (all / pick / cancel)"
3. If `--dry-run` flag is set → display manifest and **STOP HERE**. Do not copy or log.

### Step 3. Copy to Template Repo

For each approved item:

1. **Copy file** from workspace to project template directory:
   - **Do NOT** use `rm -rf` to clear target directories, as it violates safety invariants. Copy directly using `cp -r` or `cp -a` to overwrite or add files.
   - Workflows: `.agents/workflows/[name].md` → `Projects/[project]/repo/templates/common/agents/workflows/[name].md`
   - Rules: `.agents/rules/[name].md` → `Projects/[project]/repo/templates/common/agents/rules/[name].md`
   - Skills: `.agents/skills/[name]/` → `Projects/[project]/repo/templates/common/agents/skills/[name]/` (recursive copy via `cp -r` or `cp -a` without removing destination folder first)

2. **Preserve catalog files:** Do NOT overwrite `catalog.yml` — catalog updates are a separate, versioned operation handled during the project's release plan.

3. **Report:** List each copied file with source → destination paths.

4. **Local Git Commit (Optional / if --commit is set):**
   - If the `--commit` option is active, or after asking the user and receiving explicit approval:
     - Run `git add` for all copied files in the project's repository.
     - Run `git commit -m "feat([component]): stage templates from workspace (YYYY-MM-DD)"`.
     - Report the local commit SHA and verify the working directory status.

> ⚠️ **GUARD:** Agent MUST NOT auto-push these copies. Staged files must sit in the local repository as a progress checkpoint until the user runs `/push` or merges via PR.

> ⚡ **Track Bypass:** If `--track` is active, SKIP all file copying and committing logic. Skip Step 3 entirely, as no physical copies or commits are made.

### Step 4. Log to Sprint Current

Append a task entry to the target project's `sprint-current.md`:

```markdown
- [ ] 📦 Staged templates from workspace (YYYY-MM-DD): [list of staged items]. Staged and committed locally (Commit ID: `[SHA]`). Needs: version bump, catalog update, release plan.
# OR if running in track-only mode (--track):
- [ ] 📦 Tracked session workspace changes (YYYY-MM-DD):
  - Modified files in workspace:
    - `.agents/workflows/[file]`
    - `.agents/skills/[file]`
  - Needs: staging review, version bump, catalog update, release plan.
```

This ensures the next `/open` session on that project surfaces the pending work.

> [!IMPORTANT]
> **Information Preservation Rule:** This task MUST be logged in the incomplete state `- [ ]`.
> **DO NOT** mark it as completed `- [x]` immediately after staging, as this task serves as a "pointer" reminding of downstream steps (version bump, catalog update, release plan). If marked `[x]`, the cleanup logic in the `/end` workflow will automatically delete this task at the end of the session, causing you to lose track of incomplete work.

### Step 5. Summary Report

Present final summary:

```
✅ STAGING COMPLETE: [project]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Staged:  N files (M workflows, K skills, J rules)
Target:  Projects/[project]/repo/templates/
Sprint:  sprint-current.md updated ✅

📋 Next steps when working on [project]:
  1. /open [project]
  2. Review staged templates in repo/templates/
  3. /plan create — to version bump + catalog update
  4. /push — commit staged changes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Guards & Constraints

| Constraint | Rule |
|:--|:--|
| No auto-push | Staged templates are committed locally (if confirmed or --commit is set) but MUST never be pushed to remote without PR/push workflows |
| No catalog mutation | `catalog.yml` is never overwritten — update via release plan |
| No version bump | Version changes require a proper plan (not ad-hoc staging) |
| Preserve `source: catalog` | Agent MUST NOT change frontmatter `source` field in copied files |
| Sprint logging | MUST follow C1 (Hot Lane) rules — add `- [ ]` entry only (never mark completed `[x]` as it is a downstream pointer) |
| No Destructive Commands | ABSOLUTELY DO NOT use `rm -rf` on target folders. Always copy directly via `cp -r` or `cp -a` to overwrite. |
| OSS English-First Guard | Verify staged files contain no non-English content (except dedicated i18n wiki translations). Propose user fixes before copying. |

---

## Examples

### Stage all changes to para-workspace

```
User: /staging para-workspace
Agent: (diffs workspace vs templates → shows manifest → copies → logs sprint task)
```

### Preview without staging

```
User: /staging para-workspace --dry-run
Agent: (diffs workspace vs templates → shows manifest → STOPS)
```

### Stage after iterating on QA workflow

```
User: /staging para-workspace
Agent: Detected 2 modified files: qa.md, qa/SKILL.md
       Stage all? (all / pick / cancel)
User: all
Agent: ✅ Staged 2 files. Sprint task logged.
```

### Track session workspace changes without copying

```
User: /staging para-workspace --track
Agent: Scanning current workspace changes. Found 4 modified files (from Git status under .agents/).
       Tracked Manifest:
       | Type     | File                            | Status      |
       | -------- | ------------------------------- | ----------- |
       | Workflow | plan.md                         | 🔄 Modified |
       | Workflow | vibecode.md                     | 🆕 New      |
       | Skill    | plan/SKILL.md                   | 🔄 Modified |
       | Skill    | plan/references/session-plan.md  | 🆕 New      |
       Log these tracked files to sprint-current.md? (y/n)
User: y
Agent: ✅ Tracked files logged to sprint-current.md (no files copied).
```

---

## Related

- `/para-workflow` — Manages workflow library (create, validate, standardize)
- `/push` — Commit staged changes after review
- `/plan` — Create release plan for version bump + catalog update
- `/open` — Surfaces sprint tasks including staged templates
- `/install` — Reverse direction: install templates FROM repo INTO workspace
