# CLI Documentation

## Overview

The PARA CLI (`para`) is the primary interface for managing workspace infrastructure.

## Commands

### `para init`

Create a new workspace from the repo.

```bash
para init [--profile=general] [--lang=vi] [--path=./]
```

| Flag        | Default   | Description              |
| ----------- | --------- | ------------------------ |
| `--profile` | `general` | Workspace profile preset |
| `--lang`    | `en`      | Agent response language  |
| `--path`    | `./`      | Target directory         |

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

Sync kernel and workflows from repo to workspace.

```bash
para install [--force]
```

### `para config`

Manage workspace configuration.

```bash
para config [key] [value]
para config list
```

## Contract

All commands follow these rules:

| Property       | Requirement                                |
| -------------- | ------------------------------------------ |
| **Exit codes** | 0 = success, non-zero = failure            |
| **Output**     | Human-readable default; `--json` for agent |
| **Idempotent** | Safe to run multiple times                 |
| **Scriptable** | Works in automation without manual input   |
