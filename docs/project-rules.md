# Project Rules & Context Loading

> **Version**: 1.5.0

PARA Workspace supports **project-specific rules** — custom governance that applies only when working on a particular project. Starting from v1.5.0, agents load these rules progressively to save tokens.

## How It Works

### Rule Hierarchy

```
.agent/rules/                    ← Global rules (always active)
Projects/<project>/.agent/rules/ ← Project rules (loaded on demand)
```

Project rules **supplement** global rules — they do not override them.

### Rules Index (Progressive Disclosure)

Each project MAY provide a lightweight `rules.md` index at:

```
Projects/<project>/.agent/rules.md
```

This ~5–10 line file tells the agent **what rules exist** and **when to load them**:

```markdown
| Rule              | Trigger                                   | File                 |
| :---------------- | :---------------------------------------- | :------------------- |
| Dogfooding Policy | Editing repo/, syncing files to workspace | dogfooding-policy.md |
| Maintenance       | Version bumps, writing docs/changelog     | maintenance.md       |
```

### Loading Protocol

1. Agent starts working on a project (via `/open` or context detection).
2. Agent checks for `rules.md` index → reads it (~5 lines, minimal tokens).
3. During the session, when an action matches a trigger → agent reads that specific rule file.
4. Rules not matching any current action are **never loaded**.

**If no index exists**, the agent checks `Projects/<project>/.agent/rules/` directory. If files exist, it lists names and loads only when relevant. If empty — skip entirely.

## Creating Project Rules

Use the `/para-rule add` action:

1. Create the rule file in `Projects/<project>/.agent/rules/[name].md`
2. Follow the standard rule template (Scope, Rules, Examples)
3. Update the project's `rules.md` index with the rule name, trigger, and filename

## Governed Rule: `context-rules.md`

The loading protocol is defined in `context-rules.md` Rule #4 (shipped with the kernel). This ensures all agents in all workspaces follow the same progressive disclosure pattern.

## Related

- [Kernel Documentation](../kernel.md) — Invariants and governance
- [Workflow Documentation](../workflows.md) — `/para-rule` workflow

---

_Added in v1.5.0_
