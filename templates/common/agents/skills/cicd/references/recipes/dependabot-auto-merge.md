# Recipe: Dependabot Smart Auto-Merge

> **Purpose:** Automate zero-touch patching for security and patch updates while preserving main branch safety.

---

## 1. Dependabot Config (`.github/dependabot.yml`)

```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "monthly"
    open-pull-requests-limit: 3
    target-branch: "main"
    labels:
      - "dependencies"
      - "dependabot"
    ignore:
      - dependency-name: "*"
        update-types: ["version-update:semver-major"]
```

---

## 2. Smart Auto-Merge Workflow (`.github/workflows/dependabot-auto-merge.yml`)

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

## 3. How It Works

1. Dependabot opens PR for minor/patch dependency update.
2. `dependabot-auto-merge.yml` runs immediately and flags PR with `gh pr merge --auto --squash`.
3. `ci.yml` quality gate executes.
4. Once all 3 CI jobs pass 100% GREEN 🟢, GitHub Server automatically merges the PR and deletes the remote branch.
