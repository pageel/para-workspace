---
name: HTML Renderer
description: >
  Modular HTML rendering engine for PARA Workspace. Converts Markdown documents, code graphs, and standalone files
  into interactive, self-contained HTML pages with consistent Notion-inspired theming.
  Triggers when the user asks to compile docs to HTML, render graph visualization, export markdown to HTML,
  view docs statically, or preview documents.
version: "1.0.0"
---

# HTML Renderer

> **Purpose:** Modular HTML rendering engine providing consistent, themed HTML output for multiple data types across the PARA Workspace.
> **Architecture:** Plugin-based — each renderer type lives in its own sub-directory with independent scripts and templates, sharing only design tokens from `shared/`.

## Router Table

| Renderer | Trigger | Sub-directory | Status |
|:--|:--|:--|:--|
| **Docs** | "render docs", "compile markdown to html", "convert md to html", "preview docs" | `docs/` | ✅ Active |
| **Graph** | "render graph", "visualize code graph", "graph to html" | `graph/` | ✅ Active |
| **Markdown** | "render single markdown file", "preview single md" | `markdown/` | 🔜 Planned |

## Architecture

```
html-renderer/
├── SKILL.md              # This file — Router & overview
├── shared/               # Design tokens (CSS variables, fonts, color palette)
│   └── theme.css         # Source of truth for all renderers
├── docs/                 # Markdown docs → interactive HTML viewer
│   ├── scripts/render.js
│   └── references/viewer-template.html
├── graph/                # Code graph JSON → force-graph visualization
│   ├── scripts/render.js
│   └── references/viewer-template.html
└── markdown/             # Single .md file → standalone HTML page (planned)
```

### Shared Layer Convention

`shared/theme.css` is the **source of truth** for design tokens. Each renderer's template embeds CSS inline for offline `file://` compatibility. When creating a new renderer:

1. Copy CSS variables from `shared/theme.css` into your template's `<style>` block
2. This ensures visual consistency across all renderer types
3. `shared/theme.css` is NOT loaded at runtime — it's a development reference

## Docs Renderer

> Compiles Markdown documents (`.md`) within the workspace into interactive, self-contained HTML pages following a clean, minimalist design.

### Premium Features

1. **Clean Minimalist Interface**: Light/Dark mode, alert callouts, clean tables
2. **Dynamic Tree & Header Navigation**: File tree sidebar, breadcrumbs, customizable fonts/size
3. **Full-Text Search**: Modal search (Ctrl+K) with title + content indexing and keyword highlighting
4. **VSCode Deep Linking**: Click source path to open in VSCode/Cursor
5. **Agent Feedback Loop**: Chat buttons and heading-level comment anchors for edit requests
6. **Favicon**: Books emoji (📚) SVG favicon for browser tab identification

### Usage

#### Compile all project documentation
```bash
node .agents/skills/html-renderer/docs/scripts/render.js [source_folder] [output_folder]
```

*If `[output_folder]` is omitted, it defaults to creating an hidden directory at `[source_folder]/.html`.*

Example:
```bash
# Outputs to Projects/pageel-crm/docs/.html/ (Recommended)
node .agents/skills/html-renderer/docs/scripts/render.js Projects/pageel-crm/docs

# Outputs to a specific custom directory
node .agents/skills/html-renderer/docs/scripts/render.js Projects/pageel-crm/docs Projects/pageel-crm/custom-html
```

#### Run with Watcher and HTTP Server (Recommended)
```bash
# Starts local live-reload server serving compiled docs from default .html
node .agents/skills/html-renderer/docs/scripts/render.js Projects/pageel-crm/docs --watch
```

### Scripts & Templates

- HTML Template: `.agents/skills/html-renderer/docs/references/viewer-template.html`
- Compiler Script: `.agents/skills/html-renderer/docs/scripts/render.js`

## Graph Renderer

> Compiles codebase graph data (JSONL files inside `.beads/graph/`) into an interactive, self-contained HTML visualization utilizing `force-graph` and Lucide icons.

### Premium Features

1. **Interactive 2D Force-Directed Graph**: Smooth physics-based canvas representing files, functions, classes, interfaces, and variables.
2. **Double Sidebar Layout**:
   - **Left Sidebar**: Controls for filtering node types, setting minimum degree of connections, searching nodes by name, and confidence filtering. Includes a dynamic alphabetical node list.
   - **Right Sidebar**: Details tab showing selected node info (type, signature, line range, VSCode deep linking, and AI Semantic summary/complexity/domain concepts) + Memory tab displaying the project's session logs in a timeline.
3. **Smart Hot Reload**: In watch mode, it spins up an internal server that auto-refreshes the browser graph upon data changes.
4. **Clean Notion-Inspired Theming**: Seamless Light/Dark theme transitions synced to system preferences, using consistent design tokens.
5. **No Native SQLite Binding**: Portably reads static `.jsonl` dumps directly, guaranteeing out-of-the-box compatibility without complex build dependencies.

### Usage

#### Compile project codebase graph
```bash
node .agents/skills/html-renderer/graph/scripts/render.js [project_folder] [output_file]
```

*If `[output_file]` is omitted, it defaults to `[project_folder]/.beads/graph/graph.html`.*

Example:
```bash
# Outputs to Projects/para-workspace/.beads/graph/graph.html (Recommended)
node .agents/skills/html-renderer/graph/scripts/render.js Projects/para-workspace

# Outputs to a specific custom file
node .agents/skills/html-renderer/graph/scripts/render.js Projects/para-workspace docs/graph.html
```

#### Run with Watcher and HTTP Server (Recommended)
```bash
# Starts local watch server (port 3001+) serving compiled graph with hot reload
node .agents/skills/html-renderer/graph/scripts/render.js Projects/para-workspace --watch
```

### Scripts & Templates

- HTML Template: `.agents/skills/html-renderer/graph/references/viewer-template.html`
- Compiler Script: `.agents/skills/html-renderer/graph/scripts/render.js`
