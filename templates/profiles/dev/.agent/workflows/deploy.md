---
description: Deploy Astro project to Git/Vercel with verification
---

# /deploy

> **Profile:** Dev
> **Version:** 1.0.0

Deploy the current project to production (Vercel/Netlify) via Git push, ensuring all checks pass.

## Steps

### 1. Pre-flight Check

//turbo

```bash
npm run build
```

Verify that the project builds successfully locally.

### 2. Git Status Check

//turbo

```bash
git status --short
```

Ensure the working directory is clean or only has intended changes.

### 3. Commit & Push

```bash
git add .
git commit -m "deploy: [reason for deployment]"
git push origin main
```

### 4. Deployment Verification

- Check the deployment URL (e.g., Vercel Dashboard).
- Verify the live site triggers no console errors.
