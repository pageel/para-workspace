# Reference Architecture: Event-Driven Microservices (Pub-Sub / Saga)

## 1. Topology
*   **Message Broker**: Apache Kafka or RabbitMQ for asynchronous event ingestion.
*   **Coordination Strategy**: Choreography (decentralized, service-to-service events) or Orchestration (centralized orchestrator managing saga steps).
*   **Infrastructure Layout**: Microservices running inside containerized clusters (Kubernetes/Docker) behind an API Gateway.

## 2. API & Event Communication Spec
*   **Protocols**: Async Event Streaming (AMQP / Kafka Protocol).
*   **Event Envelope Pattern**:
    ```json
    {
      "eventId": "uuid-v4",
      "eventType": "ORDER_CREATED",
      "timestamp": 1718928000,
      "version": "1.0.0",
      "payload": {
        "orderId": "12345",
        "userId": "999"
      }
    }
    ```
*   **Dead-Letter Queue (DLQ)**: Failed events must be retried up to 3 times with exponential backoff before routing to a DLQ for manual reconciliation.
*   **Idempotent Consumers**: Every consumer must implement deduplication logic using the `eventId` in a Redis cache (TTL: 86400s) to prevent double-processing.

## 3. Database & Storage Architecture
*   **Consistency Model**: Eventual Consistency (CAP Theorem trade-off: AP model over CP).
*   **Transactional Outbox Pattern**: To guarantee atomic database writes and message publishing:
    1. Write business state and insert event record into an `outbox` table in the same transaction.
    2. A Change Data Capture (CDC) engine (e.g., Debezium) reads the outbox table and streams events to the message broker.
    ```sql
    CREATE TABLE outbox (
      id TEXT PRIMARY KEY,
      aggregate_type TEXT NOT NULL,
      aggregate_id TEXT NOT NULL,
      event_type TEXT NOT NULL,
      payload TEXT NOT NULL,
      created_at INTEGER DEFAULT (strftime('%s', 'now'))
    );
    ```

## 4. Software Topology
*   **Folder Structure Layout**: Domain-Driven Design (DDD) layout:
    ```
    src/
    ├── domain/       # Core business logic (Entities, Value Objects)
    ├── application/  # Command/Event handlers
    └── infrastructure/ # DB repositories, Event consumers/producers
    ```
*   **Resiliency Patterns**: Enforce Circuit Breaker and Rate Limiting on external HTTP communication.
*   **Component Flow Diagram**:
    ```mermaid
    graph LR
        Client[Client] --> Gateway[API Gateway]
        Gateway --> ServiceA[Order Service]
        ServiceA --> DB_A[(Order DB + Outbox)]
        DB_A --> CDC[CDC Worker]
        CDC --> Broker[Message Broker - Kafka]
        Broker --> ServiceB[Inventory Service]
        ServiceB --> DB_B[(Inventory DB)]
    ```
