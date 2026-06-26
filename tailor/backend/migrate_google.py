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
    # Check if google_id column exists
    result = conn.execute(
        text("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=:db AND TABLE_NAME='users' AND COLUMN_NAME='google_id'"),
        {'db': DB_NAME}
    )
    count = result.scalar()
    print(f'google_id column exists: {count > 0}')

    if count == 0:
        conn.execute(text('ALTER TABLE users ADD COLUMN google_id VARCHAR(128) NULL'))
        print('Added google_id column')
        
        # Add unique index separately (safer)
        try:
            conn.execute(text('ALTER TABLE users ADD UNIQUE INDEX idx_users_google_id (google_id)'))
            print('Added unique index on google_id')
        except Exception as e:
            print(f'Index may already exist: {e}')
        
        # Make password_hash nullable
        conn.execute(text('ALTER TABLE users MODIFY COLUMN password_hash VARCHAR(255) NULL'))
        print('password_hash is now nullable')
        
        # Make username nullable
        conn.execute(text('ALTER TABLE users MODIFY COLUMN username VARCHAR(80) NULL'))
        print('username is now nullable')
        
        conn.commit()
        print('Migration berhasil!')
    else:
        print('Kolom google_id sudah ada. Pastikan password_hash dan username sudah nullable.')
        # Ensure nullable anyway
        try:
            conn.execute(text('ALTER TABLE users MODIFY COLUMN password_hash VARCHAR(255) NULL'))
            conn.execute(text('ALTER TABLE users MODIFY COLUMN username VARCHAR(80) NULL'))
            conn.commit()
            print('Kolom password_hash dan username dipastikan nullable.')
        except Exception as e:
            print(f'Modify error (mungkin sudah nullable): {e}')

print('Done.')
