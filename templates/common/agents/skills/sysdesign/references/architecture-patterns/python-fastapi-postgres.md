---
tags: [rest-api, python, async, sql, containerized]
stack: [fastapi, postgres, sqlalchemy, alembic, docker, uvicorn]
scale: [medium, large, enterprise]
complexity: intermediate
---

# Reference Architecture: Async Python API (FastAPI + PostgreSQL)

## 1. Topology
*   **Infra**: FastAPI application served by `uvicorn` behind Nginx/Traefik reverse proxy. Deployed via Docker on VPS or Kubernetes.
*   **Database**: PostgreSQL with async driver (`asyncpg`) for non-blocking I/O.
*   **Task Queue**: Celery + Redis for background jobs (email, reports, heavy processing).

## 2. API Contract
*   **Router Separation**: `app/api/v1/endpoints/` — one module per domain entity.
*   **Pydantic Models**: Request/Response schemas with automatic validation and OpenAPI docs.
    ```python
    from pydantic import BaseModel, EmailStr
    from datetime import datetime
    from uuid import UUID

    class UserCreate(BaseModel):
        email: EmailStr
        password: str

    class UserResponse(BaseModel):
        id: UUID
        email: str
        created_at: datetime

        model_config = {"from_attributes": True}
    ```
*   **Dependency Injection**: FastAPI `Depends()` for DB sessions, auth, and rate limiting.
*   **Error Format**:
    ```json
    { "detail": { "code": "VALIDATION_ERROR", "message": "Email is required", "errors": [] } }
    ```

## 3. Database Schema (SQLAlchemy ORM)
```python
from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime, timezone

class User(Base):
    __tablename__ = "users"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    posts = relationship("Post", back_populates="author")

class Post(Base):
    __tablename__ = "posts"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    author_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    title = Column(String, nullable=False)
    content = Column(String)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    author = relationship("User", back_populates="posts")
```

*   **Migrations**: Alembic for schema version control (`alembic revision --autogenerate -m "add posts table"`).

## 4. Software Topology
```
app/
├── api/
│   └── v1/
│       ├── endpoints/    # Route handlers
│       └── dependencies/ # Auth, DB session injectors
├── core/
│   ├── config.py         # Settings via pydantic-settings
│   └── security.py       # JWT, password hashing
├── models/               # SQLAlchemy ORM models
├── schemas/              # Pydantic request/response models
├── services/             # Business logic layer
├── db/
│   ├── session.py        # Async session factory
│   └── migrations/       # Alembic migrations
└── main.py               # FastAPI app factory
```

## 5. Security
*   **Auth**: JWT Bearer tokens (`python-jose`) with refresh token rotation.
*   **Password Hashing**: `passlib` with bcrypt or Argon2.
*   **CORS**: `CORSMiddleware` with strict origins list.
*   **Rate Limiting**: `slowapi` middleware (token bucket per IP/user).
*   **SQL Injection**: Fully prevented by SQLAlchemy ORM parameterized queries.

## 6. Observability
*   **Logging**: `structlog` with JSON output → stdout → log aggregator (ELK/Loki).
*   **Health Check**: `GET /healthz` pings DB connection pool + Redis.
*   **Metrics**: `prometheus-fastapi-instrumentator` for auto-instrumented request metrics.
*   **OpenAPI**: Auto-generated at `/docs` (Swagger UI) and `/redoc`.
