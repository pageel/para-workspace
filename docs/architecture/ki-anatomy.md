# Knowledge Item Anatomy

> **Version**: 1.7.2 | **Last reviewed**: 2026-04-02

## Overview

A Knowledge Item (KI) is the unit of persistent cross-session memory for AI agents on the [Antigravity](https://antigravity.google/docs/knowledge) platform. Each KI is a **directory** containing metadata and artifact files, automatically injected into the agent's context at session start.

KI Store lives **outside** the workspace at `~/.gemini/antigravity/knowledge/`. The workspace **governs** KI operations (schema, rules, lifecycle) without owning the data.

## Directory Structure

```text
~/.gemini/antigravity/knowledge/          # KI Store (platform-managed)
├── knowledge.lock                        # Concurrent access protection
├── .archived/                            # Retired KIs
│
├── para_example_system_ki/               # System KI (para_* prefix)
│   ├── metadata.json                     # ① Identity + graph edges
│   ├── timestamps.json                   # ② Platform lifecycle
│   └── artifacts/                        # ③ Knowledge content
│       ├── overview.md
│       ├── governance.md
│       └── subdomain/
│           └── patterns.md
│
└── user_example_ki/                      # User KI
    ├── metadata.json
    ├── timestamps.json
    └── artifacts/
        └── decisions.md
```

## Three Core Components

### ① metadata.json — Identity & Graph Edges

Field        | Role                                    | Values
:------------|:----------------------------------------|:------
`title`      | Display name — injected as KI summary   | Descriptive string
`summary`    | Primary injected content                | ≤800 characters
`scope`      | Application scope                       | `workspace` / `project` / `ecosystem`
`domain`     | Subject area                            | `workspace` / `engineering` / `design`...
`purpose`    | Usage intent                            | `context` / `reference` / `pitfall` / `playbook`
`owner`      | Who manages this KI                     | `para` (system) / `user`
`para_version` | PARA version at creation (system only)| e.g. `"1.7.2"`
`references` | Links to files/conversations            | Array of `{type, value}`
`code_refs`  | Related repo file paths (graph seed)    | Relative paths from repo root
`concepts`   | Abstract terms (graph seed)             | Domain terminology array
`relates_to` | Links to other KIs (future graph)       | Array of KI slugs

### ② timestamps.json — Platform Lifecycle

```json
{
  "created": "2026-03-02T13:57:58+07:00",
  "modified": "2026-04-01T14:55:05+07:00",
  "accessed": "2026-04-02T08:33:50+07:00"
}
```

Managed entirely by the platform. Agents MUST NOT modify this file.

### ③ artifacts/ — Knowledge Content

Markdown files containing the actual knowledge. The platform reads these when the agent needs deeper context beyond the summary.

- Each artifact ≤200 lines (keep token cost low)
- Supports nested subdirectories
- English-first convention for cross-project portability

## Data Flow

```text
① Inject (session start)     ② Read (on demand)
Platform ──────────────────→ Agent Context
         title + summary       view_file(artifact)
                                    │
③ Write (/knowledge only)    ④ Store
Agent ─────────────────────→ KI Store
      KR1 gate + KR2 confirm   ~/.gemini/.../knowledge/
```

## System vs User KIs

Aspect          | System KI (`para_*`)        | User KI
:---------------|:----------------------------|:---------------------------
Slug prefix     | `para_*` (required)         | No `para_*` (rejected)
Owner           | `"para"`                    | `"user"`
Source          | `repo/templates/knowledge/` | Agent creates from session
Update method   | CLI sync / `/knowledge system update` | `/knowledge [topic]`
Ad-hoc edits    | ❌ Not allowed              | ✅ Allowed

## Graph-Ready Fields

Three metadata fields seed the future Knowledge Graph:

- **`code_refs`** — Impact surface: agent checks before modifying listed files
- **`concepts`** — Semantic nodes: graph engine connects concept → KI → code_refs
- **`relates_to`** — KI-to-KI edges: creates clusters when >10 KIs exist

## Validation Checklist

- [ ] Slug matches `^[a-z0-9_]{3,60}$`
- [ ] System KIs: slug starts with `para_`, owner = `"para"`, has `para_version`
- [ ] User KIs: slug does NOT start with `para_`
- [ ] Summary ≤ 800 characters
- [ ] At least 1 artifact file exists
- [ ] All file references in `references` are valid paths

---

_See also: [Knowledge System Architecture](./knowledge-system.md) · [Knowledge Rule](../rules/knowledge.md) · [KI Schema](../../kernel/schema/ki.schema.json)_
