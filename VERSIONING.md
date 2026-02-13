# Versioning Policy

PARA Workspace uses **Semantic Versioning** with two independent tracks.

## Version Tracks

| Track                 | Example | Managed By          | Stored In                                        |
| --------------------- | ------- | ------------------- | ------------------------------------------------ |
| **Kernel Version**    | `1.4.0` | Repo `CHANGELOG.md` | Repo `VERSION` + workspace `.para-workspace.yml` |
| **Workspace Version** | `1.0.0` | Each workspace      | Workspace `.para-workspace.yml`                  |

## Kernel Versioning Rules

| Change                    | Bump      | Example                                  |
| ------------------------- | --------- | ---------------------------------------- |
| Invariant change          | **MAJOR** | Rename canonical files, remove PARA dirs |
| New heuristic/convention  | **MINOR** | Add naming rule, new workflow            |
| Bug fix, docs improvement | **PATCH** | Fix schema typo, update README           |
| New profile               | **MINOR** | Add `data-scientist` profile             |
| New workflow              | **MINOR** | Add `/deploy` workflow                   |

## Compatibility Matrix

| Kernel Version | Compatible Workflows | Compatible CLI |
| -------------- | -------------------- | -------------- |
| 1.4.x          | >=1.4.0              | >=1.4.0        |
| 1.3.x          | >=1.3.0 <1.4.0       | >=1.3.0        |

## Workspace Versioning

Each workspace maintains its own version independently:

- Starts at `1.0.0` when created by `para init`
- Increments based on the workspace owner's discretion
- Not coupled to kernel version (but kernel_version is tracked)
