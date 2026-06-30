"""Migration: Add item_type column to order_queues table."""
import pymysql
import os
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

host = os.getenv('MYSQL_HOST', 'localhost')
user = os.getenv('MYSQL_USER', 'root')
password = os.getenv('MYSQL_PASSWORD', '')
database = os.getenv('MYSQL_DATABASE', 'tailorlink_db')

conn = pymysql.connect(host=host, user=user, password=password, database=database)
cur = conn.cursor()

try:
    cur.execute("""
        ALTER TABLE order_queues
        ADD COLUMN item_type varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL
        COMMENT 'kemeja, jaket, batik, dll'
        AFTER `type`
    """)
    print("OK: item_type column added to order_queues")
except Exception as e:
    if "Duplicate column" in str(e):
        print("OK: item_type already exists")
    else:
        print(f"Error: {e}")

conn.commit()
cur.close()
conn.close()
