import os
from datetime import timedelta
from dotenv import load_dotenv

# Load .env automatically so secrets are always available
load_dotenv()


def _require_env(key: str, fallback: str | None = None) -> str:
    """Return env var value. Warn loudly if using fallback in non-dev mode."""
    value = os.getenv(key)
    if value:
        return value
    if fallback is not None:
        import warnings
        warnings.warn(
            f"[SECURITY] Environment variable '{key}' is not set. "
            f"Using insecure fallback. Set it in .env before deploying!",
            stacklevel=2,
        )
        return fallback
    raise RuntimeError(f"Required environment variable '{key}' is missing.")


class Config:
    # ── Flask Core ────────────────────────────────────────────────────────
    SECRET_KEY = _require_env('FLASK_SECRET_KEY', 'change-me-in-production-32chars!')
    DEBUG = os.getenv('FLASK_DEBUG', 'false').lower() == 'true'

    # ── Session Security ──────────────────────────────────────────────────
    SESSION_COOKIE_SECURE   = not DEBUG          # HTTPS only in production
    SESSION_COOKIE_HTTPONLY = True               # JS cannot access cookie
    SESSION_COOKIE_SAMESITE = 'Lax'             # CSRF mitigation
    PERMANENT_SESSION_LIFETIME = timedelta(hours=8)

    # ── Database ──────────────────────────────────────────────────────────
    DB_HOST     = os.getenv('DB_HOST',     'localhost')
    DB_PORT     = os.getenv('DB_PORT',     '3306')
    DB_NAME     = os.getenv('DB_NAME',     'tailorlink_db')
    DB_USER     = os.getenv('DB_USER',     'root')
    DB_PASSWORD = os.getenv('DB_PASSWORD', '')

    SQLALCHEMY_DATABASE_URI = (
        f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_pre_ping': True,
        'pool_recycle': 300,
    }

    # ── JWT ───────────────────────────────────────────────────────────────
    JWT_SECRET_KEY            = _require_env('JWT_SECRET_KEY', 'change-jwt-secret-in-production!')
    JWT_ACCESS_TOKEN_EXPIRES  = timedelta(hours=8)    # 8h (reduced from 24h)
    JWT_ALGORITHM             = 'HS256'
    JWT_TOKEN_LOCATION        = ['headers']
    JWT_HEADER_NAME           = 'Authorization'
    JWT_HEADER_TYPE           = 'Bearer'

    # ── File Upload ───────────────────────────────────────────────────────
    UPLOAD_FOLDER      = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'static', 'uploads')
    MAX_CONTENT_LENGTH = 5 * 1024 * 1024   # 5 MB (reduced from 16MB)
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp'}
    ALLOWED_MIMETYPES  = {'image/png', 'image/jpeg', 'image/webp'}

    # ── AI / Google ───────────────────────────────────────────────────────
    GEMINI_API_KEY  = os.getenv('GEMINI_API_KEY', '')
    GOOGLE_CLIENT_ID = os.getenv('GOOGLE_CLIENT_ID', '')

    # ── Rate Limiting ─────────────────────────────────────────────────────
    RATELIMIT_STORAGE_URL      = 'memory://'
    RATELIMIT_DEFAULT          = '200 per hour'
    RATELIMIT_HEADERS_ENABLED  = True
