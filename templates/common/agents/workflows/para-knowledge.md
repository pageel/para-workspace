---
description: Manage Knowledge Items — dashboard, create, update, audit, archive
---

# /para-knowledge [action] [topic]

> **Workspace Version:** 1.7.5
> **Scope:** Workspace-level — manage Knowledge Items (KI) for AI agent persistence
> **Governance:** KR1-KR7 (`rules/knowledge.md`), H10 (`kernel/heuristics.md`)

Manage the AI agent's persistent knowledge base. KIs are curated, distilled knowledge from past conversations that persist across sessions.

## Constants

```
KI_ROOT   = ~/.gemini/antigravity/knowledge
APP_DATA  = ~/.gemini/antigravity
LOCAL_DIR = .para/knowledge          # Workspace-local index + reports
REPO_TMPL = repo/templates/knowledge  # System KI templates (source of truth)
```

## Steps

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

### 0. Ensure Local Directory + Route Action

// turbo

```bash
mkdir -p .para/knowledge/reports
```

Parse the command to determine action:

```
/para-knowledge                       → Dashboard (Step 1)
/para-knowledge [topic]               → Smart Create/Update (Step 3)
/para-knowledge system [topic]        → System KI Create/Update (Step 3, force system mode)
/para-knowledge system update         → Sync system KIs from repo templates (Step 7)
/para-knowledge system defaults       → Init all default system KIs (Step 8)
/para-knowledge audit                 → Full Audit (Step 5)
/para-knowledge archive [id]          → Retire a KI (Step 6)
```

If no action or unrecognized → default to **Dashboard**.

---

### 1. 📊 Knowledge Dashboard

// turbo

Scan all KIs and render a visual control panel.

**Data gathering:**

```bash
# Gather KI data
for dir in $KI_ROOT/*/; do
  meta="$dir/metadata.json"
  ts="$dir/timestamps.json"
  if [ -f "$meta" ]; then
    id=$(basename "$dir")
    title=$(grep -o '"title": "[^"]*"' "$meta" | head -1 | sed 's/"title": "//;s/"$//')
    refs=$(grep -c '"value"' "$meta")
    arts=$(find "$dir/artifacts" -type f 2>/dev/null | wc -l)
    size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    # Timestamps
    created=$(grep -o '"created": "[^"]*"' "$ts" 2>/dev/null | sed 's/.*"created": "//;s/"$//' | cut -dT -f1)
    modified=$(grep -o '"modified": "[^"]*"' "$ts" 2>/dev/null | sed 's/.*"modified": "//;s/"$//' | cut -dT -f1)
    accessed=$(grep -o '"accessed": "[^"]*"' "$ts" 2>/dev/null | sed 's/.*"accessed": "//;s/"$//' | cut -dT -f1)
    echo "$id|$title|$arts|$refs|$size|$created|$modified|$accessed"
  fi
done
```

**Reference validation (per KI):**

```bash
# Check each file reference exists
grep -o '"value": "[^"]*"' "$meta" | while read ref; do
  path=$(echo "$ref" | sed 's/"value": "//;s/"$//')
  if echo "$path" | grep -q "^/"; then
    test -f "$path" && echo "OK" || echo "BROKEN"
  fi
done
```

#### Render Dashboard

Split KIs into two sections based on `owner` field or slug prefix:

```
📚 KNOWLEDGE DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏛️ SYSTEM KIs (para_*) — managed by PARA v[version]
| #  | Title               | PARA Ver | Arts | Refs  | Health |
|:---|:--------------------|:---------|:-----|:------|:-------|
| 1  | [title]             | [ver]    | [N]  | [N/M] | ✅/⚠️  |

👤 USER KIs — managed by agent/user
| #  | Title               | Scope | Domain | Refs  | Health |
|:---|:--------------------|:------|:-------|:------|:-------|
| 2  | [title]             | [sc]  | [dom]  | [N/M] | ✅/⚠️  |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 STATS: [N] system + [N] user = [N] KIs | [N]K total
⚠️ STALE: [N] KIs not updated in 30+ days
🔴 BROKEN: [N] KIs with invalid references

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 ACTIONS:
  /para-knowledge [topic]           — Create or update a user KI
  /para-knowledge system [topic]    — Create or update a system KI
  /para-knowledge system update     — Sync system KIs from repo templates
  /para-knowledge audit             — Full health check + save report
  /para-knowledge archive [#]       — Retire a KI
  /para-knowledge [#]               — View KI details

❓ What would you like to do?
```

#### Health Scoring

For each KI, compute health:

```
✅ Healthy:
  - Modified within 30 days
  - All reference files exist
  - Has ≥1 artifact

⚠️ Stale:
  - Modified 30-90 days ago
  - OR ≥1 reference file missing

🔴 Critical:
  - Modified 90+ days ago
  - OR >50% reference files missing
  - OR 0 artifacts
```

#### Save Index (after every dashboard render)

// turbo

Write the dashboard data to `.para/knowledge/index.md` for quick workspace-level access:

```markdown
# Knowledge Items Index

> Auto-generated by `/para-knowledge` — YYYY-MM-DD HH:MM
> Source: `~/.gemini/antigravity/knowledge/`
> Path: `{source}/{slug}/` → `metadata.json` + `artifacts/`

#  | Title | Slug | Owner | Scope | Domain | Purpose | PARA Ver | Arts | Refs | Modified | Health
:--|:------|:-----|:------|:------|:-------|:--------|:---------|:-----|:-----|:---------|:------
1  | [title] | [slug] | para/user | ws/proj/eco | [domain] | [purpose] | [ver] | [N] | [N/M] | YYYY-MM-DD | ✅/⚠️/🔴

> **Key:** Owner: `para` (system) / `user`. Scope: `ws` (workspace) / `proj` / `eco` (ecosystem).

## KI #1: [Title]

📁 `~/.gemini/antigravity/knowledge/[slug]/`

Artifact | Link
:--------|:----
[relative/path.md] | [open](file:///absolute/path/to/artifact.md)
[subdir/file.md]   | [open](file:///absolute/path/to/subdir/file.md)

_(Repeat section for each KI)_

## Stats

- Total: [N] KIs | [N] artifacts | [N]K
- Healthy: [N] | Stale: [N] | Critical: [N]
```

**Artifact listing rules:**
- List ALL files under `artifacts/` (recursive `find`)
- Show path relative to `artifacts/` directory
- Link uses absolute `file:///` URI so user can click to open
- Directories shown with trailing `/` (no link)

This index file lets user and agent check KI status without navigating to `~/.gemini/`.

---

### 2. 🔍 View KI Detail (when user selects a number)

Read and display the selected KI's full info:

```
📖 KI #[N]: [Title]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Summary:
[First 200 chars of summary from metadata.json]

📁 Artifacts ([N] files):
  1. [relative path] — [first heading or section name]
  2. [relative path] — ...

🔗 References ([N] total, [M] valid):
  ✅ [file path] — exists
  ⚠️ [file path] — MISSING
  📝 [conversation_id] — [title if resolvable]

📅 Timeline:
  Created:  YYYY-MM-DD
  Modified: YYYY-MM-DD
  Accessed: YYYY-MM-DD

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 ACTIONS:
  U. Update this KI
  A. Archive (retire) this KI
  B. Back to dashboard
```

---

### 3. ✏️ Smart Create / Update

When user runs `/para-knowledge [topic]` or `/para-knowledge system [topic]`:

#### 3a. Detect: Create or Update? + Namespace Gate

```
1. Generate slug from topic
2. Scan all KI titles in metadata.json files
3. Fuzzy match [topic] against existing titles
4. IF match score > 70% → propose UPDATE (show matched KI)
5. ELSE → propose CREATE
6. NAMESPACE GATE:
   IF slug starts with "para_" OR action = "system":
     → SYSTEM KI MODE
     → Show: "🏛️ System KI detected (para_*). Version alignment required."
     → Confirm with user (KR2)
     → IF denied → strip "para_" prefix, route to User KI
   ELSE:
     → USER KI MODE
     → Guard: IF slug somehow starts with "para_" → REJECT
       "❌ Prefix 'para_' is reserved for System KIs.
        Use `/para-knowledge system [topic]` or choose a different name."
7. Confirm with user before proceeding
```

#### 3b. CREATE — User Knowledge Item

> This is the default flow for user KIs (slug does NOT start with `para_`).

**Slug naming convention:**

| Scope | Prefix | Example | Use case |
|:---|:---|:---|:---|
| Project-specific | `project_` | `project_para_workspace` | Dev patterns, pitfalls for a specific project |
| Topic/domain | (descriptive) | `astro_migration_patterns` | Cross-project technical knowledge |
| Tool/tech | (tool name) | `cloudflare_workers_gotchas` | Tool-specific gotchas |

> 💡 **Tip:** For project KIs, use `project_` + project name (kebab→snake).
> Example: project `my-app` → slug `project_my_app`

```bash
# Generate slug from topic
SLUG=$(echo "[topic]" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd 'a-z0-9_')

# Validate slug format (H10.11, KR3)
if ! echo "$SLUG" | grep -qE '^[a-z0-9_]{3,60}$'; then
  echo "ERROR: Invalid slug '$SLUG'. Must be 3-60 chars, a-z0-9_ only."
  exit 1
fi

# GUARD: Reject para_ prefix for user KIs (KR3, H10.10)
if echo "$SLUG" | grep -qE '^para_'; then
  echo "❌ Prefix 'para_' is reserved for System KIs."
  echo "   Use: /para-knowledge system [topic]"
  echo "   Or choose a name without 'para_' prefix."
  exit 1
fi

# Check slug collision (KR5)
KI_DIR="$KI_ROOT/$SLUG"
if [ -d "$KI_DIR" ]; then
  echo "WARNING: Slug '$SLUG' already exists → routing to UPDATE"
  # → Route to Step 3c (UPDATE), do NOT overwrite
fi

mkdir -p "$KI_DIR/artifacts"
```

**Workflow:**

1. **Ask user** for context sources:
   - Current session context?
   - Specific files to reference?
   - Specific conversation IDs?

2. **Generate artifacts:**
   - Read source files/context
   - Distill into concise, structured .md files
   - Focus on: patterns, decisions, constraints, gotchas
   - English-first for technical content (PARA convention)

3. **Create metadata.json:**
   ```json
   {
     "title": "[Descriptive Title]",
     "summary": "[Multi-line summary]",
     "owner": "user",
     "references": [
       { "type": "file", "value": "/absolute/path" },
       { "type": "conversation_id", "value": "uuid" }
     ]
   }
   ```

4. **Validate:**
   - All reference files exist
   - **Ephemeral guard (KR7):** Reject references matching `artifacts/plans/`, `sessions/`, `sprint-current.md`
   - Summary ≤ 800 chars
   - At least 1 artifact
   - Title is descriptive (not generic)

   ```bash
   # Ephemeral reference guard (KR7)
   for ref in $(grep -o '"value": "[^"]*"' "$KI_DIR/metadata.json" | sed 's/"value": "//;s/"$//'); do
     if echo "$ref" | grep -qE '(artifacts/plans/|sessions/|sprint-current\.md)'; then
       echo "⚠️  EPHEMERAL_REF detected: $ref"
       echo "   KR7 violation — ephemeral files MUST NOT be in references."
       echo "   Remove this reference or replace with a durable path."
     fi
   done
   ```

5. **Update local index:**
   - Regenerate `.para/knowledge/index.md` (Step 1 save logic)

6. **Display confirmation:**
   ```
   ✅ KI CREATED: [Title]
   📁 Artifacts: [N] files
   🔗 References: [N] sources
   📦 Size: [N]K
   📋 Index updated: .para/knowledge/index.md
   ```

#### 3d. CREATE/UPDATE — System Knowledge Item (para_*)

> Triggered when action = `system` OR slug starts with `para_`.
> System KIs follow governed lifecycle: repo templates → sync → read-mostly.

**System KI Create:**

```bash
# Enforce para_ prefix
if ! echo "$SLUG" | grep -qE '^para_'; then
  SLUG="para_$SLUG"
fi

# Read PARA version
PARA_VER=$(grep 'version:' .para-workspace.yml 2>/dev/null | head -1 | awk '{print $2}' | tr -d '"')

KI_DIR="$KI_ROOT/$SLUG"
TMPL_DIR="$REPO_TMPL/$SLUG"
```

**Workflow:**

1. **Check template** in `repo/templates/knowledge/{slug}/`:
   - IF template exists → copy `metadata.json` + `artifacts/` as baseline
   - IF no template → create fresh with system metadata defaults

2. **Set system metadata:**
   ```json
   {
     "title": "[Descriptive Title]",
     "summary": "[Multi-line summary]",
     "version": "1.0",
     "scope": "workspace",
     "domain": "workspace",
     "purpose": "context",
     "owner": "para",
     "para_version": "[PARA_VER]",
     "tags": [],
     "references": [],
     "relates_to": [],
     "code_refs": [],
     "concepts": []
   }
   ```

3. **Ask user**: "Add context from current session? (Y/N)"
   - IF Y: merge session insights into artifacts
   - IF N: use template/defaults only

4. **Validate** (same as user KI + system-specific):
   - `owner` MUST be `"para"`
   - `para_version` MUST be set
   - slug MUST start with `para_`

5. **Update local index**

6. **Display confirmation:**
   ```
   🏛️ SYSTEM KI CREATED: [Title]
   📁 Artifacts: [N] files
   🔗 References: [N] sources
   🏷️ Owner: para | PARA Version: [ver]
   📋 Index updated: .para/knowledge/index.md
   ```

**System KI Update:**

1. Read existing KI metadata → compare `para_version`
2. IF `para_version` < current PARA version:
   - Show: `"⚠️ KI outdated (v{old} → v{current}). Recommend full refresh."`
3. Check template for structural changes
4. **Merge strategy:**
   - `metadata.json` fields: template wins (except `references` → merge)
   - `artifacts/`: template files override matching filenames
   - User-added artifacts (no template match): KEEP
   - `references`: union set (keep user refs + add template refs)
   - `timestamps`: KEEP (system-managed)
5. Bump `para_version` to current
6. Update local index

#### 3c. UPDATE — Existing Knowledge Item

**Workflow:**

1. **Read current state:**
   - Read metadata.json → current title, summary, references
   - Read all artifacts → current content
   - Read timestamps.json → staleness

2. **Detect changes needed:**
   - Compare reference file paths → any missing?
   - Compare workspace version vs KI version references
   - User specifies what changed

3. **Update process:**
   - Rewrite affected artifacts (preserve structure, update content)
   - Update metadata.json summary if content changed significantly
   - Update references (add new, remove dead)
   - Do NOT modify timestamps.json (system-managed)

4. **Update local index:**
   - Regenerate `.para/knowledge/index.md`

5. **Diff summary:**
   ```
   🔄 KI UPDATED: [Title]
   ━━━━━━━━━━━━━━━━━━━━━
   📝 Artifacts changed: [list]
   🔗 References: +[N] added, -[N] removed, ⚠️[N] fixed
   📦 Size: [old] → [new]
   📋 Index updated: .para/knowledge/index.md
   ```

---

### 4. 💡 KI Suggestion Engine

> Optional — agent runs this proactively when context suggests valuable knowledge.

**Trigger conditions (agent should check):**

- Session involved major architectural decision
- User explicitly asks "remember this" or "save this as knowledge"
- A pattern was discovered that applies across projects
- A non-obvious gotcha or workaround was found

**Suggestion format:**

```
💡 KNOWLEDGE SUGGESTION
━━━━━━━━━━━━━━━━━━━━━━━
Topic: [detected topic]
Reason: [why this is worth persisting]
Source: Current session + [files referenced]

Create KI? (Y/N/Later)
```

---

### 5. 🔍 Full Audit

// turbo

Comprehensive health check of all KIs.

**Data collection:**

```bash
# For each KI:
for dir in $KI_ROOT/*/; do
  meta="$dir/metadata.json"
  if [ -f "$meta" ]; then
    # 1. Check reference validity
    grep -o '"value": "[^"]*"' "$meta" | while read ref; do
      path=$(echo "$ref" | sed 's/"value": "//;s/"$//')
      # Broken ref check
      if echo "$path" | grep -q "^/"; then
        test -f "$path" || echo "BROKEN_REF|$(basename $dir)|$path"
      fi
      # Ephemeral ref check (KR7)
      if echo "$path" | grep -qE '(artifacts/plans/|sessions/|sprint-current\.md)'; then
        echo "EPHEMERAL_REF|$(basename $dir)|$path"
      fi
    done
    # 2. Check artifact count
    art_count=$(find "$dir/artifacts" -type f 2>/dev/null | wc -l)
    [ "$art_count" -eq 0 ] && echo "NO_ARTIFACTS|$(basename $dir)"
    # 3. Check staleness (modified date)
    modified=$(grep -o '"modified": "[^"]*"' "$dir/timestamps.json" 2>/dev/null | sed 's/.*"modified": "//;s/"$//' | cut -dT -f1)
  fi
done
```

**Render Audit Report:**

```
🔍 KNOWLEDGE AUDIT REPORT — YYYY-MM-DD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Overview:
  Total KIs: [N]
  Healthy: [N] ✅
  Stale: [N] ⚠️
  Critical: [N] 🔴

🔗 Reference Integrity:
  Total refs: [N]
  Valid: [N] ✅
  Broken: [N] 🔴
  [List broken refs with KI name + path]

📅 Staleness:
  [List KIs older than 30 days with last modified date]

💡 Recommendations:
  - [KI name]: [N] broken refs — `/para-knowledge [topic]` to fix
  - [KI name]: [N] ephemeral refs — KR7 violation, replace with durable paths
  - [KI name]: 90+ days old — review or `/para-knowledge archive [#]`
  - [Topic from recent sessions]: Consider creating new KI

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Save audit report persistently:**

// turbo

```bash
# Save to .para/knowledge/reports/
REPORT_FILE=".para/knowledge/reports/audit-$(date +%Y-%m-%d).md"
```

Write the rendered audit report to `$REPORT_FILE`. This creates an audit trail of KI health over time.

Also regenerate `.para/knowledge/index.md` with latest data.

```
📄 Report saved: .para/knowledge/reports/audit-YYYY-MM-DD.md
📋 Index updated: .para/knowledge/index.md
```

---

### 6. 📦 Archive (Retire a KI)

When user wants to retire a stale or obsolete KI:

1. **Show KI detail** first (Step 2) for confirmation
2. **Confirm** with user explicitly
3. **Move to archived directory** (PARA discipline — never delete):
   ```bash
   # Safe archive
   ARCHIVE_DIR="$KI_ROOT/.archived/$(date +%Y-%m-%d)_$KI_SLUG"
   mkdir -p "$(dirname $ARCHIVE_DIR)"
   mv "$KI_ROOT/$KI_SLUG" "$ARCHIVE_DIR"
   ```
4. **Update local index:**
   - Regenerate `.para/knowledge/index.md` (KI removed from active list)
5. **Confirmation:**
   ```
   📦 KI ARCHIVED: [Title]
   📁 Moved to: knowledge/.archived/[date]_[slug]/
   📋 Index updated: .para/knowledge/index.md
   💡 Can be restored manually if needed.
   ```

---

### 7. 🔄 System KI Update (Sync from Templates)

When user runs `/para-knowledge system update`:

// turbo

```bash
# Scan repo templates for system KIs
for tmpl_dir in $REPO_TMPL/para_*/; do
  [ -d "$tmpl_dir" ] || continue
  slug=$(basename "$tmpl_dir")
  tmpl_meta="$tmpl_dir/metadata.json"
  ki_dir="$KI_ROOT/$slug"
  ki_meta="$ki_dir/metadata.json"
  [ -f "$tmpl_meta" ] || continue
  tmpl_ver=$(grep -o '"para_version": "[^"]*"' "$tmpl_meta" | sed 's/.*"para_version": "//;s/"$//')
  if [ -d "$ki_dir" ]; then
    ki_ver=$(grep -o '"para_version": "[^"]*"' "$ki_meta" 2>/dev/null | sed 's/.*"para_version": "//;s/"$//')
    echo "EXISTS|$slug|$ki_ver|$tmpl_ver"
  else
    echo "NEW|$slug|$tmpl_ver"
  fi
done
```

**Workflow:**

1. Read PARA version from workspace
2. Scan `repo/templates/knowledge/` for all `para_*` template slugs
3. For each template:
   - **IF KI exists** in KI Store:
     - Compare `para_version`
     - IF template newer: upgrade with merge strategy
     - IF same version: skip
   - **IF KI not exists**:
     - Show: `"✨ New system KI available: {title}"`
     - Ask: `"Install? (Y/N/All)"`
4. **Merge strategy** (for upgrades):
   - `metadata.json`: template wins (except `references` → union merge)
   - `artifacts/`: template files override matching filenames
   - User-added artifacts (no template filename match): KEEP
   - `timestamps`: KEEP (system-managed)
5. Update local index
6. Display summary:
   ```
   🏛️ SYSTEM KI SYNC COMPLETE
   ━━━━━━━━━━━━━━━━━━━━━━━━━━
   🔄 Updated: [N] ([list slugs])
   ✨ New:     [N] ([list slugs])
   ⏭️ Unchanged: [N]
   📋 Index updated: .para/knowledge/index.md
   ```

---

### 8. 📦 System KI Defaults Init

When user runs `/para-knowledge system defaults`:

> Run once on first install, or to restore missing system KIs.

// turbo

```bash
# Install all template KIs that don't already exist
for tmpl_dir in $REPO_TMPL/para_*/; do
  [ -d "$tmpl_dir" ] || continue
  slug=$(basename "$tmpl_dir")
  ki_dir="$KI_ROOT/$slug"
  if [ ! -d "$ki_dir" ]; then
    echo "INSTALL|$slug"
  else
    echo "SKIP|$slug"
  fi
done
```

**Workflow:**

1. Scan all templates in `repo/templates/knowledge/`
2. For each template:
   - IF KI exists: **skip** (do NOT overwrite)
   - IF KI not exists: **install** from template
3. Set `para_version` = current for all installed
4. Update local index
5. Display summary:
   ```
   🏛️ SYSTEM KI DEFAULTS INSTALLED
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ✨ Installed: [N] system KIs
   ⏭️ Skipped:  [N] (already exist)
   📋 Index updated: .para/knowledge/index.md
   ```

> **Integration:** `./para install` and `./para update` can call this logic
> to auto-sync system KIs when updating the workspace.

---

## `/end` Hook (Optional Enhancement)

> Add as optional step in `/end` workflow — lightweight, not mandatory.

After session summary, IF session involved significant decisions or discoveries:

```
💡 SESSION KNOWLEDGE CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━
This session touched:
  - [Topic 1] — relates to KI "[existing KI title]" (last updated [date])
  - [Topic 2] — no matching KI found

Suggestions:
  📝 Update "[KI title]" with today's changes?
  ✨ Create new KI for "[Topic 2]"?
  🏛️ Update system KI? (if session = para-workspace)
  ⏭️ Skip

(U/C/S)
```

---

## `.para/knowledge/` Structure

```
.para/knowledge/
├── index.md              # Master KI mapping table (auto-generated)
└── reports/
    ├── audit-2026-03-31.md   # Audit report history
    ├── audit-2026-04-15.md
    └── ...
```

**Benefits:**
- `index.md` = single-file overview — open one file to see all KIs
- `reports/` = audit trail — track KI health over time
- Located in workspace — no need to navigate to `~/.gemini/`
- `.para/` = system state (follows PARA convention — I8, I10)

---

## Related

- `/brainstorm` — Brainstorm decisions that may become KIs (Option F: system hint)
- `/end` — Session close with optional KI extraction hook
- `/learn` — Extract reusable lessons to Areas/Learning
- `/retro` — Project retrospective with graduation ritual (system KI hint)
