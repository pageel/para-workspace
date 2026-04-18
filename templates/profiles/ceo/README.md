# Profile: `ceo` — Strategic Leadership Workspace

> **For**: Founders, executives, and leaders managing strategy, teams, and organizational oversight with AI.
> **Philosophy**: Initiatives are Projects. Strategy, finance, and org knowledge live in Areas. Research and references live in Resources.

---

## 📂 Workspace Structure

```
workspace/
├── _inbox/                             # 📥 Quick capture: decisions, ideas, meeting notes
├── Projects/                           # ⚡ Active strategic initiatives with deadlines
│   └── product-market-fit-2026/
│       ├── project.md                  # Initiative contract (goal, deadline, DoD)
│       ├── sessions/                   # Session logs & BACKLOG.md
│       ├── docs/                       # Strategy docs, memos, OKRs
│       └── artifacts/
│           └── tasks/
│               ├── backlog.md          # 📌 CANONICAL task list
│               ├── sprint-current.md
│               └── done.md
├── Areas/
│   ├── strategy/                       # Vision, mission, long-term OKRs, roadmaps
│   ├── finance/                        # Budgets, forecasts, financial models, KPIs
│   └── organization/                  # Team structure, hiring, culture, processes
├── Resources/
│   ├── ai-agents/                      # 🤖 Kernel snapshot, agent workflows
│   │   ├── kernel/
│   │   └── workflows/
│   └── references/                     # Books, frameworks, industry research, board materials
├── Archive/                            # ❄️ Completed initiatives & historical decisions
├── .agents/                             # Agent runtime (auto-installed)
│   ├── rules/
│   └── workflows/
├── .para-workspace.yml
├── para
└── README.md
```

---

## 📑 Recommended Workflows

| Workflow | When to Use |
| :-- | :-- |
| **`/open`** | Start a strategy session, load initiative context |
| **`/backlog`** | Add/review strategic tasks and decisions |
| **`/new-project`** | Launch a new strategic initiative |
| **`/verify`** | Verify initiative milestones are complete |
| **`/end`** | Close session and capture decisions for the record |
| **`/retro`** | Retrospective before completing an initiative |
| **`/para`** | Workspace health check and quarterly review |

---

## 📜 Active Rules

After `para init`, the following rules are installed in `.agents/rules/`:

- **`governance.md`** — Core PARA discipline (invariants + heuristics)

---

## 🔄 Standard Daily Workflow

### 1. 🌅 Open Session — `/open [initiative-name]`

```
@[/open] product-market-fit-2026
```

- Loads initiative contract: goal, deadline, and Definition of Done
- Shows last session log and outstanding decisions/tasks
- Surfaces Sync Queue items (cross-initiative notifications)

---

### 2. 📋 Manage Tasks & Decisions — `/backlog`

```
@[/backlog] product-market-fit-2026 add task: finalize Q2 hiring plan
```

- Track strategic tasks and open decisions in `artifacts/tasks/backlog.md`
- Prioritize ruthlessly: **High** (blocks progress), **Medium** (this quarter), **Low** (future)

---

### 3. 🧠 Think & Decide

Use your agent as a strategic thinking partner:

- **Draft memos and strategy docs** in `Projects/[initiative]/docs/`
- **Reference your OKRs** from `Areas/strategy/` to stay aligned
- **Review financial models** from `Areas/finance/` for data-backed decisions
- **Capture meeting outcomes and raw ideas immediately** to `_inbox/`

---

### 4. ✅ Verify Milestones — `/verify`

```
@[/verify] product-market-fit-2026 "Q1 milestone: 10 customer interviews completed"
```

- Step-by-step verification of milestone completion
- Creates an audit trail of strategic decisions

---

### 5. 🌙 End Session — `/end`

```
@[/end]
```

- Summarize decisions made and outcomes reached
- Log open items and blockers for next session
- Process `_inbox/`: file meeting notes in appropriate Areas, move research to `Resources/repo/`
- Note any cross-initiative impacts in the Sync Queue

---

## 💡 Tips for `ceo` Profile

- **Strategic initiatives are Projects**: Every major initiative gets its own `Projects/` folder with a clear goal, deadline, and Definition of Done.
- **Strategy is an Area, not a Project**: Your annual vision and OKRs live in `Areas/strategy/` and evolve over time — they don't have a completion date.
- **Decisions belong in the record**: Log key decisions in session notes. Future-you (and your team) will thank you.
- **`_inbox/` for meeting captures**: Paste raw meeting notes here immediately. Process them during `/end` into the correct Area.
- **Quarterly `/para` review**: Use `/para` for a high-level workspace health check — ensure Projects align with Areas strategy and nothing is stagnating.
- **`/retro` before archiving**: Run `/retro` on completed initiatives to capture learnings in `Areas/strategy/`.
