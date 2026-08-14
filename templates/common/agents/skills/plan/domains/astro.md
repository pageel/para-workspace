# Plan Domain Rules: Astro SSR & Hybrid Stack

> **Loaded via:** `/plan` workflow Step 3.5 — Stack Reconnaissance when project `tags[]` includes `astro`
> **Location:** `.agents/skills/plan/domains/astro.md`

## 1. Mandatory Dual Static Analysis Gate (Pre-Commit)

Before EVERY `git commit` task in any Phase, Agent MUST inject **both** preceding tasks in this exact order:

1. **`npx astro check` REQUIRED:** `- [ ] 🤖 Static Analysis Gate (1/2): Run npx astro check to verify 0 errors.`
   - **Rationale:** Astro's checker validates component props, slot types, frontmatter scope, and `.astro`-specific diagnostics that `tsc` cannot detect. CI/CD pipelines using `astro check` will fail if skipped locally.
2. **`npx tsc --noEmit` REQUIRED:** `- [ ] 🤖 Static Analysis Gate (2/2): Run npx tsc --noEmit to verify 0 TypeScript compilation errors.`
   - **Rationale:** `tsc --noEmit` catches pure TypeScript errors across `.ts` service files, API endpoints, utility modules, and type-level regressions that `astro check` does not cover (e.g., incorrect function signatures in `src/services/`, missing type exports, `strict` mode violations).

> **Why both?** `astro check` and `tsc --noEmit` have complementary scopes. `astro check` covers `.astro` component layer. `tsc --noEmit` covers `.ts` service/API layer. Skipping either leaves a blind spot. The **ordered pair** is the minimum viable gate for Astro SSR projects.

- **TS6133 Cleanup:** If either tool reports unused import/parameter warnings in test files, Agent MUST include a cleanup task in the same Phase (not defer to a separate Phase).

## 2. CSP Nonce Binding Guard

- **Trigger:** Project has CSP active (detected via `csa.spec_threshold > 0` OR project rules mention "CSP" or "nonce").
- **Rule:** Every `.astro` file created or modified that contains `<script>` or `<script is:inline>` tags MUST include `nonce={Astro.locals.nonce}` attribute.
- **Plan Injection:** Agent MUST add nonce binding verification as a sub-task under any task that creates/modifies `.astro` files with script blocks.
- **Coexistence:** `define:vars` and `nonce` can coexist on the same script tag: `<script is:inline nonce={Astro.locals.nonce} define:vars={{ ... }}>`.

## 3. Browser DevTools Verification Gate (Conditional)

- **Trigger:** IF project rules contain a DevTools/Browser verification mandate (detected from `quality_gates.browser_devtools: true` in project.md, or from project `maintenance.md` containing "DevTools" or "Browser Verification").
- **Rule:** Plan Phases that modify UI components, CSP headers, script tags, or interactive elements MUST include a DevTools MCP verification task:
  ```
  - [ ] 🤖 (DevTools Gate): Start local preview, navigate to [affected-route],
    run list_console_messages to verify 0 CSP/JS errors.
  ```
- **Checkpoint:** Agent MUST add `⛔ CHECKPOINT` after the DevTools verification task to ensure user reviews results before proceeding to git operations.

## 4. Frontmatter Import Order Guard

- **Rule:** In any plan task that modifies `.astro` frontmatter, Agent MUST note: "Static `import` statements MUST be placed before any conditional `if` blocks or early `return` statements in Astro frontmatter."
- **Rationale:** Placing `import` after control flow causes esbuild parse errors during SSR compilation.

## 5. Event-Driven Sub-Component Pattern

- **Trigger:** Plan creates a tabbed/multi-panel layout with sub-components that need to react to parent state changes.
- **Recommended Pattern:** Use `CustomEvent` dispatched on `window`: `window.dispatchEvent(new CustomEvent('[parent]-tab-changed', { detail: { tab: activeTab } }))`
- **Agent SHOULD:** Suggest this pattern in Architecture Overview when plan involves Settings pages or Dashboard with tabs.
