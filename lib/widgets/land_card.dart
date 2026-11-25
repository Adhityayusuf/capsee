import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../core/app_theme.dart';
import '../models/land_data.dart';
import 'ui_kit.dart';

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
    wateringIntervalWeeks:
        (land['interval_siram_minggu'] as num?)?.toInt() ?? 1,
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

    // Status mengikuti hasil pemindaian terakhir lahan.
    final warning = land['status_kesehatan'] == 'tidak_sehat';
    final status = warning ? 'Perlu Ditangani' : 'Sedang Dipantau';
    final statusDetail = warning
        ? 'Ada Indikasi Penyakit'
        : 'Data Tersinkronisasi';

    final color = warning ? p.error : p.accent;
    return CapseeCard(
      border: Border.all(
        color: color.withValues(alpha: .35),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: p.shadow,
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: color.withValues(alpha: .06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
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
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(Icons.eco_rounded, color: color, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.headline(context, color: p.title).copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 13, color: p.subtitle),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.caption(context),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 12, color: p.subtitle),
                        const SizedBox(width: 4),
                        Text(
                          phase,
                          style: AppText.caption(context, color: p.title).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                              style: AppText.body(context, color: p.error),
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
                borderRadius: BorderRadius.circular(AppSpace.radiusTile),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded, color: color, size: 19),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      status,
                      style: AppText.bodySm(
                        context,
                        color: color,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    statusDetail,
                    style: AppText.micro(context, color: color),
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
      );
  }
}
