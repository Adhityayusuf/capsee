import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../widgets/ui_kit.dart';

/// Enum jenis masalah scan.
enum ScanProblemKind {
  /// Gambar secara teknis tidak valid (blur, gelap, dll).
  imageTechnical,

  /// Objek bukan daun cabai.
  invalidLeaf,

  /// Objek bukan buah cabai.
  invalidFruit,

  /// Error tidak terduga saat inferensi.
  inferenceError,
}

/// Halaman yang ditampilkan ketika validasi gambar atau objek gagal.
///
/// Menyediakan tombol:
/// - Ambil Gambar Ulang (buka kamera).
/// - Pilih Gambar Lain (buka galeri).
/// - Kembali.
class ScanValidasiGagalScreen extends StatelessWidget {
  final ScanProblemKind kind;
  final String? customMessage;
  final VoidCallback onAmbilUlang;
  final VoidCallback onPilihLain;

  const ScanValidasiGagalScreen({
    super.key,
    required this.kind,
    this.customMessage,
    required this.onAmbilUlang,
    required this.onPilihLain,
  });

  String get _title => switch (kind) {
        ScanProblemKind.imageTechnical => 'Kualitas Gambar Kurang',
        ScanProblemKind.invalidLeaf => 'Input Tidak Valid',
        ScanProblemKind.invalidFruit => 'Input Tidak Valid',
        ScanProblemKind.inferenceError => 'Gagal Memproses Gambar',
      };

  String get _defaultMessage => switch (kind) {
        ScanProblemKind.imageTechnical =>
          'Gambar tidak memenuhi kualitas yang dibutuhkan. '
              'Pastikan pencahayaan cukup, kamera fokus, dan gambar tidak buram.',
        ScanProblemKind.invalidLeaf =>
          'Input tidak valid. Pastikan gambar yang dimasukkan merupakan daun cabai.',
        ScanProblemKind.invalidFruit =>
          'Input tidak valid. Pastikan gambar yang dimasukkan merupakan buah cabai.',
        ScanProblemKind.inferenceError =>
          'Terjadi kesalahan saat memproses gambar. '
              'Coba lagi atau gunakan gambar yang berbeda.',
      };

  IconData get _icon => switch (kind) {
        ScanProblemKind.imageTechnical => Icons.image_not_supported_rounded,
        ScanProblemKind.invalidLeaf => Icons.block_rounded,
        ScanProblemKind.invalidFruit => Icons.block_rounded,
        ScanProblemKind.inferenceError => Icons.error_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: p.title),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text('Scan Gagal', style: AppText.headline(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpace.page),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: p.error.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(_icon, color: p.error, size: 40),
            ),
            const SizedBox(height: AppSpace.gapLg),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: AppText.title(context),
            ),
            const SizedBox(height: 10),
            Text(
              customMessage ?? _defaultMessage,
              textAlign: TextAlign.center,
              style: AppText.body(context),
            ),
            const SizedBox(height: AppSpace.gapXl),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.maybePop(context);
                  onAmbilUlang();
                },
                icon: const Icon(Icons.photo_camera_rounded, size: 18),
                label: const Text('Ambil Gambar Ulang'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.maybePop(context);
                  onPilihLain();
                },
                icon: const Icon(Icons.photo_library_rounded, size: 18),
                label: const Text('Pilih Gambar Lain'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
