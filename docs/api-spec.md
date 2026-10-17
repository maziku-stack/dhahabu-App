# API Specification

## Authentication Endpoints
- `POST /api/auth/register/` — Register a new miner or dealer account with email/password and privacy acknowledgment.
- `POST /api/auth/login/` — Authenticate user and return JWT access/refresh tokens.
- `GET /api/auth/me/` — Retrieve authenticated user profile.
- `PATCH /api/auth/me/` — Update user profile details.
- `POST /api/auth/pin/` — Set or update account transaction PIN.

## Pricing & Market Endpoints
- `GET /api/pricing/current/` — Retrieve live gold reference prices across purities (24K, 22K, 18K).
- `POST /api/pricing/set/` — Admin endpoint to update official gold reference rates.

## Listings Endpoints
- `GET /api/listings/` — Browse open gold listings.
- `POST /api/listings/create/` — Publish a new miner gold listing.
- `POST /api/listings/{id}/share-phone/` — Toggle phone number sharing on a listing.

## Transactions Endpoints
- `GET /api/transactions/` — Retrieve user transaction ledger and sales history.
- `POST /api/transactions/create/` — Initiate a new trade record between counter-parties.
- `POST /api/transactions/{id}/confirm/` — Confirm and sign a transaction using account PIN.
- `GET /api/transactions/tax-summary/` — Retrieve tax and government charge assessments.
