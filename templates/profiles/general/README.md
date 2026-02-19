# Profile: `general` — Standard PARA Workspace

> **For**: Anyone who wants a structured, AI-friendly personal knowledge workspace.
> **Philosophy**: Capture everything. Organize into PARA. Let your agent help.

---

## 📂 Workspace Structure

```
workspace/
├── _inbox/                        # 📥 Unprocessed items, quick capture
├── Projects/                      # ⚡ Active work with deadlines
│   └── my-project/
│       ├── project.md             # Project contract (goal, deadline, DoD)
│       ├── sessions/              # Session logs & BACKLOG.md
│       ├── docs/
│       └── artifacts/
│           └── tasks/
│               ├── backlog.md     # 📌 CANONICAL task list
│               ├── sprint-current.md
│               └── done.md
├── Areas/                         # 🛡️ Stable knowledge & responsibilities
│   └── (your areas here)          # e.g., health/, finance/, learning/
├── Resources/                     # 📚 Reference materials & tools
│   ├── ai-agents/                 # 🤖 Kernel snapshot, agent workflows
│   │   ├── kernel/
│   │   └── workflows/
│   └── references/                # Books, links, templates
├── Archive/                       # ❄️ Completed/retired items
├── .agent/                        # Agent runtime (auto-installed)
│   ├── rules/
│   └── workflows/
├── .para-workspace.yml
├── para
└── README.md
```

---

## 📑 Recommended Workflows

| Workflow           | When to Use                               |
| :----------------- | :---------------------------------------- |
| **`/open`**        | Start a working session, load context     |
| **`/backlog`**     | Add/review tasks for a project            |
| **`/new-project`** | Scaffold a new project                    |
| **`/end`**         | Close session and classify work into PARA |
| **`/para`**        | Workspace health check and maintenance    |
| **`/retro`**       | Retrospective before archiving a project  |

---

## 📜 Active Rules

After `para init`, the following rules are installed in `.agent/rules/`:

- **`governance.md`** — Core PARA discipline (invariants + heuristics)

---

## 🔄 Standard Daily Workflow

### 1. 🌅 Open Session — `/open [project-name]`

```
@[/open] my-project
```

- Reads `project.md` for goal and deadline
- Shows last session log and pending TODOs
- Reports workspace status

---

### 2. 📋 Manage Tasks — `/backlog`

```
@[/backlog] my-project add task: write blog post outline
```

- Add or triage tasks in `artifacts/tasks/backlog.md`
- Prioritize by impact and urgency

---

### 3. 🛠️ Do the Work

Work on your project. Keep this process in mind:

- Drop rough notes and clippings into `_inbox/` without overthinking
- Create or update files in the correct PARA category
- Use your agent to help draft, summarize, or research

---

### 4. 🌙 End Session — `/end`

```
@[/end]
```

- Summarize what you completed
- Log outstanding TODOs for next session
- Process `_inbox/` — classify each item into Projects / Areas / Resources / Archive

---

## 💡 Tips for `general` Profile

- **`_inbox/` first**: Never waste time deciding where something goes when you capture it. Just drop it in `_inbox/` and process it during `/end`.
- **Areas are evergreen**: Your `Areas/` folders represent ongoing responsibilities (finance, health, etc.) — keep them accurate and up-to-date.
- **Projects have deadlines**: If something doesn't have an end date, it's probably an Area, not a Project.
- **Archive is not trash**: Move completed work to `Archive/` to keep things tidy without deleting history.
