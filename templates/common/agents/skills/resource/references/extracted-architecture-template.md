# 🏗️ Extracted Architecture Pattern: {{RESOURCE_NAME}}

> **Namespace:** `{{NAMESPACE}}`
> **Extracted Date:** {{DATE}}
> **Graph Metrics:** `{{FILES}}` files | `{{NODES}}` nodes | `{{EDGES}}` edges

<!-- ⚠️ AGENT INSTRUCTION:
This template extracts an architecture pattern from a studied resource and formats it
as a DRAFT sysdesign pattern. The goal is to turn real-world code into a reusable
reference architecture that can be promoted to the sysdesign pattern catalog.

WORKFLOW:
1. Analyze the resource's codebase using graph tools + native file reading
2. Fill in each section below by mapping real code to architectural concepts
3. Generate YAML frontmatter tags by analyzing the resource's tech stack
4. Save as draft → User reviews → If approved, promote to sysdesign catalog

OUTPUT PATH: Areas/Learning/Resources/[namespace]/extracted_architecture/pattern-draft.md
PROMOTION PATH: .agents/skills/sysdesign/references/architecture-patterns/[pattern-slug].md
-->

## Auto-Generated YAML Frontmatter (Draft)

```yaml
---
tags: [Agent: extract from package.json, Dockerfile, config files]
stack: [Agent: list primary frameworks, databases, runtimes detected]
scale: [Agent: estimate based on architecture complexity — small/medium/large/enterprise]
complexity: [basic | intermediate | advanced]
source_resource: "{{NAMESPACE}}"
---
```

## 1. Topology
*   [Agent: Describe the deployment architecture based on Dockerfile, docker-compose.yml, wrangler.toml, vercel.json, netlify.toml, or similar infrastructure config files found in the resource]
*   [Agent: Identify runtime environment (Edge, VPS, Serverless, Container)]
*   [Agent: Map data flow between components using a Mermaid diagram]

## 2. API & Communication Design
*   [Agent: Analyze route handlers, controllers, API endpoints found in the codebase]
*   [Agent: Extract request/response contracts from TypeScript interfaces, Zod schemas, or OpenAPI specs]
*   [Agent: Identify communication patterns (REST, GraphQL, gRPC, WebSockets)]
*   [Agent: Document error handling patterns and standard error format]
*   [Agent: Note pagination, rate limiting, and idempotency strategies if found]

## 3. Database & Storage Architecture
*   [Agent: Extract schema definitions from ORM models, migration files, or raw DDL]
*   [Agent: Identify database engine (Postgres, SQLite, MongoDB, Redis)]
*   [Agent: Document indexing strategy from migration files or schema annotations]
*   [Agent: Note any caching layers, session storage, or file storage patterns]

## 4. Software Topology
*   [Agent: Map the folder structure to architectural layers (routes, controllers, services, models, utils)]
*   [Agent: Generate a Mermaid component diagram showing module relationships from graph edges]
*   [Agent: Identify key entry points from graph god nodes analysis]

## 5. Security Patterns (if detected)
*   [Agent: Analyze auth middleware, CORS configuration, rate limiting, input validation]
*   [Agent: Note secret management patterns (env files, vault integration)]
*   [Agent: Document RBAC/ABAC patterns if found in the authorization layer]
*   [Agent: Skip this section if no security patterns detected — mark as "Not applicable (static/library)"]

## 6. Observability Patterns (if detected)
*   [Agent: Analyze logging configuration (structured logging, log levels)]
*   [Agent: Note health check endpoints, metrics collection, tracing setup]
*   [Agent: Skip this section if no observability patterns detected — mark as "Not applicable"]

## 📊 Quality Assessment

| Criterion | Score | Evidence |
|:--|:--|:--|
| Architectural clarity | [🟢/🟡/🔴] | [Agent: Is the codebase well-structured with clear separation of concerns?] |
| Reusability potential | [🟢/🟡/🔴] | [Agent: Can this pattern be generalized for other projects?] |
| Documentation quality | [🟢/🟡/🔴] | [Agent: Does the resource have good documentation explaining design decisions?] |
| Pattern novelty | [🟢/🟡/🔴] | [Agent: Does this pattern offer something not already in the sysdesign catalog?] |

## 🔗 Promotion Recommendation

<!-- ⚠️ AGENT INSTRUCTION:
After filling in the template, Agent MUST evaluate whether this pattern is worth
promoting to the sysdesign catalog. Use these criteria:

PROMOTE (recommend /sysdesign learn) if:
- Quality score ≥ 3 Green across all criteria
- Pattern fills a gap in the current catalog (check SKILL.md router table)
- Pattern is generalizable beyond the specific resource

SKIP if:
- Resource is too niche or project-specific
- Similar pattern already exists in catalog
- Architecture is poorly structured or anti-pattern heavy

Agent MUST present this recommendation to the user with:
"📐 This pattern is [PROMOTABLE / NOT RECOMMENDED] for catalog.
  To standardize and enrich it with internet research, run:
  `/sysdesign learn [pattern-slug] --source [namespace]`"
-->

**Verdict:** [PROMOTABLE / NOT RECOMMENDED]
**Reasoning:** [Agent: explain why]
**Next Step:** `/sysdesign learn [pattern-slug] --source {{NAMESPACE}}`
