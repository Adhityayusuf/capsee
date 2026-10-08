# Capsee Backend (Python)

Backend FastAPI untuk aplikasi Capsee. Fitur tambahan dibanding versi
Node.js sebelumnya: **kompresi gambar otomatis** (pakai Pillow) sebelum
diupload ke Cloudinary.

Folder ini ditaruh di dalam repo capsee yang sama, sebagai subfolder
`backend/`, sejajar dengan `lib/`, `android/`, dst — bukan dicampur ke
dalam kode Flutter.

## Cara menjalankan

1. Buat virtual environment (opsional tapi disarankan):
   ```
   python -m venv venv
   venv\Scripts\activate        # Windows
   source venv/bin/activate     # Mac/Linux
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Salin `.env.example` jadi `.env`, isi `DATABASE_URL` (dari Neon) dan
   `CLOUDINARY_CLOUD_NAME` + `CLOUDINARY_UPLOAD_PRESET` (dari Cloudinary).

4. Jalankan server:
   ```
   uvicorn app.main:app --reload --port 8000
   ```
   Server berjalan di `http://localhost:8000`.
   Dokumentasi API otomatis (Swagger UI) ada di `http://localhost:8000/docs`
   — ini bawaan FastAPI, berguna untuk testing endpoint tanpa Postman.

   Untuk HP fisik (satu WiFi dengan laptop), ganti `--reload` dengan:
   ```
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```
   lalu samakan `baseUrl` di `lib/services/api_client.dart` dengan IPv4
   laptop (cek via `ipconfig`), misal `http://192.168.75.116:8000`.
   Buka izin firewall Windows untuk port 8000 bila HP tidak bisa konek.

## Skema & seed database (Neon)

`schema.sql` adalah salinan struktur live DB (12 tabel). `seed.sql`
berisi data awal penyakit + penanganan + langkah + pencegahan.
Keduanya idempotent (aman dijalankan ulang).

Jalankan sekali di DB kosong via Neon SQL Editor atau psql:

```
psql "$DATABASE_URL" -f backend/schema.sql
psql "$DATABASE_URL" -f backend/seed.sql
```

Cek kesiapan DB:

```
python cek_db.py
```

Harus keluar `Semua 12 tabel sudah ada. Database siap.`

## Perbedaan penting dari versi Node.js

Endpoint `/api/pemindaian` sekarang menerima **file gambar asli** (bukan
URL Cloudinary), lewat `multipart/form-data`, bukan JSON biasa. Artinya
kode Flutter untuk fitur scan perlu disesuaikan: kirim file langsung ke
backend ini, bukan upload ke Cloudinary dulu dari Flutter.

## Daftar endpoint

Sama persis dengan versi Node.js sebelumnya — lihat `http://localhost:8000/docs`
setelah server jalan untuk daftar lengkap dan interaktif.

## TODO

- Ganti hasil placeholder di `app/routers/pemindaian.py` dengan
  pemanggilan model ML sesungguhnya.
- Integrasi BMKG untuk jadwal penyiraman otomatis.
