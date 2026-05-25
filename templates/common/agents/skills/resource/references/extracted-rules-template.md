# 🛡️ Extracted Rules & Governance: {{RESOURCE_NAME}}

> **Source:** `{{NAMESPACE}}`
> **Extraction Date:** {{DATE}}

<!-- ⚠️ AGENT INSTRUCTION: You MUST read `.para-workspace.yml` to get the user's preferred language (`preferences.language`). All generated text replacing the brackets [Agent: ...] MUST be translated into the user's preferred language. The section titles MAY remain in English if preferred. -->

## 1. Governance Overview
- [Agent: Summarize the agent behavior, safety guardrails, and compliance standards enforced in the resource codebase.]

## 2. Behavioral Constraints & Rules
### 2.1. [Agent: Rule Category/Name]
- **Original Location:** `[Agent: File path, e.g., .agents/rules/agent-behavior.md]`
- **The Constraint:** [Agent: Describe the rule's constraint on the agent's behavior (e.g., English-First, no destructive edits).]
- **Safety Mechanism:** [Agent: How is this rule enforced? (e.g., prompt injections, pre-flight checks, file-level guards).]

### 2.2. [Agent: Rule Category/Name]
- **Original Location:** `[Agent: File path]`
- **The Constraint:** [Agent: Description]
- **Safety Mechanism:** [Agent: Description]

## 3. File Guards & Invariants
- [Agent: Identify any specific file-level guards or system invariants designed to prevent structural drift or accidental file mutations.]

## 4. Porting & Adaptation
- [Agent: Suggest which of these rules should be integrated into our PARA global rules (`.agents/rules/`) or project rules.]
