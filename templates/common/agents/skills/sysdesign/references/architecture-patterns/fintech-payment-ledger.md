---
tags: [fintech, payment, ledger, idempotency, reconciliation]
stack: [postgres, redis, stripe]
scale: [medium, large, enterprise]
complexity: advanced
---

# Reference Architecture: Fintech Payment & Transactional Ledger

## 1. Topology
*   **API Gateway**: Acts as the initial gatekeeper, validating signatures and enforcing rate-limiting (Token Bucket).
*   **Idempotency Store**: Fast Redis cache (TTL: 86400s) to store idempotency key results.
*   **E-commerce/Payment Service**: Business logic coordinator.
*   **Double-Entry Ledger Database**: Highly consistent relational database (PostgreSQL with strong ACID compliance).
*   **Reconciliation Background Worker**: Scheduled serverless workers (cron jobs) validating payment gateway status vs. local ledger entries.

## 2. API & Communication Spec (Deduplication Gate)
*   **Idempotency Header Requirement**:
    *   Mutative endpoints (e.g., `POST /api/v1/payments`) MUST require a unique `Idempotency-Key` (UUIDv4) header.
    *   **Deduplication Protocol Flow**:
        1. Check Redis for `idempotency_key` -> if found, return cached response immediately.
        2. If not found, acquire a distributed lock on the key.
        3. Execute business logic & write to database.
        4. Save response in Redis and release the lock.
*   **Retry with Jitter**: Client retries for failed requests MUST use Exponential Backoff with Jitter to prevent the thundering herd problem on payment gateways.

## 3. Database & Storage Architecture (Double-Entry Ledger)
*   **No Mutative Updates**: Ledger balances MUST NOT be updated using `UPDATE accounts SET balance = balance + 10`. Balances must be calculated dynamically by summing immutable transaction logs (debit/credit entries).
*   **ACID Compliance**: All transaction postings must run in isolated `SERIALIZABLE` database transactions.
*   **Ledger DDL**:
    ```sql
    CREATE TABLE accounts (
      id TEXT PRIMARY KEY,
      owner_id TEXT NOT NULL,
      currency TEXT NOT NULL,
      created_at INTEGER DEFAULT (strftime('%s', 'now'))
    );

    CREATE TABLE ledger_entries (
      id TEXT PRIMARY KEY,
      transaction_id TEXT NOT NULL,
      account_id TEXT NOT NULL,
      type TEXT CHECK(type IN ('DEBIT', 'CREDIT')) NOT NULL,
      amount INTEGER NOT NULL, -- Stored in cents (e.g. $10.00 = 1000) to avoid floating point issues
      created_at INTEGER DEFAULT (strftime('%s', 'now'))
    );
    ```

## 4. Software Topology (Reconciliation Flow)
*   **Data Flow Diagram**:
    ```mermaid
    sequenceDiagram
        Client->>API Gateway: POST /payments (Idempotency-Key)
        API Gateway->>Redis: Acquire lock & check key
        Redis-->>API Gateway: Key not exists (proceed)
        API Gateway->>Ledger DB: Insert DEBIT and CREDIT logs (Serializable txn)
        Ledger DB-->>API Gateway: Transaction recorded
        API Gateway->>Payment Provider: Execute card charge (Stripe/Visa)
        Payment Provider-->>API Gateway: Charge successful
        API Gateway->>Redis: Save success response & release lock
        API Gateway-->>Client: 201 Created (Payment Complete)
    ```
*   **Financial Reconciliation Background Task**:
    *   Runs every 10 minutes to cross-check local `ledger_entries` against the Payment Provider API.
    *   Automated alerting for mismatches (e.g., card charged but ledger write failed) to handle edge-case failures.
