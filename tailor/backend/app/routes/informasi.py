from flask import Blueprint, jsonify
import pandas as pd
import os

informasi_bp = Blueprint('informasi', __name__)
DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'data')
DATA_DIR = os.path.abspath(DATA_DIR)


def _read_csv(filename: str) -> list[dict]:
    path = os.path.join(DATA_DIR, filename)
    if not os.path.exists(path):
        return []
    df = pd.read_csv(path)
    if 'product_id' in df.columns:
        df['product_id'] = df['product_id'].astype(str)
    return df.to_dict(orient='records')


@informasi_bp.route('/api/informasi/populer', methods=['GET'])
def fashion_populer():
    """Model fashion yang paling sering dipesan."""
    produk = _read_csv('produk_fashion.csv')
    produk.sort(key=lambda p: p.get('historical_sold', 0), reverse=True)
    return jsonify({'produk': produk[:20], 'total': len(produk)})


@informasi_bp.route('/api/informasi/tren', methods=['GET'])
def tren_fashion():
    """Tren order fashion per hari."""
    pesanan = _read_csv('simulasi_pesanan.csv')
    from collections import Counter
    daily = Counter()
    for p in pesanan:
        daily[p.get('date', '')] += 1
    tren = [{'date': d, 'orders': c} for d, c in sorted(daily.items())]
    return jsonify({'tren': tren, 'total_hari': len(tren)})


@informasi_bp.route('/api/informasi/rating', methods=['GET'])
def rating_fashion():
    """Rating produk fashion."""
    feedback = _read_csv('simulasi_feedback.csv')
    produk = _read_csv('produk_fashion.csv')
    # aggregate rating per produk from feedback
    agg = {}
    for f in feedback:
        pid = str(f.get('product_id', ''))
        if pid not in agg:
            agg[pid] = {'ratings': [], 'count': 0}
        agg[pid]['ratings'].append(f.get('rating', 0))
        agg[pid]['count'] += 1
    # merge with produk data
    hasil = []
    for p in produk:
        pid = str(p.get('product_id', ''))
        r = agg.get(pid, {})
        ratings = r.get('ratings', [])
        hasil.append({
            'product_id': pid,
            'title': p.get('title', ''),
            'category': p.get('category', ''),
            'rating_star': p.get('rating_star', 0),
            'rating_avg': round(sum(ratings) / len(ratings), 2) if ratings else 0,
            'rating_count': len(ratings),
        })
    hasil.sort(key=lambda p: p['rating_avg'], reverse=True)
    return jsonify({'rating': hasil, 'total': len(hasil)})
