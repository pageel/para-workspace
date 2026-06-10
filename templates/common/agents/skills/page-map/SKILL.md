---
name: page-map
description: AI Agent skill to read, manage, and manipulate website visual structure using PAGE_MAP.md and BLUEPRINT.md — for both pages and components.
---

# Skill: page-map

> **Version**: 2.0.0

> [!WARNING]
> **Dogfooding Status**: This skill is undergoing live testing (dogfooding) at `Projects/pageel-website/repo/.pageel/page-maps/`. The `.pageel/` directory in that repository currently contains test data for this skill. Before pushing to production, review and complete the page-map files in the repo to ensure:
> 1. The map content matches the actual code precisely (no outdated info).
> 2. The `pages/` and `components/` directory structures strictly comply with the v2.0.0 spec of this skill.
> 3. The repository does not contain redundant testing artifacts — keep only finalized maps.

## Intent
Use this skill when attempting to modify page layout, analyze frontend structure, or create new views/components. This skill anchors the AI Agent's structural understanding before analyzing complex source code (`.astro`, `.tsx`, etc.).

**Scope**: Applies to both **full pages** (e.g., `index.astro`, `features.astro`) and **individual components** (e.g., `Hero.astro`, `Calculator.tsx`). A component-level map captures the internal layout of a single reusable unit; a page-level map captures how those components are assembled into a route.

## Instructions

### 1. Directory Structure

All maps are stored under `.pageel/page-maps/` at the repository root, organized into two subdirectories:

```text
.pageel/page-maps/
├── pages/              # Full route-level pages
│   ├── index/
│   │   ├── PAGE_MAP.md
│   │   └── BLUEPRINT.md
│   └── features/
│       ├── PAGE_MAP.md
│       └── BLUEPRINT.md
└── components/         # Individual reusable components
    ├── Hero/
    │   ├── PAGE_MAP.md
    │   └── BLUEPRINT.md
    ├── FeatureGrid/
    │   ├── PAGE_MAP.md
    │   └── BLUEPRINT.md
    └── Calculator/
        ├── PAGE_MAP.md
        └── BLUEPRINT.md
```

**Rules:**
- **Pages** → `.pageel/page-maps/pages/<page-name>/`
- **Components** → `.pageel/page-maps/components/<ComponentName>/`
- Component directory names use **PascalCase** matching the component filename (e.g., `Hero`, `FeatureGrid`).
- Page directory names use **lowercase** matching the route slug (e.g., `index`, `features`, `privacy`).

### 2. Identify Existing Maps

Whenever tasked with analyzing or altering a UI element, search for `PAGE_MAP.md` and `BLUEPRINT.md` in this order:
1. **`.pageel/page-maps/components/<ComponentName>/`** — For component-level work.
2. **`.pageel/page-maps/pages/<page-name>/`** — For page-level work.
3. **Current or target directory** — Fallback for legacy or simple setups.

### 3. Reading Format

The structural layout relies on bracketed section names like `[Section.Subsection]`.

- **`PAGE_MAP.md`**: ASCII wireframes illustrating the visual layout geometry. Each major zone is labeled with a `[Section.Subsection]` tag.
- **`BLUEPRINT.md`**: A table mapping those tags to exact source files, props, and notes.

**Naming convention for tags:**
- Page maps: `[page.section]` — e.g., `[index.hero]`, `[index.features]`
- Component maps: `[Component.Section]` — e.g., `[Hero.TechStackHeader]`, `[Calculator.ResultCard]`

### 4. Modifying Code

Search within the target source code for inline tags such as `{/* [Section.Subsection] */}`. Apply your edits contextually near the tags. DO NOT alter sections outside of the designated tags unless specifically requested.

### 5. Creating New Maps

When asked to create a new map:

1. **Determine scope**: Is this a page or a component?
2. **Create `PAGE_MAP.md`** containing ASCII wireframes that illustrate the layout vision. Use `[Section.Subsection]` references. For complex components, break down into logical zones (header, body, footer, sidebar, etc.).
3. **Create `BLUEPRINT.md`** to map those tags to the intended component files, props, and implementation notes.
4. **Store files** in the correct subdirectory:
   - Component → `.pageel/page-maps/components/<ComponentName>/`
   - Page → `.pageel/page-maps/pages/<page-name>/`

### 6. Cross-Referencing (Page ↔ Component)

Page maps and component maps must be **linked bidirectionally** so navigation between layers is seamless.

**In page-level `PAGE_MAP.md`:**
- Each section tag should include an arrow referencing its component map: `[index.hero] → components/Hero/`
- This tells the reader exactly where to find the detailed internal wireframe.

**In page-level `BLUEPRINT.md`:**
- Add a **Component Map** column with relative links to the component's `PAGE_MAP.md`:
  ```markdown
  | Section | Source | Hydration | Component Map |
  | :--- | :--- | :--- | :--- |
  | `[index.hero]` | `src/components/Hero.astro` | Static | [`components/Hero/`](../../components/Hero/PAGE_MAP.md) |
  ```
- Add a **Hydration** column indicating the Astro directive (`client:load`, `client:visible`, or `Static`).
- For inline sections without a dedicated component, use `—` with a parenthetical note: `— (inline: description)`.

**Why this matters:**
- Without cross-references, the agent must guess which component map corresponds to which page section.
- The hydration column prevents mistakes when modifying interactive vs. static components.

### 7. Practical Guidelines (Lessons Learned)

- **Component maps capture internal layout**: A component map should visualize the nested HTML structure _within_ the component, not just a placeholder box. This helps catch nesting bugs (e.g., unclosed `<div>` tags shifting sections).
- **Page maps show composition**: A page map shows which components appear in what order and their relative positioning — it does not duplicate component internals.
- **Keep wireframes honest**: Describe what the UI _actually renders_, not an idealized version. If a section shows a mockup dashboard built from HTML/CSS tags (not a real screenshot), label it as "Interactive UI Mockup", not "Dashboard Image".
- **Update maps when code changes**: After fixing layout bugs or restructuring components, update the corresponding `PAGE_MAP.md` to stay in sync.

### 8. Site Index (INDEX.md)

Create an **`INDEX.md`** file at the root of `.pageel/page-maps/` to serve as the **overall master map** of the entire website. This file tracks the page-mapping progress of each page and component.

**Vị trí**: `.pageel/page-maps/INDEX.md`

**Cấu trúc bắt buộc:**

```markdown
# Site Map Index

> Last updated: YYYY-MM-DD

## Pages

| Route | Source | Status | Map |
| :--- | :--- | :--- | :--- |
| `/` | `src/pages/index.astro` | ✅ Mapped | [pages/index/](pages/index/PAGE_MAP.md) |
| `/features` | `src/pages/features.astro` | ✅ Mapped | [pages/features/](pages/features/PAGE_MAP.md) |
| `/blog` | `src/pages/blog/index.astro` | ⬜ Pending | — |

Pages: `████████░░░░░░░░░░░░` 3/18 (17%)

## Components

| Component | Source | Used by | Status | Map |
| :--- | :--- | :--- | :--- | :--- |
| Navbar | `Navbar.tsx` | All pages | ✅ Mapped | [components/Navbar/](components/Navbar/PAGE_MAP.md) |
| Hero | `Hero.astro` | index | ✅ Mapped | [components/Hero/](components/Hero/PAGE_MAP.md) |
| SEO | `SEO.astro` | All pages (layout) | ⏭️ Skip | — (utility) |

Components: `██████████████████░░` 9/11 (82%)
```

**Status icons:**
- `✅ Mapped` — PAGE_MAP.md + BLUEPRINT.md are completed
- `⬜ Pending` — Map not created yet
- `⏭️ Skip` — Utility component / no visual interface (e.g., SEO, OptimizedImage)

**Progress bar format:**
- Use the block characters `█` (filled) and `░` (empty), with a total length of 20 characters.
- Formula: `filled = round(mapped / total * 20)`, remaining is `░`.
- Follow with `X/Y (Z%)`.

**Shared components (used across multiple pages):**
- The **Used by** column lists the pages utilizing that component (e.g., `index, features` or `All pages`).
- A component only needs **a single map** located at `components/<Name>/` — do not duplicate maps for each page.
- In the page's BLUEPRINT, simply link to the shared component map (as defined in §6).

- Always update INDEX.md whenever creating or deleting a page map.
- List **all** pages and components in the source code, including those without maps (to clearly identify the coverage gap).
- Calculate the progress bar at the bottom of each table to visualize progress.
