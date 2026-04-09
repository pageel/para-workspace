# /backup Workflow

> **Version**: 1.5.0

Create date-stamped snapshots of workspace files into `.para/backups/`.

## Commands

```
/backup all                 # Full backup
/backup workflows           # Only workflows
/backup rules               # Only rules
/backup metadata            # Config + workspace sessions
/backup project <name>      # One project (excludes repo/)
/backup project-all         # All projects (excludes repo/)
```

## Flow

```
Create snapshot dir → Copy by target → Cleanup old → Report
```

## Backup Coverage

### Workspace

| Component | Included | Reason |
| :-- | :-- | :-- |
| `.para-workspace.yml` | ✅ | Core config |
| `Areas/Workspace/` | ✅ | Sessions, SYNC, audits |
| `.agents/workflows/` | ✅ | Customized workflows |
| `.agents/rules/` | ✅ | Customized rules |

### Per Project

| Component | Included | Reason |
| :-- | :-- | :-- |
| `sessions/` | ✅ | Irreplaceable session logs |
| `artifacts/` | ✅ | Plans, backlogs |
| `docs/` | ✅ | Internal documentation |
| `project.md` | ✅ | Project contract |
| `repo/` | ❌ | Recoverable via `git clone` |

Automatically keeps **5 most recent** snapshots.

## Related

- [Workflow /install](./install.md)
- [Workflow /para](./para.md)

---

_Updated in v1.5.0_
