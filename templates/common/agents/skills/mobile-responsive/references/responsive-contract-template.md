# Responsive Component Contract Template

> Add this contract block under the target page or component section in `PAGE_MAP.md` before coding complex responsive layouts.

```markdown
### Component: [ComponentName]

#### Breakpoint Specifications:
- **Mobile (< 640px):**
  - Layout: `flex-col` / `grid-cols-1` (Stacked view)
  - Navigation: Drawer slide-in / Accordion co-expansion
  - Image / Media: `w-full max-h-[250px] object-cover`
  - Spacing: Padding `px-4 py-6`, Gap `gap-3`
  - Touch Targets: All buttons/links `min-h-[44px]`

- **Tablet (640px - 1024px):**
  - Layout: `grid-cols-2`
  - Spacing: Padding `px-6 py-8`, Gap `gap-4`

- **Desktop (>= 1024px):**
  - Layout: `grid-cols-3` or Sidebar + Content split (`250px 1fr`)
  - Spacing: Padding `px-12 py-12`, Gap `gap-6`

#### Safety & Overflow Guards:
- [ ] Container includes `max-w-full overflow-x-hidden` (or `break-words` on dynamic text)
- [ ] Fixed pixel widths > 320px are strictly prohibited
- [ ] Tested on 320px (Small Mobile), 375px (iPhone), and 768px (Tablet)
```
