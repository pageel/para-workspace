# Session Plan Template

> **Naming:** `v[ver/1.x.x]-[YYYY-MM-DD]-session-[topic].md` (e.g., `v1.x.x-2026-05-23-session-refactor-auth.md`)
> **Lifecycle:** Created Active → completed phases synced to done.md → archived to `plans/done/`.
> **Role:** Light-weight DSP (Dynamic Session Plan) for fast coding (vibecode) with auto-commits and micro-workflows.

````markdown
# Session Plan: [Topic]

> **Created:** YYYY-MM-DD
> **Status:** 🔨 Active
> **Topic Slug:** [topic-slug]

<!-- ⚠️ STATUS GATE: Session Plans are created directly with Status: 🔨 Active.
     Lifecycle: 🔨 Active → ✅ Done.
     Transition from Active → Done requires completed phases synced to done.md + explicit user approval. -->

---

## ⚡ Session Goals

[1-2 sentences describing the core objective of this coding session]

## 📋 Dynamic Milestone Queue

| Phase | Milestone / Goal | Activated Workflows | Commit SHA | Status |
|:---|:---|:---|:---|:---|
| Phase 1 | [Goal name] | `[--graph, --tdd, ...]` | [SHA] | 🔨 Active |
| Phase 2 | [Goal name] | `[--qa, ...]` | — | ⏳ Pending |

---

## 🏁 Milestone Details

### Phase 1: [Milestone Name] ⚙️ `Difficulty: [🟢 Low | 🟡 Medium | 🔴 High]`

> **Activated Workflows:** `[--graph, --brainstorm, --tdd, --qa, --docs]`

#### 🗺️ Blast Radius & Context Lock
- **Target Files:**
  - `path/to/file1`
  - `path/to/file2`
- **Blast Radius (Upstream/Downstream):** [List of affected nodes from Graph analysis, if --graph active]

#### ⚗️ Brainstorm Log (if --brainstorm active)
- **Question:** [Quick discussion topic/question]
- **Decision:** [Final decision reached]

#### 📝 Implementation Steps
1.1 🤖 **Step 1:** [Detail...]
1.2 🤖 **Step 2:** [Detail...]

#### 📋 Task Checklist
- [ ] 1.1 🤖 [Task description]
- [ ] 1.2 🤖 [Task description]
- [ ] 1.N-1 🤖 **Pre-commit Gate:** Run tests & lints (`npm test`, `npm run lint`).
- [ ] 1.N 👤 **Git Checkpoint:** Commit changes with message `session([topic]): [milestone goal]`.
- [ ] ⛔ CHECKPOINT: Agent verification pass -> Present diff & tests to User -> User confirms -> Write commit SHA & mark Phase Done.

---

## ⏳ Pending Queue

> Add new milestones/tasks discovered during the session here. They will be promoted to active phases sequentially.

- **Phase N+1: [Milestone Name]**
  - **Activated Workflows:** `[options]`
  - **Goal:** [Brief description]
  - **Tasks:**
    - [ ] [Task detail]

---

## 🏁 Completion & Teardown

- [ ] All completed phases synced to `artifacts/tasks/done.md` (with `#session` tag and recorded SHAs).
- [ ] Codebase graph updated and enriched (`/para-graph build` & `graph_enrich` if --graph active).
- [ ] DSP file moved to `artifacts/plans/done/` directory.
- [ ] ⛔ CHECKPOINT: Present completed session summary -> User approves -> Transition Status to ✅ Done and clear `active_plan` in `project.md`.
````
