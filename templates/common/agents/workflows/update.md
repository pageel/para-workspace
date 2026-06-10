---
description: Agent-guided safe workspace update with error recovery
source: catalog
---

# /update

> **Workspace Version:** 1.8.13 (BUG-10: Node path resolution integration)

Safely update the PARA Workspace to the latest version with pre-flight checks, dry-run preview, and automatic error recovery.

## Steps

> **Constraint:** Read `.para-workspace.yml` at the workspace root to resolve the user's preferred language.
> Resolution priority:
> 1. If `language` is a map: 
>    - chat language = `language.chat` (fallback: `language.default` -> "en")
>    - thinking language = `language.thinking` (fallback: `language.default` -> "en")
>    - artifacts language = `language.artifacts` (fallback: `language.default` -> "en")
> 2. If `language` is a string: chat & thinking & artifacts language = `language`
> 3. If `language` is undefined, look for `preferences.language` (legacy)
> 4. Default ultimate fallback: "en"
> All output (chat response) MUST be translated to the chat language, all internal reasoning (<thought>) MUST be written in the thinking language, and all generated files in artifacts/ (plans, tasks, qa) MUST follow the artifacts language.

### 1. Pre-flight checks

// turbo

Gather current workspace state. All 3 checks run in parallel:

```bash
# Check 1: Current version & git status
cd Resources/references/para-workspace && \
  echo "=== VERSION ===" && cat VERSION && \
  echo "=== GIT STATUS ===" && git status --short && \
  echo "=== BRANCH ===" && git branch --show-current
```

```bash
# Check 2: Workspace kernel version
grep 'kernel_version:' .para-workspace.yml
```

```bash
# Check 3: Network connectivity
git -C Resources/references/para-workspace ls-remote --heads origin main 2>&1 | head -3
```

**Evaluate results and display Pre-flight Report:**

```
🔍 PRE-FLIGHT CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Current kernel  : v[X.Y.Z] (from .para-workspace.yml)
  Repo VERSION    : v[X.Y.Z]
  Git branch      : [main]
  Git status      : [clean / N files dirty]
  Network         : [✅ OK / ❌ Unreachable]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Decision gates:**

> **⚠️ CRITICAL (v1.7.6 — BUG-29 fix):** Repo VERSION is read BEFORE `git pull`, so it is **always stale**.
> The agent **MUST ALWAYS proceed to Step 2** (dry-run) regardless of version match.
> **NEVER stop or suggest "no update needed" based on Step 1 alone.**
> Only `./para update --dry-run` (Step 2) can determine if changes exist.

| Condition | Action |
| :-- | :-- |
| Network ❌ | **STOP.** Inform: "Cannot reach GitHub. To re-sync with the local repo version without downloading, try `./para install`." Ask user whether to run `para install` instead or stop. |
| Git dirty (uncommitted changes in repo) | **WARN.** Display: "Repo has uncommitted changes. `git pull` may cause conflicts." Ask user: (a) Stash first then update, (b) Skip and continue, (c) Stop. |
| Kernel > Repo VERSION | **INFO.** Workspace ahead of local repo — stale repo. **Proceed to Step 2** (dry-run will pull first). |
| Kernel == Repo VERSION | **INFO.** Versions match locally, but remote may have updates. **Proceed to Step 2** (dry-run will pull and compare). |
| All OK | Proceed to Step 2. |

### 2. Dry-run preview

// turbo

Run a preview so the user knows what will change:

```bash
./para update --dry-run 2>&1
```

**Display summary:**

```
📋 DRY-RUN PREVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  New version  : v[X.Y.Z]
  Migration    : [N steps required / None needed]
  Files sync   : [N files will be updated]
  Backups      : Auto-saved to .para/backups/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Ask user for confirmation: **"Proceed with update? (Y/n)"**

- If **no** → Stop, inform "Cancelled. No changes were made."
- If **yes** → Proceed to step 3.

### 3. Execute update

Run the live update:

```bash
./para update 2>&1
```

**If successful** (exit code 0) → Proceed to step 5 (Verify).

**If failed** (exit code ≠ 0) → Proceed to step 4 (Error Recovery).

### 4. Error recovery

> ⚠️ **This step only runs when step 3 fails.**

Analyze the error output and apply the diagnosis table:

| Error detected | Root cause | Agent action |
| :-- | :-- | :-- |
| `fatal: Could not resolve host` or `Connection refused` | Network lost mid-update | Inform user. Suggest: `./para install` (offline sync). |
| `CONFLICT` or `Merge conflict` | Git conflict during pull | Run `cd Resources/references/para-workspace && git diff --name-only --diff-filter=U` to list conflicted files. Suggest: `git checkout --theirs <file>` for each (prefer upstream). |
| `Permission denied` | Missing file permissions | Run `chmod +x ./para Resources/references/para-workspace/cli/para Resources/references/para-workspace/cli/commands/*.sh`. |
| `rollback` or `Rolling back` | Install failed, already rolled back | Inform: "Auto-rollback completed. Workspace is safe." Read last line of `.para/audit.log` to confirm. Suggest: `./para install --force`. |
| `command not found: semver_gte` | Library not loaded | Check if `cli/lib/validator.sh` exists. If missing → run `./para install` first, then retry. |
| `not a git repository` | Wrong repo path | Check if `Resources/references/para-workspace/.git` exists. If not → guide user to re-clone. |
| Other errors | Unknown | Display raw output. Ask user: (a) Try `./para install --force`, (b) Stop for manual debug. |

After recovery action → **retry step 3** (max 1 retry). If still fails → report and stop.

### 5. Verify update

// turbo

Confirm the update succeeded with 3 checks:

```bash
# Check 1: Version after update
grep 'kernel_version:' .para-workspace.yml
```

```bash
# Check 2: Migration log
tail -1 .para/migrations/history.log
```

```bash
# Check 3: Audit log entry
tail -1 .para/audit.log
```

```bash
# Check 4: Preferences Node Path (BUG-10)
grep -A 2 '^preferences:' .para-workspace.yml 2>/dev/null || echo "No preferences block"
```

### 6. Display report

```
✅ UPDATE SUCCESSFUL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Previous version : v[OLD]
  New version      : v[NEW]
  Migration        : [Ran N steps / None needed]
  History log      : [latest line from history.log]
  Backups          : .para/backups/[date]/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 SUGGESTED NEXT STEPS:
1. Run `./para status` — verify workspace health.
2. Run `./para cleanup` — remove old .bak files (if needed).
3. Check Sync Queue — if downstream projects need updating.
4. Run `/para-knowledge` — review System KIs (auto-synced during update).
```

## Troubleshooting Reference

| Scenario | Alternative command |
| :-- | :-- |
| Update failed, just need sync | `./para install` |
| Force sync (overwrite all) | `./para install --force` |
| Preview changes only | `./para update --dry-run` |
| Manual rollback | Check `.para/backups/[date]/` and restore needed files |
| Clean old backups | `./para cleanup` |

## Related

- `/install` — Sync workspace without git pull
- `/push` — Commit and push changes
- `/open` — Start a working session
- `/release` — Pre-release quality gate
