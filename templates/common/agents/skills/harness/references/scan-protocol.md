# Auto-Scan Protocol

> Protocol for scanning project rules and skills to generate context-aware
> Harness Guards. Agent follows this protocol at `/plan create` Step 8.5
> or when generating guards for any phased artifact.

## Protocol Steps

### Step 1. Read Project DNA

1. Check `project.md` field `agent.rules` — if `true`, read `Projects/[name]/.agents/rules.md` index.
2. Check `project.md` field `agent.skills` — if `true`, read `Projects/[name]/.agents/skills.md` index.
3. If neither field is true → skip to Step 3 (use workspace-level guards only).

> **Token budget:** Index files only (~10-20 lines each). Do NOT read individual rule/skill files at this stage.

### Step 2. Extract Constraints

From each trigger row in the loaded indices, extract:

| Field | What to extract |
|:--|:--|
| **Trigger** | Conditions that activate the rule/skill |
| **Name** | Rule/skill identifier for guard text |
| **Relevance** | Does this trigger match any Phase scope in the plan? |

Filter to only **relevant** entries — those whose trigger matches the plan's file scope or operation type.

> **Example:** Plan Phase modifies `repo/` files → trigger match for `dogfooding-policy.md` ("Editing repo/") → generate HARNESS GUARD referencing dogfooding policy.

### Step 3. Generate Guards

For each Phase in the plan:

1. **MANDATORY guard** — Always add. Text: `Agent MUST reload .agents/rules.md + .agents/skills.md BEFORE modifying files or executing git commands`.
2. **HARNESS GUARD(s)** — Add one per matched constraint from Step 2:
   - Format: `<!-- ⚠️ HARNESS GUARD ([Source]): [Constraint summary] -->`
   - `[Source]` = rule/skill name or Risk table entry
   - `[Constraint summary]` = actionable instruction (what to do/avoid)
3. **Risk-derived guards** — Also check the plan's Risks & Mitigations table. Each risk mapped to a Phase produces an additional HARNESS GUARD.

### Step 4. Validate

- [ ] Every Phase has at least 1 MANDATORY guard.
- [ ] No HARNESS GUARD contains generic text like "be careful" — must be specific.
- [ ] Guards reference actual rule/skill names, not invented ones.
- [ ] Phase 0 MANDATORY includes `read project.md` (first Phase only).

## Guard Placement Order

```
### Phase N. [Name]

<!-- ⚠️ MANDATORY: ... -->
<!-- ⚠️ HARNESS GUARD (Risk Name): ... -->
<!-- ⚠️ HARNESS GUARD (Rule/Skill Name): ... -->

#### Implementation Plan
```

## Edge Cases

| Scenario | Action |
|:--|:--|
| Project has no rules/skills | Use workspace-level constraints + Risk table only |
| Risk table is empty | MANDATORY guards only (no HARNESS GUARD) |
| Phase has 3+ matched constraints | Combine related constraints into 1 guard to save tokens |
| Plan is documentation-only | Reference `docs-authoring` rules as harness source |
