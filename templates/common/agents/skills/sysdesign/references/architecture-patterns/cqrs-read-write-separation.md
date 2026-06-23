# Reference Architecture: CQRS & Read-Write Separation

## 1. Topology
*   **Write Database (Command Path)**: Relational database (e.g., PostgreSQL) optimized for transactional integrity (ACID).
*   **Read Database (Query Path)**: NoSQL search/cache engine (e.g., Elasticsearch, Redis) optimized for high-throughput, denormalized read queries.
*   **Synchronization Mechanism**: Asynchronous Change Data Capture (CDC) or application-level events to keep the Read DB synced.

## 2. API Spec (Command vs Query)
*   **Write API (Commands)**:
    *   Endpoint: `POST /api/v1/orders` (payload validation, returns `202 Accepted` + tracking ID).
    *   Validation: Dynamic validation with strong schemas (e.g., `zod`).
*   **Read API (Queries)**:
    *   Endpoint: `GET /api/v1/orders?page=2&limit=50` (returns pre-denormalized views directly from search index).
    *   Pagination: Cursor-based pagination recommended.

## 3. Database & Storage Architecture
*   **Consistency Model**: Strong consistency on the Write DB; Eventual consistency on the Read DB (CAP Theorem trade-off: PACELC - write path favors Consistency under Partition, read path favors Latency).
*   **Read-Write Sync Delay Handling**: Client UI should handle latency gracefully (e.g., optimistic UI updates or polling using Command ID).
*   **Write DB Schema**: Normalized DDL (3NF).
*   **Read DB Schema**: Flat JSON documents ready for display without join queries.

## 4. Software Topology
*   **Command vs. Query Code Flow Diagram**:
    ```mermaid
    graph TD
        Client[Client] --> CommandAPI[Write API - Command]
        Client --> QueryAPI[Read API - Query]
        
        CommandAPI --> WriteDB[(Write DB - PostgreSQL)]
        QueryAPI --> ReadDB[(Read DB - Elasticsearch)]
        
        WriteDB --> CDC[CDC / Sync Worker]
        CDC --> ReadDB
    ```
*   **Performance Optimization**: Enable Read DB indexing on searchable attributes and sharding based on tenant ID to distribute search load.
