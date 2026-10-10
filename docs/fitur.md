# Daftar Fitur Capsee

Dokumen ini memuat daftar fitur aplikasi Capsee yang dikelompokkan per modul.
Status yang dipakai:

- **UI** — tampilan sudah tersedia.
- **Dummy** — data masih statis/contoh, belum terhubung backend.
- **Backend** — sudah terhubung ke API FastAPI di folder `backend/`.

## 1. Autentikasi

| Fitur | Deskripsi | Status |
| --- | --- | --- |
| Onboarding | Perkenalan aplikasi sebelum masuk ke alur utama | UI |
| Registrasi akun | Membuat akun petani baru | UI + Backend |
| Login | Masuk menggunakan email dan kata sandi | UI + Backend |
| Lupa kata sandi | Alur pemulihan kata sandi | UI |
| Validasi input | Validasi email, nomor WhatsApp, dan kata sandi | UI |
| Persetujuan syarat | Persetujuan syarat dan kebijakan privasi saat daftar | UI |

Endpoint terkait: `POST /register`, `POST /login`.

## 2. Dashboard

| Fitur | Deskripsi | Status |
| --- | --- | --- |
| Ringkasan kondisi kebun | Sapaan, status sistem diagnostik, ringkasan lahan | UI + Dummy |
| Info cuaca | Lokasi, kondisi cuaca, kelembapan, kecepatan angin | UI + Backend |
| Rekomendasi agronomi | Saran singkat berdasarkan kondisi kebun | Dummy |
| Daftar lahan | Menampilkan lahan terdaftar beserta status kesehatan | UI + Backend |

Endpoint terkait: `GET /cuaca/{id_lahan}`, `GET /lahan`.

## 3. Data Lahan

| Fitur | Deskripsi | Status |
| --- | --- | --- |
| Tambah lahan | Menambahkan data lahan baru | UI + Backend |
| Nama dan lokasi | Mengisi nama lahan dan lokasi kebun | UI + Backend |
| Wilayah | Memilih provinsi, kota/kabupaten, dan kecamatan | UI + Backend |
| Umur tanaman | Mengatur umur tanaman dalam bulan | UI + Backend |
| Riwayat penyiraman | Mencatat tanggal penyiraman terakhir | UI + Backend |
| Riwayat pemupukan | Mencatat tanggal pemupukan terakhir dan intervalnya | UI + Backend |
| Ubah dan hapus lahan | Memperbarui atau menghapus data lahan | UI + Backend |

Endpoint terkait: `POST /lahan`, `GET /lahan`, `GET /lahan/{id}`, `PUT /lahan/{id}`,
`DELETE /lahan/{id}`.

## 4. Detail Lahan

| Fitur | Deskripsi | Status |
| --- | --- | --- |
| Ringkasan lahan | Informasi utama lahan yang dipilih | UI + Backend |
| Scan kesehatan | Pintasan menuju hasil scan tanaman | UI + Dummy |
| Jadwal perawatan | Jadwal penyiraman dan pemupukan | UI + Backend |
| Riwayat aktivitas | Kronologi aktivitas kebun pada lahan tersebut | UI + Backend |

Endpoint terkait: `GET /lahan/{id}/riwayat`, `GET /lahan/{id}/jadwal-penyiraman`,
`GET /lahan/{id}/jadwal-pemupukan`.

## 5. Scan Tanaman

| Fitur | Deskripsi | Status |
| --- | --- | --- |
| Ambil gambar | Mengambil foto tanaman lewat kamera atau galeri | UI |
| Status kesehatan | Menampilkan kondisi sehat atau tidak sehat | Dummy |
| Akurasi AI | Tingkat akurasi model | Dummy |
| Kondisi klorofil | Indikator kadar klorofil | Dummy |
| Status jamur dan hama | Deteksi jamur serta hama | Dummy |
| Suhu dan kelembapan | Data suhu udara dan kelembapan | Dummy |
| Kebasahan daun | Tingkat kebasahan permukaan daun | Dummy |
| Diagnosis penyakit | Nama penyakit hasil analisis | Dummy |

Endpoint terkait: `POST /pemindaian`, `GET /pemindaian/{id}`, `GET /pemindaian/lahan/{id_lahan}`.

## 6. Riwayat Aktivitas

| Fitur | Deskripsi | Status |
| --- | --- | --- |
| Daftar riwayat | Menampilkan seluruh aktivitas kebun | UI + Backend |
| Diagnosa scan AI | Aktivitas hasil pemindaian | UI + Backend |
| Penyiraman | Catatan aktivitas penyiraman | UI + Backend |
| Pemupukan | Catatan aktivitas pemupukan | UI + Backend |
| Peringatan penyakit | Notifikasi adanya penyakit | UI + Backend |
| Diagnosa buah | Aktivitas pemindaian buah | UI + Backend |
| Tindakan perawatan | Catatan perawatan yang dilakukan | UI + Backend |
| Filter jenis | Menyaring riwayat berdasarkan jenis aktivitas | UI |

## 7. Jadwal Perawatan

| Fitur | Deskripsi | Status |
| --- | --- | --- |
| Jadwal penyiraman | Jadwal penyiraman mingguan | UI + Backend |
| Prediksi cuaca | Informasi prakiraan cuaca | UI + Backend |
| Sinkronisasi BMKG | Simulasi data BMKG | Dummy |
| Jadwal pemupukan | Jadwal pemberian nutrisi | UI + Backend |
| Rekomendasi formula | Saran formula pupuk | Dummy |
| Sensor kelembapan | Data kelembapan tanah | Dummy |
| Realisasi | Menandai jadwal yang sudah dilakukan | UI + Backend |

Endpoint terkait: `PATCH /lahan/{id}/jadwal-penyiraman/{id_jadwal}/selesai`,
`PATCH /lahan/{id}/jadwal-pemupukan/{id_jadwal}/selesai`.

## 8. Rekomendasi Penanganan

| Fitur | Deskripsi | Status |
| --- | --- | --- |
| Ringkasan diagnosis | Ringkasan hasil diagnosis | Dummy |
| Tingkat keparahan | Tingkat keparahan penyakit | Dummy |
| Akurasi model | Akurasi model AI | Dummy |
| Penanganan segera | Langkah penanganan awal | Dummy |
| Rekomendasi organik | Saran penanganan organik | Dummy |
| Fungisida kimia | Saran fungisida kimia | Dummy |
| Agen hayati | Saran agen hayati | Dummy |
| Dosis dan waktu | Dosis serta waktu aplikasi | Dummy |
| Tips pencegahan | Pencegahan jangka panjang | Dummy |

## 9. Notifikasi

| Fitur | Deskripsi | Status |
| --- | --- | --- |
| Daftar notifikasi | Notifikasi cuaca dan kondisi tanaman | UI + Backend |
| Tandai dibaca | Menandai notifikasi sebagai sudah dibaca | UI + Backend |

Endpoint terkait: `GET /notifikasi`, `PATCH /notifikasi/{id}/baca`.

## 10. Akun

| Fitur | Deskripsi | Status |
| --- | --- | --- |
| Profil petani | Melihat dan mengubah data profil | UI + Backend |
| Keamanan akun | Mengubah kata sandi | UI + Backend |
| Lahan aktif | Informasi lahan yang sedang aktif | UI + Backend |
| Sensor lapangan | Informasi sensor yang terpasang | Dummy |
| Panduan dan FAQ | Bantuan penggunaan aplikasi | UI |
| Kebijakan privasi | Halaman kebijakan privasi | UI |
| Syarat dan ketentuan | Halaman syarat layanan | UI |

Endpoint terkait: `GET /me`, `PUT /me`, `PUT /me/ganti-sandi`.
