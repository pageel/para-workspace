---
id: HARDCODED-SECRET
severity_max: CRITICAL
applies_to: all
---

# Hardcoded Secret

## Intent

Khóa API / mật khẩu DB / token nhúng thẳng vào source code hoặc commit lên Git. **GitHub có bot quét 24/7 tìm secret lộ — lộ vài giây là bị scan sạch tài khoản, charge max billing**, chiếm AWS, dump DB, gửi spam email...

Đây là **lỗ hổng số 1** với vibe code vì AI thường sinh code "demo" với key cứng để chạy được luôn.

## Khi nào CRITICAL

- Secret trong file đã được commit hoặc sắp commit (staged)
- Secret là **live/production** (không phải test/sandbox key)
- Bao gồm cả file `.env`, `config.yaml`, `settings.py`, `*.config.js` — bất kỳ file nào không trong `.gitignore`

## Khi nào HIGH (giảm cấp)

- Secret trong file `.env.example` / `config.example.yaml` rõ ràng là placeholder (`YOUR_API_KEY_HERE`, `xxxx`, `changeme`)
- Test key đã rotated / expired
- Secret trong test fixture chỉ chạy local

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Quét tổng**: dùng Grep tìm pattern khả nghi (xem dưới)
2. **Verify**:
   - File đó có trong `.gitignore` không? (`cat .gitignore | grep -E "\.env|secret|credential"`)
   - Value là placeholder hay key thật? (Key thật thường: `sk_live_...`, `AKIA...`, `ghp_...`, `xoxb-...`, length >20, chứa entropy cao)
   - File có history commit nào không? (`git log --all --full-history -- <file>`)
3. **Trace**: secret này có được dùng đúng cách không? Có log ra response/error không? (rule cross-check với `VERBOSE-ERROR-DEBUG-MODE`)

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Trong code

```
# API keys nổi tiếng (prefix cố định)
sk_live_[a-zA-Z0-9]{20,}        # Stripe live secret key
sk_test_[a-zA-Z0-9]{20,}        # Stripe test (warn nhưng không critical)
AKIA[0-9A-Z]{16}                # AWS access key
ghp_[a-zA-Z0-9]{36}             # GitHub PAT
gho_[a-zA-Z0-9]{36}             # GitHub OAuth
xoxb-[0-9-]+-[a-zA-Z0-9]+       # Slack bot token
xoxp-[0-9-]+-[a-zA-Z0-9]+       # Slack user token
xapp-[0-9-]+-[a-zA-Z0-9]+       # Slack app token
sk-ant-[a-zA-Z0-9_-]{50,}       # Anthropic API key
sk-[a-zA-Z0-9]{48}              # OpenAI API key
AIza[0-9A-Za-z_-]{35}           # Google API key
hf_[a-zA-Z0-9]{30,}             # HuggingFace
pat_[a-zA-Z0-9]{30,}            # Generic PAT
[0-9a-f]{32,}                   # MD5/SHA1 hash — có thể là API key cũ

# Variable assignment patterns
(api_key|apikey|secret|password|passwd|token|access_token|private_key)\s*[:=]\s*["'][a-zA-Z0-9_\-]{16,}["']
PASSWORD\s*=\s*["'][^"']+["']
SECRET_KEY\s*=\s*["'][^"']+["']
```

### Trong config files

```
# .env, .yaml, .json
^(STRIPE_KEY|OPENAI_KEY|ANTHROPIC_KEY|AWS_SECRET|DATABASE_URL|JWT_SECRET|SESSION_SECRET)\s*=\s*[^$\{][^\s]+
# (loại trừ ${VAR} substitution patterns)
```

### Trong git history

```bash
git log --all --pretty=format: --name-only | sort -u | grep -E "\.env$|secrets?\.ya?ml$|credentials?\."
```

## Examples

### CRITICAL — flag

```python
# config.py — committed file
STRIPE_API_KEY = "sk_live_" + "51HxYzXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  # split so secret scanners don't false-flag this example
```

```javascript
// app.js
const openai = new OpenAI({ apiKey: "sk-proj-" + "REAL_KEY_GOES_HERE_xxxxxxxxxxxxxxxxx" });
```

```yaml
# docker-compose.yml — committed
services:
  app:
    environment:
      - DATABASE_URL=postgres://admin:RealPassword123@db:5432/prod
```

```php
<?php
// config.php
$config['db_password'] = 'P@ssw0rd!Real';
```

### NOT critical — không flag (hoặc downgrade)

```python
# .env.example — explicit example file
STRIPE_API_KEY=sk_live_YOUR_KEY_HERE  # placeholder
```

```javascript
// config.example.js
const apiKey = process.env.OPENAI_KEY || "your-key-here";
```

```yaml
# config.yaml — uses env var substitution
api_key: ${OPENAI_KEY}
```

```python
# test_payment.py — clearly a test, key is fake
STRIPE_TEST_KEY = "sk_test_" + "EXAMPLE_KEY_ONLY"  # split + placeholder so GitHub secret scanning doesn't false-alarm
```

## Fix recommendation

1. **Xoay (rotate) key NGAY** nếu đã commit lên Git public — kể cả khi đã delete file (Git history giữ lại). Coi như key đã lộ.
2. **Chuyển sang env var:**
   ```python
   # Trước (BAD)
   STRIPE_KEY = "sk_live_xxx"

   # Sau (GOOD)
   import os
   STRIPE_KEY = os.environ["STRIPE_KEY"]
   ```
3. **Thêm `.env` vào `.gitignore`:**
   ```
   .env
   .env.local
   .env.*.local
   secrets/
   credentials.json
   ```
4. **Cleanup Git history** (nếu cần thiết):
   ```bash
   # Dùng git-filter-repo hoặc BFG Repo-Cleaner
   git filter-repo --invert-paths --path .env
   git push --force  # CHỈ với coordinations team
   ```
   **CẢNH BÁO:** Force-push viết lại history, cần coordinate với mọi người clone repo. Trong nhiều trường hợp đơn giản hơn là rotate key + accept history.

5. **Dùng secret manager:**
   - AWS: Secrets Manager / Parameter Store
   - GCP: Secret Manager
   - Vercel/Netlify: dashboard env vars
   - Docker: `--env-file` hoặc `secrets:` trong compose v3.1+
   - Local dev: `.env` file (in `.gitignore`) + tool như `direnv` / `dotenv`

## Cross-references

- Cross-check với rule `17-verbose-error-debug-mode`: secret có thể lộ qua error log
- Cross-check với rule `20-outdated-dependency`: dependency có thể có CVE liên quan đến secret leak (vd: `node-config` cũ leak qua API)
