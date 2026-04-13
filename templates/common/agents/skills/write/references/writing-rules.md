# Writing Rules

> Language, tone, and formatting rules for all `/write` content.
> Distilled from workspace experience. This file is the single source of truth for writing standards.

## Language Rules

1. **Configured language:** Content MUST be written in the language set by `preferences.language` in `.para-workspace.yml`.
2. **Technical terms:** Keep in English regardless of content language (e.g., "Sidecar Skill", "Lazy Loading", "Token Budget").
3. **ANSI diagrams:** Use English for technical labels (paths, calls) and configured language for action descriptions.

## Metaphor Rules

1. **Prefer:** Engineering, architecture, military, logistics metaphors (cockpit, convoy, firewall, gateway).
2. **Avoid:** Biological, medical, food metaphors ("fat trimming", "contamination", "pollution").
3. **Avoid:** Casual slang, social media language, or overly informal expressions.

## Diagram Rules

1. **Dual format:** Every Mermaid diagram MUST have an ANSI text companion.
2. **No foreign characters:** Verify no unintended CJK or special characters appear in ANSI diagrams.
3. **Alignment:** Test ANSI box-drawing alignment in a monospace font before finalizing.

## Formatting Rules

1. **Headings:** Use continuous numbering (## 1, ## 2, ...). No letters.
2. **Tables:** Pad columns for readability. Max cell width: 60 characters.
3. **Line length:** Keep paragraphs under 4 lines for scannability.
4. **Version header:** Every content piece starts with version and date metadata.
