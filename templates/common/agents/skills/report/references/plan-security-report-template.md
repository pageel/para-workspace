# 🛡️ Plan Security Audit Report: `[Plan Name / Target Version]`

> **Project:** `[Project Name]` | **Plan Path:** `[Plan Path]`  
> **Security Profile / Domain:** `[General Web / Healthcare (HIPAA) / FinTech (PCI-DSS) / Multi-Tenant SaaS / AI-Agent / Cloud Infrastructure / CLI]`  
> **Target Version:** `[Target Version]` | **Generated:** `[Date]`  
> **Security Verdict:** `[🟢 PASS / 🟡 WARN / 🔴 FAIL]`  
> **Compliance Standard:** `[🟢 Compliant / 🟡 Warnings Detected / 🔴 Non-Compliant]`  

---

## 🎯 1. Plan Scope & Trust Boundary Mapping

- **Feature Scope:** [Brief summary of plan objectives and technical scope]
- **Target Inventory:**
  - `[path/to/target/file.ts]` (API Endpoint / Component / Infrastructure / Module)
  - `[path/to/target/config.json]` (Configuration / Manifest / Environment Schema)
- **Data Flow Trust Classification (L1–L4):**
  - **L1 Untrusted Inputs:** [Public Web Forms, External API Requests, Untrusted Payloads, User Prompts, File Uploads]
  - **L2 Semi-Trusted Boundaries:** [Session Tokens, JWTs, DB Query Results, Cache Layers, Internal Queues]
  - **L3 Trusted Execution:** [Server-side Controllers, Business Logic, Validated Models]
  - **L4 Trusted System & Storage:** [Encrypted Databases, Environment Vaults, Cloud IAM, Private Storage]

---

## 🛡️ 2. Core Universal Security Baseline (OWASP Top 10 Alignment)

### 2.1 Secrets & Credential Protection (OWASP A07 / Hardcoded Secrets)
- **Status:** `[🟢 PASS / 🟡 WARN / 🔴 FAIL]`
- **Audit:** Verifies zero hardcoded production keys, private tokens, certificates, or database credentials. Requires environment vaults or generic placeholders.
- **Finding & Mitigation:** [Use generic placeholders or environment variable injection]

### 2.2 Authentication, Authorization & Session Management (OWASP A01 / Broken Access Control)
- **Status:** `[🟢 PASS / 🟡 WARN / 🔴 FAIL]`
- **Audit:** Verifies server-side Auth Guards, Role-Based Access Control (RBAC/ABAC), password hashing (scrypt/bcrypt), and secure session token handling across all routes.
- **Finding & Mitigation:** [Inject explicit Server-side Auth Guards and permission checks]

### 2.3 Input Validation, Sanitization & Injection Prevention (OWASP A03 / Injection)
- **Status:** `[🟢 PASS / 🟡 WARN / 🔴 FAIL]`
- **Audit:** Verifies all L1 untrusted inputs are validated via strict type schemas (Zod, JSON Schema) and parameterized queries to prevent SQLi, XSS, Command Injection, or Mass Assignment.
- **Finding & Mitigation:** [Enforce input schema validation and parameterized execution]

### 2.4 Transport Security & External Integration Fail-Safe (OWASP A02 / Cryptographic Failures)
- **Status:** `[🟢 PASS / 🟡 WARN / 🔴 FAIL]`
- **Audit:** Verifies HTTPS/TLS encryption for all network calls, API Webhook payload signatures, and `try-catch` fail-safe wrappers to prevent catastrophic cascading failures.
- **Finding & Mitigation:** [Enforce HTTPS transport, signature verification, and fail-safe handling]

### 2.5 Resource Quotas, Rate Limiting & Denial-of-Service Defense (OWASP A04 / Insecure Design)
- **Status:** `[🟢 PASS / 🟡 WARN / 🔴 FAIL]`
- **Audit:** Verifies rate limits, API quotas, request body size limits, and memory/concurrency bounds to prevent resource exhaustion or DoS attacks.
- **Finding & Mitigation:** [Inject Rate Limiting and quota trackers]

---

## 🧩 3. Project-Specific & Domain Security Extensions

> *Note: This section dynamically activates based on the active project profile or custom rules defined in `Projects/<project>/.agents/rules/security.md` or `.agents/skills/scan-sec/rules/custom/`.*

### 3.1 Data Privacy, Compliance & Regulatory Standards (HIPAA / GDPR / PCI-DSS / PII)
- **Status:** `[🟢 PASS / 🟡 WARN / 🔴 FAIL / ➖ N/A]`
- **Audit:** Verifies data isolation, PII/PHI redaction, anonymization, and regulatory compliance (e.g., patient data privacy, credit card tokenization).
- **Finding & Mitigation:** [Enforce PII redaction and local data isolation]

### 3.2 Tenant Isolation & Multi-Tenancy Security (Row-Level Security / RLS)
- **Status:** `[🟢 PASS / 🟡 WARN / 🔴 FAIL / ➖ N/A]`
- **Audit:** Verifies multi-tenant data boundaries, tenant ID filtering, Row-Level Security (RLS), and prevention of cross-tenant data leakage.
- **Finding & Mitigation:** [Inject tenant boundary checks on all queries]

### 3.3 AI Agent, LLM & Tool Execution Security (Prompt Injection & Execution Bounds)
- **Status:** `[🟢 PASS / 🟡 WARN / 🔴 FAIL / ➖ N/A]`
- **Audit:** Verifies LLM prompt injection guards, tool call parameter validation, sandbox boundaries, and token consumption caps.
- **Finding & Mitigation:** [Sanitize prompt inputs and enforce tool execution sandboxing]

### 3.4 Custom Domain Extension: `[Project Specific Category]`
- **Status:** `[🟢 PASS / 🟡 WARN / 🔴 FAIL / ➖ N/A]`
- **Audit:** [Custom audit description defined by project security contract]
- **Finding & Mitigation:** [Custom mitigation strategy]

---

## 📊 4. Security Finding & Risk Matrix

| # | Severity | Category | Target Location / Phase | Risk Impact & Attack Scenario | Remediation Action Plan |
|---|---|---|---|---|---|
| 1 | 🔴 Critical | HARDCODED-SECRET | `Phase 1.1` | Secret key committed in version control | Extract to environment variable vault |
| 2 | 🟡 Medium | INPUT-VALIDATION-MISSING | `Phase 2.1` | Untrusted payload passed to query | Enforce Zod schema & parameterized query |
| 3 | 🔵 Info | DOMAIN-EXTENSION-NOTE | `Phase 3.1` | Domain compliance recommendation | Implement audit logging & quota counter |

---

## 🚀 5. Extensible Security Remediation Checklist (Pre-Execution Gate)

### Core Universal Baseline Checklist
- [ ] Remove hardcoded secrets in code examples (use generic environment placeholders)
- [ ] Inject Server-side Auth Guards / RBAC Access Control on all protected endpoints & routes
- [ ] Validate untrusted L1 input with strict schemas (Zod/Type Guards) to prevent injection
- [ ] Wrap external API/Webhook integrations in `try-catch` fail-safe blocks with HTTPS transport
- [ ] Implement rate limiting and resource quota monitoring for external services

### Project-Specific & Domain Extension Checklist
- [ ] Enforce Data Isolation & Privacy Principles (Zero sensitive PII/PHI leak to untrusted third parties)
- [ ] Verify Tenant Boundaries / Row-Level Security (RLS) for multi-tenant architectures
- [ ] Apply Prompt Injection Defense & Tool Execution Boundaries for AI Agent modules
- [ ] Validate custom domain security rules defined in `Projects/<project>/.agents/rules/security.md`

---

## 💡 6. Verdict & Operational Next Steps

- **Security Verdict:** `[🟢 PASS (Approved) / 🟡 WARN (Approved with Warnings) / 🔴 FAIL (Blocked)]`
- **Operational Recommendation:**
  - **Option A (Passed / Approved):** Plan Security Approved ➔ Proceed with `/plan [project-name] dev`
  - **Option B (Remediation Required):** Update Plan tasks, apply remediation checklist & re-audit via `/scan-sec plan`
