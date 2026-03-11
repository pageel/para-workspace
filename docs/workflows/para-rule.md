# /para-rule Workflow

> **Version**: 1.5.0

The `/para-rule` workflow manages, installs, and standardizes AI Agent rules within a PARA Workspace. Rules define mandatory behaviors and prohibitions for agents.

## Commands

```
/para-rule [action] [name]
```

| Action        | Description                               |
| :------------ | :---------------------------------------- |
| `list`        | Compare active rules vs. governed catalog |
| `add`         | Create a new PARA-compliant rule          |
| `standardize` | Upgrade existing rule to v1.4.1 standards |
| `install`     | Install rule from governed catalog        |
| `validate`    | Check compliance without making changes   |

## Actions

### list

Lists active rules in `.agent/rules/`, reads `catalog.yml`, and displays comparison: ✅ Installed / ⚠️ Not installed / 🔶 Untracked.

### add

Creates `.agent/rules/[name].md` with standard template including Scope, Rules (MUST/SHOULD/MUST NOT), and Examples.

### standardize

Checklist: No absolute paths, PARA boundaries, affirmative language, clear agent guidance, no conflicts with `para-discipline.md`.

### install

Resolves source from catalog, checks for conflicts (delegates to `/install` if needed), and copies to `.agent/rules/`.

### validate

Runs standardize checklist in read-only mode and outputs a compliance report.

## Context Routing (RFC-0003)

- Project Rules take priority over Global Rules
- Lazy loading via `rules.md` index
- Agent loads rules on demand based on trigger matching

## Graduation (Beads → Rules)

During `/retro`, if a knowledge point repeats 3+ times, propose graduating it to an official Rule.

## Related

- [/para Workflow](./para.md) — Master workspace controller
- [/para-workflow](./para-workflow.md) — Workflow management (sister workflow)
- [Workflow Documentation](../workflows.md) — Workflow catalog

---

_Added in v1.5.0_
