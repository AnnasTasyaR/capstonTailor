from app import db
from datetime import datetime


class OrderQueue(db.Model):
    __tablename__ = 'order_queues'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    customer_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    tailor_id = db.Column(db.Integer, db.ForeignKey('tailors.id'), nullable=False)
    type = db.Column(db.String(30), nullable=False)  # permak, custom, seragam
    complexity = db.Column(db.String(20), nullable=True)  # simple, medium, complex
    status = db.Column(db.String(30), default='pending')
    # pending, accepted, fitting, diproses, dijahit, selesai, siap_diambil, rejected
    design_image = db.Column(db.String(255), nullable=True)
    design_notes = db.Column(db.Text, nullable=True)
    estimated_done = db.Column(db.DateTime, nullable=True)
    fitting_date = db.Column(db.DateTime, nullable=True)
    queue_number = db.Column(db.Integer, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    customer = db.relationship('User', backref='orders', lazy=True)
    history = db.relationship('OrderHistory', backref='order', lazy=True, order_by='OrderHistory.changed_at')
    
    def to_dict(self):
        return {
            'id': self.id,
            'customer_id': self.customer_id,
            'tailor_id': self.tailor_id,
            'type': self.type,
            'complexity': self.complexity,
            'status': self.status,
            'design_image': self.design_image,
            'design_notes': self.design_notes,
            'estimated_done': self.estimated_done.isoformat() if self.estimated_done else None,
            'fitting_date': self.fitting_date.isoformat() if self.fitting_date else None,
            'queue_number': self.queue_number,
            'customer_name': self.customer.name if self.customer else None,
            'tailor_name': self.tailor.shop_name if self.tailor else None,
            'history': [h.to_dict() for h in self.history] if self.history else [],
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class OrderHistory(db.Model):
    __tablename__ = 'order_history'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    order_id = db.Column(db.Integer, db.ForeignKey('order_queues.id'), nullable=False)
    status = db.Column(db.String(30), nullable=False)
    changed_at = db.Column(db.DateTime, default=datetime.utcnow)
    notes = db.Column(db.Text, nullable=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'order_id': self.order_id,
            'status': self.status,
            'changed_at': self.changed_at.isoformat() if self.changed_at else None,
            'notes': self.notes
        }
