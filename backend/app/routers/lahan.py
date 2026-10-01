import uuid
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from datetime import date
from app.database import get_db_connection
from app.security import verifikasi_token

router = APIRouter(prefix="/api/lahan", tags=["Lahan"])


class TambahLahanRequest(BaseModel):
    nama: str
    provinsi: str
    kota: str
    kecamatan: str
    umur_tanaman_bulan: int
    tanggal_terakhir_siram: date | None = None
    tanggal_terakhir_pupuk: date | None = None
    interval_pupuk_minggu: int


@router.post("", status_code=201)
def tambah_lahan(data: TambahLahanRequest, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        id_lahan = str(uuid.uuid4())

        cur.execute(
            """
            INSERT INTO lahan
                (id, id_pengguna, nama, provinsi, kota, kecamatan, umur_tanaman_bulan,
                 tanggal_terakhir_siram, tanggal_terakhir_pupuk, interval_pupuk_minggu)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING *
            """,
            (id_lahan, id_pengguna, data.nama, data.provinsi, data.kota, data.kecamatan,
             data.umur_tanaman_bulan, data.tanggal_terakhir_siram,
             data.tanggal_terakhir_pupuk, data.interval_pupuk_minggu),
        )
        kolom = [desc[0] for desc in cur.description]
        lahan = dict(zip(kolom, cur.fetchone()))

        # Auto-generate jadwal penyiraman 7 hari ke depan
        # TODO: ganti CURRENT_DATE + i hari dengan logic yang mengecek
        # prediksi hujan dari BMKG, supaya hari hujan otomatis "dilewati"
        for i in range(1, 8):
            cur.execute(
                """
                INSERT INTO jadwal_penyiraman (id, id_lahan, tanggal_jadwal)
                VALUES (%s, %s, CURRENT_DATE + (%s || ' days')::interval)
                """,
                (str(uuid.uuid4()), id_lahan, i),
            )

        # Auto-generate jadwal pemupukan berikutnya
        if data.tanggal_terakhir_pupuk:
            cur.execute(
                """
                INSERT INTO jadwal_pemupukan (id, id_lahan, tanggal_jadwal)
                VALUES (%s, %s, %s::date + (%s * 7 || ' days')::interval)
                """,
                (str(uuid.uuid4()), id_lahan, data.tanggal_terakhir_pupuk, data.interval_pupuk_minggu),
            )

        return {"lahan": lahan}


@router.get("")
def daftar_lahan(id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute(
            "SELECT * FROM lahan WHERE id_pengguna = %s ORDER BY dibuat_pada DESC",
            (id_pengguna,),
        )
        kolom = [desc[0] for desc in cur.description]
        hasil = [dict(zip(kolom, row)) for row in cur.fetchall()]
        return {"lahan": hasil}


@router.get("/{id_lahan}")
def detail_lahan(id_lahan: str, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute(
            "SELECT * FROM lahan WHERE id = %s AND id_pengguna = %s",
            (id_lahan, id_pengguna),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Lahan tidak ditemukan")
        kolom = [desc[0] for desc in cur.description]
        return {"lahan": dict(zip(kolom, row))}


@router.get("/{id_lahan}/jadwal-penyiraman")
def jadwal_penyiraman(id_lahan: str, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute(
            "SELECT * FROM jadwal_penyiraman WHERE id_lahan = %s ORDER BY tanggal_jadwal ASC",
            (id_lahan,),
        )
        kolom = [desc[0] for desc in cur.description]
        hasil = [dict(zip(kolom, row)) for row in cur.fetchall()]
        return {"jadwal_penyiraman": hasil}


@router.get("/{id_lahan}/jadwal-pemupukan")
def jadwal_pemupukan(id_lahan: str, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute(
            "SELECT * FROM jadwal_pemupukan WHERE id_lahan = %s ORDER BY tanggal_jadwal ASC",
            (id_lahan,),
        )
        kolom = [desc[0] for desc in cur.description]
        hasil = [dict(zip(kolom, row)) for row in cur.fetchall()]
        return {"jadwal_pemupukan": hasil}


@router.get("/{id_lahan}/riwayat")
def riwayat_lahan(id_lahan: str, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute(
            "SELECT * FROM log_aktivitas WHERE id_lahan = %s ORDER BY terjadi_pada DESC",
            (id_lahan,),
        )
        kolom = [desc[0] for desc in cur.description]
        hasil = [dict(zip(kolom, row)) for row in cur.fetchall()]
        return {"riwayat": hasil}
