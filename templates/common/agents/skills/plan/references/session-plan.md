# Session Plan Template

> **Naming:**
> - With topic: `v[ver/1.x.x]-[YYYY-MM-DD]-session-[topic].md` (e.g., `v1.x.x-2026-05-23-session-refactor-auth.md`)
> - Without topic (Draft): `v1.x.x-session-YYYY-MM-DD-NN.md` (e.g., `v1.x.x-session-2026-05-27-01.md`, NN = sequential 01, 02...)
>
> **Lifecycle:** Created Active → completed phases synced to done.md → archived to `plans/done/`.
> **Role:** Light-weight DSP (Dynamic Session Plan) for fast coding (vibecode) with auto-commits and micro-workflows.

## Template A: Topic-Based DSP (Existing Behavior)

> Use when: `/vibecode session [topic]` — user provides a specific topic/goal upfront.

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

---

## 📊 Pre-Session Kickoff Report
- **Initial Repo Log:** `artifacts/tests/tdd-repo-before-[date].log`
- **Initial Test Log:** `artifacts/tests/tdd-evidence.log`
- **Preparation Description:**
  - Initialize the Dynamic Session Plan (DSP).
  - Record initial repository state snapshot (working tree clean / dirty).
  - Confirm active quality tools: [TDD, --graph, --hardened, etc.]

---

## 📋 Dynamic Milestone Queue

| Phase | Milestone / Goal | Quality Tools | Commit SHA | Status |
|:---|:---|:---|:---|:---|
| Phase 1 | [Goal name] | `[--tdd, --graph, ...]` | [SHA] | 🔨 Active |
| Phase 2 | [Goal name] | `[--qa, ...]` | — | ⏳ Pending |

---

## 🏁 Milestone Details

### Phase 1: [Milestone Name] ⚙️ `Difficulty: [🟢 Low | 🟡 Medium | 🔴 High]`

> **Quality Tools:** `[--tdd, --graph, --brainstorm, --qa, --hardened]`

#### 📊 Pre-Phase 1 Report
- **Reference Repo Log:** `artifacts/tests/tdd-repo-before-[date].log`
- **Reference Test Log:** `artifacts/tests/tdd-evidence.log`
- **Pre-execution Status:**
  - [Describe codebase state, bugs to fix or logic to add]

#### 🗺️ Blast Radius & Context Lock
- **Target Files:**
  - `path/to/file1`
  - `path/to/file2`
- **Blast Radius (Upstream/Downstream):** [List of affected nodes from Graph analysis, if --graph active]

#### ⚗️ Brainstorm Log (if --brainstorm active)
- **Question:** [Quick discussion topic/question]
- **Decision:** [Final decision reached]

#### 📝 Implementation Steps & Checklist
- [ ] 1.1 🤖 **Step 1:** [Task description]
- [ ] 1.2 🤖 **Step 2:** [Task description]
- [ ] 1.N-1 🤖 **Pre-commit Gate:** Run tests & lints (`npm run build` and `npx vitest run` or equivalent verification commands).
- [ ] 1.N 👤 **Git Checkpoint:** Commit changes with message `session([topic]): [milestone goal]`.
- [ ] ⛔ CHECKPOINT: Agent verification pass -> Verify that all previous tasks are successfully marked as done [x] in both this plan file and task.md (State Synchronization) -> Present the git diff & test results to the User (clearly stating: "I have completed [action, log files]. In addition, I have verified and marked all previous tasks as done. I propose that you approve running the commit command...") -> Receive explicit user approval before recording the commit SHA & marking Phase Done.
- [ ] 1.N+1 🤖 **Graph & Insight Update (if --graph):** Run `graph_enrich` for modified/new class/function nodes; and consider saving gotchas/lessons/decisions to the graph via `insight_push` (especially for feat or fix bug tasks).

#### 📊 Post-Phase 1 Report
- **Post-execution Repo Log:** `artifacts/tests/tdd-repo-before-[date].log`
- **Post-execution Test Log:** `artifacts/tests/tdd-evidence.log`
- **Completed Tasks Description:** [Describe completed tasks and results]
- **Commit SHA:** —

---

## ⏳ Pending Queue

> Add new milestones/tasks discovered during the session here. They will be promoted to active phases sequentially.

- **Phase N+1: [Milestone Name]**
  - **Quality Tools:** `[options]`
  - **Goal:** [Brief description]
  - **Tasks:**
    - [ ] [Task detail]

---

## 🏁 Completion & Teardown

> ⛔ **CHECKPOINT (Next Steps):** Session has completed all phases. Agent stops here and requests User selection for the next step (choose 1, 2, or 3):
>
> 1. **End session and close plan:** Run `/plan end` (Workflow will automatically sync completed tasks to `done.md`, update the codebase graph, archive this plan file to `plans/done/`, and clear `active_plan` in `project.md`).
> 2. **Continue with another Topic:** Run `/vibecode session [topic]` (to start a new session/phase).
> 3. **Modify / Update current plan:** Run `/plan update` (to edit phases or add new tasks to this DSP).
````

---

## Template B: DSP Draft (New — JIT Phase Creation)

> Use when: `/vibecode` (no args) or `/vibecode session` (no topic) — user starts a free coding session.
> Phases are created dynamically (JIT) as the user requests specific goals during the conversation.
> Each Phase starts with a **mandatory Quality Gate** proposing TDD, --graph, QA brainstorm, and --hardened.

````markdown
# Session Plan: Ad-hoc Session

> **Created:** YYYY-MM-DD
> **Status:** 🔨 Active
> **Topic Slug:** session-YYYY-MM-DD-NN

<!-- ⚠️ STATUS GATE: DSP Draft — phases added JIT as user requests goals.
     Lifecycle: 🔨 Active → ✅ Done.
     Each Phase begins with a mandatory Quality Gate (TDD/graph/QA/hardened proposal).
     Transition from Active → Done requires completed phases synced to done.md + explicit user approval. -->

---

## ⚡ Session Goals

Free coding session — phases will be created dynamically
as specific tasks are identified during the conversation.

---

## 📊 Pre-Session Kickoff Report
- **Initial Repo Log:** `artifacts/tests/tdd-repo-before-[date].log`
- **Initial Test Log:** `artifacts/tests/tdd-evidence.log`
- **Preparation Description:**
  - Initialize the Dynamic Session Plan (DSP).
  - Record initial repository state snapshot (working tree clean / dirty).
  - Confirm active quality tools.

---

## 📋 Dynamic Milestone Queue

| Phase | Milestone / Goal | Quality Tools | Commit SHA | Status |
|:---|:---|:---|:---|:---|
| *(Queue empty — waiting for user requests)* | | | | |

---

## 🏁 Milestone Details

> Phases will be appended here as the user requests specific goals.
> Each Phase starts with a Quality Gate (see `references/session-quality-gate.md`) and pre/post phase reports.

---

## ⏳ Pending Queue

> (Empty on initialization)

---

## 🏁 Completion & Teardown

> ⛔ **CHECKPOINT (Next Steps):** Session has completed all phases. Agent stops here and requests User selection for the next step (choose 1, 2, or 3):
>
> 1. **End session and close plan:** Run `/plan end` (Workflow will automatically sync completed tasks to `done.md`, update the codebase graph, archive this plan file to `plans/done/`, and clear `active_plan` in `project.md`).
> 2. **Continue with another Topic:** Run `/vibecode session [topic]` (to start a new session/phase).
> 3. **Modify / Update current plan:** Run `/plan update` (to edit phases or add new tasks to this DSP).
````
