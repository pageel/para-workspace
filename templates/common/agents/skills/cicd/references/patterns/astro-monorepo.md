# CI/CD Pattern: Astro 6 Monorepo + Vitest + GitHub Actions

> **Source Project:** `pageel-cms`  
> **Applicable Stack:** Astro 6, Vite, React 19, TypeScript Monorepo  

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    GitHub Cloud CI                      │
│                                                         │
│ ┌────────────────┐ ┌────────────────┐ ┌───────────────┐ │
│ │  Type Check    │ │  Vitest Tests  │ │ Prod Build    │ │
│ │  (tsc --noEmit)│ │  (vitest run)  │ │ (npm build)   │ │
│ └───────┬────────┘ └───────┬────────┘ └───────┬───────┘ │
│         └──────────────────┼──────────────────┘         │
│                            ▼                            │
│                 100% GREEN (Passed) 🟢                   │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│             Dependabot Smart Auto-Merge                 │
│    gh pr merge --auto --squash (Patch / Security)       │
└─────────────────────────────────────────────────────────┘
```

---

## 1. Quality Gate (`.github/workflows/ci.yml`)

```yaml
# @para-doc [#csa-cms-cicd-quality-gate]
name: CI Quality Gate

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  typecheck:
    name: Type & Syntax Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
      - run: npm ci
      - run: npm run build:packages --if-present
      - run: npx astro sync --if-present
      - run: npx tsc --noEmit

  test:
    name: Unit & Integration Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
      - run: npm ci
      - run: npm run build:packages --if-present
      - run: npx vitest run

  build:
    name: Production Build Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
      - run: npm ci
      - run: npm run build
```

---

## 2. Key Execution Invariants

1. **Node.js Version:** MUST use `node-version: '22'` (Astro 6 requires Node.js `>=22.12.0`).
2. **Path Context:** Do NOT prefix paths with `repo/` inside GitHub Actions YAML files.
3. **Clean Runner Preparation:** Always run `npm run build:packages --if-present` and `npx astro sync --if-present` before executing typechecks or tests.
