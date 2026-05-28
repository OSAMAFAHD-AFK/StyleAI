# StyleAI Backend

ASP.NET Core 9 Web API with Clean Architecture, PostgreSQL, and EF Core.

## Structure

```
src/
  StyleAI.Api/              # HTTP API, health endpoints
  StyleAI.Application/      # Use cases & interfaces
  StyleAI.Domain/           # Entities & enums
  StyleAI.Infrastructure/   # EF Core, persistence, external adapters
```

## Prerequisites

- [.NET 9 SDK](https://dotnet.microsoft.com/download)
- PostgreSQL 16+ (local install or Docker)
- EF Core CLI: `dotnet tool install --global dotnet-ef --version 9.0.4`

## Database setup

### Option A — Docker

```bash
cd BackEnd
docker compose up -d
```

### Option B — Local PostgreSQL

Create database `styleai_dev` and update connection string in `src/StyleAI.Api/appsettings.Development.json`.

## Apply migrations

```bash
cd BackEnd
dotnet ef database update --project src/StyleAI.Infrastructure --startup-project src/StyleAI.Api
```

## Run API

```bash
cd BackEnd
dotnet run --project src/StyleAI.Api
```

Endpoints:

- `GET /health` — health checks (includes DB when PostgreSQL is up)
- `GET /api/health` — API liveness
- `GET /api/db/ping` — database connectivity

## Tables (Task 1)

- **Users** — device identity, savings counter, preferred country/currency
- **SearchLogs** — AI tags + cropped image URL (B2B data mine)
- **ClickTrackings** — affiliate clicks, savings, conversion tracking via `AffiliateTrackingId`
