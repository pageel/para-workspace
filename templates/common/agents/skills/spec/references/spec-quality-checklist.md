# Spec Quality Checklist

> **Version:** 1.0.0 | **Last reviewed:** 2026-04-22
> Checklist for validating spec quality — used by `/spec create` Gate 1
> and `/spec review`. Inspired by addyosmani/agent-skills spec-driven-development.

---

## I. Assumption Surfacing

| # | Check | Rule |
|:--|:--|:--|
| A1 | **Assumptions listed** | MUST have explicit assumption list before spec content |
| A2 | **User confirmed** | MUST have user confirmation on assumptions before proceeding |
| A3 | **No silent defaults** | MUST NOT silently fill in ambiguous requirements |
| A4 | **Tech stack sourced** | SHOULD pull tech assumptions from `project.md`, not guess |
| A5 | **Implicit requirements** | SHOULD identify at least 1 implicit requirement user didn't state |

---

## II. Core Areas Coverage

| # | Check | Rule |
|:--|:--|:--|
| C1 | **Objective** | MUST define what, why, who, and what success looks like |
| C2 | **Commands** | MUST list full executable commands (not just tool names) |
| C3 | **Project Structure** | MUST describe where source, tests, and docs live |
| C4 | **Code Style** | MUST include at least 1 real code snippet showing conventions |
| C5 | **Testing Strategy** | MUST define framework, locations, coverage, and test levels |
| C6 | **Boundaries** | MUST define all three tiers: Always / Ask First / Never |

---

## III. Success Criteria Quality

| # | Check | Rule |
|:--|:--|:--|
| S1 | **Specific** | MUST be testable — no vague "should work well" |
| S2 | **Measurable** | SHOULD include numbers (latency, coverage %, count) |
| S3 | **Reframed** | SHOULD translate vague requirements into concrete conditions |
| S4 | **Verifiable** | MUST be possible to check "done" objectively |

---

## IV. Boundaries Quality

| # | Check | Rule |
|:--|:--|:--|
| B1 | **Always tier** | MUST have at least 2 "Always do" rules |
| B2 | **Ask first tier** | MUST have at least 1 "Ask first" rule |
| B3 | **Never tier** | MUST have at least 2 "Never do" rules |
| B4 | **Secrets prohibition** | MUST include "Never commit secrets" or equivalent |
| B5 | **Actionable** | SHOULD be specific enough that Agent can self-enforce |

---

## V. Document Structure

| # | Check | Rule |
|:--|:--|:--|
| D1 | **Template followed** | MUST follow the feature-spec template structure |
| D2 | **Naming convention** | MUST be `spec-YYYY-MM-DD-topic-slug.md` |
| D3 | **Status field** | MUST have Status in header (Draft/Approved/Updated/Archived) |
| D4 | **Open questions** | SHOULD list unresolved questions (not hide them) |
| D5 | **Change log** | SHOULD include change log section for living document updates |

---

## VI. Gate Compliance

| # | Check | Rule |
|:--|:--|:--|
| G1 | **Gate 1 passed** | MUST have user approval on spec before proceeding to plan |
| G2 | **Gate 2 passed** | MUST have user approval on plan before proceeding to tasks |
| G3 | **Gate 3 passed** | MUST have user approval on tasks before implementation |
| G4 | **No gate skipping** | MUST NOT skip any gate, even for "simple" specs |

---

## Usage

### In `/spec create` (Gate 1 self-check):

Agent runs checks A1-A5, C1-C6, S1-S4, B1-B5, D1-D5 BEFORE presenting
the spec to the user. Fix violations before showing the draft.

### In `/spec review`:

Run the full checklist on an existing spec. Report results:

```
SPEC VALIDATION: [name]
A1-A5: Assumptions     — 5/5
C1-C6: Core Areas      — 6/6
S1-S4: Success Criteria — 3/4 (S2: no measurable targets)
B1-B5: Boundaries      — 5/5
D1-D5: Document        — 4/5 (D5: missing change log)
G1-G4: Gates           — 4/4
Result: 27/29 pass | 2 warnings
```
