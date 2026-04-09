# /inbox Workflow

> **Version**: 1.5.0

Categorize files from `_inbox/` into their permanent PARA locations with smart project context awareness.

## Commands

```
/inbox                    # Review and categorize all files
/inbox [filename]         # Categorize a specific file
```

## Categorization Flow

```
Scan inbox → Classify → Project context check → Move → Report
```

### 1. Scan Inbox

Lists files in `_inbox/` for processing.

### 2. Categorization Logic

| Category | Indicators | Target |
| :-- | :-- | :-- |
| Code Templates | `.tsx`, `.jsx`, `.vue` | `Resources/references/code/components/` |
| Logic Snippets | `.ts`, `.js`, `.py` | `Resources/references/code/snippets/` |
| Design Patterns | `.md` design docs | `Resources/references/code/patterns/` |
| Integrations | API/Webhook code | `Resources/references/code/integrations/` |
| Research | `.md` tutorials | `Resources/references/articles/tutorials/` |
| Project Assets | `[p]-logo.png`, `.csv` | `Projects/[name]/artifacts/assets/` |
| Learning | Notes, best practices | `Areas/Learning/` |

### 2.5. Project Context Check

Before moving files to project directories, reads the project's existing structure first. Does NOT create new directories without confirmation.

### 3. Move File

Checks for duplicates, creates directories if needed, moves and reports.

## Related

- [Workflow /learn](./learn.md)
- [Workflow /para](./para.md)

---

_Updated in v1.5.0_
