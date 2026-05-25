# Loop Configuration Template

> JIT-loaded by `/vibecode loop` at Step 1 (Define Exit Criteria).

## Template

```markdown
## 🔄 LOOP CONFIGURATION

**Target:** [Phase/Task description]
**Max iterations:** [N, default 5]
**Project type:** [Node.js | Astro | Bash | Markdown | PARA | Custom]

### Exit Criteria (ALL must pass to exit loop)

- [ ] [Primary build/compile command succeeds]
- [ ] [Lint check passes with 0 errors]
- [ ] [Type check passes (if applicable)]
- [ ] [Custom criterion 1 from plan]
- [ ] [Custom criterion 2 from plan]

### Stop Conditions (ANY triggers immediate stop)

| Condition | Threshold | Action |
|:--|:--|:--|
| Max iterations reached | [N] | Report partial progress, ask user |
| Same error repeated | 3 times | Escalate — likely architecture issue |
| Error count INCREASED | vs previous iteration | Rollback to last good state |
| Token budget low | <20% remaining | Pause, save progress |
| New file conflict | merge conflict detected | Stop, ask user to resolve |

### Rollback Strategy

| Method | When | Command |
|:--|:--|:--|
| git stash | Before each iteration | `git stash push -m "vibecode-iter-N"` |
| git stash pop | On rollback | `git stash pop` |
| Manual restore | If stash conflicts | `git checkout -- .` |

### Verification Command

[Agent fills from `references/verification.md` based on project type]
```

## Exit Criteria Presets

### Preset: Web App (Node.js/Astro)

```markdown
- [ ] `npm run build` exits 0
- [ ] `npm run lint` exits 0
- [ ] No TypeScript errors (`npx tsc --noEmit`)
- [ ] No console.error in build output
```

### Preset: CLI / Bash Script

```markdown
- [ ] `bash -n script.sh` exits 0 (syntax valid)
- [ ] `shellcheck script.sh` no errors
- [ ] Script runs with `--help` without error
```

### Preset: Documentation

```markdown
- [ ] No broken relative links
- [ ] All files have YAML frontmatter
- [ ] English-only in repo/ files (if governed)
- [ ] No absolute paths
```

### Preset: PARA Workflow/Rule

```markdown
- [ ] YAML frontmatter valid (description, source)
- [ ] No absolute paths
- [ ] [project-name] placeholder used (no hardcoded names)
- [ ] English language for governed files
- [ ] Catalog entry exists (if governed)
```
