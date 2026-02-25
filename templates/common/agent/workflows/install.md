---
description: Intelligent agentic installer for workflows and rules. Handles updates, merges, and renames.
source: catalog
---

# /install [type] [name]

> **Workspace Version:** 1.4.1 (Governed Libraries)

Install or update components from the governed PARA Catalog into the workspace. Handles conflicts intelligently.

## Usage

```bash
/install work kickoff   # Install 'kickoff' workflow
/install rule branding  # Install 'branding' rule
```

## Logic Flow

1.  **Resolve Source & Destination**:
    - **Workflows**:
      - Source: Governed catalog directory (e.g., `templates/common/agent/workflows/[name].md` in repo)
      - Destination: `.agent/workflows/[name].md`
    - **Rules**:
      - Source: Governed catalog directory (e.g., `templates/common/agent/rules/[name].md` in repo)
      - Destination: `.agent/rules/[name].md`

2.  **Check Status**:
    - If Destination does NOT exist: **Install immediately**.
    - If Destination EXISTS: **Trigger Conflict Resolution**.

3.  **Conflict Resolution (Interactive)**:
    - Agent checks if content is identical. If yes → "Already up to date."
    - If different, Agent asks User:
      - **[O]verwrite**: Replace local with catalog version.
      - **[M]erge**: (Workflows only) Intelligently combine both. Delegates to `/merge`.
      - **[R]ename**: Install catalog version as `[name]-catalog.md` (or custom name).
      - **[C]ancel**: Do nothing.

4.  **Execution**:
    - Perform the selected file operation.
    - If Merge: Delegate to `/merge` workflow for semantic analysis.

## Step-by-Step Instructions

### 1. Resolve Catalog Source

// turbo

Find the catalog source directory (in priority order):

1. `Projects/para-workspace/repo/templates/common/agent/`
2. `Resources/references/para-workspace/templates/common/agent/`

Determine `TYPE` (`work` → `workflows/`, `rule` → `rules/`) and construct full source path.

### 2. Check Conflict

// turbo

```bash
TYPE="[type]" # 'work' or 'rule'
NAME="[name]"

if [ "$TYPE" == "work" ]; then
    DEST=".agent/workflows/$NAME.md"
else
    DEST=".agent/rules/$NAME.md"
fi

if [ -f "$DEST" ]; then echo "⚠️ CONFLICT: $DEST already exists"; else echo "✅ No conflict"; fi
```

### 3. Action

- If no conflict: Copy source to destination. Report success.
- If conflict:
  - **Compare**: Read both files. Summarize differences.
  - **Ask**: "File exists. [O]verwrite, [M]erge, [R]ename, or [C]ancel?"
  - **Act**: Execute user choice.

## Related

- `/merge` — Semantic merge for workflow conflicts
- `/para-workflow` — Workflow catalog management
- `/para-rule` — Rule catalog management
