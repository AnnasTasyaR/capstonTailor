"""Scrape Carousell Indonesia untuk produk fashion.
Fallback ke CSV jika scrape gagal."""

import csv
import os
import re
import sys
from collections import Counter, defaultdict
from datetime import datetime, timedelta
from random import choice, randint, normalvariate

DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..', 'data'))

KOTA = [
    'Jakarta', 'Bandung', 'Surabaya', 'Yogyakarta', 'Tangerang',
    'Medan', 'Makassar', 'Bekasi', 'Depok', 'Semarang',
]

GENDER_KW = {
    'Pria': ['pria', 'laki', 'cowok', 'man', 'men', 'boy', 'bapak',
             'mas', 'pak', 'male', 'gentleman', 'groom'],
    'Wanita': ['wanita', 'perempuan', 'cewek', 'girl', 'woman', 'women',
               'female', 'ibu', 'mbak', 'bu', 'lady', 'bride'],
}

HARDCODED_FALLBACK = [
    {'title': 'Kemeja Pria Premium', 'price': 150000, 'gender': 'Pria'},
    {'title': 'Batik Tulis Solo', 'price': 250000, 'gender': 'Pria'},
    {'title': 'Kaos Vintage Carousell', 'price': 75000, 'gender': 'Pria'},
    {'title': 'Jaket Denim Jacket', 'price': 200000, 'gender': 'Pria'},
    {'title': 'Hoodie Oversize Fashion', 'price': 120000, 'gender': 'Pria'},
    {'title': 'Celana Chino Pria', 'price': 135000, 'gender': 'Pria'},
    {'title': 'Rok Plisket Wanita', 'price': 85000, 'gender': 'Wanita'},
    {'title': 'Gaun Pesta Elegan', 'price': 350000, 'gender': 'Wanita'},
    {'title': 'Kebaya Encim Modern', 'price': 275000, 'gender': 'Wanita'},
    {'title': 'Cardigan Rajut Wanita', 'price': 95000, 'gender': 'Wanita'},
    {'title': 'Jas Formal Pria', 'price': 450000, 'gender': 'Pria'},
    {'title': 'Blouse Wanita Kantoran', 'price': 110000, 'gender': 'Wanita'},
    {'title': 'Celana Jeans Kulot', 'price': 140000, 'gender': 'Wanita'},
    {'title': 'Kemeja Flanel Pria', 'price': 99000, 'gender': 'Pria'},
    {'title': 'Tunik Batik Modern', 'price': 165000, 'gender': 'Wanita'},
    {'title': 'Sweater Wanita Vintage', 'price': 105000, 'gender': 'Wanita'},
    {'title': 'Jaket Kulit Sintetis', 'price': 280000, 'gender': 'Pria'},
    {'title': 'Kaos Polos Premium', 'price': 55000, 'gender': 'Pria'},
    {'title': 'Kemeja Oxford Pria', 'price': 125000, 'gender': 'Pria'},
    {'title': 'Daster Muslimah', 'price': 80000, 'gender': 'Wanita'},
]


def _hash_id(val):
    return abs(hash(val)) % 10 ** 8


def _synth_rating(title):
    return round(3.5 + (hash(title) % 15) / 10, 1)


def _synth_sold(title):
    return (hash(title) % 50) + 1


def _synth_cmt(title):
    return (hash(title) % 200) + 2


def _synth_kota(title):
    return KOTA[hash(title) % len(KOTA)]


def _detect_gender(title):
    t = title.lower()
    for g, kw in GENDER_KW.items():
        for k in kw:
            if k in t:
                return g
    if any(w in t for w in ['gamis', 'rok', 'gaun', 'kebaya', 'daster', 'tunik', 'blouse']):
        return 'Wanita'
    if any(w in t for w in ['jas', 'dasi', 'safari', 'koko']):
        return 'Pria'
    return choice(['Pria', 'Wanita'])


def scrape_carousell(keyword='fashion', limit=50, gender_label='Pria'):
    """Scrape produk fashion dari Carousell Indonesia.
    Return list of dicts, atau [] jika gagal."""
    try:
        from curl_cffi import requests
        from bs4 import BeautifulSoup
    except ImportError:
        print('[SCRAPER] curl_cffi/bs4 tidak terinstall, pakai fallback.', file=sys.stderr)
        return []

    all_items = []
    seen = set()

    try:
        url = f'https://id.carousell.com/search/{keyword}'
        resp = requests.get(url, impersonate='chrome', timeout=20)
        if resp.status_code != 200:
            print(f'[SCRAPER] Carousell return {resp.status_code}', file=sys.stderr)
            return []

        soup = BeautifulSoup(resp.text, 'lxml')
        for card in soup.find_all(attrs={
            'data-testid': lambda v: v and v.startswith('listing-card-'),
        }):
            link = card.find('a', href=lambda h: h and '/p/' in (h or ''))
            if not link:
                continue

            el = link.find('p', style=lambda s: s and 'max-line' in s)
            if not el:
                el = link.find('p')
            title = el.get_text(strip=True) if el else ''
            if len(title) < 5:
                continue
            key = title[:60]
            if key in seen:
                continue
            seen.add(key)

            price_el = link.find('p', title=lambda t: t and 'Rp' in t)
            if not price_el:
                div = link.find('div', class_=lambda c: c and 'bgE' in (c or ''))
                if div:
                    price_el = div.find('p')
            price_text = price_el.get_text(strip=True) if price_el else ''
            price = 0
            if price_text:
                digits = re.sub(r'[^0-9]', '', price_text)
                if digits:
                    price = int(digits)

            condition = ''
            psection = link.find('div', class_=lambda c: c and 'bgE' in (c or ''))
            if psection:
                np = psection.find_next_sibling('p')
                if np:
                    condition = np.get_text(strip=True)

            all_items.append({
                'product_id': _hash_id(title),
                'title': title,
                'gender': gender_label,
                'price': price or 50000,
                'rating_star': _synth_rating(title),
                'cmt_count': _synth_cmt(title),
                'historical_sold': _synth_sold(title),
                'shop_location': _synth_kota(title),
                'condition': condition,
                'source': 'carousell',
            })
            if len(all_items) >= limit:
                break
    except Exception as e:
        print(f'[SCRAPER] Error: {e}', file=sys.stderr)
        return []

    return all_items[:limit]


def _csv(path):
    with open(path, encoding='utf-8') as f:
        return list(csv.DictReader(f))


def get_products():
    """Coba scrape Carousell (pria + wanita), fallback CSV, fallback hardcoded."""
    # Scrape both genders
    pria = scrape_carousell('fashion/pria', limit=30, gender_label='Pria')
    wanita = scrape_carousell('fashion/wanita', limit=30, gender_label='Wanita')
    items = pria + wanita

    if len(items) >= 5:
        print(f'[SCRAPER] Carousell: {len(items)} produk (pria={len(pria)}, wanita={len(wanita)})', file=sys.stderr)
        return items

    # Fallback CSV
    csv_path = os.path.join(DATA_DIR, 'produk_fashion.csv')
    if os.path.exists(csv_path):
        try:
            rows = _csv(csv_path)
            print(f'[SCRAPER] CSV fallback: {len(rows)} produk', file=sys.stderr)
            return [{
                'product_id': _hash_id(r['title']),
                'title': r['title'],
                'gender': _detect_gender(r['title']),
                'price': int(r.get('price', 50000)),
                'rating_star': float(r.get('rating_star', 4.0)),
                'cmt_count': int(r.get('cmt_count', 10)),
                'historical_sold': int(r.get('historical_sold', 5)),
                'shop_location': r.get('shop_location', 'Jakarta'),
                'condition': r.get('condition', ''),
                'source': 'csv',
            } for r in rows]
        except Exception as e:
            print(f'[SCRAPER] CSV error: {e}', file=sys.stderr)

    # Last resort: hardcoded
    print('[SCRAPER] Hardcoded fallback: 20 produk', file=sys.stderr)
    return [{
        'product_id': _hash_id(p['title']),
        'title': p['title'],
        'gender': p['gender'],
        'price': p['price'],
        'rating_star': _synth_rating(p['title']),
        'cmt_count': _synth_cmt(p['title']),
        'historical_sold': _synth_sold(p['title']),
        'shop_location': _synth_kota(p['title']),
        'condition': 'Baru',
        'source': 'hardcoded',
    } for p in HARDCODED_FALLBACK]


def generate_orders(products, days=180):
    """Simulasi pesanan."""
    now = datetime.utcnow()
    orders = []
    oid = 100001
    for i in range(days, 0, -1):
        d = now - timedelta(days=i)
        is_weekend = d.weekday() >= 5
        num = randint(8, 18) if is_weekend else randint(3, 10)
        for _ in range(num):
            prod = choice(products)
            qty = choice([1] * 70 + [2] * 25 + [3] * 5)
            price = int(prod['price'] * (0.9 + (hash(str(oid)) % 41) / 100))
            hour = choice(list(range(8, 23)) * 3)
            ts = d.replace(hour=hour, minute=randint(0, 59), second=randint(0, 59))
            status = choice(['COMPLETED'] * 75 + ['SHIPPED'] * 12 + ['PROCESSED'] * 8 + ['CANCELLED'] * 5)
            orders.append({
                'order_id': f'ORD-{oid}',
                'product_id': prod['product_id'],
                'product_title': prod['title'],
                'gender': prod['gender'],
                'price': price,
                'quantity': qty,
                'total': price * qty,
                'status': status,
                'created_at': ts.isoformat(),
                'date': str(d.date()),
                'day_name': d.strftime('%A'),
                'hour': hour,
                'month': d.month,
                'week': d.isocalendar()[1],
                'is_weekend': is_weekend,
            })
            oid += 1
            if oid > 101500:
                break
        if oid > 101500:
            break
    return orders


def generate_feedback(orders):
    """Simulasi feedback dari completed orders."""
    feedbacks = []
    fid = 5001
    for o in orders:
        if o['status'] != 'COMPLETED':
            continue
        if randint(1, 100) > 60:
            continue
        real_rating = _synth_rating(o['product_title'])
        rating = max(1, min(5, round(normalvariate(real_rating, 0.3))))
        feedbacks.append({
            'feedback_id': f'FB-{fid}',
            'order_id': o['order_id'],
            'product_id': o['product_id'],
            'product_title': o['product_title'],
            'gender': o['gender'],
            'rating': rating,
            'created_at': o['created_at'],
        })
        fid += 1
    return feedbacks


def seed_data(mongo_db):
    """Main entry: scrape → proses → insert ke MongoDB."""
    now = datetime.utcnow()
    today = now.date()

    # ── Produk ───────────────────────────────────────────────────────────
    products = get_products()
    products.sort(key=lambda p: p['historical_sold'], reverse=True)
    populer_docs = [{
        'title': p['title'],
        'gender': p['gender'],
        'historical_sold': p['historical_sold'],
        'price': p['price'],
        'updated_at': now,
    } for p in products[:50]]
    mongo_db['populer'].delete_many({})
    if populer_docs:
        mongo_db['populer'].insert_many(populer_docs)
    print(f'[SEED] Populer: {len(populer_docs)} produk')

    # ── Tren ─────────────────────────────────────────────────────────────
    orders = generate_orders(products)
    counts = Counter()
    for o in orders:
        d = o['date']
        counts[d] += 1
    tren_docs = []
    for i in range(29, -1, -1):
        d = str(today - timedelta(days=i))
        tren_docs.append({'date': d, 'orders': counts.get(d, 0), 'updated_at': now})
    mongo_db['tren'].delete_many({})
    mongo_db['tren'].insert_many(tren_docs)
    print(f'[SEED] Tren: {len(tren_docs)} hari ({len(orders)} simulated orders)')

    # ── Rating ───────────────────────────────────────────────────────────
    feedbacks = generate_feedback(orders)
    by_gender = {'Pria': defaultdict(list), 'Wanita': defaultdict(list)}
    for fb in feedbacks:
        g = fb.get('gender', 'Pria')
        by_gender[g][fb['product_title']].append(fb['rating'])
    rating_docs = []
    for g, ratings in by_gender.items():
        for title, vals in ratings.items():
            rating_docs.append({
                'title': title,
                'gender': g,
                'rating_avg': round(sum(vals) / len(vals), 2),
                'rating_count': len(vals),
                'updated_at': now,
            })
    rating_docs.sort(key=lambda x: (-x['rating_avg'], -x['rating_count']))
    mongo_db['rating'].delete_many({})
    if rating_docs:
        mongo_db['rating'].insert_many(rating_docs)
    print(f'[SEED] Rating: {len(rating_docs)} produk ({len(feedbacks)} feedbacks)')

    print('[SEED] Selesai.')
