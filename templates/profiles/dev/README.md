# Profile: `dev` — Developer Workspace

> **For**: Software developers working with AI agents on technical projects.
> **Philosophy**: All code is a Project. Knowledge lives in Areas. Tools live in Resources.

---

## 📂 Workspace Structure

```
workspace/
├── _inbox/                        # 📥 Unprocessed items, quick capture
├── Projects/                      # ⚡ Active development projects (with deadlines)
│   └── my-app/                    # Each project: kebab-case, has project.md
│       ├── project.md             # Project contract (goal, deadline, DoD)
│       ├── repo/                  # Source code (git root)
│       ├── sessions/              # Session logs & BACKLOG.md
│       ├── docs/                  # Project documentation
│       └── artifacts/             # AI-generated artifacts
│           ├── plans/             # 📝 Implementation plans
│           └── tasks/
│               ├── backlog.md     # 📌 CANONICAL task list
│               ├── sprint-current.md
│               └── done.md
├── Areas/
│   ├── infra/                     # 🔧 Infrastructure SOPs, runbooks, configs
│   ├── product/                   # 📦 Product specs, design decisions
│   └── ops/                       # ⚙️ Operations, CI/CD, deployment
├── Resources/
│   ├── ai-agents/                 # 🤖 Kernel snapshot, agent workflows
│   │   ├── kernel/
│   │   └── workflows/
│   ├── references/                # 📚 Reference repos, docs, cheat-sheets
│   └── tools/                     # 🛠️ Scripts, utilities, CLI tools
├── Archive/                       # ❄️ Completed/retired projects & areas
├── .agent/                        # Agent runtime (auto-installed)
│   ├── rules/
│   └── workflows/
├── .para-workspace.yml            # Workspace config
├── para                           # CLI wrapper (auto-generated)
└── README.md
```

---

## 📑 Recommended Workflows

| Workflow           | When to Use                                  |
| :----------------- | :------------------------------------------- |
| **`/plan`**        | Create or review an implementation plan      |
| **`/open`**        | Start a working session, load context        |
| **`/backlog`**     | Add/prioritize tasks for a project           |
| **`/new-project`** | Scaffold a new development project           |
| **`/learn`**       | Document lessons and knowledge in Areas      |
| **`/push`**        | Quick commit and push to GitHub              |
| **`/verify`**      | Verify a feature is complete via walkthrough |
| **`/release`**     | Pre-release quality gate before publishing   |
| **`/retro`**       | Retrospective before archiving a project     |
| **`/end`**         | Close session and log progress               |
| **`/para`**        | Workspace health check and maintenance       |

---

## 📜 Active Rules

After `para init`, the following rules are installed in `.agent/rules/`:

- **`governance.md`** — Core PARA discipline rules (invariants + heuristics)

---

## 🔄 Standard Daily Workflow

### 1. 🌅 Open Session — `/open [project-name]`

```
@[/open] my-app
```

- Reads `project.md` for goal and DoD
- Shows last session log and pending TODOs
- Checks Sync Queue for upstream notifications
- Reports Git status

---

### 2. 📋 Manage Tasks — `/backlog`

```
@[/backlog] my-app add task: implement user authentication
```

- Add new tasks to `artifacts/tasks/backlog.md`
- Prioritize or triage existing tasks
- Move completed tasks to `done.md`

---

### 3. 💻 Develop

Work on your project. Use the following helpers as needed:

```bash
# Check workspace health
./para status

# Scaffold a new project
./para scaffold project new-feature

# Commit and push changes
@[/push]
```

---

### 4. ✅ Verify (before closing a feature)

```
@[/verify] my-app "user authentication works end-to-end"
```

- Generates a step-by-step verification walkthrough
- Logs the result in the session

---

### 5. 🌙 End Session — `/end`

```
@[/end]
```

- Summarize completed work
- Log new TODOs for next session
- Classify any loose files into PARA (Projects / Areas / Resources / Archive)
- Notify downstream projects if changes are relevant

---

## 💡 Tips for `dev` Profile

- **kebab-case everything**: `my-app`, `auth-service`, `api-gateway`
- **One git repo per Project folder**: the `repo/` sub-folder is the git root
- **`_inbox/` is your capture zone**: drop notes, code snippets, links here — process later during `/end`
- **Areas are evergreen SOPs**: runbooks in `Areas/infra/` should always be accurate
- **Resources are read-only references**: don't do active work inside `Resources/`
