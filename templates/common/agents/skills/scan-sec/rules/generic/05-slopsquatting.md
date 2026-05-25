---
id: SLOPSQUATTING
severity_max: CRITICAL
applies_to: all
---

# Slopsquatting (AI-hallucinated Package Names)

## Intent

AI sinh code import package **không tồn tại trên npm/PyPI/Packagist** (hallucination). Attacker tự đăng ký tên đó với **malware bên trong**: post-install script đánh cắp `~/.aws/credentials`, `~/.ssh/`, env var, crypto wallet, hoặc cài backdoor RAT.

Đây là attack mới đặc trưng cho vibe code: research 2024 cho thấy LLM hay invent tên kiểu `requets`, `python-requestz`, `lodahs`, `react-toastr-pro`, `axios-utils`. Một khi attacker đăng ký, chỉ cần `npm install` là dính ngay.

## Khi nào CRITICAL

- Package name trông giống package nổi tiếng nhưng sai chính tả (`requets`, `lodahs`, `expresss`, `mongose`)
- Package có suffix lạ (`-js`, `-py`, `-pro`, `-utils`, `-helpers`, `-core`) không có nguồn nào nhắc đến
- Ký tự lookalike: `l` ↔ `I` ↔ `1`, `0` ↔ `O`, dấu gạch lạ
- Project chưa cài (chưa có trong `node_modules` / `pip freeze`)

## Khi nào MEDIUM (giảm cấp)

- Package có vẻ lạ nhưng đã cài thành công và chạy ổn (có thể là package thật ít nổi)
- Package thuộc tổ chức scoped đáng tin (`@vercel/*`, `@aws-sdk/*`, `@nestjs/*`)
- Đã pin version cụ thể trong lock file và lock file đã commit

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Collect** mọi import statement trong project:
   - JS/TS: `import ... from "..."`, `require("...")`, `package.json` `dependencies`
   - Python: `import X`, `from X import ...`, `requirements.txt`, `pyproject.toml`
   - PHP: `composer.json` `require`
   - Ruby: `Gemfile`
2. **Loại** built-in/std-lib (vd: `os`, `sys`, `fs`, `path`, `crypto`) và relative import (`./`, `../`)
3. **Đánh giá heuristic**:
   - Có giống tên phổ biến không? (Levenshtein distance ≤ 2 với `requests`, `lodash`, `express`, `react`, `axios`, `numpy`, `pandas`...)
   - Có suffix khả nghi không? (`-js`, `-py`, `-pro`, `-helpers`, `-core`, `-utils`)
   - Có ký tự lookalike không?
   - Có scope không (`@org/name`)? Scope chính chủ thì an toàn hơn.
4. **Verify** (cảnh báo cho user, scanner không tự lên mạng):
   - JS: `npm view <name>` — kiểm tra publisher, downloads/week, age, repo URL
   - Python: `pip show <name>` hoặc check `pypi.org/project/<name>`
   - Cross-check: lock file có chứa package này chưa? Nếu chưa, **cảnh báo trước khi install**
5. Chú ý: package mới upload <30 ngày, weekly downloads <100, không có repo GitHub → đỏ rực

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### JS/TS

```
^import\s+.*\s+from\s+["']([^"'./][^"']*)["']
^const\s+.*=\s+require\s*\(\s*["']([^./][^"']*)["']
# package.json
"dependencies"\s*:\s*\{
```

### Python

```
^import\s+([a-z_][a-z0-9_]*)
^from\s+([a-z_][a-z0-9_]*)\s+import
# requirements.txt
^[a-zA-Z][a-zA-Z0-9_-]+
```

### Suspicious heuristics

```
# Lookalike / typo của package nổi tiếng (check thủ công)
requets|requestz|python-requests-                 # vs "requests"
lodahs|lodahs-utils|lodash-pro                    # vs "lodash"
expresss|express-pro|express-helpers              # vs "express"
mongose|mongoosee                                 # vs "mongoose"
axios-utils|axios-helpers|axios-pro               # khả nghi
react-toastr-pro|react-utils-helpers              # generic suffix
```

## Examples

### CRITICAL — flag

```javascript
// import gần giống "requests" của Python nhưng người dùng để vào Node?
const requets = require("requets");   // Typo của "requests"? Hay slopsquatting?
```

```python
# AI hay hallucinate kiểu này
import python_requests_pro       # KHÔNG tồn tại — slopsquatting bait
from openai_helpers import gpt   # KHÔNG có package "openai_helpers" chính thức
```

```json
// package.json — suspicious suffix, weekly downloads = 12
{
  "dependencies": {
    "lodahs": "^1.0.0",
    "express-utils-pro": "^0.1.2",
    "react-router-helpers": "*"
  }
}
```

```python
# requirements.txt
flask-utils-pro==0.0.1     # CỜ ĐỎ — version 0.0.1, suffix lạ
requets>=2.0                # typo của "requests"
```

### NOT critical — không flag (hoặc downgrade)

```javascript
// Scoped package từ tổ chức uy tín
import { createClient } from "@supabase/supabase-js";
import { S3Client } from "@aws-sdk/client-s3";
import { Module } from "@nestjs/common";
```

```python
# Package std/phổ biến — tên đúng
import requests
import numpy as np
from fastapi import FastAPI
```

```json
// package.json — lock file commit, version pin
{
  "dependencies": {
    "express": "4.19.2",
    "axios": "1.7.2"
  }
}
```

## Fix recommendation

1. **Trước khi install bất kỳ package nào do AI gợi ý, VERIFY:**
   ```bash
   # JS
   npm view <name>                # check publisher, repo, downloads
   npm view <name> time            # ngày publish

   # Python
   pip show <name>
   # hoặc mở https://pypi.org/project/<name>
   ```
2. **Đỏ rực nếu**:
   - Weekly downloads < 1000 với JS, < 500 với Python
   - Publisher / repo không tồn tại
   - Package mới publish <30 ngày
   - Tên gần giống package nổi tiếng (Levenshtein ≤ 2)
3. **Commit lock file** (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `poetry.lock`, `Pipfile.lock`) — bắt buộc.
4. **Bật npm/pip integrity check**:
   ```bash
   npm config set audit-level moderate
   npm install --ignore-scripts <name>   # chặn post-install script — sau đó audit
   pip install --require-hashes -r requirements.txt
   ```
5. **Dùng tool quét**:
   - `socket.dev` — phát hiện malware npm
   - `pip-audit` — CVE Python
   - `npm audit` — CVE Node
6. **Nếu lỡ install package khả nghi**:
   - `npm uninstall <name>` ngay
   - Xóa `node_modules` và lock file, install lại từ đầu
   - **Coi như máy đã bị compromised**: rotate AWS/GH/SSH key, scan máy bằng anti-malware

## Cross-references

- Rule `01-hardcoded-secret`: malware từ slopsquatting scan secret trong code và env
- Rule `20-outdated-dependency`: package cũ có CVE — khác slopsquatting nhưng cùng họ supply chain
