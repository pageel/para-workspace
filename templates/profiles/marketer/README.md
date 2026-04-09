# Profile: `marketer` — Marketing Workspace

> **For**: Marketing professionals managing campaigns, content, and customer insights with AI.
> **Philosophy**: Campaigns are Projects. Channels and customer knowledge are Areas. Research lives in Resources.

---

## 📂 Workspace Structure

```
workspace/
├── _inbox/                             # 📥 Quick capture: ideas, links, briefs
├── Projects/                           # ⚡ Active campaigns with deadlines
│   └── q1-launch-campaign/
│       ├── project.md                  # Campaign contract (goal, date, KPIs)
│       ├── sessions/                   # Session logs & BACKLOG.md
│       ├── docs/                       # Briefs, copy, strategy docs
│       └── artifacts/
│           └── tasks/
│               ├── backlog.md          # 📌 CANONICAL task list
│               ├── sprint-current.md
│               └── done.md
├── Areas/
│   ├── marketing/
│   │   ├── channels/                   # Channel SOPs: SEO, social, email, ads
│   │   ├── customers/                  # ICP, personas, customer research
│   │   └── strategy/                  # Brand voice, positioning, messaging framework
├── Resources/
│   ├── ai-agents/                      # 🤖 Kernel snapshot, agent workflows
│   │   ├── kernel/
│   │   └── workflows/
│   └── references/                     # Competitor analysis, inspiration, templates
├── Archive/                            # ❄️ Completed campaigns & retired strategies
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
| **`/open`** | Start a working session on a campaign |
| **`/backlog`** | Add/review tasks: content calendar, deliverables |
| **`/new-project`** | Scaffold a new campaign |
| **`/verify`** | Verify campaign deliverables are complete |
| **`/end`** | Close session, classify insights and materials |
| **`/retro`** | Campaign retrospective before archiving |
| **`/para`** | Workspace health check |

---

## 📜 Active Rules

After `para init`, the following rules are installed in `.agents/rules/`:

- **`governance.md`** — Core PARA discipline (invariants + heuristics)

---

## 🔄 Standard Daily Workflow

### 1. 🌅 Open Session — `/open [campaign-name]`

```
@[/open] q1-launch-campaign
```

- Loads campaign contract: goal, deadline, and KPIs
- Shows last session log and pending deliverables
- Reports campaign status

---

### 2. 📋 Manage Tasks — `/backlog`

```
@[/backlog] q1-launch-campaign add task: write landing page copy
```

- Add deliverables and tasks to `artifacts/tasks/backlog.md`
- Use priority: **High** (deadline-bound), **Medium** (important), **Low** (nice-to-have)

---

### 3. ✍️ Create & Execute

Use your agent to accelerate content creation:

- Brief your agent on target audience in `Areas/marketing/customers/`
- Reference brand voice from `Areas/marketing/strategy/`
- Draft copy, social posts, email sequences in `Projects/[campaign]/docs/`
- Drop raw inspiration and competitor screenshots in `_inbox/`

---

### 4. ✅ Verify — `/verify`

```
@[/verify] q1-launch-campaign "all campaign assets are ready for launch"
```

- Walkthrough checklist before launch
- Confirm each deliverable is complete and reviewed

---

### 5. 🌙 End Session — `/end`

```
@[/end]
```

- Summarize completed deliverables
- Log outstanding tasks for next session
- Process `_inbox/`: move insights to `Areas/marketing/customers/`, inspiration to `Resources/references/`
- Log campaign learnings in `Areas/marketing/strategy/`

---

## 💡 Tips for `marketer` Profile

- **Campaigns are Projects**: Every campaign gets its own folder under `Projects/` with a deadline and clear KPIs in `project.md`.
- **Customer knowledge is an Area**: ICPs, personas, and customer interviews belong in `Areas/marketing/customers/` — always evolving, never deleted.
- **Channel SOPs in Areas**: Keep your proven playbooks for each channel in `Areas/marketing/channels/`.
- **`_inbox/` for inspiration**: Drop competitor ads, swipe file material, or raw ideas here without interrupting your flow.
- **Retro every campaign**: Run `/retro` before archiving a campaign to capture learnings for future campaigns.
