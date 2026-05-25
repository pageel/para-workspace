# 🪝 Extracted Hooks: {{RESOURCE_NAME}}

> **Source:** `{{NAMESPACE}}`
> **Extraction Date:** {{DATE}}

<!-- ⚠️ AGENT INSTRUCTION: You MUST read `.para-workspace.yml` to get the user's preferred language (`preferences.language`). All generated text replacing the brackets [Agent: ...] MUST be translated into the user's preferred language. The section titles MAY remain in English if preferred. -->

## 1. Lifecycle Hooks Overview
- [Agent: Summarize the lifecycle hooks found in this resource. How does it leverage hooks to intercept tool execution, model invocation, or run-loop termination?]

## 2. Hooks Registry
### 2.1. [Agent: Hook/Plugin Name]
- **Original Location:** `[Agent: File path, e.g., plugins/my-plugin/hooks.json]`
- **Manifest Content (`hooks.json`):**
```json
[Agent: Raw hooks.json content]
```
- **Lifecycle Triggers:**
  - **PreToolUse:** [Agent: Explain what scripts run before tool use and which tools are targeted]
  - **PostToolUse:** [Agent: Explain what scripts run after tool use]
  - **PreInvocation / PostInvocation:** [Agent: Explain model call interception logic]
  - **Stop:** [Agent: Describe cleanup or diagnostic scripts run on run-loop termination]

## 3. Porting & Adaptation
- [Agent: Suggest how these lifecycle hooks can be registered in our current environment (e.g., using `hooks.json` or custom workflows) to automate policy enforcement, linting, or telemetry.]
