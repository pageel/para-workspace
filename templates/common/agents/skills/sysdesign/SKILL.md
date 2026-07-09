---
name: System Design Router
description: Sidecar skill routing templates and architecture patterns for the /sysdesign workflow.
source: user
---

# Skill: System Design Router

Provides structure templates, ADR governance, and default architecture patterns for the `/sysdesign` workflow.

## References

### Templates

| File | Type | Purpose |
| :--- | :--- | :--- |
| `references/templates/sysdesign.md` | Template | Base structure for system designs (6 domains: Infra, API, DB, Topology, Security, Observability) |
| `references/templates/adr.md` | Template | Architecture Decision Record layout (8 sections incl. Validation, Reversibility, Traceability) |
| `references/templates/adr-registry.md` | Template | ADR Registry for tracking all decisions with conflict detection |
| `references/templates/sysdesign-report.md` | Template | Security & architecture assessment report template for sysdesign |

### Architecture Patterns

| File | Tags | Scale | Purpose |
| :--- | :--- | :--- | :--- |
| `references/architecture-patterns/astro-website.md` | website, ssg, ssr, hybrid, seo | small–medium | Astro websites — blogs, docs, marketing, portfolios (SSG/SSR/Hybrid) |
| `references/architecture-patterns/astro-7-fullstack.md` | fullstack, hybrid, server-islands, actions | small–large | Astro 7 fullstack app — auth, DB, dashboard, Actions, Server Islands |
| `references/architecture-patterns/cloudflare-workers-d1.md` | edge, serverless, sql | small–medium | Serverless Edge with Workers, D1 DB, KV |
| `references/architecture-patterns/nextjs-supabase-postgres.md` | fullstack, ssr, realtime | medium–large | Fullstack architecture with Next.js, Supabase, Postgres |
| `references/architecture-patterns/express-mongodb-docker.md` | rest-api, nosql, containerized | small–large | Node REST API with Express, MongoDB, Docker |
| `references/architecture-patterns/python-fastapi-postgres.md` | rest-api, python, async | medium–enterprise | Async Python API with FastAPI, PostgreSQL, SQLAlchemy |
| `references/architecture-patterns/event-driven-microservices.md` | async, pub-sub, saga | large–enterprise | Asynchronous message broker pub-sub / Saga orchestration & choreography |
| `references/architecture-patterns/cqrs-read-write-separation.md` | cqrs, read-write, cdc | large–enterprise | Read-write database path separation with CDC sync |
| `references/architecture-patterns/fintech-payment-ledger.md` | fintech, ledger, idempotency | medium–enterprise | Double-entry ledger, idempotency dedup, reconciliation |
| `references/architecture-patterns/spatial-geohashing-search.md` | geolocation, spatial, postgis | medium–large | Location-based services with Geohashing & PostGIS |
| `references/architecture-patterns/multi-tenant-saas.md` | multi-tenant, saas, horizontal | medium–enterprise | Horizontal multi-tenant isolation strategies (stack-agnostic) |
| `references/architecture-patterns/react-native-expo.md` | mobile, cross-platform, offline | small–large | Cross-platform mobile with React Native, Expo, SQLite |

## Auto-Matching Logic

When the `/sysdesign create` workflow runs Step 2 (Select Architecture Pattern), Agent SHOULD:

1. **Read project context**: Detect tech stack from `project.md` (goal, tags), `package.json`, `wrangler.toml`, `pyproject.toml`, or `app.json`.
2. **Match YAML tags**: Compare detected stack keywords against each pattern's `tags` and `stack` fields in YAML frontmatter.
3. **Filter by scale**: Use project's `scale` field (from sysdesign frontmatter) to narrow candidates.
4. **Suggest top 1–3 patterns**: Present matched patterns to the user with rationale.
5. **Horizontal patterns**: Always check if `multi-tenant-saas.md` applies in addition to the primary stack pattern.

> **Fallback**: If no pattern matches, proceed with the base `sysdesign.md` template without pattern scaffolding.
