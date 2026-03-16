# /new-project Workflow

> **Version**: 1.5.0

Initialize a new PARA-compliant project with standard scaffolding and artifacts.

## Commands

```
/new-project project [project-name]
```

## Flow

```
Scaffold → Define goal → Init backlog → Register config → First session
```

### 1. Scaffold Project

Runs `./para scaffold [project-name]` to create:

```
Projects/[project-name]/
├── repo/              # Source code (git init)
├── sessions/          # Session logs
├── artifacts/tasks/backlog.md
├── docs/
└── project.md
```

### 2. Define Goal

Sets `project.md` frontmatter: goal, deadline, status, DoD.

### 3. Initialize Backlog

Populates `backlog.md` with the initial roadmap.

### 4. Register in Config

Adds project to `.para-workspace.yml`.

### 5. First Session

Records kickoff in `sessions/YYYY-MM-DD.md`.

## Output Checklist

- [ ] Folder structure created
- [ ] Registered in `.para-workspace.yml`
- [ ] Goals in `project.md`
- [ ] Backlog initialized
- [ ] First session logged

## Related

- [Workflow /open](./open.md)
- [Workflow /plan](./plan.md)
- [Workflow /backlog](./backlog.md)

---

_Updated in v1.5.0_
