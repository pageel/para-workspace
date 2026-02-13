# Kernel Heuristics

> **Changing heuristics = MINOR/PATCH version bump**
> These are soft rules and conventions. They are strongly recommended but can be adapted based on context. Violations are not breaking changes.

---

## H1. Naming Conventions

### File System

| Object              | Convention         | Examples                                        |
| ------------------- | ------------------ | ----------------------------------------------- |
| Project slug        | `kebab-case`       | `my-saas-app`, `campaign-q1-2026`               |
| Session file        | `YYYY-MM-DD.md`    | `2026-02-13.md`                                 |
| Decision file       | `<timestamp>.json` | `1739001234.json`                               |
| Plan file           | `plan-v<NNN>.md`   | `plan-v001.md`                                  |
| Folder names (PARA) | PascalCase         | `Projects/`, `Areas/`, `Resources/`, `Archive/` |
| Sub-folder names    | kebab-case         | `ai-agents/`, `web-development/`                |
| Workflow files      | kebab-case         | `new-project.md`, `para-discipline.md`          |

### Source Code

| Object                | Convention         | Examples                          |
| --------------------- | ------------------ | --------------------------------- |
| Components & classes  | `PascalCase`       | `UserCard`, `AuthService`         |
| Variables & functions | `camelCase`        | `isLoading`, `calculateTotal()`   |
| Constants & env vars  | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT`, `API_BASE_URL` |
| CSS classes & IDs     | `kebab-case`       | `.btn-primary`, `#main-content`   |
| HTML data attributes  | `kebab-case`       | `data-user-id`, `data-is-active`  |
| Metadata JSON keys    | `camelCase`        | `"projectName"`, `"lastSync"`     |

### Exceptions

- `README.md`, `LICENSE`, `VERSION`, `CHANGELOG.md` follow established uppercase conventions
- Tool-specific files follow their tool's requirements: `package.json`, `tsconfig.json`

## H2. Context Loading Priority

Agent should load context in this sequence (highest priority first):

1. **Project Contract**: `Projects/<project>/project.md`
2. **Project Rules**: `Projects/<project>/.agent/rules/`
3. **Workspace Rules**: `.agent/rules/`
4. **Artifacts**: `Projects/<project>/artifacts/` (tasks, plans, walkthroughs)
5. **Active Memory**: `Projects/<project>/.beads/`
6. **Abstract Knowledge**: `Areas/`
7. **Reference**: `Resources/`

### Isolation Rules

- **Scope First**: Always look inside the active project folder before searching elsewhere
- **Ignore Archive**: Do not read from `Archive/` unless the user explicitly requests historical data
- **Ignore Passive Projects**: Do not scan other projects unless working on an integration
- **Beads Priority**: For recurring issues, prefer `.beads/` data over general documentation

## H3. Versioning

### Semantic Versioning

Use **SemVer** (`MAJOR.MINOR.PATCH`) for all projects:

| Level     | When to use                                       | Agent autonomy               |
| --------- | ------------------------------------------------- | ---------------------------- |
| **PATCH** | Bug fixes, docs, small features, dependency bumps | Agent MAY increment alone    |
| **MINOR** | Significant features, architectural changes       | Agent MUST ask for approval  |
| **MAJOR** | Breaking changes, incompatible structure changes  | Agent MUST present full plan |

### Version Synchronization

When bumping a version, update ALL locations:

- `CHANGELOG.md` (add new entry at the top)
- `package.json` (if applicable)
- UI elements (footers, badges)
- `README.md` badges (if applicable)

### CHANGELOG Convention

- Follow [Keep a Changelog](https://keepachangelog.com/) format
- Group changes: `Added`, `Changed`, `Fixed`, `Removed`
- Include date: `## [X.Y.Z] - YYYY-MM-DD`

## H4. Project Structure

Recommended project directory layout:

```
<project-slug>/
├── project.md              # YAML frontmatter: goal, deadline, status, dod
├── sessions/
│   └── YYYY-MM-DD.md       # Daily session logs
├── artifacts/
│   ├── tasks/
│   │   ├── backlog.md      # Canonical task store
│   │   ├── sprint-current.md  # Active tasks view
│   │   └── done.md         # Completed tasks archive
│   ├── plans/
│   │   └── plan-v001.md    # Versioned plans
│   ├── para-decisions/
│   │   └── <timestamp>.json # Decision records
│   └── outputs/            # Deliverables
├── .beads/
│   └── seeds.md            # Ideas, hypotheses, raw notes
└── README.md
```

## H5. Beads Lifecycle

1. **Creation**: Create beads in `.beads/` when encountering repeated issues, project-specific quirks, or critical decisions
2. **Messy Thinking**: Beads are allowed to be messy, partial, and contradictory while the project is active
3. **Graduation Ritual**: Before archiving, perform a "Graduation Review" — move valuable knowledge from beads to `Areas/`, `Resources/`, or `.agent/rules/`

## H6. VCS & Git Boundaries

- Git operations should only affect the `repo/` directory (for framework projects)
- Session logs, local artifacts, and metadata are **not committed** unless explicitly tracked in repo
- Never run git commands at workspace root unless updating the template repository itself

## H7. Cross-Project References

- When referencing content from another project, use full relative paths
- Prefer creating a shared resource in `Resources/` over cross-project file dependencies
- Each project should be as self-contained as possible

## H8. Workflow Compatibility

Each workflow should declare kernel compatibility:

```yaml
kernel_compat: ">=1.0.0 <2.0.0"
```

This helps detect issues when the kernel changes (e.g., renamed files, changed schemas).
