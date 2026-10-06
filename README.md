# Capsee

Aplikasi mobile untuk membantu petani memantau kondisi kebun cabai secara lebih
teratur. Capsee menggabungkan pencatatan data lahan, pemantauan kondisi tanaman,
riwayat aktivitas, jadwal perawatan, serta hasil analisis kesehatan tanaman.

Dikembangkan menggunakan Flutter, dengan backend FastAPI di folder `backend/`,
sebagai bagian dari kegiatan PBL.

## UI Design

[![Buka di Figma](https://img.shields.io/badge/Figma-Design-blue)](https://www.figma.com/design/l8uP3WlKO9h2eBlMCQ3nN0/PBL---Capsee?node-id=0-1&t=4mYiw0519STWqdEU-1)

Pratinjau setiap layar tersedia di [design/README.md](design/README.md).

## Fitur

Daftar fitur lengkap per modul ada di [docs/fitur.md](docs/fitur.md).

- **Autentikasi** — registrasi, login, validasi, dan persetujuan syarat
- **Dashboard** — ringkasan kebun, cuaca, rekomendasi, daftar lahan
- **Data Lahan** — tambah, ubah, dan hapus lahan beserta riwayat perawatan
- **Detail Lahan** — scan kesehatan, jadwal perawatan, riwayat aktivitas
- **Scan Tanaman** — analisis kesehatan, hama, penyakit, dan data sensor
- **Riwayat Aktivitas** — kronologi kebun dengan filter jenis aktivitas
- **Jadwal Perawatan** — penyiraman, pemupukan, dan sinkronisasi cuaca
- **Rekomendasi Penanganan** — langkah penanganan dan pencegahan penyakit
- **Notifikasi** — pemberitahuan cuaca dan kondisi tanaman
- **Akun** — profil, keamanan, panduan, dan halaman legal

## Test Case

Skenario pengujian otomatis dan manual ada di
[docs/test-case.md](docs/test-case.md).

## Download Aplikasi

APK akan tersedia melalui tautan distribusi Relay dan GitHub Releases setelah
build rilis disiapkan.

<!-- TODO: ganti bagian ini dengan link Relay dan GitHub Releases
- Relay: <link>
- GitHub Releases: <link>
-->

## Menjalankan Proyek

### Aplikasi (Flutter)

```
flutter pub get
flutter run
```

Membangun APK rilis:

```
flutter build apk --release
```

Hasil build berada di `build/app/outputs/flutter-apk/app-release.apk`.

### Backend (FastAPI)

Petunjuk lengkap ada di [backend/README.md](backend/README.md).

```
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

## Struktur Repo

```
capsee/
├── README.md      # halaman utama
├── docs/          # fitur dan test case
├── design/        # link Figma dan pratinjau UI
├── lib/           # kode aplikasi Flutter
├── android/       # konfigurasi Android
├── backend/       # API FastAPI
└── test/          # widget test
```

## Pengujian

```
flutter test
```
