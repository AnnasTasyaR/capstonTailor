# Jahitln (TailorLink) — Agent Guide

Single Flutter + Flask repo inside `tailor/`:
- **Flutter app** (`tailor/lib/`) — GetX, Material 3, Poppins font, navy-blue primary (`#1B2A6B`)
- **Flask backend** (`tailor/backend/`) — REST API (`/api/*`) + session-based web dashboard for admin/owner
- **Data analysis** (`data/`) — Jupyter notebook + CSVs (not read by backend)

## Quick start (dev server)

```bash
# 1. Import DB & run migrations
mysql -u root -p tailorlink_db < tailor/database/jahit.sql
cd tailor/backend
pip install -r requirements.txt
python migrate_google.py
python migrate_email_verification.py
python migrate_item_type.py

# 2. Start backend (port 5000, binds 0.0.0.0)
flask run --debug

#    Pada startup akan:
#    - Scrape Carousell (produk fashion terbaru)
#    - Seed ke MongoDB Atlas (populer, tren, rating)
#    - Fallback ke CSV / hardcoded jika scrape gagal

# 3. Expose via ngrok, then update baseUrl in lib/app/data/providers/api_provider.dart
ngrok http 5000

# 4. Run Flutter app
cd tailor
flutter pub get
flutter run
```

> **Python version**: Dependencies target Python 3.12. Use `py -3.12` if default `python` is a different version.
> **SMTP config**: `tailor/backend/.env` (SMTP_HOST/PORT/USER/PASS, FROM_EMAIL). Requires Gmail App Password.
> **ngrok URL**: Changes every restart. Update `baseUrl` in `api_provider.dart` line 8.

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
`pending → accepted → fitting → diproses → dijahit → selesai / siap_diambil` (or `rejected` at any point)

## Key conventions

- All API error messages in **Indonesian**
- Every response body includes `_statusCode` key (added by Flutter client)
- Multipart upload file field: `design_image`
- API client (`api_provider.dart`) — custom `HttpClient` bypasses SSL for ngrok, sends `ngrok-skip-browser-warning` header, 15s timeout
- Admin auto-seeded: username `admin`, password from `ADMIN_DEFAULT_PASSWORD` env or random printed to console
- `/api/informasi/*` reads from `data/*.csv` (Shopee analysis), not from MySQL/MongoDB

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

## Notes

- **Web dashboard**: Admin/owner login at `http://localhost:5000/login` (Flask sessions); customers use mobile app only
- **Database**: Tables auto-created via `db.create_all()` on first backend run
- **File uploads**: max 5MB, `png/jpg/jpeg/webp`, stored in `app/static/uploads/`
- **Rate limiting**: 200 req/hour, 50 req/min (in-memory); auth endpoints tighter
- **Data analysis**: `/api/informasi/*` reads from MongoDB (auto-seeded from `data/*.csv` on every restart; Shopee analysis)
