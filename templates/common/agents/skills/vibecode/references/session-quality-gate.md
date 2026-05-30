# Session Quality Gate Reference

> **Loaded by:** `/vibecode session` mode at Phase start.
> **Purpose:** Provides the mandatory Quality Gate template and auto-recommend logic
> for each Phase in a Dynamic Session Plan (DSP).

## Phase-Level Quality Gate Template

At the **start of every Phase** (before any code work), Agent MUST present the following gate to the user, complete all pre-code steps (brainstorm, QA), and obtain approval at the **Pre-Code Checkpoint (2f)**:

```
📋 PHASE [N] QUALITY GATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Goal: [Phase goal description]

Proposed quality tools for this phase:

  Pre-code (run BEFORE coding):
  ⚗️ /brainstorm   → [✅ Recommended | ⚪ Optional] — [Reason]
  📋 /qa           → [✅ Recommended | ⚪ Optional] — [Reason]

  During dev (activate WHILE coding):
  🧪 TDD Mode      → [✅ Recommended | ⚪ Optional] — [Reason]
  🔍 --graph       → [✅ Recommended | ⚪ Optional] — [Reason]
  🔒 --hardened    → [✅ Recommended | ⚪ Optional] — [Reason]

💡 Recommended flow: brainstorm → QA stress-test → then code with TDD + --graph
Select tools to activate: (all / pick / none)
```

**Rules:**
- Agent MUST present this gate for EVERY Phase, no exceptions.
- Agent MUST NOT skip the gate even if the task seems trivial.
- **MANDATORY CHECKPOINT:** After selecting and running pre-code tools, Agent MUST present the final proposed files/tasks for Phase N and get explicit User confirmation to proceed before starting coding.
- User has final say — Agent only recommends, never forces.
- If user says "none", Agent proceeds with Standard mode (code → verify → commit).

---

## Auto-Recommend Decision Table

| Tool | Recommend YES when | Recommend NO when |
|:--|:--|:--|
| **🧪 TDD** | Logic-heavy code, DB schema changes, API endpoints, business rules, data validation, state machines | Pure CSS/styling, config file changes, documentation |
| **🔍 --graph** | Blast radius ≥ 3 files, cross-module imports, refactoring shared utilities, changing function signatures | Single-file fix, adding new isolated file, docs |
| **⚗️ /brainstorm** | Architecture unclear, multiple valid approaches, new patterns not yet in codebase, trade-off decisions | Well-defined tasks, bug fix with clear root cause, routine CRUD |
| **📋 /qa** | Complex business logic, security-critical flows, edge cases likely, multi-step user journeys | Simple one-file changes, config updates, styling fixes |
| **🔒 --hardened** | Sensitive keyword detected (see registry below), security-critical code, auth flows | UI components, non-sensitive CRUD, styling |

### Combination Rules

- If `--hardened` is activated → TDD is **automatically recommended** (defense-in-depth).
- If `--graph` is activated → Agent runs `graph_impact_analysis` BEFORE presenting the gate
  (so blast radius data is available for the TDD/QA recommendation).
- If `/brainstorm` is activated → Agent runs a focused 3-turn brainstorm BEFORE coding
  starts. Result is logged in the Phase's `⚗️ Brainstorm Log` section.
- If `/qa` is activated → Agent runs a stress-test review (probing questions across logic,
  security, feasibility dimensions) BEFORE coding. Issues found feed into implementation.
- **Execution order:** `/brainstorm` → `/qa` → then code with TDD + `--graph` + `--hardened`.

---

## Sensitive Keywords Registry

Agent scans the user's chat message (case-insensitive) against these keywords.
If ANY match → auto-recommend `--hardened` in the Quality Gate.

```
# Authentication & Authorization
password, auth, login, logout, sign.?in, sign.?up, sign.?out,
token, JWT, OAuth, 2FA, MFA, TOTP, OTP,
session, cookie, CORS, CSRF,
permission, role, admin, rbac, acl,

# Cryptography
crypto, hash, encrypt, decrypt, HMAC, bcrypt, argon2,
salt, pepper, key.?pair, private.?key, public.?key,
secret, API.?key, API.?secret,

# Data Safety
delete.?user, xoá.?user, remove.?account, purge,
PII, GDPR, data.?export, data.?retention,
sanitize, escape, injection, XSS, SQL.?injection,

# Financial
payment, billing, invoice, subscription,
stripe, paypal, checkout, refund,
webhook, callback.?url,

# Rate Limiting & Abuse
rate.?limit, throttle, brute.?force, captcha,
IP.?block, ban, blacklist, allowlist
```

> **Matching:** Use regex (case-insensitive). Dot (`.`) between words means
> "any single character" to catch variants like `sign_in`, `sign-in`, `signin`.
>
> **Important:** Keyword match only triggers a RECOMMENDATION.
> The user always has the final decision. False positives are acceptable
> because they only add a suggestion line — they don't block work.

---

## Intent Detection Keywords (JIT Phase Creation)

When running in DSP Draft mode (no topic), Agent listens for action intent
in user messages. These keywords trigger a Phase creation proposal:

```
# Vietnamese action verbs
thêm, sửa, fix, tạo, xóa, xoá, refactor, di chuyển, chỉnh,
nâng cấp, cập nhật, thay đổi, chuyển đổi, tối ưu, dọn dẹp,

# English action verbs
add, create, remove, delete, update, change, modify, fix, refactor,
migrate, move, rename, optimize, clean, upgrade, implement, build,
extract, split, merge, convert
```

> **Rules:**
> - Agent MUST ask user confirmation before creating a Phase.
> - Agent MUST NOT create Phases from questions or discussions (only action requests).
> - If unsure whether user wants action or discussion → ASK, don't assume.

---

## DSP Naming Convention

### With topic (existing behavior)

```
v[ver/1.x.x]-[YYYY-MM-DD]-session-[topic].md
Example: v1.x.x-2026-05-27-session-refactor-auth.md
```

### Without topic (DSP Draft — new behavior)

```
v1.x.x-session-YYYY-MM-DD-NN.md
Example: v1.x.x-session-2026-05-27-01.md
         v1.x.x-session-2026-05-27-02.md (second session same day)
```

**Sequence detection:**
```bash
# Agent scans existing files to determine NN
ls artifacts/plans/v1.x.x-session-$(date +%Y-%m-%d)-*.md 2>/dev/null \
  | grep -oP '\d{2}(?=\.md$)' \
  | sort -n | tail -1
# If empty → 01, else → max + 1 (zero-padded)
```
