# RFC-XXXX: <Title>

- Feature Name: <kebab-case-feature-name>
- Start Date: YYYY-MM-DD
- Status: Proposed | Accepted | Rejected | Withdrawn | Implemented
- Target Release: vX.Y.Z
- Owners: @<github-handle> (primary), @<handle> (reviewer)
- Affected:
  - kernel/
  - cli/
  - templates/
  - docs/
  - workspace runtime
- Related:
  - Kernel Invariants: I1..I10 (if any)
  - Kernel Heuristics: H1..H8 (if any)
  - Prior RFCs: RFC-XXXX (if any)

## Summary

1–3 sentences describing what this RFC changes and why.

## Motivation

Explain the problem and who it affects.

Goals:

- <goal 1>
- <goal 2>

Non-goals:

- <non-goal 1>
- <non-goal 2>

## Guide-level explanation

Describe how users/agents will use this feature.

Example:

- User runs: `para <command>`
- Workspace changes: <what appears/changes>
- Agent behavior: <what the agent reads/writes>

## Reference-level specification

### Definitions

Define key terms consistent with PARA principles.

### Repo changes (normative)

List exact files/folders to add/change/remove and their purpose.

### Workspace changes (normative)

Define exact workspace paths, what is read-only vs runtime.

### CLI behavior (normative)

Specify command behavior, flags, exit codes, and compatibility gates.

### Compatibility & versioning (normative)

- How this interacts with kernel version tracking in `.para-workspace.yml`
- Semver rules: what constitutes MAJOR/MINOR/PATCH

### Security / safety (normative)

- Drift detection rules
- Multi-agent safety (locks, merge strategy, conflict rules) if applicable

## Rationale

Explain why this design is chosen over alternatives (trade-offs).

## Alternatives

List alternatives considered and why rejected.

## Drawbacks

What gets worse? (complexity, migration cost, maintenance burden)

## Implementation plan

Step-by-step breakdown:

1. <repo change>
2. <cli change>
3. <docs/tests change>

## Migration plan

How existing workspaces upgrade safely:

- `para update` / `para migrate` behavior
- Backups/rollbacks

## Testing plan

- Unit tests (if any)
- Integration tests (CLI)
- Kernel test vectors (examples/)

## Unresolved questions

Open items, decisions deferred, or future RFCs required.
