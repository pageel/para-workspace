# Profile: `general` — Standard PARA Workspace

> **For**: Anyone who wants a structured, AI-friendly personal knowledge workspace.
> **Philosophy**: Capture everything. Organize into PARA. Let your agent help.
> **Workspace Version**: 1.5.0

---

## 📂 Workspace Structure

```
workspace/
├── _inbox/                        # 📥 Unprocessed items, quick capture
├── Projects/                      # ⚡ Active work with deadlines
│   └── my-project/
│       ├── project.md             # Project contract (goal, deadline, DoD)
│       ├── sessions/              # Session logs
│       ├── docs/                  # Project documentation
│       └── artifacts/
│           └── tasks/
│               ├── backlog.md         # 📌 CANONICAL task list (Single Source of Truth)
│               ├── sprint-current.md  # 🔄 Auto-generated focus view (One-way Snapshot)
│               └── done.md            # 📦 Completed tasks archive (Append-only)
├── Areas/                         # 🛡️ Stable knowledge & responsibilities
│   ├── Workspace/                 # Workspace-level sessions, sync queue, audits
│   └── Learning/                  # Cross-project reusable lessons
├── Resources/                     # 📚 Reference materials & tools
│   └── references/                # Books, links, templates
├── Archive/                       # ❄️ Completed/retired items
├── .agent/                        # Agent runtime (auto-installed)
│   ├── rules/                     # AI behavior rules
│   └── workflows/                 # AI workflow instructions
├── .para-workspace.yml            # Workspace configuration
├── para                           # CLI entry point
└── README.md
```

> **Task Management**: Uses the [Hybrid 3-File Model](../../docs/hybrid-3-file.md) — `backlog.md` is the canonical source, `sprint-current.md` and `done.md` are derived automatically.

---

## 📑 Recommended Workflows

| Workflow           | When to Use                               |
| :----------------- | :---------------------------------------- |
| **`/open`**        | Start a working session, load context     |
| **`/backlog`**     | Add/review tasks for a project            |
| **`/plan`**        | Create phased implementation plans        |
| **`/brainstorm`**  | Explore ideas before committing to a plan |
| **`/new-project`** | Scaffold a new project                    |
| **`/end`**         | Close session and classify work into PARA |
| **`/push`**        | Commit and push code to GitHub            |
| **`/para`**        | Workspace health check and maintenance    |
| **`/retro`**       | Retrospective before archiving a project  |
| **`/docs`**        | Generate and publish documentation        |

---

## 📜 Active Rules

After `para init`, the following rules are installed in `.agent/rules/`:

| Rule                 | Purpose                                          |
| :------------------- | :----------------------------------------------- |
| `governance.md`      | Core PARA discipline (invariants + heuristics)   |
| `para-discipline.md` | Enforce PARA classification (P/A/R/A/\_inbox)    |
| `naming.md`          | File and directory naming standards              |
| `vcs.md`             | Git and version control best practices           |
| `agent-behavior.md`  | Core behavioral constraints for AI agents        |
| `context-rules.md`   | Rules for context loading and session management |

---

## 🔄 Standard Daily Workflow

### 1. 🌅 Open Session — `/open [project-name]`

```
@[/open] my-project
```

- Reads `project.md` for goal and deadline
- Shows last session log and pending TODOs
- Displays `sprint-current.md` for fast task overview
- Reports workspace status

---

### 2. 📋 Manage Tasks — `/backlog`

```
@[/backlog] my-project add task: write blog post outline
```

- Add or triage tasks in `artifacts/tasks/backlog.md`
- Prioritize by impact and urgency
- Auto-syncs `sprint-current.md` and `done.md`

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
- **Agent reads `sprint-current.md`**: For maximum speed, your AI reads the small focus file instead of the full backlog.
