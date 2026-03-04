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

| Workflow         | Type     | Description                                                                    |
| ---------------- | -------- | ------------------------------------------------------------------------------ |
| `/para`          | Core     | Master workflow — orchestrate work                                             |
| `/open`          | Session  | Start session, load context                                                    |
| `/end`           | Session  | Close session, save logs                                                       |
| `/plan`          | Planning | Create implementation plans — see [Planning Guide](./planning.md)              |
| `/backlog`       | Planning | Manage product backlog — see [Planning Guide](./planning.md)                   |
| `/push`          | Dev      | Commit & push code                                                             |
| `/verify`        | QA       | Check task completion                                                          |
| `/retro`         | Review   | Retrospective before archive                                                   |
| `/release`       | Release  | Pre-release quality gate                                                       |
| `/install`       | Admin    | Install workflow/rule                                                          |
| `/merge`         | Admin    | Merge conflicting workflows                                                    |
| `/para-rule`     | Admin    | Manage, install, and standardize agent rules                                   |
| `/para-workflow` | Admin    | Manage, install, and standardize agent workflows                               |
| `/docs`          | Admin    | Generate, review, and publish technical documentation                          |
| `/para-audit`    | Audit    | Macro Assessor for tracking workspace structural drift against the Kernel Spec |

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

## Macro Assessor: `/para-audit`

> Added in v1.4.5

The `/para-audit` workflow functions as the **supreme workspace health checker**.

**Why it exists:**
Instead of agents reading the hundreds-of-lines `Kernel Specs` (like `invariants.md`) on every single `/open` or `/plan` command (which wastes thousands of tokens and causes attention decay), the PARA workspace uses a **Progressive Disclosure** model.

- Daily workflows only read the ultra-light `governance.md` runtime file.
- When an audit is needed, the user runs the `/para-audit` workflow.

**What it does:**

1. **Full Scans the Kernel:** This is the _only_ workflow permitted to read `invariants.md` in full.
2. **Detects Structural Drift:** Checks if `Projects/`, `Areas/`, `Resources/`, and `Archive/` are intact and unpolluted (no loose files at the root).
3. **Validates Project Activity:** Checks `backlog.md` of all projects to see if they are genuinely active (have "In Progress" or "ToDo" tasks) or if they have gone dormant.
4. **Verifies Libraries:** Calls the packages managers (`/para-rule list` and `/para-workflow list`) to find outdated or untracked routines.
5. **Generates Report:** Exports finding to `Areas/Workspace/audits/audit-report-YYYY-MM-DD.md` along with a remediation plan for the user.

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

## Related Guides

- [Development Workflow Guide](./development.md) — How all 4 workflow streams fit together
- [Planning Guide](./planning.md) — Plan + Backlog detailed guide
