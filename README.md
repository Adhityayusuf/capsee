# Capsee

Capsee adalah aplikasi mobile untuk membantu petani memantau kondisi kebun cabai secara lebih teratur. Aplikasi ini menggabungkan pencatatan data lahan, pemantauan kondisi tanaman, riwayat aktivitas, jadwal perawatan, serta hasil analisis kesehatan tanaman.

Project ini dikembangkan menggunakan Flutter sebagai bagian dari kegiatan PBL.

## Tentang Capsee

Pengelolaan kebun cabai membutuhkan pemantauan rutin, terutama terhadap kelembapan, jadwal penyiraman, pemupukan, serta gejala penyakit pada daun dan buah. Capsee dirancang untuk membantu petani menyimpan informasi lahan dan mendapatkan ringkasan kondisi kebun dalam satu aplikasi.

Versi saat ini masih menggunakan data dummy untuk mensimulasikan alur penggunaan aplikasi. Struktur aplikasi telah disiapkan agar nantinya dapat dihubungkan dengan backend, sensor IoT, kamera, dan model machine learning.

## Fitur Utama

### Autentikasi

- Registrasi akun petani
- Login akun
- Validasi email, nomor WhatsApp, dan kata sandi
- Persetujuan syarat dan kebijakan privasi

### Dashboard

- Ringkasan kondisi kebun
- Sapaan dan status sistem diagnostik
- Informasi lokasi dan kondisi cuaca
- Data kelembapan dan kecepatan angin
- Rekomendasi agronomi
- Daftar lahan yang terdaftar
- Status kesehatan setiap lahan

### Data Lahan

- Menambahkan data lahan baru
- Mengisi nama lahan dan lokasi kebun
- Memilih provinsi, kota/kabupaten, dan kecamatan
- Mengatur umur tanaman
- Mencatat tanggal penyiraman terakhir
- Mencatat tanggal pemupukan terakhir
- Mengatur interval pemupukan

### Detail Lahan

Setiap lahan memiliki halaman detail dengan beberapa bagian:

- Scan kesehatan tanaman
- Jadwal penyiraman dan pemupukan
- Riwayat aktivitas kebun

### Scan Tanaman

Data dummy hasil scan menampilkan:

- Status kesehatan tanaman
- Tingkat akurasi AI
- Kondisi klorofil
- Status jamur dan hama
- Data suhu udara
- Data kelembapan
- Tingkat kebasahan daun
- Hasil diagnosis penyakit

### Riwayat Aktivitas

Riwayat lahan berisi beberapa jenis aktivitas:

- Diagnosa scan AI
- Penyiraman
- Pemupukan
- Peringatan penyakit
- Diagnosa buah
- Tindakan perawatan

Riwayat juga dilengkapi filter berdasarkan jenis aktivitas agar informasi lebih mudah dicari.

### Jadwal Perawatan

- Jadwal penyiraman mingguan
- Informasi prediksi cuaca
- Sinkronisasi data BMKG dalam bentuk simulasi
- Jadwal pemupukan
- Rekomendasi formula pupuk
- Data sensor kelembapan tanah
- Pencatatan realisasi penyiraman dan pemupukan

### Rekomendasi Penanganan

Aplikasi menyediakan data dummy rekomendasi untuk penyakit tanaman, meliputi:

- Ringkasan diagnosis
- Tingkat keparahan penyakit
- Akurasi model AI
- Langkah penanganan segera
- Rekomendasi organik
- Rekomendasi fungisida kimia
- Rekomendasi agen hayati
- Dosis dan waktu aplikasi
- Tips pencegahan jangka panjang

### Notifikasi dan Akun

- Daftar notifikasi cuaca dan kondisi tanaman
- Pengaturan profil petani
- Pengaturan keamanan akun
- Informasi lahan aktif
- Informasi sensor lapangan
- Panduan dan FAQ