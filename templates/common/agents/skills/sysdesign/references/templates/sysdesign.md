---
title: System Design: [Project/Subsystem Name]
status: Proposed
date: YYYY-MM-DD
target_version: vX.Y.Z
architecture_pattern: [pattern-slug]
reference_curriculum: "Standard Web Architecture Patterns"
---

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
