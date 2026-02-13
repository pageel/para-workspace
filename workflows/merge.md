---
description: Intelligent agentic merge for workflows. Combines user customizations with catalog updates.
---

# /merge [target-workflow]

> **Workspace Version:** 1.4.0

This workflow intelligently merges a user's customized workflow with the latest version from the PARA Catalog.

## Usage

```bash
/merge target=kickoff
```

## Logic Flow

1.  **Identify Paths**:
    - User (Destination): `.agent/workflows/[target].md`
    - Catalog (Source): `.agent/workflows/[target].md`

2.  **Read Content**:
    - AI reads both files to understand the context.

3.  **Semantic Analysis**:
    - **Identify Customizations**: What has the user changed? (e.g., custom deploy steps, specific notification channels).
    - **Identify Updates**: What is new in the catalog version? (e.g., new standard CLI commands, improved prompts).

4.  **Intelligent Merge Strategy**:
    - **Preserve**: KEEP all user variables, custom steps, and project-specific logic.
    - **Inject**: ADD new sections or improvements from the catalog that do not conflict with user intent.
    - **Update**: UPGRADE deprecated syntax (e.g., old CLI flags) to the new standard.

5.  **Execution**:
    - Generate the fully merged content.
    - Write it to `.agent/workflows/[target].md`.
    - (Optionally) Create a backup `.bak` before writing.

## Step-by-Step Instructions for Agent

### 1. Load Context

// turbo

```bash
CATALOG=".agent/workflows/[target].md"
USER_FILE=".agent/workflows/[target].md"

cat "$CATALOG"
cat "$USER_FILE"
```

### 2. Analyze & Plan

**Thinking Process:**

- Compare `USER_FILE` vs `CATALOG`.
- Note down unique user sections.
- Note down new catalog features.
- Draft a structure that combines both.

### 3. Generate & Apply

**Action:**

- Use `write_to_file` to overwrite `USER_FILE` with the _merged content_.
- Ensure the frontmatter description is updated to reflect the merge.

### 4. Verify

- Ask the user to confirm the merge looks correct.
