# Authority integration slots (Dhahabu)

No authority or assay API is active yet. Blank settings are intentional. Do not put production secrets in source control.

## Indicative market reference (non-authoritative)

Dhahabu includes an optional third-party reference feed for development and display only. It combines XAU/USD spot from Gold-API.com with USD/TZS daily FX from Frankfurter, converts USD per troy ounce to an estimated TZS per gram, and stores each refresh in `ReferencePriceSnapshot` with both source timestamps. It does not feed sale agreement, assay, tax, royalty, or payment calculations. It is never returned as an official Commission price.

Run `python manage.py refresh_reference_prices` on a scheduled job (for example, every 5 minutes). The command writes a new snapshot; the authenticated `GET /api/pricing/reference/` endpoint serves the latest stored snapshot without calling external services during an app request. It returns `official: false` and marks gold quotes older than 30 minutes or FX dates older than two days as stale. Before public display, review the providers' current terms and attribution requirements. Provider outages or malformed responses fail the refresh and leave the last snapshot intact.

This feed does not change `DH_COMMISSION_PRICE_PROVIDER` or the official `GET /api/pricing/current/` contract. The authority adapters below remain disabled until the Commission provides an approved API and signature-validation scheme.

**Integration boundary:** the Commission provider setting is currently consumed by the official-price endpoint. The assay, charge-assessment and government-payment settings and null adapters reserve their interfaces, but their execution pipeline and payment callback are not implemented yet. Do not configure those three settings expecting them to execute until the authority specifications arrive and the adapters plus workflow/callback code are completed and tested.

## Current behavior with empty settings

- Miner and dealer each approve a sale with their own account PIN. Both approvals are required; admin accounts cannot approve on behalf of either party.
- Completed sales are recorded while authority assessment is unavailable. A charge record has `assessment_status=unavailable`, `payment_status=not_started`, and no invented rate or amount. Dhahabu does not collect or hold tax money.
- Official market prices stay unavailable until a Commission feed is connected. Legacy/manual price rows are not served by current-price/history APIs; manual publishing is disabled.
- Transaction weight/karat are marked unverified and the price is party-agreed until approved assay and official-price integrations are connected.

## Exact provider locations and settings

Implement adapters in `backend/integrations/` and set their Python class import paths in backend environment variables (or `backend/.env` for local development):

| Purpose | Setting | Required class method | Data returned/stored |
| --- | --- | --- | --- |
| Mining Commission prices | `DH_COMMISSION_PRICE_PROVIDER` | `get_prices()` | Commission price type, value, currency/unit, effective time, publication/source and official reference. Exposed by `GET /api/pricing/current/`. |
| Assay scale/device (reserved) | `DH_ASSAY_PROVIDER` | planned `measure(*, transaction)` | Intended fields: verified net weight, purity/karat, device ID, timestamp and signed assay reference. No live invocation yet. |
| Statutory charge assessment (reserved) | `DH_CHARGE_ASSESSMENT_PROVIDER` | planned `assess(*, transaction, assay)` | Intended fields: separate charge components, legal basis, recipient (TRA vs Commission), payer, rate/basis, amount/currency and authority reference. No live invocation yet. |
| Government payment (reserved) | `DH_GOVERNMENT_PAYMENT_PROVIDER` | planned `initiate(*, assessment, idempotency_key)` | Intended authority payment reference and initiation state. No live invocation or verified callback endpoint yet. |

Each setting takes an import path to a class, e.g. `integrations.authorities.commission.CommissionPriceProvider`. That example provider module does not exist yet. Add the real adapters only after authorities provide the approved interface. Leave settings blank until then. Null adapters and the Commission record verifier are in `backend/integrations/providers.py`. A Commission record must include `price_type`, positive `value`, `currency`, `unit`, ISO `effective_at`, `source`, `reference`, `verified: true` after validating the authority signature, and boolean `is_stale` computed from the official publication cadence.

## Obtain from authorities before implementing adapters

Request API base URL/version, sandbox access, authentication/signature rules, price response examples and update cadence, charge components/effective dates, assay device format and trust method, payment recipient/channel, idempotency rules, webhook signature and status definitions, retry/rate limits, and sandbox test cases. Confirm in writing which amounts go to TRA and which go to the Mining Commission or another recipient. Do not assume one recipient or hardcode a universal royalty rate.

## Adapter safety rules

- On timeout, bad signature, stale feed or malformed response, report unavailable/failed; never substitute a guessed official value.
- Persist authority references and timestamps; make retries idempotent.
- Only a verified authority callback can mark payment `paid`. A client request or screenshot is not payment proof.
- Keep secrets in deployment environment/secret manager, never Flutter or committed files.
- Use an approved background job/outbox for calls and retries so authority downtime cannot erase or block an agreed sale.

No live authority, device or payment integration can be claimed until approved sandbox details are supplied and exercised.
