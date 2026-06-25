# Meta Plan: [Kit/Configuration Name]

> **Description**: Integration design blueprint and implementation plan for Agent governance components (Workflows, Skills, Rules, MCP, Plugins, KIs).
> **Workflow**:
> 1. Design drafts directly inside this Plan.
> 2. Run `/para-workflow add` and `/para-skill add` to scaffold folders/files.
> 3. Populate contents and run `/para-workflow validate` to pass quality gates.

---

## Phase 0: Target & Environment Selection ⚙️ `Difficulty: 🟢 Low`

> 💡 **Model Hint:** This phase defines target directory paths. Use a lightweight model to save costs.

*   **Target Environment Decision**:
    *   [ ] **Option A (Workspace-Live)**: Deploy directly into the active workspace config (`.agents/workflows/`, `.agents/skills/`). Ideal for quick live sandboxed experiments.
    *   [ ] **Option B (Project-Template)**: Deploy into a project's template directory (`Projects/[project-name]/repo/templates/`). Ideal for packaging and distribution.

### Checklist:
- [ ] Choose Option A or Option B.
- [ ] Map the target file paths based on the selection.
- [ ] (If Option A chosen) Verify workspace root `.gitignore` covers the live folder paths to prevent committing trial files.

---

## Phase 1: Component & Tooling Inventory ⚙️ `Difficulty: 🟢 Low`

Identify components to create and their respective scaffolding commands:

| Component File | Type | Target Path (Derived from Phase 0) | Scaffolding Command |
| :--- | :--- | :--- | :--- |
| `[name].md` | Workflow | `.agents/workflows/` OR `repo/templates/...` | `/para-workflow add [name]` |
| `[name]` | Skill | `.agents/skills/` OR `repo/templates/...` | `/para-skill add [name]` |

---

## Phase 2: Design Drafts ⚙️ `Difficulty: 🔴 High`

> 💡 **Model Hint:** Designing agent logic, steps, and rules requires high reasoning. Switch to a thinking model for this phase.

### 📝 Draft: Workflow `[name].md`
```markdown
[Draft the complete workflow script here: steps, inline bash commands, and checkpoints]
```

### 📝 Draft: Skill `SKILL.md` & Templates
```markdown
[Draft the skill routing table and template files here]
```

---

## Phase 3: Scaffolding & Content Injection ⚙️ `Difficulty: 🟡 Medium`

Initialize the file structures using specialized tool commands, and populate the contents:

### Checklist:
- [ ] Run `/para-workflow add [name]` to scaffold the workflow skeleton.
- [ ] Run `/para-skill add [name]` to scaffold the sidecar skill directory.
- [ ] Write the workflow content from **Phase 2 (Draft Workflow)** into the live workflow file.
- [ ] Write the skill content from **Phase 2 (Draft Skill)** into the live skill files.

---

## Phase 4: Compliance Validation ⚙️ `Difficulty: 🟢 Low`

Validate the newly deployed configurations:

### Checklist:
- [ ] Run `/para-workflow validate [name]` to check syntax and standard compliance.
- [ ] Run `/para-skill validate [name]` to check skill folder integrity.
- [ ] Test the workflow and skill conversational flow in a sandboxed scenario.
