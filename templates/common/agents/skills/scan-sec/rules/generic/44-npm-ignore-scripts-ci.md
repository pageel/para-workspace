---
id: NPM-IGNORE-SCRIPTS-CI
severity_max: HIGH
applies_to: yaml, yml, json
---

# NPM Postinstall Arbitrary Code Execution in CI

## Intent

Detects NPM installation steps in CI pipelines or local setup scripts that fail to disable lifecycle script hooks (`--ignore-scripts`). Malicious NPM dependencies often abuse `preinstall`, `install`, or `postinstall` hooks in `package.json` to execute arbitrary shell scripts, harvest environment variables (such as `NPM_TOKEN`, `AWS_SECRET_ACCESS_KEY`), or establish reverse shells during `npm install`.

Reference OWASP Cheat Sheet Series: `NPM_Security_Cheat_Sheet.md` & `Software_Supply_Chain_Security_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- CI/CD workflow step runs `npm install` or `yarn install` without `--ignore-scripts` when building untrusted external PRs.
- `package.json` contains suspicious `postinstall` commands executing obfuscated curl/bash scripts.

## When MEDIUM / LOW

- Local development scripts execute `npm install` without audit scanning.

## Search patterns (suggestions)

```yaml
run:\s*npm\s+ci(?!\s+--ignore-scripts)
run:\s*npm\s+install(?!\s+--ignore-scripts)
"postinstall":\s*"curl
"postinstall":\s*"bash
```

## Examples

### BAD — Arbitrary Postinstall Execution in CI
```yaml
# BAD: Vulnerable dependency's postinstall script executes arbitrary shell code in CI
steps:
  - uses: actions/checkout@v4
  - run: npm ci # Executes package postinstall hooks!
```

### GOOD — Disabling Lifecycle Scripts with --ignore-scripts
```yaml
# GOOD: `--ignore-scripts` prevents execution of arbitrary package lifecycle hooks
steps:
  - uses: actions/checkout@v4
  - run: npm ci --ignore-scripts # Safe from postinstall RCE!
  - run: npm rebuild # Explicitly rebuild trusted native C++ bindings if necessary
```

## Fix recommendation

1. Use `npm ci --ignore-scripts` or `yarn install --ignore-scripts` in CI pipelines to prevent untrusted packages from executing arbitrary postinstall code.
2. If native C++ node bindings require building, explicitly trigger build commands (`npm rebuild`) only for trusted, audited packages.
