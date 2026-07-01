"""
APScheduler: daily ETL from MySQL → MongoDB analytics collections.
Runs at 00:00 every day. Also runs once on startup to seed initial data.
"""
import sys
from datetime import datetime, timedelta
from apscheduler.schedulers.background import BackgroundScheduler
from sqlalchemy import func
from app import db

scheduler = BackgroundScheduler()


def _now():
    return datetime.utcnow()


def _build_populer(app, mongo_db):
    """Group orders by item_type (COALESCE with type), count, ordered desc."""
    from app.models.order import OrderQueue
    from sqlalchemy import literal
    with app.app_context():
        group_col = func.coalesce(OrderQueue.item_type, OrderQueue.type, literal('tailor'))
        rows = db.session.query(
            group_col.label('group_key'),
            func.count(OrderQueue.id).label('order_count'),
        ).group_by(group_col).order_by(
            func.count(OrderQueue.id).desc()
        ).limit(50).all()

    docs = []
    for key, count in rows:
        label = key.capitalize() if key and key != 'tailor' else 'Tailor'
        docs.append({
            'title': label,
            'category': label,
            'historical_sold': count,
            'price': 0,
            'updated_at': _now(),
        })
    mongo_db['populer'].delete_many({})
    if docs:
        mongo_db['populer'].insert_many(docs)
    print(f'[SCHEDULER] Populer: {len(docs)} item types synced', file=sys.stderr)


def _build_tren(app, mongo_db):
    """Daily order count for last 30 days (UI shows 7, but we store 30 for flexibility)."""
    from app.models.order import OrderQueue
    with app.app_context():
        today = _now().date()
        rows = dict(
            db.session.query(
                func.date(OrderQueue.created_at).label('tgl'),
                func.count(OrderQueue.id).label('jml')
            ).filter(
                func.date(OrderQueue.created_at) >= today - timedelta(days=29)
            ).group_by(
                func.date(OrderQueue.created_at)
            ).all()
        )

    docs = []
    for i in range(29, -1, -1):
        d = today - timedelta(days=i)
        ds = str(d)
        docs.append({
            'date': ds,
            'orders': rows.get(d, 0),
        })
    mongo_db['tren'].delete_many({})
    mongo_db['tren'].insert_many(docs)
    print(f'[SCHEDULER] Tren: {len(docs)} days synced', file=sys.stderr)


def _build_rating(app, mongo_db):
    """Group completed orders by item_type with avg Tailor.rating."""
    from app.models.order import OrderQueue
    from app.models.tailor import Tailor
    from sqlalchemy import literal
    with app.app_context():
        group_col = func.coalesce(OrderQueue.item_type, OrderQueue.type, literal('tailor'))
        rows = db.session.query(
            group_col.label('group_key'),
            func.avg(Tailor.rating).label('avg_rating'),
            func.count(OrderQueue.id).label('order_count'),
        ).join(Tailor, OrderQueue.tailor_id == Tailor.id
        ).filter(
            OrderQueue.status.in_(['selesai', 'siap_diambil']),
            Tailor.is_suspended == False,
        ).group_by(group_col).order_by(
            func.avg(Tailor.rating).desc(),
            func.count(OrderQueue.id).desc()
        ).limit(50).all()

    docs = []
    for key, avg_rating, order_count in rows:
        label = key.capitalize() if key and key != 'tailor' else 'Tailor'
        docs.append({
            'title': label,
            'category': label,
            'rating_avg': round(float(avg_rating), 2) if avg_rating else 0,
            'rating_count': order_count,
            'updated_at': _now(),
        })
    mongo_db['rating'].delete_many({})
    if docs:
        mongo_db['rating'].insert_many(docs)
    print(f'[SCHEDULER] Rating: {len(docs)} item types synced', file=sys.stderr)


def build_all(app, mongo_db):
    """Run all ETL jobs immediately (used on startup and scheduled runs)."""
    print('[SCHEDULER] Running analytics ETL...', file=sys.stderr)
    try:
        _build_populer(app, mongo_db)
        _build_tren(app, mongo_db)
        _build_rating(app, mongo_db)
        print('[SCHEDULER] ETL complete.', file=sys.stderr)
    except Exception as e:
        print(f'[SCHEDULER] ETL failed: {e}', file=sys.stderr)


def start_scheduler(app, mongo_db):
    """Start APScheduler with daily job at 00:00."""
    # Run once on startup
    build_all(app, mongo_db)

    # Schedule daily at midnight
    scheduler.add_job(
        func=build_all,
        trigger='cron',
        hour=0,
        minute=0,
        args=[app, mongo_db],
        id='etl_daily',
        name='Daily analytics ETL',
        replace_existing=True,
    )
    scheduler.start()
    print('[SCHEDULER] Started. Next run at 00:00 UTC.', file=sys.stderr)


def stop_scheduler():
    if scheduler.running:
        scheduler.shutdown(wait=False)
