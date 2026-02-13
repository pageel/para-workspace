# Migration Guide

## v1.3.x → v1.4.0

### What Changed

v1.4.0 is a **major architectural refactor** that separates the repo (governance) from the workspace (runtime).

| Aspect        | v1.3.x                           | v1.4.0                        |
| ------------- | -------------------------------- | ----------------------------- |
| Repo identity | Hybrid (template + workspace)    | Governance only               |
| Kernel        | Scattered rules                  | Dedicated `kernel/` directory |
| CLI           | `Areas/infra/cli/`               | Top-level `cli/`              |
| Workflows     | `Resources/ai-agents/workflows/` | Top-level `workflows/`        |
| Templates     | Mixed in `Resources/`            | Dedicated `templates/`        |
| Profiles      | Not supported                    | `templates/profiles/`         |

### Automated Migration

```bash
para migrate --from=1.3.6 --to=1.4.0 --dry-run  # Preview changes
para migrate --from=1.3.6 --to=1.4.0             # Apply migration
```

### Manual Migration Steps

If automated migration is not available:

1. **Backup your workspace**
2. **Create new workspace**: `para init --profile=dev --lang=vi`
3. **Move your data**:
   - Copy `Projects/` from old workspace to new
   - Copy `Areas/` content
   - Copy `Resources/` (excluding `ai-agents/` — will be regenerated)
4. **Verify**: Run `para status` to confirm everything is in place

### Breaking Changes

- `metadata.json` → replaced by `.para-workspace.yml`
- `workspace.md` → merged into `README.md`
- `Areas/infra/cli/` → moved to top-level `cli/`
- `Resources/ai-agents/workflows/` → moved to top-level `workflows/`
- `Resources/ai-agents/rules/` → extracted into `kernel/`
