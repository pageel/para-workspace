# Agent Routing & Context Loading

> Agent governance rule for context management and routing. Based on RFC-0003.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. Context Loading Priority

**MUST** load context in this sequence (highest priority first):

1. **Project Contract**: `Projects/<project>/project.md`
2. **Project Rules**: `Projects/<project>/.agent/rules/`
3. **Workspace Rules**: `.agent/rules/`
4. **Artifacts**: `Projects/<project>/artifacts/` (tasks, plans, walkthroughs)
5. **Active Memory**: `Projects/<project>/.beads/`
6. **Abstract Knowledge**: `Areas/`
7. **Reference**: `Resources/`

### 2. Isolation & Relevance

- **MUST** look inside the active project folder before searching elsewhere.
- **MUST NOT** read from `Archive/` unless the user explicitly requests historical data.
- **MUST NOT** scan other projects unless working on an integration or explicitly told to.
- **SHOULD** prefer `.beads/` data over general documentation for recurring issues.

### 3. Beads Lifecycle (RFC-0002)

- **SHOULD** create friction beads in `Projects/<project>/.beads/` when encountering repeated logic failures, project-specific quirks, or critical decisions.
- Beads are allowed to be messy, partial, and contradictory while the project is active.
- **MUST** perform a "Graduation Review" before archiving a project — move valuable knowledge from beads to `Areas/`, `Resources/`, or `.agent/rules/`.
