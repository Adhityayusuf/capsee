import uuid
from datetime import date, timedelta
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from app.database import get_db_connection
from app.security import verifikasi_token
from app.image_utils import kompres_gambar
from app.cloudinary_utils import upload_ke_cloudinary

router = APIRouter(prefix="/api/pemindaian", tags=["Pemindaian"])


@router.post("", status_code=201)
async def buat_pemindaian(
    id_lahan: str = Form(...),
    bagian_tanaman: str = Form(...),  # 'daun' atau 'buah'
    gambar: UploadFile = File(...),
    id_pengguna: str = Depends(verifikasi_token),
):
    # 1. Baca file gambar yang dikirim Flutter
    gambar_asli_bytes = await gambar.read()

    # 2. Kompres gambar (resize + turunkan kualitas) sebelum diupload
    gambar_terkompres = kompres_gambar(gambar_asli_bytes, kualitas=70, lebar_maksimal=1280)

    # 3. Upload hasil kompresi ke Cloudinary
    url_gambar = upload_ke_cloudinary(gambar_terkompres, nama_file=f"{bagian_tanaman}_{uuid.uuid4().hex[:8]}.jpg")

    # -----------------------------------------------------
    # TODO: PENTING — ganti bagian ini dengan pemanggilan
    # model ML yang sesungguhnya. Placeholder di bawah hanya
    # supaya alur bisa diuji end-to-end dulu.
    # -----------------------------------------------------
    hasil_ml = {
        "status_hasil": "sehat",
        "id_penyakit": None,
        "skor_keyakinan": 95.0,
        "tanggal_scan_ulang_disarankan": date.today() + timedelta(days=7),
    }

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
        kolom = [desc[0] for desc in cur.description]
        scan = dict(zip(kolom, cur.fetchone()))

        cur.execute(
            "UPDATE lahan SET status_kesehatan = %s WHERE id = %s",
            (hasil_ml["status_hasil"], id_lahan),
        )

        cur.execute(
            """
            INSERT INTO log_aktivitas (id, id_lahan, jenis_aktivitas, id_referensi, deskripsi)
            VALUES (%s, %s, 'scan', %s, %s)
            """,
            (str(uuid.uuid4()), id_lahan, id_scan, f"Scan {bagian_tanaman}: {hasil_ml['status_hasil']}"),
        )

        penanganan = []
        if hasil_ml["status_hasil"] == "tidak_sehat" and hasil_ml["id_penyakit"]:
            cur.execute("SELECT * FROM penanganan WHERE id_penyakit = %s", (hasil_ml["id_penyakit"],))
            kolom_p = [desc[0] for desc in cur.description]
            penanganan = [dict(zip(kolom_p, row)) for row in cur.fetchall()]

        return {"pemindaian": scan, "penanganan": penanganan}


@router.get("/lahan/{id_lahan}")
def riwayat_scan(id_lahan: str, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute(
            "SELECT * FROM pemindaian WHERE id_lahan = %s ORDER BY dipindai_pada DESC",
            (id_lahan,),
        )
        kolom = [desc[0] for desc in cur.description]
        hasil = [dict(zip(kolom, row)) for row in cur.fetchall()]
        return {"pemindaian": hasil}
