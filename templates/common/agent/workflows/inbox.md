---
description: Categorize files from the _inbox/ directory
source: catalog
---

# /inbox [filename]

> **Workspace Version:** 1.5.0 (Governed Libraries)

Automatically or manually categorize incoming files from the `_inbox/` directory into their permanent locations within the PARA structure.

## Usage

```bash
/inbox                    # Review and categorize all files in _inbox/
/inbox [filename]         # Categorize a specific file
```

---

## Steps

### 1. Scan Inbox

// turbo

```bash
ls -la _inbox/
```

### 2. Categorization Logic

| Category               | Indicators             | Target Directory                            |
| :--------------------- | :--------------------- | :------------------------------------------ |
| **Code Templates**     | `.tsx`, `.jsx`, `.vue` | `Resources/references/code/components/`     |
| **Logic Snippets**     | `.ts`, `.js`, `.py`    | `Resources/references/code/snippets/`       |
| **Design Patterns**    | `.md` regarding design | `Resources/references/code/patterns/`       |
| **Integrations**       | API/Webhook code       | `Resources/references/code/integrations/`   |
| **Research/Tutorials** | `.md` how-to guides    | `Resources/references/articles/tutorials/`  |
| **Project Assets**     | `[p]-logo.png`, `.csv` | `Projects/[project-name]/artifacts/assets/` |
| **Learning**           | Notes, best practices  | `Areas/Learning/`                           |

### 2.5. Project Context Check (BUG-16 fix)

// turbo

> ⚠️ **Before moving files to any project**, agent MUST read the project's existing structure.

If the categorization target is a `Projects/[project-name]/` directory:

1. Read `Projects/[project-name]/docs/README.md` (if exists) to understand directory layout.
2. List `Projects/[project-name]/` top-level to see existing folder structure.
3. **Match** the file to an existing folder — do NOT create new top-level directories unless confirmed by user.
4. If the project has a specific docs index or artifacts structure, respect it.

> **Rule:** Do NOT assume directory structure. Read first, then place.

### 3. Move File

1. **Check for duplicates**: If target file exists, append timestamp `_YYYYMMDD`.
2. **Ensure directory exists**: Run `mkdir -p "[target-dir]"` (only for known paths from Step 2.5).
3. **Move and report**:
   ```bash
   mv "_inbox/[file]" "[target-dir]/"
   ```

---

## 💡 Notes

- **Large files (>10MB)**: Confirm with User before moving if storage is a concern.
- **Unidentified files**: Keep in `_inbox/` and ask for clarification.
- Files moved to `Projects/` should match an active project. If uncertain, ask the user.

## Related

- `/learn` — Capture lessons into Areas/Learning
- `/para` — Master workspace controller
- `/open` — Start session (scans inbox as awareness)
