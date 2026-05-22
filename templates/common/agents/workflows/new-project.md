---
description: Initialize a new PARA-compliant project with scaffolding
source: catalog
---

# /new-project [project-name] [--meta]

> **Workspace Version:** 1.6.0 (Ecosystem)

Initialize a new PARA project with standard scaffolding and artifacts.

| Flag | Description |
| :-- | :-- |
| `--meta` | Skip type selection, directly create ecosystem meta-project (no repo/) |

## Steps

### 1. Scaffold Project

// turbo

```bash
./para scaffold [project-name]
```

This creates the standard structure:

```
Projects/[project-name]/
├── repo/              # Source code (git init)
├── sessions/          # Session logs
├── artifacts/
│   └── tasks/
│       ├── backlog.md         # Product backlog (operational authority)
│       ├── done.md            # Completed tasks (append-only)
│       └── sprint-current.md  # Hot Lane (quick tasks)
├── docs/              # Project documentation
└── project.md         # Project contract (YAML frontmatter)
```

### 2. Define Goal

Update `Projects/[project-name]/project.md` with:

```yaml
---
goal: "[Specific, measurable project goal]"
deadline: "YYYY-MM-DD"
status: "active"
dod:
  - "[Done condition 1]"
  - "[Done condition 2]"
last_reviewed: "YYYY-MM-DD"
active_plan: ""
---
```

**Ecosystem support (v1.6.0+):**

**If `--meta` flag is provided:** Skip type selection → directly create ecosystem project.

**Otherwise:** Ask the user for project type:

```
❓ Project type?
   1. standard  — Regular project with source code (default)
   2. ecosystem — Meta-project coordinating satellite projects
   3. satellite — Standard project linked to an ecosystem
```

- **If ecosystem (or `--meta`):** Add `type: ecosystem` and `satellites: []` to frontmatter. Skip `repo/` directory creation (no source code).
- **If satellite:** Ask for ecosystem name. Add `ecosystem: [name]` to frontmatter.
- **If standard (default):** No extra fields needed.

### 3. Initialize Task Files

// turbo

**3a. Backlog** — Create `artifacts/tasks/backlog.md` with guard header:

```markdown
# Backlog — [project-name]

<!-- ⚠️ OPERATIONAL AUTHORITY — Mutations via /backlog only (C3) -->

> **Model**: Hybrid 3-File (backlog → sprint-current → done)

## 📊 Summary

| Category | Count |
| :--- | :--- |
| Active Items | 0 |

## 🚀 Features & Enhancements

_(use `/backlog add` to add items)_
```

**3b. Companion files** — Create with guard headers:

`artifacts/tasks/done.md`:

```markdown
# Done — [project-name]

<!-- ⚠️ APPEND-ONLY — /end or /backlog clean only (C2) -->

> **Project**: [project-name]
> Completed tasks grouped by plan. See plan details at `plans/done/`.

---

## Standalone Tasks

_(none yet)_
```

`artifacts/tasks/sprint-current.md`:

```markdown
# Sprint Current — [project-name]

<!-- ⚠️ HOT LANE ONLY — No backlog tasks here (C1) -->

> **Source**: backlog.md (Hybrid 3-File Model)
> **Updated**: YYYY-MM-DD

## Quick Tasks

## Notes
```

> **Rule:** Guard headers (`<!-- ⚠️ ... -->`) are required per `hybrid-3-file-integrity.md` C6.

### 4. Register in Workspace Config

// turbo

Add the project to `.para-workspace.yml` if not already registered.

### 5. Start First Session

Record the kickoff in `Projects/[project-name]/sessions/YYYY-MM-DD.md`:

```markdown
# YYYY-MM-DD | [project-name]

## Session 1: Project Kickoff

- **Goal**: [project goal]
- **Initial Backlog**: [N] items defined
- **Tech Stack**: [technologies]
- **Next Steps**: [first priority]
```

### 6. Choose Next Action

Present options and ask the user how to proceed:

```
🎉 PROJECT CREATED: [project-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Structure scaffolded
✅ project.md configured
✅ Task files initialized
✅ First session logged

💡 WHAT'S NEXT?

  A. 🧠 /brainstorm — Explore the problem space first
     → Best when: requirements are vague, multiple approaches possible

  B. 📝 /spec — Write a structured specification
     → Best when: requirements are clear but need formal boundaries

  C. 📐 /plan — Jump straight to implementation planning
     → Best when: scope is well-defined and ready to execute

  D. 📥 /backlog — Add tasks directly to backlog
     → Best when: you already have a clear task list

  E. 🔍 Just explore — Open the project later with /open
     → Best when: you want to set up and come back another day

❓ Which option? (A/B/C/D/E)
```

> 💡 **Recommendation heuristic:** If the user provided a vague or broad goal in Step 2
> (e.g., "build a SaaS app"), Agent SHOULD recommend option A (brainstorm).
> If the goal is specific and actionable (e.g., "create a CLI tool for X"),
> Agent SHOULD recommend option B (spec) or C (plan).

**Option A:** Suggest: `/brainstorm [project-name] [goal-topic]`
**Option B:** Suggest: `/spec [project-name] create`
**Option C:** Suggest: `/plan [project-name] create`
**Option D:** Suggest: `/backlog [project-name]`
**Option E:** No action. User can return later with `/open [project-name]`.

> ⚠️ **Workflow Transition Rule:** The Agent MUST cleanly close `/new-project` before
> starting the next workflow. Each downstream workflow has its own context-loading
> and pre-flight checks that MUST NOT be bypassed.

## Output Checklist

- [ ] Project folder structure created
- [ ] Registered in `.para-workspace.yml`
- [ ] Goals defined in `project.md`
- [ ] Project type set (standard/ecosystem/satellite) ← v1.6.0+
- [ ] Backlog initialized
- [ ] `done.md` created with guard header
- [ ] `sprint-current.md` created with guard header
- [ ] First session logged
- [ ] Next action suggested to user ← v1.8.10+

## Related

- `/brainstorm` — Explore ideas before planning (upstream)
- `/spec` — Write structured specification before coding (upstream)
- `/plan` — Create implementation plan for the project
- `/open` — Start session with context loading
- `/backlog` — Manage project backlog
- `/config` — Register project in workspace config
