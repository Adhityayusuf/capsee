import uuid
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.database import get_db_connection
from app.security import hash_password, verify_password, buat_token

router = APIRouter(prefix="/api/auth", tags=["Auth"])


class RegisterRequest(BaseModel):
    nama: str
    email: str
    nomor_hp: str | None = None
    password: str


class LoginRequest(BaseModel):
    email: str
    password: str


@router.post("/register", status_code=201)
def register(data: RegisterRequest):
    with get_db_connection() as conn:
        cur = conn.cursor()

        cur.execute("SELECT id FROM pengguna WHERE email = %s", (data.email,))
        if cur.fetchone():
            raise HTTPException(status_code=409, detail="Email sudah terdaftar")

        id_baru = str(uuid.uuid4())
        kata_sandi_hash = hash_password(data.password)

        cur.execute(
            """
            INSERT INTO pengguna (id, nama, email, nomor_hp, kata_sandi_hash)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id, nama, email, nomor_hp
            """,
            (id_baru, data.nama, data.email, data.nomor_hp, kata_sandi_hash),
        )
        row = cur.fetchone()

        return {
            "pengguna": {
                "id": row[0], "nama": row[1], "email": row[2], "nomor_hp": row[3],
            }
        }


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

        id_pengguna, nama, email, nomor_hp, _ = row
        token = buat_token(id_pengguna)

        cur.execute("SELECT id FROM lahan WHERE id_pengguna = %s LIMIT 1", (id_pengguna,))
        sudah_punya_lahan = cur.fetchone() is not None

        return {
            "token": token,
            "pengguna": {"id": id_pengguna, "nama": nama, "email": email, "nomor_hp": nomor_hp},
            "sudah_punya_lahan": sudah_punya_lahan,
        }
