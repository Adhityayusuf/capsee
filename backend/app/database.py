import os
from contextlib import contextmanager

from dotenv import load_dotenv
from psycopg2 import pool
from psycopg2.extensions import cursor as PgCursor

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise RuntimeError(
        "DATABASE_URL belum diset. Salin backend/.env.example menjadi "
        "backend/.env lalu isi kredensial Neon."
    )

# Connection pool supaya tidak buka-tutup koneksi tiap request (lebih efisien)
_connection_pool = pool.SimpleConnectionPool(
    minconn=1,
    maxconn=10,
    dsn=DATABASE_URL,
)


@contextmanager
def get_db_connection():
    """Pakai dengan: `with get_db_connection() as conn:`"""
    conn = _connection_pool.getconn()
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        _connection_pool.putconn(conn)


def row_to_dict(cur: PgCursor, row) -> dict:
    """Ubah satu baris hasil query menjadi dict {nama_kolom: nilai}."""
    return dict(zip((desc[0] for desc in cur.description), row))


def rows_to_dicts(cur: PgCursor) -> list[dict]:
    """Ambil seluruh hasil query dan ubah menjadi list of dict."""
    return [row_to_dict(cur, row) for row in cur.fetchall()]
