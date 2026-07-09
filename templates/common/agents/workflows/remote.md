---
description: Manage remote repositories (clone, sync, list)
source: user
---

# /remote [action]

> **Workspace Version:** 1.7.14

Manage Git repositories and reference resources within `Resources/references/` using a **Flexible Namespace** structure. Repos are organized by either their source origin (auto-derived from URL) or user-defined categories.

## Namespace Types

| Type               | Rule                       | Pattern                 | Example                  |
| :----------------- | :------------------------- | :---------------------- | :----------------------- |
| **Source-based**   | First segment contains `.` | `[host]/[owner]/[repo]` | `github.com/L-Tien/para` |
| **Category-based** | First segment has NO `.`   | `[category]/[name]`     | `libs/react`             |

> 🧩 **Sidecar Skill:** Full namespace conventions, URL parsing rules, and clone options are in `.agents/skills/remote/references/namespace-conventions.md`. Agent loads this at clone time.

## Usage

```bash
/remote                              # List all repos
/remote clone <url>                  # Clone (auto-detect namespace from URL)
/remote clone <url> --category libs  # Clone into user-defined category
/remote sync                         # Sync all repos
/remote sync github.com              # Sync a specific namespace
/remote link [project] [repo]        # Link a repo with a project
```

---

## Steps

### 0. Pre-flight

// turbo

Load namespace conventions from sidecar skill:

```bash
cat .agents/skills/remote/references/namespace-conventions.md 2>/dev/null || echo "⚠️ No namespace conventions found"
```

### 1. List all remotes

// turbo

```bash
echo "📦 REMOTE REPOSITORIES"
echo ""

for ns in Resources/references/*/; do
  [ -d "$ns" ] || continue
  ns_name=$(basename "$ns")
  echo "📂 $ns_name/"

  # Find all git repos under this namespace (any depth, max 3)
  find "$ns" -name ".git" -type d -maxdepth 3 2>/dev/null | while read gitdir; do
    repo_dir=$(dirname "$gitdir")
    rel_path=${repo_dir#Resources/references/$ns_name/}
    branch=$(cd "$repo_dir" && git branch --show-current 2>/dev/null || echo "?")
    echo "  └── $rel_path ($branch)"
  done

  # Check if namespace is empty
  if [ -z "$(find "$ns" -name ".git" -type d -maxdepth 3 2>/dev/null)" ]; then
    echo "  (empty)"
  fi
  echo ""
done
```

### 2. Clone a new repository

> 🧩 Agent MUST read `skills/remote/references/namespace-conventions.md` before cloning to determine namespace resolution.

#### Namespace Resolution

```
1. IF URL provided (no --category flag):
   → Parse host/owner/repo from URL
   → Target: Resources/references/[host]/[owner]/[repo]

2. IF --category [name] flag provided:
   → Target: Resources/references/[category]/[repo-name]

3. IF ambiguous:
   → Ask user: "Clone vào source namespace hay category?"
```

#### Clone from URL (source-based namespace — default)

```bash
# Parse URL components
URL="[git-url]"
# HTTPS: https://github.com/owner/repo.git
# SSH:   git@github.com:owner/repo.git
HOST=$(echo "$URL" | sed -E 's~^(https?://|git@)([^:/]+)[:/]([^/]+)/([^.]+)(\.git)?.*~\2~')
OWNER=$(echo "$URL" | sed -E 's~^(https?://|git@)([^:/]+)[:/]([^/]+)/([^.]+)(\.git)?.*~\3~')
REPO=$(echo "$URL" | sed -E 's~^(https?://|git@)([^:/]+)[:/]([^/]+)/([^.]+)(\.git)?.*~\4~')

mkdir -p "Resources/references/$HOST/$OWNER"
cd "Resources/references/$HOST/$OWNER"
git clone --depth 1 "$URL"
echo ".beads/" >> "$REPO/.git/info/exclude"
echo "✅ Cloned to Resources/references/$HOST/$OWNER/$REPO"
```

#### Clone into category (user-defined namespace)

```bash
CATEGORY="[user-chosen-name]"
REPO="[repo-name]"

mkdir -p "Resources/references/$CATEGORY"
cd "Resources/references/$CATEGORY"
git clone --depth 1 "$URL"
echo ".beads/" >> "$REPO/.git/info/exclude"
echo "✅ Cloned to Resources/references/$CATEGORY/$REPO"
```

### 2b. Update References Index

// turbo

After every clone, regenerate `Resources/references/README.md`:

```bash
INDEX="Resources/references/README.md"
TMP_DESC="Resources/references/.desc_cache.txt"

# Extract existing descriptions to preserve them
if [ -f "$INDEX" ]; then
  # Grab Path ($3) and Description ($5) from existing table
  grep "^| " "$INDEX" | grep -v "Namespace" | grep -v ":--" | awk -F'|' '{print $3 "|" $5}' > "$TMP_DESC"
else
  touch "$TMP_DESC"
fi

cat > "$INDEX" << 'HEADER'
# References Index

> Auto-updated by `/remote clone`. Manual edits allowed.

## Repositories

| Namespace | Path | Source URL | Description |
| :-- | :-- | :-- | :-- |
HEADER

find Resources/references -name ".git" -type d -maxdepth 4 2>/dev/null | sort | while read gitdir; do
  repo_dir=$(dirname "$gitdir")
  rel=${repo_dir#Resources/references/}
  ns=$(echo "$rel" | cut -d'/' -f1)
  url=$(cd "$repo_dir" && git remote get-url origin 2>/dev/null)

  # Look up existing description using the exact Path
  desc=$(grep " \`$rel\` " "$TMP_DESC" | awk -F'|' '{print $2}' | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')

  echo "| \`$ns\` | \`$rel\` | $url | $desc |" >> "$INDEX"
done

echo "" >> "$INDEX"
echo "✅ Updated $INDEX"
```

### 3. Sync repos

// turbo

```bash
echo "🔄 Syncing all remote repositories..."
echo ""

for ns in Resources/references/*/; do
  [ -d "$ns" ] || continue
  ns_name=$(basename "$ns")
  echo "📂 $ns_name/"

  find "$ns" -name ".git" -type d -maxdepth 3 2>/dev/null | while read gitdir; do
    repo_dir=$(dirname "$gitdir")
    rel_path=${repo_dir#Resources/references/}
    echo "  → $rel_path"
    (cd "$repo_dir" && git pull --rebase 2>&1 | tail -1)
  done
  echo ""
done

echo "✅ Sync complete!"
```

### 4. Link repo with project

When a repo needs to be associated with a specific project:

1. Record the link in `project.md` or `.para-workspace.yml`.
2. Agent uses this link to resolve references during `/open` and `/brainstorm`.

---

## Naming Conventions

> 🧩 Full reference: `.agents/skills/remote/references/namespace-conventions.md`

**Source-based:** URL → Path mapping is automatic. Agent derives `host/owner/repo` from clone URL.

**Category-based:** User chooses namespace name freely. No reserved names.

**Detection rule:** Namespace segment contains `.` → source-based host. No `.` → category.

## Best Practices

1. **Shallow clone for references**: Use `--depth 1` to save space (default).
2. **Full clone for data**: Use `--full` flag if you need git history.
3. **Sync frequently**: Run `/remote sync` before starting work.
4. **No commits to workspace root**: Each subfolder is an independent repo.
5. **URL → Path**: Always derive directory path from URL — never manually rename.
6. **Category freedom**: Use any category name that makes sense to you — `libs`, `tools`, `design`, `archive`, etc.

## Related

- `/config` — View workspace configuration
- `/open` — Start a working session
- `/new-project` — Initialize project (may need linked data repo)
