from pymongo import MongoClient, database as mongo_database

mongo_client: MongoClient | None = None
mongo_db_obj: mongo_database.Database | None = None


def init_mongo(uri: str, db_name: str):
    global mongo_client, mongo_db_obj
    mongo_client = MongoClient(uri, serverSelectionTimeoutMS=5000)
    mongo_client.admin.command('ping')
    mongo_db_obj = mongo_client[db_name]
    # Seed data: scrape Carousell + generate simulasi
    try:
        from app.scraper import seed_data
        seed_data(mongo_db_obj)
    except Exception as e:
        print(f'[MONGO] Seed gagal: {e}', file=__import__('sys').stderr)
    return mongo_db_obj


def get_db():
    return mongo_db_obj


def close_mongo():
    global mongo_client, mongo_db_obj
    if mongo_client:
        mongo_client.close()
        mongo_client = None
        mongo_db_obj = None
