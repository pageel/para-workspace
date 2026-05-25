#!/usr/bin/env bash
# parse-args.sh — Parse arguments and gather target files for security scanning.
# Part of scan-sec sidecar skill.

ARGS="$1"

# 0) Detect git availability
IS_GIT_REPO=true
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || IS_GIT_REPO=false

# 1) Extract lang flag (default vi)
LANG="vi"
if echo "$ARGS" | grep -qE -- 'lang=en|--en|\ben\b'; then LANG="en"; fi
if echo "$ARGS" | grep -qE -- 'lang=vi|--vi'; then LANG="vi"; fi

# 1.5) Extract graph flag (default false)
USE_GRAPH=false
if echo "$ARGS" | grep -qE -- '--graph'; then USE_GRAPH=true; fi

# 2) Extract scope
SCOPE=$(echo "$ARGS" | sed -E 's/(lang=(vi|en)|--vi|--en|--graph)//g' | xargs)

# 2.5) Resolve project/resource/area parameters
TARGET_DIR=""
REPORT_TARGET_DIR="reports/security"

# Case-insensitive check for prefix
SCOPE_LOWER=$(echo "$SCOPE" | tr '[:upper:]' '[:lower:]')

if [[ "$SCOPE_LOWER" =~ ^project\ +(.*) ]]; then
  PROJ_NAME="${BASH_REMATCH[1]}"
  TARGET_DIR="Projects/${PROJ_NAME}"
  if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Project directory '$TARGET_DIR' does not exist."
    exit 1
  fi
  REPORT_TARGET_DIR="${TARGET_DIR}/artifacts/reports/security"
elif [[ "$SCOPE_LOWER" =~ ^resource\ +(.*) ]]; then
  RES_NAME="${BASH_REMATCH[1]}"
  
  # Resolve full namespace from short name or path under Resources/references/
  RESOLVED_PATH=""
  NAMESPACE=""
  
  if [ -d "Resources/references/${RES_NAME}" ]; then
    RESOLVED_PATH="Resources/references/${RES_NAME}"
    NAMESPACE="${RES_NAME}"
  else
    # Find matching directory recursively under Resources/references/
    FOUND=$(find Resources/references/ -type d -name "${RES_NAME}" -not -path '*/.*' 2>/dev/null | head -n 1)
    if [ -n "$FOUND" ]; then
      RESOLVED_PATH="$FOUND"
      NAMESPACE=$(echo "$FOUND" | sed 's|Resources/references/||')
    fi
  fi
  
  if [ -z "$RESOLVED_PATH" ]; then
    echo "Error: Resource '${RES_NAME}' not found in Resources/references/"
    exit 1
  fi
  
  TARGET_DIR="${RESOLVED_PATH}"
  # Save reports under Areas/Learning/Resources/[namespace]/reports/security
  REPORT_TARGET_DIR="Areas/Learning/Resources/${NAMESPACE}/reports/security"
elif [[ "$SCOPE_LOWER" =~ ^area\ +(.*) ]]; then
  AREA_NAME="${BASH_REMATCH[1]}"
  TARGET_DIR="Areas/${AREA_NAME}"
  if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Area directory '$TARGET_DIR' does not exist."
    exit 1
  fi
  REPORT_TARGET_DIR="${TARGET_DIR}/reports/security"
else
  # Generic path fallback: check if SCOPE itself is a directory
  if [ -n "$SCOPE" ] && [ -d "$SCOPE" ]; then
    TARGET_DIR="$SCOPE"
    
    if [[ "$TARGET_DIR" =~ ^Projects/([^/]+) ]]; then
      REPORT_TARGET_DIR="${TARGET_DIR}/artifacts/reports/security"
    elif [[ "$TARGET_DIR" =~ ^Resources/references/(.*) ]]; then
      NAMESPACE="${BASH_REMATCH[1]}"
      REPORT_TARGET_DIR="Areas/Learning/Resources/${NAMESPACE}/reports/security"
    else
      REPORT_TARGET_DIR="${TARGET_DIR}/reports/security"
    fi
  fi
fi

# 3) Gather files
NO_GIT_NOTE=""
if [ -n "$TARGET_DIR" ]; then
  # When scanning a sub-folder within a git repo, use git ls-files if available
  if [ "$IS_GIT_REPO" = true ]; then
    FILES=$(git ls-files -- "$TARGET_DIR")
  else
    FILES=$(find "$TARGET_DIR" -type f \
      -not -path '*/.git/*' \
      -not -path '*/.next/*' \
      -not -path '*/.nuxt/*' \
      -not -path '*/.venv/*' \
      -not -path '*/.idea/*' \
      -not -path '*/.vscode/*' \
      -not -path '*/node_modules/*' \
      -not -path '*/vendor/*' \
      -not -path '*/dist/*' \
      -not -path '*/build/*' \
      -not -path '*/target/*' \
      -not -path '*/__pycache/*' \
      -not -path '*/reports/*' \
      2>/dev/null | sed 's|^\./||')
  fi
else
  case "$SCOPE" in
    "staged"|"uncommitted"|"diff"|"commit within "*|"commit id "*|"pr id "*)
      if [ "$IS_GIT_REPO" = false ]; then
        echo "{msg_scope_needs_git}"
        exit 1
      fi
      case "$SCOPE" in
        "staged")             FILES=$(git diff --cached --name-only) ;;
        "uncommitted"|"diff") FILES=$(git diff --name-only HEAD); [ -z "$FILES" ] && FILES=$(git diff --cached --name-only) ;;
        "commit within "*)    DAYS=$(echo "$SCOPE" | grep -oE '[0-9]+'); FILES=$(git log --since="${DAYS} days ago" --name-only --pretty=format: | sort -u | grep -v '^$') ;;
        "commit id "*)        SHA=$(echo "$SCOPE" | sed 's/commit id //'); FILES=$(git diff-tree --no-commit-id --name-only -r "$SHA") ;;
        "pr id "*)            PR=$(echo "$SCOPE" | sed 's/pr id //'); FILES=$(gh pr diff "$PR" --name-only) ;;
      esac
      ;;
    "all"|"")
      if [ "$IS_GIT_REPO" = true ]; then
        FILES=$(git ls-files)
      else
        FILES=$(find . -type f \
          -not -path '*/.git/*' \
          -not -path '*/.next/*' \
          -not -path '*/.nuxt/*' \
          -not -path '*/.venv/*' \
          -not -path '*/.idea/*' \
          -not -path '*/.vscode/*' \
          -not -path '*/node_modules/*' \
          -not -path '*/vendor/*' \
          -not -path '*/dist/*' \
          -not -path '*/build/*' \
          -not -path '*/target/*' \
          -not -path '*/__pycache__/*' \
          -not -path '*/reports/*' \
          2>/dev/null | sed 's|^\./||')
        NO_GIT_NOTE="true"
      fi
      ;;
    *)
      echo "Unknown scope or directory: $SCOPE"
      exit 1
      ;;
  esac
fi

# 4) Strip noise (double-protect)
FILES=$(echo "$FILES" | grep -vE '(^|/)(node_modules|vendor|dist|build|\.next|\.nuxt|target|\.venv|__pycache__|\.git|reports)/' || true)

# 5) Prepare save location
TIMESTAMP=$(date +"%Y-%m-%d-%H%M%S")
REPORT_DIR="${REPORT_TARGET_DIR}"
REPORT_FILE="${REPORT_DIR}/scan-${TIMESTAMP}.md"
mkdir -p "${REPORT_DIR}"

# 6) Check .gitignore (relevant only if git repo)
# If saving reports outside the current repo (e.g. inside Areas/Learning for cloned resources), skip gitignore warning
GITIGNORE_WARNING=""
if [ "$IS_GIT_REPO" = true ]; then
  # Only check .gitignore if the report directory is inside the current git repo
  if [[ "$REPORT_DIR" != Areas/* ]]; then
    if [ -f .gitignore ]; then
      grep -qE 'reports/?' .gitignore || GITIGNORE_WARNING="missing"
    else
      GITIGNORE_WARNING="missing"
    fi
  fi
fi

# Output parameters for downstream Agent execution
echo "Scope: ${SCOPE:-all (default)}"
echo "Target Directory: ${TARGET_DIR:-root}"
echo "Report Directory: ${REPORT_DIR}"
echo "Lang: $LANG"
echo "Use Graph: $USE_GRAPH"
echo "Git repo: $IS_GIT_REPO"
echo "Files count: $(echo "$FILES" | wc -l)"
echo "Report file: $REPORT_FILE"
[ "$NO_GIT_NOTE" = "true" ] && echo "Note: non-git folder — scanning all files via find"
echo "---FILES_START---"
echo "$FILES"
echo "---FILES_END---"
