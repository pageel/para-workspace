---
description: Backup workflows, rules, and important config files
source: catalog
---

# /backup [target]

> **Workspace Version:** 1.4.6

Create a date-stamped snapshot of important workspace files into `.para/backups/`.

## Usage

```
/backup all                 # Backup system config + workspace sessions + all projects
/backup workflows           # Only backup workflows
/backup rules               # Only backup rules
/backup metadata            # Only backup .para-workspace.yml + workspace sessions
/backup project <name>      # Backup one project (excludes repo/)
/backup project-all         # Backup all projects (excludes repo/)
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

// turbo

Backup workspace-level sessions and state from `Areas/Workspace/`:

```bash
BACKUP_DIR=".para/backups/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR/workspace"
for item in Areas/Workspace/SESSION_LOG.md Areas/Workspace/SYNC.md Areas/Workspace/COMMANDS.md; do
  [ -f "$item" ] && cp "$item" "$BACKUP_DIR/workspace/"
done
for dir in Areas/Workspace/sessions Areas/Workspace/audits; do
  [ -d "$dir" ] && cp -r "$dir" "$BACKUP_DIR/workspace/"
done
WS_FILES=$(find "$BACKUP_DIR/workspace" -type f 2>/dev/null | wc -l)
echo "✅ Workspace sessions: $WS_FILES files backed up"
```

#### Target: `project <name>`

Backup user data of a single project. **Excludes `repo/`** — repos can be re-cloned from GitHub.

// turbo

```bash
PROJECT_NAME="<name>"
BACKUP_DIR=".para/backups/$(date +%Y-%m-%d)"
PROJECT_SRC="Projects/$PROJECT_NAME"
PROJECT_DEST="$BACKUP_DIR/projects/$PROJECT_NAME"

# Verify project exists
if [ ! -d "$PROJECT_SRC" ]; then
  echo "❌ Error: Project '$PROJECT_NAME' not found at $PROJECT_SRC"
  exit 1
fi

mkdir -p "$PROJECT_DEST"

# Copy project.md
[ -f "$PROJECT_SRC/project.md" ] && cp "$PROJECT_SRC/project.md" "$PROJECT_DEST/"

# Copy user data directories (exclude repo/)
for dir in sessions artifacts docs .agent; do
  if [ -d "$PROJECT_SRC/$dir" ]; then
    cp -r "$PROJECT_SRC/$dir" "$PROJECT_DEST/"
  fi
done

# Count files backed up
FILE_COUNT=$(find "$PROJECT_DEST" -type f 2>/dev/null | wc -l)
echo "✅ Project '$PROJECT_NAME': $FILE_COUNT files backed up (repo/ excluded)"
```

#### Target: `project-all` or `all`

Backup user data for **all** projects. Excludes `repo/` from each.

// turbo

```bash
BACKUP_DIR=".para/backups/$(date +%Y-%m-%d)"
TOTAL_FILES=0
PROJECT_COUNT=0

for project_dir in Projects/*/; do
  if [ -d "$project_dir" ]; then
    PROJECT_NAME="$(basename "$project_dir")"
    PROJECT_DEST="$BACKUP_DIR/projects/$PROJECT_NAME"
    mkdir -p "$PROJECT_DEST"

    # Copy project.md
    [ -f "$project_dir/project.md" ] && cp "$project_dir/project.md" "$PROJECT_DEST/"

    # Copy user data directories (exclude repo/)
    for dir in sessions artifacts docs .agent; do
      if [ -d "$project_dir/$dir" ]; then
        cp -r "$project_dir/$dir" "$PROJECT_DEST/"
      fi
    done

    FILE_COUNT=$(find "$PROJECT_DEST" -type f 2>/dev/null | wc -l)
    TOTAL_FILES=$((TOTAL_FILES + FILE_COUNT))
    PROJECT_COUNT=$((PROJECT_COUNT + 1))
  fi
done

echo "✅ Projects: $PROJECT_COUNT projects backed up ($TOTAL_FILES total files, repo/ excluded)"
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
🗂️ Workspace: N session files (SESSION_LOG, SYNC, audits)
📦 Projects: N projects (M files) — repo/ excluded

💡 To restore, copy files from backup to original location:
   cp .para/backups/YYYY-MM-DD/workflows/* .agent/workflows/
   cp -r .para/backups/YYYY-MM-DD/projects/<name>/* Projects/<name>/
```

> **Note:** Repos are NOT backed up — use `git clone` to restore source code.

## Restore

When restoring from a backup:

```bash
# Restore all workflows
cp .para/backups/YYYY-MM-DD/workflows/* .agent/workflows/

# Restore a single file
cp .para/backups/YYYY-MM-DD/workflows/backlog.md .agent/workflows/backlog.md

# Restore metadata
cp .para/backups/YYYY-MM-DD/.para-workspace.yml ./.para-workspace.yml

# Restore a project's user data
cp -r .para/backups/YYYY-MM-DD/projects/<name>/* Projects/<name>/

# Restore project repo (from GitHub)
cd Projects/<name> && git clone <repo-url> repo
```

## What Gets Backed Up?

### Workspace-level

| Component                        | Included? | Reason                   |
| :------------------------------- | :-------- | :----------------------- |
| `.para-workspace.yml`            | ✅ Yes    | Core workspace config    |
| `Areas/Workspace/SESSION_LOG.md` | ✅ Yes    | Global session history   |
| `Areas/Workspace/SYNC.md`        | ✅ Yes    | Cross-project sync queue |
| `Areas/Workspace/sessions/`      | ✅ Yes    | Workspace session files  |
| `Areas/Workspace/audits/`        | ✅ Yes    | Audit reports            |
| `.agent/workflows/`              | ✅ Yes    | Customized workflows     |
| `.agent/rules/`                  | ✅ Yes    | Customized rules         |

### Per Project

| Component    | Included? | Reason                                            |
| :----------- | :-------- | :------------------------------------------------ |
| `sessions/`  | ✅ Yes    | Session logs — unique, irreplaceable              |
| `artifacts/` | ✅ Yes    | Plans, backlogs, walkthroughs — user work product |
| `docs/`      | ✅ Yes    | Internal documentation — unique analysis          |
| `project.md` | ✅ Yes    | Project contract — YAML config + goals            |
| `.agent/`    | ✅ Yes    | Project-specific rules and overrides              |
| `repo/`      | ❌ No     | Source code — recoverable via `git clone`         |

## Related

- `/install` — Install workflow from catalog (alternative to restore)
- `/merge` — Merge new workflow with customized version
- `/para` — Master workspace controller
