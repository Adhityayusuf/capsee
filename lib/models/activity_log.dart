import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Kategori aktivitas dalam kronologi, menentukan warna & ikon default.
enum ActivityCategory { scan, irrigation, alert, fertilizer }

extension ActivityCategoryStyle on ActivityCategory {
  Color get color {
    switch (this) {
      case ActivityCategory.scan:
        return AppColors.primary;
      case ActivityCategory.irrigation:
        return AppColors.info;
      case ActivityCategory.alert:
        return AppColors.error;
      case ActivityCategory.fertilizer:
        return AppColors.primary;
    }
  }

  Color get softColor {
    switch (this) {
      case ActivityCategory.scan:
        return AppColors.primarySoft;
      case ActivityCategory.irrigation:
        return AppColors.infoSoft;
      case ActivityCategory.alert:
        return AppColors.errorContainer;
      case ActivityCategory.fertilizer:
        return AppColors.primarySoft;
    }
  }
}

/// Satu chip kecil pada baris statistik footer (mis. "23°C", "Lengas 74%").
class StatItem {
  final IconData icon;
  final String label;
  const StatItem(this.icon, this.label);
}

/// Footer berupa foto sampel + keterangan + tautan (mis. "Lihat >").
class PhotoResult {
  final String caption;
  final String subtitle;
  final String linkLabel;
  const PhotoResult({
    required this.caption,
    required this.subtitle,
    required this.linkLabel,
  });
}

/// Footer berupa kartu hijau "tindakan selesai" + tautan (mis. "Detail >").
class ActionResult {
  final String title;
  final String subtitle;
  final String linkLabel;
  const ActionResult({
    required this.title,
    required this.subtitle,
    required this.linkLabel,
  });
}

/// Satu entri pada Kronologi Aktivitas.
class ActivityLog {
  final ActivityCategory category;
  final IconData icon;
  final String badge;
  final String time;
  final String title;
  final String description;

  /// Isi hanya SATU dari tiga footer berikut (boleh semua null).
  final List<StatItem>? stats;
  final PhotoResult? photo;
  final ActionResult? action;

  const ActivityLog({
    required this.category,
    required this.icon,
    required this.badge,
    required this.time,
    required this.title,
    required this.description,
    this.stats,
    this.photo,
    this.action,
  });
}

/// Data contoh untuk mengisi tampilan Detail Lahan.
/// Ganti dengan data dari API saat backend sudah tersedia.
final List<ActivityLog> sampleActivityLogs = [
  const ActivityLog(
    category: ActivityCategory.scan,
    icon: Icons.check_circle_outline_rounded,
    badge: 'Diagnosa Scan AI',
    time: '09:41 WIB • Hari ini',
    title: 'Tanaman Sehat & Bebas Hama',
    description:
        'SPAD Index 94%, tidak ada bercak atau kutu terdeteksi pada '
        'kanopi daun utama petak cabai.',
    photo: PhotoResult(
      caption: 'Sampel Kanopi #04',
      subtitle: 'Daun Sempurna',
      linkLabel: 'Lihat',
    ),
  ),
  const ActivityLog(
    category: ActivityCategory.irrigation,
    icon: Icons.water_drop_outlined,
    badge: 'Irigasi Tetes Presisi',
    time: '06:30 WIB • Hari ini',
    title: 'Penyiraman Pagi Selesai',
    description:
        'Volume 1.5 L/m² dikombinasikan sensor lengas tanah 69% → 78% '
        'kapasitas lapang. Cuaca sejuk 23°C. Mode adaptif BMKG aktif.',
    stats: [
      StatItem(Icons.thermostat_outlined, '23°C'),
      StatItem(Icons.water_outlined, 'Lengas 74%'),
      StatItem(Icons.bolt_rounded, 'Otomatis'),
    ],
  ),
  const ActivityLog(
    category: ActivityCategory.alert,
    icon: Icons.warning_amber_rounded,
    badge: 'Diagnosa AI: Perlu Tindakan',
    time: '26 Okt • 10:15 WIB',
    title: 'Penyakit Terdeteksi: Bercak Daun Cercospora',
    description:
        'Gejala bercak frogeye leaf spot ~18% area daun. Status: '
        'dilakukan pemangkasan daun bawah & isolasi 4 tanaman terdampak.',
    action: ActionResult(
      title: 'Lihat Rekomendasi Penanganan',
      subtitle: 'Pemangkasan & isolasi 4 tanaman terdampak',
      linkLabel: 'Buka',
    ),
  ),
  const ActivityLog(
    category: ActivityCategory.fertilizer,
    icon: Icons.eco_outlined,
    badge: 'Pemupukan Terjadwal (Interval 7 Hari)',
    time: '24 Okt • 07:30 WIB',
    title: 'Aplikasi Nutrisi NPK 16-16-16 + Kalsium Nitrat',
    description:
        'Dosis kocor 5 gram/tanaman (250 ml larutan/lubang mulsa). '
        'Pelaksana: Pak Budi (Manual). Tanaman merespons baik tanpa '
        'gejala defisiensi kalsium.',
    stats: [
      StatItem(Icons.person_outline_rounded, 'Operator: Pak Budi'),
      StatItem(Icons.water_drop_outlined, '250 ml/Tanaman'),
    ],
  ),
  const ActivityLog(
    category: ActivityCategory.irrigation,
    icon: Icons.search_rounded,
    badge: 'Diagnosa Scan Rutin',
    time: '22 Okt • 14:10 WIB',
    title: 'Pemeriksaan Buah Cabai Rawit',
    description:
        'Bebas antraknosa (Colletotrichum), permukaan tekstur & warna '
        'buah mulai berubah oranye-merah normal.',
    photo: PhotoResult(
      caption: 'Cluster Buah #12',
      subtitle: 'Daun A + Buah 6',
      linkLabel: 'Arsip',
    ),
  ),
  const ActivityLog(
    category: ActivityCategory.scan,
    icon: Icons.spa_outlined,
    badge: 'Diagnosa Scan Buah',
    time: '20 Okt • 09:12 WIB',
    title: 'Buah Cabai Berkembang Normal',
    description:
        'Ukuran buah seragam, warna hijau mengilap, dan tidak ditemukan '
        'gejala antraknosa pada 12 sampel buah dari baris 2–4.',
    stats: [
      StatItem(Icons.thermostat_outlined, '26°C'),
      StatItem(Icons.verified_outlined, '12 Sampel'),
      StatItem(Icons.check_circle_outline, 'Grade A'),
    ],
  ),
  const ActivityLog(
    category: ActivityCategory.fertilizer,
    icon: Icons.compost_outlined,
    badge: 'Pemupukan Selesai',
    time: '17 Okt • 07:15 WIB',
    title: 'Aplikasi Kalsium-Boron Daun',
    description:
        'Penyemprotan nutrisi mikro dilakukan pada pagi hari saat angin '
        'tenang. Daun merespons baik tanpa tanda terbakar atau keriting.',
    action: ActionResult(
      title: 'Perawatan Selesai',
      subtitle: 'Kalsium-Boron • 2 ml/L',
      linkLabel: 'Detail',
    ),
  ),
];
