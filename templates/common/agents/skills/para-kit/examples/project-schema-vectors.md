# Project Schema Test Vectors

> Examples for validating `project.schema.json` — covers standard, ecosystem,
> and satellite project types. Updated to v1.6.3 schema (agent block, strategy, roadmap).

## Standard Project (standalone)

```yaml
name: my-app
version: "1.2.0"
status: active
created: "2026-01-15"
goal: "Build a web application for task management."
deadline: "2026-06-30"
type: standard
active_plan: "plans/mvp-launch.md"
strategy: "Mobile-first PWA with offline support"
roadmap: "plans/roadmap-product.md"
agent:
  rules: true
  skills: false
downstream: []
dod:
  - "Core features implemented"
  - "Test coverage > 80%"
last_reviewed: "2026-03-15"
tags: ["web", "saas"]
milestones:
  - name: "Core MVP"
    status: done
    shipped_in: "1.0.0"
  - name: "Public Launch"
    status: in-progress
```

## Ecosystem Project (meta-project)

```yaml
name: acme-platform
status: active
created: "2026-03-20"
goal: "Coordinate the ACME platform ecosystem."
type: ecosystem
strategy: "Microservices architecture with shared auth"
roadmap: "plans/roadmap-ecosystem.md"
agent:
  rules: true
  skills: false
satellites:
  - acme-api
  - acme-sdk
  - acme-dashboard
dod:
  - "All satellites integrated"
  - "Shared auth working across services"
tags: ["platform", "ecosystem"]
```

## Satellite Project (linked to ecosystem)

```yaml
name: acme-sdk
status: active
created: "2026-03-19"
goal: "JavaScript SDK for ACME platform API."
type: standard
ecosystem: acme-platform
active_plan: "@acme-platform/plans/sdk-v2.md"
strategy: "TypeScript-first with tree-shaking support"
roadmap: ~
agent:
  rules: false
  skills: false
upstream:
  - acme-api
tags: ["sdk", "typescript"]
```

## Satellite Project (local plan, no cross-project)

```yaml
name: acme-api
version: "2.0.0"
status: active
created: "2026-02-01"
goal: "REST API backend for ACME platform."
type: standard
ecosystem: acme-platform
active_plan: "plans/api-v2-migration.md"
strategy: "Gradual migration from Express to Fastify"
roadmap: "plans/roadmap-api.md"
agent:
  rules: true
  skills: false
downstream:
  - acme-sdk
  - acme-dashboard
milestones:
  - name: "v2 API Migration"
    status: in-progress
  - name: "GraphQL Layer"
    status: planned
```

## Legacy Project (no v1.6.x fields — backward compat)

```yaml
name: old-project
status: active
created: "2025-12-01"
goal: "Legacy project without new fields."
active_plan: ""
```

> This example validates backward compatibility: `type`, `ecosystem`, `strategy`,
> `roadmap`, `agent`, and `satellites` fields are all optional. Existing projects
> without these fields MUST still pass schema validation.
