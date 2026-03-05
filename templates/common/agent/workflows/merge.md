---
description: Intelligent agentic merge for workflows. Combines user customizations with catalog updates.
source: catalog
---

# /merge [target-workflow]

> **Workspace Version:** 1.5.0 (Governed Libraries)

Intelligently merge a user's customized workflow with the latest version from the governed catalog.

## Usage

```bash
/merge open       # Merge local /open with catalog version
/merge backlog    # Merge local /backlog with catalog version
```

## Logic Flow

1.  **Identify Paths**:
    - **User (Local)**: `.agent/workflows/[target].md`
    - **Catalog (Source)**: Governed catalog directory (priority order):
      1. `Projects/para-workspace/repo/templates/common/agent/workflows/[target].md`
      2. `Resources/references/para-workspace/templates/common/agent/workflows/[target].md`

2.  **Read Content**:
    - Read both files to understand the context.

3.  **Semantic Analysis**:
    - **Identify Customizations**: What has the user changed? (e.g., custom deploy steps, specific notification channels).
    - **Identify Updates**: What is new in the catalog version? (e.g., new standard CLI commands, improved prompts).

4.  **Intelligent Merge Strategy**:
    - **Preserve**: KEEP all user variables, custom steps, and project-specific logic.
    - **Inject**: ADD new sections or improvements from the catalog that do not conflict with user intent.
    - **Update**: UPGRADE deprecated syntax (e.g., old CLI flags, legacy paths) to the new standard.

5.  **Execution**:
    - Generate the fully merged content.
    - Create a backup `.bak` before writing.
    - Write merged content to `.agent/workflows/[target].md`.

## Step-by-Step Instructions

### 1. Load Context

// turbo

Read both files:

- **Local**: `.agent/workflows/[target].md`
- **Catalog**: Resolve from governed catalog source (see Logic Flow step 1).

### 2. Analyze & Plan

**Thinking Process:**

- Compare Local vs Catalog.
- Note down unique user sections (to preserve).
- Note down new catalog features (to inject).
- Identify deprecated patterns (to upgrade).
- Draft a structure that combines both.

### 3. Generate & Apply

1. Create backup: copy `.agent/workflows/[target].md` → `.agent/workflows/[target].md.bak`
2. Write the merged content to `.agent/workflows/[target].md`.
3. Ensure the frontmatter description reflects any new capabilities.

### 4. Verify

- Display a summary of what was preserved, injected, and upgraded.
- Ask the user to confirm the merge looks correct.

## Related

- `/install` — Install with conflict resolution (delegates here for merge)
- `/para-workflow` — Workflow catalog management
- `/para-rule` — Rule catalog management
