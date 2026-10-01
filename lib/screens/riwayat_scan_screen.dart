import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';

class ScanHistoryItem {
  final String imagePath;
  final DateTime scannedAt;

  const ScanHistoryItem({required this.imagePath, required this.scannedAt});
}

class RiwayatScanScreen extends StatelessWidget {
  final List<ScanHistoryItem> items;
  final VoidCallback onScan;

  const RiwayatScanScreen({
    super.key,
    required this.items,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          Expanded(child: items.isEmpty ? _empty() : _list()),
        ],
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Riwayat Scan', style: _style(20, AppColors.title, FontWeight.w700)),
        const SizedBox(height: 3),
        Text(
          items.isEmpty
              ? 'Belum ada foto yang dipindai'
              : '${items.length} foto hasil pindai sesi ini',
          style: _style(12, AppColors.subtitle, FontWeight.w400),
        ),
      ],
    ),
  );

  Widget _empty() => Center(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Riwayat masih kosong',
            style: _style(16, AppColors.title, FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Hasil pindai daun akan tampil di sini setelah Anda mengambil foto dengan kamera.',
            textAlign: TextAlign.center,
            style: _style(12, AppColors.subtitle, FontWeight.w400, height: 1.4),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.photo_camera_rounded, size: 18),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('Scan Sekarang'),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _list() => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
    itemCount: items.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) => _card(items[index]),
  );

  Widget _card(ScanHistoryItem item) {
    final file = File(item.imagePath);
    return Card(
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: file.existsSync()
                  ? Image.file(
                      file,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      color: AppColors.chipBg,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.icon,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foto Daun',
                    style: _style(13, AppColors.title, FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _format(item.scannedAt),
                    style: _style(11, AppColors.subtitle, FontWeight.w400),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Menunggu analisis',
                style: _style(10, AppColors.subtitle, FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} • ${two(d.hour)}:${two(d.minute)} WIB';
  }
}

TextStyle _style(
  double size,
  Color color,
  FontWeight weight, {
  double? height,
}) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
);
