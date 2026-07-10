# Specification Index & CSA Audit Registry

> **Project:** [Project Name] | **Standards:** Convergent Specification Architecture (CSA)
> This document acts as the registry for all project specifications and tracks CSA compliance audits over time.

---

## 📂 Specification Registry

Below is the list of all specification documents for the project, categorized and managed by their CSA compliance status:

| Key | Specification File | Created Date | Version | Business Status | CSA Status | CSA Anchors | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `S1` | [spec-example.md](spec-example.md) | YYYY-MM-DD | `v0.1.0` | ✅ Approved | ✅ CSA-ified | 4 anchors | Synced 100% (YYYY-MM-DD) |

> 💡 **CSA Classification Tiers:**
> *   `✅ CSA-ified`: Specification file contains HTML anchors `<span id="csa-..."></span>` for automated audit compliance.
> *   `⚠️ Uncurated`: Legacy specification file lacking anchors. Needs audit planning.
> *   `❌ Deprecated`: Obsolete or replaced specification file.

---

## 📈 CSA Audit Registry

Historical log of CSA compliance audit results across project versions:

| Audit Date | Version | Spec Coverage | Doc Coverage | Dangling Errors | Operator | Associated Plan |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| YYYY-MM-DD | `0.1.0` | **100%** (4/4) | **50%** (2/4) | 0 | Agent Name | [plan-link](plan-link) |

## ⚙️ CSA Standards Reference

For CSA anchor design standards, naming schemas, and integration workflows, please refer to the global rule [.agents/rules/csa.md](file:///.agents/rules/csa.md) or the CSA Skill documentation [.agents/skills/csa/SKILL.md](file:///.agents/skills/csa/SKILL.md).
