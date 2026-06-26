from functools import wraps
from flask import session, redirect, url_for, flash, jsonify
from flask_jwt_extended import verify_jwt_in_request, get_jwt


def role_required(*roles):
    """JWT role guard for API endpoints (mobile). Never leaks internal error detail."""
    def wrapper(fn):
        @wraps(fn)
        def decorated(*args, **kwargs):
            try:
                verify_jwt_in_request()
                claims = get_jwt()
                if claims.get("role") not in roles:
                    return jsonify({"msg": "Akses ditolak."}), 403
                return fn(*args, **kwargs)
            except Exception:
                # Do NOT expose str(e) — it can leak token details / internals
                return jsonify({"msg": "Autentikasi diperlukan."}), 401
        return decorated
    return wrapper


def web_login_required(*roles):
    """Session-based role guard for web routes (admin/owner)."""
    def wrapper(fn):
        @wraps(fn)
        def decorated(*args, **kwargs):
            user_id   = session.get('user_id')
            user_role = session.get('role')
            if not user_id:
                flash('Silakan login terlebih dahulu.', 'warning')
                return redirect(url_for('auth.web_login'))
            if roles and user_role not in roles:
                flash('Anda tidak memiliki akses ke halaman ini.', 'danger')
                return redirect(url_for('auth.web_login'))
            return fn(*args, **kwargs)
        return decorated
    return wrapper
