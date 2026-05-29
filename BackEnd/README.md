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

## Gemini API key (Task 3)

Never commit API keys. Store locally with user secrets:

```bash
cd BackEnd/src/StyleAI.Api
dotnet user-secrets set "Gemini:ApiKey" "YOUR_GEMINI_API_KEY"
```

Optional request headers for B2B logging:

- `X-Device-Token` — stable anonymous device identity
- `X-Country-Code` — ISO-2 country code (example: `SA`)

## Skimlinks Product API (Task 4)

### 1) Create publisher account

1. Register at [skimlinks.com](https://www.skimlinks.com) as a publisher.
2. Complete site/app details (use your StyleAI domain or staging URL).
3. Wait for account approval.

### 2) Get Product Key (required for live API)

The Product API key is available for **Managed** accounts:

1. Open [Publisher Hub](https://hub.skimlinks.com).
2. Go to **Settings → Account**.
3. Copy **Product Key** (long technical key).
4. Copy **Publisher ID** (numeric) for future link wrapping.

If Product Key is empty, your account is likely **Growth tier**. Contact Skimlinks support and request:

- Upgrade to Managed, or
- Product API access for your shopping app use case.

Docs:

- [Product Key guide](https://www.skimlinks.com/resources/product-guide/product-key/)
- [Product API docs](http://api-products.skimlinks.com/doc/)

### 3) Store secrets locally (never commit)

```bash
cd BackEnd/src/StyleAI.Api
dotnet user-secrets set "Skimlinks:ProductKey" "YOUR_SKIMLINKS_PRODUCT_KEY"
dotnet user-secrets set "Skimlinks:PublisherId" "YOUR_PUBLISHER_ID"
```

### 4) Development without Product Key

If `Skimlinks:ProductKey` is missing, API uses **Skimlinks mock** automatically (`AffiliateSearch:UseMockWhenProductKeyMissing=true`).  
Only **one affiliate network** is wired: **Skimlinks** (no ShopStyle/Amazon direct clients in Task 4).

## Task 4 endpoints

- `POST /api/search/upload` — image + Gemini tags
- `POST /api/search/{requestId}/offers/start` — starts Skimlinks fan-out search
- `GET /api/search/{requestId}/offers` — ranked results (benchmark, originals, dupes, summary)
- SignalR hub: see **Task 5** below

## Task 5 — SignalR live offer streaming

Hub path (configurable): `/hubs/search-offers`

### Flutter / client flow

1. Connect to SignalR hub (WebSockets).
2. Call `JoinSearchGroup(requestId)` **before or right after** `POST .../offers/start`.
3. Listen for events (in typical order):

| Event | When |
|-------|------|
| `SearchStarted` | Search pipeline began |
| `OfferReceived` | One normalized offer (drip) |
| `ProviderSearchCompleted` | One affiliate provider finished (e.g. skimlinks) |
| `OffersCatchUp` | On join/reconnect — replays offers already collected |
| `SearchCompleted` | Done — includes `summary` |

4. Optional: `LeaveSearchGroup(requestId)` when leaving the screen.

### CORS (development)

Set `SignalR:CorsOrigins` in `appsettings.Development.json` for your Flutter web origin. Mobile apps usually do not need CORS.

### Architecture

- **Contracts:** `ISearchOffersHubClient` + notification records in `StyleAI.Application`

## Task 6 — Affiliate redirect, thrift counter, webhooks

### Purchase flow (Flutter)

1. User taps **Buy** on an offer.
2. `POST /api/redirect/prepare` with `{ requestId, offerId }` and header `X-Device-Token`.
3. Open `redirectUrl` from the response (in-app browser / external).
4. API records `ClickTrackings`, updates `Users.TotalSavings`, returns savings for UI.
5. `GET /api/redirect/{affiliateTrackingId}` returns **HTTP 302** to the monetized merchant URL (idempotent).

### Thrift counter

- `GET /api/thrift/summary` + `X-Device-Token` → `totalSavings`, `currency`, click stats.

### Webhooks (conversion confirmation)

- `POST /api/webhooks/affiliate/skimlinks` — Skimlinks postback (body or query `xcust` / `affiliateTrackingId`).
- `POST /api/webhooks/affiliate/conversion` — generic provider payload.
- Secure with header `X-Webhook-Secret` (set `Monetization:WebhookSecret`).

```bash
dotnet user-secrets set "Monetization:WebhookSecret" "YOUR_WEBHOOK_SECRET"
```

### Architecture (Task 6)

- `AffiliatePurchaseRedirectService` — click logging + Skimlinks URL wrapping + thrift update
- `ThriftCounterService` — reads `Users.TotalSavings`
- `AffiliateConversionWebhookService` — marks `ClickTrackings.IsConverted` and commission

### Architecture (Task 5)

- **Publisher:** `SearchOffersSignalRPublisher` (typed hub client)
- **Catch-up:** `SearchOffersCatchUpService` replays state when client joins late
- **Pipeline:** `AffiliateOfferSearchOrchestrator` publishes per-offer as they are normalized (no wait for full search)

### Ranked offers response (`GET .../offers` after completion)

```json
{
  "requestId": "...",
  "status": "completed",
  "benchmark": { "offerKind": "benchmark", "localizedPrice": 450.0, "..." },
  "originals": [ { "offerKind": "original", "merchantSlug": "asos", "..." } ],
  "dupes": [ { "offerKind": "dupe", "savedAmount": 120.0, "savingsPercent": 80.0, "..." } ],
  "priceMatches": [],
  "summary": {
    "benchmarkLocalizedPrice": 450.0,
    "cheapestDupeLocalizedPrice": 89.0,
    "maxSavings": 361.0,
    "maxSavingsPercent": 80.2,
    "currency": "SAR",
    "totalOffers": 12,
    "originalCount": 3,
    "dupeCount": 9
  },
  "offers": []
}
```

While search is running, `GET .../offers` returns a flat `offers` list; after completion it returns the ranked shape above.

### Quick test flow

```bash
# 1) upload image
curl -X POST "http://localhost:5045/api/search/upload" ^
  -H "X-Country-Code: SA" ^
  -F "image=@your-image.jpg"

# 2) start offers (use requestId from step 1)
curl -X POST "http://localhost:5045/api/search/{requestId}/offers/start" ^
  -H "X-Country-Code: SA"

# 3) poll offers
curl "http://localhost:5045/api/search/{requestId}/offers"
```
