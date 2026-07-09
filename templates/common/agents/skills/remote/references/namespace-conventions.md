# Namespace Conventions

> JIT-loaded by `/remote clone` to determine directory structure.
> **This file is user-editable** — add your own source hosts or categories.

## Two Namespace Types

### 1. Source-based (auto-derived from URL)

Agent parses the clone URL and extracts `host/owner/repo` automatically.

**Pattern:** `Resources/references/[host]/[owner]/[repo]`

**URL → Path mapping:**

```
https://github.com/facebook/react.git
  → host:  github.com
  → owner: facebook
  → repo:  react
  → path:  Resources/references/github.com/facebook/react/
```

**Supported URL formats:**

| Format | Example |
| :-- | :-- |
| HTTPS | `https://github.com/owner/repo.git` |
| SSH | `git@github.com:owner/repo.git` |
| HTTPS (no .git) | `https://github.com/owner/repo` |

**Detection rule:** If the first path segment contains a dot (`.`), treat it as a source-based namespace (hostname).

### 2. Category-based (user-defined)

User creates custom categories for non-URL-based resources or for organizing repos by purpose instead of origin.

**Pattern:** `Resources/references/[category]/[name]`

**Detection rule:** If the first path segment does NOT contain a dot, treat it as a category namespace.

> **No reserved names.** Users can create ANY category name they want.
> Examples: `data`, `libs`, `examples`, `tools`, `design`, `archive`, `snippets`, `templates`

## Namespace Resolution Logic

When Agent receives a `/remote clone` command:

```
1. IF URL provided:
   → Parse host/owner/repo from URL
   → Target: Resources/references/[host]/[owner]/[repo]

2. IF --category [name] flag provided:
   → Target: Resources/references/[category]/[repo-name]

3. IF ambiguous:
   → Ask user: "Clone vào source namespace (github.com/...) hay category?"
```

## Clone Options

| Flag | Effect | Example |
| :-- | :-- | :-- |
| (none) | Auto-derive from URL → source namespace | `/remote clone https://github.com/org/repo` |
| `--category [name]` | Override namespace to user category | `/remote clone <url> --category libs` |
| `--depth 1` | Shallow clone (default for source) | Implicit |
| `--full` | Full clone with history | For data repos needing history |

## Examples

```
# Source-based (auto from URL)
/remote clone https://github.com/L-Tien/para
→ Resources/references/github.com/L-Tien/para/

# Source-based (GitLab)
/remote clone https://gitlab.com/org/internal-tool
→ Resources/references/gitlab.com/org/internal-tool/

# Category-based (user-defined)
/remote clone https://github.com/L-Tien/data-repo --category data
→ Resources/references/data/data-repo/

# Category only (no URL, local resource)
mkdir -p Resources/references/snippets/my-utils
→ Resources/references/snippets/my-utils/
```
