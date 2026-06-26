from app import db
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime


class User(UserMixin, db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    username = db.Column(db.String(80), unique=True, nullable=True)  # nullable for Google users
    password_hash = db.Column(db.String(255), nullable=True)          # nullable for Google-only users
    google_id = db.Column(db.String(128), unique=True, nullable=True) # Google OAuth user identifier
    phone = db.Column(db.String(20), nullable=True)
    role = db.Column(db.String(20), nullable=False, default='customer')  # admin, owner, customer
    avatar = db.Column(db.String(255), nullable=True)
    is_active_user = db.Column(db.Boolean, default=True)
    email_verified = db.Column(db.Boolean, default=False)
    verification_code = db.Column(db.String(6), nullable=True)
    verification_code_expires = db.Column(db.DateTime, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    tailor = db.relationship('Tailor', backref='user', uselist=False, lazy=True)
    notifications = db.relationship('Notification', backref='user', lazy=True)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        if not self.password_hash:
            return False
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'username': self.username,
            'phone': self.phone,
            'role': self.role,
            'avatar': self.avatar,
            'is_active': self.is_active_user,
            'email_verified': self.email_verified,
            'google_id': self.google_id,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
