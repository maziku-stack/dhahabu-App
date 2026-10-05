# Dhahabu — Full MVP

Gold trade platform for **Miners**, **Licensed Dealers**, and **Government** (Mining Commission / TRA).

**Stack:** Django 5 + DRF + SimpleJWT | Flutter 3  
**Design:** Navy `#0B1F3A` · Gold `#C9A227` · dark-first mobile (UI/UX Spec)

---

## Features included

| Area | Status |
|------|--------|
| Landing (Sign in top right, CTAs) | ✅ |
| Register Miner \| Dealer only | ✅ |
| Login (OTP, mock 123456) | ✅ |
| Set PIN after auth | ✅ |
| Role shells (Miner / Dealer / Gov) | ✅ |
| Market prices 24K/22K/18K + stale label | ✅ |
| Listings (create / browse) | ✅ |
| Confirm sale + tax estimate | ✅ |
| Miner confirm → TaxRecord 7% | ✅ |
| Receipt screen | ✅ |
| Dealer tax summary | ✅ |
| Feedback | ✅ |
| Gov compliance overview | ✅ |
| Dealer verification queue | ✅ |
| Audit log | ✅ |
| PostgreSQL optional | ✅ |
| create_admin command | ✅ |

---

## Backend setup

```powershell
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt

$env:USE_SQLITE="True"
$env:DEBUG="True"
$env:SECRET_KEY="dev-secret"
$env:MOCK_OTP="True"

python manage.py makemigrations
python manage.py migrate
python manage.py create_admin --phone 0700000001 --name "TRA Admin"
python manage.py runserver 0.0.0.0:8000
```

API docs: http://127.0.0.1:8000/api/docs/

**PostgreSQL:** set `USE_SQLITE=False` and `POSTGRES_*` env vars.

---

## Flutter setup

```powershell
cd mobile
flutter create .
flutter pub get
```

1. Edit `lib/utils/constants.dart` → your PC IP for real device  
2. AndroidManifest: `android:usesCleartextTraffic="true"`  
3. `flutter run` / `flutter run -d chrome`

---

## Test flow

1. Admin: Sign in `0700000001` → OTP `123456` → set PIN → set gold prices  
2. Register Miner → OTP → PIN → New Listing  
3. Register Dealer → OTP → PIN → pending until Admin approves  
4. Admin → Dealers tab → Approve  
5. Dealer → browse listing → Confirm Sale  
6. Miner → Sales → Confirm & Sign → TaxRecord + receipt  
7. Dealer → Tax summary; Admin → Overview shows royalty  

---

## Project layout

```
backend/
  accounts/ pricing/ listings/ transactions/ feedback/
mobile/lib/
  theme/ widgets/ models/ services/ providers/
  screens/auth|shells|market|listings|transactions|tax|feedback|government|profile
```
