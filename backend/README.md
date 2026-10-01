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
