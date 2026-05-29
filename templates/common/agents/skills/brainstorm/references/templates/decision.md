# Brainstorm: [Topic]

> **Date:** YYYY-MM-DD | **Project:** [project-name]
> **Brainstorm:** `brainstorms/[topic].md` ← (if evolved from open brainstorm)
> **Research:** `docs/researches/[topic]-[YYYY-MM-DD].md` ← (only if Research extracted)

## Problem

[1-2 sentences describing the core problem or question]

## Options & Detailed Analysis

### Option 1: [Name]

**Concept:** [What this option does, 2-3 sentences]

**Pros:**
- [Advantage 1]
- [Advantage 2]

**Cons / Risks:**
- [Risk 1]
- [Risk 2]

**Deep Dive:** [Optional — technical detail, edge cases, implementation notes if the option is complex enough to warrant deeper analysis]

---

### Option 2: [Name]

**Concept:** [What this option does, 2-3 sentences]

**Pros:**
- [Advantage 1]
- [Advantage 2]

**Cons / Risks:**
- [Risk 1]
- [Risk 2]

**Deep Dive:** [Optional]

---

## Summary Comparison

| # | Option | Key Trade-off | Score |
|---|---|---|---|
| 1 | [Name] | [Pro vs Con] | |
| 2 | [Name] | [Pro vs Con] | |

## Decision

[Selected approach and rationale — or "Pending" if still incubating]

### Key Principles

1. ...
2. ...

## 🔍 Technical Impact & Blast Radius

- **Target Files:**
  - Create: `exact/path/to/new_file.ts`
  - Modify: `exact/path/to/existing_file.ts`
- **Graph Impact (if para-graph enabled):**
  - God Nodes affected: `node_id`
  - Blast Radius assessment: (callers, downstream impact)
- **Database Schema Changes:** (Migrations, new fields, index changes, backward compatibility check)
- **Complexity Rating:** [🟢 Low | 🟡 Medium | 🔴 High]

## ⚠️ Risks & Mitigations Matrix

| # | Identified Risk | Severity | Mitigation Strategy | Plan Mapped Phase |
|---|-----------------|----------|---------------------|-------------------|
| 1 | [e.g., Data loss during migration] | [High]   | [Take local backup via git before db push] | Phase 0/1         |

## 🧪 Test Strategy & TDD Recommendations

- **Testing Methodology:** [Unit Testing | Integration Testing | End-to-End Testing]
- **TDD Task Classification Proposal:**
  - `🧪 TDD` (Logic, algorithms, migrations): [Task names]
  - `📝 Standard` (Configs, UI views, docs): [Task names]
- **Mocking Strategy:** (APIs, third-party libraries needing mock)

## Next Steps

<!-- ⚠️ AGENT INSTRUCTION:
Agent MUST populate this section with the chosen next action(s).
Present ALL options to the user (from /brainstorm Step 5) before filling in.

Options menu to present:
  A. 📐 /plan [project] create  — Formalize into implementation plan (RECOMMENDED for decided brainstorms)
  B. 📥 /backlog add            — Create tasks directly if simple enough
  C. 📝 /spec [project] create  — Write structured specification before coding
  D. 🔴 /qa [project] [topic]   — Stress-test decision with Red Team review
  E. 🌱 Save to Seeds           — Incubate further in .beads/seeds.md
  F. 📄 Save as project doc     — Keep as reference in docs/
  G. 🎓 /learn                  — Extract reusable lesson for Areas/Learning/
  H. 📊 Extract to Research     — Standalone research document in docs/researches/

Agent MUST wait for user selection before proceeding.
Agent MUST NOT auto-transition to /plan or /spec without explicit user choice.
-->

1. ...
