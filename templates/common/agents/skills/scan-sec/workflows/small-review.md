# SMALL Review Workflow

Inline scan workflow for small-to-medium repositories (≤20 main-lang files AND ≤30 total AND ≤14 days). Main agent executes all steps, no sub-agents are spawned.

> Invoked from [`../SKILL.md`](../SKILL.md) Step 3 when routing decides SMALL mode. Before reading this file, SKILL.md has done: parse args, gather files, detect lang, load i18n.

## Inputs (already available from SKILL.md context)

- `$SCOPE` — scope label
- `$LANG` — output lang (`vi` or `en`)
- `$FILES` — list of filtered files (excluding vendored ones)
- `$PRIMARY_LANG` — detected language result
- `$OVERLAY_AVAILABLE` — whether specialized rules are available
- Loaded i18n strings (from `references/i18n/<lang>.md`)

## Steps

### Step S1 — Load applicable rules

1. **Generic rules (always load):**
   ```
   skill/rules/generic/01-hardcoded-secret.md
   skill/rules/generic/02-sql-injection.md
   ...
   skill/rules/generic/21-command-injection.md
   ```

   Read ALL 21 files using the Read tool.

2. **Specialized overlay (if `$OVERLAY_AVAILABLE`):**
   ```
   skill/rules/languages/<primary_lang>/*.md
   ```

   For each overlay file with the same `id` as a generic rule, the **specialized rule completely replaces** the generic rule for that language. Remember which IDs have overridden.

### Step S2 — Apply rules per file

For each file in `$FILES`:

1. **Skip if not applicable**:
   - Binary file (image, font, archive) → skip
   - Generated file (e.g.: `*.pb.go`, `*_pb2.py`, `dist/*`) → skip with note
   - File >5000 lines → read but use search-then-read pattern (Grep for pattern, Read surrounding context)

2. **For each applicable rule**:
   - Read `Search patterns` of the rule (only as suggestion, do not run literal)
   - Use **Grep tool** to find patterns in the file
   - For each match, use **Read tool** to view the full function/context
   - Apply **L1-L4 data flow analysis** (see [`../references/data-flow-classification.md`](../references/data-flow-classification.md))
   - Decide: real vulnerability or false positive?

3. **Record findings** in memory with fields:
   - `file`, `line`, `rule_id`, `severity` (≤ `severity_max` của rule), `issue`, `fix`, `context`

**Rule ID discipline (MANDATORY):**
- **Only use the 21 canonical rule IDs** listed in [SKILL.md Step 4](../SKILL.md#step-4--apply-rules). DO NOT invent new rule IDs (`INSECURE-COOKIE`, `AUTH-BYPASS`, `WEAK-CRYPTO`, `DATA-IN-URL`, `OAUTH-MISCONFIG`, `SUPPLY-CHAIN`, `INFO-DISCLOSURE`, `DATA-AT-REST`...).
- If you detect an issue that does not match any rule 100%, MAP to the closest canonical rule (see the mapping table in [`../references/sub-agent-prompts.md`](../references/sub-agent-prompts.md#rule-id-discipline-critical--read-carefully)) and note the reason in the `issue` field.
- 1 line of code triggering 2 rules (e.g., IDOR + RACE) → create **2 separate findings**, each with 1 `rule_id`. Do not use comma-separated values.

### Step S3 — Cross-rule checks

Some rules need cross-file checking:

- **SLOPSQUATTING**: collect all import statements → check if package names are valid (npm/PyPI/Packagist). In an offline environment, use heuristics: names with lookalike characters (l/I, 0/O), unusual suffixes (e.g. `-js`/`-py`), or common typos (e.g., `requets` instead of `requests`).
- **OUTDATED-DEPENDENCY**: read `package.json` / `requirements.txt` / `go.mod` / `composer.json` / `Gemfile.lock` → check if versions exist in the list of known-vulnerabilities (rule will have a static list, no internet fetch).
- **IDOR + BROKEN-ACCESS-CONTROL**: need to read both route definitions and handlers to verify authz checks.
- **MASS-ASSIGNMENT**: need to read both model definitions and endpoint handlers.
- **CSRF**: check global middleware configurations (Express `csurf`, Laravel `VerifyCsrfToken`...) before flagging individual endpoints.

### Step S4 — Build PASSED list

For each applicable rule checked that **does not detect issues**, add to the PASSED list with a 1-line explanation of what was checked.

Rules that are **not applicable** (e.g., PHP rules in a pure Node repo) → do not include in the PASSED list.

### Step S5 — Determine verdict

| Findings | Verdict |
|---|---|
| ≥1 CRITICAL | FAIL |
| 0 CRITICAL, ≥1 HIGH | WARN |
| 0 CRITICAL, 0 HIGH | PASS |

MEDIUM/LOW do not affect the final verdict but are still rendered.

### Step S6 — Render report (v0.3+ verbose)

According to the template in [`../references/output-format.md`](../references/output-format.md). Use i18n strings from the `$LANG` file.

**Render order:**
1. Header
2. Verdict + description
3. CRITICAL section: **overview table + verbose blocks per finding** (Short description + Why dangerous + Attack scenario + Code before/after + Read more)
4. HIGH section: **overview table + medium blocks per finding** (Description + Impact + Code fix + Read more)
5. MEDIUM section (compact table, 1 row/finding)
6. LOW section (compact table, 1 row/finding)
7. PASSED section
8. Next steps
9. **Save notification + gitignore warning**
10. Footer
11. JSON summary (canonical EN, fenced ```json)

**Per-finding data to collect** (to render verbose):

When scanning, for each finding, besides `file`, `line`, `rule_id`, `severity`, `issue`, `fix`, the agent needs to collect:
- `short_desc` (1 line for the overview table)
- If CRITICAL: `why_dangerous` (1 paragraph), `attack_scenario` (numbered steps), `code_before` (actual code snippet from file), `code_after` (fixed snippet)
- If HIGH: `impact` (1 paragraph), `fix_code` (snippet with before→after comments)
- If MEDIUM/LOW: only `short_desc`

Source for `why_dangerous` + `attack_scenario`: rule file content (see "Intent" + "Search patterns" sections). The agent paraphrases for non-tech users, DO NOT copy raw blocks from rules.

### Step S7 — Output + Save (v0.3+)

1. **Print full report to stdout** (displayed to the user by Claude Code)
2. **Save same content to file** using Write tool:
   - Path: `reports/security/scan-<TIMESTAMP>.md` (prepared in SKILL.md Step 0)
   - Content IDENTICAL to stdout
3. **Print save notification** to stdout (after report, before JSON):
   ```
   📄 {msg_report_saved}: reports/security/scan-2026-05-13-143022.md
   ```
4. **If gitignore warning needed** (check from SKILL.md Step 0):
   ```
   ⚠️ {msg_gitignore_warning_title}: {msg_gitignore_warning_text}
   ```

NOTE: i18n keys `msg_report_saved` and `msg_gitignore_warning_*` are already defined in `references/i18n/{vi,en}.md`.

## Tips to reduce context burn

- **Read rule files once**, keep them in context throughout
- **Do not read a file twice** during the same scan — if you already read a file for rule X, reuse the context when checking rule Y
- **Grep first, Read after**: find hot spots using Grep (cheap), only Read when verification is needed
- **Skip aggressively**: if a file is read and has no suspicious patterns → mark as "scanned" and move on
- **Batch tools**: Grep once for multiple patterns if the tool supports it (e.g. regex alternation)

## Performance target

Typical SMALL repo (10-30 files):
- Tool calls: 30-80 (Grep + Read combined)
- Time: 30-60 seconds
- Context burn: ~30-50K tokens

If tool calls exceed 100 or context exceeds 80K tokens → consider switching to LARGE mode (main agent can re-route automatically).

## Quick verification

After rendering the report, double-check:
- [ ] Every finding has a specific file path + line number
- [ ] CRITICAL severity is used correctly for L1 → dangerous sink, no sanitization
- [ ] JSON summary at the end contains all fields according to schema
- [ ] PASSED list contains at least the applicable rules checked (no omissions)
- [ ] No hardcoded English/Vietnamese strings — used i18n keys
- [ ] **Every `rule_id` in findings is in the 21 canonical IDs** (no invented rules)
- [ ] **Counts sanity check**: `len(findings)` == `summary.critical + high + medium + low`
- [ ] If rendering `top_rules_by_count`: total count == `len(findings)` (no double-counting)
