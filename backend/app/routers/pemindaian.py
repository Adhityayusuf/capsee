import uuid
from datetime import date, timedelta
from typing import Literal

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile

from app.access import pastikan_lahan_milik_pengguna
from app.cloudinary_utils import CloudinaryUploadError, upload_ke_cloudinary
from app.database import get_db_connection, row_to_dict, rows_to_dicts
from app.image_utils import kompres_gambar
from app.security import verifikasi_token

router = APIRouter(prefix="/api/pemindaian", tags=["Pemindaian"])


import random

def _jalankan_model_ml() -> dict:
    """Placeholder hasil model ML.

    Secara acak mengembalikan 'sehat' atau 'tidak_sehat' agar UI bisa diuji.
    """
    is_sehat = random.choice([True, False])
    
    if is_sehat:
        return {
            "status_hasil": "sehat",
            "id_penyakit": None,
            "skor_keyakinan": random.uniform(85.0, 99.9),
            "tanggal_scan_ulang_disarankan": date.today() + timedelta(days=7),
        }
    else:
        # Menggunakan ID penyakit yang baru saja di-seed ('Bercak Daun')
        with get_db_connection() as conn:
            cur = conn.cursor()
            cur.execute("SELECT id FROM penyakit LIMIT 1")
            row = cur.fetchone()
            id_penyakit = row[0] if row else None
            
        return {
            "status_hasil": "tidak_sehat",
            "id_penyakit": id_penyakit,
            "skor_keyakinan": random.uniform(75.0, 98.5),
            "tanggal_scan_ulang_disarankan": date.today() + timedelta(days=3),
        }


@router.post("", status_code=201)
async def buat_pemindaian(
    id_lahan: str = Form(...),
    bagian_tanaman: Literal["daun", "buah"] = Form(...),
    gambar: UploadFile = File(...),
    id_pengguna: str = Depends(verifikasi_token),
):
    # 0. WAJIB cek lahan dulu SEBELUM baca/upload gambar.
    #    Mencegah Cloudinary penuh oleh upload yang id_lahan-nya
    #    kosong / milik orang lain / tidak ada.
    if not id_lahan or not id_lahan.strip():
        raise HTTPException(status_code=400, detail="Pilih lahan dulu sebelum scan")
    with get_db_connection() as conn:
        pastikan_lahan_milik_pengguna(conn.cursor(), id_lahan, id_pengguna)

    # 1. Baca + kompres gambar.
    #    File bukan-gambar → 400 (jangan jadi 500, jangan upload).
    try:
        gambar_asli_bytes = await gambar.read()
        if not gambar_asli_bytes:
            raise HTTPException(status_code=400, detail="File gambar kosong")
        gambar_terkompres = kompres_gambar(gambar_asli_bytes, kualitas=70, lebar_maksimal=1280)
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=400, detail="File bukan gambar yang valid")

    # 2. Upload hasil kompresi ke Cloudinary.
    #    Gangguan jaringan/timeout → 502 (jangan jadi 500).
    try:
        url_gambar = upload_ke_cloudinary(
            gambar_terkompres,
            nama_file=f"{bagian_tanaman}_{uuid.uuid4().hex[:8]}.jpg",
        )
    except CloudinaryUploadError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"Upload ke Cloudinary gagal: {exc}") from exc

    hasil_ml = _jalankan_model_ml()
    id_scan = str(uuid.uuid4())

    # 3. Semua operasi DB dalam SATU blok koneksi
    #    (cek ulang kepemilikan agar aman dari race delete di tengah upload)
    with get_db_connection() as conn:
        cur = conn.cursor()

        # Pastikan lahan masih milik pengguna setelah upload selesai
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)

        cur.execute(
            """
            INSERT INTO pemindaian
                (id, id_lahan, bagian_tanaman, url_gambar, status_hasil,
                 id_penyakit, skor_keyakinan, tanggal_scan_ulang_disarankan)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING *
            """,
            (id_scan, id_lahan, bagian_tanaman, url_gambar, hasil_ml["status_hasil"],
             hasil_ml["id_penyakit"], hasil_ml["skor_keyakinan"],
             hasil_ml["tanggal_scan_ulang_disarankan"]),
        )
        scan = row_to_dict(cur, cur.fetchone())

        cur.execute(
            "UPDATE lahan SET status_kesehatan = %s WHERE id = %s",
            (hasil_ml["status_hasil"], id_lahan),
        )

        cur.execute(
            """
            INSERT INTO log_aktivitas (id, id_lahan, jenis_aktivitas, id_referensi, deskripsi)
            VALUES (%s, %s, 'scan', %s, %s)
            """,
            (str(uuid.uuid4()), id_lahan, id_scan,
             f"Scan {bagian_tanaman}: {hasil_ml['status_hasil']}"),
        )

        penanganan = []
        langkah_tindakan = []
        pencegahan = []
        penyakit = None

        if hasil_ml["status_hasil"] == "tidak_sehat" and hasil_ml["id_penyakit"]:
            id_penyakit = hasil_ml["id_penyakit"]

            cur.execute("SELECT * FROM penyakit WHERE id = %s", (id_penyakit,))
            row_penyakit = cur.fetchone()
            if row_penyakit:
                penyakit = row_to_dict(cur, row_penyakit)

            cur.execute(
                "SELECT * FROM penanganan WHERE id_penyakit = %s",
                (id_penyakit,),
            )
            penanganan = rows_to_dicts(cur)

            cur.execute(
                "SELECT * FROM langkah_tindakan WHERE id_penyakit = %s ORDER BY urutan ASC",
                (id_penyakit,),
            )
            langkah_tindakan = rows_to_dicts(cur)

            cur.execute(
                "SELECT * FROM pencegahan WHERE id_penyakit = %s",
                (id_penyakit,),
            )
            pencegahan = rows_to_dicts(cur)

        return {
            "pemindaian": scan,
            "penyakit": penyakit,
            "penanganan": penanganan,
            "langkah_tindakan": langkah_tindakan,
            "pencegahan": pencegahan,
        }


@router.get("/lahan/{id_lahan}")
def riwayat_scan(id_lahan: str, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)
        cur.execute(
            "SELECT * FROM pemindaian WHERE id_lahan = %s ORDER BY dipindai_pada DESC",
            (id_lahan,),
        )
        return {"pemindaian": rows_to_dicts(cur)}


@router.get("/{id_scan}")
def detail_scan(
    id_scan: str,
    id_pengguna: str = Depends(verifikasi_token),
):
    """Ambil detail satu hasil scan beserta data penyakit, penanganan,
    langkah tindakan, dan pencegahan (jika tidak sehat)."""
    with get_db_connection() as conn:
        cur = conn.cursor()

        # Pastikan scan ada dan milik pengguna yang login
        cur.execute(
            """
            SELECT p.* FROM pemindaian p
            JOIN lahan l ON l.id = p.id_lahan
            WHERE p.id = %s AND l.id_pengguna = %s
            """,
            (id_scan, id_pengguna),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Hasil scan tidak ditemukan")

        scan = row_to_dict(cur, row)
        id_penyakit = scan.get("id_penyakit")

        penanganan = []
        langkah_tindakan = []
        pencegahan = []
        penyakit = None

        if id_penyakit:
            cur.execute("SELECT * FROM penyakit WHERE id = %s", (id_penyakit,))
            row_penyakit = cur.fetchone()
            if row_penyakit:
                penyakit = row_to_dict(cur, row_penyakit)

            cur.execute(
                "SELECT * FROM penanganan WHERE id_penyakit = %s",
                (id_penyakit,),
            )
            penanganan = rows_to_dicts(cur)

            cur.execute(
                "SELECT * FROM langkah_tindakan WHERE id_penyakit = %s ORDER BY urutan ASC",
                (id_penyakit,),
            )
            langkah_tindakan = rows_to_dicts(cur)

            cur.execute(
                "SELECT * FROM pencegahan WHERE id_penyakit = %s",
                (id_penyakit,),
            )
            pencegahan = rows_to_dicts(cur)

        return {
            "pemindaian": scan,
            "penyakit": penyakit,
            "penanganan": penanganan,
            "langkah_tindakan": langkah_tindakan,
            "pencegahan": pencegahan,
        }
