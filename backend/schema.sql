-- Skema database Capsee (Neon / PostgreSQL).
-- Disalin dari struktur live DB agar repo bisa dipakai ulang di DB kosong.
-- Cara pakai: jalankan file ini sekali di Neon SQL Editor / psql,
-- lalu jalankan seed.sql untuk data awal penyakit.
--
--   psql "$DATABASE_URL" -f backend/schema.sql
--   psql "$DATABASE_URL" -f backend/seed.sql

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── Pengguna ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pengguna (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama VARCHAR NOT NULL,
  email VARCHAR NOT NULL UNIQUE,
  nomor_hp VARCHAR,
  kata_sandi_hash TEXT,
  google_id VARCHAR UNIQUE,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  diperbarui_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Penyakit & turunannya ────────────────────────────────
CREATE TABLE IF NOT EXISTS penyakit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama VARCHAR NOT NULL,
  deskripsi TEXT,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  nama_latin VARCHAR
);

-- ── Lahan ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS lahan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_pengguna UUID NOT NULL REFERENCES pengguna(id) ON DELETE CASCADE,
  nama VARCHAR NOT NULL,
  provinsi VARCHAR NOT NULL,
  kota VARCHAR NOT NULL,
  kecamatan VARCHAR NOT NULL,
  umur_tanaman_bulan SMALLINT NOT NULL CHECK (umur_tanaman_bulan BETWEEN 1 AND 5),
  tanggal_terakhir_siram DATE,
  tanggal_terakhir_pupuk DATE,
  interval_pupuk_minggu SMALLINT NOT NULL CHECK (interval_pupuk_minggu IN (1, 2)),
  status_kesehatan VARCHAR NOT NULL DEFAULT 'belum_discan'
    CHECK (status_kesehatan IN ('sehat', 'tidak_sehat', 'belum_discan')),
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  diperbarui_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Pemindaian ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pemindaian (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_lahan UUID NOT NULL REFERENCES lahan(id) ON DELETE CASCADE,
  bagian_tanaman VARCHAR NOT NULL CHECK (bagian_tanaman IN ('daun', 'buah')),
  url_gambar TEXT NOT NULL,
  status_hasil VARCHAR NOT NULL CHECK (status_hasil IN ('sehat', 'tidak_sehat')),
  id_penyakit UUID REFERENCES penyakit(id),
  skor_keyakinan NUMERIC,
  tanggal_scan_ulang_disarankan DATE,
  dipindai_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  tingkat_keparahan_label VARCHAR,
  tingkat_keparahan_persen NUMERIC,
  kondisi_klorofil NUMERIC,
  tingkat_kebasahan_daun NUMERIC
);

CREATE TABLE IF NOT EXISTS parameter_pemindaian (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_pemindaian UUID NOT NULL REFERENCES pemindaian(id) ON DELETE CASCADE,
  label VARCHAR NOT NULL,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS penanganan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_penyakit UUID NOT NULL REFERENCES penyakit(id) ON DELETE CASCADE,
  nama_produk VARCHAR NOT NULL,
  jenis VARCHAR NOT NULL CHECK (jenis IN ('kimia', 'organik', 'hayati')),
  dosis VARCHAR,
  cara_pakai TEXT,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  direkomendasikan BOOLEAN NOT NULL DEFAULT false,
  waktu_aplikasi VARCHAR,
  frekuensi VARCHAR
);

CREATE TABLE IF NOT EXISTS langkah_tindakan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_penyakit UUID NOT NULL REFERENCES penyakit(id) ON DELETE CASCADE,
  urutan SMALLINT NOT NULL DEFAULT 1,
  judul VARCHAR NOT NULL,
  deskripsi TEXT,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS pencegahan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_penyakit UUID NOT NULL REFERENCES penyakit(id) ON DELETE CASCADE,
  judul VARCHAR NOT NULL,
  deskripsi TEXT,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Jadwal & aktivitas ───────────────────────────────────
CREATE TABLE IF NOT EXISTS jadwal_penyiraman (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_lahan UUID NOT NULL REFERENCES lahan(id) ON DELETE CASCADE,
  tanggal_jadwal DATE NOT NULL,
  status VARCHAR NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'selesai', 'dilewati_hujan')),
  catatan_cuaca VARCHAR,
  selesai_pada TIMESTAMPTZ,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS jadwal_pemupukan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_lahan UUID NOT NULL REFERENCES lahan(id) ON DELETE CASCADE,
  tanggal_jadwal DATE NOT NULL,
  jenis_pupuk VARCHAR,
  status VARCHAR NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'selesai')),
  selesai_pada TIMESTAMPTZ,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Jadwal kegiatan manual (nama + tanggal + deskripsi) ──
CREATE TABLE IF NOT EXISTS jadwal_kegiatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_lahan UUID NOT NULL REFERENCES lahan(id) ON DELETE CASCADE,
  nama_kegiatan VARCHAR(150) NOT NULL CHECK (char_length(btrim(nama_kegiatan)) > 0),
  deskripsi TEXT,
  tanggal_jadwal DATE NOT NULL,
  status VARCHAR NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'selesai')),
  selesai_pada TIMESTAMPTZ,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_jadwal_kegiatan_id_lahan ON jadwal_kegiatan (id_lahan);
CREATE INDEX IF NOT EXISTS idx_jadwal_kegiatan_tanggal ON jadwal_kegiatan (tanggal_jadwal);

CREATE TABLE IF NOT EXISTS log_aktivitas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_lahan UUID NOT NULL REFERENCES lahan(id) ON DELETE CASCADE,
  jenis_aktivitas VARCHAR NOT NULL
    CHECK (jenis_aktivitas IN ('scan', 'siram', 'pupuk', 'peringatan', 'kegiatan_lain')),
  id_referensi UUID,
  deskripsi TEXT NOT NULL,
  terjadi_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  detail_tambahan JSONB
);

CREATE TABLE IF NOT EXISTS notifikasi (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_pengguna UUID NOT NULL REFERENCES pengguna(id) ON DELETE CASCADE,
  id_lahan UUID REFERENCES lahan(id) ON DELETE CASCADE,
  jenis VARCHAR NOT NULL
    CHECK (jenis IN ('siram', 'pupuk', 'scan_ulang', 'cuaca')),
  judul VARCHAR NOT NULL,
  pesan TEXT NOT NULL,
  sudah_dibaca BOOLEAN NOT NULL DEFAULT false,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
