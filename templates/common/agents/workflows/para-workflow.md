---
description: Manage and standardize AI Agent Workflows according to PARA standards
source: catalog
---

# /para-workflow [action] [name]

> **Workspace Version:** 1.8.5

Specialized workflow to manage, install, and standardize AI Agent workflows within a PARA Workspace.

## Actions

| Action | Description |
| :-- | :-- |
| `list` | Compare active workflows vs. governed catalog |
| `add` | Create a new PARA-compliant workflow |
| `standardize` | Upgrade an existing workflow to current PARA standards |
| `install` | Install or update a workflow from the governed catalog |
| `validate` | Check a workflow for PARA compliance issues |

---

## 📋 Action: list

Compare workflows currently active in `.agents/workflows/` against the governed catalog.

### Steps

// turbo

**Step 1.** List active workflows:

```bash
echo "🚀 ACTIVE WORKFLOWS (.agents/workflows):"
ls -1 .agents/workflows/*.md 2>/dev/null | xargs -I{} basename {} .md | sort
echo ""
```

**Step 2.** Read `catalog.yml` to get the governed library list, and `VERSIONS.yml` for version info:

// turbo

Read the file at the **catalog source** (one of these, in priority order):

1. `Projects/para-workspace/repo/templates/common/agents/workflows/catalog.yml`
2. `Resources/references/para-workspace/templates/common/agents/workflows/catalog.yml`

**Step 3.** Display comparison report:

```
📦 GOVERNED CATALOG (catalog.yml + VERSIONS.yml):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| ID             | Version | Status          |
| -------------- | ------- | --------------- |
| open           | 1.0.0   | ✅ Installed    |
| backlog        | 1.0.0   | ✅ Installed    |
| para-workflow  | 1.0.0   | ⚠️ Not installed |
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

- **✅ Installed**: File exists in `.agents/workflows/`.
- **⚠️ Not installed**: Entry in catalog but missing from active directory.
- **🔶 Untracked**: File exists locally but is NOT in the catalog (user-created).

---

## 🛠 Action: add [name]

Create a new PARA-compliant workflow from scratch.

### Steps

1. **Create file**: `.agents/workflows/[name].md`
2. **Apply standard template**:

```markdown
---
description: [Short description of the workflow]
source: user
---

# /[name] [args]

> **Workspace Version:** {kernel_version from .para-workspace.yml}

[Purpose and context]

## Steps

### 1. [First step]

// turbo

[Instructions]

## Related

- [Links to related workflows]
```

3. **Conventions to follow**:
   - YAML frontmatter with `description` is **required**.
   - Version label must match current workspace version (read `kernel_version` from `.para-workspace.yml`).
   - Use `[project-name]` placeholder instead of hardcoded project names.
   - Use `// turbo` annotation above steps that are safe to auto-run.
   - All paths must be **relative** from workspace root.
   - Instructions should be in **English** (workspace default).

---

## 📈 Action: standardize [name]

Upgrade an existing workflow to the latest PARA standards.

### Checklist

The agent will read `.agents/workflows/[name].md` and apply fixes for each item:

| # | Check | Rule |
| -- | -- | -- |
| 1 | **YAML Frontmatter** | Must have `description` field |
| 2 | **Version Label** | Must match `kernel_version` from `.para-workspace.yml` |
| 3 | **Language** | Instructions should be in English |
| 4 | **Relative Paths** | No absolute paths (e.g., `/media/tienle/...`) |
| 5 | **Project Placeholders** | Use `[project-name]` instead of hardcoded project names |
| 6 | **Catalog Paths** | Reference governed catalog, NOT legacy `Resources/ai-agents/` |
| 7 | **Turbo Annotations** | Mark safe-to-autorun steps with `// turbo` |
| 8 | **No Duplicate Scope** | Don't duplicate logic that belongs to `/install` or `/para` |

### Legacy Path Migration Table

| Old Path (legacy) | New Path (current) |
| -- | -- |
| `Resources/ai-agents/workflows/` | `templates/common/agents/workflows/` (in repo) |
| `Resources/ai-agents/rules/` | `templates/common/agents/rules/` (in repo) |
| `Resources/ai-agents/skills/` | `templates/common/agents/skills/` (in repo) |
| `Resources/Themes/` | `Resources/themes/` (lowercase) |
| `Resources/Remotes/` | `Resources/references/` (renamed) |
| `Resources/Reference/` | `Resources/references/` (lowercase) |
| `Projects/_playground/` | `Projects/_playground/` (unchanged) |

### Execution

1. Read the target workflow file.
2. Run through the checklist above.
3. Present a **diff summary** of proposed changes.
4. Apply changes after user confirmation.

---

## 🚀 Action: install [name]

Install a workflow from the governed catalog into `.agents/workflows/`.

### Steps

1. **Resolve source**: Find the workflow file in the catalog source directory.
2. **Check conflict**: If `.agents/workflows/[name].md` already exists, delegate to `/install` workflow for conflict resolution (Overwrite / Merge / Rename / Cancel).
3. **Copy**: Install the file into `.agents/workflows/[name].md`.
4. **Report**: Confirm installation with version info from `VERSIONS.yml`.

> **Note:** For complex merge scenarios, use `/merge` workflow directly.

---

## ✅ Action: validate [name]

Check a workflow for PARA compliance without making changes.

### Steps

1. Read `.agents/workflows/[name].md`.
2. Run the **standardize checklist** (read-only mode).
3. Output a compliance report:

```
🔍 VALIDATION REPORT: [name].md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ YAML Frontmatter      — OK
✅ Version Label          — {kernel_version}
⚠️ Legacy Path Found     — Line 42: Resources/ai-agents/workflows/
✅ No Absolute Paths      — OK
✅ Project Placeholders   — OK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Result: 1 warning(s), 0 error(s)
💡 Run `/para-workflow standardize [name]` to fix.
```

---

## 💡 Notes

- This workflow manages the **workflow library** itself. For day-to-day workflow usage, just invoke the workflow directly (e.g., `/open`, `/end`).
- The governed catalog (`catalog.yml`) lists officially supported workflows, while `VERSIONS.yml` is the single source of truth for versions.
- User-created workflows (not in catalog) are valid but considered **untracked** — they won't receive automatic updates.
- Always backup before running `standardize` on modified workflows.

## Related

- `/para` — Master workspace controller
- `/para-rule` — Rule management (sister workflow)
- `/install` — Generic installer with conflict resolution
- `/merge` — Semantic merge for workflow conflicts
