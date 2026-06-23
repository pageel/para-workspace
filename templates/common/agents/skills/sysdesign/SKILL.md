---
name: System Design Router
description: Sidecar skill routing templates and architecture patterns for the /sysdesign workflow.
source: user
---

# Skill: System Design Router

Provides structure templates and default patterns for the `/sysdesign` workflow.

## References

| File | Type | Purpose |
| :--- | :--- | :--- |
| `references/templates/sysdesign.md` | Template | Base structure for system designs |
| `references/templates/adr.md` | Template | Architecture Decision Record layout |
| `references/architecture-patterns/cloudflare-workers-d1.md` | Pattern | Edge architecture with Workers, D1 DB, KV |
| `references/architecture-patterns/nextjs-supabase-postgres.md` | Pattern | Fullstack architecture with Next.js, Supabase, Postgres |
| `references/architecture-patterns/express-mongodb-docker.md` | Pattern | Node REST API with Express, MongoDB, Docker |
| `references/architecture-patterns/astro-static.md` | Pattern | Static site architecture with Astro |
| `references/architecture-patterns/event-driven-microservices.md` | Pattern | Asynchronous message broker pub-sub / Saga orchestration & choreography |
| `references/architecture-patterns/cqrs-read-write-separation.md` | Pattern | Read-write database path separation with CDC sync |
