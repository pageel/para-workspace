# Skill Quality Checklist

> **Version:** 1.0.0 | **Last reviewed:** 2026-04-06
> Checklist for evaluating `SKILL.md` quality — used by `/para-skill validate` and `/para-skill add`.
> Distilled from open-source research and practical experience.

---

## I. PARA Structure Compliance

| #   | Check                       | Rule                                                            |
|:----|:----------------------------|:----------------------------------------------------------------|
| P1  | **YAML Frontmatter**        | MUST have `name`, `description`, `version` in frontmatter       |
| P2  | **Folder Structure**        | MUST be in `.agents/skills/[skill-name]/SKILL.md`               |
| P3  | **Skills Index**            | MUST have matching entry in `.agents/skills.md` (trigger index) |
| P4  | **Folder Name**             | MUST use `kebab-case` for skill folder name                     |
| P5  | **Version Format**          | MUST use SemVer (`"1.0.0"`)                                     |

---

## II. Description Quality

The `description` field in YAML frontmatter is the primary trigger mechanism.

| #   | Check                           | Rule                                                         |
|:----|:--------------------------------|:-------------------------------------------------------------|
| D1  | **Clear trigger context**       | MUST describe WHEN the skill activates, not just WHAT it does |
| D2  | **Pushy — encourage usage**     | SHOULD include phrases like "even if the user doesn't explicitly mention X, consult this skill for Y" |
| D3  | **Sufficient length**           | SHOULD be >= 20 words (too short = Agent won't know when to use it) |
| D4  | **Not too generic**             | MUST NOT use vague descriptions like "A useful skill for various tasks" |

### Examples

**Good:**
```yaml
description: >
  Project-specific conventions, naming patterns, quality standards, and plan
  review checklist. Use this skill whenever creating plans, naming files,
  writing docs, or reviewing plan quality for this project. Even if the user
  doesn't mention "conventions", consult this skill for any project-level decision.
```

**Bad:**
```yaml
description: "Skill about project conventions"
```

---

## III. Content Structure

| #   | Check                          | Rule                                                          |
|:----|:-------------------------------|:--------------------------------------------------------------|
| C1  | **Reasonable length**          | SHOULD be under 500 lines. If longer, split into `references/` |
| C2  | **Progressive Disclosure**     | MUST organize in 3 tiers: (1) Frontmatter ~100 words, (2) SKILL.md body <500 lines, (3) references/ when needed |
| C3  | **Clear references**           | If `references/` exists, MUST document in SKILL.md: when to read which file |
| C4  | **Table of Contents**          | If references/ > 300 lines, SHOULD include a TOC at file top  |

---

## IV. Writing Style

| #   | Check                                | Rule                                                     |
|:----|:-------------------------------------|:---------------------------------------------------------|
| W1  | **Explain "Why" over "MUST"**        | SHOULD explain reasoning instead of overusing mandatory keywords. Use theory-of-mind: why this matters so AI understands intrinsically |
| W2  | **Imperative form**                  | SHOULD write instructions as commands: "Read the config file" not "You should read the config file" |
| W3  | **Input/Output examples**            | SHOULD include at least 1 concrete example (Input → Output) so AI understands the expected format |
| W4  | **Not too narrow**                   | SHOULD be general enough to apply across situations, not just one specific case |
| W5  | **No harmful instructions**          | MUST NOT contain instructions for exploiting vulnerabilities, exfiltrating data, or surprising the user |

---

## V. Bundled Resources

| #   | Check                          | Rule                                                          |
|:----|:-------------------------------|:--------------------------------------------------------------|
| B1  | **scripts/ for repeated logic**| SHOULD put executable code in `scripts/` instead of inline in SKILL.md |
| B2  | **references/ for domain docs**| SHOULD organize supplementary docs by domain/framework (e.g., `references/aws.md`) |
| B3  | **assets/ for static files**   | SHOULD put template files, icons, fonts in `assets/`          |

---

## VI. Test Readiness

| #   | Check                          | Rule                                                          |
|:----|:-------------------------------|:--------------------------------------------------------------|
| T1  | **Suggested test prompts**     | SHOULD include 2-3 test prompts at end of SKILL.md or in separate file |
| T2  | **Clear expected output**      | SHOULD describe expected result for each test prompt           |
| T3  | **Testability classification** | SHOULD note output type: `objective` (auto-verifiable) or `subjective` (vibe check) |

---

## VII. Test Mode Readiness

| #   | Check                          | Rule                                                          |
|:----|:-------------------------------|:--------------------------------------------------------------|
| TM1 | **Test Mode section exists**   | MUST have "## 🧪 Test Mode (Sandbox Override)" section        |
| TM2 | **Containment path defined**   | MUST specify sandbox output directory                         |
| TM3 | **Report template included**   | MUST describe `test-report.md` structure                      |

---

## Usage

### In `/para-skill validate [name]`:

Run the full checklist in read-only mode. Report results:
```
SKILL VALIDATION: [name]
P1-P5: PARA Structure     — 5/5
D1-D4: Description       — 3/4 (D2: not pushy enough)
C1-C4: Content Structure  — 4/4
W1-W5: Writing Style      — 4/5 (W3: missing example)
B1-B3: Bundled Resources  — 3/3
T1-T3: Test Readiness     — 3/3
TM1-TM3: Test Mode        — 3/3
Result: 25/27 pass | 2 warnings
```

### In `/para-skill add [name]`:

Agent consults this checklist BEFORE writing SKILL.md to ensure output meets quality standards from the start.
