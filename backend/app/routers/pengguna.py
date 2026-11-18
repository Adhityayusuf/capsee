from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field, field_validator
import re

from app.database import get_db_connection, row_to_dict
from app.security import verifikasi_token, hash_password, verify_password

router = APIRouter(prefix="/api/pengguna", tags=["Pengguna"])

_EMAIL_REGEX = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")

_PROFIL_COLUMNS = "id, nama, email, nomor_hp, provinsi, kota, kecamatan, dibuat_pada"


def _profil_lengkap(pengguna: dict) -> bool:
    """Identitas dianggap lengkap kalau nama + no HP + provinsi/kota/kecamatan terisi."""
    for key in ("nama", "nomor_hp", "provinsi", "kota", "kecamatan"):
        value = (pengguna.get(key) or "").strip() if isinstance(pengguna.get(key), str) else pengguna.get(key)
        if not value:
            return False
    return True


class EditProfilRequest(BaseModel):
    nama: str | None = Field(default=None, min_length=3)
    nomor_hp: str | None = None
    provinsi: str | None = None
    kota: str | None = None
    kecamatan: str | None = None

    @field_validator("nama")
    @classmethod
    def _nama_valid(cls, value: str | None) -> str | None:
        if value is not None:
            value = value.strip()
            if len(value) < 3:
                raise ValueError("Nama minimal 3 karakter")
        return value

    @field_validator("nomor_hp", "provinsi", "kota", "kecamatan")
    @classmethod
    def _strip_empty_to_none(cls, value: str | None) -> str | None:
        if value is None:
            return None
        value = value.strip()
        return value if value else None


class GantiSandiRequest(BaseModel):
    sandi_lama: str
    sandi_baru: str = Field(min_length=8)


@router.get("/me")
def profil_saya(id_pengguna: str = Depends(verifikasi_token)):
    """Ambil data profil pengguna yang sedang login."""
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute(
            f"SELECT {_PROFIL_COLUMNS} FROM pengguna WHERE id = %s",
            (id_pengguna,),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Pengguna tidak ditemukan")
        pengguna = row_to_dict(cur, row)
        return {"pengguna": pengguna, "profil_lengkap": _profil_lengkap(pengguna)}


@router.put("/me")
def edit_profil(
    data: EditProfilRequest,
    id_pengguna: str = Depends(verifikasi_token),
):
    """Edit nama / nomor HP / lokasi domisili. Field yang tidak dikirim tidak berubah."""
    fields = {
        "nama": data.nama,
        "nomor_hp": data.nomor_hp,
        "provinsi": data.provinsi,
        "kota": data.kota,
        "kecamatan": data.kecamatan,
    }
    to_update = {k: v for k, v in fields.items() if v is not None}

    if not to_update:
        raise HTTPException(status_code=400, detail="Tidak ada field yang diubah")

    with get_db_connection() as conn:
        cur = conn.cursor()

        set_clause = ", ".join(f"{col} = %s" for col in to_update)
        values = list(to_update.values()) + [id_pengguna]

        cur.execute(
            f"""
            UPDATE pengguna
            SET {set_clause}, diperbarui_pada = now()
            WHERE id = %s
            RETURNING {_PROFIL_COLUMNS}
            """,
            values,
        )
        pengguna = row_to_dict(cur, cur.fetchone())
        return {"pengguna": pengguna, "profil_lengkap": _profil_lengkap(pengguna)}


@router.put("/me/ganti-sandi")
def ganti_sandi(
    data: GantiSandiRequest,
    id_pengguna: str = Depends(verifikasi_token),
):
    """Ganti kata sandi pengguna. Perlu verifikasi sandi lama terlebih dahulu."""
    with get_db_connection() as conn:
        cur = conn.cursor()

        cur.execute(
            "SELECT kata_sandi_hash FROM pengguna WHERE id = %s",
            (id_pengguna,),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Pengguna tidak ditemukan")

        if not verify_password(data.sandi_lama, row[0]):
            raise HTTPException(status_code=401, detail="Kata sandi lama tidak cocok")

        cur.execute(
            "UPDATE pengguna SET kata_sandi_hash = %s, diperbarui_pada = now() WHERE id = %s",
            (hash_password(data.sandi_baru), id_pengguna),
        )
        return {"pesan": "Kata sandi berhasil diperbarui"}
