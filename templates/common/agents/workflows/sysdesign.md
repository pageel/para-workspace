---
description: Design system architecture, data models, APIs, and infra before specifying features
source: user
---

# /sysdesign [project-name] [action] [topic] [--graph]

> ⚠️ **HARNESS GUARD (MANDATORY SKILL LOADING):** Before executing any sysdesign action, Agent MUST load `.agents/skills/sysdesign/SKILL.md` and its base template `references/templates/sysdesign.md` to ensure correct architectural standards are applied.

> **Workspace Version:** 1.9.4 (Architecture-First — Full Actions)

Establish or update the system design for a project or subsystem. Runs before `/spec`.

## Actions

| Action | Description |
| :-- | :-- |
| `create` | Create a new system architecture design or subsystem design (default) |
| `review` | Compare the active codebase against the design to detect architecture drift |
| `update` | Update an existing system design when architecture changes |
| `diff` | Compare two versions of a system design and generate blast radius report |
| `learn` | Learn a new architecture pattern from resource extraction + internet research |
| `audit-specs` | Compare the system design against all active specs to detect spec gaps and coverage rate |
| `report` | Conduct a security & architecture assessment and generate a formal audit report |

> **Decision Flow:** When sysdesign or spec encounters a choice point with 2+ viable options,
> Agent MUST suggest `/brainstorm` to formally evaluate alternatives before committing.
> Decisions are stored in `artifacts/para-decisions/` and referenced via `decisions: []` metadata in sysdesign files.

## Options

| Option | Description |
| :-- | :-- |
| `--graph` | Run Graph Pipeline (Build → Query → Blast Radius Analysis) to anchor design in the active codebase |
| `--update` | Used with report action: Automatically apply remediation recommendations back to the system design file in one go |

---

## 📋 Action: create

### Steps

#### 0. Pre-flight
Read project contract (`project.md`), workspace rules, and load custom agent instructions.

> **Constraint:** Read `.para-workspace.yml` at the workspace root to resolve the user's preferred language.
> All output (chat response) MUST be translated to the chat language, all internal reasoning (<thought>) MUST be written in the thinking language, and all generated files in artifacts/ (plans, tasks, qa) MUST follow the artifacts language.

**Mandatory Insight Query:**
Agent MUST query the workspace/project SQLite store using `insight_search` and `memory_search` tool calls to search for past architecture `lesson`, `risk`, `decision`, or `gotcha` entries matching the tech stack or topic.
If `--graph` is specified:
1. Run `/para-graph build [project-name]` to sync code graph.
2. Run `graph_impact_analysis` to identify dependencies and blast radius of the topic.

> ⛔ **HARNESS GUARD (Avoid Sysdesign Duplicates):** Before creating a new sysdesign file, Agent MUST list existing sysdesign files (`ls -t Projects/[project-name]/artifacts/sysdesigns/sysdesign-*.md 2>/dev/null`).
> - **IF a sysdesign file for this topic/subsystem already exists:** Agent MUST abort the `create` action, notify the user, and propose running `/sysdesign [project] update` on the existing file instead.
> - **IF no matching sysdesign exists:** Proceed with the creation flow.

#### 1. Surface Design Constraints
Agent MUST ask and define:
- Target deployment platform (Edge/Workers, VPS, Docker, Serverless, v.v.).
- Database/Storage engine (SQLite, PostgreSQL, MongoDB, Local Files).
- Request volume & performance targets (RPS, Latency limits).
- Scale classification: `small` / `medium` / `large` / `enterprise`.

> 🧠 **Clarification Loop (Interactive Q&A):** If the initial design parameters (scale, platforms, constraints) are incomplete or unclear, Agent MUST ask 1-3 targeted questions to resolve them inline (Inline Resolution) instead of eagerly recommending a brainstorm.
> 
> 🧠 **Decision Trigger (Escalation to Brainstorm):** If the user is uncertain about core architectural directions (e.g., Relational vs Document storage, Serverless vs Dedicated VPS) OR if the Q&A reveals conflicting priorities, Agent MUST pause and suggest:
> `"This involves a significant architectural trade-off. Would you like to run /brainstorm to evaluate options before committing?"`
> If user agrees → delegate to `/brainstorm` → link decision via `decisions: []` metadata in sysdesign file.
> If user has already decided → proceed.

#### 2. Select Architecture Pattern & Scaffolding

> 🧩 **Sidecar Skill:** Load pattern catalog from `.agents/skills/sysdesign/SKILL.md`.
> Read the Auto-Matching Logic section and follow the 5-step matching process.

1. **Read project context**: Detect tech stack from `project.md`, `package.json`, `wrangler.toml`, `pyproject.toml`, or `app.json`.
2. **Match YAML tags**: Compare detected keywords against each pattern's `tags` and `stack` fields.
3. **Filter by scale**: Use project's scale classification (from Step 1) to narrow candidates.
4. **Suggest top 1–3 patterns**: Present matched patterns to user with rationale.
5. **Horizontal patterns**: Always check if `multi-tenant-saas.md` applies as an overlay.
6. Bootstrap the design file `artifacts/sysdesigns/sysdesign-[topic].md` using the matched pattern.

> 🧠 **Decision Trigger:** If 2+ patterns score equally or user hesitates between patterns,
> Agent MUST suggest: `"Multiple patterns match equally. Would you like to /brainstorm to evaluate trade-offs?"`

#### 2.5. Resource Intelligence Scan (Auto)

> This step runs automatically after pattern selection. It scans the workspace's imported resource library to find reference implementations that can improve the design quality.

// turbo

```bash
# Scan resource index for relevant references
echo "=== Resource Audit Dashboard ==="
head -20 Areas/Learning/Resources/README.md 2>/dev/null || echo "No audit dashboard"
echo ""
echo "=== Resource Summaries ==="
for f in $(find Areas/Learning/Resources/ -name "summary.txt" -type f 2>/dev/null | sort); do
  ns=$(echo "$f" | sed 's|Areas/Learning/Resources/||' | sed 's|/summary.txt||')
  echo "--- $ns ---"
  cat "$f"
  echo ""
done
```

**Matching Logic:**

1. **Extract project signals**: From Step 1 (tech stack, platform, DB engine) + Step 2 (matched pattern tags).
2. **Score each resource**: Compare project signals against each resource's `summary.txt` content:
   - **Stack match**: Does the resource use the same framework/runtime? (e.g., Astro, Cloudflare, Next.js)
   - **Pattern match**: Does the resource implement a similar architectural pattern? (e.g., edge workers, auth, CMS)
   - **Domain match**: Does the resource solve a problem relevant to this project's domain?
3. **Classify relevance**:

| Score | Classification | Action |
|:--|:--|:--|
| 🟢 High (2+ signal matches) | Directly applicable reference | **Recommend**: `/resource study [ns] --extract-architecture --target [project]` |
| 🟡 Medium (1 signal match) | Potentially useful insights | **Suggest**: `/resource study [ns] --deep` |
| ⚪ Low (0 matches) | Not relevant | Skip silently |

4. **Present recommendations** (if any found):

```
📚 Resource Intelligence — Found relevant references for this sysdesign:

🟢 HIGH RELEVANCE:
  • github.com/acme/edge-app — Uses Cloudflare Workers + D1 (same stack)
    → /resource study github.com/acme/edge-app --extract-architecture --target [project]

🟡 MEDIUM RELEVANCE:
  • github.com/other/auth-lib — Better Auth implementation patterns
    → /resource study github.com/other/auth-lib --deep

Would you like to study any of these before generating the sysdesign? (Y/N)
```

5. **If user says Yes**: Pause sysdesign generation → execute resource study → return to Step 3 with enriched context.
6. **If user says No (or no relevant resources found)**: Proceed directly to Step 3.

> **Rationale:** This step costs ~200 tokens (scanning summaries) but can dramatically improve sysdesign quality by incorporating real-world patterns from studied resources instead of relying solely on template patterns.

#### 3. Write System Design File

> 🧩 **Sidecar Skill:** Load template from `.agents/skills/sysdesign/references/templates/sysdesign.md`.

Fill in the 6 core domains inside `artifacts/sysdesigns/sysdesign-[topic].md`:
1. **Infrastructure & Deployment** (Docker/Workers configs, Env vars, Secrets).
   * 🧠 **Decision Trigger:** Compute Paradigm trade-offs (e.g., Serverless vs Dedicated VMs, Edge vs Centralized Cloud).
2. **API & Communication Spec** (REST/gRPC endpoints, payload schemas, error formats, pagination strategy, idempotency & retry mechanisms).
   * 🧠 **Decision Trigger:** API Protocol / Communication pattern trade-offs. MANDATORY to specify the **Boundary & Transport Matrix** (Client-to-Server vs Server-to-Server) for APIs involving authentication or cross-subdomain/cross-origin communications (CORS, service bindings).
3. **Database & Storage Architecture** (Schema DDL, ERD, indexes strategy, migration strategy).
   * 🧠 **Decision Trigger:** Storage Paradigm trade-offs (e.g., Relational SQL vs Non-relational Document/Key-Value, Local/Embedded database vs Cloud/Remote database).
4. **Software Topology** (Folder structure, Mermaid component diagrams, sequence diagrams).
   * 🧠 **Decision Trigger:** Code Structure / Rendering trade-offs (e.g., Monolithic vs Microservices, SSR vs SSG, Clean/Hexagonal vs Layered MVC).
5. **Security Architecture & Threat Model** (Trust boundaries, STRIDE analysis, data classification, secret rotation).
   * 🧠 **Decision Trigger:** Identity & Session pattern trade-offs. MANDATORY to verify **Browser Sandbox Constraints** (cookie domain, SameSite, HttpOnly, CORS Credentials) for cookie-based APIs.
6. **Observability & Day-2 Operations** (Structured logging, SLOs, health checks, alerting, tracing).
   * 🧠 **Decision Trigger:** Telemetry & Logging pattern trade-offs (e.g., Push Metrics vs Pull Metrics, SaaS Observability vs Self-hosted/Open-source logs).

> ℹ️ **Design Note:** The tech stack templates and patterns provided in the sidecar skills are **reference models only**. They do not limit the architecture design of the application. The system design should remain strictly tech-agnostic and tailored to the project's actual requirements.

> **Conditional Rendering:** Respect the `scale` field:
> - `small/prototype` → Sections 5 & 6 may be simplified or omitted
> - `medium` → Section 5 required, Section 6 optional
> - `large/enterprise` → All 6 sections required

> 🧠 **Decision Trigger (Trade-off Execution):** While writing any of the 6 domains, if the design calls for one of the triggered choices above (or if the user hesitates), Agent MUST:
> 1. Briefly explain the pros/cons of the options in the chat.
> 2. Ask 1 clarifying question about the project's priorities (e.g., ease of development vs maximum scalability) to resolve it inline.
> 3. If the choice remains unresolved or requires deep structural analysis, suggest:
>    `"This is a critical trade-off in the [Domain Name] domain. Would you like to run /brainstorm to evaluate options before committing?"`
> If approved → run `/brainstorm` and reference the decision in the sysdesign frontmatter:
> ```yaml
> decisions:
>   - brainstorm-YYYY-MM-DD-[topic].md
> ```

#### 3.5. Load Existing Decisions (Auto)

Before writing, Agent MUST scan for related brainstorm decisions:

// turbo

```bash
# Check for existing architectural decisions for this project
ls -t Projects/[project-name]/artifacts/para-decisions/brainstorm-*.md 2>/dev/null | head -10
```

- **If related decisions exist**: Read them and inherit constraints into the sysdesign.
  Agent MUST NOT contradict an existing accepted decision without flagging it.
- **If no decisions exist**: Proceed — decisions will be created on-demand at trigger points.

#### 3.6. Sysdesign Quality Self-Audit (MANDATORY)

> ⛔ **HARNESS GUARD:** Agent MUST complete this step BEFORE presenting the system design to the user for review. Skipping this step is a process violation.

Agent MUST load the system design template `.agents/skills/sysdesign/references/templates/sysdesign.md` and perform a self-compliance check:
1. **Scale Mapping:** Verify the design matches the target project `scale` (small/prototype requires sections 1-4, medium requires 1-5, large/enterprise requires all 6).
2. **Component Completeness:** Verify all required structural elements (DDL SQL, API contracts, Folder Topology, Security Architecture, SLOs/Observability) are specified.
3. **Draft Report:** If any required domain is missing, Agent MUST report the gaps and automatically fill in missing sections or warn the user about design gaps.

#### 4. User Review & Save Gate

Present the design to the user. **Wait for explicit approval (A) before saving.**
Save path: `Projects/[project-name]/artifacts/sysdesigns/sysdesign-[topic].md`.

> 🧠 **Smart Spec Transition Gate (Avoid Blind Spec Suggestions):** Once approved, before proposing the next step:
> 1. **Scan Section 7 (Specs Mapping):** Agent MUST read the `## 7. Specs Mapping` table in the newly saved/updated sysdesign file.
> 2. **Check File Existence:** For each planned or active spec listed in the table, verify if the physical file exists in `Projects/[project-name]/artifacts/specs/`.
> 3. **Propose Correct Action:**
>    - **IF target spec file exists:** Read the spec, and suggest `/spec [project-name] update [topic]` to align it with the updated architecture.
>    - **IF target spec file does NOT exist (or is marked as Planned placeholder):** Suggest `/spec [project-name] create [topic]` to write it from scratch.
>    - Clearly outline this reasoning in the chat.

---

## 📋 Architectural Decision Flow (via /brainstorm)

> **Deprecated:** The standalone `/sysdesign adr` action has been merged into `/brainstorm`.
> All architectural decisions are now managed through the brainstorm decision pipeline.
> Decisions are stored in `Projects/[project-name]/artifacts/para-decisions/` and referenced
> via `decisions: []` metadata in sysdesign and spec files.

**When to trigger `/brainstorm` from sysdesign:**

| Decision Point | Example | Trigger |
|:--|:--|:--|
| Step 1: Design Constraints | "D1 or Postgres?", "Edge or VPS?" | User uncertain about platform/DB |
| Step 2: Pattern Selection | 2+ patterns score equally | Agent detects ambiguity |
| Step 3: Domain Trade-offs | REST vs GraphQL, JWT vs Session | Agent identifies significant trade-off |
| Review: Intentional Drift | Code diverged from design on purpose | Need to document rationale |
| Update: Architecture Change | Major component replacement | One-way door decision |

**Linking decisions to sysdesign:**

After `/brainstorm` completes, Agent MUST add the decision reference to the sysdesign file's frontmatter:

```yaml
---
decisions:
  - brainstorm-2026-07-03-d1-vs-postgres.md
  - brainstorm-2026-07-03-jwt-vs-session.md
---
```

---

## 📋 Action: review

Compare the active codebase against the system design to detect **Architecture Drift**.

### Steps

#### R0. Pre-flight

// turbo

```bash
# List available system designs
ls -t Projects/[project-name]/artifacts/sysdesigns/sysdesign-*.md 2>/dev/null
```

If no sysdesign exists, abort: "No system design found. Run `/sysdesign create` first."

#### R1. Load & Validate System Design (Compliance Check)

> 🧠 **Harness Guard (Template Compliance):** Agent MUST load `.agents/skills/sysdesign/references/templates/sysdesign.md` and check if the target sysdesign file has any missing sections or empty domains based on the project's scale.

Read the target sysdesign file. Extract:
- Declared API endpoints (Section 2)
- Declared DB schema/tables (Section 3)
- Declared folder structure (Section 4)
- Declared security controls (Section 5)
- **Template Gaps:** Identify any missing sections (e.g., missing Section 6 Observability) and list them under the `🔴 Drift Detected` or a dedicated `⚠️ Document Gaps` section in the final Drift Report.

#### R2. Analyze Actual Codebase

**If `--graph` is specified (recommended):**
1. Run `/para-graph build [project-name]` to ensure fresh graph data.
2. Use `graph_query` to find all API route handlers, DB models, and service classes.
3. Use `graph_edges` to map actual dependency relationships.
4. Use `graph_god_nodes` to identify architectural hot spots.

**If no graph:**
1. Scan `repo/` for route definitions, DB schemas, and folder structure using `grep_search` and `list_dir`.
2. Compare manually against the sysdesign declarations.

#### R3. Generate Drift Report

Compare declared architecture (sysdesign) vs actual code and produce a report:

```markdown
# Architecture Drift Report: [project-name]

> **Date**: YYYY-MM-DD
> **Sysdesign**: sysdesign-[topic].md
> **Codebase commit**: [short SHA]

## Summary
- Declared entities: [N] | Actual entities: [M] | Drift score: [X]%

## 🟢 Aligned (Declared & Found)
| Entity | Sysdesign Section | Code Location |
|:--|:--|:--|

## 🔴 Drift Detected (Declared but NOT Found)
| Entity | Sysdesign Section | Expected Location | Issue |
|:--|:--|:--|:--|

## 🟡 Undocumented (Found in Code but NOT in Sysdesign)
| Entity | Code Location | Recommendation |
|:--|:--|:--|
```

#### R4. User Review & Action

Present drift report. Suggest actions:
- **Fix code**: Remove undocumented entities or implement missing declared entities.
- **Fix sysdesign**: Update sysdesign to reflect the actual evolved architecture (`/sysdesign update`).
- **Decomposition & Spec Check Trigger**: If the review detects that major components of the Software Topology, APIs, or DB schemas listed in the sysdesign lack corresponding specifications in `artifacts/specs/`, Agent MUST suggest:
  `"We detected potential gaps between our system design and specs. Run /sysdesign [project-name] audit-specs to analyze spec coverage and identify missing specifications."`
- **Document Decision**:

> 🧠 **Decision Trigger (Architecture Drift):** If drift detected is intentional (representing a change in design direction rather than a bug), Agent MUST NOT silently modify the sysdesign. Agent MUST suggest:
> `"We have detected intentional architecture drift in the codebase. Would you like to run /brainstorm to evaluate this design change before updating our blueprint?"`
> If approved → run `/brainstorm` → document decisions → run `/sysdesign update` next.

---

## 📋 Action: update

Update an existing system design when architecture has changed.

### Steps

#### U0. Pre-flight

// turbo

```bash
# List available system designs
ls -t Projects/[project-name]/artifacts/sysdesigns/sysdesign-*.md 2>/dev/null
```

If multiple sysdesigns exist, ask user which one to update.

#### U1. Load Current Sysdesign

Read the target sysdesign file. Parse each section.

#### U2. Identify Changes

**If `--graph` is specified:**
1. Run `graph_impact_analysis` on the changed component to identify blast radius.
2. Determine which sysdesign sections are affected (API, DB, Topology, Security, Observability).

**If no graph:**
Ask the user: "Which sections have changed? (1: Infra, 2: API, 3: DB, 4: Topology, 5: Security, 6: Observability)"

#### U3. Merge Strategy

For each changed section:
1. **Keep unchanged content**: Do NOT rewrite sections that haven't changed.
2. **Highlight modifications**: Use `<!-- UPDATED: YYYY-MM-DD -->` comment markers on changed subsections.
3. **Add new content**: Append new endpoints, tables, or components.
4. **Remove deprecated content**: Mark deprecated items with `~~strikethrough~~` and add `<!-- DEPRECATED: YYYY-MM-DD, reason -->`.

#### U4. User Review & Save

Present the updated sysdesign diff to the user. **Wait for approval before saving.**
Bump the `date` field in YAML frontmatter.

> 🧠 **Decision Trigger (Blast Radius & Reversibility):** If the update introduces a "one-way door" change (e.g., changing a core database structure, removing deprecations, modifying structural API contracts), Agent MUST suggest:
> `"This update contains significant structural changes (one-way door decisions). Would you like to run /brainstorm to validate the update's blast radius first?"`
> If approved → run `/brainstorm` before saving the updated sysdesign.

---

## 📋 Action: diff

Compare two versions of a system design or before/after states.

### Steps

#### D0. Pre-flight

Identify the two versions to compare:
- **Option A**: Git-based — compare current file vs previous commit: `git diff HEAD~1 -- artifacts/sysdesigns/sysdesign-[topic].md`
- **Option B**: Two sysdesign files — compare `sysdesign-[topic-v1].md` vs `sysdesign-[topic-v2].md`
- **Option C**: Sysdesign vs codebase — redirect to `/sysdesign review`

#### D1. Section-by-Section Diff

For each of the 6 sections, produce a structured comparison:

| Section | Status | Changes |
|:--|:--|:--|
| 1. Infrastructure | 🟢 Unchanged | — |
| 2. API | 🔴 Modified | Added 2 endpoints, changed error format |
| 3. Database | 🔴 Modified | New table `audit_logs`, added 3 indexes |
| 4. Topology | 🟡 Minor | New `services/audit.ts` module |
| 5. Security | 🔴 Modified | Added RBAC trust boundary |
| 6. Observability | 🟢 Unchanged | — |

#### D2. Blast Radius Analysis

From the changed sections, derive which codebase files are likely affected:
- Changed API endpoints → route handlers, tests, client SDK
- Changed DB schema → migration files, ORM models, seed data
- Changed topology → folder structure, imports, barrel files

#### D3. Output Report

Save diff report to `Projects/[project-name]/artifacts/sysdesigns/diff-[topic]-[YYYY-MM-DD].md`.
Suggest next actions: `/sysdesign update` to apply changes, `/brainstorm` to document rationale.

## Related

- `/spec` — Write structured specification within architecture boundaries (downstream)
- `/plan` — Formalize architecture decisions into implementation phases
- `/brainstorm` — Explore problem spaces before committing to architecture
- `/scan-sec` — Security scan to validate Section 5 compliance
- `/para-graph` — Build code graph for architecture review
- `/resource study --extract-architecture` — Extract raw architecture pattern from a resource (upstream)

---

## Action: learn

**Usage:**

```bash
/sysdesign learn <pattern-slug> --source <namespace>  # From resource extraction draft
/sysdesign learn <pattern-slug>                       # From scratch (internet research only)
```

**Goal:** Produce a standardized, catalog-quality architecture pattern by combining signals from a resource extraction draft with internet research on best practices.

### L0. Pre-flight

// turbo

```bash
# Load current catalog for duplicate/overlap check
ls -la .agents/skills/sysdesign/references/architecture-patterns/
cat .agents/skills/sysdesign/SKILL.md
```

### L1. Input Assessment

#### L1a. If `--source <namespace>` provided:

1. Read the resource extraction draft:
   `Areas/Learning/Resources/[namespace]/extracted_architecture/pattern-draft.md`
2. If draft not found → STOP and suggest: `"Run /resource study [namespace] --extract-architecture first."`
3. Parse the draft's Quality Assessment scores.
4. Parse the draft's YAML frontmatter tags.
5. Extract key signals: stack technologies, architectural characteristics, scale estimate.

#### L1b. If no `--source` (from scratch):

1. Ask user for a brief description of the pattern they want to learn.
2. Identify the core technology stack and architectural paradigm.

### L2. Duplicate & Overlap Check

1. Compare the `<pattern-slug>` against existing catalog filenames.
2. Compare extracted `tags` against existing patterns' YAML frontmatter tags.
3. **If exact match found:** STOP and inform user: `"Pattern [name] already exists. Use /sysdesign update to modify it."`
4. **If partial overlap found:** Warn user: `"Overlap detected with [existing-pattern]. Proceed to create a distinct pattern, or merge into existing?"`
5. Wait for user confirmation before continuing.

### L3. Internet Research & Enrichment

Agent MUST perform web research to enrich the pattern beyond what the resource code shows:

1. **Search for best practices:** `search_web` for the identified stack + architectural patterns.
   - Example: `"Astro 7 server islands actions fullstack best practices 2026"`
2. **Search for production patterns:** Real-world deployment configurations, scaling strategies, security hardening.
3. **Search for anti-patterns:** Common mistakes to avoid with this stack.
4. **Compare with industry standards:** How does this architecture compare to well-known reference architectures?

Agent MUST synthesize research findings with resource extraction signals.

### L4. Pattern Generation

Generate the final architecture pattern following the standard sysdesign pattern format:

1. **YAML Frontmatter:** Finalize `tags`, `stack`, `scale`, `complexity` based on combined analysis.
2. **6 Domains:** Fill all sections using the enriched pattern format:
   - § 1 Topology (Mermaid diagram + deployment target)
   - § 2 API & Communication Design (contracts, protocols, error handling)
   - § 3 Database & Storage Architecture (schema, indexes, migrations)
   - § 4 Software Topology (folder structure, component architecture)
   - § 5 Security Architecture (auth, trust boundary, headers)
   - § 6 Observability & Day-2 Operations (logging, metrics, health)
3. **"When to Use" Decision Table:** Compare with similar existing patterns.
4. Quality gate: Each section must have concrete code examples, not just descriptions.

### L5. Review & Promotion

1. Save draft pattern to:
   `Areas/Learning/Resources/sysdesign-drafts/[pattern-slug]-draft.md`

2. ⛔ CHECKPOINT: Present pattern draft to user for review.
   - Display summary table: Tags, Stack, Scale, Section count.
   - Ask: "Approve promotion to catalog, request changes, or discard?"

3. **If approved:**
   - Copy to `.agents/skills/sysdesign/references/architecture-patterns/[pattern-slug].md`
   - Update `SKILL.md` router table to include the new pattern.
   - Report: `"✅ Pattern [pattern-slug] promoted to sysdesign catalog (total: N patterns)."`

4. **If changes requested:**
   - Apply user feedback.
   - Re-present for review (loop back to checkpoint).

5. **If discarded:**
    - Keep draft in `Areas/Learning/` for future reference.
    - Report: `"Draft preserved at [path]. You can revisit later."`

---

## 📋 Action: audit-specs

Compare the system design against all active specs to detect spec gaps and coverage rate.

### Steps

#### AS0. Pre-flight
Check if any system design exists in `Projects/[project-name]/artifacts/sysdesigns/`.
If none, abort: "No system design found. Run `/sysdesign create` first."

#### AS1. Parse Architecture Blueprint
Read the target system design file. Extract:
- Declared API endpoints (Section 2)
- Declared DB schema & tables (Section 3)
- Declared folder structure & Software Topology components (Section 4)

#### AS2. Scan Specs Portfolio
Read all active spec files in `Projects/[project-name]/artifacts/specs/*.md`.
Build a map of:
- Which specs cover which API endpoints
- Which specs cover which database tables/columns migrations
- Which specs cover which Software Topology components (e.g. Frontend UI)

#### AS3. Generate Spec Coverage Report
Compare the architecture blueprint (Step AS1) vs the spec map (Step AS2) to identify:
- **Fully Covered:** Architectural components that are documented in active specs.
- **Uncovered Components (Gaps):** Components, DDL tables, or API endpoints that are designed in the sysdesign but have no corresponding specs.
- **Dangling Specs:** Specs that refer to deprecated endpoints or tables no longer in the sysdesign.

For each identified **Gap (Uncovered Component)**, the Agent MUST perform a physical code search (e.g. scanning files in `repo/` or querying the code graph):
- **IF code implementation exists:** Mark the gap as `Code Present`.
- **IF code implementation does NOT exist:** Mark the gap as `No Code`.

Calculate the **Spec Coverage Score**: `(Covered Components / Total Components) * 100`.

#### AS4. Report & Recommendations
Present the report to the user:
```markdown
# Spec Coverage & Gap Report: [project-name]

> **Date**: YYYY-MM-DD
> **Sysdesign**: sysdesign-[topic].md
> **Specs Count**: [N] active specs
> **Spec Coverage**: [X]%

## 🔴 Spec Gaps Detected (Designed but NOT Specified)
| Component | Category | Status | Recommendation |
|:--|:--|:--|:--|
| [e.g. Frontend UI] | Software Topology | Code Present | `/spec [project] reverse client-portal-ui --sys` |
| [e.g. GET /api/mcp/sse] | API Endpoint | No Code | `/spec [project] create mcp-server --sys` |

## 🟡 Dangling Specs (Specified but NOT in Design)
| Spec File | Entity Reference | Issue |
|:--|:--|:--|
| [e.g. spec-old-db.md] | table `allowed_domains` | Table deprecated in sysdesign |
```

**Recommendation Logic Guidelines:**
- For gaps with status `No Code` -> Recommend `/spec [project] create [topic] --sys` to specify before coding.
- For gaps with status `Code Present` -> Recommend `/spec [project] reverse [topic] --sys` to generate a spec backward from existing code.

Suggest next actions: Run the recommended `/spec create` or `/spec reverse` commands to close the gaps and standardize the documentation portfolio.

---

## 📋 Action: report

Conduct a security, performance, and architecture assessment, generate a formal audit report, and link it to the system design.

### Steps

#### RP1. Pre-flight
Verify the target system design exists in `Projects/[project-name]/artifacts/sysdesigns/sysdesign-[topic].md`.
Ensure the target subdirectory `Projects/[project-name]/artifacts/reports/sysdesign/` exists, create it if it does not.

#### RP2. Conduct Architecture & Security Audit
Analyze the target system design and cross-reference with the active codebase (or code graph if `--graph` is enabled) to identify:
1.  **Security Risks:** Threats from input validation, CORS, session cookie policies, CSRF, or SSRF.
2.  **Performance Bottlenecks:** Database rate limits, roundtrip latencies, or edge runtime limitations.
3.  **Runtime Compatibility Gaps:** Dependency compatibility between environments (e.g., Node.js vs Cloudflare Workers V8 isolates).
4.  **Race Conditions:** Optimistic concurrency control gaps or lack of transactional lock mechanisms.

#### RP3. Generate Assessment Report
Save the report to `Projects/[project-name]/artifacts/reports/sysdesign/sysdesign-report-[topic]-[YYYY-MM-DD].md`.

The report MUST use the following template:
```markdown
---
title: "Security & Architecture Assessment: [Topic]"
status: Completed
date: YYYY-MM-DD
target_sysdesign: "../../sysdesigns/sysdesign-[topic].md"
assessor: Antigravity (Senior Solutions Architect / Tech Lead)
health_score: [X]/100
---

# Security & Architecture Assessment: [Topic]

... [Details on Executive Summary, Risk Matrix, Deep Dive, and Sign-off] ...
```

#### RP4. Link Report to Sysdesign
Update the target `sysdesign-[topic].md` file to append the report reference in the `## Reviews & Risk Assessments` section (Section 9):
```markdown
## 9. Reviews & Risk Assessments

| Đánh giá ngày | Phiên bản | Chỉ số sức khỏe | Trạng thái | Tài liệu đánh giá chi tiết | Người thực hiện |
| :--- | :--- | :--- | :--- | :--- | :--- |
| YYYY-MM-DD | `vX.Y.Z` | **[Score]/100** | `Completed` | [Report Title](../reports/sysdesign/sysdesign-report-[topic]-[date].md) | [Assessor] |
```

#### RP4.1. Apply Remediation Updates (Conditional)
- **IF the `--update` flag is specified:** The Agent MUST automatically extract the remediation recommendations from the generated report (RP3) and apply them to the target `sysdesign-[topic].md` file in the same run (e.g., updating database cache layer or security configurations). Mark any modified sections with the `<!-- UPDATED: YYYY-MM-DD -->` comment to trace modifications.

#### RP5. Report to User
Report the completion of the assessment, highlight the key risks identified, and output the click-able file link to the generated report file.
