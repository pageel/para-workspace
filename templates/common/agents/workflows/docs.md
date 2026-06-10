---
description: Generate and maintain project documentation following best practices
source: catalog
---

# /docs [project-name] [action] [--graph] [--watch] [--render]

> **Workspace Version:** 1.8.10 (Modular HTML Renderer)

Generate, review, update, or preview technical documentation for a PARA project. Docs are always created in `Projects/[project-name]/docs/` (internal). Use `publish` to promote selected docs to `repo/docs/` when ready.

## Actions

| Action | Description |
|:--|:--|
| `new` | Analyze project and create appropriate documentation (default) |
| `review` | Audit existing docs for completeness and freshness |
| `update` | Update specific doc files to reflect current state |
| `publish` | Copy selected docs from `docs/` to `repo/docs/` for shipping |
| `watch` | Launch local live-reload server to preview documentation inside browser |

## Options

| Option | Description |
|:--|:--|
| `--graph` | Run Graph Pipeline (Build → Query → Context Bundles) before documentation to anchor docs in real codebase architecture |
| `--watch` | Automatically spin up the local watch server after the creation or update steps are completed |
| `--render` | Compile Markdown documents to HTML and start the live-reload watch server automatically (defaults to compile + watch) |

---

## Principles

> 🛡️ **Constraint:** Read `preferences.language` from `.para-workspace.yml` to get the user's preferred language. All generated documentation MUST be written in this language. Default: `en`.

1. **Internal first.** Always create docs in `Projects/[name]/docs/`. Publish to repo only when ready.
2. **Only document what exists.** Never create docs for planned or hypothetical features.
3. **Source code is truth.** Read the actual codebase before writing — do not invent.
4. **Progressive depth.** Each doc has a clear summary at top → details below.
5. **Versioned and dated.** Every doc carries a version header and "last reviewed" date.
6. **Minimal overhead.** Only create docs the project actually needs based on its type and size.
7. **Source-verified.** Every doc MUST carry a `<!-- ⚠️ SOURCE-VERIFIED -->` guard header listing the source files that were cross-referenced during writing. If a feature is declared in config but has no code usage, mark it `[Planned — Not yet implemented in source]`.

## Doc Locations

Every PARA project has **2 doc locations** serving different purposes:

```
Projects/[project-name]/
├── docs/               ← DEFAULT: All docs created here (internal)
│   ├── architecture.md
│   ├── cli.md
│   └── update-mechanism.md
│
└── repo/docs/          ← PUBLISH ONLY: Promoted from docs/
    ├── architecture.md   # Reviewed, ready to ship
    └── cli.md
```

| Criteria | `docs/` (default) | `repo/docs/` (after publish) |
|:--|:--|:--|
| **Created** | Always — `/docs new` | Only via `/docs publish` |
| **Audience** | Internal team, AI agent | Developer, contributor, user |
| **Git tracked** | ❌ No (PARA workspace only) | ✅ Yes (shipped with repo) |
| **Style** | Detailed, user's language | Concise, 40-100 lines, English |

> **Flow:** `/docs new` → create in `docs/` → user review → `/docs publish` → copy to `repo/docs/`

## Doc Index

Every project’s `docs/` directory MUST have a `README.md` index file. This is the **single source of truth** for doc inventory — agent reads this one file (~10 lines) instead of scanning the directory.

**Template:**

```markdown
# [Project Name] — Documentation

> [One-line project description]

| Document | Description | Updated |
|:--|:--|:--|
| [Architecture](./architecture.md) | System overview & component diagram | YYYY-MM-DD |
| [CLI](./cli.md) | Commands, options, examples | YYYY-MM-DD |

## Strategy (optional)

> Appears only when `docs/strategy/` exists. See Step 3.5.

| Document | Description | Updated |
|:--|:--|:--|
| [Strategy](./strategy/strategy.md) | Overall strategic vision | YYYY-MM-DD |
| [Strategy — [Topic]](./strategy/strategy-[topic].md) | Topic-specific strategy | YYYY-MM-DD |

---

_Updated: YYYY-MM-DD_
```

**Rules:**

- `/docs new` auto-creates this file if it does not exist (Step 7).
- When adding or removing docs, always update this table.
- No prose, no extra sections — just title, description, and the table.

---

## 📝 Action: new

Analyze the project and create documentation appropriate to its type and complexity.

### Steps

#### 0. Agent Indices Pre-flight (all actions)

// turbo

> **Layer 3 defense:** Re-read indices to guard against attention decay.

> ⚠️ **Proactive Context & Trigger Check:** BEFORE generating any docs, YOU MUST:
> 1. Read the project's own domain skill at `Projects/[project-name]/.agents/skills/[project-name]/SKILL.md` (if it exists) to understand project-specific rules and conventions.
> 2. Scan workspace index triggers based on the intended target.

```bash
# Context & Trigger Load (Anti-Cognitive-Bypass)
echo ""
echo "> ⚠️ Loading Project Skill: Projects/[project-name]/.agents/skills/[project-name]/SKILL.md"
cat Projects/[project-name]/.agents/skills/[project-name]/SKILL.md 2>/dev/null || echo "No project specific skill found."
echo ""
echo "> ⚠️ Proactive Trigger Scan: .agents/rules.md & .agents/skills.md"
cat .agents/rules.md 2>/dev/null | head -n 30
cat .agents/skills.md 2>/dev/null | head -n 30
```

3. Check `project.md` for `agent.rules` / `agent.skills` — if true, re-read project indices too

#### 0.5. Graph Context Pipeline (if --graph)

// turbo

If the `--graph` flag is provided, execute the graph intelligence pipeline BEFORE reading the contract:

1. **Build Graph:** Run `/para-graph build [project-name]` to ensure graph data is up-to-date.
2. **Identify Target Nodes:** Use MCP tools `graph_query` and `graph_god_nodes` to locate architectural nodes and hot spots related to the project's core modules.
3. **Deep Context:** Use MCP tools `graph_context_bundle` and `graph_edges` on the identified nodes to gather callers, callees, dependencies, and structural relationships.
4. **Impact Analysis:** Use `graph_impact_analysis` on God nodes to map upstream/downstream dependencies — essential for writing accurate architecture diagrams and component relationship docs.
5. **Pattern Verify (Step G):** If the documentation covers specific code patterns (e.g., error handling, logging, environment variables), run `grep_search` to cross-validate and get the exact file counts and locations.
6. **Inject Context:** Keep this enriched graph and grep intelligence in memory to ground the documentation in the actual codebase structure, preventing hallucinations and ensuring accuracy.


#### 1. Read Project Contract

// turbo

Read `Projects/[project-name]/project.md` to extract:

- **Goal** and **Description**
- **Tech Stack** (language, framework, tooling)
- **Status** (active, dormant, completed)
- **Definition of Done**

#### 2. Analyze Source Code

// turbo

> 🔍 **Memory-Assisted Docs:** Before analyzing source code, Agent SHOULD use `memory_search` to find past documentation decisions and architectural patterns. This ensures docs build on existing knowledge rather than re-discovering.

Scan the project's source code to understand structure:

```bash
# Get directory tree (depth 3, ignore common noise)
find Projects/[project-name]/repo -maxdepth 3 -type f \
  ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/dist/*' \
  ! -path '*/.astro/*' ! -path '*/.next/*' | head -80
```

Extract:

- **File structure** and key directories
- **Entry points** (main, index, CLI, etc.)
- **Config files** (package.json, astro.config, tsconfig, etc.)
- **Internal libraries** (lib/, utils/, helpers/)

#### 3. Classify Project Type

Determine what documentation this project needs (all created in `docs/`):

| Project Type | Indicators | Recommended Docs |
|:--|:--|:--|
| **CLI Tool** | `cli/`, shell scripts, `bin/` | architecture, cli, development, update-mechanism |
| **Web App** | Astro/Next/Vite, `src/pages/` | architecture, development, deployment |
| **Library/SDK** | `lib/`, `src/index.ts`, exports | architecture, api-reference, getting-started |
| **Website** | Static pages, CMS integration | architecture, deployment, content-structure |
| **Template** | `templates/`, scaffolding scripts | architecture, cli, workflows, kernel |
| **Ecosystem** | `satellites` field, `type: ecosystem` | architecture, strategy/, roadmap |

> **Rule:** Do NOT create all possible docs. Only create what the project type requires.

#### 3.5. Strategy Docs Check

// turbo

> 🛡️ **Field-gated (v1.6.3):** Uses `strategy` field from `project.md` instead of filesystem probe.

1. Check `strategy` field from `project.md` (already loaded in Step 1):

2. **IF has value** — Strategy doc exists:
   - Resolve path (IF starts with `@` → cross-project: `Projects/{ecosystem}/...`, ELSE → local)
   - Read file list from strategy directory (~1 ls)
   - Flag for review/update if any file's "Last reviewed" date > 30 days

3. **IF null/empty** — Check if project should have strategy:
   - `project.md` has `satellites` field? → 🔴 Strong suggest
   - `project.md` has `ecosystem` field? → 🟡 Soft suggest
   - Backlog has > 5 active features? → 🟢 Optional suggest
   - No match → Skip silently

4. Suggest (if matched):
   ```
   📄 This project has no strategy docs.
      Create docs/strategy/strategy.md? (y/n)
   ```

**Strategy field lifecycle (v1.6.3):**

When user confirms creation (y):
1. Create the strategy doc in `docs/strategy/strategy.md`
2. Set `strategy` field in `project.md`:
   ```yaml
   strategy: docs/strategy/strategy.md
   ```
3. If creating for satellite from ecosystem, suggest:
   ```yaml
   strategy: "@{ecosystem}/docs/strategy.md"
   ```
4. Log: `📄 strategy field set in project.md`

> **Smart Routing from /brainstorm (D6):** When `/brainstorm` Step 5 selects
> Option D (/docs), this workflow detects strategy-related topic keywords
> ("strategy", "product", "direction", "vision") and routes output to
> `docs/strategy/` instead of `docs/`. Logic lives HERE — `/brainstorm`
> itself does NOT change.

#### 4. Read Doc Index (if exists)

// turbo

> ⚠️ **Token optimization:** Read `Projects/[project-name]/docs/README.md` only. Do NOT `ls` or read individual doc files.

- **Index exists** → extract the table to know what docs are already covered. Skip those.
- **Index does not exist** → fresh project, all docs are new. Step 7 will auto-create the index.

#### 5. Present Doc Plan

Before writing, present a plan to the user:

```
📖 Documentation Plan: [Project Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Project Type: [CLI Tool / Web App / Library / Website]
📁 Location: Projects/[project-name]/docs/ (internal)

📝 Docs to create:
  1. 🆕 architecture.md — System overview & component diagram
  2. 🆕 cli.md — Command reference and usage
  3. ⏭️ roadmap.md — Already exists, skipping

� Tip: Use `/docs publish` later to promote to repo/docs/

❓ Create these docs? (y/n, or specify numbers)
```

Wait for user confirmation before proceeding.

#### 6. Generate Documentation

// turbo

Create each approved document using the appropriate template from Section "Doc Templates" below.

**For each doc file:**

1. Read the relevant source files (max 5 files per doc to limit tokens)
2. Write documentation based on **actual code**, not assumptions
3. Include the standard header with version and date
4. Save to `Projects/[project-name]/docs/[doc-name].md`
5. **Git Guard**: DO NOT run `git commit` for files created in `docs/` (internal docs are not git-tracked).

#### 6.1. Auto-Insert Graph Anchors (MANDATORY)

When generating or updating any documentation sections (e.g. classes, functions, files, schemas, APIs):
1. **Identify Node IDs:** The Agent MUST identify the corresponding code entities (functions, classes, schemas, config files) that are referenced or explained in each section using Code-Graph queries.
2. **Inject Anchors:** The Agent MUST automatically insert the HTML comment annotation `<!-- @graph-node: nodeId -->` immediately before the section heading (H2 or H3).
3. **No Ceremony:** Do NOT wait for user instructions to do this — it is a default requirement for codebase traceability.

#### 6.2. Source Verification Gate

> ⛔ CHECKPOINT: Agent MUST NOT proceed to Step 7 until verification is complete.

For EVERY doc created in Step 6, perform anti-hallucination verification:

1. **Path Verification:** Confirm every file path referenced in the doc actually exists using `find` or `ls`.
2. **Function Verification:** Confirm every function/class name referenced matches the actual export in source code.
3. **Config Verification:** For each env var, binding, or config key mentioned, verify it exists in `wrangler.jsonc`, `package.json`, or `.env.example`.
4. **State Verification:** If a config binding exists but has NO code using it, the doc MUST mark it as `[Planned — Not yet implemented in source]`.
5. **Guard Header:** Insert `<!-- ⚠️ SOURCE-VERIFIED — Cross-referenced with [file1, file2, ...] on YYYY-MM-DD -->` after the document title.

**Quick Verification Script:**

```bash
# Extract all src/ paths from the doc and verify they exist
grep -oP 'src/[a-zA-Z0-9_./-]+' Projects/[project-name]/docs/[doc-name].md | sort -u | while read f; do
  test -f "Projects/[project-name]/repo/$f" && echo "✅ $f" || echo "🔴 MISSING: $f"
done
```

If any `🔴 MISSING` is found → fix the doc before proceeding.

#### 6.3. Anchor Linking

// turbo

> **Gate:** Only runs if the project graph is available (`Projects/[project-name]/.beads/graph/` exists).

1. Scan the newly created Markdown document for anchor annotations `<!-- @graph-node: nodeId -->`.
2. If found, call the MCP tool `graph_link_docs` with the parameters:
   - `projectName`: Name of the project
   - `docPath`: Relative path to the document file (e.g., `docs/architecture.md`)
3. This command parses all anchors in the file, links them to the corresponding code entities, and updates the `docAnchors` attribute on the graph.

#### 7. Create or Update Doc Index

// turbo

Create or update `Projects/[project-name]/docs/README.md` using the template from the **Doc Index** section above. Add a row for each doc created in Step 6.

#### 8. Log in Session

// turbo

Append to current session log:

```markdown
### Documentation Generated

- **Project**: [project-name]
- **Docs created**: [list of files]
- **Location**: `Projects/[project-name]/docs/`
```

#### 8.5. Graph Memory Push (CONDITIONAL)

> **Gate:** Only trigger if project has `.beads/graph/` directory.

1. Check graph availability:
   ```bash
   test -d "Projects/[project-name]/.beads/graph" && echo "✅ Graph Memory available" || echo "⏭️ No graph — skip memory push"
   ```

2. **IF graph exists:**
   Push the docs creation summary via MCP `memory_push`:
   - **kind:** `docs-generated`
   - **content:** List of docs created + project type classification
   - **sessionId:** `YYYY-MM-DD-docs-[project-name]`
   - **metadata:** `{ "docs_created": ["architecture.md", ...], "project_type": "[type]" }`

3. **Curate memory:** After pushing, call `memory_curate(projectName)` to consolidate raw memory events into semantic slices.

4. **IF no graph** → Skip silently.

#### 9. HTML Compilation & Live Watch

// turbo

1. Compile the newly generated Markdown documents to HTML (stored in `docs/.html/`):
   ```bash
   node .agents/skills/html-renderer/docs/scripts/render.js Projects/[project-name]/docs
   ```

2. **IF `--watch` or `--render` is specified:**
   Start the local live-reload server immediately:
   ```bash
   node .agents/skills/html-renderer/docs/scripts/render.js Projects/[project-name]/docs --watch
   ```

3. **Output Link**: The agent MUST print the clickable `file://` URL of the generated `README.html` (using absolute workspace path) and guide the user on how to open it in their browser.

---

## 📋 Action: review

Audit existing documentation for completeness, accuracy, and freshness.

### Steps

// turbo

1. Read `Projects/[project-name]/docs/README.md` (Doc Index) to get the authoritative document list.
   - **Index Drift Check**: Cross-check the list of physical files in `docs/` against the inventory declared in the Doc Index table (ignore historical log folders like `docs/researches/` or daily `sessions/` data).
   - If files exist in the folder (excluding ignored ones) but are missing from the Doc Index, report them as `⚠️ Index Drift` to avoid orphan documentation.
2. **Traceability & Staleness check**: If the graph is available, perform codebase-to-docs checks:
   - **Undocumented God Nodes**: Invoke `graph_god_nodes` to fetch the top-connected core components. Cross-check these God Nodes against their documentation status (where `docAnchors` is empty or missing).
   - **Unenriched God Nodes**: For documented (linked) God Nodes, check if their nodes in the graph database contain a non-empty `semantic.description`. If a God Node is documented but not enriched, flag it.
   - **Stale linked nodes**: Use `graph_query` to find stale nodes (where `staleSince` is not null). Correlate with the time when code signatures were changed.
   - **Traceability Alignment**: Scan the index-registered documents for graph anchors (`<!-- @graph-node -->`). If any index-registered document contains anchors but lacks active links in the graph database, highlight them for sync.
   - **Target-Seeking Loop Target**: Report the exact ratio of documented God Nodes vs total God Nodes. Instruct the agent to run an active target-seeking loop to reach 100% coverage (adding anchors for all God Nodes and resolving all unlinked anchors).
3. For each doc, check:
   - **Freshness**: Is "last reviewed" date > 30 days old?
   - **Accuracy**: Does the doc reference files/functions that still exist?
   - **Completeness**: Are there gaps (e.g., does Architecture doc miss new modules)?
   - **Staleness**: Are there any linked nodes marked as stale (outdated due to code signature changes)?
4. Present audit report:

```
Configure review report:

📖 Docs Audit: [Project Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| Document | Status | Issue |
|:--|:--|:--|
| architecture.md | ✅ OK | — |
| cli-reference.md | ⚠️ Stale | Last reviewed 45 days ago |
| deployment.md | 🔴 Missing | No deployment docs found |

⚠️ Index Drift (Orphan Files):
- `[doc-name].md` — Exists on disk but is missing from README.md index.

🔴 Undocumented Core Components (God Nodes):
- `[nodeId]` (calls/callers: N) — Missing docAnchors. Recommendation: Add graph anchor to docs.

⚠️ Unenriched Core Components (God Nodes):
- `[nodeId]` (calls/callers: N) — Documented but missing semantic enrichment. Recommendation: Run `/para-graph enrich` before `/docs update --graph`.

💡 Recommendations:
  1. Update cli-reference.md (new commands added since last review)
  2. Create deployment.md (project has deploy scripts)
  3. Document core component `[nodeId]` in architecture.md or target guides.
  4. Register `[doc-name].md` in the README.md index.
  5. Run `/para-graph enrich` to add semantic descriptions to unenriched God Nodes.

❓ Fix these issues now?
```


---

## ✏️ Action: update

Update specific documentation to reflect current project state.

### Steps

#### 1. User specifies which doc to update (or "all").

#### 1.5. Index-Driven File List

// turbo

> ⚠️ **MANDATORY**: Agent MUST read the doc index before proceeding.
> The index is the authoritative file list — do NOT rely solely on user input.

1. Read `Projects/[project-name]/docs/README.md`
2. Parse ALL file entries from the tables (across all sections: Features, Architecture, References, Guides, Workflows, etc.)
3. Build a checklist of files to check/update
4. For "update all": iterate **every file** in the checklist — no exceptions
5. For specific file: verify the file exists in the index, warn if not listed

> **Anti-drift guard:** If a file exists in `docs/` but is NOT in the index, report it to the user and suggest adding it.

#### 2. Re-read the relevant source code.

#### 3. Diff current doc against actual code to find discrepancies.

#### 4. Update the doc and bump "last reviewed" date.

#### 4.5. Re-Link Anchors

If the graph is available, re-run `graph_link_docs(projectName, links)` for the updated document file to reset the `staleSince` state and refresh graph linkages.

> **v0.16.1+:** `linkDocs` now auto-initializes `semantic: {}` for non-enriched nodes — all anchors will link successfully regardless of enrichment status.

#### 5. Log in session.

#### 5.5. Update Index Statistics (if --graph)

// turbo

> **Gate:** Only runs if `--graph` flag is provided and `.beads/graph/` exists.

1. Call `graph_query(projectName)` to get total enrichable node count
2. Count how many nodes have `docAnchors` (non-empty array)
3. Count docs in index that contain `<!-- @graph-node -->` anchors
4. Call `graph_god_nodes(projectName)` to get top-connected God Nodes count (G)
5. Count how many of these God Nodes have non-empty `docAnchors` (L)
6. Count how many of these God Nodes have non-empty `docAnchors` AND non-empty `semantic.description` (E)
7. Check for stale nodes (where `staleSince` is not null AND have `docAnchors`)
8. Update or create the `## Graph Traceability` section in `docs/README.md`:

```markdown
## Graph Traceability

> Auto-generated by `/docs update --graph` | Last scan: YYYY-MM-DD

| Metric | Value |
|:--|:--|
| Total docs | N |
| Docs with graph anchors | M (P%) |
| Graph nodes with docAnchors | X/Y enrichable (Z%) |
| God Nodes documented | L/G top-connected (K%) |
| God Nodes fully covered (Enriched & Linked) | E/G (Y%) |
| Stale docs (code changed) | S |
```

If stale docs are found, append a table:

```markdown
### Stale Documents

| Document | Stale Since | Affected Nodes |
|:--|:--|:--|
| architecture.md | 2026-05-20 | `CodeGraph`, `AstStore` |
```

#### 6. **HTML Compilation & Watch (Optional)**:
   // turbo
   
   Compile the updated Markdown documents:
   ```bash
   node .agents/skills/html-renderer/docs/scripts/render.js Projects/[project-name]/docs
   ```
   
   If `--watch` or `--render` flag is provided, start the live-reload watch server:
   ```bash
   node .agents/skills/html-renderer/docs/scripts/render.js Projects/[project-name]/docs --watch
   ```

   After compilation, the agent MUST print the clickable `file://` URL of the generated `README.html` (using absolute workspace path) and guide the user on how to open it.
   
#### 7. **Git Guard**: DO NOT run `git commit` or `git add` for files in `docs/` (internal docs are not git-tracked).

---

## 📤 Action: publish

Copy selected docs from `docs/` (internal) to `repo/docs/` (ship with code).

### Steps

#### 1. Read Doc Index

// turbo

Read `Projects/[project-name]/docs/README.md` to list available docs.

#### 2. User selects which docs to publish

Present the list and let the user choose:

```
📤 Publish to repo/docs/:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Available in docs/:
  1. architecture.md (120 lines)
  2. cli.md (85 lines)
  3. update-mechanism.md (350 lines)

❓ Which docs to publish? (numbers, or "all")
```

#### 3. Adapt for repo audience

Before copying, adapt the doc to match the repo's standards:

1. **Detect repo language**: Check existing `repo/docs/` or `repo/README.md` to determine the repo's language.
2. **Translate if needed**: If internal doc language ≠ repo language, translate to match.
3. **Condense**: Shorten to 40-100 lines if internal doc is a deep-dive.
4. **Fix references**: Replace workspace-specific paths with relative repo paths.

> **Ask the user**: _"Should this doc be condensed for the repo, or published in full?"_

#### 4. Copy to repo/docs/

// turbo

```bash
mkdir -p Projects/[project-name]/repo/docs/
cp Projects/[project-name]/docs/[selected].md Projects/[project-name]/repo/docs/
```

#### 5. Log in session

// turbo

Append to current session log:

```markdown
### Docs Published to Repo

- **Files**: [list]
- **From**: `docs/` → `repo/docs/`
```

---

## 📡 Action: watch

Start the local watch server with live reload for project documentation.

### Steps

// turbo

1. Spin up the watcher to track changes in Markdown files and render them dynamically:
   ```bash
   node .agents/skills/html-renderer/docs/scripts/render.js Projects/[project-name]/docs --watch
   ```

2. **Output Link**: The agent MUST print the clickable `file://` URL of the generated `README.html` (using absolute workspace path) and guide the user on how to open it in their browser.

---


## Doc Templates

> 🧩 **Sidecar Skill:** Load document templates from the `docs` skill:
> - `.agents/skills/docs/references/architecture.md`
> - `.agents/skills/docs/references/cli.md`
> - `.agents/skills/docs/references/deployment.md`
> - `.agents/skills/docs/references/changelog.md`
> - `.agents/skills/docs/references/strategy.md`
>
> Load only the template matching the document type being generated in Step 6.

---

> **Flow:** `/docs new` creates in `docs/` → review & iterate → `/docs publish` copies to `repo/docs/`.
> **Rule:** If writing a doc yields a reusable lesson → extract it with `/learn`.
> **Learning docs** go to `Areas/Learning/` (via `/learn`), not in project docs.

## Output Checklist

- [ ] Project contract and source code analyzed
- [ ] Project type classified
- [ ] Existing docs inventoried (no duplicates)
- [ ] Doc plan presented and approved by user
- [ ] Docs written from actual code (not assumptions)
- [ ] All docs have version header and "last reviewed" date
- [ ] **Source Verification Gate passed** (Step 6.5 — all paths, functions, configs verified)
- [ ] **Guard header `<!-- ⚠️ SOURCE-VERIFIED -->` present** in every doc file
- [ ] `docs/README.md` index created or updated
- [ ] Session log updated

## Related

- `/learn` — Extract reusable lessons from project experience
- `/plan` — Create implementation plan (may reference architecture docs)
- `/end` — End session (may trigger doc updates for significant changes)
- `/release` — Pre-release quality gate (checks doc completeness)
- `/verify` — Verify task completion (may use docs as checklist)
