-- Migrasi Neon: interval siram + interval pupuk bebas (idempoten).
-- 1. Interval pupuk: dulu hanya 1/2 minggu → sekarang 1–12 minggu.
-- 2. Kolom baru interval_siram_hari (1–30 hari, default tiap hari).
-- Jalankan sekali di Neon SQL Editor.
ALTER TABLE lahan DROP CONSTRAINT IF EXISTS lands_fertilizing_interval_weeks_check;
ALTER TABLE lahan ADD CONSTRAINT lands_fertilizing_interval_weeks_check
  CHECK (interval_pupuk_minggu BETWEEN 1 AND 12);

ALTER TABLE lahan ADD COLUMN IF NOT EXISTS interval_siram_hari SMALLINT NOT NULL DEFAULT 1;
ALTER TABLE lahan DROP CONSTRAINT IF EXISTS lands_interval_siram_check;
ALTER TABLE lahan ADD CONSTRAINT lands_interval_siram_check
  CHECK (interval_siram_hari BETWEEN 1 AND 30);
