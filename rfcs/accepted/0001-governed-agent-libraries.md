# RFC-0001: Governed Agent Libraries (Workflows / Rules / Skills)

- Feature Name: governed-agent-libraries
- Start Date: 2026-02-24
- Status: Implemented
- Target Release: v1.4.1
- Owners: @pageel (maintainer)
- Affected: templates/, cli/, workspace runtime layout, kernel heuristics
- Related:
  - Kernel Invariants: I9 (Resources read-only), I10 (Repo ↔ Workspace separation)
  - Kernel Heuristics: H8 (Workflow kernel compatibility), H9 (NEW — catalog.yml required)

## Summary

Standardize the location, structure, metadata, syncing, and compatibility checks
for three governed libraries: 1) workflows, 2) rules, 3) skills.

This RFC defines:

- The canonical source-of-truth in the repo
- The read-only snapshot location inside a user workspace
- The runtime location used by agents
- A machine-readable catalog manifest for versioning and kernel compatibility

## Motivation

The repo already groups "Centralized Rules, Skills, Workflows" under
`templates/common/agent/` but the system lacked a consistent library contract:
metadata, compatibility gates, and drift detection.

Goals:

- Make every workspace predictable by ensuring consistent library layout
- Enable safe updates by validating kernel/library compatibility before sync
- Reduce multi-agent drift by separating read-only snapshots from runtime copies

Non-goals:

- This RFC does not define the content of individual workflows/rules/skills
- This RFC does not introduce multi-agent routing (separate RFC)

## Guide-level explanation

- Repo authors maintain libraries once, in one place, via PR review.
- Workspace users run `para init` and get a consistent runtime with pinned
  library snapshots.
- Agents load runtime workflows/rules from `.agent/`, and may reference
  read-only copies from `Resources/ai-agents/`.

## Reference-level specification

### Repo: canonical locations (normative)

```
templates/common/agent/
  workflows/
    catalog.yml
    *.md
  rules/
    catalog.yml
    *.md
  skills/
    catalog.yml
    para-kit/SKILL.md
```

### Catalog manifest format (normative)

Each library MUST include a `catalog.yml`. Required fields per item:

- `id`: stable identifier (kebab-case), unique per library
- `name`: human readable
- `version`: semver
- `kernel_min`: minimum kernel version required
- `kernel_max`: maximum supported (optional)
- `entrypoint`: relative path to the markdown file
- `description`: short string
- `tags`: list of strings (optional)

Schema: `kernel/schema/catalog.schema.json`

### Workspace: snapshot vs runtime (normative)

Read-only snapshots (enforced by tooling):

```
Resources/ai-agents/
  kernel/
  workflows/   → catalog.yml + *.md
  rules/       → catalog.yml + *.md
  skills/      → catalog.yml + para-kit/
```

Runtime (mutable, managed by CLI):

```
.agent/
  workflows/   → catalog.yml + *.md
  rules/       → catalog.yml + *.md
  skills/      → catalog.yml + para-kit/ (optional, default OFF)
```

### Sync semantics (para init / install / update) (normative)

Installer MUST:

1. Copy `templates/common/agent/workflows` → `Resources/ai-agents/workflows` + `.agent/workflows`
2. Copy `templates/common/agent/rules` → `Resources/ai-agents/rules` + `.agent/rules`
3. Copy `templates/common/agent/skills` → `Resources/ai-agents/skills` + `.agent/skills` (optional)

Compatibility gate:

- Validate each catalog item's `kernel_min/kernel_max` against workspace
  kernel version in `.para-workspace.yml`
- Fail with clear error + remediation hint if incompatible

## Rationale

Mirrors the kernel snapshot approach already used in `Resources/ai-agents/kernel/`.
Keeps governance assets centralized while preserving Repo ≠ Workspace.

## Alternatives

1. Keep workflows in repo root `workflows/` and rules/skills elsewhere
   → Rejected: increases cognitive load, complicates versioning

2. Put everything directly under `.agent/` only
   → Rejected: loses read-only reference snapshot for auditability

3. No catalogs, only file conventions
   → Rejected: prevents automated kernel_min/max compatibility gates

## Implementation plan

1. ✅ Repo: create `templates/common/agent/{workflows,rules,skills}/catalog.yml`
2. ✅ Repo: add `kernel/schema/catalog.schema.json`
3. CLI: update `install.sh` to sync rules + skills (v1.4.1)
4. CLI: add `cli/lib/validator.sh` (catalog parse + kernel compat check)
5. CLI: update `para status` to report library drift

## Migration plan

`para update` / `para install`:

- Creates `Resources/ai-agents/rules/` and `skills/` if missing
- Backfills catalogs with minimal entries
- Leaves existing `.agent/` content intact unless `--force`

## Testing plan

- `tests/kernel/test-schemas.sh` → validate catalog.schema.json
- `tests/cli/test-init.sh` → verify all 3 library dirs created
- `kernel/examples/valid/` → add workspace with all 3 catalog.yml

## Unresolved questions

- Do skills need runtime loading from `.agent/skills/` by default, or compiled
  into workflows at install time?
- Should catalogs store checksums for drift detection?
- What is the policy for workspace-local overrides (e.g., `.agent/rules.local.md`)?
