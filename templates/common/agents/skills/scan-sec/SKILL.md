---
name: scan-sec
description: Use when scanning code for security vulnerabilities. Use when user says "scan security", "kiểm tra bảo mật", "security audit", "review security", or invokes `/scan-sec`. For large scans (>20 main-language files OR >30 total OR >14 days) processes chunks sequentially. Outputs bilingual reports (vi/en).
---

# scan-sec — Security Scanner for Vibe Coders (Antigravity variant)

Scan security vulnerabilities for AI-generated code (vibe code). This skill checks for the 21 most common vulnerabilities of vibe code, inheriting the SMALL/LARGE mode architecture, generalized cross-language + deep-dive for Go/PHP/Python/TypeScript/.NET.

> **Platform:** Google Antigravity. This version uses **sequential chunking** to preserve portability — ~3× slower but identical output.

## Resource Router

| Resource | Relative Path | Description |
| :-- | :-- | :-- |
| Arguments Parser | `scripts/parse-args.sh` | Main script to parse scope arguments and gather target files |
| Language Detection | `references/language-detection.md` | Language detection guide to find primary repo language |
| Output Template | `references/output-format.md` | Layout template for report generation |
| Data Flow Classification | `references/data-flow-classification.md` | Data flow mapping (L1-L4) guidelines |
| Rules directory | `rules/` | Directory containing all 21 generic and specific rule files |



## Invocation

In the Antigravity Agent Manager chat box:

- **Auto-trigger:** speak naturally — *"scan security for this repo"*, *"check security"*, *"security audit"*. Antigravity automatically matches the description and loads the skill.
- **Explicit slash command:** if the workspace contains `.agents/workflows/scan-sec.md`, type `/scan-sec` to invoke.

| Argument | Scope | Description |
|---|---|---|
| (no args) | **Entire repo** | Default — scan the entire repository |
| `all` | Entire repo | Explicit alias |
| `uncommitted` / `diff` | Uncommitted changes | Staged + unstaged changes |
| `staged` | Staged files only | Pre-commit scan |
| `project <name>` | Specific project | Scan files in `Projects/<name>` |
| `resource <name>` | Specific resource | Scan files in `Resources/<name>` (or Areas/Learning/Resources) |
| `area <name>` | Specific area | Scan files in `Areas/<name>` |

**Output Language Selection:** `lang=vi` / `--vi` (default) or `lang=en` / `--en`.

Examples:
```
scan security uncommitted lang=en
/scan-sec project app-tinycrm
audit security resource para-workspace lang=vi
```


---

## CRITICAL: How to use this skill (for LLM agent)

**The bash/grep patterns in the rule files are EXAMPLES, NOT commands to be run literally.**

### Principles

1. **Reason, do not just pattern-match** — Understand the security intent behind each check, do not just search for strings.
2. **Use appropriate tools** — Antigravity has built-in file/grep tools (read, grep, search). Do not call raw shell grep/find when native tools are available.
3. **Read complete context** — When finding a pattern, read the surrounding function to understand if it is a real vulnerability.
4. **Data flow trust levels** — A string formatting query is only dangerous if the interpolated data is **L1 (untrusted)**.
5. **No Auto-Remediation (Strict Guardrail)** — The Agent **MUST NOT** modify, edit, or refactor any codebase file to fix vulnerabilities during or after the scan without explicit user request. The scanner is strictly a diagnostic tool. Remediation is user-led.

### Data Flow Classification (L1–L4)

| Level | Source | Trust | Example |
|---|---|---|---|
| L1 | User input | **UNTRUSTED** | `req.body`, `$_GET`, `request.params`, HTTP headers, file uploads |
| L2 | Database | Semi-trusted | Values from DB whose origin was user input |
| L3 | Internal code | Trusted | Hardcoded strings, config keys, computed values |
| L4 | System | Trusted | Env vars, internal file paths, framework constants |

**Key insight:** `f"SELECT ... {x}"` is SAFE if `x` is L3+. It is CRITICAL if `x` is L1 without parameterization.

Refer to: [`references/data-flow-classification.md`](references/data-flow-classification.md).

---

## Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│      scan-sec WORKFLOW (Antigravity — Sequential)                   │
├─────────────────────────────────────────────────────────────────────┤
│  [Step 0] Parse args → scope + lang                                  │
│  [Step 1] Gather files (git)                                         │
│  [Step 2] Detect primary code language                               │
│  [Step 3] Route by size:                                             │
│           SMALL (≤20 main, ≤30 total, ≤14d) → inline                 │
│           LARGE (exceeding threshold)        → sequential chunking   │
│  [Step 4] Apply 21 rules (generic + lang overlay)                    │
│  [Step 5] Generate bilingual report + save to reports/security/      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Step 0: Parse Arguments

Offload CLI argument parsing and file gathering to the helper script:

```bash
# Execute arguments parser script
bash .agents/skills/scan-sec/scripts/parse-args.sh "$ARGUMENTS"
```

**Note:** Skill works on non-git folders. Default scope (`all`) uses `find` instead of `git ls-files`. Git-specific scopes (`staged`, `uncommitted`, `commit within`, `commit id`, `pr id`) require git.


---

## Step 1: Load i18n Strings

Read i18n file corresponding to `$LANG`:
- `lang=vi` → read [`references/i18n/vi.md`](references/i18n/vi.md)
- `lang=en` → read [`references/i18n/en.md`](references/i18n/en.md)

The i18n file contains key-value pairs for all user-facing strings. All report text must come from i18n, DO NOT hardcode.

**Strings NEVER translated:** rule ID, file path, code snippet, command name.

---

## Step 2: Detect Primary Code Language

Read [`references/language-detection.md`](references/language-detection.md). Summary:

1. Count extensions in file list: `.go`, `.py`, `.php`, `.js`, `.ts`, `.jsx`, `.tsx`, `.rb`, `.java`, `.rs`, `.cs`, `.csproj`, `.sln`
2. Primary lang = language representing ≥30% of total files
3. If `rules/languages/<lang>/` exists → load overlay; otherwise → use generic rules only
4. Multi-lang repo (e.g. Go backend + Vue frontend) → load both overlays

**Currently supported language overlays:** `go`, `php`, `typescript` (JS+TS combined), `python`, `dotnet`.

---

## Step 3: Route by Size

| Condition | Threshold | Mode |
|---|---|---|
| Primary language files | ≤20 | SMALL |
| Primary language files | >20 | **LARGE** |
| Total files | ≤30 | SMALL |
| Total files | >30 | **LARGE** |
| Timespan (scope `commit within`) | ≤14 days | SMALL |
| Timespan | >14 days | **LARGE** |

If ANY condition goes to LARGE → use LARGE mode.

- **SMALL mode:** Read [`workflows/small-review.md`](workflows/small-review.md) — inline scan.
- **LARGE mode:** Read [`workflows/large-review-sequential.md`](workflows/large-review-sequential.md) — chunk + process **sequentially**.

---

## Step 4: Apply Rules

For each rule in `rules/generic/` (01-21):

1. Read rule file → understand intent, severity, search patterns.
2. Apply to files in scope.
3. For each match: trace data flow (L1-L4) to classify if it is a real vulnerability.
4. If a rule with the same `id` exists in `rules/languages/<detected-lang>/`, the **specific rule overrides the generic one**.

---

## Step 4.5: Graph Blast Radius & Mitigation Analysis (if `--graph`)

If `parse-args.sh` outputs `Use Graph: true`, execute blast radius analysis for each finding (MEDIUM severity and above):

1. **Build Graph:** Run `/para-graph build [project-name]` (or `/para-graph build @resources/[namespace]` for resources) to ensure the graph database is fresh.
2. **Execute Graph Analyzer:** Run the analyzer script to query the call tree:
   ```bash
   node .agents/skills/scan-sec/scripts/graph-analyzer.js --project <project_path> --file <relative_file_path>
   ```
3. **Parse Output:** Extract `callerCount`, `severityBoost`, `mermaid`, and `remediationPoints`.
4. **Boost Severity:** If `severityBoost` is elevated (e.g. `HIGH` or `CRITICAL`), upgrade the finding's severity level.
5. **Add to Finding Details:** Keep the Mermaid call graph and remediation points in memory to embed them into the final report.

---

## Step 5: Generate Report

Refer to template in [`references/output-format.md`](references/output-format.md). Core rules:

**Verbose level by severity:**
- **CRITICAL** → overview table + full verbose block per finding
- **HIGH** → overview table + medium block per finding
- **MEDIUM** → compact table only (or full block if `--graph` contains blast radius)
- **LOW** → compact table only

**OWASP Mapping & Packaged References:**
- For each finding, read `references/owasp/mappings.json` to resolve its corresponding OWASP Top 10 category.
- Display the resolved OWASP category tag next to the rule name (e.g., `HARDCODED-SECRET [OWASP A02/A05]`).
- Provide local relative/absolute `file:///` links to the local markdown documents packaged under `references/owasp/2021/en/` so users can read the detailed official guides offline.

**Graph Blast Radius & Remediation (if `--graph`):**
- Display `Caller Count: N` next to the finding file path.
- Include a **"Blast Radius (Upstream Callers)"** sub-section showing the Mermaid flowchart.
- Include a **"Suggested Remediation Points"** list detailing where sanitization or validation controls should be placed.

**Layout:**
1. Header block (scope, file count, primary lang, mode, date, lang code)
2. VERDICT + 1-line description
3. CRITICAL section
4. HIGH section
5. MEDIUM section
6. LOW section
7. PASSED CHECKS
8. Next steps
9. Save notification
10. Gitignore warning (if needed)
11. Footer + disclaimer
12. JSON summary (canonical EN)

**Save-to-file:** write the ENTIRE report (identical to stdout) to the `Report file` path printed by the `parse-args.sh` script (e.g., `reports/security/scan-<timestamp>.md` or `artifacts/reports/security/scan-<timestamp>.md`) using Antigravity write tool.

Then print 1-2 summary lines to stdout:
```
📄 {msg_report_saved}: <Report file path>
⚠️ {msg_gitignore_warning_title}: {msg_gitignore_warning_text}
```

All headers, labels, and verdicts must come from the i18n file loaded in Step 1.

**Next Steps & Actionable Workflows:**
- If the scan fails (`Verdict: FAIL` or `WARN` due to findings), the Agent **MUST** actively suggest that the user initiate a follow-up workflow:
  - `/brainstorm`: To discuss design trade-offs and structural changes.
  - `/plan create`: To design a security mitigation plan.
  - `/vibecode`: To fix and verify vulnerabilities in sandbox mode.

---

## Verdict Logic

| Condition | Verdict |
|---|---|
| Has ≥1 CRITICAL | **FAIL** |
| No CRITICAL, has ≥1 HIGH | **WARN** |
| No CRITICAL, no HIGH | **PASS** |

WARN is not an approval. The report should specify HIGH issues to be fixed before production.

---

## Differences with Claude Code variant

| Aspect | Claude Code | Antigravity (this file) |
|---|---|---|
| LARGE mode | Parallel sub-agents (3 concurrent) | Sequential chunking (1 chunk at a time) |
| Resume on interrupt | TodoWrite tasks | `.security-scan-tmp/findings-*.md` (skip chunk if already processed) |
| Trigger | Slash command Claude | Auto-trigger by description + optional `.agents/workflows/` |

---

## Reasoning-First (Core)

**DO:**
- Read the full function context when finding a pattern, DO NOT flag immediately.
- Trace data flow: input → transformations → sink.
- Classify L1-L4 before assigning CRITICAL.
- Read rule file before applying.

**DON'T:**
- Run bash command examples literally.
- Flag all `fmt.Sprintf` as SQLi (only flag if data is L1 and not parameterized).
- Skip context (one line of grep is not enough to decide a verdict).

**Goal is to understand security, not just count patterns.**
