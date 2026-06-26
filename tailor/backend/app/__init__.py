from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_login import LoginManager
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import os

db           = SQLAlchemy()
jwt          = JWTManager()
login_manager = LoginManager()
limiter      = Limiter(
    key_func=get_remote_address,
    default_limits=["200 per hour", "50 per minute"],
    storage_uri="memory://",
)


def create_app():
    app = Flask(__name__)

    # Load config
    from app.config import Config
    app.config.from_object(Config)

    # Ensure upload directory exists
    os.makedirs(app.config.get('UPLOAD_FOLDER', 'static/uploads'), exist_ok=True)

    # ── Initialize extensions ─────────────────────────────────────────────
    db.init_app(app)
    jwt.init_app(app)
    limiter.init_app(app)

    # ── CORS — only allow mobile client & web dashboard ───────────────────
    # In development we allow all; in production set ALLOWED_ORIGINS in .env
    allowed_origins = os.getenv('ALLOWED_ORIGINS', '*').split(',')
    CORS(app, resources={
        r"/api/*": {
            "origins": allowed_origins,
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": [
                "Authorization", "Content-Type",
                "ngrok-skip-browser-warning", "X-Requested-With",
            ],
            "expose_headers": ["X-RateLimit-Limit", "X-RateLimit-Remaining"],
            "max_age": 600,
        }
    })

    login_manager.init_app(app)
    login_manager.login_view = 'auth.web_login'
    login_manager.login_message = 'Silakan login terlebih dahulu.'
    login_manager.login_message_category = 'warning'

    # ── Security Headers ──────────────────────────────────────────────────
    @app.after_request
    def set_security_headers(response):
        # Prevent clickjacking
        response.headers['X-Frame-Options'] = 'DENY'
        # Prevent MIME sniffing
        response.headers['X-Content-Type-Options'] = 'nosniff'
        # Basic XSS protection for older browsers
        response.headers['X-XSS-Protection'] = '1; mode=block'
        # Referrer policy
        response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        # Feature policy
        response.headers['Permissions-Policy'] = (
            'geolocation=(), microphone=(), camera=()'
        )
        # Content Security Policy (web dashboard)
        if not response.content_type.startswith('application/json'):
            response.headers['Content-Security-Policy'] = (
                "default-src 'self'; "
                "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; "
                "font-src 'self' https://fonts.gstatic.com; "
                "script-src 'self' 'unsafe-inline'; "
                "img-src 'self' data: https:; "
                "connect-src 'self';"
            )
        # Remove server signature
        response.headers.pop('Server', None)
        return response

    # ── JWT error handlers (no internal detail leakage) ───────────────────
    @jwt.expired_token_loader
    def expired_token_callback(jwt_header, jwt_payload):
        return jsonify({"msg": "Token telah kadaluarsa. Silakan login ulang."}), 401

    @jwt.invalid_token_loader
    def invalid_token_callback(error):
        return jsonify({"msg": "Token tidak valid."}), 401

    @jwt.unauthorized_loader
    def missing_token_callback(error):
        return jsonify({"msg": "Token diperlukan untuk akses ini."}), 401

    @jwt.revoked_token_loader
    def revoked_token_callback(jwt_header, jwt_payload):
        return jsonify({"msg": "Token telah dicabut."}), 401

    # ── Global error handlers (no stack traces in production) ─────────────
    @app.errorhandler(400)
    def bad_request(e):
        return jsonify({"msg": "Permintaan tidak valid."}), 400

    @app.errorhandler(404)
    def not_found(e):
        return jsonify({"msg": "Sumber daya tidak ditemukan."}), 404

    @app.errorhandler(405)
    def method_not_allowed(e):
        return jsonify({"msg": "Metode tidak diizinkan."}), 405

    @app.errorhandler(413)
    def request_entity_too_large(e):
        return jsonify({"msg": "File terlalu besar. Maksimum 5MB."}), 413

    @app.errorhandler(429)
    def ratelimit_handler(e):
        return jsonify({"msg": "Terlalu banyak permintaan. Coba lagi nanti."}), 429

    @app.errorhandler(500)
    def internal_error(e):
        return jsonify({"msg": "Terjadi kesalahan internal. Hubungi administrator."}), 500

    # ── Import models ─────────────────────────────────────────────────────
    from app.models.user import User
    from app.models.tailor import Tailor, TailorAvailability
    from app.models.order import OrderQueue, OrderHistory
    from app.models.notification import Notification
    from app.models.favourite import Favourite

    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(int(user_id))

    # ── Register blueprints ───────────────────────────────────────────────
    from app.routes.auth import auth_bp
    from app.routes.customer import customer_bp
    from app.routes.owner import owner_bp
    from app.routes.admin import admin_bp
    from app.routes.ai_analysis import ai_bp
    from app.routes.informasi import informasi_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(customer_bp)
    app.register_blueprint(owner_bp)
    app.register_blueprint(admin_bp)
    app.register_blueprint(ai_bp)
    app.register_blueprint(informasi_bp)

    # ── Create tables & default admin ─────────────────────────────────────
    with app.app_context():
        db.create_all()

        admin = User.query.filter_by(username='admin').first()
        if not admin:
            from werkzeug.security import generate_password_hash
            import secrets
            # Generate a strong random password if not set via env
            default_pass = os.getenv('ADMIN_DEFAULT_PASSWORD', secrets.token_urlsafe(16))
            admin = User(
                name='Administrator',
                email='admin@jahitln.com',
                username='admin',
                password_hash=generate_password_hash(default_pass),
                phone='08123456789',
                role='admin'
            )
            db.session.add(admin)
            db.session.commit()
            if not os.getenv('ADMIN_DEFAULT_PASSWORD'):
                print(f"\n{'='*60}")
                print(f"[ADMIN] Default admin created.")
                print(f"[ADMIN] Username : admin")
                print(f"[ADMIN] Password : {default_pass}")
                print(f"[ADMIN] IMPORTANT: Change this password immediately!")
                print(f"{'='*60}\n")

    # ── Root redirect ─────────────────────────────────────────────────────
    @app.route('/')
    def index():
        from flask import redirect, url_for
        return redirect(url_for('auth.web_login'))

    return app
