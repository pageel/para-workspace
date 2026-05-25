# LARGE Review Workflow — Sequential (Codex/Antigravity)

Sequential chunking workflow for large repositories (>20 main-lang files OR >30 total OR >14 days). Unlike the Claude Code variant (which spawns parallel sub-agents), this variant processes **each chunk sequentially** within the same main agent context.

> Invoked from [`../SKILL.md`](../SKILL.md) Step 3 when routing decides LARGE mode.

## Why sequential?

Codex CLI and Antigravity (at this time) do not have a mechanism for a skill to spawn parallel sub-agents. To keep the output IDENTICAL to the Claude Code variant, we split the files into chunks (similar to Claude) but process them sequentially. Trade-off: ~3× slower but identical results.

## Inputs (already available from SKILL.md context)

- `$SCOPE`, `$LANG`, `$FILES`, `$PRIMARY_LANG`, `$OVERLAY_AVAILABLE`, i18n strings — same as SMALL mode

## Steps

### Step L1 — Load rule files (Once only)

Read all rule files into context **once at the start of the workflow** to avoid re-reading for each chunk:

1. Generic rules: `rules/generic/01-*.md` … `rules/generic/21-*.md` (21 files)
2. Language overlay (if `$OVERLAY_AVAILABLE`): `rules/languages/$PRIMARY_LANG/*.md`

Remember which rule IDs are overridden by the overlay.

### Step L2 — Setup workspace

```bash
mkdir -p .tmp
```

Ensure `.tmp/` is in `.gitignore` (warn user if not, but still proceed).

### Step L3 — Chunk files

Read [`../references/chunking-strategy.md`](../references/chunking-strategy.md) and apply the algorithm.

Output: list `chunks` with format:
```
chunks = [
  {"name": "api/handlers", "slug": "api-handlers", "files": [...], "count": 12},
  {"name": "frontend/src/components", "slug": "frontend-components", "files": [...], "count": 25},
  ...
]
```

`slug` = `name` with `/` replaced by `-`.

### Step L4 — Process chunks SEQUENTIALLY

For each `chunk` in `chunks` (in order, not parallel):

1. **Resume check:** if `.tmp/findings-<slug>.md` already exists and is non-empty → skip this chunk (already scanned in a previous session). Read the file back into memory.

2. **Print progress** to stdout: `[chunk N/total] Scanning <chunk.name> (<count> files)...`

3. **Apply rules to files in the chunk:**
   - For each file in `chunk.files`:
     - Skip if binary/generated/>5000 lines (see [`small-review.md`](small-review.md#step-s2--apply-rules-per-file) Step S2.1)
     - For each rule in (generic + overlay):
       - Use grep tool to find patterns
       - Use read tool to view full function/context
       - Apply L1-L4 data flow analysis (see [`../references/data-flow-classification.md`](../references/data-flow-classification.md))
       - Decide: real vulnerability or false positive?
   - Collect findings: `(file, line, rule_id, severity, issue, fix, context)`

4. **Rule ID discipline (MANDATORY):**
   - **Only use the 21 canonical rule IDs**. DO NOT invent new rules.
   - 1 line of code triggering 2 rules → create **2 separate findings**, each with 1 `rule_id`.

5. **Write chunk findings** to `.tmp/findings-<slug>.md`:
   - Markdown format (same schema as the Claude variant sub-agent output)
   - Sections: `## FINDINGS`, `## PASSED`, `## NOT_MAPPED` (if any)
   - Absolute file path from repo root

6. **Print confirmation:** `[chunk N/total] ✓ <count_findings> findings`

7. **Continue to the next chunk** (no spawn, no await — since it is sequential).

### Step L5 — Aggregate findings

Read all `.tmp/findings-*.md`:

1. **Parse** each file into a list of findings (file/line/rule_id/severity/issue/fix/context)
2. **Validate rule_ids**: every finding must have a `rule_id` within the 21 canonical IDs.
3. **Dedup**: key = `(file, line, rule_id)`. Keep the entry with the highest severity. If tied, keep the entry with the longer `context`.
   - **Note:** dedup key contains `rule_id` → a single location (file:line) triggering 2 different rules (e.g., IDOR + RACE) will remain 2 entries, DO NOT dedup.
4. **Collect NOT_MAPPED**: if any, note at the end of the main report (helps roadmap future rules).
5. **Collect PASSED**: union of rule_ids appearing in the `## PASSED` section of all chunks. A rule only enters the PASSED list if it does **not** appear in findings of any chunk.
6. **Cross-chunk rules**:
   - **SLOPSQUATTING**: collect all import statements from chunks, dedup, verify if the packages are valid.
   - **OUTDATED-DEPENDENCY**: read dependency lock file (`package-lock.json`, `go.sum`, `composer.lock`) at the root.
   - **CSRF middleware global**: if a global middleware is detected in 1 chunk, downgrade CSRF findings in other chunks.

7. **Counts sanity check** (MANDATORY before rendering):
   ```
   total = len(findings)
   assert total == count_by_severity('CRITICAL') + count_by_severity('HIGH') + count_by_severity('MEDIUM') + count_by_severity('LOW')
   ```

### Step L6 — Translate (if lang=vi)

If `$LANG = "vi"`:

For each finding:
- `issue` (EN) → translate to vi, keeping English technical terms (function name, library, code snippet)
- `fix` (EN) → prefer using phrase templates from `i18n/vi.md`

Section headers, verdict labels — retrieved from loaded i18n keys.

### Step L7 — Render report

According to the template in [`../references/output-format.md`](../references/output-format.md).

**Verbose level by severity:**
- CRITICAL → overview table + full verbose block (Short description + Why dangerous + Attack scenario + Code before/after + Read more)
- HIGH → overview table + medium block (Description + Impact + Code fix + Read more)
- MEDIUM → compact table only
- LOW → compact table only

**Generate verbose content (non-tech friendly):**

Findings from chunks are compact (file, line, rule_id, severity, issue, fix, context). When rendering, paraphrase from rule file content (Read in Step L1):
- `why_dangerous` → from "Intent" + "Examples CRITICAL" sections of the rule
- `attack_scenario` → real scenario based on rule's pattern + chunk's `context`
- `code_before` → from chunk's `context` (already contains the actual snippet)
- `code_after` → from the "Fix recommendation" section of the rule, adapted for actual code

When translating to `$LANG=vi`: translate text, keep code in English. When `lang=en`: use EN canonical.

### Step L8 — Save report to file

1. Render full report (according to Step L7 logic)
2. **Save** using Antigravity's write/create-file tool:
   - Path: `reports/security/scan-<TIMESTAMP>.md` (prepared in SKILL.md Step 0)
   - Content IDENTICAL to stdout
3. **Print stdout** after report:
   ```
   📄 {msg_report_saved}: reports/security/scan-2026-05-13-143022.md
   ```
4. **If gitignore warning needed:**
   ```
   ⚠️ {msg_gitignore_warning_title}: {msg_gitignore_warning_text}
   ```

### Step L9 — Determine verdict

| Findings | Verdict |
|---|---|
| ≥1 CRITICAL | FAIL |
| 0 CRITICAL, ≥1 HIGH | WARN |
| 0 CRITICAL, 0 HIGH | PASS |

### Step L10 — Cleanup

```bash
rm -rf .tmp    # cleanup temp files (always delete)
# DO NOT delete reports/security/ — that is persisted output for the user
```

## Resume protocol

If the user re-runs the skill while `.tmp/` remains from a previous session:

1. Read `.tmp/` — chunks that already have non-empty `findings-*.md` are considered scanned
2. Only process chunks that do not have a findings file yet (Step L4 already has resume check in item 1)
3. Aggregate as normal (Step L5)

If the user wants to re-scan from scratch: use the `--fresh` argument → delete `.tmp/` before starting.

## Performance target

| Chunks | Sequential time |
|---|---|
| 5 | ~5-8 min |
| 10 | ~10-15 min |
| 15 | ~15-25 min |

Comparison: Claude variant parallel is ~2-10 min for the same workload. Sequential variant is ~3× slower but identical output.

Main agent context: ~50-100K tokens (enough for average repos; if the repo is extremely large → might need to be split into 2 invokes).

## Edge cases

| Scenario | Handling |
|---|---|
| Chunk has 1 very large file (>5000 lines) | Read using grep first → read targeted sections |
| 2 chunks find the same issue in the same file (border file) | Dedup in Step L5 |
| Generated code occupies an entire chunk | Self-flag "this chunk is mostly generated, low priority". Downgrade severity of findings in this chunk by 1 level. |
| Repo with 500+ files → 15 chunks, each with 30+ files | OK but slow (~20-30 min). Suggest user to use Claude Code variant for repos of this size. |
| User Ctrl+C mid-run | `.tmp/` is kept. Re-run → resume from unfinished chunk. |
| No git (repo not initialized) | Early exit in SKILL.md Step 0 — does not enter here. |
| Agent context nearly full mid-run | Save partial findings to `.tmp/` then notify user to re-invoke skill to continue. |
