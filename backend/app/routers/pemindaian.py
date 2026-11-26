import uuid
from datetime import date, timedelta
from typing import Literal, Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile

from app.access import pastikan_lahan_milik_pengguna
from app.cloudinary_utils import CloudinaryUploadError, upload_ke_cloudinary
from app.database import get_db_connection, row_to_dict, rows_to_dicts
from app.image_utils import kompres_gambar
from app.security import verifikasi_token

router = APIRouter(prefix="/api/pemindaian", tags=["Pemindaian"])


# ─── Label-ke-status mapper ──────────────────────────────────────────────────
# Daftar nama kelas yang dianggap "sehat" dari kedua model TFLite.
# Cocokkan dengan ModelConfig.leafLabels & ModelConfig.fruitLabels di Flutter.
_HEALTHY_LABELS = {"Healthy Leaf", "Healthy Fruit"}

# Pemetaan nama kelas penyakit (dari Flutter) ke nama penyakit di tabel penyakit.
# Kunci = className dari model TFLite, Nilai = nama di kolom `nama` tabel penyakit.
_CLASS_TO_DISEASE_NAME: dict[str, str] = {
    "Bacterial Spot":       "Bercak Bakteri",
    "Cercospora":           "Bercak Mata Kodok",
    "Leaf Curl":            "Keriting Daun",
    "Nutrition Deficiency": "Kekurangan Nutrisi",
    "White Spot":           "Bercak Putih (Embun Tepung)",
    "Anthracnose":          "Antraknosa",
    "Fruit Fly":            "Lalat Buah",
    "Fruit Rot":            "Busuk Buah",
}


def _normalize_kelas(label: str) -> str:
    """Normalisasi label model ML ke format snake_case untuk kolom `kelas`.
    Contoh: 'Bacterial Spot' -> 'bacterial_spot'
    """
    return label.strip().lower().replace(" ", "_").replace("-", "_")


def _resolve_id_penyakit(cur, label: str | None) -> str | None:
    """Cari id penyakit dari nama kelas atau label model ML.
    Mendukung pencarian via:
    1. Kolom `nama` (misal 'Bercak Bakteri', 'Antraknosa')
    2. Pemetaan dari nama kelas bahasa Inggris ke nama Indonesia
    3. Kolom `kelas` (jika ada di tabel)
    4. Pencarian parsial (ILIKE)
    """
    if not label:
        return None

    clean_label = label.strip()
    kelas_norm = _normalize_kelas(clean_label)

    # 1. Cocokkan dengan kolom `nama` secara langsung
    cur.execute("SELECT id FROM penyakit WHERE LOWER(nama) = %s LIMIT 1", (clean_label.lower(),))
    row = cur.fetchone()
    if row:
        return str(row[0])

    # 2. Gunakan kamus terjemahan bahasa Inggris -> Indonesia
    nama_indo = _CLASS_TO_DISEASE_NAME.get(clean_label)
    if not nama_indo:
        for k, v in _CLASS_TO_DISEASE_NAME.items():
            if _normalize_kelas(k) == kelas_norm:
                nama_indo = v
                break

    if nama_indo:
        cur.execute("SELECT id FROM penyakit WHERE LOWER(nama) = %s LIMIT 1", (nama_indo.lower(),))
        row = cur.fetchone()
        if row:
            return str(row[0])
        cur.execute("SELECT id FROM penyakit WHERE nama ILIKE %s LIMIT 1", (f"%{nama_indo}%",))
        row = cur.fetchone()
        if row:
            return str(row[0])

    # 3. Cocokkan dengan kolom `kelas` jika kolom tersebut ada di tabel
    try:
        cur.execute(
            "SELECT 1 FROM information_schema.columns WHERE table_name = 'penyakit' AND column_name = 'kelas' LIMIT 1"
        )
        if cur.fetchone():
            cur.execute("SELECT id FROM penyakit WHERE LOWER(kelas) = %s LIMIT 1", (kelas_norm,))
            row = cur.fetchone()
            if row:
                return str(row[0])
    except Exception:
        pass

    # 4. Fallback ILIKE
    cur.execute("SELECT id FROM penyakit WHERE nama ILIKE %s LIMIT 1", (f"%{clean_label}%",))
    row = cur.fetchone()
    if row:
        return str(row[0])

    return None


@router.post("", status_code=201)
async def buat_pemindaian(
    id_lahan: str = Form(...),
    bagian_tanaman: Literal["daun", "buah"] = Form(...),
    gambar: UploadFile = File(...),
    # ── Hasil inferensi TFLite dari Flutter (on-device) ──────────────────────
    # Dikirim sebagai form field tambahan. Backend menggunakannya langsung
    # tanpa menjalankan ulang model ML.
    nama_kelas: Optional[str] = Form(None),          # e.g. "Healthy Leaf", "Cercospora"
    status_hasil: Optional[Literal["sehat", "tidak_sehat"]] = Form(None),
    label_hasil: Optional[str] = Form(None),
    skor_keyakinan: Optional[float] = Form(None),     # 0.0 – 100.0
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

    # 3. Bangun hasil ML dari data inferensi Flutter
    id_scan = str(uuid.uuid4())

    # Semua operasi DB dalam SATU blok koneksi
    # (cek ulang kepemilikan agar aman dari race delete di tengah upload)
    with get_db_connection() as conn:
        cur = conn.cursor()

        # Pastikan lahan masih milik pengguna setelah upload selesai
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)

        # Tentukan status dan id_penyakit dari nama kelas yang dikirim Flutter
        label = label_hasil or nama_kelas
        if status_hasil is None:
            status_hasil = "sehat" if label in _HEALTHY_LABELS else "tidak_sehat"

        id_penyakit = None if status_hasil == "sehat" else _resolve_id_penyakit(cur, label)
        keyakinan = skor_keyakinan if skor_keyakinan is not None else 0.0
        hari_ulang = 7 if status_hasil == "sehat" else 3
        tanggal_scan_ulang = date.today() + timedelta(days=hari_ulang)

        cur.execute(
            """
            INSERT INTO pemindaian
                (id, id_lahan, bagian_tanaman, url_gambar, status_hasil,
                 label_hasil, id_penyakit, skor_keyakinan, tanggal_scan_ulang_disarankan)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING *
            """,
            (id_scan, id_lahan, bagian_tanaman, url_gambar, status_hasil,
             label, id_penyakit, keyakinan, tanggal_scan_ulang),
        )
        scan = row_to_dict(cur, cur.fetchone())

        cur.execute(
            "UPDATE lahan SET status_kesehatan = %s WHERE id = %s",
            (status_hasil, id_lahan),
        )

        cur.execute(
            """
            INSERT INTO log_aktivitas (id, id_lahan, jenis_aktivitas, id_referensi, deskripsi)
            VALUES (%s, %s, 'scan', %s, %s)
            """,
            (str(uuid.uuid4()), id_lahan, id_scan,
             f"Scan {bagian_tanaman} ({label or 'unknown'}): {status_hasil}"),
        )

        penanganan = []
        langkah_tindakan = []
        pencegahan = []
        penyakit = None

        if status_hasil == "tidak_sehat" and id_penyakit:
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


@router.get("/penyakit")
def ambil_semua_penyakit():
    """Ambil seluruh daftar penyakit dari tabel penyakit."""
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM penyakit ORDER BY nama ASC")
        return rows_to_dicts(cur)


@router.get("/penyakit/{nama_atau_kelas}")
def ambil_info_penyakit(nama_atau_kelas: str):
    """Ambil data penyakit (nama, nama_latin, deskripsi, penanganan) langsung dari tabel penyakit."""
    with get_db_connection() as conn:
        cur = conn.cursor()
        id_penyakit = _resolve_id_penyakit(cur, nama_atau_kelas)
        if not id_penyakit:
            raise HTTPException(status_code=404, detail=f"Penyakit '{nama_atau_kelas}' tidak ditemukan")

        cur.execute("SELECT * FROM penyakit WHERE id = %s", (id_penyakit,))
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Penyakit tidak ditemukan")

        data = row_to_dict(cur, row)

        # Ambil penanganan terkait dari tabel penanganan jika ada
        cur.execute("SELECT * FROM penanganan WHERE id_penyakit = %s", (id_penyakit,))
        data["daftar_penanganan"] = rows_to_dicts(cur)

        # Jika penanganan di tabel penyakit belum terisi tapi ada di tabel penanganan, rangkai jadi teks
        if not data.get("penanganan") and data["daftar_penanganan"]:
            lines = []
            for item in data["daftar_penanganan"]:
                prod = item.get("nama_produk", "")
                dosis = item.get("dosis", "")
                cara = item.get("cara_pakai", "")
                line = f"- {prod}"
                if dosis:
                    line += f" ({dosis})"
                if cara:
                    line += f": {cara}"
                lines.append(line)
            data["penanganan"] = "\n".join(lines)

        cur.execute(
            "SELECT * FROM langkah_tindakan WHERE id_penyakit = %s ORDER BY urutan ASC",
            (id_penyakit,),
        )
        data["langkah_tindakan"] = rows_to_dicts(cur)

        cur.execute("SELECT * FROM pencegahan WHERE id_penyakit = %s", (id_penyakit,))
        data["pencegahan"] = rows_to_dicts(cur)

        return data


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
