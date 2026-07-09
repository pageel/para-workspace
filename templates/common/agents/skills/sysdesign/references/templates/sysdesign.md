---
title: System Design: [Project/Subsystem Name]
status: Proposed
date: YYYY-MM-DD
target_version: vX.Y.Z
architecture_pattern: [pattern-slug]
scale: [small | medium | large | enterprise]
reference_curriculum: "Standard Web Architecture Patterns"
---

<!-- ⚠️ CONDITIONAL RENDERING:
  - scale: small/prototype → Sections 5 & 6 may be simplified or omitted
  - scale: medium → Section 5 required, Section 6 optional
  - scale: large/enterprise → All 6 sections required
-->

# System Design: [Project/Subsystem Name]

---

## 1. Infrastructure & Deployment Architecture
*   **Deployment Target**: [e.g., Cloudflare Workers, Docker on AWS EC2]
*   **Networking & Gateway**: [CDN, Load balancer, CORS, domain routes]
*   **Load Balancing & Routing Algorithm**: [e.g., Weighted Round-Robin, Least Connections, IP Hashing]
*   **Clustering & Redundancy Configuration**: [e.g., Active-Active or Active-Passive for high availability]
*   **Environment Configuration**:
    ```ini
    # .env.example
    PORT=3000
    DATABASE_URL=
    ```
*   **Secret Management**: [Where secrets are stored, e.g. Cloudflare Secrets, AWS Secrets Manager]
*   **Latency & Performance Budget**: [L1/L2 cache vs RAM vs SSD vs Network latency budget. e.g., Max database roundtrips = 2, target endpoint execution < 50ms]

## 2. API & Communication Design
*   **Protocols**: [REST / GraphQL / gRPC / WebSockets]
*   **Connection Protocols**: [e.g., Long polling, WebSockets, Server-Sent Events]
*   **Contracts & Payload Schemas**:
    ```typescript
    // Example Request/Response contracts
    ```
*   **Pagination Design**: [e.g., Keyset/Cursor-based pagination (recommended for high-churn/infinite scroll)]
*   **Idempotency & Retry Details**: [e.g., Idempotency-Key headers for mutative endpoints, client retries with exponential backoff and jitter]
*   **Authentication & Authorization**: [JWT, API Key, Session config, OAuth 2.0 / OIDC]
*   **Boundary & Transport Matrix**: [MANDATORY for multi-subsystem/cross-domain APIs: Specify the transport method (Client-to-Server vs Server-to-Server) and the corresponding credential transmission mechanism (Cookie, Header, token)]
*   **Fault Tolerance & Resiliency Strategy**: [Fault tolerance mechanisms: e.g., Bulkhead, Rate Limiting, Backpressure/flow control, Graceful Degradation]
*   **Standard Error Format**:
    ```json
    { "success": false, "error": { "code": "ERROR_CODE", "message": "Details" } }
    ```

## 3. Database & Storage Architecture
*   **Storage Selection**: [RDBMS / NoSQL / Graph - Reason for choice]
*   **Consistency Model**: [ACID vs. BASE consistency model]
*   **CAP / PACELC Trade-off**: [How the database handles Partitioning: Consistency vs. Latency under partition]
*   **Concurrency & Deduplication Strategy**: [Double-write prevention, idempotency logic, and concurrency controls e.g., Optimistic/Pessimistic locking, Distributed Lock]
*   **Data Models & ERD**:
    > **Design Constraint**: Specify exact entity cardinality (e.g., `1:1`, `1:N`, `N:N`) on the Mermaid diagram. If this is a feature-level sysdesign, show only local/relevant tables and link back to the central `sysdesign-database-schema.md` (SSOT) to avoid schema drift.
    ```mermaid
    erDiagram
        USER ||--o{ POST : writes
    ```
*   **Schema Definition (DDL / ORM)**:
    ```sql
    -- SQL schema DDL or ORM structures
    ```
*   **Distributed Transaction Strategy**: [e.g., Saga pattern, Two-Phase Commit, or Local-only]
*   **Indexes & Optimization**: [Indexes needed on key queries to optimize latency]
*   **Migrations**: [Steps to apply database changes safely without downtime]

## 4. Software Topology
*   **Folder Structure & Code Separation**: [Directory layout guidelines]
*   **Component & Class Diagram**: [Mermaid class/component diagram separating system components]
*   **Resiliency Patterns**: [e.g., Circuit Breaker, Rate Limiting, Retries]
*   **Sequence Diagrams (Core Flow)**:
    ```mermaid
    sequenceDiagram
        Client->>API: Request
    ```
*   **Architecture Decision Records (ADR)**: Links to `adr/` files.

## 5. Security Architecture & Threat Model

<!-- Conditional: If scale = small AND architecture_pattern = astro-static → simplify to "Security Headers & CSP" only -->

*   **Authentication & Authorization Topology**: [Token flow diagram, session lifecycle, credential storage, MFA strategy]
*   **Browser Sandbox Constraints & Cookie Policies**: [MANDATORY for cookie/session-based architectures: Specify cookie security flags (HttpOnly, Secure, SameSite), Domain scope, and CORS Credentials options to prevent browser blocking]
*   **Trust Boundary Diagram**:
    ```mermaid
    graph TD
        subgraph "Untrusted Zone"
            Client[Browser / Mobile Client]
        end
        subgraph "DMZ / Edge"
            CDN[CDN / WAF]
            Gateway[API Gateway]
        end
        subgraph "Trusted Zone"
            AppServer[Application Server]
            DB[(Database)]
        end
        Client -->|HTTPS| CDN
        CDN -->|TLS| Gateway
        Gateway -->|Internal| AppServer
        AppServer -->|Encrypted| DB
    ```
*   **Threat Surface Analysis (STRIDE Simplified)**:
    | Threat | Category | Affected Component | Mitigation |
    |:--|:--|:--|:--|
    | [e.g., Session hijacking] | Spoofing | Auth module | [e.g., HttpOnly cookies, SameSite=Strict] |
    | [e.g., SQL injection] | Tampering | Database layer | [e.g., Parameterized queries, ORM] |
    | [e.g., Missing audit log] | Repudiation | API endpoints | [e.g., Structured audit logging] |
    | [e.g., Token leak in logs] | Info Disclosure | Logging system | [e.g., PII redaction filter] |
    | [e.g., Rate limit bypass] | Denial of Service | API Gateway | [e.g., Token bucket, WAF rules] |
    | [e.g., Privilege escalation] | Elevation | RBAC system | [e.g., Principle of least privilege] |
*   **Secret Rotation Strategy**: [Rotation schedule, zero-downtime rotation mechanism, key versioning]
*   **Data Classification & Encryption**:
    | Classification | Examples | At Rest | In Transit | Retention |
    |:--|:--|:--|:--|:--|
    | PII | Email, name | AES-256 | TLS 1.3 | 90 days after deletion |
    | Credentials | Passwords, tokens | bcrypt/PBKDF2 | TLS 1.3 | Never stored raw |
    | Public | Blog posts | N/A | HTTPS | Indefinite |
*   **Security Headers & CSP**: [Content-Security-Policy, X-Frame-Options, Strict-Transport-Security, Permissions-Policy]

## 6. Observability & Day-2 Operations

<!-- Conditional: If scale = small/prototype → this section may be omitted entirely -->

*   **Structured Logging**:
    *   Format: [JSON logs with correlation ID]
    *   Log Levels: `DEBUG` (dev only), `INFO` (request lifecycle), `WARN` (degraded), `ERROR` (failures), `FATAL` (shutdown)
    *   PII Redaction: [Fields to mask in production logs]
    ```json
    {
      "timestamp": "2026-01-01T00:00:00Z",
      "level": "INFO",
      "correlationId": "req-uuid",
      "message": "Request processed",
      "duration_ms": 42,
      "status": 200
    }
    ```
*   **Metrics & SLOs**:
    | Metric | Target SLO | Alert Threshold | Collection |
    |:--|:--|:--|:--|
    | Availability | 99.9% | < 99.5% over 5m | [Prometheus / CloudWatch] |
    | Latency (p99) | < 200ms | > 500ms over 1m | [Histogram metric] |
    | Error Rate | < 1% | > 5% over 5m | [Counter metric] |
    | Saturation | < 80% CPU/Mem | > 90% over 5m | [Gauge metric] |
*   **Health Check Endpoints**:
    *   `GET /healthz` — Liveness probe (returns `200 OK` if process is alive)
    *   `GET /readyz` — Readiness probe (returns `200 OK` if dependencies are connected: DB, cache, external APIs)
*   **Distributed Tracing**: [OpenTelemetry / Jaeger / X-Ray — trace ID propagation strategy across services]
*   **Alerting & Escalation**:
    *   **P1 (Critical)**: Service down, data loss risk → immediate page
    *   **P2 (High)**: Degraded performance, error spike → 15-min response
    *   **P3 (Medium)**: Non-critical warnings → next business day
*   **Runbook References**: Links to operational runbooks for common failure modes
