"""
Router cuaca — proxy ke API publik BMKG.

Alur:
1. Flutter memanggil GET /api/cuaca/{id_lahan}
2. Backend ambil data lahan (provinsi + kota + kecamatan) dari DB
3. Backend cari kode ADM4 lewat API wilayah emsifa
4. Backend panggil BMKG prakiraan-cuaca?adm4=...
5. Backend kembalikan ringkasan cuaca hari ini + 2 hari ke depan

Sumber data BMKG: https://api.bmkg.go.id/publik/prakiraan-cuaca
Wajib mencantumkan BMKG sebagai sumber pada tampilan aplikasi.
"""

import httpx
from fastapi import APIRouter, Depends, HTTPException

from app.access import pastikan_lahan_milik_pengguna
from app.database import get_db_connection, row_to_dict
from app.security import verifikasi_token

router = APIRouter(prefix="/api/cuaca", tags=["Cuaca"])

# ─── Konstanta URL ────────────────────────────────────────────────
_BMKG_URL        = "https://api.bmkg.go.id/publik/prakiraan-cuaca"
_PROV_URL        = "https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json"
_KOTA_URL        = "https://www.emsifa.com/api-wilayah-indonesia/api/regencies/{prov_id}.json"
_KEC_URL         = "https://www.emsifa.com/api-wilayah-indonesia/api/districts/{kota_id}.json"
_DESA_URL        = "https://www.emsifa.com/api-wilayah-indonesia/api/villages/{kec_id}.json"

_TIMEOUT = 15  # detik


def _cari_id(data: list[dict], nama: str, field: str = "name") -> str | None:
    """Cari id dari list wilayah berdasarkan nama.

    Tahan terhadap data lama aplikasi yang tersimpan sebagai KODE
    (jabar/kbb/lembang...) maupun varian penulisan (Kab./Kota/dll):
    normalisasi + alias → exact → partial match.
    """
    import re

    # Kode lama aplikasi → nama resmi.
    _ALIAS = {
        "jabar": "jawa barat", "jateng": "jawa tengah", "jatim": "jawa timur",
        "sumut": "sumatera utara", "sumsel": "sumatera selatan",
        "sumbar": "sumatera barat", "riau": "riau", "jambi": "jambi",
        "bengkulu": "bengkulu", "lampung": "lampung", "babel": "kepulauan bangka belitung",
        "kepri": "kepulauan riau", "dki": "dki jakarta", "jakarta": "dki jakarta",
        "banten": "banten", "diy": "di yogyakarta", "yogya": "di yogyakarta",
        "bali": "bali", "ntb": "nusa tenggara barat", "ntt": "nusa tenggara timur",
        "kalbar": "kalimantan barat", "kalteng": "kalimantan tengah",
        "kalsel": "kalimantan selatan", "kaltim": "kalimantan timur",
        "kaltara": "kalimantan utara", "sulut": "sulawesi utara",
        "sulteng": "sulawesi tengah", "sulsel": "sulawesi selatan",
        "sultra": "sulawesi tenggara", "sulbar": "sulawesi barat",
        "gorontalo": "gorontalo", "maluku": "maluku", "malut": "maluku utara",
        "papua": "papua", "papuabarat": "papua barat",
        "kbb": "bandung barat", "bdg": "bandung", "grt": "garut", "cjr": "cianjur",
        "lembang": "lembang", "parongpong": "parongpong",
        "cisarua": "cisarua", "ngamprah": "ngamprah",
    }

    def _norm(s: str) -> str:
        s = s.strip().lower()
        s = _ALIAS.get(s, s)
        # buang awalan kab./kota/kec. dan tanda baca agar "Kab. Bandung Barat"
        # cocok dengan "BANDUNG BARAT".
        s = re.sub(r"^(kab\.?|kota|kec\.?|kecamatan)\s+", "", s)
        s = re.sub(r"[^a-z0-9 ]", "", s)
        return re.sub(r"\s+", " ", s).strip()

    target = _norm(nama)
    if not target:
        return None
    # 1. exact match ternormalisasi
    for item in data:
        if _norm(str(item.get(field, ""))) == target:
            return item["id"]
    # 2. partial match dua arah
    for item in data:
        norm_item = _norm(str(item.get(field, "")))
        if target in norm_item or norm_item in target:
            return item["id"]
    return None


def _ringkas_cuaca(cuaca_raw: list[list[dict]]) -> list[dict]:
    """
    Dari list-of-list prakiraan per hari BMKG, ambil item pertama
    setiap hari dan bentuk ringkasan yang ramah frontend.

    Setiap item:
      - waktu_lokal      : str   ("2026-10-06 09:00:00")
      - suhu             : int   (°C)
      - kelembapan       : int   (%)
      - cuaca            : str   (deskripsi bahasa Indonesia)
      - cuaca_en         : str
      - ikon             : str   (URL SVG dari BMKG)
      - kecepatan_angin  : float (km/h)
      - arah_angin       : str
      - kemungkinan_hujan: bool  (weather code >= 60)
    """
    ringkasan = []
    for hari in cuaca_raw:
        if not hari:
            continue
        item = hari[0]  # ambil prakiraan awal hari
        ringkasan.append({
            "waktu_lokal"      : item.get("local_datetime"),
            "suhu"             : item.get("t"),
            "kelembapan"       : item.get("hu"),
            "cuaca"            : item.get("weather_desc"),
            "cuaca_en"         : item.get("weather_desc_en"),
            "ikon"             : item.get("image"),
            "kecepatan_angin"  : item.get("ws"),
            "arah_angin"       : item.get("wd"),
            "kemungkinan_hujan": (item.get("weather", 0) or 0) >= 60,
        })
    return ringkasan


@router.get("/{id_lahan}")
def cuaca_lahan(id_lahan: str, id_pengguna: str = Depends(verifikasi_token)):
    """
    Ambil prakiraan cuaca BMKG untuk lahan milik pengguna yang login.

    Mengembalikan:
    - sumber   : "BMKG"
    - lokasi   : dict (dari BMKG — provinsi, kota, kecamatan, desa, lat, lon)
    - prakiraan: list ringkasan cuaca per hari (3 hari ke depan)
    """
    # 1. Ambil data lahan dari DB
    with get_db_connection() as conn:
        cur = conn.cursor()
        pastikan_lahan_milik_pengguna(cur, id_lahan, id_pengguna)
        cur.execute("SELECT * FROM lahan WHERE id = %s", (id_lahan,))
        lahan = row_to_dict(cur, cur.fetchone())

    nama_provinsi  = lahan.get("provinsi", "")
    nama_kota      = lahan.get("kota", "")
    nama_kecamatan = lahan.get("kecamatan", "")

    # 2. Lookup kode ADM4 via API emsifa
    try:
        with httpx.Client(timeout=_TIMEOUT) as client:
            # Provinsi
            r = client.get(_PROV_URL)
            r.raise_for_status()
            prov_id = _cari_id(r.json(), nama_provinsi)
            if not prov_id:
                raise HTTPException(
                    status_code=404,
                    detail=f"Provinsi '{nama_provinsi}' tidak ditemukan di data wilayah"
                )

            # Kota / Kabupaten
            r = client.get(_KOTA_URL.format(prov_id=prov_id))
            r.raise_for_status()
            kota_id = _cari_id(r.json(), nama_kota)
            if not kota_id:
                raise HTTPException(
                    status_code=404,
                    detail=f"Kota/Kabupaten '{nama_kota}' tidak ditemukan"
                )

            # Kecamatan
            r = client.get(_KEC_URL.format(kota_id=kota_id))
            r.raise_for_status()
            kec_id = _cari_id(r.json(), nama_kecamatan)
            if not kec_id:
                raise HTTPException(
                    status_code=404,
                    detail=f"Kecamatan '{nama_kecamatan}' tidak ditemukan"
                )

            # Desa pertama di kecamatan → kode ADM4
            r = client.get(_DESA_URL.format(kec_id=kec_id))
            r.raise_for_status()
            desa_list = r.json()
            if not desa_list:
                raise HTTPException(
                    status_code=404,
                    detail=f"Tidak ada data desa/kelurahan untuk kecamatan '{nama_kecamatan}'"
                )

            # Konversi kode emsifa (tanpa titik, 10 digit) → format BMKG (titik, e.g. "35.07.01.1001")
            # (kode dipakai di langkah 3; desa pertama belum tentu dikenal BMKG)

            # 3. Panggil API BMKG.
            #    Satu kecamatan punya banyak desa; kode desa pertama tidak
            #    selalu terdaftar di BMKG (404). Coba desa lain sekecamatan
            #    sampai ada yang dikenal BMKG.
            bmkg_data = None
            adm4 = ""
            for desa in desa_list[:8]:
                raw = str(desa.get("id", ""))
                if len(raw) < 10:
                    continue
                adm4 = f"{raw[0:2]}.{raw[2:4]}.{raw[4:6]}.{raw[6:]}"
                r = client.get(_BMKG_URL, params={"adm4": adm4})
                if r.status_code == 404:
                    continue
                r.raise_for_status()
                bmkg_data = r.json()
                break

            if bmkg_data is None:
                raise HTTPException(
                    status_code=404,
                    detail=f"Kecamatan '{nama_kecamatan}' tidak terdaftar di BMKG. "
                           f"Perbaiki nama provinsi/kota/kecamatan lewat Edit Lahan."
                )

    except httpx.HTTPError as exc:
        raise HTTPException(
            status_code=502,
            detail=f"Gagal mengambil data cuaca: {exc}"
        )

    # 4. Parsing & ringkasan
    data_list = bmkg_data.get("data", [])
    if not data_list:
        raise HTTPException(status_code=502, detail="Data cuaca BMKG kosong")

    cuaca_raw   = data_list[0].get("cuaca", [])
    lokasi_bmkg = bmkg_data.get("lokasi", {})

    return {
        "sumber": "BMKG",
        "lokasi": {
            "provinsi"        : lokasi_bmkg.get("provinsi"),
            "kota_kabupaten"  : lokasi_bmkg.get("kotkab"),
            "kecamatan"       : lokasi_bmkg.get("kecamatan"),
            "desa"            : lokasi_bmkg.get("desa"),
            "lat"             : lokasi_bmkg.get("lat"),
            "lon"             : lokasi_bmkg.get("lon"),
            "kode_adm4"       : adm4,
        },
        "prakiraan": _ringkas_cuaca(cuaca_raw),
    }
