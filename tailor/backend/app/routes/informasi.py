from flask import Blueprint, jsonify
from app import db
from app.models.tailor import Tailor
from app.models.order import OrderQueue
from sqlalchemy import func
from datetime import datetime, timedelta


informasi_bp = Blueprint('informasi', __name__)


def _today_local():
    return datetime.utcnow().date()


@informasi_bp.route('/api/informasi/populer', methods=['GET'])
def fashion_populer():
    top = db.session.query(
        OrderQueue.tailor_id,
        OrderQueue.type,
        func.count(OrderQueue.id).label('order_count')
    ).group_by(
        OrderQueue.tailor_id, OrderQueue.type
    ).order_by(
        func.count(OrderQueue.id).desc()
    ).limit(20).all()

    hasil = []
    for tailor_id, service_type, count in top:
        tailor = db.session.get(Tailor, tailor_id)
        shop_name = tailor.shop_name if tailor else 'Tidak dikenal'
        hasil.append({
            'title': f'{shop_name} - {service_type}',
            'category': service_type,
            'historical_sold': count,
            'price': 0,
        })
    return jsonify({'produk': hasil, 'total': len(hasil)})


@informasi_bp.route('/api/informasi/tren', methods=['GET'])
def tren_fashion():
    today = _today_local()
    # Always return 7 consecutive days (fill missing days with 0)
    rows = dict(
        db.session.query(
            func.date(OrderQueue.created_at).label('tgl'),
            func.count(OrderQueue.id).label('jml')
        ).filter(
            func.date(OrderQueue.created_at) >= today - timedelta(days=6)
        ).group_by(
            func.date(OrderQueue.created_at)
        ).all()
    )

    tren = []
    for i in range(6, -1, -1):
        d = today - timedelta(days=i)
        tren.append({'date': str(d), 'orders': rows.get(d, 0)})
    return jsonify({'tren': tren, 'total_hari': len(tren)})


@informasi_bp.route('/api/informasi/rating', methods=['GET'])
def rating_fashion():
    tailor_list = Tailor.query.filter(
        Tailor.is_suspended == False
    ).order_by(Tailor.rating.desc()).all()

    order_counts = dict(
        db.session.query(
            OrderQueue.tailor_id,
            func.count(OrderQueue.id)
        ).filter(
            OrderQueue.status.in_(['selesai', 'siap_diambil'])
        ).group_by(OrderQueue.tailor_id).all()
    )

    hasil = []
    for t in tailor_list:
        hasil.append({
            'title': t.shop_name,
            'category': 'Tailor',
            'rating_star': t.rating,
            'rating_avg': round(t.rating, 2),
            'rating_count': order_counts.get(t.id, 0),
        })
    hasil.sort(key=lambda x: x['rating_avg'], reverse=True)
    return jsonify({'rating': hasil, 'total': len(hasil)})
