# /update Workflow

> **Version**: 1.5.0

The `/update` workflow provides **agent-guided safe updates** for the PARA Workspace. Instead of users running `./para update` directly and troubleshooting errors alone, the agent walks through pre-flight checks, a dry-run preview, and automatic error recovery.

## Commands

```
/update
```

No arguments needed — the workflow auto-detects versions and state.

## Update Flow

```
Pre-flight → Dry-run → Confirm → Live update → Verify → Report
```

### 1. Pre-flight Checks

The agent verifies 3 things before proceeding:

| Check          | What                | Failure action                          |
| -------------- | ------------------- | --------------------------------------- |
| **Network**    | Can reach GitHub?   | Suggest `./para install` (offline sync) |
| **Git status** | Dirty working tree? | Offer to stash or skip                  |
| **Version**    | Already latest?     | Inform and ask to continue              |

### 2. Dry-run Preview

Runs `./para update --dry-run` to show what will change: version bump, migration steps, files to sync. User confirms before applying.

### 3. Live Update

Executes `./para update`. If it fails, the agent diagnoses the error automatically.

### 4. Error Recovery

Built-in diagnosis for common failures:

| Error              | Root cause                  | Agent action                        |
| ------------------ | --------------------------- | ----------------------------------- |
| Network lost       | Connection dropped mid-pull | Suggest offline sync                |
| Git conflict       | Upstream diverged           | List conflicts, offer `--theirs`    |
| Permission denied  | Missing `chmod +x`          | Fix permissions                     |
| Rollback triggered | Install failed              | Confirm rollback, suggest `--force` |

After recovery, the agent retries once. If still failing, it stops and reports.

### 5. Post-update Verify

Confirms success by checking:

- `kernel_version` in `.para-workspace.yml`
- Latest entry in `.para/migrations/history.log`
- Latest entry in `.para/audit.log`

## Related

- [Workflow Documentation](../reference/workflows.md) — Workflow catalog and philosophy
- [CLI Reference](../reference/cli.md) — `para update` command details

---

_Added in v1.5.0_
