# Chunking Strategy

How files are divided into chunks for LARGE mode (sub-agent delegation). Each chunk is scanned by a sub-agent sequentially or in parallel.

## Goals

- **Clear Scope**: One chunk = one logical part of the repository (not just single files).
- **Adequate Context**: Each chunk contains enough context for reasoning (avoid cutting mid-function).
- **Load Balancing**: Maintain roughly similar sizes across chunks.
- **Avoid Excess Chunks**: Target 3-10 chunks (sub-agent overhead is high; avoid dozens of tiny chunks).

## Default Strategy: Top-Level Folders

Group files by their **top-level folder** under the git root, where each folder represents one chunk.

```
my-repo/
├── api/           ← chunk 1
├── web/           ← chunk 2
├── shared/        ← chunk 3
└── scripts/       ← chunk 4
```

Files at the root level (e.g.: `package.json`, `Dockerfile`, `.env.example`) are grouped into a dedicated chunk named `root`.

## Balancing Rules

1. **Chunks with >50 files** → Split into smaller chunks by sub-folders:
   ```
   api/ (120 files) → split:
     ├── api/handlers/   ← chunk
     ├── api/middleware/ ← chunk
     └── api/services/   ← chunk
   ```

2. **Folders with <5 files** → Merge with another similar chunk:
   ```
   utils/ (3 files) + helpers/ (4 files) → 1 chunk "utils+helpers"
   ```

3. **Detected Primary Language ≠ Folder Language** → Prioritize language grouping so sub-agents can apply the correct language-specific rules overlay:
   - Example: `frontend/` contains `.ts`, `backend/` contains `.go` → 2 chunks, each with its own language profile.

4. **Test files**: Group `__tests__/`, `*_test.go`, `*.spec.ts` into the parent chunk of the code they test. Rationale: security rules apply differently to test code (e.g. hardcoded credentials in test fixtures are usually not critical).

## Alternative Strategy: Extension Clustering

When a repository lacks a structured folder hierarchy (flat repo where files are mixed at the root), group by extension clusters:

```
flat-repo/
├── *.go (8 files)        ← chunk "go"
├── *.py (5 files)        ← chunk "python"
├── *.js (3 files)        ← chunk "js"
├── Dockerfile, .env*     ← chunk "config"
```

## Strategy by File Count

| Total Files | Target Chunks | Files/Chunk |
|---|---|---|
| 30-60 | 3-5 | ~10-15 |
| 60-150 | 5-8 | ~15-25 |
| 150-300 | 8-12 | ~20-30 |
| >300 | 12-15 | ~25-30 |

Max limit: 15 chunks. Beyond this, sub-agent startup overhead and main-agent aggregation context sizes degrade performance.

## Pseudocode

```python
def chunk_files(files, max_files_per_chunk=30, target_chunks_max=15):
    # 1. Group by top-level folder
    groups = {}
    for f in files:
        top = f.split("/")[0] if "/" in f else "root"
        groups.setdefault(top, []).append(f)

    # 2. Split big chunks
    final = []
    for folder, fs in groups.items():
        if len(fs) > max_files_per_chunk:
            # Split by sub-folder
            sub_groups = {}
            for f in fs:
                parts = f.split("/")
                sub = parts[1] if len(parts) > 1 else parts[0]
                sub_groups.setdefault(f"{folder}/{sub}", []).append(f)
            for sub_folder, sub_fs in sub_groups.items():
                final.append({"name": sub_folder, "files": sub_fs})
        else:
            final.append({"name": folder, "files": fs})

    # 3. Merge tiny chunks
    tiny = [c for c in final if len(c["files"]) < 5]
    if len(tiny) >= 2:
        merged_name = "+".join(c["name"] for c in tiny)
        merged_files = [f for c in tiny for f in c["files"]]
        final = [c for c in final if len(c["files"]) >= 5]
        final.append({"name": merged_name, "files": merged_files})

    # 4. If still too many chunks, merge sequentially
    while len(final) > target_chunks_max:
        final.sort(key=lambda c: len(c["files"]))
        c1, c2 = final.pop(0), final.pop(0)
        final.append({"name": f"{c1['name']}+{c2['name']}", "files": c1["files"] + c2["files"]})

    return final
```

The LLM agent uses reasoning to perform the chunking based on these rules; direct Python execution is not required.

## Orchestration Output Format

Once chunked, the main agent maintains a listing structure:

```
[
  {"name": "api/handlers", "files": ["api/handlers/user.ts", "api/handlers/order.ts", ...], "count": 12},
  {"name": "api/middleware", "files": [...], "count": 8},
  {"name": "frontend/src/components", "files": [...], "count": 25},
  ...
]
```

Each chunk is processed as a separate task. Sub-agents receive their files along with the prompt template (see [`sub-agent-prompts.md`](sub-agent-prompts.md)).

## Edge Cases

| Scenario | Handling Strategy |
|---|---|
| Git submodules in repo | Skip submodules (do not scan). Note in final report. |
| Generated code occupies 80% of chunk | Split: chunk "generated" (low priority) + chunk source. Skip "generated" if confirmed by user. |
| Monorepo with 50+ apps | Chunk by app (prioritizing top-level `apps/<name>`); avoid splitting deeper. |
| Single file > 5000 lines | Keep as a single chunk (do not split a single file). Mark as "large file, review carefully". |
| Tiny repository (e.g. <30 files) | Do not trigger LARGE mode; fallback to SMALL mode. |
