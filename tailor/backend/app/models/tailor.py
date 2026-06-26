from app import db
from datetime import datetime


class Tailor(db.Model):
    __tablename__ = 'tailors'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, unique=True)
    shop_name = db.Column(db.String(150), nullable=False)
    address = db.Column(db.Text, nullable=True)
    phone = db.Column(db.String(20), nullable=True)
    rating = db.Column(db.Float, default=0.0)
    status = db.Column(db.String(20), default='open')  # open, close
    bio = db.Column(db.Text, nullable=True)
    shop_image = db.Column(db.String(255), nullable=True)
    is_verified = db.Column(db.Boolean, default=False)
    is_suspended = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    availability = db.relationship('TailorAvailability', backref='tailor', lazy=True)
    orders = db.relationship('OrderQueue', backref='tailor', lazy=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'shop_name': self.shop_name,
            'address': self.address,
            'phone': self.phone,
            'rating': self.rating,
            'status': self.status,
            'bio': self.bio,
            'shop_image': self.shop_image,
            'is_verified': self.is_verified,
            'is_suspended': self.is_suspended,
            'availability': [a.to_dict() for a in self.availability] if self.availability else [],
            'owner_name': self.user.name if self.user else None,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class TailorAvailability(db.Model):
    __tablename__ = 'tailor_availability'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    tailor_id = db.Column(db.Integer, db.ForeignKey('tailors.id'), nullable=False)
    type = db.Column(db.String(30), nullable=False)  # permak, custom, seragam
    is_open = db.Column(db.Boolean, default=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'tailor_id': self.tailor_id,
            'type': self.type,
            'is_open': self.is_open
        }
