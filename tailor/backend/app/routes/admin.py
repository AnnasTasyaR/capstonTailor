from flask import Blueprint, render_template, request, redirect, url_for, flash, session
from app import db
from app.models.user import User
from app.models.tailor import Tailor
from app.models.order import OrderQueue
from app.middleware.jwt_guard import web_login_required

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')

@admin_bp.route('/dashboard')
@web_login_required('admin')
def dashboard():
    total_users = User.query.count()
    total_tailors = Tailor.query.count()
    total_orders = OrderQueue.query.count()
    total_customers = User.query.filter_by(role='customer').count()
    pending_orders = OrderQueue.query.filter_by(status='pending').count()
    completed_orders = OrderQueue.query.filter(OrderQueue.status.in_(['selesai','siap_diambil'])).count()
    recent_orders = OrderQueue.query.order_by(OrderQueue.created_at.desc()).limit(10).all()
    return render_template('admin/dashboard.html', total_users=total_users, total_tailors=total_tailors,
        total_orders=total_orders, total_customers=total_customers, pending_orders=pending_orders,
        completed_orders=completed_orders, recent_orders=recent_orders)

@admin_bp.route('/users')
@web_login_required('admin')
def users():
    role_filter = request.args.get('role', '')
    query = User.query
    if role_filter:
        query = query.filter_by(role=role_filter)
    all_users = query.order_by(User.created_at.desc()).all()
    return render_template('admin/users.html', users=all_users, role_filter=role_filter)

@admin_bp.route('/users/<int:uid>/toggle', methods=['POST'])
@web_login_required('admin')
def toggle_user(uid):
    user = db.get_or_404(User, uid)
    if user.role == 'admin':
        flash('Tidak dapat menonaktifkan admin.', 'danger')
    else:
        user.is_active_user = not user.is_active_user
        db.session.commit()
        status = 'diaktifkan' if user.is_active_user else 'dinonaktifkan'
        flash(f'User {user.name} berhasil {status}.', 'success')
    return redirect(url_for('admin.users'))

@admin_bp.route('/users/<int:uid>/delete', methods=['POST'])
@web_login_required('admin')
def delete_user(uid):
    user = db.get_or_404(User, uid)
    if user.role == 'admin':
        flash('Tidak dapat menghapus admin.', 'danger')
    else:
        db.session.delete(user)
        db.session.commit()
        flash(f'User {user.name} berhasil dihapus.', 'success')
    return redirect(url_for('admin.users'))

@admin_bp.route('/tailors')
@web_login_required('admin')
def tailors():
    all_tailors = Tailor.query.order_by(Tailor.created_at.desc()).all()
    return render_template('admin/tailors.html', tailors=all_tailors)

@admin_bp.route('/tailors/<int:tid>/verify', methods=['POST'])
@web_login_required('admin')
def verify_tailor(tid):
    tailor = db.get_or_404(Tailor, tid)
    tailor.is_verified = True
    db.session.commit()
    flash(f'{tailor.shop_name} berhasil diverifikasi.', 'success')
    return redirect(url_for('admin.tailors'))

@admin_bp.route('/tailors/<int:tid>/suspend', methods=['POST'])
@web_login_required('admin')
def suspend_tailor(tid):
    tailor = db.get_or_404(Tailor, tid)
    tailor.is_suspended = not tailor.is_suspended
    db.session.commit()
    status = 'disuspend' if tailor.is_suspended else 'diaktifkan kembali'
    flash(f'{tailor.shop_name} berhasil {status}.', 'success')
    return redirect(url_for('admin.tailors'))

@admin_bp.route('/orders')
@web_login_required('admin')
def orders():
    status_filter = request.args.get('status', '')
    query = OrderQueue.query
    if status_filter:
        query = query.filter_by(status=status_filter)
    all_orders = query.order_by(OrderQueue.created_at.desc()).all()
    return render_template('admin/orders.html', orders=all_orders, status_filter=status_filter)
