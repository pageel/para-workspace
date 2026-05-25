---
id: INSECURE-DESERIALIZATION
severity_max: CRITICAL
applies_to: typescript
---

# Insecure Deserialization — TypeScript/JavaScript Specialization

> Override cho rule chung `rules/generic/08-insecure-deserialization.md`. Áp dụng khi `primary_language: typescript`.

## Intent (TypeScript-specific)

Node.js có vài package nhỏ nhưng đầy lỗ hổng deserialization classic RCE:
- **`js-yaml` v3 default `load()`**: cho phép `!!js/function` → instantiate hàm tùy ý khi parse YAML
- **`node-serialize`**: `serialize.unserialize()` với payload `_$$ND_FUNC$$_` chạy code ngay khi parse — bài tập CTF kinh điển
- **Node `vm.runInNewContext(userInput)`**: chạy JS trong sandbox yếu, dễ break out
- **`notevil`, `safe-eval`, `eval-stringify`**: thư viện "safe eval" — đều có CVE bypass

JSON.parse bản thân an toàn (không chạy code), nhưng nếu pass `reviver` function xử lý user data và reviver có logic gì đó thì có thể nguy hiểm gián tiếp.

## Khi nào CRITICAL

- `yaml.load(userInput)` với `js-yaml` < v4 (mặc định v3 dùng DEFAULT_FULL_SCHEMA cho phép code)
- `serialize.unserialize(userInput)` từ package `node-serialize`
- `vm.runInNewContext(code)` / `vm.runInThisContext` / `new vm.Script(code).runInContext()` với `code` từ request
- `eval(userInput)`, `new Function(userInput)`, `Function(userInput)()`
- `notevil`, `safe-eval`, `vm2` (đã bị CVE RCE 2023 — nếu thấy version < 3.9.19)
- `funcster.deepDeserialize`

## Khi nào HIGH (giảm cấp)

- `yaml.load(input)` với `js-yaml` v4+ (default an toàn — nhưng vẫn nên dùng `yaml.load(input, { schema: yaml.JSON_SCHEMA })`)
- `JSON.parse(input)` không có reviver phức tạp — chỉ HIGH nếu input cực lớn (DoS qua sparse array, prototype pollution với `__proto__`)
- Prototype pollution: `Object.assign({}, JSON.parse(input))` nếu input có `__proto__` key → pollute global Object

## Cách reasoning

1. **Grep** sink: `yaml\.load`, `unserialize`, `vm\.run`, `eval\(`, `new Function`, `Function\(`, `safe-eval`, `notevil`
2. **Read** import: `const yaml = require('js-yaml')` — check `package.json` version. v3 là CRITICAL, v4+ là HIGH nhưng vẫn warn nếu không pass `JSON_SCHEMA`
3. **Trace input → sink**:
   - `yaml.load(req.body.config)` — L1 direct
   - `yaml.load(fs.readFileSync(path))` — L3 (file), risk thấp hơn trừ khi `path` là L1 (path traversal kết hợp)
4. **Verify**:
   - js-yaml: dùng `yaml.load(s, { schema: yaml.SAFE_SCHEMA })` (v3) hoặc `JSON_SCHEMA`?
   - vm: có sandbox isolated context + timeout? (vẫn không đủ — vm2 đã có RCE)

## Search patterns

```
# js-yaml
require\(["']js-yaml["']\)
from\s+["']js-yaml["']
yaml\.load\s*\(
yaml\.loadAll\s*\(
# NEGATIVE — safe form:
yaml\.safeLoad\s*\(            # v3 safe
\{\s*schema:\s*yaml\.(SAFE|JSON)_SCHEMA\s*\}

# node-serialize
require\(["']node-serialize["']\)
serialize\.unserialize
\.unserialize\s*\(

# vm module
require\(["']vm["']\)
import\s+vm\s+from\s+["']vm["']
vm\.runIn(NewContext|ThisContext|Context)
new vm\.Script

# eval-like
\beval\s*\(
new Function\s*\(
Function\s*\(["'`]            # Function('return ...')()

# Sketchy libs
require\(["'](notevil|safe-eval|node-serialize|funcster|eval-stringify|vm2)["']\)

# Prototype pollution
Object\.assign\s*\(\s*\{\s*\}\s*,\s*JSON\.parse
_\.merge\s*\([^,]+,\s*JSON\.parse
```

## Examples

### CRITICAL — flag

```typescript
// js-yaml v3 load với user input → RCE
import yaml from 'js-yaml';

app.post('/config', (req, res) => {
  const config = yaml.load(req.body.yamlConfig);
  // Payload: "!!js/function 'function(){require(\"child_process\").exec(\"...\")}'"
});
```

```typescript
// node-serialize — classic RCE
import serialize from 'node-serialize';

app.post('/import', (req, res) => {
  const data = serialize.unserialize(req.body.data);
  // Payload: {"a":"_$$ND_FUNC$$_function(){require('child_process').exec('id')}()"}
});
```

```typescript
// vm.runInNewContext với code từ user
import vm from 'vm';

app.post('/run', (req, res) => {
  const result = vm.runInNewContext(req.body.code, {});
  // Sandbox break-out trivial qua constructor chain
});
```

```typescript
// eval với JSON-like input
app.get('/calc', (req, res) => {
  const result = eval(req.query.expr as string);  // CRITICAL
  res.json({ result });
});
```

```typescript
// vm2 outdated (RCE CVE-2023-29017 nếu < 3.9.17)
// package.json: "vm2": "3.9.0" — flag
import { VM } from 'vm2';
const vm = new VM();
vm.run(userCode);  // có CVE đã public exploit
```

### NOT critical — safe

```typescript
// js-yaml v4 load (default SAFE)
import yaml from 'js-yaml';  // v4+
const config = yaml.load(yamlString);  // không thực thi function

// Hoặc explicit JSON_SCHEMA
const safe = yaml.load(input, { schema: yaml.JSON_SCHEMA });
```

```typescript
// JSON.parse — không thực thi code (vẫn cần guard prototype pollution)
const data = JSON.parse(req.body.json);
// Nhưng phải tránh: Object.assign({}, data) nếu data có __proto__

// Safer:
const data = JSON.parse(req.body.json, (key, val) => {
  if (key === '__proto__' || key === 'constructor') return undefined;
  return val;
});
```

```typescript
// Isolated-vm (production-grade alternative to vm2) — vẫn cần thận trọng
import ivm from 'isolated-vm';
const isolate = new ivm.Isolate({ memoryLimit: 8 });
// Có thể chấp nhận nếu nguồn code là trusted developer plugin, không phải user-internet
```

## Fix recommendation

1. **YAML**: dùng `js-yaml` v4+ với schema rõ ràng:
   ```typescript
   import yaml from 'js-yaml';
   const safe = yaml.load(input, { schema: yaml.JSON_SCHEMA });
   ```
   Nếu kẹt v3, dùng `yaml.safeLoad()`. Cập nhật package ngay.

2. **KHÔNG dùng** `node-serialize`, `serialize-javascript` (cho parse), `notevil`, `safe-eval`, `eval-stringify`, `funcster` — đều có lịch sử CVE.

3. **vm/vm2**: nếu thật sự cần chạy code untrusted, dùng `isolated-vm` + memory/time limit + KHÔNG expose Node globals. Tốt nhất chạy trong subprocess hoặc container.

4. **Thay eval bằng parser chính thức**:
   - Expression math: `mathjs` (`math.evaluate(expr)`)
   - Template: `handlebars` precompiled
   - Logic: `json-logic-js` (declarative)

5. **Prototype pollution defense**:
   ```typescript
   // package: secure-json-parse
   import sjson from 'secure-json-parse';
   const data = sjson.parse(req.body.json);  // strip __proto__/constructor
   ```
   Hoặc upgrade Node ≥ 17 (built-in `Object.hasOwn`), set `Object.freeze(Object.prototype)` early.

6. **Audit deps**: `npm audit` → check `js-yaml`, `vm2`, `lodash.merge`, `set-value`, `unset-value` (lịch sử proto pollution).

## Cross-references

- TS `21-command-injection`: deserialization RCE thường chain với `child_process.exec`
- TS `02-sql-injection` / `09-ssrf`: deserialization có thể chain để vượt input filter
- Generic `20-outdated-dependency`: `vm2`, `js-yaml@3`, `node-serialize` đều có CVE public
- TS `17-verbose-error-debug-mode`: error parse YAML leak file path / nội dung
