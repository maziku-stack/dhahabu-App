# Technology Stack

This document outlines the core frameworks, libraries, and tools utilized in the Dhahabu platform across both backend and mobile frontend development.

## Backend Technologies

- **Python (Version 3.14+):** Core programming language powering all server-side business logic and APIs.
- **Django (Version 5.1.3):** High-level Python web framework encouraging rapid development and clean, pragmatic design.
- **Django REST Framework (DRF):** Powerful and flexible toolkit for building robust Web APIs.
- **SimpleJWT:** JSON Web Token authentication plugin for Django REST Framework providing secure token issuance, verification, and refresh flows.
- **PostgreSQL (Version 18):** Enterprise-grade relational database management system storing users, dealer profiles, gold listings, transactions, and tax records.
- **Psycopg2-Binary:** PostgreSQL adapter for Python.
- **Corsheaders:** Django middleware handling Cross-Origin Resource Sharing (CORS) for local development and client communication.

---

## Mobile Frontend Technologies

- **Flutter (Version 3+):** Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
- **Dart:** Strongly typed, object-oriented programming language optimized for client development.
- **Provider (Package):** Recommended dependency injection and state management library (`ChangeNotifier`) for reactive UI updates and session management.
- **HTTP Package:** Composable, multi-platform, Future-based API client for executing REST requests (`GET`, `POST`, `PATCH`).
- **Flutter Secure Storage:** Encrypted persistent storage utility for securely storing JWT access and refresh tokens on mobile devices.
- **Shared Preferences:** Lightweight key-value storage for non-sensitive local settings (such as app preferences).
- **Google Fonts (Urbanist, Public Sans):** Typography packages providing custom high-end font styling.
- **Intl:** Internationalization and localization utility used for currency and number formatting (`TSh #,##0.00`).

---

## Development & Infrastructure Tooling

- **Git & GitHub:** Version control system and remote repository hosting.
- **Android Studio / VS Code:** Primary integrated development environments for Flutter and Python development.
- **Gradle:** Build automation system for Android application compilation.
- **Windows PowerShell:** Shell environment for local script execution and server management.
