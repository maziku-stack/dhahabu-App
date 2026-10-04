# Dhahabu App — MVP

Secure digital platform connecting **Small-scale Miners**, **Licensed Gold Dealers**, and **Government** (Mining Commission / TRA) for auditable gold sales, market pricing, and automated royalty/tax.

**Stack:** Django 5 + DRF + SimpleJWT | Flutter 3

---

## Features (MVP)

| Epic | Status |
|------|--------|
| Phone OTP auth (mock OTP `123456` in dev) | ✅ |
| Roles: Miner / Dealer / **Admin** | ✅ |
| Admin dashboard (volume, royalty) | ✅ |
| Dealer verification workflow | ✅ |
| Daily gold prices by karat (24K / 22K / 18K) | ✅ |
| Record sale → Miner confirm → TaxRecord (7%) | ✅ |
| Feedback / grievance channel | ✅ |
| Audit log on confirm | ✅ |

---

## 1. Backend setup

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

# Create Government Admin account
python manage.py create_admin --phone 0700000001 --name "TRA Admin"

python manage.py runserver 0.0.0.0:8000
```

API docs: http://127.0.0.1:8000/api/docs/

---

## 2. Flutter — deploy / run

```powershell
cd mobile
flutter create .          # once — creates android/ios/web/windows
flutter pub get
```

### Set API URL

Edit `lib/utils/constants.dart`:

```dart
// Real phone (same Wi‑Fi) — use your PC IP from ipconfig
static const String baseUrl = 'http://192.168.x.x:8000/api';

// Android emulator
// static const String baseUrl = 'http://10.0.2.2:8000/api';

// Chrome / Edge / Windows desktop
// static const String baseUrl = 'http://127.0.0.1:8000/api';
```

### Allow HTTP on Android

After `flutter create .`, open  
`android/app/src/main/AndroidManifest.xml`  
and inside `<application ...>` add:

```xml
android:usesCleartextTraffic="true"
```

### Run on device / web / desktop

```powershell
flutter devices
flutter run                 # connected phone
flutter run -d chrome       # web
flutter run -d windows      # Windows app
flutter run -d <device_id>  # specific device
```

---

## 3. Admin login (in the app)

1. Open app → tap **Admin** role card  
2. Optional: tap **Use demo admin (0700000001)**  
3. **Send OTP** → enter **123456**  
4. You open the **Government Dashboard** (transactions volume, royalty, prices, feedback)

Admin can also:
- Publish gold prices (Prices tab → edit / publish)
- View all transactions
- Read miner feedback / grievances

---

## 4. Full test flow

| Step | Action |
|------|--------|
| 1 | `create_admin` then login as Admin → set 24K price |
| 2 | Register Miner (role Miner, OTP 123456) |
| 3 | Register Dealer (role Dealer, OTP 123456) |
| 4 | Dealer or Miner → New Sale → other party’s phone, weight, karat, price |
| 5 | Miner → My Sales → **Confirm Sale** → royalty calculated |
| 6 | Admin → Dashboard shows volume + royalty |

---

## Project structure

```
dhahabu/
├── backend/
│   ├── accounts/          # OTP, User roles, create_admin command
│   ├── pricing/
│   ├── transactions/      # Sale + TaxRecord + AuditLog
│   ├── feedback/
│   └── config/
└── mobile/
    └── lib/
        ├── models/
        ├── services/
        ├── providers/
        └── screens/       # Login (with Admin), Dashboard, Prices, Sales, Feedback
```

---

## Production notes

- Set `MOCK_OTP=False` and integrate SMS (e.g. Africa’s Talking)
- Use PostgreSQL (`USE_SQLITE=False` + env vars)
- Tax rate: `DEFAULT_ROYALTY_RATE=0.07` in settings / env
- Build release APK: `flutter build apk --release`
