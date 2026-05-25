---
id: MISSING-RATE-LIMIT
severity_max: HIGH
applies_to: all
---

# Missing Rate Limit on Expensive Endpoints

## Intent

Endpoint **đắt tiền** (AI inference, image processing, search full-text, OTP/email send, password reset) không rate-limit → hacker viết script gọi 10k req/giây. Hậu quả:

- **AI endpoint**: hóa đơn OpenAI/Anthropic $50k/ngày (đã xảy ra với nhiều startup vibe code)
- **Email/SMS endpoint**: spam reset email → blacklist domain, bill SendGrid
- **Search/DB query**: full-table scan → DB sập
- **Image resize**: out-of-memory crash

Khác với BRUTE-FORCE-LOGIN (target auth) — rule này về **cost / DoS prevention** cho mọi expensive endpoint.

## Khi nào HIGH

- Endpoint gọi LLM / AI inference / image generation, **không có** rate limiter
- Endpoint gửi email / SMS / push notification từ user input
- Endpoint trigger cloud-billable operation (S3 list, video transcode, external API)
- Endpoint search / report tốn CPU/DB, không có pagination + rate limit
- Password reset / OTP send không có cooldown per email

## Khi nào MEDIUM (giảm cấp)

- Có rate limit nhưng quá lỏng (100 req/phút cho LLM endpoint = vẫn đốt tiền)
- Rate limit per IP nhưng dễ bypass với rotating proxy — cần thêm per-account
- Endpoint cheap nhưng được gọi loop từ frontend (waste resource, không phá)

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Liệt kê endpoint expensive**: AI call, file upload, email, search, report, external API
2. **Grep** tìm rate limit middleware: `express-rate-limit`, `flask-limiter`, `fastify-rate-limit`, `django-ratelimit`, `rack-attack`
3. **Read** xem endpoint expensive có gắn limiter không. Limiter có set đúng key (per-user, không chỉ per-IP)?
4. **Trace cost**:
   - Endpoint gọi `openai.chat.completions.create` / `anthropic.messages.create`? → CRITICAL nếu unlimited
   - Endpoint gọi `sendgrid.send` / `twilio.messages.create`? → spam vector
5. **Auth không thay thế rate-limit**: user login vẫn có thể spam — cần limit per account.

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Tìm endpoint expensive

```
# LLM / AI
openai\.(chat|completions|images|embeddings)
anthropic\.(messages|completions)
\.generate_content|\.invoke_model|bedrock-runtime
huggingface|replicate|stability

# Email / SMS
sendgrid|nodemailer|smtplib|mail\(|Mail::send|twilio|messagebird

# Image / video
sharp\(|jimp|Pillow|imagemagick|ffmpeg
```

### Tìm rate limiter

```
express-rate-limit|rateLimit\(
flask-limiter|@limiter\.limit
django-ratelimit|@ratelimit
fastify-rate-limit
rack-attack|Rack::Attack
@nestjs/throttler|ThrottlerGuard
```

### Negative search

Sau khi liệt kê endpoint expensive, grep ngược lại xem route handler có gắn middleware limiter không. Nếu route file không import limiter library → suspect.

## Examples

### HIGH — flag

```javascript
// Express — endpoint AI, unlimited
const OpenAI = require('openai');
const openai = new OpenAI();
app.post('/api/chat', async (req, res) => {
  const result = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: req.body.messages
  });
  res.json(result);
});
// Hacker script: while(true) fetch(...) → đốt $/giây
```

```python
# Flask — gửi email không cooldown
@app.route('/api/reset-password', methods=['POST'])
def reset():
    email = request.json['email']
    user = User.query.filter_by(email=email).first()
    if user:
        send_reset_email(user)   # gọi liên tục cho user → flood inbox
    return jsonify(ok=True)
```

```python
# Django search endpoint không paginate + không limit
def search(request):
    q = request.GET.get('q')
    results = Product.objects.filter(name__icontains=q)   # full table scan
    return JsonResponse([p.to_dict() for p in results], safe=False)
```

```javascript
// Image resize endpoint
app.post('/resize', upload.single('img'), async (req, res) => {
  const out = await sharp(req.file.path).resize(4000, 4000).toBuffer();
  res.send(out);   // hacker upload 100 file lớn parallel → OOM
});
```

### NOT critical — không flag

```javascript
// Express + express-rate-limit
const rateLimit = require('express-rate-limit');
const chatLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 20,                                  // 20 req/phút per IP
  keyGenerator: (req) => req.user?.id ?? req.ip,
  message: 'Too many requests'
});
app.post('/api/chat', chatLimiter, async (req, res) => { /* ... */ });
```

```python
# Flask-Limiter
from flask_limiter import Limiter
limiter = Limiter(get_remote_address, app=app)

@app.route('/api/reset-password', methods=['POST'])
@limiter.limit("3 per hour", key_func=lambda: request.json['email'])
def reset(): ...
```

```python
# Django-ratelimit
from django_ratelimit.decorators import ratelimit
@ratelimit(key='user_or_ip', rate='10/m', block=True)
def search(request): ...
```

## Fix recommendation

1. **Cài rate-limit middleware:**
   ```javascript
   // Express
   const rateLimit = require('express-rate-limit');
   const RedisStore = require('rate-limit-redis');
   app.use('/api/ai', rateLimit({
     store: new RedisStore({ /* ... */ }),
     windowMs: 60 * 1000,
     max: 10,
     keyGenerator: req => req.user?.id ?? req.ip
   }));
   ```
2. **Per-user limit** (không chỉ per-IP — IP rotating dễ):
   ```python
   @limiter.limit("100 per day", key_func=lambda: g.current_user.id)
   ```
3. **Tier theo plan**: free 10/giờ, paid 1000/giờ → kèm billing.
4. **Hard cap monthly** ở user level: ghi count vào DB, check trước khi gọi LLM API. Block khi vượt budget.
5. **Concurrency limit** cho image/video: queue worker (BullMQ, Celery) max N concurrent jobs.
6. **Captcha** cho endpoint gửi email/reset — bot không qua được.
7. **Alert** khi spike: monitoring (Datadog, Sentry) gửi notification khi rate > threshold.
8. **Cloudflare / WAF**: bật rate limit ở edge — chặn trước khi tới app.

## Cross-references

- Cross-check với `01-hardcoded-secret`: AI API key + missing rate limit = bankruptcy fast path
- Cross-check với `12-broken-access-control`: endpoint expensive chỉ-nội-bộ vô tình public
- Cross-check với `19-race-condition`: rate limit có thể bị race nếu counter không atomic
