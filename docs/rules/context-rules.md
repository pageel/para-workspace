# Context Rules — Agent Routing & Context Loading

> **Version**: 1.5.4

Governs how the agent loads and prioritizes context within the workspace. Defines loading order, project isolation, beads lifecycle, and the Two-Tier Progressive Disclosure mechanism for rules.

## Scope

- **Type**: Global (all projects)
- **Priority**: 🟡 Important
- **Trigger**: Loading context, starting session, detecting project

## Rules

### 1. Context Loading Priority

MUST load context in this sequence (highest priority first):

1. **Project Contract** — `Projects/<project>/project.md`
2. **Project Rules** — `Projects/<project>/.agent/rules/`
3. **Workspace Rules** — `.agent/rules/`
4. **Artifacts** — `Projects/<project>/artifacts/`
5. **Active Memory** — `Projects/<project>/.beads/`
6. **Abstract Knowledge** — `Areas/`
7. **Reference** — `Resources/`

### 2. Isolation & Relevance

- MUST search active project folder first.
- MUST NOT read from `Archive/` unless user requests historical data.
- MUST NOT scan other projects unless working on integration.
- SHOULD prefer `.beads/` over general docs for recurring issues.

### 3. Beads Lifecycle

Beads capture project-specific decisions, failures, and quirks in `Projects/<project>/.beads/`. Allowed to be messy and partial during active development. MUST perform "Graduation Review" before archiving — move valuable knowledge to `Areas/`, `Resources/`, or `.agent/rules/`.

### 4. Rules Loading — Two-Tier Progressive Disclosure

**Tier 1 (ALWAYS):** Read `.agent/rules.md` (~20 lines, ~200 tokens). Memorize trigger table, load rule files on demand.

**Tier 2 (CONDITIONAL):** Check `Projects/<project>/.agent/rules.md`. If exists, read index and load rules when triggers match. If missing, skip.

**Standard index format:**

```markdown
| Rule      | Trigger                | File        | Pri |
| :-------- | :--------------------- | :---------- | :-- |
| Rule Name | When to load this rule | filename.md | 🔴  |
```

**File Guards format** (optional, extends `agent-behavior.md` §4):

```markdown
## File Guards
| File pattern   | MUST re-read | Reason                |
| :------------- | :----------- | :-------------------- |
| `path/to/file` | rule-name.md | Why this guard exists |
```

## Related

- [Rule Layers Architecture](../architecture/rule-layers.md)
- [Context Recovery](../architecture/context-recovery.md)
- [Agent Behavior](./agent-behavior.md) — Context Recovery protocol
- **Source**: `templates/common/agent/rules/context-rules.md`
