# Jahitln (TailorLink)

Platform manajemen jasa jahit premium — menghubungkan customer dengan penjahit.  
Flutter mobile app (customer) + Flask web dashboard (admin/owner) + MySQL database.

---

## Daftar Isi

- [Arsitektur](#arsitektur)
- [Tech Stack](#tech-stack)
- [Struktur Proyek](#struktur-proyek)
- [Database Schema](#database-schema)
- [API Endpoints](#api-endpoints)
- [Alur Autentikasi](#alur-autentikasi)
- [Alur Pesanan](#alur-pesanan)
- [Sistem Notifikasi](#sistem-notifikasi)
- [Sistem Activity Log](#sistem-activity-log)
- [AI Analysis](#ai-analysis)
- [Data Analytics](#data-analytics)
- [Flutter App](#flutter-app)
- [Backend (Flask)](#backend-flask)
- [Setup & Instalasi](#setup--instalasi)
- [Keamanan](#keamanan)

---

## Arsitektur

```
┌─────────────────────────────────────────────────────────────────┐
│                   MOBILE APP (Flutter)                          │
│  main.dart ──► GetMaterialApp                                   │
│    ├─ Theme: Material 3, Poppins, Navy Blue #1B2A6B            │
│    ├─ Routes: 14 route (GetX GetPage)                           │
│    └─ Modules: {Binding → Controller → View}                   │
│         └─ Providers ──► ApiProvider (HTTP Client)              │
│                              │                                  │
│                              ▼ HTTPS (ngrok)                    │
└──────────────────────────────┼──────────────────────────────────┘
                               │
┌──────────────────────────────┼──────────────────────────────────┐
│                   BACKEND (Flask :5000)                         │
│  run.py ──► create_app()                                        │
│    ├─ 6 Blueprints (auth, customer, owner, admin, ai, info)    │
│    ├─ Middleware: jwt_guard.py (JWT + session guards)           │
│    ├─ Models: 7 tables (SQLAlchemy + PyMySQL)                  │
│    ├─ Utils: email_util.py (SMTP)                              │
│    └─ Templates: Jinja2 web dashboard                          │
│         │                                                      │
│         ▼                                                      │
│  ┌────────────────────────────────────┐                        │
│  │  MySQL: tailorlink_db              │                        │
│  │  ├─ users, tailors                 │                        │
│  │  ├─ order_queues, order_history    │                        │
│  │  ├─ notifications, favourites      │                        │
│  │  └─ activity_logs                  │                        │
│  └────────────────────────────────────┘                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  EXTERNAL SERVICES                                              │
│  ├─ Google OAuth API (ID token verification)                    │
│  ├─ Google Gemini API (AI image analysis)                       │
│  ├─ Gmail SMTP (Email verifikasi)                               │
│  └─ ngrok (Public tunnel development)                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

### Frontend (Mobile)
| Komponen | Teknologi |
|---|---|
| Framework | Flutter 3.35 (Dart 3.11) |
| State Management | GetX ^4.7.3 |
| Routing | GetX GetPage (14 routes) |
| HTTP Client | dart:io HttpClient + http package |
| Auth Storage | flutter_secure_storage (Android Keystore) |
| Google Sign-In | google_sign_in ^6.2.1 |
| Font | Google Fonts (Poppins) |
| Image | image_picker, cached_network_image |
| Loading | shimmer |

### Backend (Web)
| Komponen | Teknologi |
|---|---|
| Framework | Flask 3.1 (Python 3.12) |
| ORM | Flask-SQLAlchemy 3.1 (PyMySQL) |
| Auth (Mobile) | Flask-JWT-Extended (HS256, 8h) |
| Auth (Web) | Flask-Login (sessions) |
| Rate Limiting | Flask-Limiter (200/hr, 50/min) |
| Template | Jinja2 (Bootstrap 5 sidebar) |
| AI | Google Gemini 2.0 Flash API |
| Production WSGI | Gunicorn 23.0 |

### Database
| Komponen | Detail |
|---|---|
| Database | MySQL (via XAMPP / Laragon) |
| Driver | PyMySQL 1.1.1 |
| Migration | db.create_all() + manual Python scripts |

---

## Struktur Proyek

```
capstonTailor/
├── AGENTS.md                          # Panduan agent / ringkasan proyek
├── data/                              # Data analisis (Jupyter terpisah)
│   ├── analisis_penjahit_shopee.ipynb
│   └── *.csv                          # Data simulasi (tidak dipakai backend)
└── tailor/                            # Root utama
    ├── pubspec.yaml
    ├── analysis_options.yaml
    ├── database/jahit.sql             # Dump MySQL awal
    ├── lib/                           # Flutter App
    │   ├── main.dart                  # Entry point (cek login → dashboard/login)
    │   └── app/
    │       ├── data/
    │       │   ├── models/            # Dart model classes
    │       │   └── providers/         # API communication layer
    │       ├── modules/               # 12 GetX modules
    │       │   ├── auth/              # Login, Register, VerifyEmail
    │       │   ├── home/              # Home screen (tailor list + notif)
    │       │   ├── dashboard/         # Main dashboard after login
    │       │   ├── tailor_detail/     # Detail profil penjahit
    │       │   ├── order/             # Form order + kustomisasi
    │       │   ├── orders/            # Daftar pesanan
    │       │   ├── tracking/          # Tracking pesanan
    │       │   ├── profile/           # Profil user
    │       │   ├── explore/           # Eksplor penjahit
    │       │   ├── favourite/         # Favorit
    │       │   ├── informasi/         # Info populer/tren/rating
    │       │   └── activity_log/      # Riwayat aktivitas
    │       ├── routes/
    │       │   ├── app_routes.dart    # Route constants
    │       │   └── app_pages.dart     # GetPage definitions
    │       └── theme/
    │           ├── app_colors.dart    # Palet warna
    │           └── app_theme.dart     # Material 3 ThemeData
    └── backend/                       # Flask App
        ├── run.py                     # Entry point
        ├── requirements.txt
        ├── .env                       # Environment variables
        ├── migrate_google.py          # Migrasi kolom google_id
        ├── migrate_email_verification.py  # Migrasi kolom verifikasi email
        ├── daily_update.py            # Scheduler Jupyter notebook
        └── app/
            ├── __init__.py            # Flask factory (create_app)
            ├── config.py              # Konfigurasi dari .env
            ├── middleware/
            │   └── jwt_guard.py       # role_required + web_login_required
            ├── models/
            │   ├── __init__.py
            │   ├── user.py            # User model
            │   ├── tailor.py          # Tailor + TailorAvailability
            │   ├── order.py           # OrderQueue + OrderHistory
            │   ├── notification.py    # Notification
            │   ├── favourite.py       # Favourite
            │   └── activity_log.py    # ActivityLog
            ├── routes/
            │   ├── __init__.py
            │   ├── auth.py            # Auth blueprint
            │   ├── customer.py        # Customer API
            │   ├── owner.py           # Owner web dashboard
            │   ├── admin.py           # Admin web dashboard
            │   ├── ai_analysis.py     # AI analysis
            │   └── informasi.py       # Public info endpoints
            ├── utils/
            │   └── email_util.py      # SMTP email
            ├── templates/             # Jinja2 templates
            │   ├── base.html
            │   ├── auth/ (login.html, register.html)
            │   ├── admin/ (dashboard, users, tailors, orders)
            │   └── owner/ (dashboard, orders, order_detail, profile, settings)
            └── static/
                ├── css/style.css
                ├── js/main.js
                └── uploads/           # Uploaded design images
```

---

## Database Schema

### `users`
| Column | Type | Keterangan |
|---|---|---|
| id | INT PK AUTO_INCREMENT | |
| name | VARCHAR(100) NOT NULL | |
| email | VARCHAR(120) UNIQUE NOT NULL | |
| username | VARCHAR(80) UNIQUE NULLABLE | Null untuk Google-only |
| password_hash | VARCHAR(255) NULLABLE | Null untuk Google-only (scrypt) |
| google_id | VARCHAR(128) UNIQUE NULLABLE | |
| phone | VARCHAR(20) NULLABLE | |
| role | VARCHAR(20) DEFAULT 'customer' | admin / owner / customer |
| avatar | VARCHAR(255) NULLABLE | |
| is_active_user | BOOLEAN DEFAULT TRUE | |
| email_verified | BOOLEAN DEFAULT FALSE | |
| verification_code | VARCHAR(6) NULLABLE | 6 digit |
| verification_code_expires | DATETIME NULLABLE | 5 menit |
| created_at | DATETIME DEFAULT utcnow | |

### `tailors`
| Column | Type | Keterangan |
|---|---|---|
| id | INT PK AUTO_INCREMENT | |
| user_id | INT FK → users.id UNIQUE NOT NULL | |
| shop_name | VARCHAR(150) NOT NULL | |
| address | TEXT NULLABLE | |
| phone | VARCHAR(20) NULLABLE | |
| rating | FLOAT DEFAULT 0.0 | |
| status | VARCHAR(20) DEFAULT 'open' | open / close |
| bio | TEXT NULLABLE | |
| shop_image | VARCHAR(255) NULLABLE | |
| is_verified | BOOLEAN DEFAULT FALSE | |
| is_suspended | BOOLEAN DEFAULT FALSE | |
| created_at | DATETIME DEFAULT utcnow | |

### `tailor_availability`
| Column | Type | Keterangan |
|---|---|---|
| id | INT PK AUTO_INCREMENT | |
| tailor_id | INT FK → tailors.id NOT NULL | |
| type | VARCHAR(30) NOT NULL | permak / custom / seragam |
| is_open | BOOLEAN DEFAULT TRUE | |

### `order_queues`
| Column | Type | Keterangan |
|---|---|---|
| id | INT PK AUTO_INCREMENT | |
| customer_id | INT FK → users.id NOT NULL | |
| tailor_id | INT FK → tailors.id NOT NULL | |
| type | VARCHAR(30) NOT NULL | permak / custom / seragam |
| complexity | VARCHAR(20) NULLABLE | sederhana / sedang / rumit |
| status | VARCHAR(30) DEFAULT 'pending' | Lihat alur pesanan |
| design_image | VARCHAR(255) NULLABLE | |
| design_notes | TEXT NULLABLE | |
| estimated_done | DATETIME NULLABLE | |
| fitting_date | DATETIME NULLABLE | |
| queue_number | INT NULLABLE | Nomor antrian per-penjahit |
| created_at | DATETIME DEFAULT utcnow | |

### `order_history`
| Column | Type | Keterangan |
|---|---|---|
| id | INT PK AUTO_INCREMENT | |
| order_id | INT FK → order_queues.id NOT NULL | |
| status | VARCHAR(30) NOT NULL | |
| changed_at | DATETIME DEFAULT utcnow | |
| notes | TEXT NULLABLE | |

### `notifications`
| Column | Type | Keterangan |
|---|---|---|
| id | INT PK AUTO_INCREMENT | |
| user_id | INT FK → users.id NOT NULL | |
| message | TEXT NOT NULL | |
| is_read | BOOLEAN DEFAULT FALSE | |
| created_at | DATETIME DEFAULT utcnow | |

### `favourites`
| Column | Type | Keterangan |
|---|---|---|
| id | INT PK AUTO_INCREMENT | |
| user_id | INT FK → users.id NOT NULL | |
| tailor_id | INT FK → tailors.id NOT NULL | |
| created_at | DATETIME DEFAULT utcnow | |
| UNIQUE | (user_id, tailor_id) | uq_user_tailor |

### `activity_logs`
| Column | Type | Keterangan |
|---|---|---|
| id | INT PK AUTO_INCREMENT | |
| user_id | INT FK → users.id NOT NULL | |
| activity_type | VARCHAR(50) NOT NULL | login / logout / checkout |
| description | VARCHAR(255) NULLABLE | |
| created_at | DATETIME DEFAULT utcnow | |

---

## API Endpoints

Semua API error messages dalam **Bahasa Indonesia**.  
Response selalu menyertakan key `_statusCode` (ditambahkan oleh Flutter client).

### Auth (`/api/auth/*`)

| Method | Endpoint | Rate Limit | Deskripsi |
|---|---|---|---|
| POST | `/api/auth/login` | 10/min, 30/hr | Login email/username + password (customer only) |
| POST | `/api/auth/register` | 5/min, 20/hr | Register customer baru |
| POST | `/api/auth/logout` | - | Logout (catat activity log) |
| POST | `/api/auth/send-verification` | 3/min, 10/hr | Kirim ulang kode verifikasi email |
| POST | `/api/auth/verify-email` | 5/min, 20/hr | Verifikasi kode 6 digit → return JWT |
| POST | `/api/auth/google` | 10/min | Google OAuth login/auto-register |

### Auth Web (session)

| Method | Endpoint | Deskripsi |
|---|---|---|
| GET/POST | `/login` | Web login (admin/owner) |
| GET/POST | `/register` | Web register (owner only) |
| GET | `/logout` | Clear session |

### Customer (JWT, role=customer)

| Method | Endpoint | Deskripsi |
|---|---|---|
| GET | `/api/tailors` | List penjahit (filter: type, search, sort) |
| GET | `/api/tailors/top` | Top penjahit (by completed orders) |
| GET | `/api/tailors/<tid>` | Detail penjahit |
| POST | `/api/orders` | Buat pesanan (multipart: design_image) |
| GET | `/api/orders/my` | Daftar pesanan saya |
| GET | `/api/orders/<oid>` | Detail pesanan |
| GET | `/api/orders/<oid>/tracking` | Tracking steps |
| GET | `/api/profile` | Profil user |
| PUT | `/api/profile` | Update profil |
| PUT | `/api/profile/password` | Ganti password |
| GET | `/api/notifications` | List notifikasi (50 terakhir) |
| PUT | `/api/notifications/<nid>/read` | Tandai baca 1 notifikasi |
| PUT | `/api/notifications/read-all` | Tandai baca semua |
| GET | `/api/favourites` | List favorit |
| POST | `/api/favourites/<tid>` | Tambah favorit |
| DELETE | `/api/favourites/<tid>` | Hapus favorit |
| GET | `/api/activity-logs` | Riwayat aktivitas (50 terakhir) |
| POST | `/api/tailors/<tid>/rate` | Rating penjahit (1-5) |

### Owner Web (`/owner/*`, session)

| Method | Endpoint | Deskripsi |
|---|---|---|
| GET | `/owner/dashboard` | Statistik (active, completed, pending, total) |
| GET | `/owner/orders` | Daftar pesanan (tab: active/history) |
| GET | `/owner/orders/<oid>` | Detail pesanan |
| POST | `/owner/orders/<oid>/update` | Update status (history + notifikasi) |
| GET/POST | `/owner/profile` | Edit profil toko |
| GET/POST | `/owner/settings` | Atur layanan (permak/custom/seragam) |

### Admin Web (`/admin/*`, session)

| Method | Endpoint | Deskripsi |
|---|---|---|
| GET | `/admin/dashboard` | Statistik (users, tailors, orders) |
| GET | `/admin/users` | Daftar users (filter role) |
| POST | `/admin/users/<uid>/toggle` | Aktif/nonaktifkan user |
| POST | `/admin/users/<uid>/delete` | Hapus user (kecuali admin) |
| GET | `/admin/tailors` | Daftar penjahit |
| POST | `/admin/tailors/<tid>/verify` | Verifikasi penjahit |
| POST | `/admin/tailors/<tid>/suspend` | Suspend penjahit |
| GET | `/admin/orders` | Semua pesanan (filter status) |

### AI Analysis (JWT, role=customer)

| Method | Endpoint | Deskripsi |
|---|---|---|
| POST | `/api/ai/analyze` | Analisis desain AI (field: image). Gemini 2.0 Flash → fallback heuristic |

### Informasi (Public, no auth)

| Method | Endpoint | Deskripsi |
|---|---|---|
| GET | `/api/informasi/populer` | Top 20 layanan populer (real-time dari MySQL) |
| GET | `/api/informasi/tren` | Tren 7 hari (real-time dari MySQL) |
| GET | `/api/informasi/rating` | Semua penjahit by rating (real-time dari MySQL) |

---

## Alur Autentikasi

### Mobile (Customer) — JWT

```
Register:
  1. POST /api/auth/register → buat User (role=customer)
  2. Kirim email verifikasi (6 digit code via SMTP)
  3. POST /api/auth/verify-email dengan code → email_verified=true
  4. Return JWT (HS256, 8 jam expiry)

Login Email:
  1. POST /api/auth/login (login_id, password)
  2. Validasi: active_user, email_verified, role=customer
  3. Return JWT + user data

Google OAuth:
  1. Flutter: google_sign_in → dapat id_token
  2. POST /api/auth/google dengan id_token
  3. Server: verify_oauth2_token() via google-auth
  4. Auto-register jika baru (generate username)
  5. Jika email belum verified → kirim kode verifikasi
  6. Return JWT

Token Usage:
  Authorization: Bearer <token>
  Dicek oleh @jwt_required() + @role_required('customer')
```

### Web Dashboard (Admin/Owner) — Session

```
  1. GET /login → render form
  2. POST /login (login_id, password)
  3. Validasi role IN ('admin', 'owner')
  4. Simpan session {user_id, role, user_name}
  5. Redirect ke dashboard masing-masing
  6. Session 8 jam, HTTP-only, SameSite=Lax
```

---

## Alur Pesanan

```
pending → accepted → fitting → diproses → dijahit → selesai / siap_diambil
                                                     atau rejected (kapan saja)
```

Setiap transisi status oleh owner:
1. Update `order_queues.status`
2. Buat record `order_history` (audit trail)
3. Buat `notifications` untuk customer
4. Label notifikasi: `accepted → diterima`, `fitting → jadwal fitting`, dll.

---

## Sistem Notifikasi

| Aspek | Detail |
|---|---|
| Tabel | `notifications` (user_id, message, is_read, created_at) |
| Pembuatan | Saat owner update status pesanan (`owner.py:59`) |
| Pengambilan | `GET /api/notifications` — 50 terakhir, DESC |
| Polling (Flutter) | Setiap 15 detik (HomeController._startPolling) |
| Snackbar | Notif baru muncul sebagai toast di atas layar (Get.rawSnackbar) |
| Mark Read | Per-item: `PUT /api/notifications/<id>/read`; Bulk: `/read-all` |
| Bottom Sheet | Daftar notifikasi dari icon bell di halaman home |

---

## Sistem Activity Log

| Aspek | Detail |
|---|---|
| Tabel | `activity_logs` (user_id, activity_type, description, created_at) |
| Tipe | `login` (email/Google), `logout`, `checkout` |
| Pembuatan | Auth login/logout, order creation |
| Pengambilan | `GET /api/activity-logs` — 50 terakhir, DESC |

---

## AI Analysis

| Aspek | Detail |
|---|---|
| Endpoint | `POST /api/ai/analyze` (multipart, field `image`) |
| Proses | 1. Simpan image → 2. Resize 512×512, grayscale, SMOOTH filter → 3. Gemini 2.0 Flash (JSON: complexity, estimated_days) → 4. Fallback: heuristic warna |
| Fallback | <50 warna → sederhana (3 hari); 50-199 → sedang (5 hari); 200+ → rumit (10 hari) |
| Response | `{complexity, estimated_days, image}` |

---

## Data Analytics

Tiga endpoint `/api/informasi/*` query **MySQL langsung** (real-time, tanpa CSV):

| Endpoint | Query |
|---|---|
| `/populer` | Top 20 layanan (group by tailor_id + type, order count DESC) |
| `/tren` | Count order per-hari 7 hari terakhir (0-filled untuk hari tanpa order) |
| `/rating` | Semua penjahit aktif non-suspend, sort by rating DESC + completed order count |

> Notebook `data/analisis_penjahit_shopee.ipynb` adalah tools data science terpisah untuk analisis histori Shopee (CSV). **Tidak terhubung** ke backend.

---

## Flutter App

### Route Table

| Route Constant | Path | Module | Transition |
|---|---|---|---|
| LOGIN | `/login` | auth/login | fadeIn |
| REGISTER | `/register` | auth/register | rightToLeft |
| HOME | `/home` | home | fadeIn |
| TAILOR_DETAIL | `/tailor-detail` | tailor_detail | rightToLeft |
| ORDER_FORM | `/order-form` | order | rightToLeft |
| CUSTOMIZE | `/customize` | order | rightToLeft |
| ORDERS | `/orders` | orders | rightToLeft |
| TRACKING | `/tracking` | tracking | rightToLeft |
| PROFILE | `/profile` | profile | rightToLeft |
| DASHBOARD | `/dashboard` | dashboard | default |
| EXPLORE | `/explore` | explore | default |
| FAVOURITE | `/favourite` | favourite | default |
| VERIFY_EMAIL | `/verify-email` | auth/verify_email | fadeIn |
| ACTIVITY_LOG | `/activity-log` | activity_log | rightToLeft |

### Theme

| Properti | Value |
|---|---|
| Primary | Navy Blue `#1B2A6B` |
| Accent | Warm Gold `#C9813A` |
| Background | Light Gray `#F7F8FC` |
| Font | Poppins (google_fonts) |
| Framework | Material 3 |
| Card Radius | 16px |
| Button | Pill shape (30px radius) |

### Module Pattern (GetX)

Setiap modul mengikuti struktur:
```
modules/<nama>/
├── bindings/<nama>_binding.dart    # Dependency injection
├── controllers/<nama>_controller.dart  # Business logic + state
└── views/<nama>_view.dart          # UI (GetView / StatelessWidget)
```

### API Communication

- **ApiProvider** — HTTP client kustom (SSL bypass untuk ngrok)
- Header wajib: `ngrok-skip-browser-warning: true`
- Semua response ditambahi `_statusCode`
- JWT disimpan di `FlutterSecureStorage`
- Upload multipart via `http.MultipartRequest`

---

## Backend (Flask)

### Blueprint Registry

| Blueprint | Prefix | File | Fungsi |
|---|---|---|---|
| auth_bp | - | auth.py | Auth JWT + session |
| customer_bp | - | customer.py | Customer mobile API |
| owner_bp | /owner | owner.py | Owner web dashboard |
| admin_bp | /admin | admin.py | Admin web dashboard |
| ai_bp | - | ai_analysis.py | AI analysis |
| informasi_bp | - | informasi.py | Public info |

### Middleware

- **`@role_required('customer')`** — JWT guard untuk mobile API
- **`@web_login_required('admin', 'owner')`** — Session guard untuk web dashboard

### Configuration (.env keys)

| Key | Fungsi |
|---|---|
| FLASK_SECRET_KEY | Secret key Flask |
| JWT_SECRET_KEY | Secret key JWT |
| DB_HOST / DB_PORT / DB_NAME / DB_USER / DB_PASS | Koneksi MySQL |
| GEMINI_API_KEY | API key Google Gemini |
| GOOGLE_CLIENT_ID | Client ID Google OAuth |
| SMTP_HOST / PORT / USER / PASS | Konfigurasi SMTP |
| FROM_EMAIL | Email pengirim |
| ADMIN_DEFAULT_PASSWORD | Password default admin |

### Rate Limiting

| Scope | Limit |
|---|---|
| Global | 200 request/jam, 50 request/menit |
| Auth login | 10/menit, 30/jam |
| Auth register | 5/menit, 20/jam |
| Google login | 10/menit |
| Order creation | 10/menit, 30/jam |
| Email verification | 5/menit, 20/jam |
| Send verification | 3/menit, 10/jam |

---

## Setup & Instalasi

### Prasyarat

- Flutter 3.35+ (Dart 3.11+)
- Python 3.12
- MySQL (XAMPP / Laragon)
- ngrok (https://ngrok.com/download)
- Gmail App Password (untuk SMTP verifikasi email)

### Langkah Instalasi

```bash
# 1. Import database
mysql -u root -p tailorlink_db < tailor/database/jahit.sql

# 2. Backend
cd tailor/backend
pip install -r requirements.txt
# Jalankan migrasi
python migrate_google.py
python migrate_email_verification.py
# Jalankan server
flask run --debug

# 3. Expose backend via ngrok
ngrok config add-authtoken <token>
ngrok http 5000

# 4. Update URL di Flutter
# Edit: lib/app/data/providers/api_provider.dart (baseUrl)

# 5. Flutter
cd tailor
flutter pub get
flutter run
```

### Urutan Run (Daily)

```bash
# 1. Backend
flask run --debug

# 2. ngrok (terminal baru)
ngrok http 5000

# 3. Update baseUrl di api_provider.dart dengan URL ngrok baru

# 4. Flutter
flutter run
```

---

## Keamanan

| Aspek | Implementasi |
|---|---|
| Password | scrypt (32768 iterasi, werkzeug) |
| JWT | HS256, 8 jam expiry |
| Rate Limit | 200/jam, 50/menit (lebih ketat di auth) |
| File Upload | Cek ekstensi + MIME (Pillow), max 5MB |
| Error Messages | Bahasa Indonesia, tanpa stack trace |
| Security Headers | X-Frame-Options: DENY, CSP, X-Content-Type-Options |
| Session | HTTP-only, SameSite=Lax, Secure (prod) |
| Google Token | Verifikasi google-auth library, clock skew 10s |
| Admin Seed | Random password jika tidak di .env |

---

## Catatan Penting

- **ngrok URL**: Berubah setiap restart ngrok. Update `baseUrl` di `api_provider.dart`.
- **Python versi**: Dependencies untuk Python 3.12. Gunakan `py -3.12` jika default Python berbeda.
- **Database**: Tabel auto-created via `db.create_all()` saat backend pertama kali jalan.
- **Web Dashboard**: Admin/owner login via browser di `http://localhost:5000/login`.
- **SMTP**: Butuh Gmail App Password, konfigurasi di `.env`.
- **Order status flow**: `pending → accepted → fitting → diproses → dijahit → selesai / siap_diambil` (bisa `rejected` kapan saja).
- **All API errors in Indonesian**: Sesuai target market.
