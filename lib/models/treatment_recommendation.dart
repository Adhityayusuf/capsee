import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Ringkasan hasil diagnosis yang ditampilkan di bagian atas halaman.
class DiagnosisSummary {
  final String diagnosisId;
  final String plantName;
  final String statusLabel;
  final String diseaseName;
  final String latinName;
  final String dateTime;
  final String severityLabel;
  final double severityProgress; // 0.0 - 1.0, untuk bar visual
  final int aiAccuracyPercent;

  const DiagnosisSummary({
    required this.diagnosisId,
    required this.plantName,
    required this.statusLabel,
    required this.diseaseName,
    required this.latinName,
    required this.dateTime,
    required this.severityLabel,
    required this.severityProgress,
    required this.aiAccuracyPercent,
  });
}

/// Satu langkah pada "Langkah Tindakan Segera".
class ActionStep {
  final IconData icon;
  final String title;
  final String description;

  const ActionStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// Satu opsi solusi penanganan (Organik / Kimia).
class TreatmentOption {
  final String tabLabel;
  final bool recommended;
  final String title;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final String description;
  final String dosis;
  final String waktuAplikasi;
  final String frekuensi;
  final String applicationNote;

  const TreatmentOption({
    required this.tabLabel,
    required this.recommended,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.description,
    required this.dosis,
    required this.waktuAplikasi,
    required this.frekuensi,
    required this.applicationNote,
  });
}

/// Satu kartu pada "Pencegahan Jangka Panjang".
class PreventionTip {
  final IconData icon;
  final String title;
  final String description;

  const PreventionTip({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// ---------------------------------------------------------------
/// Data contoh. Ganti dengan hasil dari API diagnosis saat backend
/// sudah tersedia.
/// ---------------------------------------------------------------
const sampleDiagnosisSummary = DiagnosisSummary(
  diagnosisId: '#CR-8821B',
  plantName: 'Cabai Rawit (Capsicum)',
  statusLabel: 'Waspada',
  diseaseName: 'Bercak Daun Cercospora',
  latinName: 'Cercospora capsici',
  dateTime: '16 Okt 2024 • 08:42 WIB',
  severityLabel: 'Sedang (Bercak 18%)',
  severityProgress: 0.45,
  aiAccuracyPercent: 68,
);

const sampleActionSteps = [
  ActionStep(
    icon: Icons.content_cut_rounded,
    title: 'Pangkas Daun Terinfeksi (Sanitasi Basah)',
    description:
        'Gunting helai daun yang memiliki bercak konsentris abu-abu '
        'dengan gunting steril. Masukkan langsung ke kantong plastik '
        'tertutup.',
  ),
  ActionStep(
    icon: Icons.water_drop_outlined,
    title: 'Hentikan Penyiraman Tajuk (Overhead)',
    description:
        'Sirami langsung ke permukaan tanah/mulsa di pangkal batang. '
        'Jangan basahi permukaan daun untuk menekan perkecambahan '
        'konidia.',
  ),
  ActionStep(
    icon: Icons.fence_outlined,
    title: 'Karantina Pot Tanaman',
    description:
        'Beri jarak minimal 80 cm dari tanaman Solanaceae lain (tomat, '
        'terung) untuk memutus lintasan droplet jamur patogen.',
  ),
];

const sampleTreatmentOptions = [
  TreatmentOption(
    tabLabel: 'Organik',
    recommended: true,
    title: 'Ekstrak Minyak Nimba + Baking Soda',
    badge: 'Alami & Aman',
    badgeColor: AppColors.primarySoft,
    badgeTextColor: AppColors.primaryDark,
    description:
        'Kombinasi fungisida yang menghambat pertumbuhan tabung '
        'kecambah spora jamur tanpa merusak mikrobioma tanah.',
    dosis: '5 ml / 1L Air',
    waktuAplikasi: 'Sore Hari (16:30)',
    frekuensi: '3 Hari Sekali',
    applicationNote:
        'Semprotkan secara merata pada kedua sisi permukaan daun '
        '(terutama punggung bawah daun) hingga basah merata. '
        'Evaluasi setelah 2 putaran semprot.',
  ),
  TreatmentOption(
    tabLabel: 'Kimia',
    recommended: false,
    title: 'Fungisida Kimiawi (Klorotalonil / Mankozeb)',
    badge: 'Perhatikan Dosis',
    badgeColor: Color(0xFFFFEDD5),
    badgeTextColor: Color(0xFFC2410C),
    description:
        'Fungisida kontak berspektrum luas untuk menekan penyebaran '
        'spora secara cepat pada kasus infeksi yang meluas.',
    dosis: '2 gram / 1L Air',
    waktuAplikasi: 'Pagi Hari (07:00)',
    frekuensi: '5-7 Hari Sekali',
    applicationNote:
        'Gunakan sarung tangan & masker saat aplikasi. Hentikan '
        'penyemprotan minimal 7 hari sebelum masa panen (pre-harvest '
        'interval).',
  ),
];

const samplePreventionTips = [
  PreventionTip(
    icon: Icons.wb_sunny_outlined,
    title: 'Optimasi Sirkulasi & Penetrasi Cahaya',
    description:
        'Atur jarak tanam & lakukan pemangkasan tunas air yang rapat. '
        'Pastikan sirkulasi angin bebas agar kelembapan relatif tidak '
        '>85% di sekitar tanaman.',
  ),
  PreventionTip(
    icon: Icons.layers_outlined,
    title: 'Sanitasi Lantai Kebun & Mulsa Perak',
    description:
        'Singkirkan sisa guguran daun kering di atas tanah. Pasang '
        'mulsa plastik hitam-perak untuk memantulkan sinar UV yang '
        'membasmi spora di bawah daun.',
  ),
];