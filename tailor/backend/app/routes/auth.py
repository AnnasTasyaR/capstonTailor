from flask import Blueprint, request, jsonify, render_template, redirect, url_for, session, flash, current_app
from flask_jwt_extended import create_access_token
from werkzeug.security import generate_password_hash
from app import db, limiter
from app.models.user import User
from app.models.tailor import Tailor, TailorAvailability
from app.utils.email_util import generate_code, send_verification_email
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from datetime import datetime, timedelta
import re

auth_bp = Blueprint('auth', __name__)

# ── Input validators ──────────────────────────────────────────────────────────

_EMAIL_RE    = re.compile(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
_USERNAME_RE = re.compile(r'^[a-zA-Z0-9_]{3,32}$')
_PHONE_RE    = re.compile(r'^[0-9+\-\s]{7,20}$')

def _validate_password(pw: str) -> str | None:
    """Return error message or None if valid."""
    if len(pw) < 8:
        return 'Password minimal 8 karakter'
    if not re.search(r'[A-Za-z]', pw):
        return 'Password harus mengandung huruf'
    if not re.search(r'[0-9]', pw):
        return 'Password harus mengandung angka'
    return None

def _sanitize_str(value: str, max_len: int = 100) -> str:
    """Strip whitespace and truncate to max_len."""
    return value.strip()[:max_len]


# ══════════════════════════════════════════════════════════════════════════════
# API ENDPOINTS (Mobile)
# ══════════════════════════════════════════════════════════════════════════════

@auth_bp.route('/api/auth/login', methods=['POST'])
@limiter.limit("10 per minute; 30 per hour")   # Brute-force protection
def api_login():
    data = request.get_json(silent=True)
    if not data:
        return jsonify({"msg": "Body JSON tidak valid"}), 400

    login_id = _sanitize_str(data.get('login_id', ''), 128)
    password = data.get('password', '')

    if not login_id or not password:
        return jsonify({"msg": "Email/username dan password harus diisi"}), 400

    if len(login_id) > 128 or len(password) > 128:
        return jsonify({"msg": "Input tidak valid"}), 400

    user = User.query.filter(
        (User.email == login_id) | (User.username == login_id)
    ).first()

    # Generic error — don't reveal whether user exists
    if not user or not user.check_password(password):
        return jsonify({"msg": "Email/username atau password salah"}), 401

    if not user.is_active_user:
        return jsonify({"msg": "Akun Anda telah dinonaktifkan"}), 403

    if user.role != 'customer':
        return jsonify({"msg": "Gunakan web untuk login sebagai admin/owner"}), 403

    if not user.email_verified:
        return jsonify({"msg": "Silakan verifikasi email Anda terlebih dahulu"}), 403

    access_token = create_access_token(
        identity=str(user.id),
        additional_claims={"role": user.role, "name": user.name}
    )

    return jsonify({
        "msg": "Login berhasil",
        "token": access_token,
        "user": user.to_dict()
    }), 200


@auth_bp.route('/api/auth/register', methods=['POST'])
@limiter.limit("5 per minute; 20 per hour")
def api_register():
    data = request.get_json(silent=True)
    if not data:
        return jsonify({"msg": "Body JSON tidak valid"}), 400

    name     = _sanitize_str(data.get('name', ''), 100)
    email    = _sanitize_str(data.get('email', ''), 128).lower()
    username = _sanitize_str(data.get('username', ''), 32).lower()
    password = data.get('password', '')
    phone    = _sanitize_str(data.get('phone', ''), 20)

    if not all([name, email, username, password]):
        return jsonify({"msg": "Semua field wajib diisi"}), 400

    # Email format
    if not _EMAIL_RE.match(email):
        return jsonify({"msg": "Format email tidak valid"}), 400

    # Username format
    if not _USERNAME_RE.match(username):
        return jsonify({"msg": "Username hanya boleh huruf, angka, dan underscore (3-32 karakter)"}), 400

    # Phone format
    if phone and not _PHONE_RE.match(phone):
        return jsonify({"msg": "Format nomor telepon tidak valid"}), 400

    # Password strength
    pw_error = _validate_password(password)
    if pw_error:
        return jsonify({"msg": pw_error}), 400

    if User.query.filter_by(email=email).first():
        return jsonify({"msg": "Email sudah terdaftar"}), 409

    if User.query.filter_by(username=username).first():
        return jsonify({"msg": "Username sudah digunakan"}), 409

    user = User(
        name=name, email=email, username=username,
        password_hash=generate_password_hash(password),
        phone=phone, role='customer'
    )
    db.session.add(user)
    db.session.flush()

    code = generate_code()
    user.verification_code = code
    user.verification_code_expires = datetime.utcnow() + timedelta(minutes=5)
    db.session.commit()

    send_verification_email(email, code)

    return jsonify({
        "msg": "Registrasi berhasil! Silakan verifikasi email Anda.",
        "needs_verification": True,
        "email": email,
    }), 201


@auth_bp.route('/api/auth/logout', methods=['POST'])
def api_logout():
    # Stateless JWT — client must discard token
    return jsonify({"msg": "Logout berhasil"}), 200


@auth_bp.route('/api/auth/send-verification', methods=['POST'])
@limiter.limit("3 per minute; 10 per hour")
def api_send_verification():
    data = request.get_json(silent=True)
    if not data:
        return jsonify({"msg": "Body JSON tidak valid"}), 400
    email = _sanitize_str(data.get('email', ''), 128).lower()
    if not email or not _EMAIL_RE.match(email):
        return jsonify({"msg": "Email tidak valid"}), 400
    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify({"msg": "Email tidak terdaftar"}), 404
    if user.email_verified:
        return jsonify({"msg": "Email sudah terverifikasi"}), 400
    code = generate_code()
    user.verification_code = code
    user.verification_code_expires = datetime.utcnow() + timedelta(minutes=5)
    db.session.commit()
    sent = send_verification_email(email, code)
    if not sent and not current_app.config.get('DEBUG', False):
        return jsonify({"msg": "Gagal mengirim email verifikasi"}), 500
    return jsonify({"msg": "Kode verifikasi telah dikirim ke email Anda", "email": email}), 200


@auth_bp.route('/api/auth/verify-email', methods=['POST'])
@limiter.limit("5 per minute; 20 per hour")
def api_verify_email():
    data = request.get_json(silent=True)
    if not data:
        return jsonify({"msg": "Body JSON tidak valid"}), 400
    email = _sanitize_str(data.get('email', ''), 128).lower()
    code = _sanitize_str(data.get('code', ''), 6)
    if not email or not code:
        return jsonify({"msg": "Email dan kode harus diisi"}), 400
    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify({"msg": "Email tidak terdaftar"}), 404
    if user.email_verified:
        access_token = create_access_token(
            identity=str(user.id),
            additional_claims={"role": user.role, "name": user.name},
        )
        return jsonify({
            "msg": "Email sudah terverifikasi",
            "token": access_token, "user": user.to_dict(),
        }), 200
    if user.verification_code is None:
        return jsonify({"msg": "Kode verifikasi belum dikirim"}), 400
    if user.verification_code_expires and user.verification_code_expires < datetime.utcnow():
        return jsonify({"msg": "Kode verifikasi sudah kadaluarsa. Kirim ulang."}), 400
    if user.verification_code != code:
        return jsonify({"msg": "Kode verifikasi salah"}), 400
    user.email_verified = True
    user.verification_code = None
    user.verification_code_expires = None
    db.session.commit()
    access_token = create_access_token(
        identity=str(user.id),
        additional_claims={"role": user.role, "name": user.name},
    )
    return jsonify({
        "msg": "Email berhasil diverifikasi",
        "token": access_token, "user": user.to_dict(),
    }), 200


@auth_bp.route('/api/auth/google', methods=['POST'])
@limiter.limit("10 per minute")
def api_google_login():
    """Verify Google ID token from Flutter app, then login or auto-register."""
    data = request.get_json(silent=True)
    if not data:
        return jsonify({"msg": "Body JSON tidak valid"}), 400

    token = _sanitize_str(data.get('id_token', ''), 4096)
    if not token:
        return jsonify({"msg": "id_token harus diisi"}), 400

    google_client_id = current_app.config.get('GOOGLE_CLIENT_ID', '')
    if not google_client_id:
        return jsonify({"msg": "Konfigurasi Google belum diset di server"}), 500

    try:
        id_info = id_token.verify_oauth2_token(
            token,
            google_requests.Request(),
            google_client_id,
            clock_skew_in_seconds=10,
        )
    except ValueError:
        # Do NOT return str(e) — it can leak token internals
        return jsonify({"msg": "Token Google tidak valid atau kadaluarsa"}), 401

    google_id = id_info.get('sub')
    email     = id_info.get('email', '').strip().lower()
    name      = id_info.get('name', '').strip()[:100]
    picture   = id_info.get('picture', '')

    if not google_id or not email:
        return jsonify({"msg": "Token Google tidak lengkap"}), 400

    user = User.query.filter_by(google_id=google_id).first()

    if user is None:
        user = User.query.filter_by(email=email).first()
        if user:
            if not user.is_active_user:
                return jsonify({"msg": "Akun Anda telah dinonaktifkan"}), 403
            if user.role != 'customer':
                return jsonify({"msg": "Gunakan web untuk login sebagai admin/owner"}), 403
            user.google_id = google_id
            if picture and not user.avatar:
                user.avatar = picture
            db.session.commit()
        else:
            base_username = re.sub(r'[^a-z0-9]', '', email.split('@')[0].lower()) or 'user'
            base_username = base_username[:24]
            username = base_username
            counter  = 1
            while User.query.filter_by(username=username).first():
                username = f"{base_username}{counter}"
                counter += 1

            user = User(
                name=name or email.split('@')[0][:100],
                email=email, username=username,
                google_id=google_id,
                avatar=picture or None,
                role='customer',
            )
            db.session.add(user)
            db.session.commit()
    else:
        if not user.is_active_user:
            return jsonify({"msg": "Akun Anda telah dinonaktifkan"}), 403
        if user.role != 'customer':
            return jsonify({"msg": "Gunakan web untuk login sebagai admin/owner"}), 403

    if not user.email_verified:
        code = generate_code()
        user.verification_code = code
        user.verification_code_expires = datetime.utcnow() + timedelta(minutes=5)
        db.session.commit()
        send_verification_email(email, code)
        return jsonify({
            "msg": "Verifikasi email diperlukan",
            "needs_verification": True,
            "email": email,
        }), 200

    access_token = create_access_token(
        identity=str(user.id),
        additional_claims={"role": user.role, "name": user.name},
    )

    return jsonify({
        "msg": "Login dengan Google berhasil",
        "token": access_token,
        "user": user.to_dict(),
    }), 200


# ══════════════════════════════════════════════════════════════════════════════
# WEB ROUTES (Admin + Owner)
# ══════════════════════════════════════════════════════════════════════════════

@auth_bp.route('/login', methods=['GET', 'POST'])
@limiter.limit("20 per minute", methods=["POST"])
def web_login():
    if session.get('user_id'):
        role = session.get('role')
        if role == 'admin':
            return redirect(url_for('admin.dashboard'))
        elif role == 'owner':
            return redirect(url_for('owner.dashboard'))

    if request.method == 'POST':
        login_id = _sanitize_str(request.form.get('login_id', ''), 128)
        password = request.form.get('password', '')

        if not login_id or not password:
            flash('Semua field harus diisi.', 'danger')
            return render_template('auth/login.html')

        user = User.query.filter(
            (User.email == login_id) | (User.username == login_id)
        ).first()

        if not user or not user.check_password(password):
            flash('Email/username atau password salah.', 'danger')
            return render_template('auth/login.html')

        if not user.is_active_user:
            flash('Akun Anda telah dinonaktifkan.', 'danger')
            return render_template('auth/login.html')

        if user.role not in ('admin', 'owner'):
            flash('Gunakan aplikasi mobile untuk login sebagai customer.', 'warning')
            return render_template('auth/login.html')

        # Regenerate session to prevent session fixation
        session.clear()
        session['user_id']   = user.id
        session['role']      = user.role
        session['user_name'] = user.name
        session.permanent    = True

        if user.role == 'admin':
            return redirect(url_for('admin.dashboard'))
        return redirect(url_for('owner.dashboard'))

    return render_template('auth/login.html')


@auth_bp.route('/register', methods=['GET', 'POST'])
@limiter.limit("10 per minute", methods=["POST"])
def web_register():
    if request.method == 'POST':
        name             = _sanitize_str(request.form.get('name', ''), 100)
        email            = _sanitize_str(request.form.get('email', ''), 128).lower()
        username         = _sanitize_str(request.form.get('username', ''), 32).lower()
        password         = request.form.get('password', '')
        confirm_password = request.form.get('confirm_password', '')
        phone            = _sanitize_str(request.form.get('phone', ''), 20)
        shop_name        = _sanitize_str(request.form.get('shop_name', ''), 150)
        address          = _sanitize_str(request.form.get('address', ''), 300)

        if not all([name, email, username, password, shop_name]):
            flash('Semua field wajib harus diisi.', 'danger')
            return render_template('auth/register.html')

        if not _EMAIL_RE.match(email):
            flash('Format email tidak valid.', 'danger')
            return render_template('auth/register.html')

        if not _USERNAME_RE.match(username):
            flash('Username hanya boleh huruf, angka, dan underscore (3-32 karakter).', 'danger')
            return render_template('auth/register.html')

        if password != confirm_password:
            flash('Password tidak cocok.', 'danger')
            return render_template('auth/register.html')

        pw_error = _validate_password(password)
        if pw_error:
            flash(pw_error, 'danger')
            return render_template('auth/register.html')

        if User.query.filter_by(email=email).first():
            flash('Email sudah terdaftar.', 'danger')
            return render_template('auth/register.html')

        if User.query.filter_by(username=username).first():
            flash('Username sudah digunakan.', 'danger')
            return render_template('auth/register.html')

        user = User(
            name=name, email=email, username=username,
            password_hash=generate_password_hash(password),
            phone=phone, role='owner'
        )
        db.session.add(user)
        db.session.flush()

        tailor = Tailor(
            user_id=user.id, shop_name=shop_name,
            address=address, phone=phone
        )
        db.session.add(tailor)
        db.session.flush()

        for stype in ['permak', 'custom', 'seragam']:
            db.session.add(TailorAvailability(tailor_id=tailor.id, type=stype, is_open=True))

        db.session.commit()
        flash('Registrasi berhasil! Silakan login.', 'success')
        return redirect(url_for('auth.web_login'))

    return render_template('auth/register.html')


@auth_bp.route('/logout')
def web_logout():
    session.clear()
    flash('Anda telah logout.', 'info')
    return redirect(url_for('auth.web_login'))
