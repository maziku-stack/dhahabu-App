# System Architecture

## Overview
The Dhahabu platform is built on a decoupled client-server architecture:
- **Client Tier:** Cross-platform Flutter mobile application using Provider state management and Material 3 design system.
- **Backend Tier:** Django 5 REST Framework API server providing secure endpoints, business logic, tax calculation, and transaction processing.
- **Database Tier:** PostgreSQL database with relational modeling for users, dealer profiles, gold listings, transactions, and tax records.

## Security & Authentication
- **JWT Authentication:** Secure token-based authentication using SimpleJWT with access and refresh tokens stored securely on the device.
- **PIN Authorization:** Critical trade actions (such as signing and confirming sales) require secondary verification via a user account PIN hash.
- **Transport Security:** Cleartext HTTP permitted strictly for local development; production deployments enforce HTTPS / TLS.
