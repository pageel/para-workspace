# /learn Workflow

> **Version**: 1.5.0

Capture and standardize knowledge accumulated during development into `Areas/Learning/`.

## Commands

```
/learn [topic-name]
```

## Flow

```
Identify topic → Classify → Create file → Update index → Cross-reference
```

### 1. Identify Topic

Categories: Technical (Git, DevOps), Process (Workflows, Patterns), Domain (Business logic).

### 2. Create Learning File

Creates `Areas/Learning/[topic-name].md` with structured template: Context, Solution, Key Learnings, Code Example.

### 3. Update Index

Adds link to `Areas/Learning/README.md` under the appropriate category.

### 4. Cross-Reference (Optional)

If from a project, adds reference in the project's session log.

## Integration

| Workflow      | Relationship                               |
| :------------ | :----------------------------------------- |
| `/brainstorm` | Option E exits to `/learn`                 |
| `/end`        | May trigger `/learn` for discoveries       |
| `/retro`      | Graduates beads to learnings               |
| `/inbox`      | Routes learning files to `Areas/Learning/` |

## Related

- [Workflow /brainstorm](./brainstorm.md)
- [Workflow /end](./end.md)

---

_Updated in v1.5.0_
