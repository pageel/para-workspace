# Versioning Policy

> PARA Workspace uses **Semantic Versioning** with two independent tracks and governed library compatibility.

## Version Tracks

| Track                 | Example | Managed By          | Stored In                                        |
| --------------------- | ------- | ------------------- | ------------------------------------------------ |
| **Kernel Version**    | `1.4.1` | Repo `CHANGELOG.md` | Repo `VERSION` + workspace `.para-workspace.yml` |
| **Workspace Version** | `1.0.0` | Each workspace      | Workspace `.para-workspace.yml`                  |

- The **Kernel Version** tracks the governance framework itself (invariants, heuristics, CLI, templates, governed libraries).
- The **Workspace Version** tracks the user's workspace instance and is fully independent.

---

## Kernel Versioning Rules

| Change Type                      | Bump      | Example                                  |
| -------------------------------- | --------- | ---------------------------------------- |
| Invariant change (I1–I10)        | **MAJOR** | Rename canonical files, remove PARA dirs |
| New heuristic/convention         | **MINOR** | Add naming rule, new governed workflow   |
| New profile                      | **MINOR** | Add `data-scientist` profile             |
| New governed workflow or rule    | **MINOR** | Add `/deploy` workflow to catalog        |
| Bug fix, docs improvement        | **PATCH** | Fix schema typo, update README           |
| Workflow content update (no new) | **PATCH** | Standardize existing workflow content    |

### Build Convention

During active development, **build suffixes** may be used for intermediate releases:

```
1.4.0-build.1, 1.4.0-build.2, ... 1.4.0-build.6
```

Build versions:

- Are informal pre-release markers, NOT part of the final SemVer.
- Are used during a development cycle before the official version is finalized.
- Once stable, the build suffix is dropped (e.g., `1.4.0-build.6` → `1.4.1`).

---

## Governed Library Versioning (H9)

Each item in a governed library (`catalog.yml`) carries its own version and kernel compatibility:

```yaml
- id: open
  version: "1.0.0" # Item version (independent of kernel)
  kernel_min: "1.4.0" # Minimum kernel version required
  kernel_max: "1.x" # Maximum kernel version supported
```

### Compatibility Rules

- The installer (`para install`, `para update`) validates `kernel_min`/`kernel_max` before syncing.
- Incompatible items are **skipped** with a warning — never force-installed.
- Item versions increment independently from the kernel version.

### Compatibility Matrix

| Kernel Version | Compatible Library Items | Compatible CLI |
| -------------- | ------------------------ | -------------- |
| 1.4.x          | `kernel_min` ≤ 1.4.x     | ≥ 1.4.0        |
| 1.3.x          | `kernel_min` ≤ 1.3.x     | ≥ 1.3.0        |

---

## Workspace Versioning

Each workspace maintains its own version independently:

- Starts at `1.0.0` when created by `para init`.
- Increments based on the workspace owner's discretion.
- Not coupled to kernel version (but `kernel_version` is tracked in `.para-workspace.yml`).
- Workspace version reflects **the user's workspace evolution**, not the framework's.

---

## Version Bump Process

### Who bumps what

| What              | Who                    | Where to update                                  |
| ----------------- | ---------------------- | ------------------------------------------------ |
| Kernel version    | Repo maintainer        | `VERSION`, `CHANGELOG.md`, `.para-workspace.yml` |
| Library item      | Repo maintainer        | `catalog.yml` (item `version` field)             |
| Workspace version | Workspace owner (user) | `.para-workspace.yml`                            |
| Project version   | Project owner (user)   | `project.md` frontmatter                         |

### Checklist for a kernel version bump

1. Update `VERSION` file in repo root.
2. Add entry in `CHANGELOG.md` (follow [Keep a Changelog](https://keepachangelog.com/) format).
3. Update `kernel_version` in `.para-workspace.yml` (after `para update`).
4. Update any version labels in workflow headers if convention changed.
5. Update version references (badges, footer) in `README.md` (and `docs/README.vi.md` if applicable).
6. Run `/release` workflow to verify quality gates.
7. Commit and push via `/push`.

---

## Related

- [Kernel Heuristic H3](./kernel/heuristics.md) — SemVer conventions and agent autonomy levels
- [Kernel Heuristic H9](./kernel/heuristics.md) — Governed library catalog requirements
- [`/release`](./) — Pre-release quality gate workflow
- [`CHANGELOG.md`](./CHANGELOG.md) — Full version history
