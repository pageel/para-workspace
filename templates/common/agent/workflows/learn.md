---
description: Package lessons and knowledge into Areas/Learning
source: catalog
---

# /learn [topic-name]

> **Workspace Version:** 1.4.1 (Governed Libraries)

Capture and standardize knowledge and experience accumulated during development, stored in `Areas/Learning/`.

## Steps

### 1. Identify the Topic

Summarize the lesson or experience to be stored. Determine the category:

- **Technical** (Git, DevOps, Architecture)
- **Process** (Workflows, Best Practices)
- **Domain** (Business logic, Industry knowledge)

### 2. Create Learning File

// turbo

Create a `.md` file at `Areas/Learning/[topic-name].md` using this template:

```markdown
# [Lesson Title]

> [Core value summary of the lesson]

## Context

- Describe the situation or error encountered.
- Why the old method was ineffective.

## Solution

- Detailed handling method.
- Tools or techniques used (e.g., React Portal, Python Script...).

## Key Learnings

- Point 1: Technical.
- Point 2: Process.
- Point 3: Important notes.

## Code Example (If applicable)

- Code snippet illustrating the optimal solution.
```

### 3. Update Index

// turbo

Add a link to the lesson in `Areas/Learning/README.md` under the appropriate category (Git, Development, Best Practices...).

### 4. Cross-Reference (Optional)

If the lesson originated from a specific project, add a reference back in the project's session log.

## Related

- `/end` — End session (may trigger /learn for significant discoveries)
- `/retro` — Project retrospective (graduates beads to learnings)
- `/inbox` — Categorize incoming files
