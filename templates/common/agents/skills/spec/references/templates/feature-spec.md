# Feature Spec Template

> **Version:** 1.0.0 | **Last reviewed:** 2026-04-22
> Template used by `/spec create` Step 3 to generate a feature specification.
> Agent fills this template with data gathered from context + assumption surfacing.

---

## Template Output

```markdown
# Spec: [Feature/Project Name]

> **Created:** YYYY-MM-DD | **Status:** 📝 Draft
> **Author:** [Agent + User]
> **Project:** [project-name]

---

## Assumptions

> ⚠️ These assumptions were surfaced and confirmed before writing this spec.

1. [Confirmed assumption about tech stack]
2. [Confirmed assumption about target users]
3. [Confirmed assumption about data model]
4. [Confirmed assumption about deployment]
5. [Confirmed assumption about scope]

---

## 1. Objective

**What:** [What we're building — one paragraph]

**Why:** [Why it matters — user problem being solved]

**Who:** [Target user persona]

**Success looks like:** [One-sentence vision of the ideal outcome]

### User Stories / Acceptance Criteria

- As a [user], I want [goal] so that [benefit]
- As a [user], I want [goal] so that [benefit]

---

## 2. Commands

> Full executable commands — not just tool names.

| Command | Purpose |
|:--|:--|
| `npm run dev` | Start development server |
| `npm run build` | Production build |
| `npm test` | Run test suite |
| `npm run lint` | Lint and format |

---

## 3. Project Structure

> Where things live in the codebase.

```
src/                → Application source code
├── components/     → UI components
├── lib/            → Shared utilities
├── services/       → Business logic
└── types/          → TypeScript types
tests/              → Unit and integration tests
e2e/                → End-to-end tests
docs/               → Documentation
```

---

## 4. Code Style

> One real code snippet showing the style beats three paragraphs describing it.

**Naming conventions:**
- Components: PascalCase (`UserProfile.tsx`)
- Utilities: camelCase (`formatDate.ts`)
- Constants: UPPER_SNAKE_CASE (`MAX_RETRIES`)

**Example of good output:**

\```typescript
// Example: Service function following project conventions
export async function fetchUserProfile(userId: string): Promise<UserProfile> {
  const response = await api.get(`/users/${userId}`);
  if (!response.ok) {
    throw new ServiceError('USER_NOT_FOUND', `User ${userId} not found`);
  }
  return response.json();
}
\```

---

## 5. Testing Strategy

**Framework:** [Jest / Vitest / etc.]

**Test locations:**
- Unit tests: `tests/unit/` — co-located or mirrored
- Integration: `tests/integration/`
- E2E: `e2e/`

**Coverage requirements:**
- Minimum: [X]% line coverage
- Critical paths: 100% branch coverage

**Test levels:**

| Concern | Test Level | Example |
|:--|:--|:--|
| Pure logic | Unit | Utility functions, validators |
| Component render | Integration | React component with mocked API |
| User flow | E2E | Login → Dashboard → Action |

---

## 6. Boundaries

### Always Do
- [x] Run tests before commits
- [x] Follow naming conventions above
- [x] Validate all user inputs
- [x] Handle error cases explicitly

### Ask First
- [ ] Database schema changes
- [ ] Adding new dependencies
- [ ] Changing CI/CD configuration
- [ ] Modifying public API contracts

### Never Do
- 🚫 Commit secrets or API keys
- 🚫 Edit vendor directories
- 🚫 Remove failing tests without approval
- 🚫 Skip error handling for "happy path only"

---

## 7. Governance & Agent Skills

> Define the rules and skills required for the AI Agent to maintain this project's architecture. This is critical for Open Source (OSS) or complex projects.

**Required Project Rules (via `/para-rule`):**
- [ ] `rule-[name].md`: [Reason for this rule, e.g., prevent overwriting other authors' files]

**Required Agent Skills / Sidecar Skills (via `/para-skill`):**
- [ ] `skill-[name].md`: [Required skill, e.g., Academic Reviewer for PRs]

**OSS Templates / Community Standards:**
- [ ] Pull Request Template (`.github/PULL_REQUEST_TEMPLATE.md`)
- [ ] Issue Template / Contributing Guide (`CONTRIBUTING.md`)

---

## Success Criteria

> Specific, testable conditions — not vague goals.

- [ ] [Criterion 1 — measurable]
- [ ] [Criterion 2 — measurable]
- [ ] [Criterion 3 — measurable]

---

## Technical Plan

> Generated in Phase 2 (PLAN) after spec approval.

### Components & Dependencies

| Component | Depends On | Purpose |
|:--|:--|:--|
| [Component A] | — | [Purpose] |
| [Component B] | A | [Purpose] |

### Implementation Order

1. [Foundation component first]
2. [Dependent components next]
3. [Integration last]

### Risks & Mitigations

| Risk | Impact | Mitigation |
|:--|:--|:--|
| [Risk 1] | High | [Strategy] |
| [Risk 2] | Medium | [Strategy] |

---

## Task Breakdown

> Generated in Phase 3 (TASKS) after plan approval.

### Phase 1: [Name]

- [ ] Task 1: [Description]
  - Acceptance: [What must be true]
  - Verify: [How to confirm]
  - Files: [Which files]
  - Size: S

- [ ] Task 2: [Description]
  - Acceptance: [What must be true]
  - Verify: [How to confirm]
  - Files: [Which files]
  - Size: M

### Checkpoint: Phase 1
- [ ] All tests pass
- [ ] Application builds
- [ ] Review with user

### Phase 2: [Name]

[Continue pattern...]

---

## Open Questions

- [ ] [Question that needs answering before or during implementation]
- [ ] [Question about edge cases or unknowns]

---

## Change Log

| Date | Change | Reason |
|:--|:--|:--|
| YYYY-MM-DD | Initial spec created | — |
```
```

---

## Co-Author Guide (Draft-First)

### Phase A: Auto-scan
Agent reads `project.md`, backlog, and existing specs/brainstorms to determine:
- Tech stack and constraints
- Current project status and gaps
- Previous decisions that affect the spec

### Phase B: Surface Assumptions
Agent generates assumption list FIRST (before any spec writing).
Presents to user and WAITS for confirmation.

### Phase C: Fill Template
After assumptions are confirmed, Agent generates the full spec draft
using the template above. Marks unknowns with `[TBD]`.

### Phase D: Present for Review
Show complete spec to user for Gate 1 approval. Then proceed through
Plan (Gate 2) and Tasks (Gate 3) sequentially.

### Fallback: Minimal Interview
Only when context is insufficient, ask core questions:
1. "What are we building and why?"
2. "Who is the target user?"
3. "What does 'done' look like?"
4. "What are the hard constraints (tech, time, resources)?"
