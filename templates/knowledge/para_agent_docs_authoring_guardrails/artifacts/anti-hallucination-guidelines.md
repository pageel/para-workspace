# Agent Docs Authoring Guardrails (Anti-Hallucination)

## 1. URL Slug Precision (Anti-Hallucination)
When inserting internal links within Markdown files (especially in SSG frameworks like Astro):
- **No Slug Speculation**: The agent must always match the exact physical file name (e.g., if the file is named `knowledge-system.md`, the URL path must be `knowledge-system`, DO NOT speculate or assume it is `knowledge-architecture`).
- **Distinguish Route Structure**: Absolutely do not blindly copy the root directory path (`/src/content/docs/[lang]/...`) to the URL path (`/[lang]/docs/...`). They are two completely distinct mapping systems.

## 2. Technical Terminology Translation Guard
When translating or authoring specialized technical documentation:
- **Adhere to Core Concepts**: The wording must strictly follow the original technical terminology system (e.g., *Knowledge Items*, *Governance*).
- **No Creative Additions**: Do not arbitrarily add general technical words (such as `API`, `Server`, `Database`) into the content if the original design does not contain them. Doing so ruins the structural understanding of the system.
