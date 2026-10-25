# Dhahabu Platform

A comprehensive gold trade and regulatory platform designed for **Miners**, **Licensed Dealers**, and **Government Authorities** (Mining Commission / TRA).

---

## Technical Stack

- **Backend:** Python, Django 5, Django REST Framework, SimpleJWT, PostgreSQL
- **Frontend:** Flutter 3, Provider State Management, Material 3
- **Design System:** Professional Clean White Theme (Navy `#0B1F3A`, Gold `#C9A227`)

---

## Project Structure

```text
backend/
  ├── accounts/        # User authentication, profiles, and roles
  ├── pricing/         # Gold reference price feed management
  ├── listings/        # Miner gold listings and marketplace
  ├── transactions/    # Sales ledger, confirmations, tax records
  ├── feedback/        # Support and grievance management
  └── config/          # Django project settings and URLs

mobile/
  └── lib/
      ├── core/        # Theme, network service, validation, and shared widgets
      └── features/    # Feature-based modular architecture
          ├── auth/        # Login, Register, Role Selection
          ├── market/      # Home dashboard & pricing feed
          ├── listings/    # Gold listings & marketplace
          ├── transactions/# Sales, confirmation, and receipts
          ├── tax/         # Tax summary and government charges
          ├── feedback/    # Feedback and support system
          ├── profile/     # User profile and settings
          ├── government/  # Compliance and audit logs
          └── shell/       # Role-based navigation and routing
```

---

## Backend Setup

1. Navigate to the backend directory:
   ```powershell
   cd backend
   ```

2. Create and activate a virtual environment:
   ```powershell
   python -m venv venv
   .\venv\Scripts\Activate.ps1
   ```

3. Install dependencies:
   ```powershell
   pip install -r requirements.txt
   ```

4. Configure environment variables in `.env`:
   ```env
   DEBUG=True
   SECRET_KEY=dev-secret
   ALLOWED_HOSTS=*
   USE_SQLITE=False
   POSTGRES_DB=dhahabu
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=your_postgres_password
   POSTGRES_HOST=localhost
   POSTGRES_PORT=5433
   MOCK_OTP=True
   ```

   In PowerShell, an already-set process variable overrides `.env`. If Django refuses to start with `Set explicit ALLOWED_HOSTS` (for example, because the shell has `DEBUG=release`), set the local development values in that terminal before running Django:
   ```powershell
   $env:DEBUG = "True"
   $env:ALLOWED_HOSTS = "*"
   ```
   Use `ALLOWED_HOSTS=*` only with local `DEBUG=True`; production must use explicit host names.

5. Run database migrations and create an admin user:
   ```powershell
   python manage.py makemigrations
   python manage.py migrate
   python manage.py create_admin --phone 0781143866 --name "Government Admin"
   ```

6. Start the Django development server:
   ```powershell
   .\run-dev.ps1
   ```

   For an Android phone on the same Wi-Fi, run `mobile\\run-on-device.ps1` in a second terminal. It selects this computer's current LAN IP for `API_BASE_URL`.

---

## Mobile App Setup

1. Navigate to the mobile directory:
   ```powershell
   cd mobile
   ```

2. Install dependencies:
   ```powershell
   flutter pub get
   ```

3. Run the app on a connected physical device using your local network IP (e.g., `192.168.1.182`):
   ```powershell
   flutter run --dart-define=API_BASE_URL=http://192.168.1.182:8000/api
   ```

   - **Android Emulator:** `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api`
   - **Chrome / Web:** `flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api`

---

## Testing & Verification Flow

1. **Admin / Government:** Sign in, manage dealer verification queue, review audit logs.
2. **Miner:** Register with miner role, create gold listings, and record sales.
3. **Dealer:** Register with dealer role (pending approval), browse open listings, and confirm sale agreements with PIN verification.
4. **Transactions:** Both parties sign sales with account PINs to generate official receipts and government tax records.
