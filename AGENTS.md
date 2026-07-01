# Jahitln (TailorLink) — Agent Guide

Single Flutter + Flask repo. All code under `tailor/`:
- **Flutter app** (`tailor/lib/`) — GetX, Material 3, Poppins, navy-blue primary `#1B2A6B`
- **Flask backend** (`tailor/backend/`) — REST API (`/api/*`) + session-based web dashboard for admin/owner
- **Data analysis** (`data/`) — Jupyter notebook + CSVs (**not read by backend**)

## Dev server setup

```bash
# Terminal 1: Backend (port 5000, 0.0.0.0)
cd tailor/backend
pip install -r requirements.txt
mysql -u root -p tailorlink_db < tailor/database/jahit.sql
python migrate_google.py && python migrate_email_verification.py && python migrate_item_type.py
flask run --debug

# Terminal 2: ngrok
ngrok http 5000

# Terminal 3: Flutter
cd tailor
flutter pub get
# Update baseUrl in lib/app/data/providers/api_provider.dart:8 with new ngrok URL
flutter run
```

> **Python**: deps target 3.12. Use `py -3.12` if default is different.  
> **SMTP**: `.env` needs Gmail App Password (SMTP_HOST/PORT/USER/PASS, FROM_EMAIL).

## Startup behavior (important)

On `flask run --debug`, `create_app()` (backend/app/__init__.py) does in order:
1. Init SQLAlchemy + `db.create_all()` (auto-creates tables)
2. Seed default `admin` user if missing (password from `ADMIN_DEFAULT_PASSWORD` env, or random printed to console)
3. Connect to MongoDB + run `scraper.seed_data()` — scrapes Carousell fashion products, seeds `populer`/`tren`/`rating` collections, falls back to hardcoded data
4. Root `/` redirects to web login

**APScheduler** (`backend/app/scheduler.py`) defines daily ETL from MySQL → MongoDB but is **not wired into `create_app()`**. The `/api/informasi/*` reads from whatever MongoDB has (initially scraped/hardcoded data, stale unless scheduler started manually).

## Architecture

| Layer | Entry point | Auth |
|---|---|---|
| Flutter | `lib/main.dart` — checks `AuthProvider.isLoggedIn()`, routes to `DASHBOARD` or `LOGIN`. Default transition: `Transition.cupertino` | JWT in `flutter_secure_storage`, `Authorization: Bearer <token>` header |
| Flask | `backend/run.py` — loads `.env`, calls `create_app()` | JWT (mobile, HS256, 8h) + Flask-Login sessions (web dashboard) |

### Blueprints (`backend/app/__init__.py:140-152`)
`auth`, `customer`, `owner`, `admin`, `ai_analysis`, `informasi`

### Role guards (`backend/app/middleware/jwt_guard.py`)
- `@role_required('customer')` — JWT guard for mobile API
- `@web_login_required('admin', 'owner')` — Session guard for web dashboard

### Order status flow
`pending → accepted → fitting → diproses → dijahit → selesai / siap_diambil` (can `rejected` at any point)

## Conventions

- API error messages in **Indonesian**
- Every response body includes `_statusCode` key (added by Flutter client)
- Multipart upload file field: `design_image`
- API client (`api_provider.dart`) — custom `HttpClient` bypasses SSL for ngrok, sends `ngrok-skip-browser-warning` header, 15s timeout
- `ngrok-skip-browser-warning: true` header required on every request
- Admin auto-seeded: username `admin`, password from `ADMIN_DEFAULT_PASSWORD` env or random printed to console

## Routes (14)

| Constant | Path |
|---|---|
| `LOGIN` | `/login` |
| `REGISTER` | `/register` |
| `HOME` | `/home` |
| `TAILOR_DETAIL` | `/tailor-detail` |
| `ORDER_FORM` | `/order-form` |
| `CUSTOMIZE` | `/customize` |
| `ORDERS` | `/orders` |
| `TRACKING` | `/tracking` |
| `PROFILE` | `/profile` |
| `DASHBOARD` | `/dashboard` |
| `EXPLORE` | `/explore` |
| `FAVOURITE` | `/favourite` |
| `VERIFY_EMAIL` | `/verify-email` |
| `ACTIVITY_LOG` | `/activity-log` |

## Commands (from `tailor/`)

```bash
dart analyze                                         # lint + type checks
flutter test                                         # run tests (placeholder only)
flutter run                                          # run on device/emulator
dart run flutter_launcher_icons:generate             # generate launcher icons
flask run --debug                                    # dev server (from tailor/backend)
gunicorn run:app                                     # production
```

## Linting

`tailor/analysis_options.yaml` — extends `package:flutter_lints/flutter.yaml`. Notable overrides: `constant_identifier_names: false`, `unnecessary_underscores: false`. Run with `dart analyze`.

## Key operational notes

- **Web dashboard**: Admin/owner login at `http://localhost:5000/login` (Flask sessions); customers use mobile app only
- **Database**: Tables auto-created via `db.create_all()` on first backend run
- **File uploads**: max 5MB, `png/jpg/jpeg/webp`, MIME-checked via Pillow, stored in `app/static/uploads/`
- **Rate limiting**: 200 req/hour, 50 req/min (in-memory); auth endpoints tighter
- **MongoDB**: `/api/informasi/*` reads from MongoDB collections `populer`/`tren`/`rating`. Initially seeded from Carousell scrape (or hardcoded fallback). APScheduler exists in `scheduler.py` to keep data fresh but is **not auto-started**.
- **CSV files** in `data/` are for the Jupyter notebook only — not used by the backend at all
- **`daily_update.py`**: runs the Jupyter notebook via nbconvert; separate from backend scheduler
- **API endpoints reference**: full table in `tailor/README.md`
