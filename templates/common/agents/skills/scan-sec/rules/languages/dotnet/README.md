# .NET Specialization Rules

This specialization applies to `primary_language: dotnet`, covering C# / ASP.NET Core / Minimal APIs / EF Core / Newtonsoft.Json / `System.Diagnostics.Process`.

## Rules

| Rule | File | Focus |
|---|---|---|
| SQL-INJECTION | `02-sql-injection.md` | EF Core raw SQL (`FromSqlRaw`, `ExecuteSqlRaw`), ADO.NET `SqlCommand` |
| MASS-ASSIGNMENT | `07-mass-assignment.md` | ASP.NET Core model binding directly into database/domain models |
| INSECURE-DESERIALIZATION | `08-insecure-deserialization.md` | Newtonsoft `TypeNameHandling` vulnerabilities, and legacy formatters (BinaryFormatter, NetDataContractSerializer, LosFormatter) |
| COMMAND-INJECTION | `21-command-injection.md` | `Process.Start`, `ProcessStartInfo` shell invocation, and unsafe command-line argument construction |

## Detection notes

The `dotnet` primary language is detected from `.cs`, `.csproj`, `.sln`, `global.json`, and `appsettings.json`. If a repository has a TypeScript frontend alongside an ASP.NET Core backend, load both `typescript` and `dotnet` overlays if both exceed their respective detection thresholds.

## Reasoning

These rules must not perform simple pattern matching. The agent must trace data flows through trust levels L1-L4:

1. **L1 Sources**: Route parameters, query strings, request bodies, headers, form fields, and file uploads bound automatically by ASP.NET Core.
2. **Sinks**: Raw SQL inputs, entity updates, unsafe deserializers, and process execution sinks.
3. **Sanitization/Mitigation**: Parameterized queries in EF/ADO.NET, DTO-based allowlists, safe serializer configurations, and list-form process argument passing/whitelisting.
4. **Verdict**: Report findings only when untrusted inputs reach a sink without adequate sanitization or mitigation.
