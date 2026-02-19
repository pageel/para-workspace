---
description: Intelligent agentic installer for workflows and rules. Handles updates, merges, and renames.
---

# /install [type] [name]

> **Workspace Version:** 1.4.0

Use this workflow to install or update components from the PARA Catalog. It handles conflicts intelligently.

## Usage

```bash
/install work kickoff   # Install 'kickoff' workflow
/install rule branding  # Install 'branding' rule
```

## Logic Flow

1.  **Resolve Source & Destination**:
    - **Workflows**: `.agent/workflows/[name].md` -> `.agent/workflows/[name].md`
    - **Rules**: `.agent/rules/[name].md` -> `.agent/rules/[name].md`

2.  **Check Status**:
    - If Destination does NOT exist: **Install immediately**.
    - If Destination EXISTS: **Trigger Conflict Resolution**.

3.  **Conflict Resolution (Interactive)**:
    - Agent checks if content is identical. If yes -> "Already up to date."
    - If different, Agent asks User:
      - **[O]verwrite**: Replace local with catalog version.
      - **[M]erge**: (Workflows only) Intelligently combine both.
      - **[R]ename**: Install catalog version as `p-[name].md` (or custom name).
      - **[C]ancel**: Do nothing.

4.  **Execution**:
    - Perform the selected file operation.
    - If Merge: Use semantic analysis to blend content.

## Step-by-Step Instructions

### 1. Verification

// turbo

```bash
TYPE="[type]" # 'work' or 'rule'
NAME="[name]"

if [ "$TYPE" == "work" ]; then
    SRC=".agent/workflows/$NAME.md"
    DEST=".agent/workflows/$NAME.md"
else
    SRC=".agent/rules/$NAME.md"
    DEST=".agent/rules/$NAME.md"
fi

if [ ! -f "$SRC" ]; then echo "❌ Catalog item not found: $SRC"; exit 1; fi
if [ -f "$DEST" ]; then echo "⚠️ PARAM_CONFLICT=true"; else echo "✅ PARAM_CONFLICT=false"; fi
```

### 2. Action

- If `PARAM_CONFLICT=false`: Copy `SRC` to `DEST`. Report success.
- If `PARAM_CONFLICT=true`:
  - **Compare**: Read both files. Summarize differences.
  - **Ask**: "File exists. Overwrite, Merge, or Rename?"
  - **Act**: Execute user choice.
