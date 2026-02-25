---
description: Initialize a new PARA-compliant project with scaffolding
source: catalog
---

# /new-project [project-name]

> **Workspace Version:** 1.4.1 (Governed Libraries)

Initialize a new PARA project with standard scaffolding and artifacts.

## Steps

### 1. Scaffold Project

// turbo

```bash
./para scaffold [project-name]
```

This creates the standard structure:

```
Projects/[project-name]/
├── repo/              # Source code (git init)
├── sessions/          # Session logs
├── artifacts/
│   └── tasks/
│       └── backlog.md # Product backlog
├── docs/              # Project documentation
└── project.md         # Project contract (YAML frontmatter)
```

### 2. Define Goal

Update `Projects/[project-name]/project.md` with:

```yaml
---
goal: "[Specific, measurable project goal]"
deadline: "YYYY-MM-DD"
status: "active"
dod:
  - "[Done condition 1]"
  - "[Done condition 2]"
last_reviewed: "YYYY-MM-DD"
---
```

### 3. Initialize Backlog

// turbo

Edit `Projects/[project-name]/artifacts/tasks/backlog.md` to reflect the initial roadmap. Use the template from `/backlog`.

### 4. Register in Workspace Config

// turbo

Add the project to `.para-workspace.yml` if not already registered.

### 5. Start First Session

Record the kickoff in `Projects/[project-name]/sessions/YYYY-MM-DD.md`:

```markdown
# YYYY-MM-DD | [project-name]

## Session 1: Project Kickoff

- **Goal**: [project goal]
- **Initial Backlog**: [N] items defined
- **Tech Stack**: [technologies]
- **Next Steps**: [first priority]
```

## Output Checklist

- [ ] Project folder structure created
- [ ] Registered in `.para-workspace.yml`
- [ ] Goals defined in `project.md`
- [ ] Backlog initialized
- [ ] First session logged

## Related

- `/open` — Start session with context loading
- `/backlog` — Manage project backlog
- `/config` — Register project in workspace config
