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


def _jalankan_model_ml() -> dict:
    """Placeholder hasil model ML.

    TODO: ganti dengan pemanggilan model yang sesungguhnya. Struktur return
    dibuat tetap agar endpoint dan skema DB tidak perlu berubah nanti.
    """
    return {
        "status_hasil": "sehat",
        "id_penyakit": None,
        "skor_keyakinan": 95.0,
        "tanggal_scan_ulang_disarankan": date.today() + timedelta(days=7),
    }


@router.post("", status_code=201)
async def buat_pemindaian(
    id_lahan: str = Form(...),
    bagian_tanaman: Literal["daun", "buah"] = Form(...),
    gambar: UploadFile = File(...),
    id_pengguna: str = Depends(verifikasi_token),
):
    # 1. Pastikan lahan milik pengguna SEBELUM upload agar tidak membuang bandwidth.
    with get_db_connection() as conn:
        pastikan_lahan_milik_pengguna(conn.cursor(), id_lahan, id_pengguna)

    # 2. Baca + kompres gambar (resize + turunkan kualitas) sebelum diupload
    gambar_asli_bytes = await gambar.read()
    gambar_terkompres = kompres_gambar(gambar_asli_bytes, kualitas=70, lebar_maksimal=1280)

    # 3. Upload hasil kompresi ke Cloudinary
    try:
        url_gambar = upload_ke_cloudinary(
            gambar_terkompres,
            nama_file=f"{bagian_tanaman}_{uuid.uuid4().hex[:8]}.jpg",
        )
    except CloudinaryUploadError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    hasil_ml = _jalankan_model_ml()
    id_scan = str(uuid.uuid4())

    with get_db_connection() as conn:
        cur = conn.cursor()

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
