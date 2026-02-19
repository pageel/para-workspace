---
description: Categorize files from the _inbox/ directory
---

# /inbox [filename]

Automatically or manually categorize incoming files from the `_inbox/` directory into their permanent locations within the PARA structure.

## Usage

```bash
/inbox                    # Review and categorize all files in _inbox/
/inbox [filename]         # Categorize a specific file
```

---

## 🔍 Steps

### 1. Scan Inbox

//turbo

```bash
ls -la _inbox/
```

### 2. Categorization Logic

| Category               | Indicators             | Target Directory                          |
| :--------------------- | :--------------------- | :---------------------------------------- |
| **Code Templates**     | `.tsx`, `.jsx`, `.vue` | `Resources/Reference/code/components/`    |
| **Logic Snippets**     | `.ts`, `.js`, `.py`    | `Resources/Reference/code/snippets/`      |
| **Design Patterns**    | `.md` regarding design | `Resources/Reference/code/patterns/`      |
| **Integrations**       | API/Webhook code       | `Resources/Reference/code/integrations/`  |
| **Research/Tutorials** | `.md` how-to guides    | `Resources/Reference/articles/tutorials/` |
| **Project Assets**     | `[p]-logo.png`, `.csv` | `Resources/Assets/[project-name]/`        |
| **Learning**           | Notes, best practices  | `Areas/Infrastructure/learning/`          |

---

## 🛠 Action: Move File

1. **Check for duplicates**: If target file exists, append timestamp `_YYYYMMDD`.
2. **Ensure directory exists**: Run `mkdir -p "[target-dir]"`.
3. **Move and report**:
   ```bash
   mv "_inbox/[file]" "[target-dir]/"
   ```

---

## 💡 Notes

- **Large files (>10MB)**: Confirm with User before moving if storage is a concern.
- **Unidentified files**: Keep in `_inbox/` and ask for clarification.
