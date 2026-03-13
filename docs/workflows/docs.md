# /docs Workflow

> **Version**: 1.4.10

The `/docs` workflow creates, reviews, and publishes technical documentation for PARA projects. It follows an **internal-first** approach: always create in the project's `docs/` directory, then promote to `repo/docs/` when ready.

## Commands

```
/docs [project-name] [action]
```

| Action    | Description                                        |
| --------- | -------------------------------------------------- |
| `new`     | Analyze project and create appropriate docs        |
| `review`  | Audit existing docs for freshness and accuracy     |
| `update`  | Update specific doc to reflect current code        |
| `publish` | Promote selected docs from `docs/` to `repo/docs/` |

## Doc Locations

```
Projects/[project-name]/
├── docs/               ← DEFAULT: All docs created here (internal)
│   └── README.md         ← Doc Index (required)
│
└── repo/docs/          ← PUBLISH ONLY: Promoted from docs/
```

| Criteria     | `docs/` (default)             | `repo/docs/` (after publish) |
| ------------ | ----------------------------- | ---------------------------- |
| **Created**  | Always — `/docs new`          | Only via `/docs publish`     |
| **Audience** | Internal team, AI agent       | Developer, contributor       |
| **Git**      | ❌ Not tracked                | ✅ Tracked in repo           |
| **Language** | User's `preferences.language` | Repo's language              |

## Doc Index

Every `docs/` directory MUST have a `README.md` index — a ~10 line table listing all docs. The agent reads this single file instead of scanning the directory, saving tokens.

`/docs new` auto-creates this file if it doesn't exist.

## `/docs new` Flow

1. Read `project.md` (goal, tech stack, status)
2. Scan source code (structure, entry points)
3. Classify project type → recommend appropriate docs
4. Read Doc Index → skip docs that already exist
5. Present doc plan → wait for user confirmation
6. Create docs based on **actual code**, not assumptions
7. Create/update Doc Index (`README.md`)
8. Log in session

## `/docs publish` Flow

1. Read Doc Index to list available docs
2. User selects which docs to publish
3. Adapt for repo audience:
   - Detect repo language → translate if needed
   - Condense to 40-100 lines
   - Fix workspace-specific paths
4. Copy to `repo/docs/`
5. Log in session

## Related

- [Workflow Documentation](../reference/workflows.md) — Workflow catalog and philosophy
- [Development Guide](../guides/development.md) — Daily workflow streams

---

_Added in v1.4.10_
