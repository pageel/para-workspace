# Template: Social Media Content

> For social media posts across platforms: Facebook Fanpage, Facebook Group, Threads, X (Twitter).
> Target length: varies by platform (see below).

## ⚠️ Style Guide Integration (FEAT-79)

> **Before writing any social content**, Agent **MUST** check for user-authored Style Guides in `writings/templates/`:
>
> ```bash
> ls writings/templates/style-social-*.md 2>/dev/null
> ```
>
> If found:
> 1. Load the Style Guide matching the target platform (e.g., `style-social-facebook-group.md`).
> 2. Prioritize **§1 Style Characteristics** and reference **§3 Historical Raw Examples** to learn the user's actual tone and phrasing.
> 3. Default templates below are fallback ONLY — used when NO Style Guide exists.

## Platform Specifications

| Platform          | Max Length   | Tone              | Media        | Hashtags  |
| :---------------- | :----------- | :----------------- | :----------- | :-------- |
| Facebook Fanpage  | 500-1500 chars | Professional, warm | Image/Video  | 3-5       |
| Facebook Group    | 300-1000 chars | Conversational     | Optional     | 1-3       |
| Threads           | 500 chars      | Concise, punchy    | Image opt.   | 2-3       |
| X (Twitter)       | 280 chars      | Sharp, hook-driven | Image opt.   | 1-2       |

---

## Facebook Fanpage Template

```markdown
[Hook — 1 sentence that stops the scroll]

[Core message — 2-3 short paragraphs explaining the value]

[Key takeaway or surprising insight — bold or emoji-highlighted]

👉 [Call-to-action: Comment / Share / Link]

#hashtag1 #hashtag2 #hashtag3
```

**Rules:**
- Lead with value, not promotion.
- Use line breaks generously for mobile readability.
- Include 1 image or video (engagement 2-3x higher).

---

## Facebook Group Template

```markdown
[Question or relatable statement to spark discussion]

[Brief context — why you're asking / sharing this]

[Your take or experience — keep it authentic]

💬 [Discussion prompt: "What's your experience with...?"]
```

**Rules:**
- Prioritize engagement over reach — ask genuine questions.
- No hard selling. Share knowledge, ask opinions.
- Keep under 1000 chars for best engagement.
- **If Style Guide exists (`style-social-facebook-group.md`):** Prioritize user's structure and tone from the Style Guide over this default template.

---

## Threads Template

```markdown
[Sharp opening line — punchy statement or hot take]

[Supporting context — 1-2 sentences max]

[Punchline or CTA]

#tag1 #tag2
```

**Rules:**
- First line IS the hook — make it count.
- Write like you're texting a smart friend.
- One idea per thread. Use thread replies for depth.

---

## X (Twitter) Template

```markdown
[Full post in ≤280 chars. Structure:]

[Hook phrase] →
[Core insight in 1 sentence]
[Optional: link or CTA]

#tag
```

**Rules:**
- Every character matters. Cut ruthlessly.
- Use → or — for visual structure within the limit.
- Thread format (1/N) for longer topics. First tweet must stand alone.
- No more than 2 hashtags.

---

## Cross-Platform Repurposing Flow

```text
Ebook / Paper / Blog (source content)
         │
         ▼
  Extract key insight
         │
    ┌────┴────┬──────────┬──────────┐
    ▼         ▼          ▼          ▼
 Fanpage    Group     Threads    X/Twitter
 (detail)   (discuss)  (punch)   (sharp)
```

> **Principle:** Write long-form first, then distill for social. Never the reverse.

## Additional Rules

1. **Platform-native:** Each post must feel native to the platform. Do NOT copy-paste across platforms.
2. **Repurpose, don't duplicate:** Extract different angles from the same source content for each platform.
3. **Engagement-first:** Social posts exist to start conversations, not to inform exhaustively.
4. **Visual:** Always suggest an image or visual when possible (even a text screenshot or diagram).
