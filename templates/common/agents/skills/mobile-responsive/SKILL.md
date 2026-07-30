---
name: mobile-responsive
description: Complete AI Agent harness for mobile responsive UI engineering — includes fluid layout rules (clamp, container queries), automated AST/CSS linter script (scripts/check-responsive.js), DOM Bounding Box inspection for Chrome DevTools MCP (scripts/inspect-viewport.js), and responsive component contract templates. MANDATORY: Trigger when building, auditing, or refactoring UI components, CSS/Tailwind styles, Astro/React/HTML layouts, or verifying mobile responsiveness.
version: 1.1.0
---

# Mobile Responsive Engineering Harness

> **Skill Version:** 1.1.0 | **Scope:** Global (All Web Projects)

This skill equips AI Agents with a 4-Layer Quality Harness to design, code, audit, and visually inspect mobile-responsive web interfaces without layout breakage or visual bugs.

## 🎯 The 4-Layer Control Pipeline

1. **Layer 1 (Write-Time Fluid Tokens):** Enforce zero-hardcoded pixel layout rules. Use `clamp()`, `min()`, `max()`, Flexbox wrap, and Container Queries.
2. **Layer 2 (Design Contract):** Define `PAGE_MAP.md` Responsive Component Contracts for complex layouts before writing code.
3. **Layer 3 (Static Linter Guard):** Execute `node .agents/skills/mobile-responsive/scripts/check-responsive.js <file-or-dir>` to catch CSS anti-patterns at build time.
4. **Layer 4 (Visual Runtime Inspection):** Use Chrome DevTools MCP `evaluate_script` with `scripts/inspect-viewport.js` on viewports `320px`, `375px`, `768px` to catch actual DOM overflows.

## 📋 Quality Rules & Invariants

- **R1 (Zero Fixed Layout Widths):** Never use `width: 600px` or `w-[600px]`.
  - *Why:* A 600px fixed container overflows on any device < 600px viewport width, causing horizontal scroll and breaking touch interactions. Always use `max-width: 100%`, `w-full`, or `minmax()`.
- **R2 (Minimum Touch Targets):** All interactive elements (`<button>`, `<a>`, `<input>`, `<select>`) MUST have minimum dimensions of `44x44px` (or `min-h-[44px] min-w-[44px]`).
  - *Why:* Apple HIG and WCAG 2.5.5 require 44×44px minimum. Smaller targets cause mis-taps on mobile, especially for users with motor impairments.
- **R3 (Text Overflow Safety):** All containers with dynamic or long text MUST include `break-words` (`overflow-wrap: break-word`) and `max-width: 100%`.
  - *Why:* A single long URL, email, or hashtag without `break-word` can push the container width past the viewport, causing the entire page to scroll horizontally.
- **R4 (Media Fluidity):** All `<img>`, `<video>`, `<svg>`, `<canvas>`, `<iframe>` elements MUST have `max-width: 100%; height: auto;`.
  - *Why:* A 1200px-wide image without `max-width: 100%` will overflow a 375px iPhone screen, creating a horizontal scrollbar and hiding page content.
- **R5 (Viewport Meta Tag):** HTML pages MUST contain `<meta name="viewport" content="width=device-width, initial-scale=1.0">`.
  - *Why:* Without this meta tag, mobile browsers render the page at desktop width (~980px) and zoom out, making all text unreadable and interactive elements untappable.
- **R6 (Off-Screen Drawer Visibility Guard):** Off-screen navigation drawers (`right: -100%`, `left: -280px`, `transform: translateX(-100%)`) MUST include `visibility: hidden` or `pointer-events: none` when closed.
  - *Why:* Position-offset drawers without `visibility: hidden` remain in the browser's scrollable canvas calculation, causing horizontal swipe/scroll overflow on touch devices.

## 🔄 Layer 3→4 Workflow (Step-by-Step)

When auditing or fixing responsive issues, follow this pipeline:

**Step 1: Run Static Linter (Layer 3)**
```bash
node .agents/skills/mobile-responsive/scripts/check-responsive.js src/components/Hero.astro
```

**Step 2: Interpret Linter Output**
- If `✅ VERDICT: PASS` → proceed to Layer 4 visual check
- If `❌ VERDICT: FAIL` → fix all violations first, re-run linter until PASS

**Step 3: Run Visual Inspection (Layer 4)** — requires dev server running
```
# Use Chrome DevTools MCP: resize_page → evaluate_script
1. resize_page(width: 375, height: 812)      # iPhone viewport
2. evaluate_script(expression: <inspect-viewport.js content>)
3. Interpret JSON result → verdict: PASS/FAIL
```

**Step 4: Record Results**
Update the component's `BLUEPRINT.md` Linter Check and MCP Visual Check columns.

## 🛠️ Executable Tools & Scripts

### 1. Static Linter (`scripts/check-responsive.js`)

Run this script via `run_command` during pre-commit or phase verification:
```bash
node .agents/skills/mobile-responsive/scripts/check-responsive.js src/
```

**Checks performed:** R1 (fixed widths > 320px), R2 (touch targets < 44px), R3 (text overflow), R4 (unconstrained media), R5 (viewport meta tag).

**Example Output — PASS:**
```
🔍 Mobile Responsive Linter scanning: src/components/Hero.astro
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ VERDICT: PASS | Checked 1 files. Zero mobile responsive violations found.
```

**Example Output — FAIL:**
```
🔍 Mobile Responsive Linter scanning: src/components/Hero.astro
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ VERDICT: FAIL | Found 3 violation(s) across 1 file(s):

📄 File: src/components/Hero.astro
   └─ [Line 12] [R1 (Zero Fixed Layout Widths)]: Fixed width of 600px detected without max-width constraint.
   └─ [Line 25] [R2 (Minimum Touch Targets)]: Interactive element height h-[30px] is smaller than minimum 44px.
   └─ [Line 38] [R4 (Media Fluidity)]: Media element without max-width constraint (needs max-w-full or max-width: 100%).
```

### 2. Chrome DevTools MCP Inspector (`scripts/inspect-viewport.js`)

When dev server is running, use Chrome DevTools MCP `evaluate_script` with the JS code in `scripts/inspect-viewport.js`.

**Target viewports:** `320px` (small mobile), `375px` (iPhone), `768px` (tablet).

**Example Return JSON — PASS:**
```json
{
  "viewportWidth": 375,
  "scrollWidth": 375,
  "hasHorizontalOverflow": false,
  "overflowAmountPx": 0,
  "overflowingElementsCount": 0,
  "overflowingElements": [],
  "smallTouchTargetsCount": 0,
  "smallTouchTargets": [],
  "unconstrainedMediaCount": 0,
  "unconstrainedMedia": [],
  "verdict": "PASS"
}
```

**Example Return JSON — FAIL:**
```json
{
  "viewportWidth": 375,
  "scrollWidth": 620,
  "hasHorizontalOverflow": true,
  "overflowAmountPx": 245,
  "overflowingElementsCount": 2,
  "overflowingElements": [
    { "tag": "div", "selector": "div.hero-container", "right": 620, "width": 600, "overflowByPx": 245 }
  ],
  "smallTouchTargetsCount": 1,
  "smallTouchTargets": [
    { "selector": "a#cta-link", "text": "Get Started", "width": 80, "height": 28 }
  ],
  "unconstrainedMediaCount": 1,
  "unconstrainedMedia": [
    { "tag": "img", "selector": "img#hero-bg", "src": "hero-background.png", "width": 1200, "computedMaxWidth": "none" }
  ],
  "verdict": "FAIL"
}
```

## 📚 References & Templates

- CSS Fluid Recipes: `references/fluid-recipes.md`
- Component Contract Template: `references/responsive-contract-template.md`

## 🧪 Test Prompts

Use these prompts to verify the skill works correctly:

| # | Test Prompt | Expected Result | Type |
| :-- | :-- | :-- | :-- |
| T1 | Create a file with `<div style="width: 600px">` and run linter | R1 violation detected on that line | Objective |
| T2 | Create a file with `<button class="h-[30px]">` and run linter | R2 violation: height 30px < 44px minimum | Objective |
| T3 | Create a file with `<img src="photo.jpg">` (no max-w-full) and run linter | R4 violation: media without max-width | Objective |
| T4 | Run MCP inspector on a page with `375px` viewport containing a `600px` fixed div | `hasHorizontalOverflow: true`, `verdict: FAIL` | Objective |
| T5 | Run MCP inspector on a fully fluid page at `375px` | `verdict: PASS`, all counts = 0 | Objective |

## 🧪 Test Mode (Sandbox Override)

When testing this skill in isolation (via `/para-skill test` or manual testing):

- **Containment path:** `Projects/<project>/repo/.test-responsive/`
- **Test fixtures:** Create `.astro`/`.html` test files with deliberate violations in the containment path
- **Report output:** Generate `test-report.md` in the containment path with the following structure:

```markdown
# Mobile Responsive Test Report

> **Date:** YYYY-MM-DD | **Skill Version:** 1.1.0

## Layer 3 — Static Linter Results

| File | R1 | R2 | R3 | R4 | R5 | Verdict |
| :--- | :-- | :-- | :-- | :-- | :-- | :-- |
| `fixture-r1.astro` | ❌ 1 | — | — | — | — | FAIL |
| `fixture-clean.astro` | — | — | — | — | — | PASS |

## Layer 4 — MCP Visual Results

| Viewport | Overflow? | Touch Targets | Media | Verdict |
| :--- | :-- | :-- | :-- | :-- |
| 320px | No | 0 issues | 0 issues | PASS |
| 375px | No | 0 issues | 0 issues | PASS |

## Summary
- Layer 3: X/Y files PASS
- Layer 4: X/Y viewports PASS
- Overall: PASS / FAIL
```
