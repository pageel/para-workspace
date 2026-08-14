---
id: SUPPLY-CHAIN-UNPINNED-CI
severity_max: HIGH
applies_to: yaml, yml, json
---

# Supply Chain Lockfile Poisoning & Unpinned CI Installs

## Intent

Detects unpinned package installations in CI/CD pipelines (e.g. running `npm install` instead of `npm ci` or missing `--frozen-lockfile` in `pnpm`/`bun`), or wildcards in package manifests (`*`, `latest`). Running unpinned installs in CI environments exposes builds to Dependency Confusion, Lockfile Poisoning, or malicious package version releases (Typosquatting / Compromised NPM maintainer accounts).

Reference OWASP Cheat Sheet Series: `Software_Supply_Chain_Security_Cheat_Sheet.md` & `Dependency_Graph_SBOM_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- CI workflow runs `npm install` or `yarn install` on production release pipelines without enforcing lockfile immutability (`npm ci`, `yarn install --immutable`, `pnpm install --frozen-lockfile`).
- Package manifest (`package.json`) uses wildcard `*` for core security or production dependencies.

## When MEDIUM / LOW

- Lack of automated vulnerability audit step (`npm audit` / `socket.dev`) in CI workflow.

## Search patterns (suggestions)

```yaml
run:\s*npm\s+install(?!\s+--frozen-lockfile)
run:\s*yarn\s+install(?!\s+--immutable)
"\*":
"latest"
```

## Examples

### BAD — Unpinned Install in CI Workflow
```yaml
# BAD: `npm install` updates lockfile dynamically in CI, building unverified versions
steps:
  - uses: actions/checkout@v4
  - run: npm install # Unsafe in CI!
  - run: npm run build
```

### GOOD — Immutable Lockfile Installation in CI Workflow
```yaml
# GOOD: `npm ci` fails if package.json and package-lock.json are out of sync
steps:
  - uses: actions/checkout@v4
  - run: npm ci # Immutable lockfile install
  - run: npm run build
```

## Fix recommendation

1. Replace `npm install` with `npm ci` (or `pnpm install --frozen-lockfile`, `yarn install --immutable`) in all CI/CD pipelines.
2. Avoid wildcards (`*`) or `latest` tags in `package.json` for production dependencies.
3. Integrate dependency vulnerability scanning tools (such as `npm audit --audit-level=high` or Snyk/Socket.dev) into CI status gates.
