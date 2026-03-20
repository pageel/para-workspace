# RFC-0003: Meta-Project & Cross-Project Governance

- Feature Name: meta-project-governance
- Start Date: 2026-03-20
- Status: Proposed (Progressive — updated per version)
- Target Release: v1.6.0 → v2.0.0
- Owners: @pageel (maintainer)
- Affected:
  - kernel/ (schema, heuristics)
  - templates/ (workflows, project template)
  - docs/ (reference, architecture, glossary)
  - workspace runtime (project.md fields)
- Related:
  - Kernel Heuristics: H7 (Cross-Project References)
  - Prior RFCs: RFC-0001 (Governed Libraries), RFC-0002 (Hybrid 3-File)

## Summary

Introduces ecosystem meta-projects (`type: ecosystem`) to coordinate related
satellite projects, a cross-project plan reference mechanism (`@` prefix), and
a governance path from heuristics to invariants across v1.6.0 → v2.0.0.

## Motivation

PARA Workspace supports multiple projects but lacks a way to coordinate them.
When projects share plans, strategy, or dependencies (e.g., the Pageel product
ecosystem with 9 satellites), there is no standard for:

- Declaring project relationships
- Sharing plans across projects
- Skipping irrelevant operations (git for meta-projects)

Goals:

- Enable meta-projects that coordinate satellites without owning source code
- Allow satellites to reference plans from their ecosystem via `@` prefix
- Adapt workflows to detect project type and skip irrelevant steps
- Establish a governance path for promoting heuristics to invariants

Non-goals:

- This RFC does NOT define department/profile refactoring (v1.7.0)
- This RFC does NOT define trust boundaries or provenance (v1.8.0)
- This RFC does NOT introduce new CLI commands (optional enhancements only)

## Guide-level explanation

**Creating an ecosystem:**

User runs `/new-project pageel`, selects "ecosystem" type. Workspace creates
`Projects/pageel/` with `project.md` containing `type: ecosystem` and a
`satellites` list — but no `repo/` directory.

**Linking satellites:**

Each satellite project adds `ecosystem: pageel` to its `project.md`. The audit
workflow validates that ecosystems and satellites reference each other correctly.

**Cross-project plans:**

A satellite can reference a shared plan stored in its ecosystem:

```yaml
# pageel-theme-kit/project.md
active_plan: "@pageel/plans/page-map-implementation.md"
```

`/open` resolves this to `Projects/pageel/artifacts/plans/page-map-implementation.md`.

**Workflow behavior:**

- `/open` on an ecosystem project skips git, shows satellite list
- `/end` on an ecosystem project skips git-related suggestions
- `/para-audit` validates ecosystem ↔ satellite consistency

## Reference-level specification

### Definitions

- **Ecosystem project**: A meta-project (`type: ecosystem`) that coordinates
  satellites. Has no `repo/` directory. Stores strategy, cross-project plans.
- **Satellite project**: A standard project linked to an ecosystem via the
  `ecosystem` field. Can reference ecosystem plans via `@` prefix.
- **`@` prefix**: Convention `@{ecosystem}/path` that resolves to
  `Projects/{ecosystem}/artifacts/path`.

### Schema changes (normative)

New optional fields in `kernel/schema/project.schema.json`:

```jsonc
{
  "type": {
    "type": "string",
    "enum": ["standard", "ecosystem"],
    "default": "standard"
  },
  "ecosystem": {
    "type": ["string", "null"],
    "pattern": "^[a-z][a-z0-9-]*$"
  },
  "satellites": {
    "type": ["array", "null"],
    "items": { "type": "string", "pattern": "^[a-z][a-z0-9-]*$" }
  }
}
```

Updated `active_plan` description to document `@` prefix resolution.

### Heuristics changes (normative)

H7 expanded with "Ecosystem Projects (v1.6.0+)" subsection covering:
- Project types table (standard vs ecosystem)
- `@` prefix convention and resolution
- Ecosystem behavior guidelines (skip git, show satellites, validate consistency)

### Workflow changes (normative)

| Workflow        | Version | Changes                                              |
|:----------------|:--------|:-----------------------------------------------------|
| `/open`         | 1.3.0   | Ecosystem detection, @prefix resolution, skip git    |
| `/end`          | 1.4.0   | @prefix resolution, skip git suggestions             |
| `/plan`         | 1.3.0   | Cross-project plan activation prompt                 |
| `/new-project`  | 1.1.0   | Ecosystem/satellite type option                      |
| `/para-audit`   | 1.2.0   | Ecosystem consistency validation                     |

### Compatibility & versioning (normative)

- All new fields are optional with safe defaults (`type: standard`)
- Existing projects without `type`/`ecosystem`/`satellites` remain valid
- `kernel_min` for updated workflows set to `1.6.0`
- This is a MINOR version bump (backward compatible)

### Security / safety (normative)

- Ecosystem projects have no `repo/` → no git operations → no accidental commits
- `@` prefix resolution is read-only (cannot write to ecosystem from satellite)
- `/para-audit` validates bidirectional consistency (ecosystem ↔ satellite)

## Rationale

Meta-projects in `Projects/` (not `Areas/`) because they follow the project
lifecycle and benefit from existing project infrastructure (backlog, plans,
sessions). Using heuristics first allows real-world validation before promoting
to invariants at v2.0.0.

## Alternatives

1. **Areas/Product/ for coordination** → Rejected: Areas have no project
   lifecycle, no backlog, no plans infrastructure
2. **Git submodules for linking** → Rejected: too complex, not all satellites
   are in the same repo
3. **Separate ecosystem config file** → Rejected: adds another file to manage;
   project.md already tracks project metadata

## Drawbacks

- Ecosystem ↔ satellite validation adds complexity to `/para-audit`
- `@` prefix is a new convention agents must learn
- Meta-projects increase `Projects/` directory count

## Implementation plan

1. ✅ Schema: add `type`, `ecosystem`, `satellites` to `project.schema.json`
2. ✅ Heuristics: expand H7 with ecosystem conventions
3. ✅ Workflows: update 5 workflows with ecosystem support
4. ✅ Templates: update `.project.yml` template
5. ✅ Prototype: create `Projects/pageel/` ecosystem with 9 satellites
6. ✅ Docs: reference docs (EN+VI), architecture, glossary, this RFC
7. ⏳ Test: dogfood ecosystem workflows in real sessions
8. ⏳ Release: `1.6.0-beta.1` → dogfood → `1.6.0` stable

## Migration plan

- `para update` syncs new workflow versions automatically
- Existing `project.md` files remain valid (no required field changes)
- Users opt-in to ecosystem features by adding `type: ecosystem`
- No migration script needed — purely additive

## Testing plan

- ✅ Schema test vectors: `examples/projects/project-schema-vectors.md`
- ⏳ Dogfood: `/open pageel` (ecosystem), `/open pageel-page-map` (satellite)
- ⏳ Dogfood: `@pageel/` plan resolution across workflows
- ⏳ `/para-audit update` validates ecosystem consistency

## Unresolved questions

- Should `@` prefix support nested ecosystems (`@parent/@child/plans/...`)?
  **Deferred** — no use case yet.
- Should ecosystem projects have a lightweight `repo/` for shared scripts?
  **Deferred** — observe real usage first.
- When to promote H7 ecosystem heuristics to invariants?
  **Planned** — v2.0.0, criteria defined in Roadmap Coverage below.

## Roadmap coverage

| Version | Feature              | Governance Level | Status       |
|:--------|:---------------------|:-----------------|:-------------|
| v1.6.0  | Meta-Project Schema  | Heuristic (H7)   | 🔨 Building  |
| v1.6.0  | @prefix Resolution   | Heuristic (H7)   | 🔨 Building  |
| v1.7.0  | Department System    | Heuristic        | 📋 Planned   |
| v1.8.0  | Community & Trust    | Heuristic        | 📋 Planned   |
| v2.0.0  | Invariant Promotion  | Invariant        | ⏳ Future    |

## Decision log

| Date       | Decision                                     | Context       |
|:-----------|:---------------------------------------------|:--------------|
| 2026-03-19 | Meta-Project in Projects/ (not Areas/)        | Brainstorm v7 |
| 2026-03-19 | Department All-in-one (not per-area)          | Brainstorm v7 |
| 2026-03-20 | Heuristics-first, invariants at v2.0.0        | v7.1 fix      |
| 2026-03-20 | Beta release strategy (1.6.0-beta → stable)  | Plan review    |
| 2026-03-20 | Glossary as graph-ready seed data             | Session 3.1    |
