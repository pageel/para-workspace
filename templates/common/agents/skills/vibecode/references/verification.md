# Verification Commands by Project Type

> JIT-loaded by `/vibecode` when running verify steps in loop/auto modes.

## Node.js / TypeScript

```bash
npm run build 2>&1 | tail -30
echo "EXIT: $?"

npm run lint 2>&1 | tail -20
echo "EXIT: $?"

npx tsc --noEmit 2>&1 | tail -20
echo "EXIT: $?"
```

## Astro / Vite

```bash
npm run build 2>&1 | tail -30
echo "EXIT: $?"

npx astro check 2>&1 | tail -20
echo "EXIT: $?"
```

## Bash / Shell Scripts

```bash
# Syntax check
bash -n [script.sh] 2>&1
echo "EXIT: $?"

# ShellCheck (if available)
command -v shellcheck && shellcheck [script.sh] 2>&1 | tail -20
```

## Markdown / Documentation

```bash
# Check for broken links (relative paths)
grep -rn '](.*\.md)' [file] | while read line; do
  REF=$(echo "$line" | grep -oP '\]\(\K[^)]+')
  DIR=$(dirname "$(echo "$line" | cut -d: -f1)")
  FULL="$DIR/$REF"
  [ ! -f "$FULL" ] && echo "❌ BROKEN: $line → $FULL"
done

# Check YAML frontmatter
head -1 [file] | grep -q "^---" && echo "✅ Frontmatter OK" || echo "⚠️ No frontmatter"
```

## PARA Workspace (meta-project)

```bash
# No build step — validate structure
echo "=== CATALOG CONSISTENCY ==="
# Check each catalog entry has a matching file
yq '.items[].entrypoint' catalog.yml | while read f; do
  [ -f "$f" ] && echo "✅ $f" || echo "❌ MISSING: $f"
done

echo "=== VERSION CONSISTENCY ==="
cat VERSION
grep 'Version:' project.md
```

## Custom (user-defined)

If project type is unknown, ask user:

```
No verification command detected for this project type.
Please provide:
  1. Build command (e.g., `npm run build`)
  2. Test command (e.g., `npm test`)
  3. Lint command (e.g., `npm run lint`)
Or type 'skip' to proceed without verification.
```
