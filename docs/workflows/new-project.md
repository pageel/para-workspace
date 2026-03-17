# /new-project Workflow

> **Version**: 1.5.4

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
├── artifacts/tasks/
│   ├── backlog.md         # Operational authority
│   ├── done.md            # Append-only archive
│   └── sprint-current.md  # Hot Lane
├── docs/
└── project.md
```

### 2. Define Goal

Sets `project.md` frontmatter: goal, deadline, status, DoD.

### 3. Initialize Task Files

Populates `backlog.md` with the initial roadmap. Creates `done.md` and `sprint-current.md` with guard headers (`<!-- ⚠️ ... -->`) per `hybrid-3-file-integrity.md` C6.

### 4. Register in Config

Adds project to `.para-workspace.yml`.

### 5. First Session

Records kickoff in `sessions/YYYY-MM-DD.md`.

## Output Checklist

- [ ] Folder structure created
- [ ] Registered in `.para-workspace.yml`
- [ ] Goals in `project.md`
- [ ] Backlog initialized
- [ ] `done.md` + `sprint-current.md` created with guard headers
- [ ] First session logged

## Related

- [Workflow /open](./open.md)
- [Workflow /plan](./plan.md)
- [Workflow /backlog](./backlog.md)

---

_Updated in v1.5.4 (FEAT-47: Companion file templates with guard headers)_
