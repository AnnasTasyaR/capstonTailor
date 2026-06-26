from flask import Blueprint, render_template, request, redirect, url_for, flash, session
from app import db
from app.models.user import User
from app.models.tailor import Tailor, TailorAvailability
from app.models.order import OrderQueue, OrderHistory
from app.models.notification import Notification
from app.middleware.jwt_guard import web_login_required
from datetime import datetime

owner_bp = Blueprint('owner', __name__, url_prefix='/owner')

@owner_bp.route('/dashboard')
@web_login_required('owner')
def dashboard():
    user = db.get_or_404(User, session['user_id'])
    tailor = Tailor.query.filter_by(user_id=user.id).first()
    if not tailor:
        flash('Profil toko belum dibuat.', 'warning')
        return redirect(url_for('owner.profile'))
    active = OrderQueue.query.filter(OrderQueue.tailor_id==tailor.id, OrderQueue.status.notin_(['selesai','siap_diambil','rejected'])).count()
    completed = OrderQueue.query.filter(OrderQueue.tailor_id==tailor.id, OrderQueue.status.in_(['selesai','siap_diambil'])).count()
    pending = OrderQueue.query.filter_by(tailor_id=tailor.id, status='pending').count()
    total = OrderQueue.query.filter_by(tailor_id=tailor.id).count()
    recent = OrderQueue.query.filter_by(tailor_id=tailor.id).order_by(OrderQueue.created_at.desc()).limit(5).all()
    return render_template('owner/dashboard.html', user=user, tailor=tailor, active=active, completed=completed, pending=pending, total=total, recent=recent)

@owner_bp.route('/orders')
@web_login_required('owner')
def orders():
    user = db.get_or_404(User, session['user_id'])
    tailor = Tailor.query.filter_by(user_id=user.id).first()
    tab = request.args.get('tab', 'active')
    if tab == 'history':
        items = OrderQueue.query.filter(OrderQueue.tailor_id==tailor.id, OrderQueue.status.in_(['selesai','siap_diambil','rejected'])).order_by(OrderQueue.created_at.desc()).all()
    else:
        items = OrderQueue.query.filter(OrderQueue.tailor_id==tailor.id, OrderQueue.status.notin_(['selesai','siap_diambil','rejected'])).order_by(OrderQueue.created_at.desc()).all()
    return render_template('owner/orders.html', user=user, tailor=tailor, orders=items, tab=tab)

@owner_bp.route('/orders/<int:oid>')
@web_login_required('owner')
def order_detail(oid):
    user = db.get_or_404(User, session['user_id'])
    tailor = Tailor.query.filter_by(user_id=user.id).first()
    order = OrderQueue.query.filter_by(id=oid, tailor_id=tailor.id).first_or_404()
    return render_template('owner/order_detail.html', user=user, tailor=tailor, order=order)

@owner_bp.route('/orders/<int:oid>/update', methods=['POST'])
@web_login_required('owner')
def update_order_status(oid):
    user = db.get_or_404(User, session['user_id'])
    tailor = Tailor.query.filter_by(user_id=user.id).first()
    order = OrderQueue.query.filter_by(id=oid, tailor_id=tailor.id).first_or_404()
    new_status = request.form.get('status', '')
    notes = request.form.get('notes', '')
    if new_status:
        order.status = new_status
        db.session.add(OrderHistory(order_id=order.id, status=new_status, notes=notes or f'Status diubah ke {new_status}'))
        status_labels = {'accepted':'diterima','fitting':'jadwal fitting','diproses':'diproses','dijahit':'sedang dijahit','selesai':'selesai','siap_diambil':'siap diambil','rejected':'ditolak'}
        db.session.add(Notification(user_id=order.customer_id, message=f'Pesanan #{order.queue_number} {status_labels.get(new_status, new_status)}'))
        db.session.commit()
        flash(f'Status pesanan diperbarui ke {new_status}.', 'success')
    return redirect(url_for('owner.order_detail', oid=oid))

@owner_bp.route('/profile', methods=['GET', 'POST'])
@web_login_required('owner')
def profile():
    user = db.get_or_404(User, session['user_id'])
    tailor = Tailor.query.filter_by(user_id=user.id).first()
    if request.method == 'POST':
        if tailor:
            tailor.shop_name = request.form.get('shop_name', tailor.shop_name)
            tailor.address = request.form.get('address', tailor.address)
            tailor.phone = request.form.get('phone', tailor.phone)
            tailor.bio = request.form.get('bio', tailor.bio)
        user.name = request.form.get('name', user.name)
        user.phone = request.form.get('phone', user.phone)
        db.session.commit()
        flash('Profil berhasil diperbarui.', 'success')
        return redirect(url_for('owner.profile'))
    return render_template('owner/profile.html', user=user, tailor=tailor)

@owner_bp.route('/settings', methods=['GET', 'POST'])
@web_login_required('owner')
def settings():
    user = db.get_or_404(User, session['user_id'])
    tailor = Tailor.query.filter_by(user_id=user.id).first()
    if request.method == 'POST':
        for stype in ['permak', 'custom', 'seragam']:
            avail = TailorAvailability.query.filter_by(tailor_id=tailor.id, type=stype).first()
            is_open = request.form.get(f'avail_{stype}') == 'on'
            if avail:
                avail.is_open = is_open
            else:
                db.session.add(TailorAvailability(tailor_id=tailor.id, type=stype, is_open=is_open))
        tailor.status = 'open' if any(request.form.get(f'avail_{t}') == 'on' for t in ['permak','custom','seragam']) else 'close'
        db.session.commit()
        flash('Pengaturan berhasil disimpan.', 'success')
        return redirect(url_for('owner.settings'))
    avails = {a.type: a.is_open for a in (tailor.availability if tailor else [])}
    return render_template('owner/settings.html', user=user, tailor=tailor, avails=avails)
