# Project Schema Test Vectors

> Examples for validating `project.schema.json` — covers standard, ecosystem,
> and satellite project types introduced in v1.6.0.

## Standard Project (standalone)

```yaml
name: para-workspace
status: active
kernel_version: "1.6.0"
created_at: "2026-01-15"
profile: dev
type: standard
active_plan: "plans/v1.6.0-meta-project.md"
has_rules: true
```

## Ecosystem Project (meta-project)

```yaml
name: pageel
status: active
kernel_version: "1.6.0"
created_at: "2026-03-20"
profile: dev
type: ecosystem
satellites:
  - pageel-cms
  - pageel-page-map
  - pageel-mcp-page-map
description: "Pageel ecosystem — coordinates CMS, Page Map, and MCP projects."
```

## Satellite Project (linked to ecosystem)

```yaml
name: pageel-page-map
status: active
kernel_version: "1.6.0"
created_at: "2026-03-19"
profile: dev
type: standard
ecosystem: pageel
active_plan: "@pageel/plans/page-map-implementation.md"
has_rules: false
```

## Satellite Project (local plan, no cross-project)

```yaml
name: pageel-cms
status: active
kernel_version: "1.6.0"
created_at: "2026-02-01"
profile: dev
type: standard
ecosystem: pageel
active_plan: "plans/cms-redesign.md"
has_rules: true
```

## Legacy Project (no type field — backward compat)

```yaml
name: old-project
status: active
kernel_version: "1.4.0"
created_at: "2025-12-01"
profile: general
active_plan: ""
```

> This example validates backward compatibility: `type`, `ecosystem`, and
> `satellites` fields are all optional. Existing projects without these
> fields MUST still pass schema validation.
