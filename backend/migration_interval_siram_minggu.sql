-- Migrasi Neon: interval siram jadi MINGGUAN (idempoten).
-- Sebelumnya interval_siram_hari (1–30 hari) → sekarang interval_siram_minggu (1–12).
-- Nilai lama >12 minggu dipadatkan ke 12 agar CHECK baru lolos.
-- Jalankan sekali di Neon SQL Editor, SEBELUM update backend.
UPDATE lahan SET interval_siram_hari = LEAST(GREATEST(interval_siram_hari, 1), 12)
  WHERE interval_siram_hari IS NOT NULL;

ALTER TABLE lahan RENAME COLUMN interval_siram_hari TO interval_siram_minggu;

ALTER TABLE lahan DROP CONSTRAINT IF EXISTS lands_interval_siram_check;
ALTER TABLE lahan ADD CONSTRAINT lands_interval_siram_checkin
  CHECK (interval_siram_minggu BETWEEN 1 AND 12);
