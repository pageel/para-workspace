# Workspace Structure and Configuration Overview

> **Workspace Version:** 1.9.0 (Kernel version)
> **Last Updated:** 2026-06-03

This document provides a comprehensive map of the directory structure and organization of the PARA Workspace for system development and administration.

---

## 🛠️ 1. Master Configuration (.para-workspace.yml)

The core configuration of the workspace is declared in `.para-workspace.yml` at the root:
- **Kernel Version:** `1.9.0`
- **Profile:** `dev`
- **Chat & Documentation Language:** English (`en`)
- **Node.js Path:** `<user-node-bin-path>`
- **Date Format:** `DD-MM-YYYY`
- **Update Source Repo:** branch `main` of `https://github.com/pageel/para-workspace`

---

## 📂 2. Workspace Directory Map

The workspace adheres to the standardized PARA architecture:
```text
<workspace-root-path>/
├── .agents/               # Agent rules, workflows, and skills library
│   ├── rules/             # 15 behavioral and security rules
│   ├── workflows/         # 45 automated workflows (slash commands)
│   └── skills/            # 30 helper skills (Sidecar Skills)
├── .para/                 # System state, logs, and local knowledge store
│   ├── audit.log          # Audit logs
│   ├── backups/           # Configuration backups
│   ├── migrations/        # Workspace migration database
│   ├── tools/             # Helper tools for CLI execution
│   └── knowledge/         # Local knowledge index (index.md + reports)
├── Projects/              # Active projects with deadlines or deliverables (31 projects)
├── Areas/                 # Stable folders of ongoing responsibility (SYNC.md)
├── Resources/             # Reference materials, specs, templates
├── Archive/               # Immutable cold storage for completed/canceled items
└── _inbox/                # Inbox folder for incoming files classification
```

---

## 🚀 3. Projects Catalog

List of active projects managed under `Projects/` (examples):
1. `my-web-app` — A web application development project.
2. `marketing-campaign` — A marketing and content development project.
3. `workspace-docs` — A documentation and research hub.

---

## 📜 4. Rules Catalog (15 Rules)

Behavioral guidelines configured under `.agents/rules/`:
1. `governance.md` — Manages invariants & safety guardrails of the Kernel
2. `vcs.md` — Git safety, branching, PR, and secrets leakage prevention
3. `hybrid-3-file-integrity.md` — Hot Lane & Backlog task reconciliation rules
4. `context-rules.md` — Project context loading priorities
5. `agent-behavior.md` — Communication style, language, and context recovery rules
6. `para-discipline.md` — PARA directory classification and naming standards
7. `artifact-standard.md` — Presentation standards for plans, tasks, and walkthroughs
8. `naming.md` — Naming conventions for files, folders, and git branches
9. `versioning.md` — Semantic versioning and changelog rules
10. `exports-data.md` — Data exporting guidelines
11. `knowledge.md` — Knowledge Items (KIs) governance
12. `agent-persona.md` — Developer tone of voice and persona constraints
13. `graph-first-policy.md` — Rule to query codebase graph before editing code
14. `tool-routing.md` — Heuristics for tool selection (Native vs Bash vs MCP)
15. `formatting-tables-diagrams.md` — Visual markdown formatting guidelines

---

## ⚙️ 5. Workflows Catalog (45 Workflows)

Automated script workflows located under `.agents/workflows/`:
*   **Task/Backlog Management:** `backlog.md`, `open.md`, `end.md`, `verify.md`, `vibecode.md`
*   **Workspace Management:** `para.md`, `para-audit.md`, `para-graph.md`, `para-rule.md`, `para-skill.md`, `para-workflow.md`, `para-config.md`, `install.md`, `update.md`, `merge.md`, `backup.md`
*   **Project Development:** `new-project.md`, `plan.md`, `spec.md`, `test-plan.md`, `staging.md`, `push.md`, `release.md`, `remote.md`, `qa.md`
*   **Research & Documentation:** `docs.md`, `write.md`, `research.md`, `learn.md`, `inbox.md`, `resource.md`, `retro.md`
*   **Support & Integration:** `scan-sec.md`, `playground.md`, `logs.md`
*   **Pageel Ecosystem Specific:** `pageel-add.md`, `pageel-cms.md`, `pageel-component.md`, `pageel-migrate.md`, `pageel-theme.md`, `pageel-write.md`, `pageel-cleanup.md`, `pageel-astro-migrate-review.md`

---

## 🧠 6. Skills Catalog (30 Sidecar Skills)

Helper skills loaded on demand under `.agents/skills/`:
- `para-kit`, `formatting`, `para-skill`, `plan`, `docs`, `brainstorm`, `harness`, `spec`, `qa`, `resource`, `tdd`, `logs`, `new-project`, `html-renderer`, `scan-sec`, `open`, `sidecar-skill`, `staging`, `vibecode`, `write`, `web-perf`, `cloudflare`, `durable-objects`, `wrangler`, `workers-best-practices`, `page-map`, `para-graph`, `agents-sdk`, `remote`, `apps-install-stub`.

---

## 🔌 7. Plugins & Hooks

### Plugins
Available MCP plugins in the user's IDE environment:
1. `chrome-devtools-plugin` — UI debugging and accessibility audits
2. `firebase` — Firestore, Auth, and Hosting administration
3. `google-antigravity-sdk` — Multi-agent system orchestration
4. `modern-web-guidance-plugin` — Modern Web APIs and CSS optimization
5. `science` — Scientific database querying (ChEMBL, PubMed, etc.)

### Hooks
- **`/end` Hook**: Triggers on session close to review and suggest new/updated KIs from the session log.
- **Git Push Gate**: Prevents committing sensitive files or credentials automatically.
