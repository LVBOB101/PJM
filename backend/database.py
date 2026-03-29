import hashlib
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from urllib.parse import urlparse

# 1. ตั้งค่าการเชื่อมต่อ
DATABASE_URL = os.getenv('DATABASE_URL')

if DATABASE_URL:
    # Parse DATABASE_URL สำหรับ Docker/Production
    parsed = urlparse(DATABASE_URL)
    DB_CONFIG = {
        "host": parsed.hostname,
        "database": parsed.path.lstrip('/'),
        "user": parsed.username,
        "password": parsed.password,
        "port": parsed.port or 5432
    }
else:
    # Local development config
    DB_CONFIG = {
        "host": "localhost",
        "database": "parking_db",
        "user": "postgres",
        "password": "1234",
        "port": 5432
    }

def get_connection():
    """สร้างการเชื่อมต่อกับ PostgreSQL"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"❌ Error connecting to database: {e}")
        return None


def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode('utf-8')).hexdigest()


def init_db():
    """สร้างตารางเริ่มต้น (รันแค่ครั้งเดียวหรือรันตอนเริ่มระบบ)"""
    camera_query = """
    CREATE TABLE IF NOT EXISTS cameras (
        id SERIAL PRIMARY KEY,
        camera_name VARCHAR(100) NOT NULL,
        ip_address VARCHAR(50) NOT NULL,
        username VARCHAR(100) NOT NULL,
        password VARCHAR(100) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """

    user_query = """
    CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(256) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """

    conn = get_connection()
    if conn:
        cur = conn.cursor()
        cur.execute(camera_query)
        cur.execute(user_query)
        conn.commit()
        cur.close()
        conn.close()
        print("✅ Database initialized successfully")


# ฟังก์ชันช่วยเหลือสำหรับ API
def add_camera_to_db(name, ip, user, pw):
    conn = get_connection()
    if conn:
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO cameras (camera_name, ip_address, username, password) VALUES (%s, %s, %s, %s)",
            (name, ip, user, pw)
        )
        conn.commit()
        cur.close()
        conn.close()
        return True
    return False


def get_all_cameras():
    conn = get_connection()
    if conn:
        # ใช้ RealDictCursor เพื่อให้ผลลัพธ์ออกมาเป็น Dictionary (คล้าย JSON)
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute("SELECT * FROM cameras ORDER BY created_at DESC")
        rows = cur.fetchall()
        cur.close()
        conn.close()
        return rows
    return []


def create_user(username: str, password: str) -> bool:
    conn = get_connection()
    if not conn:
        return False
    try:
        password_hash = hash_password(password)
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO users (username, password_hash) VALUES (%s, %s)",
            (username, password_hash),
        )
        conn.commit()
        cur.close()
        conn.close()
        return True
    except psycopg2.IntegrityError:
        conn.rollback()
        cur.close()
        conn.close()
        return False
    except Exception as e:
        print(f"Error creating user: {e}")
        conn.rollback()
        cur.close()
        conn.close()
        return False


def authenticate_user(username: str, password: str) -> bool:
    conn = get_connection()
    if not conn:
        return False
    try:
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute("SELECT password_hash FROM users WHERE username=%s", (username,))
        user = cur.fetchone()
        cur.close()
        conn.close()
        if not user:
            return False
        return user['password_hash'] == hash_password(password)
    except Exception as e:
        print(f"Error authenticating user: {e}")
        return False
