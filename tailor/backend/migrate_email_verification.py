import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '3306')
DB_NAME = os.getenv('DB_NAME', 'tailorlink_db')
DB_USER = os.getenv('DB_USER', 'root')
DB_PASSWORD = os.getenv('DB_PASSWORD', '')

engine = create_engine(f'mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}')

with engine.connect() as conn:
    columns = ['email_verified', 'verification_code', 'verification_code_expires']
    existing = set()
    result = conn.execute(
        text("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=:db AND TABLE_NAME='users'"),
        {'db': DB_NAME}
    )
    for row in result:
        existing.add(row[0])

    if 'email_verified' not in existing:
        conn.execute(text("ALTER TABLE users ADD COLUMN email_verified TINYINT(1) NOT NULL DEFAULT 0"))
        print('Added email_verified column')
    else:
        print('email_verified already exists')

    if 'verification_code' not in existing:
        conn.execute(text("ALTER TABLE users ADD COLUMN verification_code VARCHAR(6) NULL"))
        print('Added verification_code column')
    else:
        print('verification_code already exists')

    if 'verification_code_expires' not in existing:
        conn.execute(text("ALTER TABLE users ADD COLUMN verification_code_expires DATETIME NULL"))
        print('Added verification_code_expires column')
    else:
        print('verification_code_expires already exists')

    conn.commit()
    print('Migration berhasil!')

print('Done.')
