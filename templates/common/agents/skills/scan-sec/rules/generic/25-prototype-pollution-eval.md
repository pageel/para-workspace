---
id: PROTOTYPE-POLLUTION-EVAL
severity_max: HIGH
applies_to: typescript, javascript
---

# Prototype Pollution & Unsafe Dynamic Evaluation

## Intent

Detects Prototype Pollution vulnerabilities or Unsafe Dynamic Code Evaluation (`eval()`, `new Function()`, `Object.assign` or `lodash.merge` with unvalidated input). Prototype Pollution allows attackers to overwrite properties on `Object.prototype`, leading to Authentication Bypass, Remote Code Execution (RCE), or Denial of Service (DoS).

Reference OWASP Cheat Sheet Series: `Nodejs_Security_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- L1 untrusted user input (from `req.body`, URL params) is used directly as an object key during assignment: `target[key] = val` without checking for dangerous keys `__proto__`, `constructor`, `prototype`.
- Using `eval()` or `new Function()` with L1 untrusted user input.

## When MEDIUM / LOW

- Using `Object.assign({}, ...)` with trusted L3 static objects.

## Search patterns (suggestions)

```javascript
eval\(
new Function\(
__proto__
\.prototype\.
lodash\.merge
deepMerge\(
```

## Examples

### BAD — Prototype Pollution Vulnerability
```typescript
function merge(target: any, source: any) {
  for (let key in source) {
    target[key] = source[key]; // BAD: Attacker can pass key "__proto__"
  }
}
```

### GOOD — Safe Object Creation & Key Filtering
```typescript
function merge(target: any, source: any) {
  for (let key in source) {
    if (key === "__proto__" || key === "constructor" || key === "prototype") continue;
    target[key] = source[key];
  }
}
```

## Fix recommendation

1. Eliminate all occurrences of `eval()` and `new Function()`.
2. Sanitize and reject dangerous keys (`__proto__`, `constructor`, `prototype`) prior to performing object merges.
3. Use `Map` or `Object.create(null)` when initializing dynamic dictionary objects from user input.
