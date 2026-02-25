---
description: Manage and enforce PARA-compliant rules
source: catalog
---

# /para-rule [action] [name]

> **Workspace Version:** 1.4.1 (Governed Libraries)

Manage, install, and standardize AI Agent rules within a PARA Workspace.

## Actions

| Action        | Description                                             |
| :------------ | :------------------------------------------------------ |
| `list`        | Compare active rules vs. governed catalog               |
| `add`         | Create a new PARA-compliant rule                        |
| `standardize` | Upgrade an existing rule to v1.4.1 standards            |
| `install`     | Install or update a rule from the governed catalog      |
| `validate`    | Check a rule for PARA compliance without making changes |

---

## 📋 Action: list

Compare rules currently active in `.agent/rules/` against the governed catalog.

### Steps

// turbo

**Step 1.** List active rules:

```bash
echo "🛡️ ACTIVE RULES (.agent/rules):"
ls -1 .agent/rules/*.md 2>/dev/null | xargs -I{} basename {} .md | sort
echo ""
```

**Step 2.** Read `catalog.yml` from the governed catalog source (priority order):

1. `Projects/para-workspace/repo/templates/common/agent/rules/catalog.yml`
2. `Resources/references/para-workspace/templates/common/agent/rules/catalog.yml`

**Step 3.** Display comparison report:

```
📦 GOVERNED CATALOG (rules/catalog.yml):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| ID             | Version | Status          |
| -------------- | ------- | --------------- |
| para-discipline| 1.0.0   | ✅ Installed    |
| vcs            | 1.0.0   | ⚠️ Not installed |
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🛠 Action: add [name]

Create a new PARA-compliant rule.

### Steps

1. **Create file**: `.agent/rules/[name].md`
2. **Apply standard template**:

```markdown
# [Rule Name]

> [One-line purpose of this rule]

## Scope

- [ ] Global (applies to entire workspace)
- [ ] Project-specific

## Rules

1. **MUST**: [Affirmative rule statement]
2. **SHOULD**: [Recommended practice]
3. **MUST NOT**: [Prohibition]

## Examples

### ✅ Correct

[Example of compliant behavior]

### ❌ Incorrect

[Example of non-compliant behavior]
```

3. **Conventions**:
   - Use affirmative language (Must, Should, Must Not).
   - Categorize clearly (VCS, Naming, Layout, Safety).
   - Ensure rules do not conflict with `para-discipline.md`.

---

## 📈 Action: standardize [name]

Upgrade an existing rule to v1.4.1 standards.

### Checklist

| #   | Check                    | Rule                                                         |
| --- | ------------------------ | ------------------------------------------------------------ |
| 1   | **No Absolute Paths**    | Remove any hardcoded filesystem paths                        |
| 2   | **PARA Boundaries**      | References must point to valid PARA directories              |
| 3   | **Affirmative Language** | Use Must/Should/Must Not (not vague suggestions)             |
| 4   | **Agent Guidance**       | Rules must provide clear, actionable instructions for the AI |
| 5   | **No Conflicts**         | Must not contradict `para-discipline.md`                     |

---

## 🚀 Action: install [name]

Install a rule from the governed catalog into `.agent/rules/`.

### Steps

1. **Resolve source**: Find the rule file in the catalog source directory.
2. **Check conflict**: If `.agent/rules/[name].md` already exists, delegate to `/install` workflow for conflict resolution.
3. **Copy**: Install the file into `.agent/rules/[name].md`.
4. **Report**: Confirm installation.

---

## ✅ Action: validate [name]

Check a rule for PARA compliance without making changes.

### Steps

1. Read `.agent/rules/[name].md`.
2. Run the **standardize checklist** (read-only mode).
3. Output a compliance report.

---

## ⚖️ Context Routing (RFC-0003)

- Project Rules (`Projects/[project-name]/.agent/rules/`) take priority over Global Rules (`.agent/rules/`).
- Use `.agent/rules/context-rules.md` to prevent context bloat.

## 🎓 Graduation (Beads to Rules)

- During `/retro`, if a "Bead" (knowledge point) repeats multiple times, propose "graduating" it into an official Rule in `.agent/rules/`.

## Related

- `/para` — Master workspace controller
- `/para-workflow` — Workflow management (sister workflow)
- `/install` — Generic installer with conflict resolution
