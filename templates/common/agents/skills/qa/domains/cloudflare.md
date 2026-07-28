# Domain Question Bank: Cloudflare Serverless & Edge Stack

> **Loaded via:** `/qa` workflow Step 0.6 when project tech stack includes Cloudflare (Workers, Pages, D1, KV, Turnstile)
> **Scope:** Cloudflare Worker Routing, Secret Management, D1 Migrations, Edge Caching, Turnstile Gateway.

## 1. Cloudflare Workers & Wrangler CLI
- **[CF-1] Secret Provisioning:** Are production secret keys (`wrangler secret put`) documented with CLI instructions instead of being written in `wrangler.toml` vars?
- **[CF-2] Deployment Synchronicity:** Does the plan couple D1 database migrations with backend `wrangler deploy` in the same Phase to prevent API schema mismatches?
- **[CF-3] Execution Context WaitUntil:** Are async audit logs or background operations wrapped in `ctx.waitUntil()` to prevent unmounted worker log loss?

## 2. Cloudflare Turnstile & Bot Gateway
- **[CF-4] Server-side Siteverify:** Is Turnstile token verification executed on the backend via `https://challenges.cloudflare.com/turnstile/v0/siteverify` before processing requests?
- **[CF-5] Token Single-Use Reset:** Does the client-side widget trigger `turnstile.reset()` on form submit failure (4xx/5xx) to handle single-use token expiration?
- **[CF-6] Full-Stack Turnstile Parity:** If Backend Worker API requires Turnstile verification, does the Plan/Spec contain corresponding Frontend Component tasks (`PUBLIC_TURNSTILE_SITE_KEY` container & SDK script placement in `<head>`)?
- **[CF-7] Allowed Domains & Environment Isolation:** Are production secrets set via `wrangler secret put` (Worker) vs `PUBLIC_TURNSTILE_SITE_KEY` (Pages Frontend), and are live hostnames (`your-domain.com`, `localhost`) explicitly registered under Turnstile Widget Allowed Domains on Cloudflare Dashboard?

## 3. Edge Cache & CORS
- **[CF-8] CDN Edge Cache Pollution:** Does the CORS middleware emit `Vary: Origin` header unconditionally to partition Cloudflare CDN cache across origins?
