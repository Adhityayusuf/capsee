import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';

/// Popup notifikasi terpusat — pengganti SnackBar agar tidak tertutup
/// tombol scan / bottom-nav (lihat keluhan snackbar ketutup lingkaran hijau).
///
/// Pakai:
///   showErrorPopup(context, 'Gagal melakukan scan atau upload: ...');
///   showSuccessPopup(context, 'Jadwal tersimpan.');
///   showInfoPopup(context, 'Buat lahan dulu sebelum scan.');
Future<void> showPopup({
  required BuildContext context,
  required String judul,
  required String pesan,
  required IconData ikon,
  required Color warna,
  String tombol = 'Mengerti',
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpace.radiusCard)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, color: warna, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              judul,
              style: AppText.subtitle(ctx),
            ),
          ),
        ],
      ),
      content: Text(
        pesan,
        style: AppText.bodySm(ctx),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: warna,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpace.radiusTile),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tombol),
          ),
        ),
      ],
    ),
  );
}

/// Popup merah untuk error / gagal.
Future<void> showErrorPopup(BuildContext context, String pesan) {
  return showPopup(
    context: context,
    judul: 'Terjadi Kesalahan',
    pesan: pesan,
    ikon: Icons.error_outline_rounded,
    warna: AppColors.error,
  );
}

/// Popup hijau untuk sukses.
Future<void> showSuccessPopup(BuildContext context, String pesan) {
  return showPopup(
    context: context,
    judul: 'Berhasil',
    pesan: pesan,
    ikon: Icons.check_circle_outline_rounded,
    warna: AppColors.primary,
  );
}

/// Popup biru untuk info.
Future<void> showInfoPopup(BuildContext context, String pesan) {
  return showPopup(
    context: context,
    judul: 'Informasi',
    pesan: pesan,
    ikon: Icons.info_outline_rounded,
    warna: AppColors.info,
  );
}
