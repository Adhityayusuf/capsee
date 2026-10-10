import uuid
from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.access import pastikan_lahan_milik_pengguna
from app.database import get_db_connection, row_to_dict, rows_to_dicts
from app.security import verifikasi_token

router = APIRouter(prefix="/api/lahan", tags=["Lahan"])


class TambahLahanRequest(BaseModel):
    nama: str = Field(min_length=1)
    provinsi: str = Field(min_length=1)
    kota: str = Field(min_length=1)
    kecamatan: str = Field(min_length=1)
    # Samakan dengan CHECK di DB: umur 1-5 bulan, pupuk & siram 1-12 minggu.
    umur_tanaman_bulan: int = Field(ge=1, le=5)
    tanggal_terakhir_siram: date | None = None
    tanggal_terakhir_pupuk: date | None = None
    interval_pupuk_minggu: int = Field(ge=1, le=12)
    interval_siram_minggu: int = Field(default=1, ge=1, le=12)


class EditLahanRequest(BaseModel):
    nama: str | None = Field(default=None, min_length=1)
    provinsi: str | None = Field(default=None, min_length=1)
    kota: str | None = Field(default=None, min_length=1)
    kecamatan: str | None = Field(default=None, min_length=1)
    umur_tanaman_bulan: int | None = Field(default=None, ge=1, le=5)
    tanggal_terakhir_siram: date | None = None
    tanggal_terakhir_pupuk: date | None = None
    interval_pupuk_minggu: int | None = Field(default=None, ge=1, le=12)
    interval_siram_minggu: int | None = Field(default=None, ge=1, le=12)


# ─────────────────────────────────────────────────
# CRUD LAHAN
# ─────────────────────────────────────────────────

@router.post("", status_code=201)
def tambah_lahan(data: TambahLahanRequest, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        id_lahan = str(uuid.uuid4())

        cur.execute(
            """
            INSERT INTO lahan
                (id, id_pengguna, nama, provinsi, kota, kecamatan, umur_tanaman_bulan,
                 tanggal_terakhir_siram, tanggal_terakhir_pupuk, interval_pupuk_minggu,
                 interval_siram_minggu)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING *
            """,
            (id_lahan, id_pengguna, data.nama, data.provinsi, data.kota, data.kecamatan,
             data.umur_tanaman_bulan, data.tanggal_terakhir_siram,
             data.tanggal_terakhir_pupuk, data.interval_pupuk_minggu,
             data.interval_siram_minggu),
        )
        lahan = row_to_dict(cur, cur.fetchone())

        # Auto-generate jadwal penyiraman 7 hari ke depan.
        # TODO: ganti dengan prediksi hujan BMKG agar hari hujan otomatis dilewati.
        cur.executemany(
            """
            INSERT INTO jadwal_penyiraman (id, id_lahan, tanggal_jadwal)
            VALUES (%s, %s, CURRENT_DATE + (%s || ' days')::interval)
            """,
            [(str(uuid.uuid4()), id_lahan, i) for i in range(1, 8)],
        )

        # Auto-generate jadwal pemupukan berikutnya
        if data.tanggal_terakhir_pupuk:
            cur.execute(
                """
                INSERT INTO jadwal_pemupukan (id, id_lahan, tanggal_jadwal)
                VALUES (%s, %s, %s::date + (%s * 7 || ' days')::interval)
                """,
                (str(uuid.uuid4()), id_lahan, data.tanggal_terakhir_pupuk,
                 data.interval_pupuk_minggu),
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
        return {"lahan": rows_to_dicts(cur)}


@router.get("/{id_lahan}")
def detail_lahan(id_lahan: str, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)
        cur.execute("SELECT * FROM lahan WHERE id = %s", (id_lahan,))
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Lahan tidak ditemukan")
        return {"lahan": row_to_dict(cur, row)}


@router.put("/{id_lahan}")
def edit_lahan(
    id_lahan: str,
    data: EditLahanRequest,
    id_pengguna: str = Depends(verifikasi_token),
):
    """Edit sebagian atau seluruh field lahan. Field yang tidak dikirim tidak berubah."""
    fields = {
        "nama": data.nama,
        "provinsi": data.provinsi,
        "kota": data.kota,
        "kecamatan": data.kecamatan,
        "umur_tanaman_bulan": data.umur_tanaman_bulan,
        "tanggal_terakhir_siram": data.tanggal_terakhir_siram,
        "tanggal_terakhir_pupuk": data.tanggal_terakhir_pupuk,
        "interval_pupuk_minggu": data.interval_pupuk_minggu,
        "interval_siram_minggu": data.interval_siram_minggu,
    }
    # Hanya kolom yang dikirim (bukan None)
    to_update = {k: v for k, v in fields.items() if v is not None}

    if not to_update:
        raise HTTPException(status_code=400, detail="Tidak ada field yang diubah")

    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)

        set_clause = ", ".join(f"{col} = %s" for col in to_update)
        values = list(to_update.values()) + [id_lahan]

        cur.execute(
            f"""
            UPDATE lahan
            SET {set_clause}, diperbarui_pada = now()
            WHERE id = %s
            RETURNING *
            """,
            values,
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Lahan tidak ditemukan")
        return {"lahan": row_to_dict(cur, row)}


@router.delete("/{id_lahan}", status_code=200)
def hapus_lahan(id_lahan: str, id_pengguna: str = Depends(verifikasi_token)):
    """Hapus lahan beserta semua data turunannya (CASCADE dari DB)."""
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)
        cur.execute("DELETE FROM lahan WHERE id = %s", (id_lahan,))
        return {"pesan": "Lahan berhasil dihapus"}


# ─────────────────────────────────────────────────
# JADWAL PENYIRAMAN
# ─────────────────────────────────────────────────

@router.get("/{id_lahan}/jadwal-penyiraman")
def jadwal_penyiraman(id_lahan: str, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)
        cur.execute(
            "SELECT * FROM jadwal_penyiraman WHERE id_lahan = %s ORDER BY tanggal_jadwal ASC",
            (id_lahan,),
        )
        return {"jadwal_penyiraman": rows_to_dicts(cur)}


@router.patch("/{id_lahan}/jadwal-penyiraman/{id_jadwal}/selesai")
def selesai_penyiraman(
    id_lahan: str,
    id_jadwal: str,
    id_pengguna: str = Depends(verifikasi_token),
):
    """Tandai jadwal penyiraman sebagai selesai, update tanggal_terakhir_siram di lahan,
    dan catat ke log_aktivitas."""
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)

        cur.execute(
            "SELECT * FROM jadwal_penyiraman WHERE id = %s AND id_lahan = %s",
            (id_jadwal, id_lahan),
        )
        jadwal = cur.fetchone()
        if not jadwal:
            raise HTTPException(status_code=404, detail="Jadwal penyiraman tidak ditemukan")

        jadwal_dict = row_to_dict(cur, jadwal)
        if jadwal_dict["status"] == "selesai":
            raise HTTPException(status_code=409, detail="Jadwal sudah ditandai selesai")

        # Tandai selesai
        cur.execute(
            """
            UPDATE jadwal_penyiraman
            SET status = 'selesai', selesai_pada = now()
            WHERE id = %s
            RETURNING *
            """,
            (id_jadwal,),
        )
        jadwal_updated = row_to_dict(cur, cur.fetchone())

        # Update tanggal_terakhir_siram di lahan
        cur.execute(
            "UPDATE lahan SET tanggal_terakhir_siram = CURRENT_DATE, diperbarui_pada = now() WHERE id = %s",
            (id_lahan,),
        )

        # Ambil interval siram (mingguan) dari lahan
        cur.execute(
            "SELECT interval_siram_minggu FROM lahan WHERE id = %s",
            (id_lahan,),
        )
        interval_siram = cur.fetchone()[0] or 1

        # Auto-generate jadwal penyiraman berikutnya (seperti pemupukan)
        cur.execute(
            """
            INSERT INTO jadwal_penyiraman (id, id_lahan, tanggal_jadwal)
            VALUES (%s, %s, CURRENT_DATE + (%s * 7 || ' days')::interval)
            """,
            (str(uuid.uuid4()), id_lahan, interval_siram),
        )

        # Catat ke log_aktivitas
        cur.execute(
            """
            INSERT INTO log_aktivitas (id, id_lahan, jenis_aktivitas, id_referensi, deskripsi)
            VALUES (%s, %s, 'siram', %s, %s)
            """,
            (str(uuid.uuid4()), id_lahan, id_jadwal,
             f"Penyiraman selesai untuk jadwal {jadwal_dict['tanggal_jadwal']}"),
        )

        return {"jadwal_penyiraman": jadwal_updated}


# ─────────────────────────────────────────────────
# JADWAL PEMUPUKAN
# ─────────────────────────────────────────────────

@router.get("/{id_lahan}/jadwal-pemupukan")
def jadwal_pemupukan(id_lahan: str, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)
        cur.execute(
            "SELECT * FROM jadwal_pemupukan WHERE id_lahan = %s ORDER BY tanggal_jadwal ASC",
            (id_lahan,),
        )
        return {"jadwal_pemupukan": rows_to_dicts(cur)}


@router.patch("/{id_lahan}/jadwal-pemupukan/{id_jadwal}/selesai")
def selesai_pemupukan(
    id_lahan: str,
    id_jadwal: str,
    id_pengguna: str = Depends(verifikasi_token),
):
    """Tandai jadwal pemupukan sebagai selesai, update tanggal_terakhir_pupuk di lahan,
    dan generate jadwal pemupukan berikutnya secara otomatis."""
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)

        cur.execute(
            "SELECT * FROM jadwal_pemupukan WHERE id = %s AND id_lahan = %s",
            (id_jadwal, id_lahan),
        )
        jadwal = cur.fetchone()
        if not jadwal:
            raise HTTPException(status_code=404, detail="Jadwal pemupukan tidak ditemukan")

        jadwal_dict = row_to_dict(cur, jadwal)
        if jadwal_dict["status"] == "selesai":
            raise HTTPException(status_code=409, detail="Jadwal sudah ditandai selesai")

        # Tandai selesai
        cur.execute(
            """
            UPDATE jadwal_pemupukan
            SET status = 'selesai', selesai_pada = now()
            WHERE id = %s
            RETURNING *
            """,
            (id_jadwal,),
        )
        jadwal_updated = row_to_dict(cur, cur.fetchone())

        # Ambil interval pupuk dari lahan
        cur.execute("SELECT interval_pupuk_minggu FROM lahan WHERE id = %s", (id_lahan,))
        interval = cur.fetchone()[0]

        # Update tanggal_terakhir_pupuk di lahan
        cur.execute(
            "UPDATE lahan SET tanggal_terakhir_pupuk = CURRENT_DATE, diperbarui_pada = now() WHERE id = %s",
            (id_lahan,),
        )

        # Auto-generate jadwal pemupukan berikutnya
        cur.execute(
            """
            INSERT INTO jadwal_pemupukan (id, id_lahan, tanggal_jadwal)
            VALUES (%s, %s, CURRENT_DATE + (%s * 7 || ' days')::interval)
            """,
            (str(uuid.uuid4()), id_lahan, interval),
        )

        # Catat ke log_aktivitas
        cur.execute(
            """
            INSERT INTO log_aktivitas (id, id_lahan, jenis_aktivitas, id_referensi, deskripsi)
            VALUES (%s, %s, 'pupuk', %s, %s)
            """,
            (str(uuid.uuid4()), id_lahan, id_jadwal,
             f"Pemupukan selesai untuk jadwal {jadwal_dict['tanggal_jadwal']}"),
        )

        return {"jadwal_pemupukan": jadwal_updated}


# ─────────────────────────────────────────────────
# RIWAYAT AKTIVITAS
# ─────────────────────────────────────────────────

@router.get("/{id_lahan}/riwayat")
def riwayat_lahan(id_lahan: str, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)
        cur.execute(
            "SELECT * FROM log_aktivitas WHERE id_lahan = %s ORDER BY terjadi_pada DESC",
            (id_lahan,),
        )
        return {"riwayat": rows_to_dicts(cur)}
