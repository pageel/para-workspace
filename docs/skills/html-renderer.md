# HTML Renderer Skill — Reference

> **Version**: 1.0.0

## Overview

**HTML Renderer** is a modular HTML rendering engine providing consistent, themed HTML output for multiple data types across the PARA Workspace. It converts Markdown documents, code graphs, and standalone files into interactive, self-contained HTML pages with consistent Notion-inspired theming.

## Router Table

| Renderer | Trigger | Sub-directory | Status |
|:--|:--|:--|:--|
| **Docs** | "render docs", "compile markdown to html", "convert md to html", "preview docs" | `docs/` | ✅ Active |
| **Graph** | "render graph", "visualize code graph", "graph to html" | `graph/` | ✅ Active |
| **Markdown** | "render single markdown file", "preview single md" | `markdown/` | 🔜 Planned |

## Architecture

```text
html-renderer/
├── SKILL.md              # Router & overview
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

## Docs Renderer

Compiles Markdown documents (`.md`) within the workspace into interactive, self-contained HTML pages following a clean, minimalist design.

### Premium Features
- **Clean Minimalist Interface**: Light/Dark mode, alert callouts, clean tables.
- **Dynamic Tree & Header Navigation**: File tree sidebar, breadcrumbs, customizable fonts/size.
- **Full-Text Search**: Modal search (Ctrl+K) with title + content indexing and keyword highlighting.
- **VSCode Deep Linking**: Click source path to open in VSCode/Cursor.
- **Agent Feedback Loop**: Chat buttons and heading-level comment anchors for edit requests.

### Usage
```bash
node .agents/skills/html-renderer/docs/scripts/render.js [source_folder] [output_folder]
```

## Graph Renderer

Compiles codebase graph data (JSONL files inside `.beads/graph/`) into an interactive, self-contained HTML visualization utilizing `force-graph` and Lucide icons.

### Premium Features
- **Interactive 2D Force-Directed Graph**: Smooth physics-based canvas representing files, functions, classes, interfaces, and variables.
- **Double Sidebar Layout**: Left controls (filters nodes, searches) + Right details (AI Semantic summary, complexity, timeline).
- **Smart Hot Reload**: Auto-refreshes browser graph upon data changes in watch mode.

### Usage
```bash
node .agents/skills/html-renderer/graph/scripts/render.js [project_folder] [output_file]
```

## Sync

Location | Role | Updated by
:---|:---|:---
`repo/templates/common/agents/skills/html-renderer/` | Source of Truth | Developer (git push)
`Resources/ai-agents/skills/html-renderer/` | Read-only (I9) | `para install` / `update`
`.agents/skills/html-renderer/` | Active copy | `para install` / `update`

---

_See also: [PARA Kit Skill](./para-kit.md) · [Full SKILL.md](../../templates/common/agents/skills/html-renderer/SKILL.md)_
