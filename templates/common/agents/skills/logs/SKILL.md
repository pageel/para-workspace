---
name: Logs Audit Extensions
description: Sidecar data for /logs workflow — conditional audit templates loaded just-in-time when plan methodology requires specialized compliance checks.
source: user
---

# Skill: Logs Audit Extensions

> Sidecar Skill for the `/logs` workflow. Contains audit extension templates
> that the Agent loads **only when the session used a specialized plan template**
> (e.g., TDD plan → load TDD Compliance template).
>
> **Pattern:** Workflow = Logic → Sidecar Skill = Data Router.
> The `/logs` workflow instructs the Agent to read this skill at audit extension time.

## When to Load

- `/logs --deep` → Step 3: After base audit sections, check if session used a TDD plan → load `references/tdd-compliance.md`
- `/logs` (fast glance) → NOT needed (no extensions)

## Detection Logic

```text
IF active_plan exists in project.md:
  Read the plan file → check for "Methodology: Strict TDD" or plan filename contains "-tdd"
  OR check if plan template used TDD Cycle markers (🔴 RED / 🟢 GREEN)
  → IF match: load references/tdd-compliance.md and append to audit report
ELSE:
  Skip TDD compliance section
```

## References

| Resource | Relative Path | Description |
|:--|:--|:--|
| TDD Compliance Template | `references/tdd-compliance.md` | Audit template for verifying Red-Green-Refactor order from conversation log and git history |
| Transcript Parser | `scripts/parse-transcript.py` | Python script to parse Antigravity session transcript locally for tool counts, commands, and mutated files |

## Usage: Transcript Parser

When executing `/logs --deep` or verifying TDD/Drift compliance, the Agent can run this Python utility locally to extract structured statistics without flooding the token context window:

```bash
# Resolve and run from workspace root
python3 .agents/skills/logs/scripts/parse-transcript.py [path_to_transcript_or_directory]
```

> **Convention:** Data files live in `references/` (not `templates/`).
> This follows the Sidecar Skill convention formalized in v1.7.6.3.

## Extensibility

Future audit extensions can be added here following the same pattern:

| Plan Methodology | Detection Marker | Template (planned) |
|:--|:--|:--|
| TDD | `🔴 RED` / `🟢 GREEN` markers in plan | ✅ `tdd-compliance.md` |
| Spec-Driven | `/spec` reference in plan | ⏳ `spec-compliance.md` |
| Security-First | `SECURITY` harness guards | ⏳ `security-audit.md` |
