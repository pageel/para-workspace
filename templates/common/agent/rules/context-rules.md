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

### 4. Rules Loading (Two-Tier Progressive Disclosure)

When beginning work on a project (via `/open` or context detection):

**Tier 1: Workspace Rules (ALWAYS)**

- **MUST** read `.agent/rules.md` (workspace-level rules trigger index).
- This file lists all **global rules** with trigger conditions (~20 lines, ~200 tokens).
- Agent memorizes the trigger table and loads specific rule files **on demand**.
- **MUST NOT** skip this step — global rules apply to ALL projects.

**Tier 2: Project Rules (CONDITIONAL)**

- **MUST** check for `Projects/<project>/.agent/rules.md` (project-level Rules Index).
- **If index exists:**
  - Read the index file (~5–10 lines) to learn what project-specific rules exist.
  - Load a specific rule file **ONLY WHEN** the current action matches its trigger.
  - **MUST NOT** read all rule files upfront — load on demand.
- **If index does not exist:**
  - Check if `Projects/<project>/.agent/rules/` directory has files.
  - If files exist, list names and load only when relevant.
  - If empty or missing — skip entirely.

During the session, when an action matches a trigger from **EITHER** index, the agent **MUST** read the corresponding rule file **BEFORE** acting.

> **Rules Index format** — workspace (`rules.md`) and project (`Projects/<project>/.agent/rules.md`):
>
> ```markdown
> | Rule      | Trigger                | File        |
> | :-------- | :--------------------- | :---------- |
> | Rule Name | When to load this rule | filename.md |
> ```
