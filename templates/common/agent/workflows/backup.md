---
description: Backup workflows, rules, and important config files
source: catalog
---

# /backup [target]

> **Workspace Version:** 1.4.1 (Governed Libraries)

Create a date-stamped snapshot of important workspace configuration files into `.para/backups/`.

## Usage

```
/backup all           # Backup workflows + rules + metadata
/backup workflows     # Only backup workflows
/backup rules         # Only backup rules
/backup metadata      # Only backup .para-workspace.yml
```

## Steps

### 1. Create snapshot directory

// turbo

```bash
BACKUP_DIR=".para/backups/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"
echo "📁 Backup dir: $BACKUP_DIR"
```

### 2. Backup by target

#### Target: `workflows` or `all`

// turbo

```bash
BACKUP_DIR=".para/backups/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR/workflows"
cp .agent/workflows/*.md "$BACKUP_DIR/workflows/" 2>/dev/null
echo "✅ Workflows: $(ls "$BACKUP_DIR/workflows/" 2>/dev/null | wc -l) files backed up"
```

#### Target: `rules` or `all`

// turbo

```bash
BACKUP_DIR=".para/backups/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR/rules"
cp .agent/rules/*.md "$BACKUP_DIR/rules/" 2>/dev/null
echo "✅ Rules: $(ls "$BACKUP_DIR/rules/" 2>/dev/null | wc -l) files backed up"
```

#### Target: `metadata` or `all`

// turbo

```bash
BACKUP_DIR=".para/backups/$(date +%Y-%m-%d)"
cp .para-workspace.yml "$BACKUP_DIR/.para-workspace.yml" 2>/dev/null
echo "✅ .para-workspace.yml backed up"
```

### 3. Cleanup old snapshots (keep 5 most recent)

// turbo

```bash
BACKUP_ROOT=".para/backups"
cd "$BACKUP_ROOT"
ls -d 20??-??-?? 2>/dev/null | sort -r | tail -n +6 | xargs rm -rf 2>/dev/null
echo "🧹 Cleanup done. Snapshots remaining: $(ls -d 20??-??-?? 2>/dev/null | wc -l)"
```

### 4. Report

```
✅ Backup complete!
📅 Snapshot: YYYY-MM-DD
📁 Location: .para/backups/YYYY-MM-DD/
📊 Workflows: N files | Rules: N files | Metadata: ✓/✗

💡 To restore, copy files from backup to original location:
   cp .para/backups/YYYY-MM-DD/workflows/* .agent/workflows/
```

## Restore

When restoring from a backup:

```bash
# Restore all workflows
cp .para/backups/YYYY-MM-DD/workflows/* .agent/workflows/

# Restore a single file
cp .para/backups/YYYY-MM-DD/workflows/backlog.md .agent/workflows/backlog.md

# Restore metadata
cp .para/backups/YYYY-MM-DD/.para-workspace.yml ./.para-workspace.yml
```

## Related

- `/install` — Install workflow from catalog (alternative to restore)
- `/merge` — Merge new workflow with customized version
- `/para` — Master workspace controller
