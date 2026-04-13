# Template: Ebook (Deep-Dive)

> For long-form deep-dive content analyzing a single topic.
> Target length: 500–1500 lines.

## Standard Structure

```markdown
# [Ebook Title]: [Descriptive Subtitle]

> **Version:** X.Y.Z | **Updated:** YYYY-MM-DD
> **Source document:** [link to brainstorm/decision/research source]

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Problem Statement](#2-problem-statement)
3. [Architecture / Solution Overview](#3-...)
4. [Deep-Dive: Component 1](#4-...)
   - 4.1 [Principles](#41-principles)
   - 4.2 [Mechanism](#42-...)
   - 4.3 [Real-world Flow](#43-...)
   - 4.4 [Strengths & Weaknesses](#44-...)
5. [Deep-Dive: Component 2](#5-...)
   ...
N-2. [Comparison / Evaluation Matrix](#...)
N-1. [Overall Strengths & Weaknesses](#...)
N.   [Conclusion](#...)

---

## 1. Introduction

[Summarize the problem in 2-3 sentences. State scope and goals.]

[ANSI overview diagram — REQUIRED]

---

## 2. Problem Statement

### 2.1 [Core Problem]

[Describe the problem. Use diagrams if needed.]

### 2.2 [Root Causes]

| # | Root Cause | Explanation |
|:--|:-----------|:-----------|
| 1 | ...        | ...        |

---

## 3. [Solution / Architecture Overview]

[Summary table of components]

| Component | Role | Mechanism |
|:--|:--|:--|
| ... | ... | ... |

[ANSI or Mermaid diagram — REQUIRED]

---

## 4–N. [Detailed Analysis Chapters]

> Each chapter MUST include:
> - Principles (Why)
> - Mechanism (How) + diagram
> - Real-world scenario flow
> - Strengths & Weaknesses (Trade-offs)

---

## [N-1]. Strengths & Weaknesses

| ✅ Strengths | ❌ Weaknesses |
|:--|:--|
| ... | ... |

---

## [N]. Conclusion

[Brief summary. Emphasize core value and main trade-offs.]
```

## Additional Rules

1. **Dual diagrams:** Every Mermaid diagram MUST have an ANSI companion (ensures compatibility across all environments).
2. **Source reference:** Header MUST contain a link to the source brainstorm/decision/research document.
3. **Table of Contents:** MUST list all headings down to H2 and H3 (sub-sections).
4. **Numbering:** Use continuous numbers for headings (## 1, ## 2, ...). Do not use letters.
