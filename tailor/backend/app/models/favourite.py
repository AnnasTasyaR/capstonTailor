from app import db
from datetime import datetime


class Favourite(db.Model):
    __tablename__ = 'favourites'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    tailor_id = db.Column(db.Integer, db.ForeignKey('tailors.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    __table_args__ = (db.UniqueConstraint('user_id', 'tailor_id', name='uq_user_tailor'),)

    # Relationship
    tailor = db.relationship('Tailor', lazy=True)
    user = db.relationship('User', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'tailor_id': self.tailor_id,
            'tailor': self.tailor.to_dict() if self.tailor else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }
