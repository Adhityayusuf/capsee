# Test Case Capsee

Dokumen ini memuat skenario pengujian aplikasi Capsee, baik pengujian otomatis
(widget test Flutter) maupun pengujian manual per fitur.

Status yang dipakai: **Lulus**, **Gagal**, **Belum diuji**.

## 1. Pengujian Otomatis

Dijalankan dengan `flutter test`. Berkas berada di folder `test/`.

| ID | Berkas | Skenario | Hasil yang Diharapkan | Status |
| --- | --- | --- | --- | --- |
| AT-01 | `widget_test.dart` | Aplikasi pertama kali dibuka | Halaman `Daftar Akun Capsee` tampil | Lulus |
| AT-02 | `widget_test.dart` | Membuka halaman tambah lahan | Teks `Tambah Data Lahan` tampil | Lulus |
| AT-03 | `widget_test.dart` | Membuka detail lahan | Kronologi aktivitas dan diagnosis penyakit tampil | Lulus |
| AT-04 | `widget_test.dart` | Berpindah ke tab Jadwal | `Jadwal Penyiraman Mingguan` dan `Jadwal Nutrisi & Pemupukan` tampil | Lulus |
| AT-05 | `widget_test.dart` | Berpindah ke tab Scan | Hasil scan terakhir dan sensor realtime tampil | Lulus |
| AT-06 | `bottom_nav_test.dart` | Memeriksa bottom navigation | Terdapat 5 slot menu | Lulus |
| AT-07 | `bottom_nav_test.dart` | Menekan tab Riwayat | Halaman riwayat scan tampil | Lulus |

## 2. Pengujian Manual

### Autentikasi

| ID | Skenario | Langkah | Hasil yang Diharapkan | Status |
| --- | --- | --- | --- | --- |
| TC-AUTH-01 | Registrasi valid | Isi email, WhatsApp, dan kata sandi yang valid, centang syarat, kirim | Akun dibuat dan diarahkan ke dashboard | Belum diuji |
| TC-AUTH-02 | Email tidak valid | Isi email dengan format salah | Pesan kesalahan pada kolom email | Belum diuji |
| TC-AUTH-03 | Kata sandi lemah | Isi kata sandi di bawah ketentuan | Pesan kesalahan pada kolom kata sandi | Belum diuji |
| TC-AUTH-04 | Syarat belum dicentang | Isi data valid tanpa mencentang syarat | Tombol daftar tidak dapat diproses | Belum diuji |
| TC-AUTH-05 | Login valid | Masukkan email dan kata sandi terdaftar | Masuk ke dashboard | Belum diuji |
| TC-AUTH-06 | Login salah | Masukkan kata sandi salah | Pesan kesalahan tampil | Belum diuji |

### Data Lahan

| ID | Skenario | Langkah | Hasil yang Diharapkan | Status |
| --- | --- | --- | --- | --- |
| TC-LAHAN-01 | Tambah lahan | Isi seluruh field lahan lalu simpan | Lahan baru muncul di daftar | Belum diuji |
| TC-LAHAN-02 | Field kosong | Simpan tanpa mengisi field wajib | Validasi menampilkan pesan kesalahan | Belum diuji |
| TC-LAHAN-03 | Pilih wilayah | Pilih provinsi, kota, kecamatan | Pilihan tersimpan sesuai data wilayah | Belum diuji |
| TC-LAHAN-04 | Ubah lahan | Ubah data lahan yang ada lalu simpan | Perubahan tersimpan | Belum diuji |
| TC-LAHAN-05 | Hapus lahan | Hapus lahan dari daftar | Lahan hilang dari daftar | Belum diuji |

### Scan dan Rekomendasi

| ID | Skenario | Langkah | Hasil yang Diharapkan | Status |
| --- | --- | --- | --- | --- |
| TC-SCAN-01 | Ambil gambar | Pilih kamera atau galeri lalu ambil gambar | Gambar tampil pada halaman scan | Belum diuji |
| TC-SCAN-02 | Hasil scan sehat | Jalankan scan pada tanaman sehat | Status sehat beserta data sensor tampil | Belum diuji |
| TC-SCAN-03 | Hasil scan tidak sehat | Jalankan scan pada tanaman berpenyakit | Diagnosis dan tombol rekomendasi tampil | Belum diuji |
| TC-SCAN-04 | Buka rekomendasi | Tekan `Lihat Rekomendasi Penanganan` | Halaman rekomendasi tampil lengkap | Belum diuji |

### Jadwal dan Riwayat

| ID | Skenario | Langkah | Hasil yang Diharapkan | Status |
| --- | --- | --- | --- | --- |
| TC-JADWAL-01 | Lihat jadwal | Buka tab Jadwal pada detail lahan | Jadwal penyiraman dan pemupukan tampil | Belum diuji |
| TC-JADWAL-02 | Tandai selesai | Tandai jadwal sebagai selesai | Status jadwal berubah dan tercatat | Belum diuji |
| TC-RIWAYAT-01 | Lihat riwayat | Buka tab riwayat aktivitas | Daftar aktivitas tampil berurutan | Belum diuji |
| TC-RIWAYAT-02 | Filter riwayat | Pilih salah satu jenis aktivitas | Hanya aktivitas sesuai filter yang tampil | Belum diuji |

### Notifikasi dan Akun

| ID | Skenario | Langkah | Hasil yang Diharapkan | Status |
| --- | --- | --- | --- | --- |
| TC-NOTIF-01 | Lihat notifikasi | Buka halaman notifikasi | Daftar notifikasi tampil | Belum diuji |
| TC-NOTIF-02 | Tandai dibaca | Tekan salah satu notifikasi | Status notifikasi berubah menjadi dibaca | Belum diuji |
| TC-AKUN-01 | Edit profil | Ubah nama atau data profil lalu simpan | Profil diperbarui | Belum diuji |
| TC-AKUN-02 | Ubah kata sandi | Isi kata sandi lama dan baru dengan benar | Kata sandi berhasil diubah | Belum diuji |
| TC-AKUN-03 | Kata sandi lama salah | Isi kata sandi lama yang salah | Pesan kesalahan tampil | Belum diuji |
