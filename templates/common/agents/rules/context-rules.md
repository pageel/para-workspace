---
description: Context loading, session start, project detection and rule cascade
trigger: always_on
glob:
---

# Agent Routing & Context Loading

<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->

> Agent governance rule for context management and routing. Based on RFC-0003.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. Context Loading Priority

**MUST** load context in this sequence (highest priority first):

1. **Project Contract**: `Projects/<project>/project.md`
2. **Project Rules**: `Projects/<project>/.agents/rules/`
3. **Project Skills**: `Projects/<project>/.agents/skills/` (v1.6.2+)
4. **Workspace Rules**: `.agents/rules/`
5. **Workspace Skills**: `.agents/skills/` (v1.6.2+)
6. **Artifacts**: `Projects/<project>/artifacts/` (tasks, plans, walkthroughs)
7. **Active Memory**: `Projects/<project>/.beads/`
8. **Abstract Knowledge**: `Areas/`
9. **Reference**: `Resources/`

### 2. Isolation & Relevance

- **MUST** look inside the active project folder before searching elsewhere.
- **MUST NOT** read from `Archive/` unless the user explicitly requests historical data.
- **MUST NOT** scan other projects unless working on an integration or explicitly told to.
- **SHOULD** prefer `.beads/` data over general documentation for recurring issues.

### 3. Beads Lifecycle (RFC-0002)

- **SHOULD** create friction beads in `Projects/<project>/.beads/` when encountering repeated logic failures, project-specific quirks, or critical decisions.
- Beads are allowed to be messy, partial, and contradictory while the project is active.
- **MUST** perform a "Graduation Review" before archiving a project — move valuable knowledge from beads to `Areas/`, `Resources/`, or `.agents/rules/`.

### 4. Agent Index Loading (Two-Tier Progressive Disclosure)

When beginning work on a project (via `/open` or context detection):

**Tier 1: Workspace Indices (ALWAYS)**

- **MUST** read `.agents/rules.md` (workspace-level rules trigger index).
- **MUST** read `.agents/skills.md` (workspace-level skills trigger index, v1.6.2+).
- These files list triggers (~20 lines each, ~200 tokens total).
- Agent memorizes trigger tables and loads specific files **on demand**.
- **MUST NOT** skip — global rules and skills apply to ALL projects.

**Tier 2: Project Indices (CONDITIONAL)**

- Check `project.md` for `agent` map (v1.6.2+) or `has_rules` (legacy):
  ```
  IF agent.rules: true  → read project .agents/rules.md
  ELIF has_rules: true  → read project .agents/rules.md (backward compat)
  IF agent.skills: true → read project .agents/skills.md
  ```
- **If index exists:**
  - Read the index file (~5–10 lines) to learn triggers.
  - Load a specific file **ONLY WHEN** the current action matches its trigger.
  - **MUST NOT** read all files upfront — load on demand.
- **If index does not exist:**
  - Check if directory has files. If so, list names and load when relevant.
  - If empty or missing — skip entirely.

**Proactive Trigger Check (v1.6.2+):**

BEFORE any action that edits files, runs commands, creates artifacts, or brainstorms technical solutions:

1. Scan workspace `rules.md` trigger table
2. Scan workspace `skills.md` trigger table
3. Scan project `rules.md` trigger table (if loaded)
4. Scan project `skills.md` trigger table (if loaded)
5. **IF match found → read the rule/skill file BEFORE acting**

> Principle: Check THEN act — never act THEN check.

> **Index format** — workspace and project (`rules.md` / `skills.md`):
>
> ```markdown
> | Rule/Skill | Trigger                | File        | Pri |
> | :--------- | :--------------------- | :---------- | :-- |
> | Name       | When to load this item | filename.md | 🔴  |
> ```
>
> **File Guards format** (optional section in project `rules.md`):
>
> ```markdown
> ## File Guards
>
> | File pattern   | MUST re-read | Reason                |
> | :------------- | :----------- | :-------------------- |
> | `path/to/file` | rule-name.md | Why this guard exists |
> ```
>
> File Guards extend the global table in `agent-behavior.md` §4. Agent reads both global + project guards during Context Recovery.
