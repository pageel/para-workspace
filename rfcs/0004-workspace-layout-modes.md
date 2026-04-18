# RFC-0004: Workspace Layout Modes

- Feature Name: workspace-layout-modes
- Start Date: 2026-04-18
- Status: Proposed
- Target Release: v2.0.0
- Owners: @cpd87 (primary)
- Affected:
  - kernel/invariants.md
  - kernel/heuristics.md
  - kernel/schema/workspace.schema.json
  - cli/lib/fs.sh
  - cli/commands/init.sh
  - cli/commands/status.sh
  - cli/commands/scaffold.sh
  - cli/commands/archive.sh
  - cli/commands/migrate.sh
  - cli/commands/install.sh
  - cli/commands/verify.sh
  - cli/commands/review.sh
  - cli/commands/plan.sh
  - templates/profiles/dev/preset.yaml
  - templates/profiles/general/preset.yaml
  - docs/rules/para-discipline.md
  - docs/reference/cli.md
  - tests/cli/test-init.sh
- Related:
  - Kernel Invariants: I1 (PARA Directory Structure)
  - Kernel Heuristics: H1 (Naming Conventions)

## Summary

Introduce an optional `layout` field in `.para-workspace.yml` that controls the
naming convention used for the four top-level PARA directories. Three modes are
defined: `standard` (existing PascalCase, default), `numeric` (single-digit
prefix + PascalCase), and `numeric-wide` (decade-prefixed UPPERCASE). All three
modes are functionally equivalent; the layout affects only directory names, not
behaviour.

## Motivation

The existing `standard` layout (`Projects/`, `Areas/`, `Resources/`, `Archive/`)
sorts alphabetically as A, A, P, R � the inverse of the intended PARA priority
order (Projects first, Archive last). This creates constant friction in any file
browser, terminal listing, or `ls` output.

A well-established solution in the PKM community is to prefix directory names
with numbers so that the filesystem sort order matches conceptual priority. Two
variants are in common use:

- **numeric** � `1_Projects`, `2_Areas`, `3_Resources`, `4_Archive`  
  Clean, minimal, retains PascalCase identity for readability.

- **numeric-wide** � `10_PROJECTS`, `20_AREAS`, `30_RESOURCES`, `40_ARCHIVE`  
  Decade-spaced numeric prefix with UPPERCASE pillar names. Gaps between decades
  leave room for future top-level additions without renumbering.

Goals:

- Preserve correct P?A?R?A sort order in all file browsers and terminal listings
- Keep `standard` as the default � zero breaking change for existing workspaces
- Allow the layout to be declared once at `para init` and honoured by all CLI
  commands automatically
- Keep `_inbox` unchanged across all layouts (its `_` prefix already sorts it
  correctly)

Non-goals:

- Changing behaviour, file formats, task models, or agent rules
- Supporting per-project layout overrides (workspace-level setting only)
- Providing a CLI command to switch layout post-init (see Migration plan)

## Guide-level explanation

At `para init`, pass the new `--layout` flag:

```bash
# Default (unchanged)
para init --profile=dev --lang=en

# Numeric prefix
para init --profile=dev --lang=en --layout=numeric

# Numeric wide (decade-spaced UPPERCASE)
para init --profile=dev --lang=en --layout=numeric-wide
```

The chosen layout is stored in `.para-workspace.yml`:

```yaml
layout: numeric-wide
```

All subsequent CLI commands (`para scaffold`, `para status`, `para archive`,
etc.) read this value and use the correct directory names automatically. Agents
reading the workspace see the layout-aware paths in the kernel snapshot.

### Directory name mapping

| `layout` value  | Projects dir   | Areas dir   | Resources dir   | Archive dir   | Inbox   |
|:----------------|:---------------|:------------|:----------------|:--------------|:--------|
| `standard`      | `Projects`     | `Areas`     | `Resources`     | `Archive`     | `_inbox`|
| `numeric`       | `1_Projects`   | `2_Areas`   | `3_Resources`   | `4_Archive`   | `_inbox`|
| `numeric-wide`  | `10_PROJECTS`  | `20_AREAS`  | `30_RESOURCES`  | `40_ARCHIVE`  | `_inbox`|

`_inbox` is intentionally excluded from layout modes. Its underscore prefix
already guarantees it sorts before all three main-directory naming schemes, and
changing it would break existing workflows that reference it by name.

## Reference-level specification

### Definitions

- **layout mode** � the naming scheme applied to the four canonical PARA
  top-level directories in a workspace
- **canonical key** � the abstract name used internally by the CLI to refer to
  a PARA pillar: `projects`, `areas`, `resources`, `archive`
- **resolved name** � the actual filesystem directory name produced by applying
  the layout mode to a canonical key

### Repo changes (normative)

1. `kernel/invariants.md` � I1 constraint relaxed: the four canonical
   directories MUST exist but their resolved names are determined by the
   workspace `layout` setting. The mapping table above is normative.
2. `kernel/heuristics.md` � H1 naming table updated to show all three layout
   modes side by side.
3. `kernel/schema/workspace.schema.json` � add optional `layout` property with
   enum `["standard", "numeric", "numeric-wide"]`, default `"standard"`.
4. `cli/lib/fs.sh` � add `get_para_dir <key>` function that reads `layout` from
   `.para-workspace.yml` and returns the resolved directory name.
5. All path-building CLI commands � replace hardcoded `Projects`, `Areas`,
   `Resources`, `Archive` strings with `$(get_para_dir <key>)`.
6. `cli/commands/init.sh` � add `--layout=` argument; write `layout:` field to
   `.para-workspace.yml`; use `get_para_dir` for all `mkdir` calls.
7. Profile `preset.yaml` files � `creates:` entries remain as-is (they list
   sub-paths; the top-level dir name is injected at runtime by `init.sh`).
8. `tests/cli/test-init.sh` � add a second test suite that runs `para init
   --layout=numeric-wide` and verifies `10_PROJECTS/` etc. exist.
9. `docs/rules/para-discipline.md` and `docs/reference/cli.md` � updated to
   document all three layout modes.

### CLI behaviour (normative)

- `--layout` is accepted only by `para init`. Default: `standard`.
- Invalid values produce a clear error and exit 1.
- If `.para-workspace.yml` is missing or has no `layout` field, all commands
  fall back to `standard` silently.
- `para status` reports the active layout in its header output.

### Compatibility & versioning (normative)

This RFC modifies Kernel Invariant I1 (the constraint on PascalCase naming of
PARA directories), which constitutes a MAJOR kernel version bump (v1.x.x ?
v2.0.0). Existing workspaces without a `layout` field continue to work
identically � `standard` is the implicit default.

### Security / safety (normative)

No new security surface. The `layout` field is read from `.para-workspace.yml`
using the existing `grep`/`sed` pattern already used for `kernel_version`,
`profile`, and `language`.

## Rationale

**Why three modes instead of two?**  
`numeric` and `numeric-wide` serve different audiences. `numeric` retains
PascalCase folder identity and is the minimum change for sort-order correction.
`numeric-wide` uses decade spacing and UPPERCASE, leaving room between decades
for future top-level additions without renumbering, and signalling visually that
these are structural anchor folders rather than content folders.

**Why not symlinks?**  
Symlinks require elevated privileges on Windows by default and would be
invisible to agents reading the kernel, which documents `Projects/` etc. as
canonical. A layout-aware CLI is the correct abstraction.

**Why not rename H1 from "PascalCase" to something else?**  
H1 is a heuristic, not an invariant. The update adds layout-mode awareness
without removing the `standard` PascalCase row, so existing documentation
remains accurate for the default case.

## Alternatives

1. **Numeric prefix only (no numeric-wide)** � Simpler, but loses the
   recognisable Johnny.Decimal brand that many PKM users expect.
2. **Symlinks** � Rejected; Windows compatibility issues and agent confusion.
3. **User-defined names** � Too open-ended; breaks agent parsability and
   the kernel contract.
4. **Post-init migration command** � Deferred; can be added in a follow-up
   MINOR RFC once the foundation is in place.

## Drawbacks

- MAJOR version bump required (I1 change).
- Every path-building reference in the CLI must be updated � low risk (simple
  substitution) but wide surface area.
- Agents operating without the workspace layout context (e.g. loaded from a
  snapshot that predates this feature) will fall back to `standard` silently,
  which is safe.

## Implementation plan

1. Add `get_para_dir` to `cli/lib/fs.sh`
2. Update `cli/commands/init.sh` � `--layout` flag + `mkdir` calls
3. Update `cli/commands/status.sh` � all path and label references
4. Update `cli/commands/scaffold.sh` � project/area/resource targets
5. Update `cli/commands/archive.sh` � source type validation + dest path
6. Update `cli/commands/migrate.sh` � project iteration loops
7. Update `cli/commands/install.sh` � wrapper candidate paths
8. Update `cli/commands/verify.sh` and `plan.sh` and `review.sh`
9. Update `kernel/invariants.md` (I1)
10. Update `kernel/heuristics.md` (H1)
11. Update `kernel/schema/workspace.schema.json`
12. Update profile `preset.yaml` files (labels/descriptions only)
13. Update `docs/rules/para-discipline.md`
14. Update `docs/reference/cli.md`
15. Update `tests/cli/test-init.sh`
16. Bump `VERSION` to `2.0.0`

## Migration plan

Existing workspaces: no action required. `.para-workspace.yml` without a
`layout` field defaults to `standard`. `para update` will not add the field
automatically � users opt in explicitly at `para init` time or by manually
adding `layout: numeric` (or `layout: numeric-wide`) to their config.

A future `para migrate --to-layout=<mode>` command (separate RFC) will handle
renaming existing directories and updating the config atomically.

## Testing plan

- `tests/cli/test-init.sh` � extended with `--layout=numeric` and
  `--layout=numeric-wide` test suites checking correct directory names
- `tests/cli/test-init.sh` � verify `standard` (no flag) still produces
  `Projects/`, `Areas/`, etc.
- Manual smoke test: `para scaffold project my-app` in a numeric-wide
  workspace creates `10_PROJECTS/my-app/`

## Unresolved questions

- Should `para status --json` include the `layout` field? (Likely yes � deferred
  to implementation.)
- Should `para migrate --to-layout=<mode>` be included in this RFC or a follow-up?
  Currently deferred as a follow-up to keep this RFC focused.
