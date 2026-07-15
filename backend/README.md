# kasirku_sembako backend

Go (Fiber) + PostgreSQL API for the Pro subscription (Google Play Billing) and cloud backup features. Clean architecture: `internal/domain` (entities + repository interfaces) → `internal/usecase` (business logic) → `internal/repository/postgres` (raw SQL via pgx, no ORM) → `internal/delivery/http` (Fiber handlers/middleware). `internal/platform` holds infra integrations (Google Play Developer API client).

Backups are JSON snapshots of the client's entire local database, stored verbatim in a `payload JSONB` column on the `backups` table — no on-disk file storage, no separate backup-of-backups concern (Postgres's own backup/replication strategy already covers this table like every other).

## Setup

1. `cp .env.example .env` and fill in real values (never commit `.env`).
2. Create the database and run migrations:
   ```
   migrate -database "$DATABASE_URL" -path migrations up
   ```
   (install golang-migrate's CLI: `go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest`)
3. `go run ./cmd/api`

## Google Play Developer API access

`GOOGLE_APPLICATION_CREDENTIALS` must point at a service account JSON key that has been granted access to this app's subscription/financial data in Play Console → Setup → API access. Without it, `/subscriptions/verify` and `/subscriptions/status` will fail — the server logs a warning on startup if this isn't configured.

## Deploying

`Dockerfile` builds a static binary in an alpine image. HTTPS termination (a domain + TLS cert) must sit in front of this — JWTs and passwords must never travel over plain HTTP. Any reverse proxy (Caddy, nginx, or your host's built-in TLS) works; not prescribed here.
