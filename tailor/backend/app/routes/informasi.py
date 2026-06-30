from flask import Blueprint, jsonify, request

informasi_bp = Blueprint('informasi', __name__)


def _mongo_collection(name):
    try:
        from app.db_mongo import get_db
        db = get_db()
        if db is None:
            return None
        return db[name]
    except Exception:
        return None


def _gender_filter(params: dict) -> dict:
    g = request.args.get('gender', '').lower()
    if g == 'pria':
        params['gender'] = 'Pria'
    elif g == 'wanita':
        params['gender'] = 'Wanita'
    return params


@informasi_bp.route('/api/informasi/populer', methods=['GET'])
def fashion_populer():
    coll = _mongo_collection('populer')
    if coll is None:
        return jsonify({'produk': [], 'total': 0})
    try:
        fil = _gender_filter({})
        docs = list(coll.find(
            fil,
            {'_id': False, 'title': True, 'gender': True,
             'historical_sold': True, 'price': True}
        ).sort('historical_sold', -1).limit(20))
        total = coll.count_documents(fil)
        return jsonify({'produk': docs, 'total': total})
    except Exception:
        return jsonify({'produk': [], 'total': 0})


@informasi_bp.route('/api/informasi/tren', methods=['GET'])
def tren_fashion():
    coll = _mongo_collection('tren')
    if coll is None:
        return jsonify({'tren': [], 'total_hari': 0})
    try:
        docs = list(coll.find(
            {},
            {'_id': False, 'date': True, 'orders': True}
        ).sort('date', 1).limit(7))
        return jsonify({'tren': docs, 'total_hari': len(docs)})
    except Exception:
        return jsonify({'tren': [], 'total_hari': 0})


@informasi_bp.route('/api/informasi/rating', methods=['GET'])
def rating_fashion():
    coll = _mongo_collection('rating')
    if coll is None:
        return jsonify({'rating': [], 'total': 0})
    try:
        fil = _gender_filter({})
        docs = list(coll.find(
            fil,
            {'_id': False, 'title': True, 'gender': True,
             'rating_avg': True, 'rating_count': True}
        ).sort([('rating_avg', -1), ('rating_count', -1)]).limit(20))
        total = coll.count_documents(fil)
        return jsonify({'rating': docs, 'total': total})
    except Exception:
        return jsonify({'rating': [], 'total': 0})
