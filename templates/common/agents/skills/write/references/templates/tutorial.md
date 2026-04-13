# Template: Tutorial (Step-by-Step)

> For hands-on instructional walkthroughs.
> Target length: 100–300 lines.

## Standard Structure

```markdown
# Tutorial: [Title]

> **Version:** X.Y.Z | **Updated:** YYYY-MM-DD
> **Audience:** [Who should read this guide?]
> **Prerequisites:** [Required knowledge/tools]

---

## Overview

[1-2 sentences: What does this guide help you do? What is the end result?]

---

## Step 1: [Step Name]

[Brief description of this step's goal.]

```bash
# Command or code example
command --option value
```

> 💡 **Tip:** [Useful tip for this step]

---

## Step 2: [Step Name]

[...]

---

## Step N: Verify Results

[How to check the process completed successfully.]

```bash
# Verification command
verify-command --check
```

**Expected output:**
```
✅ [Description of successful output]
```

---

## Troubleshooting

| Problem | Cause | Solution |
|:--|:--|:--|
| [Error A] | [Cause] | [Fix] |

---

## Related Resources

- [Link 1](path/to/related)
- [Link 2](path/to/related)
```

## Additional Rules

1. **Result first:** State the end result clearly in the Overview so readers know what they will achieve.
2. **One step = one action:** Do not combine multiple actions into one step. Break them down.
3. **Code examples:** Every TECHNICAL step must have a code block illustration.
4. **Troubleshooting:** A troubleshooting section at the end is REQUIRED.
5. **Verification:** The final step MUST be a result verification step.
