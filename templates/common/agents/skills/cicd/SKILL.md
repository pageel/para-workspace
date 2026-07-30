---
name: cicd
description: Automated CI/CD pipeline scaffolding, multi-job quality gates, Dependabot smart auto-merge, and CD release workflows for projects in PARA workspace.
version: 1.0.0
---

# CI/CD Skill & Pattern Catalog

> **Scope:** Global Workspace Skill (`.agents/skills/cicd/`)  
> **Version:** 1.0.0  

This skill provides production-ready GitHub Actions CI/CD workflows, Dependabot security automation, Smart Auto-Merge recipes, and CD release pipelines tailored for projects in the PARA workspace.

---

## 1. Trigger Conditions & Diagnostic Engine

### 1.1. Activation Triggers

Activate this skill when:
- Setting up a new project's CI/CD pipeline (`/new-project` or `/plan`).
- Adding GitHub Actions quality gates (`typecheck`, `test`, `build`).
- Configuring Dependabot security sweeps with Smart Auto-Merge.
- Configuring automated NPM or Vercel deployment releases.

### 1.2. Proactive Stack Diagnostic & Recommendation Engine

Before generating any CI/CD workflow, the Agent MUST execute a stack diagnostic on the target project:

1. **Scan Project Manifests:**
   - Read `package.json` (or `Cargo.toml` / `go.mod` / `pyproject.toml`).
   - Detect runtime version requirement (e.g., `engines.node`).
   - Detect framework (Astro, Next.js, React, Express, Fastify).
   - Detect test framework (`vitest`, `jest`, `playwright`).
2. **Present Recommendation Matrix:**

```text
🔍 CI/CD STACK INSPECTION REPORT: [project-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Detected Stack:   Astro 6 + Vitest + npm Workspaces
  Node Requirement: >=22.12.0

⭐ RECOMMENDED PATTERN: Pattern 2.1 — Astro Monorepo (Pageel CMS Standard)
  - 3-Job Parallel Quality Gate (Typecheck, Vitest, Prod Build)
  - Dependabot Monthly Security Sweep (3 PR limit)
  - Smart Auto-Merge for Patch & Security PRs
  - Automated CD Release Gate on Semver Tag

❓ Apply recommended pattern, or select a custom pattern? (y/n)
```

---

## 2. Core Architectural Patterns

### 2.1. Pattern A: Astro 6 Monorepo (Pageel CMS Standard)

- **CI Quality Gate (`.github/workflows/ci.yml`):**
  - Node.js 22 (`node-version: '22'`).
  - 3 parallel jobs: `typecheck` (`npm run build:packages && npx astro sync && npx tsc --noEmit`), `test` (`npx vitest run`), `build` (`npm run build`).
  - Workspace package builds (`npm run build:packages`) & Astro ambient types sync (`npx astro sync`) on clean CI runners.
- **Dependabot Security Automation (`.github/dependabot.yml`):**
  - Monthly schedule (`interval: "monthly"`).
  - Open PR limit: 3.
  - Ignores major breaking semver bumps.
- **Smart Auto-Merge (`.github/workflows/dependabot-auto-merge.yml`):**
  - Evaluates PR actor (`dependabot[bot]`).
  - Automatically issues `gh pr merge --auto --squash` for patch & security PRs upon 100% green CI.
- **CD Release Gate (`.github/workflows/publish.yml`):**
  - Triggers on semver tags (`v*.*.*`).
  - Audits, builds, and publishes packages to NPM.

---

## 3. Scaffolding Templates & Recipes

### 3.1. Quality Gate Workflow (`ci.yml`)

```yaml
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

### 3.2. Smart Auto-Merge Workflow (`dependabot-auto-merge.yml`)

```yaml
name: Dependabot Auto-Merge

on:
  pull_request:
    types: [opened, reopened, synchronize]

permissions:
  contents: write
  pull-requests: write

jobs:
  auto-merge:
    name: Smart Auto-Merge (Security & Patch)
    runs-on: ubuntu-latest
    if: github.actor == 'dependabot[bot]'
    steps:
      - name: Dependabot metadata
        id: metadata
        uses: dependabot/fetch-metadata@v2
        with:
          github-token: "${{ secrets.GITHUB_TOKEN }}"

      - name: Enable Auto-Merge for Patch and Minor Updates
        if: ${{ steps.metadata.outputs.update-type != 'version-update:semver-major' }}
        run: gh pr merge --auto --squash "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 4. Quality Gate Checklist

- [ ] Node.js version matches project requirements (`node-version: '22'`).
- [ ] Working paths do NOT include leading `repo/` in workflow files.
- [ ] Pre-commit gates execute `npx tsc --noEmit` & `npx vitest run`.
- [ ] Dependabot PRs use Feature Branch + Auto-Merge protocol.

---

## 5. Reference Catalog

### 5.1. Reference Files Index

For detailed pattern breakdowns and reusable copy-paste recipes, consult:
- **Astro Monorepo Pattern:** [`references/patterns/astro-monorepo.md`](file:///.agents/skills/cicd/references/patterns/astro-monorepo.md)
- **Dependabot Auto-Merge Recipe:** [`references/recipes/dependabot-auto-merge.md`](file:///.agents/skills/cicd/references/recipes/dependabot-auto-merge.md)
- **OSS PR Template Recipe:** [`references/recipes/pr-template-oss.md`](file:///.agents/skills/cicd/references/recipes/pr-template-oss.md)
