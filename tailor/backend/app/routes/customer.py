from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import get_jwt_identity
from werkzeug.security import generate_password_hash
from app import db, limiter
from app.models.user import User
from app.models.tailor import Tailor, TailorAvailability
from app.models.order import OrderQueue, OrderHistory
from app.models.notification import Notification
from app.models.favourite import Favourite
from app.middleware.jwt_guard import role_required
from datetime import datetime, timedelta
import os, uuid

customer_bp = Blueprint('customer', __name__)


def _validate_upload(file_obj) -> tuple[bool, str]:
    """Validate uploaded file MIME type using Pillow. Returns (ok, error_msg)."""
    if not file_obj or not file_obj.filename:
        return True, ''
    # Check extension
    ext = file_obj.filename.rsplit('.', 1)[-1].lower() if '.' in file_obj.filename else ''
    allowed_ext = current_app.config.get('ALLOWED_EXTENSIONS', {'png','jpg','jpeg','webp'})
    if ext not in allowed_ext:
        allowed_str = ', '.join(sorted(allowed_ext))
        return False, f'Format file tidak didukung. Gunakan: {allowed_str}'
    # Validate via Pillow (read full content into memory)
    try:
        from PIL import Image
        import io
        file_obj.stream.seek(0)
        data = file_obj.read()
        file_obj.stream.seek(0)
        img = Image.open(io.BytesIO(data))
        fmt = img.format.lower() if img.format else ''
        if fmt not in ('png', 'jpeg', 'webp', 'jpg'):
            return False, 'File bukan gambar yang valid'
        img.verify()
    except Exception:
        return False, 'File tidak dapat dibaca sebagai gambar'
    return True, ''

@customer_bp.route('/api/tailors', methods=['GET'])
@role_required('customer')
def list_tailors():
    service_type = request.args.get('type', '')
    search = request.args.get('search', '')
    sort = request.args.get('sort', '')
    query = Tailor.query.filter_by(is_suspended=False)
    if search:
        query = query.filter(Tailor.shop_name.ilike(f'%{search}%'))
    if sort == 'rating':
        query = query.order_by(Tailor.rating.desc())
    tailors = query.all()
    result = []
    for t in tailors:
        if service_type:
            avail = TailorAvailability.query.filter_by(tailor_id=t.id, type=service_type, is_open=True).first()
            if not avail:
                continue
        result.append(t.to_dict())
    return jsonify({"tailors": result}), 200


@customer_bp.route('/api/tailors/top', methods=['GET'])
@role_required('customer')
def top_tailors():
    """Return top tailors sorted by total completed order count (paling laris)."""
    from sqlalchemy import func
    limit = int(request.args.get('limit', 5))
    # Subquery: count completed orders per tailor
    order_counts = db.session.query(
        OrderQueue.tailor_id,
        func.count(OrderQueue.id).label('order_count')
    ).filter(
        OrderQueue.status.in_(['selesai', 'siap_diambil', 'diproses', 'dijahit', 'accepted'])
    ).group_by(OrderQueue.tailor_id).subquery()

    top = db.session.query(Tailor, order_counts.c.order_count).outerjoin(
        order_counts, Tailor.id == order_counts.c.tailor_id
    ).filter(
        Tailor.is_suspended == False
    ).order_by(
        db.desc(order_counts.c.order_count),
        Tailor.rating.desc()
    ).limit(limit).all()

    result = []
    for tailor, count in top:
        d = tailor.to_dict()
        d['total_orders'] = count or 0
        result.append(d)
    return jsonify({"tailors": result}), 200

@customer_bp.route('/api/tailors/<int:tid>', methods=['GET'])
@role_required('customer')
def get_tailor(tid):
    tailor = db.get_or_404(Tailor, tid)
    return jsonify({"tailor": tailor.to_dict()}), 200

@customer_bp.route('/api/orders', methods=['POST'])
@role_required('customer')
@limiter.limit("10 per minute; 30 per hour")
def create_order():
    uid = int(get_jwt_identity())
    tailor_id    = request.form.get('tailor_id')
    order_type   = request.form.get('type', '')[:50]
    design_notes = request.form.get('design_notes', '')[:1000]
    fitting_date_str = request.form.get('fitting_date', '')
    complexity   = request.form.get('complexity', 'medium')
    est_days     = min(int(request.form.get('estimated_days', '7')), 365)

    if not tailor_id or not order_type:
        return jsonify({"msg": "Tailor dan jenis jahit harus dipilih"}), 400

    # Validate complexity
    if complexity not in ('low', 'medium', 'high'):
        complexity = 'medium'

    tailor = db.session.get(Tailor, int(tailor_id))
    if not tailor:
        return jsonify({"msg": "Penjahit tidak ditemukan"}), 404

    design_image = None
    if 'design_image' in request.files:
        f = request.files['design_image']
        ok, err = _validate_upload(f)
        if not ok:
            return jsonify({"msg": err}), 400
        if f.filename:
            ext = f.filename.rsplit('.', 1)[-1].lower() if '.' in f.filename else 'jpg'
            fn  = f"{uuid.uuid4().hex}.{ext}"
            f.save(os.path.join(current_app.config['UPLOAD_FOLDER'], fn))
            design_image = fn

    fitting_date = None
    if fitting_date_str:
        try:
            fitting_date = datetime.fromisoformat(fitting_date_str)
        except Exception:
            pass

    last = OrderQueue.query.filter_by(tailor_id=tailor.id).order_by(OrderQueue.queue_number.desc()).first()
    qn   = (last.queue_number or 0) + 1 if last else 1
    order = OrderQueue(
        customer_id=uid, tailor_id=tailor.id, type=order_type,
        complexity=complexity, status='pending', design_image=design_image,
        design_notes=design_notes,
        estimated_done=datetime.utcnow() + timedelta(days=est_days),
        fitting_date=fitting_date, queue_number=qn
    )
    db.session.add(order)
    db.session.flush()
    db.session.add(OrderHistory(order_id=order.id, status='pending', notes='Pesanan dibuat'))
    db.session.add(Notification(user_id=tailor.user_id, message=f'Pesanan baru #{qn} ({order_type})'))
    db.session.commit()
    return jsonify({"msg": "Pesanan berhasil dibuat", "order": order.to_dict()}), 201

@customer_bp.route('/api/orders/my', methods=['GET'])
@role_required('customer')
def my_orders():
    uid = int(get_jwt_identity())
    orders = OrderQueue.query.filter_by(customer_id=uid).order_by(OrderQueue.created_at.desc()).all()
    return jsonify({"orders": [o.to_dict() for o in orders]}), 200

@customer_bp.route('/api/orders/<int:oid>', methods=['GET'])
@role_required('customer')
def get_order(oid):
    uid = int(get_jwt_identity())
    order = OrderQueue.query.filter_by(id=oid, customer_id=uid).first_or_404()
    return jsonify({"order": order.to_dict()}), 200

@customer_bp.route('/api/orders/<int:oid>/tracking', methods=['GET'])
@role_required('customer')
def get_tracking(oid):
    uid = int(get_jwt_identity())
    order = OrderQueue.query.filter_by(id=oid, customer_id=uid).first_or_404()
    statuses = ['pending','accepted','fitting','diproses','dijahit','selesai','siap_diambil']
    labels = {'pending':'Menunggu Konfirmasi','accepted':'Diterima','fitting':'Jadwal Fitting',
              'diproses':'Diproses','dijahit':'Sedang Dijahit','selesai':'Selesai','siap_diambil':'Siap Diambil'}
    icons = {'pending':'⏳','accepted':'✅','fitting':'📅','diproses':'⚙️','dijahit':'🧵','selesai':'✅','siap_diambil':'📦'}
    ci = statuses.index(order.status) if order.status in statuses else 0
    hmap = {h.status: h.changed_at.isoformat() for h in order.history if h.changed_at}
    steps = [{'status':s,'label':labels.get(s,s),'icon':icons.get(s,''),'is_completed':i<=ci,
              'is_current':i==ci,'completed_at':hmap.get(s)} for i,s in enumerate(statuses)]
    return jsonify({"order_id":order.id,"queue_number":order.queue_number,"current_status":order.status,
        "estimated_done":order.estimated_done.isoformat() if order.estimated_done else None,
        "fitting_date":order.fitting_date.isoformat() if order.fitting_date else None,"steps":steps}), 200

@customer_bp.route('/api/profile', methods=['GET'])
@role_required('customer')
def get_profile():
    user = db.get_or_404(User, int(get_jwt_identity()))
    return jsonify({"user": user.to_dict()}), 200

@customer_bp.route('/api/profile', methods=['PUT'])
@role_required('customer')
def update_profile():
    user = db.get_or_404(User, int(get_jwt_identity()))
    data = request.get_json() or {}
    if 'name' in data: user.name = data['name'].strip()
    if 'phone' in data: user.phone = data['phone'].strip()
    db.session.commit()
    return jsonify({"msg": "Profil diperbarui", "user": user.to_dict()}), 200

@customer_bp.route('/api/profile/password', methods=['PUT'])
@role_required('customer')
def change_password():
    user = db.get_or_404(User, int(get_jwt_identity()))
    data = request.get_json() or {}
    if not user.check_password(data.get('old_password','')):
        return jsonify({"msg": "Password lama salah"}), 400
    if len(data.get('new_password','')) < 6:
        return jsonify({"msg": "Password baru minimal 6 karakter"}), 400
    user.set_password(data['new_password'])
    db.session.commit()
    return jsonify({"msg": "Password berhasil diubah"}), 200

@customer_bp.route('/api/notifications', methods=['GET'])
@role_required('customer')
def get_notifications():
    notifs = Notification.query.filter_by(user_id=int(get_jwt_identity())).order_by(Notification.created_at.desc()).limit(50).all()
    return jsonify({"notifications": [n.to_dict() for n in notifs]}), 200

@customer_bp.route('/api/notifications/toggle', methods=['PUT'])
@role_required('customer')
def toggle_notifications():
    return jsonify({"msg": "Pengaturan notifikasi diperbarui"}), 200


# ── Favourites ──────────────────────────────────────────────────────────────

@customer_bp.route('/api/favourites', methods=['GET'])
@role_required('customer')
def get_favourites():
    uid = int(get_jwt_identity())
    favs = Favourite.query.filter_by(user_id=uid).all()
    return jsonify({"favourites": [f.to_dict() for f in favs]}), 200


@customer_bp.route('/api/favourites/<int:tailor_id>', methods=['POST'])
@role_required('customer')
def add_favourite(tailor_id):
    uid = int(get_jwt_identity())
    existing = Favourite.query.filter_by(user_id=uid, tailor_id=tailor_id).first()
    if existing:
        return jsonify({"msg": "Sudah ada di favorit"}), 409
    tailor = db.get_or_404(Tailor, tailor_id)
    fav = Favourite(user_id=uid, tailor_id=tailor.id)
    db.session.add(fav)
    db.session.commit()
    return jsonify({"msg": "Ditambahkan ke favorit", "favourite": fav.to_dict()}), 201


@customer_bp.route('/api/favourites/<int:tailor_id>', methods=['DELETE'])
@role_required('customer')
def remove_favourite(tailor_id):
    uid = int(get_jwt_identity())
    fav = Favourite.query.filter_by(user_id=uid, tailor_id=tailor_id).first()
    if not fav:
        return jsonify({"msg": "Tidak ada di favorit"}), 404
    db.session.delete(fav)
    db.session.commit()
    return jsonify({"msg": "Dihapus dari favorit"}), 200


# ── Rating ──────────────────────────────────────────────────────────────────

@customer_bp.route('/api/tailors/<int:tid>/rate', methods=['POST'])
@role_required('customer')
def rate_tailor(tid):
    uid = int(get_jwt_identity())
    # Only allow rating if customer has a completed order with this tailor
    completed_order = OrderQueue.query.filter(
        OrderQueue.customer_id == uid,
        OrderQueue.tailor_id == tid,
        OrderQueue.status.in_(['selesai', 'siap_diambil'])
    ).first()
    if not completed_order:
        return jsonify({"msg": "Anda hanya bisa memberi rating setelah pesanan selesai"}), 403
    data = request.get_json() or {}
    rating = data.get('rating', 0)
    if not (1 <= rating <= 5):
        return jsonify({"msg": "Rating harus antara 1-5"}), 400
    tailor = db.get_or_404(Tailor, tid)
    # Recalculate average rating
    all_orders = OrderQueue.query.filter(
        OrderQueue.tailor_id == tid,
        OrderQueue.status.in_(['selesai', 'siap_diambil'])
    ).count()
    if all_orders > 0:
        tailor.rating = ((tailor.rating * (all_orders - 1)) + rating) / all_orders
    else:
        tailor.rating = rating
    db.session.commit()
    return jsonify({"msg": "Rating berhasil disimpan", "new_rating": tailor.rating}), 200
