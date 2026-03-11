# /install Workflow

> **Version**: 1.5.0

The `/install` workflow installs or updates components from the governed PARA Catalog into the workspace. It handles conflicts intelligently with interactive resolution.

## Commands

```
/install work kickoff   # Install 'kickoff' workflow
/install rule branding  # Install 'branding' rule
```

## Install Flow

```
Resolve source & destination → Check conflict → Resolve → Execute
```

### 1. Resolve Source & Destination

| Type     | Source (Catalog)                             | Destination                  |
| :------- | :------------------------------------------- | :--------------------------- |
| Workflow | `templates/common/agent/workflows/[name].md` | `.agent/workflows/[name].md` |
| Rule     | `templates/common/agent/rules/[name].md`     | `.agent/rules/[name].md`     |

### 2. Check Conflict

- File does NOT exist → Install immediately.
- File EXISTS → Compare content. If identical: "Already up to date." If different: trigger resolution.

### 3. Conflict Resolution (Interactive)

| Option          | Description                                        |
| :-------------- | :------------------------------------------------- |
| **[O]verwrite** | Replace local with catalog version                 |
| **[M]erge**     | Intelligently combine both (delegates to `/merge`) |
| **[R]ename**    | Install as `[name]-catalog.md`                     |
| **[C]ancel**    | Do nothing                                         |

## Related

- [/merge Workflow](./merge.md) — Semantic merge for conflicts
- [Workflow Documentation](../workflows.md) — Workflow catalog

---

_Added in v1.5.0_
