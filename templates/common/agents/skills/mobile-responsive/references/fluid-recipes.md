# CSS Fluid Design & Responsive Recipes

> Reference guide for AI Agents to write zero-fixed-width, fluid-first CSS layout and typography.

---

## 1. Fluid Typography & Spacing (`clamp()`)

Use `clamp(min, preferred, max)` to allow font sizes and paddings to scale smoothly between Mobile (320px) and Desktop (1200px) without media queries:

```css
/* Typography */
h1 {
  font-size: clamp(1.75rem, 4vw + 1rem, 3rem); /* Scales 28px -> 48px */
}

h2 {
  font-size: clamp(1.35rem, 2.5vw + 0.8rem, 2.25rem); /* Scales 21.6px -> 36px */
}

p {
  font-size: clamp(0.95rem, 1vw + 0.7rem, 1.125rem); /* Scales 15.2px -> 18px */
}

/* Fluid Padding & Gap */
.section-container {
  padding-inline: clamp(1rem, 5vw, 4rem);
  padding-block: clamp(2rem, 6vh, 5rem);
}
```

---

## 2. Zero-Media-Query Fluid Grids (`auto-fit` / `auto-fill`)

Avoid writing multiple `@media (min-width)` rules for card grids. Use CSS Grid `minmax()` combined with `min(100%, width)`:

```css
/* Auto-wrapping Responsive Grid */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 300px), 1fr));
  gap: 1.5rem;
}
```

- **Mobile (< 600px):** Columns automatically collapse to 1 column (`100%`).
- **Desktop (>= 600px):** Columns expand dynamically into 2, 3, or 4 columns based on available space.

---

## 3. Flexbox Auto-Wrapping & Touch Targets

```css
/* Responsive Form Row or Button Group */
.button-group {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  align-items: center;
}

/* Ensure Minimum 44x44px Touch Target for Mobile Buttons */
.btn-touch {
  min-height: 44px;
  min-width: 44px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.75rem 1.25rem;
}
```

---

## 4. Container Queries (`cqw` / `cqi`)

When building reusable UI components (e.g., Sidebar Cards, Widget Panels) whose layout depends on the container size rather than the viewport size:

```css
/* Define Container */
.widget-card-container {
  container-type: inline-size;
  container-name: widget;
}

/* Respond to Container Width */
@container widget (max-width: 350px) {
  .widget-card {
    flex-direction: column;
    text-align: center;
  }
}
```

---

## 5. Text & Media Safety Invariants

```css
/* Prevent Horizontal Overflow Spilling */
* {
  box-sizing: border-box;
}

img, video, iframe, svg, canvas {
  max-width: 100%;
  height: auto;
}

.text-container {
  max-width: 100%;
  overflow-wrap: break-word;
  word-break: break-word;
}
```
