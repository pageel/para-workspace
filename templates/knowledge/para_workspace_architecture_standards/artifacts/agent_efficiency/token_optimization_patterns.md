# PARA Workspace Token Optimization Patterns

AI agents in a PARA Workspace environment benefit from structural patterns that reduce directory scanning and redundant context loading.

## 1. Discovery Optimization (Direct Metadata Linking)

Instead of scanning directories, project metadata contains direct links:

- `active_plan` → direct jump to implementation plan
- `strategy` → direct path to strategy doc
- `roadmap` → direct path to roadmap

```yaml
# In project.md frontmatter:
strategy: "@pageel/docs/strategy-cms.md"
roadmap: "@pageel/plans/cms-branch-roadmap.md"
active_plan: "plans/editor-ux-stable-v2.1.md"
```

## 2. Field-Gated I/O (v1.6.3 — "Central Gate")

The most impactful optimization: **IF field is null/empty → skip, zero I/O.**

Applied to three fields in project.md:
- `strategy` — null → skip strategy loading
- `roadmap` — null → skip roadmap loading
- `active_plan` — null → skip plan loading

This eliminates filesystem probing (no `ls`, `find`, `stat` needed) and makes `/open` predictably fast.

## 3. Context Noise Reduction

- **Markdown tables** over prose for tech stacks, task lists, metadata
- **Progressive Disclosure:** Load full kernel only during `/para-audit`, `/plan`, or scaffolding — not during `/open`
- Mark irrelevant sections ("N/A") to maintain structure while minimizing weight

## 4. Lazy-Loading Agent Indices (v1.6.2+)

- Workspace rules/skills indices: ~20-30 lines total (~300 tokens) — loaded ALWAYS
- Rule/skill files: loaded ONLY when trigger matches current action
- Project agent indices: loaded ONLY when `agent.rules: true` / `agent.skills: true`

Result: `/open` loads ~500 tokens of index data instead of ~5000+ tokens of all rule files.

## 5. Task Compression

For micro-projects, merge tasks directly into `backlog.md` as sub-tasks under Epics:
- Consolidates context into single source of truth
- Reduces total files agent needs to track

## 6. Constraint-Based Output

Workflows include explicit constraints:
- `/plan`: "4-7 phases max"
- `/open`: "~30 tokens max for strategy summary"
- `/brainstorm`: structured D-table decisions

Prevents "hallucination expansion" where agent adds excessive detail.

## 7. Git-Hash Change Detection (v1.6.4+)

`para update` tracks commits in audit log:
```
para update | from=1.6.5 to=1.6.5 commits=0 | OK
```

When `commits=0` → skip install phase entirely → zero wasted I/O.

## 8. Strategy Cascade Detection (v1.6.3)

When BOTH `strategy` and `roadmap` are non-null:
- Compare modified times
- If strategy newer than roadmap → warn "Roadmap may need review"
- Prevents drift between strategic intent and tactical execution
