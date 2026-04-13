# Quality Checklist for /write review

> Loaded by `/write review` action. Agent runs each check against the target content file.

## Automated Checks

| #   | Check                    | Rule                                                                   | Severity |
| :-- | :----------------------- | :--------------------------------------------------------------------- | :------- |
| 1   | Language consistency     | All text in configured language; technical terms may remain in English  | Error    |
| 2   | TOC accuracy             | Every TOC entry matches an actual heading in the document               | Error    |
| 3   | Diagram integrity        | No foreign/garbled characters in ANSI diagrams; alignment is correct   | Warning  |
| 4   | Source traceability      | Every major claim references a real file, decision, or code path       | Warning  |
| 5   | Metaphor audit           | No casual slang, biological metaphors, or social media language        | Warning  |
| 6   | Version header           | Document contains version and date in header metadata                  | Error    |
| 7   | Section depth            | Each major section has at least one visual (diagram, table, or chart)  | Info     |
| 8   | Progressive disclosure   | Summary or TL;DR exists before detailed sections                       | Info     |

## Report Format

```
🔍 REVIEW: [filename]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ [Check name]           — OK
⚠️ [Check name]          — Line [N]: [issue description]
❌ [Check name]           — Line [N]: [error description]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Result: [N] error(s), [N] warning(s), [N] info(s)
💡 Fix these issues? (y/n)
```
