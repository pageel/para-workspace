---
description: Design system architecture, data models, APIs, and infra before specifying features
source: user
---

# /sysdesign [project-name] [action] [topic] [--graph]

> **Workspace Version:** 1.9.3 (Architecture-First)

Establish or update the system design for a project or subsystem. Runs before `/spec`.

## Actions

| Action | Description |
| :-- | :-- |
| `create` | Create a new system architecture design or subsystem design (default) |
| `adr` | Create an Architecture Decision Record (ADR) for a specific design choice |
| `review` | Compare the active codebase against the design to detect architecture drift |

## Options

| Option | Description |
| :-- | :-- |
| `--graph` | Run Graph Pipeline (Build → Query → Blast Radius Analysis) to anchor design in the active codebase |

---

## 📋 Action: create

### Steps

#### 0. Pre-flight
Read project contract (`project.md`), workspace rules, and load custom agent instructions.

> **Constraint:** Read `.para-workspace.yml` at the workspace root to resolve the user's preferred language.
> All output (chat response) MUST be translated to the chat language, all internal reasoning (<thought>) MUST be written in the thinking language, and all generated files in artifacts/ (plans, tasks, qa) MUST follow the artifacts language.

**Mandatory Insight Query:**
Agent MUST query the workspace/project SQLite store using `insight_search` and `memory_search` tool calls to search for past architecture `lesson`, `risk`, `decision`, or `gotcha` entries matching the tech stack or topic.
If `--graph` is specified:
1. Run `/para-graph build [project-name]` to sync code graph.
2. Run `graph_impact_analysis` to identify dependencies and blast radius of the topic.

#### 1. Surface Design Constraints
Agent MUST ask and define:
- Target deployment platform (Edge/Workers, VPS, Docker, Serverless, v.v.).
- Database/Storage engine (SQLite, PostgreSQL, MongoDB, Local Files).
- Request volume & performance targets (RPS, Latency limits).

#### 2. Select Architecture Pattern & Scaffolding
- Check `.agents/skills/sysdesign/references/architecture-patterns/` for matching tech stack.
- Bootstrap the design file `artifacts/sysdesigns/sysdesign-[topic].md` using the matched architecture pattern.

#### 3. Write System Design File
Fill in the 4 core domains inside `artifacts/sysdesigns/sysdesign-[topic].md`:
1. **Infrastructure & Deployment** (Docker/Workers configs, Env vars, Secrets).
2. **API & Communication Spec** (REST/gRPC endpoints, payload schemas, error formats, pagination strategy, idempotency & retry mechanisms).
3. **Database & Storage Architecture** (Schema DDL, ERD, indexes strategy, migration strategy).
4. **Software Topology** (Folder structure, Mermaid component diagrams, sequence diagrams).

#### 4. User Review & Save Gate
Present the design to the user. **Wait for explicit approval (A) before saving.**
Save path: `Projects/[project-name]/artifacts/sysdesigns/sysdesign-[topic].md`.
Once approved, suggest running `/spec` next to specify features within this architecture boundary.
