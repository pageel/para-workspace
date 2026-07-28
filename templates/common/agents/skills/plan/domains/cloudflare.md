# Plan Domain Rules: Cloudflare Serverless & Edge Stack

> **Loaded via:** `/plan` workflow Step 0 — Pre-flight when project tech stack includes Cloudflare (Workers, Pages, D1, Turnstile)
> **Location:** `.agents/skills/plan/domains/cloudflare.md`

## 1. Cloudflare Turnstile & Full-Stack Security Pairing
- **Paired Contracts:** Always pair Backend Worker verification tasks (`TURNSTILE_SECRET_KEY`) with Frontend Component tasks (`PUBLIC_TURNSTILE_SITE_KEY` container & SDK script in `<head>`) in the SAME phase.
- **Allowed Domains & Env Setup:** Include explicit tasks for `.env.example` templates, `npx wrangler secret put` instructions for Workers, and Cloudflare Dashboard Allowed Domains configuration (`your-domain.com`, `*.pages.dev`, `localhost`).

## 2. Cloudflare D1 & Worker Deploy Synchronicity
- **Migration & Deploy Pairing:** Pair D1 schema migrations (`npx wrangler d1 execute`) with Worker code deployments in the same Phase to prevent API runtime errors.

## 3. Full-Stack Live Deployment Gate
- **Multi-Target Deployment:** Always define separate deployment tasks for both Worker Backend API (`npx wrangler deploy`) AND Frontend Cloudflare Pages (`npm run deploy`).
