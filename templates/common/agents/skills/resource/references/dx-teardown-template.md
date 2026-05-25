# 🛠️ DX Teardown: {{RESOURCE_NAME}}

> **Source:** `{{NAMESPACE}}`
> **Analysis Date:** {{DATE}}

<!-- ⚠️ AGENT INSTRUCTION: You MUST read `.para-workspace.yml` to get the user's preferred language (`preferences.language`). All generated text replacing the brackets [Agent: ...] MUST be translated into the user's preferred language. The section titles MAY remain in English if preferred. -->

## 1. DX Overview
- [Agent: Provide a high-level summary of the Developer Experience (DX). Is the CLI intuitive? Are the error messages helpful?]

## 2. CLI Design & Ergonomics
- **Command Structure:** [Agent: Analyze how they structure their commands (e.g., nested subcommands, flag naming conventions).]
- **Visual Feedback:** [Agent: Note any use of colors, progress bars, spinners, or interactive prompts.]
- **Help Documentation:** [Agent: How good is their `--help` output?]

## 3. Error Handling & Recovery
- **Error Messages:** [Agent: Show examples of how they format errors. Do they provide actionable solutions or just stack traces?]
- **Graceful Degradation:** [Agent: How does the tool behave when the network fails or dependencies are missing?]

## 4. Code & Architecture Insights
- **Key Modules:** [Agent: Which files handle the CLI and DX logic? Provide exact paths.]
- **Libraries Used:** [Agent: E.g., Commander.js, Chalk, Inquirer, Rich, Click.]

## 5. Adoption Strategy
- [Agent: What specific DX features should we copy for our PARA tools (like the `para` CLI or `para-graph`)?]
