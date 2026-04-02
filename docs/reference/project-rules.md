# Rules & Context Loading

> **Version**: 1.6.2

PARA Workspace uses a **Two-Tier** loading system for both rules and skills. Global indices apply to all projects, while project-specific indices add constraints for individual projects. Both tiers use **progressive disclosure** — agents load rules/skills on demand, not all at once. A **Context Recovery** mechanism ensures indices are re-loaded after context truncation. A **Proactive Trigger Check** (v1.6.2) ensures agents scan trigger tables before any side-effect.

## How It Works

### Rule Hierarchy

```
.agents/rules.md                    ← Workspace rules INDEX (always loaded)
.agents/skills.md                   ← Workspace skills INDEX (always loaded, v1.6.2+)
.agents/rules/                      ← Global rule files (10 rules, loaded on demand)
.agents/skills/                     ← Global skill files (loaded on demand)
Projects/<project>/.agents/rules.md ← Project rules INDEX (loaded if agent.rules: true)
Projects/<project>/.agents/skills.md← Project skills INDEX (loaded if agent.skills: true)
```

Project rules **supplement** global rules — they do not override them.

### Tier 1: Workspace Rules Index (ALWAYS)

The file `.agents/rules.md` lists all global rules with trigger conditions and priority levels (~20 lines, ~200 tokens). Rules are classified as 🔴 Critical, 🟡 Important, or 🟢 Standard.

`/open` Step 2.5a **ALWAYS** reads this file, regardless of which project is active. This ensures global rules like `hybrid-3-file-integrity.md` (Hot Lane logging) and `governance.md` (system file protection) are always known to the agent.

### Tier 2: Project Rules Index (CONDITIONAL)

Each project MAY provide a lightweight `rules.md` index at:

```
Projects/<project>/.agents/rules.md
```

This ~5–10 line file tells the agent **what project-specific rules exist** and **when to load them**:

```markdown
| Rule              | Trigger                                   | File                 | Pri |
| :---------------- | :---------------------------------------- | :------------------- | :-- |
| Dogfooding Policy | Editing repo/, syncing files to workspace | dogfooding-policy.md | 🔴  |
| Maintenance       | Version bumps, writing docs/changelog     | maintenance.md       | 🟡  |
```

`/open` Step 2.5c reads project indices when `project.md` has `agent.rules: true` or `agent.skills: true` (v1.6.2+). Falls back to `has_rules: true` for backward compatibility.

### Loading Protocol (v1.6.2)

1. Agent starts working on a project (via `/open` or context detection).
2. **Step 2.5a:** Agent reads `.agents/rules.md` (workspace index) — ALWAYS.
3. **Step 2.5b:** Agent reads `.agents/skills.md` (workspace index) — ALWAYS (v1.6.2+).
4. **Step 2.5c:** Agent checks `project.md` for `agent.rules`/`agent.skills` (or `has_rules` fallback) → reads project indices if true.
5. During the session, when an action matches a trigger from ANY index → agent reads that specific rule/skill file.
6. **Proactive Trigger Check** (v1.6.2): BEFORE any side-effect action, agent scans all loaded trigger tables. If a match is found, the rule/skill MUST be read BEFORE acting.
7. Rules/skills not matching any current action are **never loaded**.

> **Why two tiers?** Without the workspace index, agents skip ALL rules/skills — including critical global ones like Hot Lane logging (C1). The workspace tier ensures global governance is always discoverable.

### Context Recovery (v1.5.4)

After context truncation (checkpoint, sliding window), the agent may lose the rules index from memory. Four layers guard against this:

1. **Rule/skill files** — `agent-behavior.md` §4 instructs the agent to re-read `rules.md` and `skills.md` when context appears incomplete. Includes File-Level Guards and Proactive Trigger Check.
2. **Workflow output** — `/open` Step 8 includes a compact Safety Block that survives in checkpoint summaries.
3. **Workflow pre-flight** — Workflows with side-effects re-read both `rules.md` AND `skills.md` from disk as Step 0 before executing (Agent Indices Pre-flight, v1.6.2).
4. **File guard headers** — Task files include inline `<!-- ⚠️ -->` comments that remind the agent of write constraints even when all indices have been lost from context.

## Creating Project Rules

Use the `/para-rule add` action:

1. Create the rule file in `Projects/<project>/.agents/rules/[name].md`
2. Follow the standard rule template (Scope, Rules, Examples)
3. Update the project's `rules.md` index with the rule name, trigger, and filename

## Governed Rule: `context-rules.md`

The Two-Tier loading protocol is defined in `context-rules.md` Rule #4 (shipped with the kernel). This ensures all agents in all workspaces follow the same progressive disclosure pattern.

## Related

- [Rule Layers Architecture](../architecture/rule-layers.md) — Full architecture with diagrams
- [Kernel Documentation](../architecture/kernel.md) — Invariants and governance
- [Workflow Documentation](./workflows.md) — `/para-rule` workflow

---

_Updated in v1.6.2 (FEAT-53: Unified Agent Index + Proactive Trigger Check)_
