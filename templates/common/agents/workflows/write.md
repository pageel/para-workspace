---
description: Write deep-dive content (ebook, paper, email, guide) with structured templates and quality gates
source: catalog
---

# /write [project-name] [type]

> **Workspace Version:** 1.7.12

Write structured, deep-dive content for a PARA project. Supports multiple content types with best-practice templates loaded from a sidecar skill.

## Content Types

| Type    | Slug     | Description                                                        |
| :------ | :------- | :----------------------------------------------------------------- |
| Ebook   | `ebook`  | Long-form deep-dive on a single topic (~500-1500 lines) (default)  |
| Paper    | `paper`    | Formal analysis or case study (~200-1000 lines)                    |
| Tutorial | `tutorial` | Step-by-step instructional walkthrough (~100-300 lines)             |
| Blog     | `blog`     | Blog article — informative, engaging, SEO-friendly (~80-300 lines) |
| Social  | `social` | Social media posts: Facebook, Threads, X (platform-adapted)        |
| Email   | `email`  | Professional email: outreach, proposal, follow-up (~20-80 lines)   |

> **Default:** If user does not specify type, use `ebook`.

## Actions

| Action   | Description                                           |
| :------- | :---------------------------------------------------- |
| `new`    | Create a new content piece from scratch (default)     |
| `review` | Audit existing content for quality and completeness   |
| `extend` | Add new chapters/sections to an existing piece        |

## Options

> 🧩 **Sidecar reference:** Full option specs live in `.agents/skills/write/references/options.md`.
> Agent loads this file at Step 1 if user provides options.

| Option     | Values                                         | Default        | Description                                |
| :--------- | :--------------------------------------------- | :------------- | :----------------------------------------- |
| `--style`  | `formal`, `conversational`, `tutorial`, `storytelling` | `formal`       | Writing tone and voice                     |
| `--depth`  | `overview`, `standard`, `deep-dive`, `exhaustive`      | `standard`     | Level of technical detail                  |
| `--tools`  | `web-search`, `mcp`, `image-gen`, `none`               | `none`         | Tools agent MAY use during writing         |
| `--platform` | _(for social only)_ `fanpage`, `group`, `threads`, `x`, `all` | `all` | Target social platform              |

**Tool descriptions:**
- `web-search` — Search the web for current data, references, or competitive analysis.
- `mcp` — Use MCP (Model Context Protocol) servers for structured data retrieval.
- `image-gen` — Generate illustrative images using `generate_image` tool for visual content.
- `none` — Use only local workspace files as source material.

> Multiple tools can be combined: `--tools web-search,image-gen`

---

## Principles

> **Constraint:** Read `.para-workspace.yml` at the workspace root to resolve the user's preferred language.
> Resolution priority:
> 1. If `language` is a map: 
>    - chat language = `language.chat` (fallback: `language.default` -> "en")
>    - thinking language = `language.thinking` (fallback: `language.default` -> "en")
>    - artifacts language = `language.artifacts` (fallback: `language.default` -> "en")
> 2. If `language` is a string: chat & thinking & artifacts language = `language`
> 3. If `language` is undefined, look for `preferences.language` (legacy)
> 4. Default ultimate fallback: "en"
> All output (chat response) MUST be translated to the chat language, all internal reasoning (<thought>) MUST be written in the thinking language, and all generated files in artifacts/ (plans, tasks, qa) MUST follow the artifacts language.

1. **Source-driven.** Content must reference real system files, decisions, or code. Never invent.
2. **Structured depth.** Every piece follows a standard skeleton: Introduction → Problem → Core Content → Comparison → Conclusion.
3. **Visual-first.** Include ANSI diagrams and/or Mermaid charts in every major section.
4. **Professional tone.** Use technical metaphors from engineering/architecture domains. Avoid casual slang or biological metaphors. See sidecar `references/writing-rules.md`.
5. **Progressive disclosure.** Start with summary, drill into detail. Reader can stop at any heading and still gain value.
6. **Versioned.** Every content piece carries a version header and date.

## Location

> **Boundary:** `/write` outputs to `writings/` (authored content). `/docs` outputs to `docs/` (operational docs). They never overlap.

```text
Projects/[project-name]/writings/
├── ebooks/                           ← Ebook files
│   └── ebook-[topic-slug].md
├── papers/                           ← Paper files
│   └── paper-[topic-slug].md
├── tutorials/                        ← Tutorial files
│   └── tutorial-[topic-slug].md
├── blogs/                            ← Blog files
│   └── blog-[topic-slug].md
├── social/                           ← Social media content
│   └── social-[topic-slug].md
└── emails/                           ← Email drafts
    └── email-[topic-slug].md
```

---

## 📝 Action: new

### Steps

#### 0. Agent Indices Pre-flight

// turbo

> **Layer 3 defense:** Re-read indices to guard against attention decay.

```bash
echo ""
echo "> ⚠️ Proactive Trigger Scan: .agents/rules.md & .agents/skills.md"
cat .agents/rules.md 2>/dev/null | head -n 30
cat .agents/skills.md 2>/dev/null | head -n 30
```

Check `project.md` for `agent.rules` / `agent.skills` — if true, re-read project indices too.

#### 1. Identify Topic, Type & Options

Clarify with the user:
- **Topic:** What is the subject of the deep-dive?
- **Type:** `ebook`, `paper`, `tutorial`, `blog`, `social`, or `email`? (default: `ebook`)
- **Style:** `formal`, `conversational`, `tutorial`, or `storytelling`? (default: `formal`)
- **Depth:** `overview`, `standard`, `deep-dive`, or `exhaustive`? (default: `standard`)
- **Tools:** Does the user want web search, MCP, or image generation? (default: `none`)
- **Source material:** Any existing brainstorms, decisions, or research to reference?

> 💡 **Upstream hint:** If the user ran `/brainstorm` or `/research` before this workflow, ask for the artifact path to use as source material.

If user provides options, load the options reference for detailed specs:
```bash
cat .agents/skills/write/references/options.md 2>/dev/null
```

#### 2. Load Template from Sidecar Skill

// turbo

> 🧩 **Sidecar Skill:** Load the appropriate template from the `write` skill.
> Load **ONLY** the template matching the selected type. Do NOT read all templates.

Read the SKILL.md router first:

```bash
cat .agents/skills/write/SKILL.md 2>/dev/null | head -n 40
```

Then load the specific template file indicated by the router.

#### 3. Gather Source Material

// turbo

Read the source files that inform the content:

1. **Brainstorm artifacts** (`artifacts/para-decisions/brainstorm-*.md`) — if referenced
2. **Research documents** (`docs/researches/`) — if topic has prior research
3. **Source code or config** — if topic is architecture/technical
4. **Existing ebook/paper** — if extending prior work

> **Token budget:** Read at most 5 source files. Prioritize by relevance.

#### 4. Present Content Plan

Before writing, present a structured outline:

```
📖 Content Plan: [Topic Title]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Type: [Ebook / Paper / Guide]
📁 Location: Projects/[project-name]/writings/[type]s/[type]-[slug].md
📚 Source material: [list of referenced files]

📝 Proposed Structure:
  1. Introduction
  2. Problem Statement
  3. [Core Section 1]
  4. [Core Section 2]
  ...
  N-1. Strengths & Weaknesses
  N. Conclusion

📊 Estimated length: ~[N] lines

❓ Approve this outline? (y/n, or suggest changes)
```

Wait for user confirmation before writing.

#### 5. Write Content

For each section in the approved outline:

1. Write content based on **actual source material** (not assumptions)
2. Include at least one **ANSI diagram** or **Mermaid chart** per major section
3. Use the standard header format from the template
4. Follow the language and tone rules from Principles

**Quality gates during writing:**
- [ ] No Chinese, Japanese, or other unintended characters in ANSI diagrams
- [ ] No casual/biological metaphors (see Learning: technical-writing-standard)
- [ ] Every claim references a real file, decision, or code path
- [ ] Table of Contents matches actual heading structure

#### 6. Self-Review Pass

After completing the draft, perform a quality scan:

| Check                    | Rule                                                    |
| :----------------------- | :------------------------------------------------------ |
| **Language consistency** | All text in configured language, technical terms in English |
| **Diagram integrity**   | No foreign characters, alignment correct                 |
| **TOC accuracy**        | Every TOC entry links to a real heading                  |
| **Source traceability** | Every major claim has a file/decision reference          |
| **Metaphor audit**     | No casual slang, biological terms, or social media language |

#### 7. Save & Index

// turbo

1. Save the content file to `Projects/[project-name]/writings/[type]s/[type]-[slug].md`
2. Update `Projects/[project-name]/writings/README.md` index (create if not exists)

#### 8. Suggest Next Steps

```
✅ Content created: writings/[type]s/[type]-[slug].md

💡 Next steps:
  - `/docs publish` — Promote to repo/docs/ for external audience
  - `/write extend` — Add more sections later
  - `/learn` — Extract reusable writing lessons
```

---

## 📋 Action: review

Audit an existing content piece for quality.

### Steps

1. Read the target file.
2. Load the quality checklist from sidecar skill (`.agents/skills/write/references/quality-checklist.md`).
3. Run each check and present a report:

```
🔍 REVIEW: [filename]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Language consistency    — OK
✅ TOC accuracy            — OK
⚠️ Diagram integrity      — Line 128: misaligned ANSI boxes
✅ Source traceability     — OK
⚠️ Metaphor audit         — Line 42: "bộ mỡ thừa" (casual)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Result: 2 warning(s), 0 error(s)
💡 Fix these issues? (y/n)
```

---

## ✏️ Action: extend

Add new chapters or sections to an existing content piece.

### Steps

1. Read the existing content file.
2. User specifies the new section topic.
3. Gather additional source material (same as Step 3 of `new`).
4. Write the new section following the existing style and structure.
5. Update the Table of Contents.
6. Run Self-Review Pass on the new section only.

---

## Output Checklist

- [ ] Content type identified and template loaded
- [ ] Source material gathered (max 5 files)
- [ ] Content plan presented and approved by user
- [ ] Content written from actual sources (not assumptions)
- [ ] ANSI/Mermaid diagrams included in major sections
- [ ] Self-review pass completed (language, diagrams, TOC, metaphors)
- [ ] File saved to correct location
- [ ] Doc index updated

## Related

- `/brainstorm` — Generate ideas and decisions before writing (upstream)
- `/research` — Create structured research documents (upstream, different purpose)
- `/docs` — Project documentation (operational docs, not deep-dive content)
- `/learn` — Extract reusable writing lessons (downstream)
- `/pageel-write` — Write website content (different scope: CMS/web pages)
