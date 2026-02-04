---
description: Start a work session - load context and suggest next steps
---

# /open [project-name]

> **Workspace:** PARA Architecture

Start a new session with context from previous work.

## Usage

```
/open my-project
```

## Steps

### 1. Identify paths

```
Structure:
Projects/[project]/repo/      # Source code
Resources/Assets/[project]/   # Assets
Projects/[project]/docs/      # Documentation
Projects/[project]/sessions/  # Session logs
```

### 2. Read master index

// turbo

```bash
# UPDATE_PATH: Set this to your absolute workspace path
WORKSPACE_ROOT="."
cat $WORKSPACE_ROOT/Areas/sessions/SESSION_LOG.md 2>/dev/null || echo "No session log found"
```

### 3. Find latest session

// turbo

```bash
WORKSPACE_ROOT="."
ls -t $WORKSPACE_ROOT/Projects/[project-name]/sessions/*.md 2>/dev/null | head -3
```

### 4. Read latest session

// turbo

```bash
WORKSPACE_ROOT="."
# Read the first file found in step 3
LATEST=$(ls -t $WORKSPACE_ROOT/Projects/[project-name]/sessions/*.md 2>/dev/null | head -1)
if [ -f "$LATEST" ]; then
  cat "$LATEST"
else
  echo "No previous session found."
fi
```

### 5. Read Backlog

// turbo

```bash
WORKSPACE_ROOT="."
cat $WORKSPACE_ROOT/Projects/[project-name]/sessions/BACKLOG.md 2>/dev/null | head -30
```

### 6. Check Git Status

// turbo

```bash
WORKSPACE_ROOT="."
# Get path from metadata.json (requires jq)
PROJECT_PATH=$(jq -r ".products[\"[project-name]\"].path" $WORKSPACE_ROOT/metadata.json)

if [ "$PROJECT_PATH" != "null" ]; then
  cd $WORKSPACE_ROOT/$PROJECT_PATH && git status
else
  echo "Project path not found in metadata.json"
fi
```

### 7. Display Report

```
🚀 Start: [Project Name] | 📅 [YYYY-MM-DD]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PREVIOUS SESSION: [Date]
✅ Completed:
- [Items]
⏳ Pending:
- [ ] [Items]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❓ What would you like to do?
```
