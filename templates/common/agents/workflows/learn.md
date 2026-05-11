---
description: Package lessons and knowledge into Areas/Learning
source: catalog
---

# /learn [topic-name]

> **Workspace Version:** 1.8.6

Capture and standardize knowledge and experience accumulated during development, stored in `Areas/Learning/`.

## Usage

```bash
/learn <topic-name>   # Create a new lesson
/learn audit          # Scan and migrate legacy lessons to the new Lessons/ directory
```


## Steps

### 1. Identify the Topic

Summarize the lesson or experience to be stored. Determine the category:

- **Technical** (Git, DevOps, Architecture)
- **Process** (Workflows, Best Practices)
- **Domain** (Business logic, Industry knowledge)

### 2. Create Learning File

// turbo

Create a `.md` file at `Areas/Learning/Lessons/[topic-name].md` using this template:

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

Add a link to the lesson in `Areas/Learning/Lessons/README.md` under the appropriate category (Git, Development, Best Practices...). If this is the first lesson, make sure `Areas/Learning/README.md` has a link pointing to `Lessons/README.md`.

### 4. Cross-Reference (Optional)

If the lesson originated from a specific project, add a reference back in the project's session log.

### 4.5. Knowledge Item Suggestion

- **High-value** (affects multiple projects or sessions)
- **Cross-project** (not specific to one project)
- **Persistent** (unlikely to change frequently)

If qualified:

```
💡 This lesson could also be a Knowledge Item for cross-session persistence.
   Lessons live in Areas/Learning/Lessons/ (project-scoped).
   KIs persist in the AI platform (cross-session, auto-loaded).

   Create KI? Run `/para-knowledge [topic]` (Y/N)
```

```

### 5. Action: audit

// turbo

When the user runs `/learn audit`:

This action scans `Areas/Learning/` for legacy files stored at the root level and migrates them into the `Lessons/` subdirectory to maintain a clean architecture separating `Lessons` and `Resources`.

```bash
bash .agents/skills/learn/scripts/audit-migrate.sh
```

## Related

- `/brainstorm` — Option E exits to /learn for reusable cross-project insights
- `/end` — End session (may trigger /learn for significant discoveries)
- `/retro` — Project retrospective (graduates beads to learnings)
- `/inbox` — Categorize incoming files
