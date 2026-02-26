# Workflow Documentation

## Philosophy

Workflows are the **UI layer** for AI agents. They define processes that agents follow, but they **contain no state** themselves.

## Workflow Locations

| Location                                   | Purpose                          |
| ------------------------------------------ | -------------------------------- |
| `repo/workflows/`                          | Reference — canonical source     |
| `workspace/Resources/ai-agents/workflows/` | Snapshot — versioned copy        |
| `workspace/.agent/workflows/`              | Active — currently used by agent |

## Standard Workflows

| Workflow   | Type     | Description                                                       |
| ---------- | -------- | ----------------------------------------------------------------- |
| `/para`    | Core     | Master workflow — orchestrate work                                |
| `/open`    | Session  | Start session, load context                                       |
| `/end`     | Session  | Close session, save logs                                          |
| `/plan`    | Planning | Create implementation plans — see [Planning Guide](./planning.md) |
| `/backlog` | Planning | Manage product backlog — see [Planning Guide](./planning.md)      |
| `/push`    | Dev      | Commit & push code                                                |
| `/verify`  | QA       | Check task completion                                             |
| `/retro`   | Review   | Retrospective before archive                                      |
| `/release` | Release  | Pre-release quality gate                                          |
| `/install` | Admin    | Install workflow/rule                                             |
| `/merge`   | Admin    | Merge conflicting workflows                                       |

## Kernel Compatibility

Each workflow should declare compatibility with kernel versions:

```yaml
kernel_compat: ">=1.0.0 <2.0.0"
```

This prevents breaking when the kernel changes (e.g., renamed files, changed schemas).

## Creating New Workflows

1. Create a `.md` file in `workflows/`
2. Add YAML frontmatter with `description` and `kernel_compat`
3. Write clear step-by-step instructions
4. Submit PR with kernel compatibility noted

## Language Compliance (I11)

> Added in v1.4.1 — See `kernel/invariants.md` → I11

All workflows MUST respect the user's language preference configured in `.para-workspace.yml`:

```yaml
# .para-workspace.yml
preferences:
  language: vi # vi | en
```

**Rules:**

- Agent reads `preferences.language` at the start of every workflow execution
- All output (reports, session logs, summaries) MUST be in the configured language
- Default: `en` (English) if not configured
- This is a **kernel invariant** — violations are non-compliant

**Status:** 🧪 Testing (2026-02-25) — Monitoring across sessions to confirm agent compliance.
