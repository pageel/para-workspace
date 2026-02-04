---
description: Setup folder structure for a new project
---

# /new-project [project-name]

> **Workspace:** PARA Architecture

Automatically scaffold directories for a new project.

## Usage

```
/new-project my-app
```

## Steps

### 1. Check existence

// turbo

```bash
PROJECT_NAME="[project-name]"
# UPDATE_PATH: Set your absolute path here
BASE="."

echo "=== Checking: $PROJECT_NAME ==="
if [ -d "$BASE/Projects/$PROJECT_NAME" ]; then
  echo "⚠️ Folder already exists"
else
  echo "✅ Ready to create"
fi
```

### 2. Create scaffolding

// turbo

```bash
PROJECT_NAME="[project-name]"
BASE="."

# 1. Repo folder
mkdir -p "$BASE/Projects/$PROJECT_NAME/repo"

# 2. Sessions
mkdir -p "$BASE/Projects/$PROJECT_NAME/sessions"

# 3. Docs
mkdir -p "$BASE/Projects/$PROJECT_NAME/docs"

# 4. Assets
mkdir -p "$BASE/Resources/Assets/$PROJECT_NAME"

echo "✅ Created Project Scaffolding due to PARA standard"
```

### 3. Create Backlog

// turbo

```bash
PROJECT_NAME="[project-name]"
BASE="."
BACKLOG="$BASE/Projects/$PROJECT_NAME/sessions/BACKLOG.md"

if [ ! -f "$BACKLOG" ]; then
cat > "$BACKLOG" << 'EOF'
# Product Backlog

> 🎯 Goal: [Define Goal]

## Features
| ID | Feature | Priority | Status |
| -- | ------- | -------- | ------ |
| 1  | Initial Setup | High | Pending |

_Created: $(date)_
EOF
echo "✅ Created BACKLOG.md"
fi
```

### 4. Update Metadata (Instructions)

User should manually update `metadata.json` to include the new project:

```json
"[project-name]": {
  "name": "My Project",
  "path": "./Projects/[project-name]/repo",
  "status": "active"
}
```
