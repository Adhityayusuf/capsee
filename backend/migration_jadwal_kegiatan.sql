-- Migrasi Neon: tambah tabel jadwal_kegiatan (idempoten, aman di-run ulang).
-- Jalankan sekali di Neon SQL Editor.
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

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
