# CLI Documentation

## Overview

The PARA CLI (`para`) is the primary interface for managing workspace infrastructure.

## Commands

### `para init`

Create a new workspace from the repo.

```bash
para init [--profile=general] [--lang=vi] [--path=./]
```

| Flag | Default | Description |
| -- | -- | -- |
| `--profile` | `general` | Workspace profile preset |
| `--lang` | `en` | Agent response language |
| `--path` | `./` | Target directory |
| `--layout` | `standard` | Directory naming scheme: `standard` \| `numeric` \| `numeric-wide` |

**Layout modes:**

| Value | Projects dir | Areas dir | Resources dir | Archive dir |
| -- | -- | -- | -- | -- |
| `standard` | `Projects` | `Areas` | `Resources` | `Archive` |
| `numeric` | `1_Projects` | `2_Areas` | `3_Resources` | `4_Archive` |
| `numeric-wide` | `10_PROJECTS` | `20_AREAS` | `30_RESOURCES` | `40_ARCHIVE` |

`_inbox` is unaffected by layout. The chosen layout is stored in `.para-workspace.yml` and honoured by all subsequent CLI commands automatically.

### `para status`

Display workspace status.

```bash
para status [--json]
```

### `para scaffold`

Create new project, area, or resource.

```bash
para scaffold {project|area|resource} <name>
```

### `para migrate`

Migrate workspace between kernel versions.

```bash
para migrate [--from=X] [--to=Y] [--dry-run]
```

### `para archive`

Move completed items to Archive.

```bash
para archive <type>/<name>
```

### `para install`

Sync the kernel and governed libraries from the repo to `.para/` and `.agents/`.

```bash
para install [--force]
```

### `para update`

Pull the newest version of PARA Workspace from remote repository and run auto-migrate behind the scene to maintain structural sync.

```bash
para update
```

### `para config`

Manage workspace configuration.

```bash
para config [key] [value]
para config list
```

## Contract

All commands follow these rules:

| Property | Requirement |
| -- | -- |
| **Exit codes** | 0 = success, non-zero = failure |
| **Output** | Human-readable default; `--json` for agent |
| **Idempotent** | Safe to run multiple times |
| **Scriptable** | Works in automation without manual input |
