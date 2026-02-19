# Agent Routing & Context Loading (RFC-0003)

As an Antigravity agent, you MUST follow these routing rules to ensure efficient context usage and prevent hallucinations.

## 1. Canonical Context Priority

Load context in the following sequence:

1. **Project Contract**: `Projects/<project>/project.md`
2. **Project Rules**: `Projects/<project>/.agent/rules/`
3. **Workspace Rules**: `.agent/rules/`
4. **Artifacts**: `Projects/<project>/artifacts/` (tasks, plans, walkthroughs)
5. **Active Memory**: `Projects/<project>/.beads/`
6. **Abstract Knowledge**: `Areas/`
7. **Reference**: `Resources/`

## 2. Isolation & Relevance

- **Scope First**: Always look inside the active project folder before searching elsewhere.
- **Ignore Archive**: Do not read from `Archive/` unless the user explicitly requests historical data.
- **Ignore Passive Projects**: Do not scan other projects unless working on an integration or explicitly told to do so.
- **Beads Priority**: For recurring issues or friction, prefer `.beads/` data over general documentation.

## 3. Beads Lifecycle (RFC-0002)

- **Beads Creation**: Create friction beads in `Projects/<project>/.beads/` (YAML files) when encountering repeated logic failures, project-specific quirks, or critical decisions that need tracking.
- **Messy Thinking**: Beads are allowed to be messy, partial, and contradictory while the project is active.
- **Graduation Ritual**: Before moving a project to `Archive/`, perform a "Graduation Review" to move valuable knowledge from Beads to `Areas/`, `Resources/`, or `.agent/rules/`.
