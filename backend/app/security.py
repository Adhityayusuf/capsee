import os
from pathlib import Path
import bcrypt
import jwt
from datetime import datetime, timedelta, timezone
from fastapi import Header, HTTPException
from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[1] / ".env")

JWT_SECRET = os.getenv("JWT_SECRET")

if not JWT_SECRET:
    raise RuntimeError(
        "JWT_SECRET belum diset. Salin backend/.env.example menjadi "
        "backend/.env lalu isi JWT_SECRET."
    )

JWT_ALGORITHM = "HS256"
JWT_EXPIRE_DAYS = 7


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password: str, password_hash: str) -> bool:
    return bcrypt.checkpw(password.encode(), password_hash.encode())


def buat_token(id_pengguna: str) -> str:
    payload = {
        "id": id_pengguna,
        "exp": datetime.now(timezone.utc) + timedelta(days=JWT_EXPIRE_DAYS),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def verifikasi_token(authorization: str | None = Header(default=None)) -> str:
    """
    Dipakai sebagai dependency FastAPI untuk melindungi endpoint.
    Flutter wajib kirim header: Authorization: Bearer <token>
    Mengembalikan id_pengguna yang sudah login.
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Token tidak ditemukan, silakan login ulang")

    token = authorization.split(" ")[1]
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload["id"]
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=403, detail="Token sudah kedaluwarsa, silakan login ulang")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=403, detail="Token tidak valid")
