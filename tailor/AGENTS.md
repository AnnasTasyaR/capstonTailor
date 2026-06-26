# Jahitln (TailorLink) — Agent Guide

## Project structure

Monorepo with two apps:
- **Flutter mobile app** (`lib/`) — "Jahitln" sewing-service management, GetX framework
- **Flask backend** (`backend/`) — REST API (`/api/*`) + web dashboard (admin/owner)

## Dev setup & run order

```bash
# 1. Database — import the MySQL dump
mysql -u root -p tailorlink_db < database/jahit.sql

# 2. Backend (port 5000)
cd backend
pip install -r requirements.txt
flask run --debug              # or: python run.py

# 3. Expose backend publicly (app uses ngrok URL)
ngrok config add-authtoken <token>
ngrok http 5000

# 4. Update ngrok URL in lib/app/data/providers/api_provider.dart (baseUrl)
#    Default: https://obvious-twins-robust.ngrok-free.dev

# 5. Run Flutter app
flutter pub get
dart run flutter_launcher_icons:generate   # generate app icons (optional)
flutter run
```

## Backend (Flask)

- Entry point: `backend/run.py` — loads `.env`, calls `create_app()`
- Blueprints: `auth`, `customer`, `owner`, `admin`, `ai_analysis` — registered in `backend/app/__init__.py:138-149`
- Auth: JWT (mobile API, 8h expiry) + session-based (web dashboard, Flask-Login)
- Role guards: `backend/app/middleware/jwt_guard.py` — `@role_required('customer')` for JWT, `@web_login_required('admin','owner')` for sessions
- DB: MySQL via PyMySQL, config in `.env` (`root@localhost/tailorlink_db`). Tables auto-created via `db.create_all()` on first run.
- Admin auto-seeded on first run: username `admin`, password either `ADMIN_DEFAULT_PASSWORD` env var or random printed to console
- File uploads: max 5MB, types: `png/jpg/jpeg/webp`, stored in `app/static/uploads/`
- Rate limiting: 200 req/hour, 50 req/min (`flask-limiter`, in-memory)
- All API error messages in **Indonesian**, response body includes `_statusCode` key (added by Flutter client)
- Migration script: `backend/migrate_google.py` adds `google_id` column and makes `password_hash`/`username` nullable

### Commands

```bash
cd backend
flask run --debug              # dev server
gunicorn run:app               # production
python migrate_google.py       # Google OAuth DB migration
```

## Flutter app

- Framework: **GetX** (`GetMaterialApp`, `GetPage`, bindings, controllers)
- Module pattern: `modules/<name>/{bindings,controllers,views}/`
- Route constants use SCREAMING_CASE (lint `constant_identifier_names: false` configured)
- Entry point: `lib/main.dart` — checks `AuthProvider.isLoggedIn()`, routes to LOGIN or DASHBOARD
- Theme: Material 3, Poppins font (Google Fonts), navy blue primary (`#1B2A6B`)
- Auth: JWT stored in `flutter_secure_storage` (Android Keystore / iOS Keychain)
- API client: `lib/app/data/providers/api_provider.dart` — custom `HttpClient` bypasses SSL for ngrok, sends `ngrok-skip-browser-warning` header
- Multipart upload file field name: `design_image` (default)

### Commands

```bash
flutter pub get
flutter run                    # run on connected device/emulator
dart analyze                   # static analysis (lints + type checks)
flutter test                   # run tests
dart run flutter_launcher_icons:generate   # generate launcher icons
```

## Testing

- `flutter_test` is the only test framework configured
- Placeholder at `test/widget_test.dart`; add tests there or in new files

## Linting

- Config: `analysis_options.yaml` (extends `package:flutter_lints/flutter.yaml`)
- Notable overrides: `constant_identifier_names: false`, `unnecessary_underscores: false`
- Run: `dart analyze`

## Flutter routes

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

## Data analysis & dashboard

- **Big data analysis**: `C:\tailor\data\analisis_penjahit_shopee.ipynb` — Jupyter notebook analyzing Shopee tailor store data (popular products, rating trends, daily/weekly/monthly sales). Uses `pandas`, `matplotlib`, `seaborn`. Supports CSV export from Shopee Seller Center or built-in demo data.
- **Dashboard integration**: Analytics from the notebook can feed into:
  - Flutter mobile dashboard (`lib/app/modules/dashboard/`) — bottom nav with Home/Orders/Informasi/Profile tabs
  - Web admin dashboard (`/admin/dashboard`) — platform-wide stats (users, tailors, orders)
  - Web owner dashboard (`/owner/dashboard`) — tailor-specific stats (active/pending/completed orders)
- Data collection flows: Shopee Seller Center CSV export → notebook analysis → visualization → dashboard display

## API endpoints (backend)

All under `/api/`:
- `auth` — login, register, Google OAuth, logout, web login
- `customer` — list tailors, create orders, favourites, rating, profile, notifications
- `owner` — web dashboard, manage orders, profile, shop availability (session-based)
- `admin` — web dashboard, manage users/tailors/orders (session-based)
- `ai_analysis` — Gemini-powered image analysis with fallback heuristic

## Key conventions

- All API error messages are in **Indonesian**
- JWT token in `Authorization: Bearer <token>` header
- Multipart uploads: field name `design_image` by default
- Response body always includes `_statusCode` key (Flutter client adds this)
- Admin seeded on first run: username `admin`, password from `ADMIN_DEFAULT_PASSWORD` env or random print
- Web dashboard accessible at `/login` for admin/owner roles; customers use mobile app only
- Order status flow: `pending → accepted → fitting → diproses → dijahit → selesai / siap_diambil` (or `rejected`)
