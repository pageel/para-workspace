---
title: "Security & Architecture Assessment: [Topic]"
status: [Proposed | Completed]
date: YYYY-MM-DD
target_sysdesign: "../../sysdesigns/sysdesign-[topic].md"
assessor: [Assessor Name]
health_score: [X]/100
---

# Security & Architecture Assessment: [Topic]

> **Date**: YYYY-MM-DD  
> **Target Version**: vX.Y.Z  
> **Scale**: [small | medium | large | enterprise]  
> **Assessor**: [Name / Role]

---

## 1. Executive Summary

[Provide a high-level summary of the architectural and security assessment, overall system health, and critical findings.]

---

## 2. Risk & Vulnerability Matrix

| ID | Risk Category | Component | Severity | Description | Remediation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **R-01** | [e.g. Rate Limiting] | [Component Name] | [🔴 High | 🟡 Medium | ⚪ Low] | [Short description of the risk/flaw] | [Short description of the fix] |

---

## 3. Deep Dive Analysis & Remediation

### 3.1. [Risk Name (e.g. Rate Limit Bottleneck)]
*   **Detailed Risk Analysis:** [Under-the-hood explanation of why this is a risk, scenario description, and impact.]
*   **Detailed Remediation Plan:** [Technical architecture or code change design to solve the problem.]

### 3.2. [Risk Name (e.g. Stored XSS via Uploads)]
*   **Detailed Risk Analysis:** [...]
*   **Detailed Remediation Plan:** [...]

---

## 4. Architectural Sign-off

[Sign-off log or conditions required to resolve the risks before moving to spec or implementation phase.]
