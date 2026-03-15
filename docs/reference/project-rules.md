# Rules & Context Loading

> **Version**: 1.5.3

PARA Workspace uses a **Two-Tier** rule loading system. Global rules apply to all projects, while project-specific rules add constraints for individual projects. Both tiers use **progressive disclosure** — agents load rules on demand, not all at once.

## How It Works

### Rule Hierarchy

```
.agent/rules.md                    ← Workspace rules INDEX (always loaded)
.agent/rules/                      ← Global rule files (10 rules, loaded on demand)
Projects/<project>/.agent/rules.md ← Project rules INDEX (loaded if has_rules: true)
Projects/<project>/.agent/rules/   ← Project rule files (loaded on demand)
```

Project rules **supplement** global rules — they do not override them.

### Tier 1: Workspace Rules Index (ALWAYS)

The file `.agent/rules.md` lists all global rules with trigger conditions (~20 lines, ~200 tokens).

`/open` Step 2.5a **ALWAYS** reads this file, regardless of which project is active. This ensures global rules like `hybrid-3-file-integrity.md` (Hot Lane logging) and `governance.md` (system file protection) are always known to the agent.

### Tier 2: Project Rules Index (CONDITIONAL)

Each project MAY provide a lightweight `rules.md` index at:

```
Projects/<project>/.agent/rules.md
```

This ~5–10 line file tells the agent **what project-specific rules exist** and **when to load them**:

```markdown
| Rule              | Trigger                                   | File                 |
| :---------------- | :---------------------------------------- | :------------------- |
| Dogfooding Policy | Editing repo/, syncing files to workspace | dogfooding-policy.md |
| Maintenance       | Version bumps, writing docs/changelog     | maintenance.md       |
```

`/open` Step 2.5b reads this file only when `project.md` has `has_rules: true`.

### Loading Protocol

1. Agent starts working on a project (via `/open` or context detection).
2. **Step 2.5a:** Agent reads `.agent/rules.md` (workspace index) — ALWAYS.
3. **Step 2.5b:** Agent checks `has_rules` → reads project rules index if true.
4. During the session, when an action matches a trigger from EITHER index → agent reads that specific rule file.
5. Rules not matching any current action are **never loaded**.

> **Why two tiers?** Without the workspace index, agents with `has_rules: false` skip ALL rules — including critical global ones like Hot Lane logging (C1). The workspace tier ensures global rules are always discoverable.

## Creating Project Rules

Use the `/para-rule add` action:

1. Create the rule file in `Projects/<project>/.agent/rules/[name].md`
2. Follow the standard rule template (Scope, Rules, Examples)
3. Update the project's `rules.md` index with the rule name, trigger, and filename

## Governed Rule: `context-rules.md`

The Two-Tier loading protocol is defined in `context-rules.md` Rule #4 (shipped with the kernel). This ensures all agents in all workspaces follow the same progressive disclosure pattern.

## Related

- [Rule Layers Architecture](../architecture/rule-layers.md) — Full architecture with diagrams
- [Kernel Documentation](../architecture/kernel.md) — Invariants and governance
- [Workflow Documentation](./workflows.md) — `/para-rule` workflow

---

_Updated in v1.5.3 (BUG-17: Two-Tier Rule Gate)_
