import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_theme.dart';
import '../models/land_data.dart';

TextStyle _style(
  double size,
  Color color,
  FontWeight weight, {
  double? height,
  double? letterSpacing,
}) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
  letterSpacing: letterSpacing,
);

/// Ubah satu map lahan dari API menjadi [LandData].
LandData landDataFromMap(Map<String, dynamic> land) {
  DateTime parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  return LandData(
    id: land['id'] as String?,
    name: land['nama'] ?? 'Lahan',
    province: land['provinsi'] ?? '',
    city: land['kota'] ?? '',
    district: land['kecamatan'] ?? '',
    plantAgeMonths: land['umur_tanaman_bulan'] ?? 1,
    lastWatered: parseDate(land['tanggal_terakhir_siram']),
    lastFertilized: parseDate(land['tanggal_terakhir_pupuk']),
    fertilizeIntervalWeeks: land['interval_pupuk_minggu'] ?? 1,
  );
}

/// Kartu ringkasan satu petak lahan. Dipakai di Beranda dan tab Lahan.
class LandCard extends StatelessWidget {
  final Map<String, dynamic> land;
  final VoidCallback onDetail;
  final VoidCallback onScan;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LandCard({
    super.key,
    required this.land,
    required this.onDetail,
    required this.onScan,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final title = land['nama'] ?? 'Petak Lahan';
    final location = '${land['kecamatan'] ?? ''}, ${land['kota'] ?? ''}'.trim();
    final phase = '${land['umur_tanaman_bulan'] ?? 0} Bulan';
    const category = 'BLOK HORTIKULTURA';

    // Status mengikuti hasil pemindaian terakhir lahan.
    final warning = land['status_kesehatan'] == 'tidak_sehat';
    final status = warning ? 'Perlu Ditangani' : 'Sedang Dipantau';
    final statusDetail = warning
        ? 'Ada Indikasi Penyakit'
        : 'Data Tersinkronisasi';
    final notice = 'Interval pupuk tiap ${land['interval_pupuk_minggu']} minggu.';

    final color = warning ? p.error : p.accent;
    return Card(
      elevation: 1,
      color: p.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: warning
                        ? p.error.withValues(alpha: 0.12)
                        : p.accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.eco_rounded, color: color, size: 30),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: _style(
                          10,
                          color,
                          FontWeight.w700,
                          letterSpacing: .4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _style(13, p.title, FontWeight.w700),
                      ),
                      Text(
                        location,
                        style: _style(11, p.subtitle, FontWeight.w400),
                      ),
                      Text(
                        phase,
                        style: _style(11, p.title, FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton<String>(
                    tooltip: 'Opsi lahan',
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: p.icon,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'hapus') onDelete?.call();
                    },
                    itemBuilder: (_) => [
                      if (onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit_outlined, size: 20),
                            title: Text('Edit'),
                          ),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'hapus',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: p.error,
                            ),
                            title: Text(
                              'Hapus',
                              style: TextStyle(color: p.error),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: warning
                    ? p.error.withValues(alpha: 0.12)
                    : p.accentSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded, color: color, size: 19),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      status,
                      style: _style(12, color, FontWeight.w700),
                    ),
                  ),
                  Text(
                    statusDetail,
                    style: _style(10, color, FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    warning
                        ? Icons.notification_important_rounded
                        : Icons.event_available_rounded,
                    color: color,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      notice,
                      style: _style(
                        11,
                        p.title,
                        FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDetail,
                    child: const Text('Lihat Detail'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onScan,
                    icon: const Icon(Icons.photo_camera_rounded, size: 17),
                    label: Text(warning ? 'Pindai Ulang' : 'Pindai Daun'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
