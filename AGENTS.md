# Jahitln (TailorLink) — Agent Guide

## Project structure

Single Flutter + Flask repo inside `tailor/`:
- **Flutter app** (`tailor/lib/`) — GetX, Material 3, Poppins font, navy-blue primary (`#1B2A6B`)
- **Flask backend** (`tailor/backend/`) — REST API (`/api/*`) + session-based web dashboard for admin/owner
- **Data analysis** (`data/`) — Jupyter notebook + CSVs for Shopee tailor analytics

## Dev setup & run order

```bash
# 1. Database — import the MySQL dump
mysql -u root -p tailorlink_db < tailor/database/jahit.sql

# 2. Run DB migrations (adds google_id, email_verified columns to existing tables)
cd tailor/backend
pip install -r requirements.txt
python migrate_google.py
python migrate_email_verification.py

# 3. Backend (port 5000)
flask run --debug              # or: python run.py

# 4. Expose backend publicly (app uses ngrok URL — install from https://ngrok.com/download)
ngrok config add-authtoken <token>
ngrok http 5000

# 5. Update ngrok URL in lib/app/data/providers/api_provider.dart (baseUrl)

# 6. Run Flutter app (from tailor/)
flutter pub get
flutter run
```

> **Python version quirk**: Dependencies are installed for Python 3.12. Use `py -3.12` to run scripts if the default `python` points to a different version.

> **Email verification**: SMTP config lives in `tailor/backend/.env` (SMTP_HOST/PORT/USER/PASS, FROM_EMAIL). Requires a Gmail App Password.

## Backend (Flask)

- Entry point: `backend/run.py` — loads `.env`, calls `create_app()`
- Blueprints registered in `backend/app/__init__.py:139-151`:
  `auth`, `customer`, `owner`, `admin`, `ai_analysis`, `informasi`
- Auth: JWT (mobile, 8h expiry) + Flask-Login sessions (web dashboard)
- Role guards: `@role_required('customer')` for JWT, `@web_login_required('admin','owner')` for sessions (`backend/app/middleware/jwt_guard.py`)
- DB: MySQL via PyMySQL, config in `.env` (`root@localhost/tailorlink_db`). Tables auto-created via `db.create_all()` on first run.
- Admin auto-seeded: username `admin`, password from `ADMIN_DEFAULT_PASSWORD` env or random printed to console
- File uploads: max 5MB, `png/jpg/jpeg/webp`, stored in `app/static/uploads/`
- Rate limiting: 200 req/hour, 50 req/min (in-memory)
- All API error messages in **Indonesian**
- Response body always includes `_statusCode` key (added by Flutter client)
- Order status flow: `pending → accepted → fitting → diproses → dijahit → selesai / siap_diambil` (or `rejected`)

### Additional scripts (in `tailor/backend/`)

| Script | Purpose |
|---|---|
| `migrate_google.py` | Add `google_id` column, make `password_hash`/`username` nullable |
| `migrate_email_verification.py` | Add `email_verified`, `verification_code`, `verification_code_expires` columns |
| `daily_update.py` | Scheduled task — executes Jupyter notebook, exports CSV |

## Flutter app

- Framework: **GetX** (`GetMaterialApp`, `GetPage`, bindings, controllers)
- Module pattern: `modules/<name>/{bindings,controllers,views}/`
- Route constants use SCREAMING_CASE (lint `constant_identifier_names: false` configured)
- Entry point: `lib/main.dart` — checks `AuthProvider.isLoggedIn()`, routes to `DASHBOARD` or `LOGIN`
- Auth: JWT in `flutter_secure_storage` (Android Keystore / iOS Keychain)
- API client: `lib/app/data/providers/api_provider.dart` — custom `HttpClient` bypasses SSL for ngrok, sends `ngrok-skip-browser-warning` header
- Multipart upload file field: `design_image` (default)

### Routes

| Route | Path |
|---|---|
| LOGIN | `/login` |
| REGISTER | `/register` |
| HOME | `/home` |
| TAILOR_DETAIL | `/tailor-detail` |
| ORDER_FORM | `/order-form` |
| CUSTOMIZE | `/customize` |
| ORDERS | `/orders` |
| TRACKING | `/tracking` |
| PROFILE | `/profile` |
| DASHBOARD | `/dashboard` |
| EXPLORE | `/explore` |
| FAVOURITE | `/favourite` |
| VERIFY_EMAIL | `/verify-email` |

## Testing

Only `flutter_test` configured. Placeholder at `test/widget_test.dart` (empty). No Python test framework.

## Commands

```bash
cd tailor

flutter pub get                # install deps
flutter run                    # run on device/emulator
dart analyze                   # static analysis (lints + type checks)
flutter test                   # run tests
dart run flutter_launcher_icons:generate   # generate launcher icons

cd tailor/backend
flask run --debug              # dev server
gunicorn run:app               # production
python migrate_google.py       # Google OAuth DB migration
python migrate_email_verification.py  # email verification columns
```

## Data analysis

- **Informasi endpoints** (`/api/informasi/populer`, `/tren`, `/rating`) query **MySQL langsung** — data real-time, tidak pakai CSV.
- **Notebook**: `data/analisis_penjahit_shopee.ipynb` — analisis histori Shopee (pandas, matplotlib, seaborn).
- **CSVs**: `data/*.csv` — data simulasi lama, sudah tidak dibaca backend.
- **Scheduled update**: `backend/daily_update.py` — menjalankan notebook via `nbconvert` (tidak perlu jika hanya pakai data real-time).

## Linting

Config: `tailor/analysis_options.yaml` (extends `package:flutter_lints/flutter.yaml`). Notable: `constant_identifier_names: false`, `unnecessary_underscores: false`. Run: `dart analyze`.

## Key conventions

- API errors in **Indonesian**
- JWT in `Authorization: Bearer <token>` header
- Multipart uploads: field name `design_image`
- Web dashboard at `/login` for admin/owner roles; customers use mobile app only
