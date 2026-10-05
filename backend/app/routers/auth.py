import re
import uuid

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, field_validator

from app.database import get_db_connection, row_to_dict
from app.security import buat_token, hash_password, verify_password

router = APIRouter(prefix="/api/auth", tags=["Auth"])

_EMAIL_REGEX = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


class RegisterRequest(BaseModel):
    nama: str
    email: str
    nomor_hp: str | None = None
    password: str

    @field_validator("nama")
    @classmethod
    def _nama_valid(cls, value: str) -> str:
        value = value.strip()
        if len(value) < 3:
            raise ValueError("Nama minimal 3 karakter")
        return value

    @field_validator("email")
    @classmethod
    def _email_valid(cls, value: str) -> str:
        value = value.strip().lower()
        if not _EMAIL_REGEX.match(value):
            raise ValueError("Format email tidak valid")
        return value

    @field_validator("password")
    @classmethod
    def _password_valid(cls, value: str) -> str:
        if len(value) < 8:
            raise ValueError("Kata sandi minimal 8 karakter")
        return value


class LoginRequest(BaseModel):
    email: str
    password: str

    @field_validator("email")
    @classmethod
    def _email_normalized(cls, value: str) -> str:
        return value.strip().lower()


@router.post("/register", status_code=201)
def register(data: RegisterRequest):
    with get_db_connection() as conn:
        cur = conn.cursor()

        cur.execute("SELECT id FROM pengguna WHERE email = %s", (data.email,))
        if cur.fetchone():
            raise HTTPException(status_code=409, detail="Email sudah terdaftar")

        cur.execute(
            """
            INSERT INTO pengguna (id, nama, email, nomor_hp, kata_sandi_hash)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id, nama, email, nomor_hp
            """,
            (str(uuid.uuid4()), data.nama, data.email, data.nomor_hp,
             hash_password(data.password)),
        )
        return {"pengguna": row_to_dict(cur, cur.fetchone())}


@router.post("/login")
def login(data: LoginRequest):
    with get_db_connection() as conn:
        cur = conn.cursor()

        cur.execute(
            "SELECT id, nama, email, nomor_hp, kata_sandi_hash FROM pengguna WHERE email = %s",
            (data.email,),
        )
        row = cur.fetchone()

        if not row or not verify_password(data.password, row[4]):
            raise HTTPException(status_code=401, detail="Email atau password salah")

        id_pengguna = row[0]
        cur.execute("SELECT id FROM lahan WHERE id_pengguna = %s LIMIT 1", (id_pengguna,))
        sudah_punya_lahan = cur.fetchone() is not None

        return {
            "token": buat_token(id_pengguna),
            "pengguna": {"id": row[0], "nama": row[1], "email": row[2], "nomor_hp": row[3]},
            "sudah_punya_lahan": sudah_punya_lahan,
        }
