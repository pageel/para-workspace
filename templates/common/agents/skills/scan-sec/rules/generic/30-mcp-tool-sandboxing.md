---
id: MCP-TOOL-SANDBOXING
severity_max: CRITICAL
applies_to: typescript, javascript, python
---

# MCP Tool Sandboxing & Unconstrained Execution

## Intent

Detects unvalidated or un-sandboxed execution of Model Context Protocol (MCP) tools or AI Agent tool definitions. AI models are vulnerable to Prompt Injection attacks. If an MCP tool executes shell commands (`child_process.exec`, `os.system`), file system modifications, or database queries using raw string parameters without strict argument validation and sandboxing, an attacker can hijack the agent to achieve Remote Code Execution (RCE) or Data Exfiltration.

Reference OWASP Cheat Sheet Series: `MCP_Security_Cheat_Sheet.md` & `AI_Agent_Security_Cheat_Sheet.md`.

## When CRITICAL

- MCP tool accepts unvalidated parameters and executes raw OS shell commands (`exec`, `eval`, `subprocess`).
- MCP tool allows unrestricted file system path traversal outside workspace root.

## When HIGH / MEDIUM

- MCP tool executes write operations without validating schema bounds via Zod/Pydantic schemas.

## Search patterns (suggestions)

```typescript
CallToolRequestSchema
ListToolsRequestSchema
exec\(
spawn\(
```

## Examples

### BAD — Unvalidated Shell Command Execution in MCP Tool
```typescript
// BAD: Prompt injection in argument payload allows command injection
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === "run_script") {
    const cmd = request.params.arguments.command; // UNTRUSTED!
    return { content: [{ type: "text", text: execSync(cmd).toString() }] }; // RCE!
  }
});
```

### GOOD — Schema Validation & Parameterized Execution
```typescript
// GOOD: Strict Zod schema validation and direct binary execution without shell interpolation
const RunToolSchema = z.object({
  action: z.enum(["build", "test", "lint"])
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === "run_script") {
    const args = RunToolSchema.parse(request.params.arguments);
    const result = execFileSync("npm", ["run", args.action], { encoding: "utf-8" });
    return { content: [{ type: "text", text: result }] };
  }
});
```

## Fix recommendation

1. Validate 100% of MCP tool call arguments against strict type schemas (Zod or Pydantic).
2. Avoid shell command string interpolation; use `execFile` or `execFileSync` with explicit argument arrays.
3. Restrict file system tools strictly within designated sandbox directories.
