"""
Router cuaca — prakiraan cuaca 14 hari dari Open-Meteo.

Alur:
1a. Flutter memanggil GET /api/cuaca/{id_lahan} (cuaca per lahan)
1b. Flutter memanggil GET /api/cuaca/profil (cuaca umum ikut identitas diri)
2. Backend cari koordinat wilayah lewat geocoding Open-Meteo
3. Backend panggil Open-Meteo /v1/forecast?forecast_days=14
4. Backend kembalikan ringkasan cuaca per hari (maksimal 14 hari)

Sumber data:
- Open-Meteo : https://open-meteo.com  (tanpa API key, gratis untuk pemakaian
               non-komersial, lisensi data CC BY 4.0 — aplikasi wajib
               mencantumkan "Open-Meteo" sebagai sumber)
"""

import re

import httpx
from fastapi import APIRouter, Depends, HTTPException

from app.access import pastikan_lahan_milik_pengguna
from app.database import get_db_connection, row_to_dict
from app.security import verifikasi_token

router = APIRouter(prefix="/api/cuaca", tags=["Cuaca"])

# ─── Konstanta URL ────────────────────────────────────────────────
_GEO_URL         = "https://geocoding-api.open-meteo.com/v1/search"
_FC_URL          = "https://api.open-meteo.com/v1/forecast"
_FC_DAYS         = 14  # jumlah hari prakiraan yang diminta

_TIMEOUT = 15  # detik

# Kode cuaca WMO (Open-Meteo) → deskripsi bahasa Indonesia / English.
_WMO_ID = {
    0: "Cerah", 1: "Cerah Berawan", 2: "Berawan Sebagian", 3: "Berawan",
    45: "Kabut", 48: "Kabut Embun Beku",
    51: "Gerimis Ringan", 53: "Gerimis", 55: "Gerimis Lebat",
    56: "Gerimis Beku Ringan", 57: "Gerimis Beku",
    61: "Hujan Ringan", 63: "Hujan Sedang", 65: "Hujan Lebat",
    66: "Hujan Beku Ringan", 67: "Hujan Beku",
    71: "Salju Ringan", 73: "Salju", 75: "Salju Lebat", 77: "Butiran Salju",
    80: "Hujan Lokal Ringan", 81: "Hujan Lokal", 82: "Hujan Lokal Lebat",
    85: "Hujan Salju Ringan", 86: "Hujan Salju Lebat",
    95: "Hujan Petir", 96: "Hujan Petir dan Hujan Es",
    99: "Hujan Petir Lebat dan Hujan Es",
}
_WMO_EN = {
    0: "Clear Sky", 1: "Mainly Clear", 2: "Partly Cloudy", 3: "Overcast",
    45: "Fog", 48: "Depositing Rime Fog",
    51: "Light Drizzle", 53: "Drizzle", 55: "Dense Drizzle",
    56: "Freezing Drizzle", 57: "Dense Freezing Drizzle",
    61: "Slight Rain", 63: "Moderate Rain", 65: "Heavy Rain",
    66: "Freezing Rain", 67: "Heavy Freezing Rain",
    71: "Slight Snow", 73: "Moderate Snow", 75: "Heavy Snow",
    77: "Snow Grains",
    80: "Slight Rain Showers", 81: "Moderate Rain Showers",
    82: "Violent Rain Showers", 85: "Snow Showers", 86: "Heavy Snow Showers",
    95: "Thunderstorm", 96: "Thunderstorm with Hail",
    99: "Severe Thunderstorm with Hail",
}

# Kode lama aplikasi → nama resmi wilayah.
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
    """Normalisasi nama wilayah: alias kode lama + buang awalan kab./kota/kec."""
    s = s.strip().lower()
    s = _ALIAS.get(s, s)
    # buang awalan kab./kota/kec. dan tanda baca agar "Kab. Bandung Barat"
    # cocok dengan "BANDUNG BARAT".
    s = re.sub(r"^(kab\.?|kota|kec\.?|kecamatan)\s+", "", s)
    s = re.sub(r"[^a-z0-9 ]", "", s)
    return re.sub(r"\s+", " ", s).strip()


def _cocok(a: str, b: str) -> bool:
    """Cocokkan dua nama wilayah ternormalisasi (exact atau saling berisi)."""
    if not a or not b:
        return False
    return a == b or a in b or b in a


# ─── Open-Meteo — sumber utama (prakiraan 14 hari) ───────────────
# Dokumentasi : https://open-meteo.com/en/docs
# Tanpa API key, gratis untuk pemakaian non-komersial (≤10.000 req/hari),
# lisensi data CC BY 4.0 → aplikasi wajib mencantumkan "Open-Meteo".

_ARAH_8 = ("U", "TL", "T", "TG", "S", "BD", "B", "BL")


def _ambil(baris, i: int):
    """Ambil baris ke-i dari list apa pun (aman terhadap None/pendek)."""
    if isinstance(baris, list) and i < len(baris):
        return baris[i]
    return None


def _arah_dari_derajat(nilai) -> str | None:
    """Derajat arah angin (0-360) → label kompas Indonesia."""
    if nilai is None:
        return None
    try:
        sudut = float(nilai) % 360
    except (TypeError, ValueError):
        return None
    return _ARAH_8[round(sudut / 45) % 8]


def _ikon_wmo(kode) -> str:
    """Kode cuaca WMO → nama ikon Material agar frontend tinggal pakai."""
    try:
        k = int(kode)
    except (TypeError, ValueError):
        return "wb_sunny_rounded"
    if k <= 1:
        return "wb_sunny_rounded"
    if k <= 3:
        return "cloud_rounded"
    if k in (45, 48):
        return "fog_rounded"
    if k <= 67:
        return "rainy_rounded"
    if k <= 77:
        return "ac_unit_rounded"
    if k <= 86:
        return "shower_rounded"
    return "thunderstorm_rounded"


def _geocode_open_meteo(
    nama_provinsi: str, nama_kota: str, nama_kecamatan: str
) -> dict | None:
    """Cari koordinat wilayah lewat geocoding Open-Meteo.

    Kandidat nama dicoba dari yang paling spesifik (kecamatan → kota →
    provinsi). Tiap hasil diberi skor kecocokan provinsi/kota/kecamatan,
    hasil dengan skor terbaik yang lolos ambang dipakai. Gagal → None
    (pemanggil melempar 404 dengan pesan wilayah tidak ditemukan).
    """
    prov, kota, kec = _norm(nama_provinsi), _norm(nama_kota), _norm(nama_kecamatan)
    if not (prov or kota or kec):
        return None

    kandidat = [n for n in (nama_kecamatan, nama_kota, nama_provinsi) if _norm(n)]
    try:
        with httpx.Client(timeout=_TIMEOUT) as client:
            for nama in kandidat:
                r = client.get(
                    _GEO_URL,
                    params={
                        "name"    : _norm(nama),
                        "count"   : 10,
                        "language": "id",
                        "country" : "ID",
                    },
                )
                if r.status_code != 200:
                    continue

                terbaik, skor_terbaik = None, -1
                for item in r.json().get("results") or []:
                    if item.get("country_code") != "ID":
                        continue
                    admin1 = _norm(str(item.get("admin1") or ""))
                    admin2 = _norm(str(item.get("admin2") or ""))
                    nama_hasil = _norm(str(item.get("name") or ""))

                    skor = 0
                    if prov:
                        skor += 4 if _cocok(admin1, prov) else -10
                    if kota and admin2:
                        skor += 3 if _cocok(admin2, kota) else -2
                    if kec and _cocok(nama_hasil, kec):
                        skor += 3
                    elif kota and _cocok(nama_hasil, kota):
                        skor += 2
                    if skor > skor_terbaik:
                        terbaik, skor_terbaik = item, skor

                if terbaik is not None and skor_terbaik >= 4:
                    return {
                        "provinsi"      : terbaik.get("admin1") or nama_provinsi,
                        "kota_kabupaten": terbaik.get("admin2") or nama_kota,
                        "kecamatan"     : terbaik.get("admin3") or nama_kecamatan,
                        "desa"          : terbaik.get("admin4"),
                        "lat"           : terbaik.get("latitude"),
                        "lon"           : terbaik.get("longitude"),
                        "kode_adm4"     : None,
                    }
    except httpx.HTTPError:
        return None
    return None


def _prakiraan_open_meteo(lat, lon) -> list[dict]:
    """Ambil prakiraan harian Open-Meteo (maksimal 14 hari) untuk 1 titik.

    Respons harian dipadukan dengan data per jam (kelembapan rata-rata &
    suhu pukul 12:00) supaya bentuk keluaran konsisten dengan yang sudah
    dipakai frontend.
    """
    params = {
        "latitude"          : lat,
        "longitude"         : lon,
        "daily"             : ",".join([
            "weather_code",
            "temperature_2m_max",
            "temperature_2m_min",
            "precipitation_sum",
            "precipitation_probability_max",
            "wind_speed_10m_max",
            "wind_gusts_10m_max",
            "wind_direction_10m_dominant",
        ]),
        "hourly"            : "relative_humidity_2m,temperature_2m",
        "forecast_days"     : _FC_DAYS,
        "timezone"          : "auto",       # ikuti zona lokasi lahan
        "wind_speed_unit"   : "kmh",
    }
    with httpx.Client(timeout=_TIMEOUT) as client:
        r = client.get(_FC_URL, params=params)
    if r.status_code != 200:
        raise HTTPException(
            status_code=502,
            detail=f"Open-Meteo tidak merespons ({r.status_code})",
        )

    data = r.json()
    daily = data.get("daily") or {}
    tanggal = daily.get("time") or []
    if not tanggal:
        raise HTTPException(status_code=502, detail="Open-Meteo tidak mengembalikan prakiraan")

    # Kelompokkan data per jam per tanggal (untuk kelembapan & suhu siang).
    hourly = data.get("hourly") or {}
    lembap_per_hari: dict[str, list[float]] = {}
    for t, v in zip(hourly.get("time") or [], hourly.get("relative_humidity_2m") or []):
        if v is not None:
            lembap_per_hari.setdefault(str(t)[:10], []).append(float(v))
    suhu_per_jam = {
        str(t): float(v)
        for t, v in zip(hourly.get("time") or [], hourly.get("temperature_2m") or [])
        if v is not None
    }

    ringkasan: list[dict] = []
    for i, tgl in enumerate(tanggal):
        tgl = str(tgl)[:10]
        kode = _ambil(daily.get("weather_code"), i)
        tmax = _ambil(daily.get("temperature_2m_max"), i)
        tmin = _ambil(daily.get("temperature_2m_min"), i)
        mm = _ambil(daily.get("precipitation_sum"), i)
        prob = _ambil(daily.get("precipitation_probability_max"), i)
        angin = _ambil(daily.get("wind_speed_10m_max"), i)
        gust = _ambil(daily.get("wind_gusts_10m_max"), i)
        arah = _ambil(daily.get("wind_direction_10m_dominant"), i)

        daftar_lembap = lembap_per_hari.get(tgl) or []
        kelembapan = round(sum(daftar_lembap) / len(daftar_lembap)) if daftar_lembap else None

        suhu = suhu_per_jam.get(f"{tgl}T12:00")
        if suhu is None and tmax is not None and tmin is not None:
            suhu = round((float(tmax) + float(tmin)) / 2)
        elif suhu is not None:
            suhu = round(suhu)

        kemungkinan_hujan = (prob is not None and float(prob) >= 60) or (
            mm is not None and float(mm) >= 1
        )

        ringkasan.append({
            "waktu_lokal"      : f"{tgl} 12:00:00",
            "suhu"             : suhu,
            "suhu_max"         : round(float(tmax)) if tmax is not None else None,
            "suhu_min"         : round(float(tmin)) if tmin is not None else None,
            "kelembapan"       : kelembapan,
            "cuaca"            : _WMO_ID.get(int(kode), "Tidak diketahui")
                                 if kode is not None else "Tidak diketahui",
            "cuaca_en"         : _WMO_EN.get(int(kode), "Unknown")
                                 if kode is not None else "Unknown",
            "ikon"             : _ikon_wmo(kode),
            "kecepatan_angin"  : round(float(angin), 1) if angin is not None else None,
            "gust_maks"        : round(float(gust), 1) if gust is not None else None,
            "arah_angin"       : _arah_dari_derajat(arah),
            "kemungkinan_hujan": bool(kemungkinan_hujan),
            "kemungkinan_hujan_persen": int(float(prob)) if prob is not None else None,
            "curah_hujan_mm"   : round(float(mm), 1) if mm is not None else None,
        })
    return ringkasan


def _cuaca_untuk_wilayah(nama_provinsi: str, nama_kota: str, nama_kecamatan: str) -> dict:
    """Cuaca satu wilayah — 14 hari dari Open-Meteo.

    Urutan:
    1. Geocoding Open-Meteo → lat/lon (1 request, cepat).
    2. Forecast Open-Meteo → ringkasan per hari.
    3. Gagal → 404/502 dengan pesan jelas, frontend menampilkan state
       error + tombol Coba lagi.
    """
    lokasi = _geocode_open_meteo(nama_provinsi, nama_kota, nama_kecamatan)
    if lokasi is None or lokasi.get("lat") is None:
        raise HTTPException(
            status_code=404,
            detail=f"Lokasi '{nama_kecamatan}, {nama_kota}, {nama_provinsi}' "
                   f"tidak ditemukan. Periksa nama wilayah di identitas diri.",
        )

    try:
        prakiraan = _prakiraan_open_meteo(lokasi["lat"], lokasi["lon"])
    except httpx.HTTPError as exc:
        raise HTTPException(
            status_code=502,
            detail=f"Gagal mengambil data cuaca: {exc}",
        ) from exc

    return {
        "sumber"  : "Open-Meteo",
        "lokasi"  : lokasi,
        "prakiraan": prakiraan,
    }


@router.get("/profil")
def cuaca_profil(id_pengguna: str = Depends(verifikasi_token)):
    """
    Ambil prakiraan cuaca umum mengikuti identitas diri pengguna
    (provinsi + kota + kecamatan di tabel pengguna).

    Sumber: Open-Meteo (prakiraan 14 hari).
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
    Ambil prakiraan cuaca untuk lahan milik pengguna yang login.

    Mengembalikan:
    - sumber   : "Open-Meteo"
    - lokasi   : dict (provinsi, kota, kecamatan, desa, lat, lon, kode_adm4)
    - prakiraan: list ringkasan cuaca per hari (tanggal, ikon, suhu,
                 kemungkinan hujan, curah hujan, angin, arah angin)
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
