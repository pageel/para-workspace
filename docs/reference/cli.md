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

## Tool & MCP Management

### `install-tool`

Install a PARA tool plugin from the registry or local DEV path. Will prompt to install bundled AI intelligence (workflows, rules, skills) and configure IDE MCP settings if applicable.

```bash
para install-tool <name> [--version=X.Y.Z] [--local=PATH] [--latest] [--update] [--agents] [--sync] [--no-agents] [--no-mcp]
```

| Flag | Description |
| -- | -- |
| `--version` | Specific version to install |
| `--local` | Path to local tool source directory for DEV mode |
| `--latest` | Install the latest version from the registry |
| `--update` | Upgrade an existing tool |
| `--agents` | Install bundled AI agent templates (enabled by default) |
| `--sync` | Sync AI intelligence templates. Supports **Local Sync** (directly copies templates from `Projects/<tool>/` development directory bypassing network) and **Index Auto-Sync** (registers rules/skills in `.agents/rules.md` and `.agents/skills.md` catalog tables automatically) |
| `--no-agents` | Skip installing AI agent templates |
| `--no-mcp` | Do not configure the MCP server for the IDE |

### `remove-tool`

Remove an installed tool and clean up its wrapper script. Will prompt to remove associated AI intelligence and IDE MCP config.

```bash
para remove-tool <name> [--force]
```

### `list-tools`

List installed tools with their versions, wrapper paths, and target paths.

```bash
para list-tools [--json]
```

### `mcp-setup`

Configure MCP server for an IDE based on the `mcp:` block in `tool.manifest.yml`. Supports auto-detection of IDEs (Antigravity, Claude, Cursor) and atomic JSON merging.

```bash
para mcp-setup <name> [--ide=<ide>] [--print-only]
```

### `mcp-list`

List tools capable of acting as an MCP server.

```bash
para mcp-list [--json]
```

### `mcp-remove`

Remove an MCP server from an IDE config.

```bash
para mcp-remove <name> [--ide=<ide>]
```

## Contract

All commands follow these rules:

| Property | Requirement |
| -- | -- |
| **Exit codes** | 0 = success, non-zero = failure |
| **Output** | Human-readable default; `--json` for agent |
| **Idempotent** | Safe to run multiple times |
| **Scriptable** | Works in automation without manual input |
