-- Data awal Capsee. Idempotent: aman dijalankan ulang.
-- Prasyarat: backend/schema.sql sudah dijalankan.
-- Cara pakai: psql "$DATABASE_URL" -f backend/seed.sql

-- ── Penyakit: Bercak Daun ────────────────────────────────
INSERT INTO penyakit (nama, deskripsi, nama_latin)
SELECT 'Bercak Daun',
       'Infeksi jamur yang membuat daun berbercak dan rontok.',
       'Cercospora capsici'
WHERE NOT EXISTS (SELECT 1 FROM penyakit WHERE nama = 'Bercak Daun');

-- ── Penanganan ───────────────────────────────────────────
INSERT INTO penanganan (id_penyakit, nama_produk, jenis, dosis, cara_pakai, direkomendasikan, waktu_aplikasi, frekuensi)
SELECT p.id, 'Fungisida Mancozeb', 'kimia', '2 ml/L air',
       'Semprotkan fungisida secara merata.', true, 'Pagi hari', '1 minggu sekali'
FROM penyakit p WHERE p.nama = 'Bercak Daun'
  AND NOT EXISTS (
    SELECT 1 FROM penanganan x
    WHERE x.id_penyakit = p.id AND x.nama_produk = 'Fungisida Mancozeb'
  );

-- ── Langkah tindakan ─────────────────────────────────────
INSERT INTO langkah_tindakan (id_penyakit, urutan, judul, deskripsi)
SELECT p.id, 1, 'Pangkas Daun', 'Pangkas dan buang daun yang terinfeksi.'
FROM penyakit p WHERE p.nama = 'Bercak Daun'
  AND NOT EXISTS (
    SELECT 1 FROM langkah_tindakan x
    WHERE x.id_penyakit = p.id AND x.urutan = 1
  );

-- ── Pencegahan (di live DB masih kosong, jadi wajib ada minimal 1) ──
INSERT INTO pencegahan (id_penyakit, judul, deskripsi)
SELECT p.id, 'Jaga Daun Tetap Kering',
       'Gunakan irigasi tetes pada pagi hari dan hindari penyiraman tajuk agar daun kering sebelum malam.'
FROM penyakit p WHERE p.nama = 'Bercak Daun'
  AND NOT EXISTS (
    SELECT 1 FROM pencegahan x
    WHERE x.id_penyakit = p.id AND x.judul = 'Jaga Daun Tetap Kering'
  );
