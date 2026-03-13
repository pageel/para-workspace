# 🧠 PARA Workspace Kernel

The Kernel is the **canonical rule system** for PARA Workspace. It defines what is allowed, recommended, and enforced across all workspace instances.

## Structure

```
kernel/
├── KERNEL.md                      # Constitution — supreme law overview
├── invariants.md                  # Hard rules (change = MAJOR bump)
├── heuristics.md                  # Soft rules (change = MINOR/PATCH)
├── schema/
│   ├── tasks.schema.md            # Task file format definition
│   ├── backlog.schema.json        # Backlog validation schema
│   ├── decision-plan.schema.json  # Decision record JSON Schema
│   ├── catalog.schema.json        # Governed library catalog schema
│   ├── project.schema.json        # project.md frontmatter schema
│   └── workspace.schema.json      # .para-workspace.yml schema
├── examples/
│   ├── decisions/                 # Valid decision record examples
│   │   └── task-management-model.json
│   └── tasks/                     # Valid task file examples
│       ├── backlog.md
│       ├── sprint-current.md
│       └── done.md
└── README.md                      # This file
```

## Quick Reference

### Invariants (Must follow)

| #   | Rule                                                                |
| --- | ------------------------------------------------------------------- |
| I1  | PARA directory structure (Projects, Areas, Resources, Archive)      |
| I2  | Hybrid 3-file task model (backlog = canonical, hot lane, /end sync) |
| I3  | kebab-case project naming                                           |
| I4  | No active tasks = inactive project                                  |
| I5  | Areas contain no runtime tasks                                      |
| I6  | Archive is immutable cold storage                                   |
| I7  | Seeds are raw ideas, not tasks                                      |
| I8  | No loose files at workspace root                                    |
| I9  | Resources are read-only references                                  |
| I10 | Repo ↔ Workspace separation                                         |
| I11 | Workflow language compliance (preferences.language)                 |

### Heuristics (Should follow)

| #   | Guideline                                                    |
| --- | ------------------------------------------------------------ |
| H1  | Naming conventions (kebab-case files, PascalCase components) |
| H2  | Context loading priority                                     |
| H3  | Semantic versioning with approval levels                     |
| H4  | Standard project directory structure                         |
| H5  | Beads lifecycle (create → messy → graduate)                  |
| H6  | VCS & Git boundaries                                         |
| H7  | Cross-project references via Resources                       |
| H8  | Workflow kernel compatibility declaration                    |
| H9  | Governed library catalogs (catalog.yml required)             |

## For Contributors

See `../CONTRIBUTING.md` for the change process. Key rules:

- Invariant changes require **RFC + MAJOR bump**
- Heuristic changes require **PR + MINOR/PATCH bump**
- All changes must pass test vectors in `examples/`
