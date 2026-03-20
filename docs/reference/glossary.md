# Glossary & Impact Map

> **Version:** 1.6.0 | **Last updated:** 2026-03-20
> **Mục đích:** Danh mục thuật ngữ, biến, fields sử dụng trong PARA Workspace.
> Mỗi entry = 5 fields đồng nhất (graph-ready design).

---

## active_plan

- **Định nghĩa:** Path đến implementation plan đang active. Hỗ trợ local path và `@{ecosystem}/` cross-project prefix.
- **Nơi define:** `kernel/schema/project.schema.json` (type: string|null)
- **Nơi sử dụng:**
  - `/open` (Step 5) — đọc plan summary
  - `/end` (Step 4) — check plan progress
  - `/plan` (create Step 10, review Step 1) — activate/read plan
  - `/para-audit` (update Step 3) — validate field exists
- **Ảnh hưởng khi sửa:** 4 workflows. Nếu đổi syntax `@` prefix → sửa resolution logic ở 4 nơi.
- **Liên quan:** `ecosystem`, `type`, `satellites`

## type

- **Định nghĩa:** Loại project. `standard` = project thường, `ecosystem` = meta-project điều phối satellites.
- **Nơi define:** `kernel/schema/project.schema.json` (enum: standard|ecosystem, default: standard)
- **Nơi sử dụng:**
  - `/open` (Step 2) — ecosystem detection
  - `/open` (Step 7) — skip git for ecosystem
  - `/end` (Step 3.5) — skip git suggestions
  - `/new-project` (Step 2) — prompt project type
  - `/para-audit` (update Step 3) — validate consistency
- **Ảnh hưởng khi sửa:** 5 workflows. Nếu thêm enum value mới → cập nhật 5 nơi.
- **Liên quan:** `ecosystem`, `satellites`

## ecosystem

- **Định nghĩa:** Tên ecosystem cha (meta-project slug). Set trên satellite projects.
- **Nơi define:** `kernel/schema/project.schema.json` (type: string|null, pattern: kebab-case)
- **Nơi sử dụng:**
  - `/open` (Step 2) — note parent ecosystem
  - `/open` (Step 5) — resolve `@` prefix
  - `/para-audit` (update Step 3) — cross-reference với satellites list
  - `/new-project` (Step 2) — prompt ecosystem name
- **Ảnh hưởng khi sửa:** 4 workflows. Nếu đổi naming convention → rename tất cả satellite project.md.
- **Liên quan:** `type`, `satellites`, `active_plan`

## satellites

- **Định nghĩa:** Danh sách slug các satellite projects. Chỉ valid khi `type: ecosystem`.
- **Nơi define:** `kernel/schema/project.schema.json` (type: array|null, items: kebab-case)
- **Nơi sử dụng:**
  - `/open` (Step 2, Step 8) — display satellite list in report
  - `/para-audit` (update Step 3) — cross-reference với satellite ecosystem fields
- **Ảnh hưởng khi sửa:** 2 workflows. Impact thấp — chỉ display + validation.
- **Liên quan:** `type`, `ecosystem`

## profile

- **Định nghĩa:** Profile preset dùng khi init workspace. Định hướng departments/capabilities.
- **Nơi define:** `kernel/schema/workspace.schema.json` + `project.schema.json` (enum: dev|general|marketer|ceo)
- **Nơi sử dụng:**
  - `para init` CLI — select profile
  - `para scaffold` CLI — set in .project.yml
  - Profile presets (`templates/profiles/*/preset.yaml`) — directory structure
  - `/new-project` (Step 2) — inherit from workspace
- **Ảnh hưởng khi sửa:** Schema (2 files), CLI (2 commands), templates (4 presets), workflows (1). Rất cao.
- **Liên quan:** `kernel_version`

## kernel_version

- **Định nghĩa:** Phiên bản kernel tại thời điểm init/update. SemVer format.
- **Nơi define:** `kernel/schema/workspace.schema.json` + `project.schema.json` (type: string, pattern: semver)
- **Nơi sử dụng:**
  - `.para-workspace.yml` — workspace level
  - `project.md` — project level
  - `para update` CLI — compat check
  - `para migrate` CLI — version diff
  - Catalog `catalog.yml` — kernel_min/kernel_max constraints
  - `/para-audit` (update Step 1) — detect version change
- **Ảnh hưởng khi sửa:** Schema (2), CLI (2), catalog (mọi workflow entry), audit (1). Rất cao.
- **Liên quan:** `profile`

## has_rules

- **Định nghĩa:** Boolean cho biết project có custom rules trong `.agent/rules.md`.
- **Nơi define:** `kernel/schema/project.schema.json` (type: boolean, default: false)
- **Nơi sử dụng:**
  - `/open` (Step 2.5b) — gate rules loading (skip if false)
  - `/para-audit` (update Step 5) — verify consistency với disk
- **Ảnh hưởng khi sửa:** 2 workflows. Impact thấp.
- **Liên quan:** —

---

## Impact Summary

| Term             | Workflows | Files        | Impact      |
|:-----------------|:----------|:-------------|:------------|
| `active_plan`    | 4         | 1 schema     | 🔴 Cao      |
| `type`           | 5         | 1 schema     | 🟡 TB       |
| `ecosystem`      | 4         | 1 schema     | 🟡 TB       |
| `satellites`     | 2         | 1 schema     | 🟢 Thấp     |
| `profile`        | 1+CLI     | 2 schemas    | 🔴 Cao      |
| `kernel_version` | 1+CLI     | 2 schemas    | 🔴 Cao      |
| `has_rules`      | 2         | 1 schema     | 🟢 Thấp     |

> Glossary sẽ grow theo v1.7.0 (department, tier) và v1.8.0 (provenance, trust).
