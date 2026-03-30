# Update Mechanism

> **Version**: 1.6.5 | **Last reviewed**: 2026-03-30

How `para update` works — from git pull through migration to install.

## Pipeline Overview

```
para update [--dry-run]
│
├── Phase 1: git pull origin main              ← update.sh
│     ├── Git commit hash detection (v1.6.4)
│     ├── Version direction detection (v1.6.5)
│     └── Self-restart if update.sh itself changed
│
├── Phase 2: migrate.sh --from=OLD --to=NEW    ← Only on upgrade
│     ├── Version-gated migration steps
│     └── Conditional history logging (v1.6.5)
│
└── Phase 3: install.sh                        ← ALWAYS runs
      ├── Backup .bak → .para/backups/<date>/
      ├── Recursive sync: kernel, workflows, rules, skills
      └── Atomic rollback on failure
```

## Phase 1: Git Pull (`update.sh`)

1. Read `CURRENT_VER` from `.para-workspace.yml` (workspace, not repo)
2. Capture `OLD_COMMIT` hash before pull
3. Run `git pull origin main` (skipped in `--dry-run`)
4. **Self-restart**: if `update.sh` changed → `exec bash update.sh "$@"`
5. Read `NEW_VER` from `repo/VERSION`
6. **Change detection** (v1.6.4): compare commit hashes
7. **Version direction** (v1.6.5): `semver_gte` detects upgrade vs downgrade
8. Migration runs only on **upgrade** (`CURRENT_VER < NEW_VER`)
9. Install **always** runs (idempotent)

## Phase 2: Migration (`migrate.sh`)

Runs only when upgrading. Each block is version-gated:

```bash
if ! semver_gte "$FROM_VERSION" "1.4.0"; then
  # Steps 1-6: only if FROM < 1.4.0
fi
```

| Gate | Steps | Description |
| :--- | :---- | :---------- |
| < 1.4.0 | 1-6 | Task model, kernel, catalog, metadata migration |
| < 1.4.1 | 7-10 | .para/ state, governed libraries, kernel version |
| < 1.4.6 | 11 | Smart Archive obsolete files |

**History logging** (v1.6.5): Only writes to `.para/migrations/history.log` when migration steps actually execute (`MIGRATION_RAN` flag).

## Phase 3: Install (`install.sh`)

Always runs, idempotent. 7 steps:

1. Set permissions (`chmod +x`)
2. Sync kernel snapshot → `Resources/ai-agents/kernel/`
3. Sync governed libraries (workflows, rules, skills) via `sync_library()`
4. Initialize `.para/` state
5. Validate library compatibility
6. Install root `para` wrapper

**Recursive sync** (v1.6.4): `sync_directory_recursive()` handles nested directories inside skills.

## Data Protection

### Backup .bak (install.sh)

When repo has a newer file that user customized → backup old copy before overwriting.

- **Trigger**: File exists + content differs (`cmp -s`)
- **Location**: `.para/backups/<date>/`
- **Cleanup**: `para cleanup`

### Smart Archive (migrate.sh)

When architecture no longer uses a system file → move instead of delete.

- **Trigger**: Version-gated, file exists
- **Location**: `.para/archive/<version>-orphans/`
- **Operation**: `mv` (file disappears from original location)

## Atomic Rollback

If install fails mid-operation, all changes are automatically rolled back:

```
install.sh start → rollback_init()
  → sync_file() → rollback_register() for each changed file
  → Error! → trap EXIT → rollback_execute() → restore all
```

## `--dry-run` Flag

Passes through entire pipeline:
- `update.sh`: skips git pull
- `migrate.sh`: prints "→ Would execute:" instead of running
- `install.sh`: prints "→ Would sync:" instead of copying

## .para/ Directory

```
.para/
├── audit.log                   ← All CLI action history
├── migrations/
│   └── history.log             ← Migration log (only when steps ran)
├── backups/<date>/             ← Date-stamped file backups
└── archive/<version>-orphans/  ← Smart Archive vault
```

---

_Last updated: 2026-03-30 — v1.6.5_
