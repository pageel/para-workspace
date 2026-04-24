# PARA Tool Registry

> Central registry of official tool plugins for PARA Workspace.

## Overview

This directory contains the governance artifacts for PARA's Dynamic Tool System:

| File | Purpose |
|:--|:--|
| `tools.yml` | Registry of approved tools — name, repo, runtime, version |
| `tool.schema.json` | JSON Schema for validating `tool.manifest.yml` files |
| `README.md` | This file — contributor guide |

## Adding a New Tool

### Prerequisites

1. The tool must be hosted as a public GitHub repository.
2. The tool must include a `tool.manifest.yml` at the root of its distribution tarball.
3. The manifest must conform to `tool.schema.json`.

### Steps

1. **Create a `tool.manifest.yml`** in your tool's repo root:
   ```yaml
   name: para-example
   version: "1.0.0"
   runtime: node          # node | python | binary
   min_runtime_version: "18.0.0"
   entry: dist/cli.js     # Entry point relative to tarball root
   description: "Short description of what this tool does"
   repo: "https://github.com/owner/para-example"
   ```

2. **Package a tarball** containing your tool + manifest:
   ```bash
   tar -czf para-example-v1.0.0.tar.gz dist/ node_modules/ package.json tool.manifest.yml
   ```

3. **Create a GitHub Release** and attach the tarball.

4. **Submit a PR** to this repo adding an entry to `tools.yml`:
   ```yaml
   example:
     name: para-example
     repo: pageel/para-example
     runtime: node
     min_runtime_version: "18.0.0"
     entry: dist/cli.js
     latest: "1.0.0"
     tarball_pattern: "https://github.com/pageel/para-example/releases/download/v{{VERSION}}/para-example-v{{VERSION}}.tar.gz"
     description: "Short description"
   ```

## Naming Convention

- **Registry key:** Short name without `para-` prefix (e.g., `graph`, `audit`)
- **Full name:** `para-<short-name>` (e.g., `para-graph`)
- **Wrapper script:** `cli/commands/<short-name>.sh` (auto-generated)
- **Install path:** `.para/tools/<short-name>/`

## Validation

Run the test suite to validate registry entries:
```bash
./para test
```

## Related

- [Dynamic Tool System Spec](../../docs/architecture/dynamic-tool-system.md)
- [Kernel Schema](../kernel/schema/)
