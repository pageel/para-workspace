# Auto Execution Queue Template

> JIT-loaded by `/vibecode auto` at Step 1 (Build Execution Queue).

## Template

```markdown
## ⚡ VIBECODE AUTO — Execution Queue

**Plan:** [Plan title]
**Plan path:** [Resolved path]
**Phases:** [N]
**Total tasks:** [Count]
**Estimated turns:** [Based on task count + verification]

### Queue

| Order | Phase | Task # | Task Name | Target | Verify? | Status |
|:--|:--|:--|:--|:--|:--|:--|
| 1 | Phase 0 | 1 | [Name] | `[path]` | No | ⏳ |
| 2 | Phase 0 | 2 | [Name] | `[path]` | No | ⏳ |
| 3 | Phase 0 | — | [Phase verify] | — | Yes | ⏳ |
| 4 | Phase 1 | 1 | [Name] | `[path]` | No | ⏳ |
| ... | ... | ... | ... | ... | ... | ⏳ |

### Phase Gates

| Phase | Gate type | Command |
|:--|:--|:--|
| Phase 0 | User confirm | "Phase 0 complete. Continue?" |
| Phase 1 | Build verify | `npm run build` |
| Phase 2 | Test verify | `npm test` |
| Phase 3 | User confirm + build | Both |

### Token Budget Estimate

| Phase | Tasks | Est. tokens | Fit in 1 turn? |
|:--|:--|:--|:--|
| Phase 0 | [N] | ~[X]K | ✅/❌ |
| Phase 1 | [N] | ~[X]K | ✅/❌ |
| Total | [N] | ~[X]K | [N turns needed] |

### Resume Point

If execution pauses mid-way:
- **Last completed:** Phase [N], Task [M]
- **Resume command:** `/vibecode auto [plan-ref] --resume Phase[N+1]`
- **Progress saved to:** `sprint-current.md` Hot Lane

Proceed with auto-execution? (y/n)
```

## Progress Update Format

After each task completion:

```
⚡ AUTO [N/Total] ━━━━━━━━━━━━━━━━━━━━━━━━
Phase [X]: [Phase Name]
  ✅ Task 1: [Done]
  ✅ Task 2: [Done]
  🔨 Task 3: [In Progress]
  ⏳ Task 4: [Pending]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Error Recovery

```
⚡ AUTO PAUSED ━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ Task failed: Phase [N], Task [M]
   Error: [error message]

Options:
  1. 🔄 Retry (attempt fix automatically)
  2. 🔄 Loop (switch to /vibecode loop for this task)
  3. ⏭️ Skip (mark as skipped, continue to next task)
  4. ⏸ Pause (save progress, resume later)
  5. ❌ Abort (stop execution, keep completed work)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
