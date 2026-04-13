# Write Options Reference

> Detailed specifications for `/write` workflow options.
> Loaded by the workflow when user provides `--style`, `--depth`, `--tools`, or `--platform`.

## Style Profiles

| Style           | Tone                  | Sentence Length | Use When                                    |
| :-------------- | :-------------------- | :-------------- | :------------------------------------------ |
| `formal`        | Professional, precise | Medium-long     | Ebooks, papers, architecture docs (default) |
| `conversational`| Friendly, relatable   | Short-medium    | Blog posts, guides for beginners            |
| `tutorial`      | Instructional, clear  | Short           | Step-by-step guides, how-tos                |
| `storytelling`  | Narrative, engaging   | Varied          | Case studies, dev chronicles, blog posts    |

### Style Guardrails

- **`formal`**: No contractions, no slang, no "you/your" addressing. Use passive voice when appropriate.
- **`conversational`**: Contractions OK. Direct "you" addressing. Keep technical accuracy while being approachable.
- **`tutorial`**: Imperative tone ("Run this command", "Open the file"). Every paragraph leads to an action.
- **`storytelling`**: Chronological flow. Use transitions ("Then we discovered...", "This led to..."). Include setbacks and resolutions.

---

## Depth Levels

| Level        | Sections per Topic | Diagrams | Code Examples | Target Audience           |
| :----------- | :----------------- | :------- | :------------ | :------------------------ |
| `overview`   | 1-2                | Optional | None          | Executives, stakeholders  |
| `standard`   | 2-3                | 1 per section | Inline    | Engineers, team members   |
| `deep-dive`  | 3-5                | 2+ per section | Detailed | Architects, specialists  |
| `exhaustive` | 5+                 | Every subsection | Full listings | Reference docs, audits |

### Depth Guardrails

- **`overview`**: Max 200 lines. Focus on "what" and "why", skip "how".
- **`standard`**: 200-500 lines. Balanced who/what/why/how.
- **`deep-dive`**: 500-1500 lines. Include trade-offs, edge cases, real-world scenarios.
- **`exhaustive`**: No upper limit. Include every detail, configuration, and alternative.

---

## Tool Usage

### `web-search`

When enabled, agent MAY use `search_web` and `read_url_content` tools to:
- Find current best practices or industry standards
- Verify technical claims against official documentation
- Research competitive approaches or alternatives
- Gather statistics or benchmarks

**Constraints:**
- Always cite URLs in the content's References section.
- Prefer official documentation over blog posts.
- Do NOT use web search as a substitute for reading local workspace files.

### `mcp`

When enabled, agent MAY use MCP (Model Context Protocol) servers to:
- Query structured databases or APIs for data
- Retrieve real-time system metrics or status
- Access external knowledge bases

**Constraints:**
- Only use MCP servers already configured in the workspace.
- Document which MCP server was used in the content header.

### `image-gen`

When enabled, agent MAY use `generate_image` tool to:
- Create architectural diagrams or flowcharts as images
- Generate illustrative visuals for concepts
- Create cover images for blog posts or social media

**Constraints:**
- Images must be saved to the same directory as the content file.
- Always provide an alt-text description.
- Use images to supplement (not replace) ANSI/Mermaid text diagrams.

### `none` (default)

Agent uses only local workspace files. No external tools.

---

## Platform Targeting (Social Only)

Used with `--platform` option when type is `social`.

| Platform   | Char Limit | Best Practices                                          |
| :--------- | :--------- | :------------------------------------------------------ |
| `fanpage`  | 1500       | Lead with value. Include image. Professional but warm.  |
| `group`    | 1000       | Start with question. Spark discussion. Authentic voice. |
| `threads`  | 500        | Punchy first line. One idea. Thread for depth.          |
| `x`        | 280        | Every word counts. Hook → insight → CTA. Max 2 tags.   |
| `all`      | —          | Generate all 4 variants from same source. (default)     |
