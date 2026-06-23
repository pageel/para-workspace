# Reference Architecture: Static Web / Jamstack (Astro)

## 1. Topology
*   **Infra**: SSG (Static Site Generation) deployed to Cloudflare Pages / Vercel.
*   **Styling**: Vanilla CSS or TailwindCSS.

## 2. Code Layout
*   `src/layouts/`: Global wrapper layouts.
*   `src/pages/`: File-system routing.
*   `src/components/`: Reusable static UI components.

## 3. Performance & SEO Targets
*   Include standard `<SEO />` tag component in all layout heads.
*   Enforce LCP < 1.5s, CLS < 0.1.
*   Images MUST use Astro's `<Image />` component for automatic optimization.
