---
description: Backup workflows, rules, and important config files
---

# /p-backup [target]

> **Workspace Version:** 1.3.5 (PARA Architecture)

Create a date-stamped snapshot of important workspace configuration files into `Areas/Infrastructure/backup/`.

## Usage

```
/backup all           # Backup workflows + rules + metadata
/backup workflows     # Only backup workflows
/backup rules         # Only backup rules
/backup metadata      # Only backup metadata.json
```

## Steps

### 1. Create snapshot directory

// turbo

```bash
WORKSPACE_ROOT="$(pwd)"
BACKUP_DIR="$WORKSPACE_ROOT/Areas/Infrastructure/backup/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"
echo "📁 Backup dir: $BACKUP_DIR"
```

### 2. Backup by target

#### Target: `workflows` or `all`

// turbo

```bash
WORKSPACE_ROOT="$(pwd)"
BACKUP_DIR="$WORKSPACE_ROOT/Areas/Infrastructure/backup/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR/workflows"
cp -r "$WORKSPACE_ROOT/.agent/workflows/"*.md "$BACKUP_DIR/workflows/" 2>/dev/null
echo "✅ Workflows: $(ls "$BACKUP_DIR/workflows/" 2>/dev/null | wc -l) files backed up"
```

#### Target: `rules` or `all`

// turbo

```bash
WORKSPACE_ROOT="$(pwd)"
BACKUP_DIR="$WORKSPACE_ROOT/Areas/Infrastructure/backup/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR/rules"
cp -r "$WORKSPACE_ROOT/.agent/rules/"*.md "$BACKUP_DIR/rules/" 2>/dev/null
echo "✅ Rules: $(ls "$BACKUP_DIR/rules/" 2>/dev/null | wc -l) files backed up"
```

#### Target: `metadata` or `all`

// turbo

```bash
WORKSPACE_ROOT="$(pwd)"
BACKUP_DIR="$WORKSPACE_ROOT/Areas/Infrastructure/backup/$(date +%Y-%m-%d)"
cp "$WORKSPACE_ROOT/metadata.json" "$BACKUP_DIR/metadata.json" 2>/dev/null
echo "✅ metadata.json backed up"
```

### 3. Cleanup old snapshots (keep 5 most recent)

// turbo

```bash
BACKUP_ROOT="$(pwd)/Areas/Infrastructure/backup"
cd "$BACKUP_ROOT"
ls -d 20??-??-?? 2>/dev/null | sort -r | tail -n +6 | xargs rm -rf 2>/dev/null
echo "🧹 Cleanup done. Snapshots remaining: $(ls -d 20??-??-?? 2>/dev/null | wc -l)"
```

### 4. Report

```
✅ Backup complete!
📅 Snapshot: YYYY-MM-DD
📁 Location: Areas/Infrastructure/backup/YYYY-MM-DD/
📊 Workflows: N files | Rules: N files | Metadata: ✓/✗

💡 To restore, copy files from backup to original location:
   cp Areas/Infrastructure/backup/YYYY-MM-DD/workflows/* .agent/workflows/
```

## Restore

When restoring from a backup:

```bash
# Restore all workflows
cp Areas/Infrastructure/backup/YYYY-MM-DD/workflows/* .agent/workflows/

# Restore a single file
cp Areas/Infrastructure/backup/YYYY-MM-DD/workflows/backlog.md .agent/workflows/backlog.md

# Restore metadata
cp Areas/Infrastructure/backup/YYYY-MM-DD/metadata.json ./metadata.json
```

## Related

- `/install` - Install workflow from catalog (alternative to restore)
- `/merge` - Merge new workflow with customized version
