---
description: Run security scanner for vibe code (scan-sec integration)
source: custom
---

# /scan-sec [scope]

<!-- ⚠️ OPERATIONAL AUTHORITY — Delegate process logic to sidecar skill (SKILL.md) -->

> **Goal:** Scan and detect over 20 common vulnerability groups (SQL Injection, Hardcoded Secrets, XSS...) in source code.
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

## Usage

```bash
/scan-sec                       # Scan entire repo (default)
/scan-sec uncommitted           # Scan uncommitted changes
/scan-sec staged                # Scan staged files only
/scan-sec project <name>        # Scan a specific project (e.g., project app-tinycrm)
/scan-sec project <name> --graph # Scan project and assess blast radius using code graph
/scan-sec resource <name>       # Scan a specific resource (e.g., resource scan-sec)
/scan-sec area <name>           # Scan a specific area (e.g., area Learning)
```

Optional arguments:
- Language selection: `lang=en` (English) or `lang=vi` (Vietnamese).
- Graph integration: `--graph` (runs graph blast-radius analysis, requiring `para-graph` database).

---

## Execution Steps

### 0.5. Build Graph (if --graph)
If the arguments contain `--graph`:
- For projects, run: `/para-graph build [project-name]`
- For resources, run: `/para-graph build @resources/[namespace]`
to ensure the code-knowledge graph database is up-to-date.

### 1. Initialize Sidecar Skill
Read the sidecar routing table and configuration:
- Load `.agents/skills/scan-sec/SKILL.md` to identify parameters and rules.

### 2. Parse & Gather Files
Execute the parsed args helper script:
```bash
bash .agents/skills/scan-sec/scripts/parse-args.sh "$ARGUMENTS"
```

### 3. Run Vulnerability Audit & Graph Analysis
Follow the steps in `.agents/skills/scan-sec/SKILL.md` to:
- Detect the repository's primary language.
- Run in **SMALL Mode** (inline) or **LARGE Mode** (sequential chunking).
- Trace data flow using **L1-L4 trust classification** (Reasoning-First).
- If `--graph` is active, call `graph-analyzer.js` to enrich findings with caller count, Mermaid call tree, and suggested remediation points.
- **Pattern Verify (Step G, para-graph §4.2):** After graph analysis, run `grep_search` to cross-validate inline pattern counts (e.g., `details: err.message`, `console.log(error)`) against graph estimates. Log discrepancies: `⚠️ Pattern Verify: Graph estimated N files, grep verified M files`.

### 4. Output Results
Generate a bilingual markdown report and save to:
📁 `reports/security/` or `artifacts/reports/security/` subdirectory of the target.
Print the final summary and Verdict (PASS/WARN/FAIL).

### 5. Next Steps & Actionable Workflows
After presenting the report, the Agent MUST actively propose the next operational step based on the scan results:
- **Propose `/brainstorm`**: If findings require architectural analysis or secure design decisions (e.g., refactoring auth or session layers).
- **Propose `/plan create`**: If there are multiple findings of HIGH/CRITICAL severity, to structure the security remediation into clear phases.
- **Propose `/vibecode`**: To jump straight into code remediation, loop-verify fixes, and run security verification.

> ⛔ **HARNESS GUARD (No Auto-Remediation):** The Agent **MUST NOT** edit or modify any codebase file to fix vulnerabilities during or after the scan without explicit user request. The scanner's role is strictly diagnostic. All fixes must be proposed as code snippets first, and executed only when approved by the user.
