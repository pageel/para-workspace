---
tags: [website, content-site, ssg, ssr, hybrid, seo, jamstack, marketing, blog, docs]
stack: [astro-7, cloudflare-pages, vercel, netlify]
scale: [small, medium]
complexity: basic
---

# Reference Architecture: Astro Website (SSG / SSR / Hybrid)

> **Astro Version:** 7.x
> **Paradigm:** Content-first website — blogs, marketing pages, documentation, landing pages, portfolios.
> **When to use:** Building a **website** (content consumption) rather than an **application** (user interaction, auth, DB). If you need auth, database, or user dashboards → use `astro-7-fullstack.md` instead.

## 1. Topology

*   **Infra**: Deployed to Cloudflare Pages / Vercel / Netlify.
*   **Rendering Mode**: Choose based on content freshness requirements:

| Mode | Config | Best For | Trade-off |
|:--|:--|:--|:--|
| **Static (SSG)** | `output: 'static'` (default) | Blogs, docs, portfolios, marketing | Fastest, cheapest — content fixed at build time |
| **Hybrid** | `output: 'hybrid'` | Sites with mostly static + a few dynamic pages (contact form, newsletter, search) | Best balance — static pages cached, dynamic pages rendered on request |
| **Server (SSR)** | `output: 'server'` | i18n detection, geo-personalized content, CMS preview mode | Full flexibility — every page rendered per-request |

```typescript
// astro.config.mjs
import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';

export default defineConfig({
  output: 'hybrid',  // or 'static' / 'server'
  adapter: cloudflare(), // Only needed for hybrid/server
  site: 'https://example.com',
  i18n: {
    defaultLocale: 'vi',
    locales: ['vi', 'en'],
    routing: { prefixDefaultLocale: false },
  },
});
```

## 2. Code Layout

```
src/
├── assets/               # Images, SVGs processed by Astro (optimization + hashing)
├── components/           # Reusable .astro components (zero JS by default)
│   ├── ui/               # Design primitives (Button, Card, Badge)
│   ├── sections/         # Page sections (Hero, Features, Pricing, CTA)
│   └── islands/          # Interactive widgets (client:idle / client:visible)
├── content/              # Content Collections (Markdown/MDX + Zod schema)
│   ├── config.ts         # Collection definitions with type-safe frontmatter
│   ├── blog/             # Blog posts
│   ├── docs/             # Documentation
│   ├── authors/          # Author profiles
│   └── pages/            # CMS-managed static pages
├── data/                 # Static data files (JSON/YAML: nav, footer, social links)
├── layouts/
│   ├── BaseLayout.astro  # HTML shell: <head>, fonts, global styles
│   ├── BlogLayout.astro  # Blog post wrapper with ToC, author, date
│   └── DocsLayout.astro  # Documentation with sidebar nav
├── pages/
│   ├── index.astro       # Home page
│   ├── blog/
│   │   ├── index.astro   # Blog listing (paginated)
│   │   └── [...slug].astro  # Individual blog posts (from content collection)
│   ├── docs/[...slug].astro
│   ├── about.astro
│   └── contact.astro     # prerender: false (if hybrid — handles form POST)
├── styles/
│   ├── global.css        # CSS custom properties, reset, typography
│   └── components/       # Component-scoped CSS (if needed beyond <style>)
└── utils/                # Date formatting, slugify, reading time calc
```

## 3. Content Collections (Content Layer API)

```typescript
// src/content/config.ts
import { defineCollection, z } from 'astro:content';

const blog = defineCollection({
  type: 'content',  // Markdown/MDX files
  schema: z.object({
    title: z.string(),
    description: z.string(),
    date: z.date(),
    updated: z.date().optional(),
    author: z.string(),
    tags: z.array(z.string()).default([]),
    image: z.object({
      src: z.string(),
      alt: z.string(),
    }).optional(),
    draft: z.boolean().default(false),
  }),
});

const docs = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    order: z.number().default(0),
    section: z.string(), // Sidebar grouping
  }),
});

export const collections = { blog, docs };
```

### Querying Content

```astro
---
// src/pages/blog/index.astro
import { getCollection } from 'astro:content';
import BlogLayout from '../../layouts/BlogLayout.astro';

const posts = (await getCollection('blog', ({ data }) => !data.draft))
  .sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf());
---
<BlogLayout title="Blog">
  {posts.map(post => (
    <article>
      <a href={`/blog/${post.slug}`}>{post.data.title}</a>
      <time>{post.data.date.toLocaleDateString('vi-VN')}</time>
    </article>
  ))}
</BlogLayout>
```

## 4. Performance & SEO

### Core Web Vitals Targets

| Metric | Target | How |
|:--|:--|:--|
| **LCP** | < 1.5s | Astro `<Image />` component, preload hero image, edge CDN |
| **CLS** | < 0.1 | Explicit width/height on images, `font-display: swap` |
| **INP** | < 200ms | Zero JS default, `client:visible` for below-fold interactions |

### SEO Component

```astro
---
// src/components/SEO.astro
interface Props {
  title: string;
  description: string;
  image?: string;
  canonicalUrl?: string;
  type?: 'website' | 'article';
}
const { title, description, image, canonicalUrl, type = 'website' } = Astro.props;
const siteUrl = Astro.site?.toString() ?? '';
const ogImage = image ?? `${siteUrl}/og-default.png`;
---
<title>{title}</title>
<meta name="description" content={description} />
<link rel="canonical" href={canonicalUrl ?? Astro.url.href} />

<!-- Open Graph -->
<meta property="og:type" content={type} />
<meta property="og:title" content={title} />
<meta property="og:description" content={description} />
<meta property="og:image" content={ogImage} />
<meta property="og:url" content={Astro.url.href} />

<!-- Twitter -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content={title} />
<meta name="twitter:description" content={description} />
<meta name="twitter:image" content={ogImage} />
```

### Image Optimization

```astro
---
import { Image } from 'astro:assets';
import heroImage from '../assets/hero.jpg';
---
<!-- Automatic WebP/AVIF conversion, responsive srcset, lazy loading -->
<Image src={heroImage} alt="Hero banner" width={1200} height={630} loading="eager" />
```

### Font Loading

```html
<!-- In BaseLayout.astro <head> -->
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="preload" as="style" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" />
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" />
```

## 5. Security (Headers & CSP)

Configure via `_headers` file (Cloudflare Pages) or platform equivalent:

```
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
  Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
  Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self';
```

*   **No server secrets**: SSG websites have no runtime secrets. Third-party API keys (analytics, forms) must be public-safe.
*   **If Hybrid/SSR**: Form endpoints or newsletter subscriptions should validate inputs server-side and use CSRF tokens.

## 6. Observability (Lightweight)

*   **Analytics**: Privacy-friendly analytics (Plausible, Fathom, or Cloudflare Web Analytics — no cookie banner needed).
*   **Performance Monitoring**: Cloudflare Speed Test or Google PageSpeed Insights for CWV tracking.
*   **Build Monitoring**: Track build time via CI/CD pipeline. Astro 7 Rust compiler targets < 5s for 100-page sites.
*   **Sitemap & RSS**: `@astrojs/sitemap` and `@astrojs/rss` for SEO crawlability.

## When to Use This Pattern vs `astro-7-fullstack.md`

| Need | This Pattern (Website) | Fullstack Pattern |
|:--|:--|:--|
| Blog, docs, marketing pages | ✅ | Overkill |
| Portfolio / landing page | ✅ | Overkill |
| Content site + contact form | ✅ (hybrid mode) | Not needed |
| Content site + newsletter signup | ✅ (hybrid mode) | Not needed |
| User auth + dashboard | ❌ | ✅ |
| Database CRUD + admin panel | ❌ | ✅ |
| E-commerce with cart + checkout | ❌ | ✅ |
| Multi-tenant SaaS | ❌ | ✅ + multi-tenant overlay |
