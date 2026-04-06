# Architecture Overview

> **Version**: 1.7.4 | **Last reviewed**: 2026-04-03

## Three-Tier Architecture

PARA Workspace operates through three layers:

```text
┌─────────────────────────────────────────────────────────┐
│                    Workspace Root                       │
│  (.para-workspace.yml, Areas/, Projects/, Resources/)   │
└────────────────────────┬────────────────────────────────┘
              ┌──────────┴──────────┐
              │ Enforces            │ Operates
┌─────────────┴────────┐  ┌────────┴────────────┐
│       Kernel         │  │     CLI Tools       │
│ (Schemas, Policies)  │  │ (init, status, upd) │
└─────────────┬────────┘  └────────┬────────────┘
              │ Abides             │ Automates
┌─────────────┴────────────────────┴────────────┐
│               AI Agent Layer                   │
│  (Workflows, Rules, Skills, Knowledge Items)   │
└───────────────────┬────────────────────────────┘
                    │ Learns
┌───────────────────┴────────────────────────────┐
│            Knowledge System (v1.7.0+)          │
│  (KI Store, System KI Sync, platform-injected) │
└────────────────────────────────────────────────┘
```

1. **Kernel** (Immutable): Constitution — 11 Invariants, 10 Heuristics (incl. H10 Knowledge Items), JSON schemas. Changes require RFC + MAJOR version bump.
2. **CLI** (Interface): 14 bash commands for workspace operations. Pipeline: `update → migrate → install` with atomic rollback.
3. **Agent** (Execution): Rules (11), Workflows (32), Skills (2+), Knowledge Items — governed by Kernel, synced via CLI.

## Directory Structure

Core repository structure:

- `cli/` — Shell scripts: `status`, `update`, `install`, `migrate`, etc.
- `kernel/schema/` — JSON Schemas (`workspace`, `backlog`, `project`, `catalog`, `decision-plan`, `ki`) — system constitution.
- `templates/common/agents/` — Agent governance: `workflows/` (32), `rules/` (11), `skills/` (2 + catalog).
- `templates/project/agents/` — Project-level agent templates (skills, rules).
- `templates/knowledge/` — System KI templates (source of truth for `./para update` sync).
- `tests/` — Unit tests for CLI and Kernel schemas.
- `docs/` — Developer documentation (English).

## Data Flow (Update Pipeline)

When updating workspace structure or rules (`para update`):

1. **Fetch**: `git pull` latest from `para-workspace` repository.
2. **Migrate**: Version-gated migrations (if kernel version changes).
3. **Install**: Sync kernel, workflows (32), rules (11), skills (2+) via `install.sh`.
4. **KI Sync** (v1.7.1+): Dual-gate (version + hash) sync System KIs from `templates/knowledge/`.
5. **Validate**: Library catalog compatibility check.
6. **Log**: Record in `.para/audit.log`.

## Ecosystem Architecture (v1.6.0+)

Workspaces support **Ecosystem Projects** — meta-projects coordinating multiple satellite projects.

```text
┌─────────────────────────────────────────────────────────┐
│                      Projects/                          │
│                                                         │
│  ┌──────────────┐                                       │
│  │   pageel/    │ ← Ecosystem (type: ecosystem)         │
│  │  · strategy  │   No repo/, contains strategy         │
│  │  · backlog   │   and cross-project plans             │
│  │  · plans/    │                                       │
│  └──────┬───────┘                                       │
│         │ @pageel/ prefix                               │
│    ┌────┴────┬──────────┐                               │
│    ▼         ▼          ▼                               │
│  ┌─────┐  ┌─────┐  ┌─────┐                              │
│  │ cms │  │p-map│  │ mcp │  ← Satellites                │
│  └─────┘  └─────┘  └─────┘    (ecosystem: pageel)       │
│                                                         │
│  ┌──────────────┐                                       │
│  │para-workspace│ ← Standalone (type: standard)         │
│  └──────────────┘                                       │
└─────────────────────────────────────────────────────────┘
```

### Cross-Project Plan Flow

1. Ecosystem project creates shared plans in `artifacts/plans/`.
2. Satellite references via `@` prefix: `@pageel/plans/xxx.md`.
3. Workflows resolve: `@pageel/plans/xxx.md` → `Projects/pageel/artifacts/plans/xxx.md`.

## Knowledge System (v1.7.0+)

Knowledge Items allow agents to learn and accumulate knowledge across sessions:

- **KI Store** (`~/.gemini/antigravity/knowledge/`): Each KI has `metadata.json` + `artifacts/`.
- **System KIs** (`para_*` prefix): Governed by repo templates, synced via `./para update` (dual-gate: version + hash).
- **User KIs** (no `para_` prefix): User-created via `/para-knowledge`, never overwritten.
- **Platform-injected context**: Summaries auto-injected at conversation start — no file reading needed.

> Details: [knowledge-system.md](knowledge-system.md) | [ki-anatomy.md](ki-anatomy.md)

## Version Tracking

| Location                        | Tracks                     |
| :------------------------------ | :------------------------- |
| Repo `VERSION`                  | Kernel version             |
| `.para-workspace.yml`           | Kernel + workspace version |
| `Resources/ai-agents/VERSION`   | Snapshot version           |

---

_Last updated: 2026-04-03 (FEAT-61: v1.7.4)_
