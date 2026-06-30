# Alur Kerja Jahitln — Informasi & Real-time Scraper

## Arsitektur

```
┌─────────────────────────────────────────────────────────────────┐
│                     FLUTTER APP (Mobile)                        │
│  Explore Page                                                  │
│    → GET /api/informasi/populer                                │
│    → GET /api/informasi/tren                                   │
│    → GET /api/informasi/rating                                 │
└─────────────────────────────────────────────────────────────────
         │  HTTP (JWT Bearer Token)
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FLASK BACKEND (Server)                       │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                   informasi.py                          │    │
│  │   Baca dari MongoDB (collections: populer, tren, rating) │    │
│  └────────────────────────┬────────────────────────────────┘    │
│                           │                                     │
│                           ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │            db_mongo.py  (init_mongo)                    │    │
│  │                                                        │    │
│  │  Saat server START:                                    │    │
│  │    1. Konek ke MongoDB Atlas                           │    │
│  │    2. Panggil scraper.seed_data()                      │    │
│  │    3. Siap diakses API                                  │    │
│  └───────────────────────┬─────────────────────────────────┘    │
│                          │                                       │
│                          ▼                                       │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │               scraper.py                                │    │
│  │                                                        │    │
│  │  seed_data() →                                          │    │
│  │    ├── get_products()                                   │    │
│  │    │     ├── ✅ scrape_carousell() → Carousell LIVE     │    │
│  │    │     ├── ⚠️  gagal? → baca produk_fashion.csv      │    │
│  │    │     └── ❌ CSV juga gak ada? → 20 hardcoded        │    │
│  │    ├── generate_orders() → simulasi 180 hari            │    │
│  │    └── generate_feedback() → rating dari completed      │    │
│  │                                                        │    │
│  │  ↓ delete_many + insert_many ke MongoDB                 │    │
│  └─────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────
```

---

## Sumber Data

### Produk Fashion
| Prioritas | Sumber | Cara |
|---|---|---|
| 1️⃣ | **Carousell Indonesia** | Scrape `id.carousell.com/search/fashion` (curl_cffi + Chrome impersonate) |
| 2️⃣ | **CSV (`data/produk_fashion.csv`)** | Jika Carousell tidak bisa diakses |
| 3️⃣ | **Hardcoded (20 produk)** | Jika semuanya gagal |

> Judul & harga produk **asli** dari Carousell.  
> Rating, sold count, komentar **disimulasi** (sama seperti di notebook).

### Orders & Feedback
Semua **simulasi** (sama persis dengan notebook analisis):
- `generate_orders()` — 180 hari simulasi pesanan, weekend lebih padat
- `generate_feedback()` — 60% dari completed orders dapat rating

---

## Alur Startup

```
Flask start
    │
    ▼
init_mongo() ─────→ Connect MongoDB Atlas
    │
    ▼
scraper.seed_data()
    │
    ├── get_products()
    │     ├── 🔥 Scrape Carousell → 45-50 produk real-time
    │     ├── ⚠️  Fallback CSV   → baca data/produk_fashion.csv
    │     └── ❌ Fallback HC     → 20 produk hardcoded
    │
    ├── Sort by historical_sold desc
    ├── delete_many + insert_many → collection populer
    │
    ├── generate_orders(products)
    │     ├── Loop 180 hari, random orders per hari
    │     ├── Weekend: 8-18, Weekday: 3-10
    │     ├── Status: COMPLETED 75%, SHIPPED/PROCESSED/CANCELLED sisanya
    │     └── delete_many + insert_many → collection tren
    │
    └── generate_feedback(orders)
          ├── Ambil COMPLETED orders, 60% dikasih rating
          ├── Rating: normal distribution dari synthetic rating_produk
          └── delete_many + insert_many → collection rating
    │
    ▼
API siap melayani request
```

> ✅ **Tidak perlu notebook, tidak perlu CSV manual, tidak perlu scheduler.**  
> Cukup restart server → scrape langsung dari Carousell → seed MongoDB.

---

## API Endpoints

| Endpoint | Method | Collection | Proses |
|---|---|---|---|
| `/api/informasi/populer` | GET | `populer` | Sort `historical_sold` desc → top 20 |
| `/api/informasi/tren` | GET | `tren` | Sort `date` asc → 7 hari terakhir |
| `/api/informasi/rating` | GET | `rating` | Sort `rating_avg` desc → top 20 |

### Response

```json
// /api/informasi/populer
{
  "produk": [{"title": "Jaket Denim Jacket", "category": "Fashion", "historical_sold": 42, "price": 200000}],
  "total": 20
}

// /api/informasi/tren
{
  "tren": [{"date": "2026-07-04", "orders": 15}],
  "total_hari": 7
}

// /api/informasi/rating
{
  "rating": [{"title": "Hoodie Oversize Fashion", "rating_avg": 4.8, "rating_count": 22}],
  "total": 20
}
```

---

## Dependencies (baru)

Library scraping yang ditambahkan ke `requirements.txt`:

```
curl-cffi==0.15.0       # HTTP client dgn Chrome impersonate (bypass bot detection)
beautifulsoup4==4.15.0   # parsing HTML
lxml==6.1.1              # parser backend
```

Install sekali:
```bash
cd tailor/backend
pip install -r requirements.txt
```

---

## Troubleshooting

| Problem | Penyebab | Solusi |
|---|---|---|
| `[MONGO] Could not connect` | Atlas cluster mati / IP / password salah | Cek Atlas UI → Network Access & Database Access |
| `[SCRAPER] Carousell return 403/429` | Diblokir Carousell | Otomatis fallback ke CSV → hardcoded, tidak perlu tindakan |
| `[SCRAPER] curl_cffi/bs4 tidak terinstall` | Lupa `pip install -r requirements.txt` | Jalankan install dependencies |
| Endpoint return `[]` | MongoDB fallback total | Cek log, perbaiki `.env`, restart |
| Password dengan `@` / `:` error | Karakter spesial di URI | URL encode: `@`→`%40`, `:`→`%3A`, `/`→`%2F` |

## File Terkait

| File | Fungsi |
|---|---|
| `tailor/backend/app/scraper.py` | Scrape Carousell + generate simulasi orders/feedback |
| `tailor/backend/app/db_mongo.py` | Koneksi MongoDB + panggil `seed_data()` di startup |
| `tailor/backend/app/routes/informasi.py` | 3 endpoint baca dari MongoDB |
| `tailor/backend/app/config.py` | Config `MONGO_URI` & `MONGO_DB` |
| `tailor/backend/app/__init__.py` | Init MongoDB + seed di `create_app()` |
| `tailor/backend/.env` | `MONGO_URI` — koneksi Atlas |
| `data/analisis_penjahit_shopee.ipynb` | Notebook asli (referensi logic scraper) |
