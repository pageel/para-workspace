---
description: Package lessons and knowledge into Areas/Learning
---

# /learn [topic-name]

> **Workspace Version:** 1.4.0

This workflow standardizes the storage of knowledge and experience accumulated during development according to the PARA Workspace standard.

### Steps:

1. **Identify the topic**: Summarize the lesson or experience to be stored.
2. **Create a new file**: Create a `.md` file in `Areas/Learning/[topic-name].md`.
3. **Apply the Template**:

   ```markdown
   # [Lesson Title]

   > [Core value summary of the lesson]

   ## Context

   - Describe the situation or error encountered.
   - Why the old method was ineffective.

   ## Solution

   - Detailed handling method.
   - Tools or techniques used (e.g., React Portal, Python Script...).

   ## Key Learnings

   - Point 1: Technical.
   - Point 2: Process.
   - Point 3: Important notes.

   ## Code Example (If applicable)

   - Code snippet illustrating the optimal solution.
   ```

4. **Update README**: Add a link to the lesson in `Areas/Learning/README.md` under the appropriate category (Git, Development, Best Practices...).
