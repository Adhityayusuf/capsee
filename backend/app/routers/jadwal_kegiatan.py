import uuid
from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.access import pastikan_lahan_milik_pengguna
from app.database import get_db_connection, row_to_dict, rows_to_dicts
from app.security import verifikasi_token

router = APIRouter(prefix="/api/lahan", tags=["JadwalKegiatan"])


class TambahJadwalKegiatanRequest(BaseModel):
    nama_kegiatan: str = Field(min_length=1, max_length=150)
    deskripsi: str | None = None
    tanggal_jadwal: date


class EditJadwalKegiatanRequest(BaseModel):
    nama_kegiatan: str | None = Field(default=None, min_length=1, max_length=150)
    deskripsi: str | None = None
    tanggal_jadwal: date | None = None


@router.post("/{id_lahan}/jadwal-kegiatan", status_code=201)
def tambah_jadwal_kegiatan(
    id_lahan: str,
    data: TambahJadwalKegiatanRequest,
    id_pengguna: str = Depends(verifikasi_token),
):
    """Tambah jadwal kegiatan manual (nama + tanggal + deskripsi) per lahan."""
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)

        id_jadwal = str(uuid.uuid4())
        cur.execute(
            """
            INSERT INTO jadwal_kegiatan (id, id_lahan, nama_kegiatan, deskripsi, tanggal_jadwal)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING *
            """,
            (
                id_jadwal,
                id_lahan,
                data.nama_kegiatan.strip(),
                data.deskripsi.strip() if data.deskripsi else None,
                data.tanggal_jadwal,
            ),
        )
        return {"jadwal_kegiatan": row_to_dict(cur, cur.fetchone())}


@router.get("/{id_lahan}/jadwal-kegiatan")
def daftar_jadwal_kegiatan(
    id_lahan: str, id_pengguna: str = Depends(verifikasi_token)
):
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)
        cur.execute(
            "SELECT * FROM jadwal_kegiatan WHERE id_lahan = %s ORDER BY tanggal_jadwal ASC",
            (id_lahan,),
        )
        return {"jadwal_kegiatan": rows_to_dicts(cur)}


@router.patch("/{id_lahan}/jadwal-kegiatan/{id_jadwal}/selesai")
def selesai_jadwal_kegiatan(
    id_lahan: str,
    id_jadwal: str,
    id_pengguna: str = Depends(verifikasi_token),
):
    """Tandai selesai + catat ke log_aktivitas sebagai 'kegiatan_lain'
    (sesuai CHECK terbaru di Neon)."""
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)

        cur.execute(
            "SELECT * FROM jadwal_kegiatan WHERE id = %s AND id_lahan = %s",
            (id_jadwal, id_lahan),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Jadwal kegiatan tidak ditemukan")
        jadwal = row_to_dict(cur, row)
        if jadwal["status"] == "selesai":
            raise HTTPException(status_code=409, detail="Jadwal sudah ditandai selesai")

        cur.execute(
            """
            UPDATE jadwal_kegiatan
            SET status = 'selesai', selesai_pada = now()
            WHERE id = %s
            RETURNING *
            """,
            (id_jadwal,),
        )
        updated = row_to_dict(cur, cur.fetchone())

        cur.execute(
            """
            INSERT INTO log_aktivitas (id, id_lahan, jenis_aktivitas, id_referensi, deskripsi)
            VALUES (%s, %s, 'kegiatan_lain', %s, %s)
            """,
            (
                str(uuid.uuid4()),
                id_lahan,
                id_jadwal,
                f"Kegiatan '{jadwal['nama_kegiatan']}' selesai ({jadwal['tanggal_jadwal']})",
            ),
        )
        return {"jadwal_kegiatan": updated}


@router.delete("/{id_lahan}/jadwal-kegiatan/{id_jadwal}")
def hapus_jadwal_kegiatan(
    id_lahan: str,
    id_jadwal: str,
    id_pengguna: str = Depends(verifikasi_token),
):
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)
        cur.execute(
            "DELETE FROM jadwal_kegiatan WHERE id = %s AND id_lahan = %s",
            (id_jadwal, id_lahan),
        )
        if cur.rowcount == 0:
            raise HTTPException(status_code=404, detail="Jadwal kegiatan tidak ditemukan")
        return {"pesan": "Jadwal kegiatan berhasil dihapus"}
