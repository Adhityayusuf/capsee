"""
Router cuaca — proxy ke API publik BMKG.

Alur:
1a. Flutter memanggil GET /api/cuaca/{id_lahan} (cuaca per lahan, lama)
1b. Flutter memanggil GET /api/cuaca/profil (cuaca umum ikut identitas diri)
2. Backend lookup kode ADM4 lewat API wilayah emsifa
3. Backend panggil BMKG prakiraan-cuaca?adm4=...
4. Backend kembalikan ringkasan cuaca hari ini + 2 hari ke depan

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


def _kandidat_adm4(kec_id: str, desa_list: list[dict], nama_kota: str) -> list[str]:
    """Susun kandidat kode ADM4 BMKG untuk satu kecamatan.

    Latar: emsifa pakai akhiran 0001.. (Kemendagri), sedangkan BMKG pakai
    1001.. untuk kelurahan (kota) dan 2001.. untuk desa (kabupaten).
    Contoh nyata: Lowokwaru emsifa 3573050004 → BMKG 35.73.05.1006;
    Lembang emsifa 3217050xxx → BMKG 32.17.01.2001.
    Daftar desa emsifa juga bisa kedaluwarsa (mis. Tunggulwulung ada di
    BMKG tapi tidak ada di emsifa), jadi sapu juga 1001-1015/2001-2020.
    """
    kandidat: list[str] = []
    seen: set[str] = set()

    def _dorong(adm4: str) -> None:
        if adm4 and adm4 not in seen:
            seen.add(adm4)
            kandidat.append(adm4)

    # 1. Kode emsifa mentah (legacy, kalau kebetulan cocok).
    for desa in desa_list:
        raw = str(desa.get("id", ""))
        if len(raw) >= 10:
            _dorong(f"{raw[0:2]}.{raw[2:4]}.{raw[4:6]}.{raw[6:]}")

    # 2. Varian 0xxx → 1xxx/2xxx untuk tiap desa emsifa.
    for desa in desa_list:
        raw = str(desa.get("id", ""))
        if len(raw) >= 10 and len(raw[6:]) == 4:
            prefix = f"{raw[0:2]}.{raw[2:4]}.{raw[4:6]}"
            suffix = raw[6:]
            for ganti in ("1", "2"):
                _dorong(f"{prefix}.{ganti}{suffix[1:]}")

    # 3. Sapuan sistematis per kecamatan (tangkap desa yang hilang di emsifa).
    #    Kota → coba 1xxx dulu, kabupaten → 2xxx dulu.
    kota_norm = (nama_kota or "").strip().lower()
    is_kota = kota_norm.startswith("kota")
    urutan = ("1", "2") if is_kota else ("2", "1")
    prefix_kec = ""
    kec = (kec_id or "").strip()
    if len(kec) >= 6:
        prefix_kec = f"{kec[0:2]}.{kec[2:4]}.{kec[4:6]}"
    if prefix_kec:
        for ganti in urutan:
            for i in range(1, 21):
                _dorong(f"{prefix_kec}.{ganti}{i:03d}")

    return kandidat


def _cuaca_untuk_wilayah(nama_provinsi: str, nama_kota: str, nama_kecamatan: str) -> dict:
    """Lookup emsifa → BMKG untuk satu triple wilayah. Dipakai lahan & profil."""
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

            # 3. Panggil API BMKG.
            #    Satu kecamatan punya banyak desa; kode desa pertama tidak
            #    selalu terdaftar di BMKG (404). Coba kandidat sekecamatan
            #    sampai ada yang dikenal BMKG (emsifa 0xxx vs BMKG 1xxx/2xxx).
            bmkg_data = None
            adm4 = ""
            for kode in _kandidat_adm4(str(kec_id), desa_list, nama_kota):
                r = client.get(_BMKG_URL, params={"adm4": kode})
                if r.status_code == 404:
                    continue
                r.raise_for_status()
                bmkg_data = r.json()
                adm4 = kode
                break

            if bmkg_data is None:
                raise HTTPException(
                    status_code=404,
                    detail=f"Cuaca untuk '{nama_kecamatan}, {nama_kota}' belum tersedia di BMKG. "
                           f"Coba lagi nanti atau periksa nama wilayah.",
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


@router.get("/profil")
def cuaca_profil(id_pengguna: str = Depends(verifikasi_token)):
    """
    Ambil prakiraan cuaca BMKG umum mengikuti identitas diri pengguna
    (provinsi + kota + kecamatan di tabel pengguna).

    Dipakai kartu cuaca dashboard. Kalau identitas belum lengkap → 400
    agar frontend mengarahkan ke form identitas.
    """
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute(
            "SELECT provinsi, kota, kecamatan FROM pengguna WHERE id = %s",
            (id_pengguna,),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Pengguna tidak ditemukan")
        nama_provinsi, nama_kota, nama_kecamatan = (
            (row[0] or "").strip(),
            (row[1] or "").strip(),
            (row[2] or "").strip(),
        )
    if not nama_provinsi or not nama_kota or not nama_kecamatan:
        raise HTTPException(
            status_code=400,
            detail="Lengkapi identitas diri (provinsi, kota, kecamatan) dulu untuk melihat cuaca.",
        )
    return _cuaca_untuk_wilayah(nama_provinsi, nama_kota, nama_kecamatan)


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

    return _cuaca_untuk_wilayah(nama_provinsi, nama_kota, nama_kecamatan)
