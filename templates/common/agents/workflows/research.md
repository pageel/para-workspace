---
description: Create research case studies documenting agent processes, development timelines, and architecture analysis
---

# /research [project-name] [type]

> **Workspace Version:** 1.7.2

Create structured research documents that capture real-world processes, agent behavior, architecture decisions, and development timelines. Research docs are **internal-only** — never published via `/docs publish`.

## Research Types

| Type          | Slug      | Mô tả                                                        |
| :------------ | :-------- | :------------------------------------------------------------ |
| Agent Process | `process` | Suy nghĩ, hành động, ra quyết định của agent (default)       |
| Dev Chronicle | `chronicle` | Lịch sử phát triển feature/system qua nhiều phiên            |
| Architecture  | `analysis` | Deep dive vào kiến trúc, patterns, trade-offs                |
| Comparison    | `compare` | So sánh approaches, tools, hoặc design options               |

> **Default:** Nếu user không chỉ định type → dùng `process`.

---

## Principles

> 🛡️ **Constraint:** Read `preferences.language` from `.para-workspace.yml`. All research MUST use this language. Default: `vi`.

1. **Evidence-based.** Mọi nhận định phải có bằng chứng (tool calls, git commits, file paths).
2. **Chronological.** Sắp xếp theo thứ tự thời gian xảy ra.
3. **Transparent.** Ghi cả thất bại (tool errors, wrong assumptions), không chỉ thành công.
4. **Reproducible.** Người đọc phải hiểu đủ để reproduce quy trình.
5. **Internal-only.** Research là `docs/researches/` — KHÔNG bao giờ publish ra `repo/docs/`.

## Location

```text
Projects/[project-name]/docs/researches/
├── README.md                                     ← Index phân loại tự động
└── [category]/research-[YYYY-MM-DD]-[topic].md   ← Research file (category tự định nghĩa)
```
> **Note:** Thư mục `[category]/` là do người dùng tự định nghĩa dựa trên mục đích lưu trữ (vd: `process/`, `architecture/`, `history/`, `compare/`, v.v.). Các `slug` ở phần Type đóng vai trò là category mặc định nếu user không chỉ định.

---

## Steps (all types)

### 0. Pre-flight

// turbo

1. Re-read `.agent/rules.md` (workspace rules index)
2. Re-read `.agent/skills.md` (workspace skills index)
3. Check `project.md` for `agent.rules` / `agent.skills` — if true, re-read project indices too

### 1. Identify Research Scope

Determine:

- **Project**: From user input or active document context
- **Type**: From user input, or infer from request keywords:

| Keywords trong request                        | Type suy luận |
| :-------------------------------------------- | :------------ |
| "suy nghĩ", "agent", "tool calls", "quyết định", "process" | `process`    |
| "quá trình", "lịch sử", "timeline", "phát triển"          | `chronicle`  |
| "kiến trúc", "architecture", "patterns", "deep dive"       | `analysis`   |
| "so sánh", "compare", "options", "trade-offs"              | `compare`    |

- **Topic**: Chủ đề cụ thể (e.g., "knowledge-system-merge", "v1.7.2-workflow-simplification")
- **Scope**: Phiên hiện tại only, hay nhiều phiên (cross-session)?

### 2. Gather Evidence

// turbo

Thu thập dữ liệu theo type:

**For ALL types:**

```bash
# Read project contract
cat Projects/[project-name]/project.md

# Check existing researches
ls -t Projects/[project-name]/docs/researches/ 2>/dev/null | head -5

# Read docs index
cat Projects/[project-name]/docs/README.md 2>/dev/null
```

**Type-specific evidence gathering:**

| Type        | Evidence sources                                         |
| :---------- | :------------------------------------------------------- |
| `process`   | Conversation memory (tool calls, thinking, decisions)    |
| `chronicle` | Git log, brainstorm artifacts, session logs, milestones  |
| `analysis`  | Source code, architecture docs, KI artifacts, schemas    |
| `compare`   | Multiple source files, benchmarks, brainstorm artifacts  |

**`chronicle` evidence:**

```bash
# Git history for the topic period
cd Projects/[project-name]/repo && git log --oneline --since="[start-date]" --pretty=format:"%h %ai %s" -30

# Brainstorm artifacts
ls -t Projects/[project-name]/artifacts/para-decisions/brainstorm-*[topic]* 2>/dev/null
```

**`process` evidence:**
- Primary source: **Conversation memory** — agent recalls all tool calls, thinking, decisions from current session
- Secondary: Try session logs at `~/.gemini/antigravity/brain/[conversation-id]/.system_generated/logs/overview.txt`
- Fallback: Git log + brainstorm artifacts for corroboration

**`analysis` evidence:**

```bash
# Source code structure
find Projects/[project-name]/repo -maxdepth 3 -type f \
  ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/dist/*' | head -50

# Architecture docs
ls Projects/[project-name]/docs/architecture/ 2>/dev/null
```

### 3. Present Research Plan

```
🔬 Research Plan: [topic]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Project: [project-name]
🏷️ Type: [process / chronicle / analysis / compare]
📅 Scope: [phiên hiện tại / cross-session / date range]

📋 Sections planned:
  1. [Section name] — [brief description]
  2. [Section name] — [brief description]
  ...

📦 Evidence collected:
  - [N] tool calls from conversation memory
  - [N] git commits
  - [N] brainstorm artifacts
  - [N] source files read

❓ Proceed? (y/n, or adjust scope)
```

Wait for user confirmation.

### 4. Generate Research Document

// turbo

Use the appropriate template from **Research Templates** section below.

Write to `Projects/[project-name]/docs/researches/research-[YYYY-MM-DD]-[topic].md`.

### 5. Update Doc Index

// turbo

Add entry to `Projects/[project-name]/docs/researches/README.md` under the appropriate **[Category]** section:
*(Nếu Category chưa tồn tại, Agent tự tạo thêm Header H2 mới trong file README.md)*

```markdown
| [topic-title][res-NN]  | [1-line description] | YYYY-MM-DD |

[res-NN]: ./[category]/research-[YYYY-MM-DD]-[topic].md
```

### 6. Suggested Follow-ups

```
🔬 RESEARCH COMPLETE: [topic]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Saved: docs/researches/research-[date]-[topic].md

💡 NEXT STEPS:
  A. 📚 Extract to /knowledge — Persist patterns as KI
  B. 📐 Inform /plan — Use findings for implementation plan
  C. 📝 Create /docs — Turn analysis into architecture doc
  D. 🎓 Extract to /learn — Reusable lesson for Areas/Learning

❓ Which option? (A/B/C/D/skip)
```

---

## Research Templates

### 📡 Type: `process` — Agent Process Case Study

> Ghi lại quá trình suy nghĩ, hành động, và ra quyết định của agent. **Mỗi request của user là một case study.**

```markdown
# [Topic] — Agent Process Case Study

> **Version**: 1.0 | **Last reviewed**: YYYY-MM-DD
> **Subject**: [Mô tả 1 dòng]
> **Session**: YYYY-MM-DD, conversation `[conversation-id]`

---

## 1. Bối cảnh phiên

| Thuộc tính | Giá trị |
|:--|:--|
| Conversation ID | `[id]` |
| Project | [project-name] |
| KIs injected | [list slugs] |
| Active document | [file path] |
| Open documents | [N] files |

---

## 2. Request Log

### Request [N]: "[Trích nguyên văn user request]"

**Thời gian:** ~HH:MM

**Context nhận được từ platform:**
- Active document: `[path]` (cursor dòng [N])
- Open documents: [list relevant ones]
- KI injected: [list]
- Workflow injected: [if @mention]

#### Bước 1: [Tên bước] — **[Mục đích]**

> ⚠️ **LUẬT CHỐNG ẢO GIÁC (ANTI-HALLUCINATION):**
> Phần log quá trình này bắt buộc phải phản ánh **TRUNG THỰC 100%** suy nghĩ nội bộ (internal thoughts) và quyết định hành động của chính Agent trong quá trình chạy Tool Calls (bao gồm cả sai lầm, nhảy cóc, và khắc phục lỗi). TUYỆT ĐỐI KHÔNG sáng tạo văn vẻ hay thêm thắt các bước không có thật để tô vẽ sự hoàn hảo.

```text
Suy nghĩ nội bộ (Internal Monologue):
  - [Dữ liệu context nhặt được thực thiệp từ tool trước đó là gì?]
  - [IF/ELSE reasoning trees - Cân nhắc giữa các lựa chọn như thế nào?]
  - [Có nhầm lẫn hay nhận thức nào bị hổng không?]

Quyết định hành động (Action):
  - [Kết luận chọn tool gọi/lệnh gì và giải thích ngắn gọn tại sao]
```

#### Bước 2: Thu thập dữ liệu — **[N] tool calls**

```text
BATCH [N] (song song / tuần tự):
  ├── [tool_name]([params])    ← [mục đích]
  └── [tool_name]([params])    ← [mục đích]

Tại sao [song song/tuần tự]? [lý do dependency]
```

#### Bước [N]: [Tên bước]

[Tiếp tục pattern trên cho mỗi bước...]

#### Tổng kết Request [N]

```text
Tool calls:   [N] ([breakdown by tool type])
Batches:      [N] ([N] parallel + [N] sequential)
Thời gian:    ~[N] phút
Quyết định:   [N] ([list key decisions])
Token ước lượng:
  Input:      ~[N] tokens ([N] files × avg [N] lines)
  Output:     ~[N] tokens ([N] lines generated)
Code changed: [N] files, +[N] / -[N] lines
```

---

## 3. Thống kê tổng hợp

### Tool Calls

| Tool | Count | Mục đích chính |
|:--|:--|:--|
| `view_file` | [N] | [purpose] |
| `run_command` | [N] | [purpose] |
| `write_to_file` | [N] | [purpose] |
| `replace_file_content` | [N] | [purpose] |
| **Total** | **[N]** | |

### Impact Metrics

**Token ước lượng (toàn phiên):**

| Loại | Ước lượng | Ghi chú |
|:-----|:----------|:--------|
| Input (files đọc) | ~[N] tokens | [N] files × avg [M] lines, ~4 tokens/line |
| Input (user requests) | ~[N] tokens | [N] requests |
| Input (platform inject) | ~[N] tokens | KI summaries + metadata |
| Output (text responses) | ~[N] tokens | [N] responses |
| Output (code generated) | ~[N] tokens | [N] files written/edited |
| **Subtotal** | **~[N] tokens** | |

> **Quy tắc ước lượng:** 1 dòng code ≈ 4 tokens (trung bình). 1 dòng prose ≈ 8 tokens. JSON/YAML ≈ 6 tokens/line. Batch song song không cộng thêm token nhưng giảm latency.

**Code impact (files thay đổi):**

| File | Action | +Lines | -Lines | Net |
|:-----|:-------|:-------|:-------|:----|
| `[path/to/file]` | created/edited | +[N] | -[N] | +[N] |
| `[path/to/file]` | created/edited | +[N] | -[N] | +[N] |
| **Total** | | **+[N]** | **-[N]** | **+[N]** |

### Quyết định quan trọng

| # | Quyết định | Dữ liệu quyết định | Kết quả |
|:--|:--|:--|:--|
| 1 | [decision] | [evidence] | [outcome] |

---

## 4. Dấu hiệu & Patterns (Khách quan)

> ⚠️ **LUẬT KHÁCH QUAN:** Chỉ ghi nhận các hành vi lặp lại (patterns) hoặc dấu hiệu từ log. KHÔNG suy diễn thành "Bài học rút ra" (lessons learned) hay kết luận chủ quan.

### 4.1. [Tên Pattern / Dấu hiệu]

[Mô tả pattern + bằng chứng/ví dụ từ phiên, không kèm nhận xét đúng/sai hay bài học]

### 4.2. [Tên Pattern / Dấu hiệu]

[Mô tả pattern + bằng chứng/ví dụ từ phiên]

---

_Tài liệu nội bộ — YYYY-MM-DD_
_Nguồn: conversation memory, [other sources]_
```

---

### 📜 Type: `chronicle` — Development Chronicle

> Lịch sử diễn biến quá trình phát triển qua nhiều phiên.

```markdown
# [Feature/System Name] — Development Chronicle

> **Version**: 1.0 | **Last reviewed**: YYYY-MM-DD
> **Subject**: [Mô tả 1 dòng]
> **Period**: YYYY-MM-DD → YYYY-MM-DD
> **Conversations**: [list conversation IDs]

---

## 1. Bối cảnh

### Vấn đề cần giải quyết

[2-3 đoạn mô tả WHY]

### Giải pháp đề xuất

[Mô tả WHAT ở level cao]

---

## 2. Timeline

### Phase [N]: [Tên] (YYYY-MM-DD — Conv [short-id])

**Objective**: [1 dòng]

| Bước | Hành động | Kết quả |
|:-----|:----------|:--------|
| 1 | [action] | [result] |
| 2 | [action] | [result] |

**Quyết định quan trọng:**
- [decision + rationale]

**Git evidence:**

```text
[hash] [date] [commit message]
[hash] [date] [commit message]
```

### Phase [N+1]: [Tên] (YYYY-MM-DD — Conv [short-id])

[Repeat pattern...]

---

## 3. Artifacts tạo ra

| Artifact | Loại | Đường dẫn |
|:---------|:-----|:----------|
| [name] | brainstorm | [path] |
| [name] | plan | [path] |
| [name] | code | [path] |

---

## 4. Nhận diện Sự kiện/Dấu hiệu (Khách quan)

> ⚠️ **LUẬT KHÁCH QUAN:** Chỉ tổng hợp các sự kiện, dấu hiệu hoặc facts thực tế thu thập từ log/commit. KHÔNG suy diễn thành bài học.

### 4.1. [Tên Sự kiện / Dấu hiệu]

[Mô tả fact/event + evidence]

---

## 5. Trạng thái sau cùng

| Component | Status | Files |
|:----------|:-------|:------|
| [component] | ✅/🔴/🟡 | [files] |

### Tồn đọng

| # | Item | Priority | Target |
|:--|:-----|:---------|:-------|
| 1 | [item] | [emoji] | [version] |

---

## 6. Evolution Diagram

```text
v[X]          v[Y]          v[Z]
────          ────          ────
[summary] →   [summary] →   [summary]
```

---

_Tài liệu nội bộ — YYYY-MM-DD_
_Nguồn: [list sources]_
```

---

### 🔍 Type: `analysis` — Architecture Analysis

> Deep dive vào kiến trúc hệ thống, patterns, và trade-offs.

```markdown
# [System Name] — Architecture Analysis

> **Version**: 1.0 | **Last reviewed**: YYYY-MM-DD
> **Subject**: [Mô tả 1 dòng]
> **Scope**: [component / subsystem / full system]

---

## 1. Tổng quan hệ thống

[2-3 đoạn mô tả system ở level cao]

### System Diagram

```text
[ASCII component diagram]
```

---

## 2. Thành phần cốt lõi

### [Component 1]

| Thuộc tính | Giá trị |
|:--|:--|
| Location | `[path]` |
| Purpose | [what it does] |
| Dependencies | [list] |
| Consumers | [who uses it] |

**Cách hoạt động:**

[Chi tiết implementation, data flow, edge cases]

### [Component 2]

[Repeat pattern...]

---

## 3. Design Patterns nhận diện

| # | Pattern | Nơi áp dụng | Lý do |
|:--|:--------|:-------------|:------|
| 1 | [pattern] | [where] | [why] |

---

## 4. Trade-offs & Constraints

| Quyết định | Được gì | Mất gì | Alternatives xem xét |
|:-----------|:--------|:-------|:---------------------|
| [decision] | [gain] | [loss] | [alternatives] |

---

## 5. Rủi ro & Giải pháp

| Rủi ro | Mức | Mitigation |
|:-------|:----|:-----------|
| [risk] | 🔴/🟡/🟢 | [mitigation] |

---

## 6. Đề xuất cải thiện

| # | Đề xuất | Priority | Effort | Impact |
|:--|:--------|:---------|:-------|:-------|
| 1 | [proposal] | [emoji] | [estimate] | [impact] |

---

_Tài liệu nội bộ — YYYY-MM-DD_
_Nguồn: [source code, docs, KI artifacts]_
```

---

### ⚖️ Type: `compare` — Comparison Study

> So sánh approaches, tools, options.

```markdown
# [Topic] — Comparison Study

> **Version**: 1.0 | **Last reviewed**: YYYY-MM-DD
> **Subject**: [Mô tả 1 dòng]
> **Decision owner**: [user / team]

---

## 1. Bối cảnh

### Vấn đề cần giải quyết

[WHY we need to decide]

### Tiêu chí đánh giá

| # | Tiêu chí | Weight | Mô tả |
|:--|:---------|:-------|:------|
| 1 | [criteria] | 🔴 Must | [description] |
| 2 | [criteria] | 🟡 Should | [description] |
| 3 | [criteria] | 🟢 Nice | [description] |

---

## 2. Options

### Option [A]: [Name]

**Concept:** [2-3 câu]

**Pros:**
- [pro 1]
- [pro 2]

**Cons:**
- [con 1]
- [con 2]

**Evidence:** [code samples, benchmarks, references]

### Option [B]: [Name]

[Repeat pattern...]

---

## 3. So sánh tổng hợp

| Tiêu chí | Option A | Option B | Option C |
|:---------|:---------|:---------|:---------|
| [criteria 1] | ✅/❌/⚠️ | ✅/❌/⚠️ | ✅/❌/⚠️ |
| [criteria 2] | ✅/❌/⚠️ | ✅/❌/⚠️ | ✅/❌/⚠️ |

---

## 4. Quyết định

**Chọn: Option [X]**

**Lý do:**
1. [reason 1]
2. [reason 2]

**Mitigations cho cons:**
- [mitigation]

---

## 5. Next Steps

- [ ] [action item]

---

_Tài liệu nội bộ — YYYY-MM-DD_
_Nguồn: [brainstorm artifacts, code analysis, external research]_
```

---

## Output Checklist

- [ ] Research type identified and confirmed with user
- [ ] Evidence gathered from appropriate sources
- [ ] Research plan presented and approved
- [ ] Document follows the correct template for type
- [ ] All claims backed by evidence (tool calls, git commits, file paths)
- [ ] Failures and wrong assumptions included (transparency)
- [ ] `docs/researches/README.md` updated with new entry under the correct type
- [ ] Follow-up action suggested

## Related

- `/brainstorm` — Explore problems before formal research
- `/docs` — Create technical documentation (architecture, CLI, etc.)
- `/learn` — Extract reusable lessons from research findings
- `/knowledge` — Persist key findings as cross-session KI
- `/retro` — Project retrospective (may trigger research)
- `/end` — End session (research may be suggested for significant sessions)
