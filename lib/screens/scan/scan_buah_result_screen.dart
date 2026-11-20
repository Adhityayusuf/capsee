import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../core/ml/inference_result.dart';
import '../../core/ml/model_config.dart';
import '../../widgets/ui_kit.dart';

/// Halaman hasil inferensi model deteksi buah (YOLOv5n).
///
/// Menampilkan:
/// - Gambar buah dengan bounding box overlay.
/// - Daftar deteksi (kelas + confidence).
/// - Jumlah deteksi per kelas.
/// - Peringatan jika ada deteksi confidence rendah atau tidak ada deteksi.
/// - Tombol Scan Ulang.
class ScanBuahResultScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final FruitInferenceResult result;

  /// Dimensi gambar asli untuk mapping bounding box.
  final double imageWidth;
  final double imageHeight;
  final VoidCallback onScanUlang;

  const ScanBuahResultScreen({
    super.key,
    required this.imageBytes,
    required this.result,
    required this.imageWidth,
    required this.imageHeight,
    required this.onScanUlang,
  });

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
        title: Text('Hasil Scan Buah', style: AppText.headline(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.page, AppSpace.gapMd, AppSpace.page, 32),
        children: [
          _buildImageWithBoxes(context, p),
          const SizedBox(height: AppSpace.gapMd),
          _buildSummaryCard(context, p),
          if (result.isEmpty) ...[
            const SizedBox(height: AppSpace.gapMd),
            _buildNoDetectionCard(context, p),
          ] else ...[
            if (result.hasLowConfidence) ...[
              const SizedBox(height: AppSpace.gapMd),
              _buildLowConfidenceWarning(context, p),
            ],
            const SizedBox(height: AppSpace.gapMd),
            _buildDetectionList(context, p),
            const SizedBox(height: AppSpace.gapMd),
            _buildCountByClassCard(context, p),
          ],
          const SizedBox(height: AppSpace.gapMd),
          _buildInfoCard(context, p),
          const SizedBox(height: AppSpace.gapLg),
          _buildActions(context, p),
        ],
      ),
    );
  }

  // ── Gambar dengan bounding box ────────────────────────────────────────────

  Widget _buildImageWithBoxes(BuildContext context, AppPalette p) {
    return CapseeCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpace.radiusCard),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final displayW = constraints.maxWidth;
              final displayH = constraints.maxHeight;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(imageBytes, fit: BoxFit.contain),
                  // Overlay bounding boxes
                  if (result.detections.isNotEmpty)
                    CustomPaint(
                      painter: _BoundingBoxPainter(
                        detections: result.detections,
                        origWidth: imageWidth,
                        origHeight: imageHeight,
                        displayWidth: displayW,
                        displayHeight: displayH,
                      ),
                    ),
                  // Badge jumlah deteksi
                  Positioned(
                    top: 10,
                    left: 10,
                    child: StatusBadge(
                      label: result.isEmpty
                          ? 'Tidak Terdeteksi'
                          : '${result.detections.length} Deteksi',
                      kind: result.isEmpty
                          ? BadgeKind.warning
                          : BadgeKind.success,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Ringkasan hasil ───────────────────────────────────────────────────────

  Widget _buildSummaryCard(BuildContext context, AppPalette p) {
    final totalDetections = result.detections.length;
    final highConf = result.detections.where((d) => d.isHighConfidence).length;
    final lowConf = totalDetections - highConf;

    return CapseeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.isEmpty
                    ? Icons.search_off_rounded
                    : Icons.document_scanner_rounded,
                color: result.isEmpty ? p.error : p.accent,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text('Ringkasan Deteksi', style: AppText.subtitle(context)),
            ],
          ),
          const SizedBox(height: AppSpace.gapMd),
          Row(
            children: [
              _summaryMetric(
                context,
                p,
                label: 'Total Deteksi',
                value: '$totalDetections',
                color: p.accent,
                icon: Icons.layers_rounded,
              ),
              const SizedBox(width: 8),
              _summaryMetric(
                context,
                p,
                label: 'Keyakinan Tinggi',
                value: '$highConf',
                color: const Color(0xFF16A34A),
                icon: Icons.verified_rounded,
              ),
              const SizedBox(width: 8),
              _summaryMetric(
                context,
                p,
                label: 'Keyakinan Rendah',
                value: '$lowConf',
                color: p.error,
                icon: Icons.warning_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric(
    BuildContext context,
    AppPalette p, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppText.title(context, color: color),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppText.micro(context),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tidak ada deteksi ─────────────────────────────────────────────────────

  Widget _buildNoDetectionCard(BuildContext context, AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.card),
      decoration: BoxDecoration(
        color: p.error.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(AppSpace.radiusCard),
        border: Border.all(color: p.error.withValues(alpha: .25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.search_off_rounded, color: p.error, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Belum ditemukan objek buah cabai yang dapat dikenali. '
              'Silakan ambil gambar ulang dengan fokus yang lebih jelas '
              'pada buah cabai.',
              style: AppText.body(context, color: p.error),
            ),
          ),
        ],
      ),
    );
  }

  // ── Peringatan confidence rendah ──────────────────────────────────────────

  Widget _buildLowConfidenceWarning(BuildContext context, AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.tile),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(AppSpace.radiusCard),
        border:
            Border.all(color: const Color(0xFFF59E0B).withValues(alpha: .4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_rounded,
              color: Color(0xFFB45309), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Beberapa deteksi memiliki tingkat keyakinan rendah (ditandai ⚠). '
              'Ambil gambar ulang untuk memperoleh hasil yang lebih akurat.',
              style: AppText.bodySm(
                context,
                color: const Color(0xFF78350F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Daftar deteksi ────────────────────────────────────────────────────────

  Widget _buildDetectionList(BuildContext context, AppPalette p) {
    return CapseeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.list_alt_rounded,
            title: 'Daftar Deteksi',
            subtitle: '${result.detections.length} objek terdeteksi',
          ),
          const SizedBox(height: AppSpace.gapMd),
          for (int i = 0; i < result.detections.length; i++)
            _detectionItem(context, p, i + 1, result.detections[i]),
        ],
      ),
    );
  }

  Widget _detectionItem(
    BuildContext context,
    AppPalette p,
    int index,
    FruitDetection detection,
  ) {
    final isHealthy = detection.isHealthy;
    final accentColor = isHealthy ? p.accent : p.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSpace.tile),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: AppText.caption(context, color: accentColor)
                    .copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      detection.className,
                      style: AppText.subtitle(context),
                    ),
                    if (!detection.isHighConfidence) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.warning_rounded,
                          color: Color(0xFFB45309), size: 14),
                    ],
                  ],
                ),
                Text(
                  'Conf: ${detection.confidencePercent.toStringAsFixed(1)}%',
                  style: AppText.micro(context),
                ),
              ],
            ),
          ),
          StatusBadge(
            label: isHealthy ? 'Sehat' : 'Penyakit',
            kind: isHealthy ? BadgeKind.success : BadgeKind.error,
          ),
        ],
      ),
    );
  }

  // ── Jumlah per kelas ──────────────────────────────────────────────────────

  Widget _buildCountByClassCard(BuildContext context, AppPalette p) {
    final counts = result.countByClass;
    return CapseeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.bar_chart_rounded,
            title: 'Jumlah Deteksi per Kelas',
          ),
          const SizedBox(height: AppSpace.gapMd),
          for (final entry in counts.entries) ...[
            _classCountRow(context, p, entry.key, entry.value),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  Widget _classCountRow(
    BuildContext context,
    AppPalette p,
    String className,
    int count,
  ) {
    final isHealthy = className.toLowerCase().contains('healthy');
    return Row(
      children: [
        Icon(
          isHealthy ? Icons.check_circle_rounded : Icons.circle,
          size: 14,
          color: isHealthy ? p.accent : p.error,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(className, style: AppText.body(context))),
        StatusBadge(
          label: '$count objek',
          kind: isHealthy ? BadgeKind.success : BadgeKind.error,
        ),
      ],
    );
  }

  // ── Informasi model ───────────────────────────────────────────────────────

  Widget _buildInfoCard(BuildContext context, AppPalette p) {
    return CapseeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.info_outline_rounded,
            title: 'Informasi Model',
          ),
          const SizedBox(height: AppSpace.gapMd),
          _infoRow(context, p, 'Model', 'YOLOv5n (Deteksi Buah)'),
          _infoRow(context, p, 'Kelas tersedia',
              ModelConfig.fruitLabels.length.toString()),
          _infoRow(
            context,
            p,
            'Semua kelas',
            ModelConfig.fruitLabels.join(', '),
          ),
          _infoRow(context, p, 'Input', '320 × 320 piksel'),
          _infoRow(
            context,
            p,
            'Conf. threshold',
            '${(ModelConfig.fruitConfidenceThreshold * 100).toStringAsFixed(0)}%',
          ),
          _infoRow(context, p, 'Inferensi', 'On-device (offline)'),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    AppPalette p,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppText.caption(context)),
          ),
          Expanded(child: Text(value, style: AppText.bodySm(context))),
        ],
      ),
    );
  }

  // ── Tombol aksi ───────────────────────────────────────────────────────────

  Widget _buildActions(BuildContext context, AppPalette p) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.maybePop(context);
              onScanUlang();
            },
            icon: const Icon(Icons.photo_camera_rounded, size: 18),
            label: const Text('Scan Ulang'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Kembali ke Lahan'),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Painter bounding box
// ────────────────────────────────────────────────────────────────────────────

class _BoundingBoxPainter extends CustomPainter {
  final List<FruitDetection> detections;
  final double origWidth;
  final double origHeight;
  final double displayWidth;
  final double displayHeight;

  const _BoundingBoxPainter({
    required this.detections,
    required this.origWidth,
    required this.origHeight,
    required this.displayWidth,
    required this.displayHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (origWidth <= 0 || origHeight <= 0) return;

    // Hitung skala dan offset untuk mode BoxFit.contain
    final scaleX = displayWidth / origWidth;
    final scaleY = displayHeight / origHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final offsetX = (displayWidth - origWidth * scale) / 2;
    final offsetY = (displayHeight - origHeight * scale) / 2;

    for (final detection in detections) {
      final box = detection.boundingBox;
      final isHealthy = detection.isHealthy;
      final isHighConf = detection.isHighConfidence;

      // Konversi ke koordinat display
      final left = box.left * scale + offsetX;
      final top = box.top * scale + offsetY;
      final right = box.right * scale + offsetX;
      final bottom = box.bottom * scale + offsetY;
      final rect = Rect.fromLTRB(left, top, right, bottom);

      // Warna bounding box
      final color = isHealthy
          ? const Color(0xFF16A34A)
          : isHighConf
              ? const Color(0xFFDC2626)
              : const Color(0xFFF59E0B);

      // Gambar border box
      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRect(rect, boxPaint);

      // Background label
      const labelPadH = 4.0;
      const labelPadV = 2.0;
      final label =
          '${detection.className} ${detection.confidencePercent.toStringAsFixed(0)}%'
          '${!isHighConf ? ' ⚠' : ''}';

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelRect = Rect.fromLTWH(
        left,
        top - tp.height - labelPadV * 2,
        tp.width + labelPadH * 2,
        tp.height + labelPadV * 2,
      );

      final labelBg = Paint()..color = color;
      canvas.drawRect(labelRect, labelBg);
      tp.paint(canvas, Offset(left + labelPadH, top - tp.height - labelPadV));
    }
  }

  @override
  bool shouldRepaint(covariant _BoundingBoxPainter old) =>
      old.detections != detections;
}
