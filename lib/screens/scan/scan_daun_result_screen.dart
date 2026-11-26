import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../core/ml/disease_data.dart';
import '../../core/ml/inference_result.dart';
import '../../core/ml/model_config.dart';
import '../../models/treatment_recommendation.dart';
import '../../widgets/ui_kit.dart';
import 'treatment_recommendation_screen.dart';

/// Halaman hasil inferensi model klasifikasi daun (MobileNetV2).
///
/// Menampilkan:
/// - Gambar daun yang di-scan.
/// - Nama kelas prediksi.
/// - Confidence dalam persen.
/// - Status keyakinan (tinggi / rendah) beserta peringatan.
/// - Tombol Scan Ulang.
class ScanDaunResultScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final LeafInferenceResult result;
  final VoidCallback onScanUlang;
  final Future<bool> Function() onSimpan;

  const ScanDaunResultScreen({
    super.key,
    required this.imageBytes,
    required this.result,
    required this.onScanUlang,
    required this.onSimpan,
  });

  Future<void> _simpan(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final saved = await onSimpan();
    if (!context.mounted) return;
    Navigator.of(context).pop();
    if (saved && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

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
        title: Text('Hasil Scan Daun', style: AppText.headline(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.page,
          AppSpace.gapMd,
          AppSpace.page,
          32,
        ),
        children: [
          _buildImageCard(context, p),
          const SizedBox(height: AppSpace.gapMd),
          _buildResultCard(context, p),
          if (!result.isHighConfidence) ...[
            const SizedBox(height: AppSpace.gapMd),
            _buildLowConfidenceWarning(context, p),
          ],
          if (!result.isHealthy) ...[
            const SizedBox(height: AppSpace.gapMd),
            _buildTreatmentCard(context, p),
          ],
          const SizedBox(height: AppSpace.gapMd),
          _buildInfoCard(context, p),
          const SizedBox(height: AppSpace.gapLg),
          _buildActions(context, p),
        ],
      ),
    );
  }

  // ── Gambar yang di-scan ───────────────────────────────────────────────────

  Widget _buildImageCard(BuildContext context, AppPalette p) {
    return CapseeCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpace.radiusCard),
            ),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(imageBytes, fit: BoxFit.cover),
                  // Overlay badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: StatusBadge(
                      label: result.isHighConfidence
                          ? 'Keyakinan Tinggi'
                          : 'Keyakinan Rendah',
                      kind: result.isHighConfidence
                          ? BadgeKind.success
                          : BadgeKind.warning,
                    ),
                  ),
                  // Overlay bagian label bawah
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.eco_rounded,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Scan Daun Cabai',
                            style: AppText.micro(
                              context,
                              color: Colors.white70,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Kartu hasil utama ─────────────────────────────────────────────────────

  Widget _buildResultCard(BuildContext context, AppPalette p) {
    final isHealthy = result.isHealthy;
    final accentColor = isHealthy ? p.accent : p.error;
    final bgColor = isHealthy ? p.accentSoft : p.error.withValues(alpha: .10);

    return CapseeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHealthy
                    ? Icons.verified_rounded
                    : Icons.warning_amber_rounded,
                color: accentColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text('Diagnosis Daun Cabai', style: AppText.subtitle(context)),
            ],
          ),
          const SizedBox(height: AppSpace.gapMd),
          // Nama kelas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpace.tile),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHealthy ? 'Daun Sehat' : 'Penyakit Terdeteksi',
                  style: AppText.caption(
                    context,
                    color: accentColor,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  result.className,
                  style: AppText.title(context, color: accentColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.gapMd),
          // Metrik confidence
          _metricRow(
            context,
            p,
            label: 'Tingkat Keyakinan AI',
            value: '${result.confidencePercent.toStringAsFixed(1)}%',
            icon: Icons.analytics_rounded,
            valueColor: result.isHighConfidence ? p.accent : p.error,
          ),
          const SizedBox(height: 8),
          // Progress bar confidence
          _confidenceBar(context, p),
          const SizedBox(height: 8),
          _metricRow(
            context,
            p,
            label: 'Threshold Keyakinan',
            value:
                '≥ ${(ModelConfig.leafConfidenceThreshold * 100).toStringAsFixed(0)}%',
            icon: Icons.tune_rounded,
          ),
          const SizedBox(height: 8),
          _metricRow(
            context,
            p,
            label: 'Status',
            value: isHealthy ? 'Tanaman Sehat' : 'Perlu Perhatian',
            icon: isHealthy ? Icons.check_circle_rounded : Icons.error_rounded,
            valueColor: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _confidenceBar(BuildContext context, AppPalette p) {
    final pct = result.confidence.clamp(0.0, 1.0);
    final color = result.isHighConfidence ? p.accent : p.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpace.radiusPill),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: p.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: AppText.micro(context)),
            Text(
              '${(ModelConfig.leafConfidenceThreshold * 100).toStringAsFixed(0)}% threshold',
              style: AppText.micro(context, color: p.subtitle),
            ),
            Text('100%', style: AppText.micro(context)),
          ],
        ),
      ],
    );
  }

  Widget _metricRow(
    BuildContext context,
    AppPalette p, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: p.icon),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppText.caption(context))),
        Text(
          value,
          style: AppText.subtitle(context, color: valueColor ?? p.title),
        ),
      ],
    );
  }

  // ── Peringatan confidence rendah ──────────────────────────────────────────

  Widget _buildLowConfidenceWarning(BuildContext context, AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.tile),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(AppSpace.radiusCard),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: .4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_rounded, color: Color(0xFFB45309), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hasil prediksi memiliki tingkat keyakinan rendah. '
              'Hasil ini belum dapat dipastikan. '
              'Silakan ambil gambar ulang untuk memperoleh hasil yang lebih baik.',
              style: AppText.bodySm(context, color: const Color(0xFF78350F)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Deskripsi Penyakit & Tombol Rekomendasi Penanganan (dari Database) ───

  Widget _buildTreatmentCard(BuildContext context, AppPalette p) {
    return FutureBuilder<DiseaseInfo?>(
      future: fetchDiseaseInfo(result.className),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CapseeCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.cardPadding),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Memuat data penyakit ${result.className} dari database...',
                      style: AppText.caption(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final info = snapshot.data;
        if (info == null) return const SizedBox.shrink();

        final nama = info.name;
        final namaLatin = info.latinName ?? '';
        final deskripsi = info.description;
        final penanganan = info.treatment;

        return CapseeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                icon: Icons.description_outlined,
                title: 'Deskripsi Penyakit',
                subtitle: nama,
              ),
              const SizedBox(height: AppSpace.gapMd),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpace.tile),
                decoration: BoxDecoration(
                  color: p.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                  border: Border.all(color: p.error.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: AppText.subtitle(context, color: p.error),
                    ),
                    if (namaLatin.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        namaLatin,
                        style: AppText.caption(context).copyWith(
                          fontStyle: FontStyle.italic,
                          color: p.subtitle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (deskripsi.isNotEmpty) ...[
                const SizedBox(height: AppSpace.gapMd),
                Text(
                  'Ciri-Ciri Gejala (Database):',
                  style: AppText.caption(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  deskripsi,
                  style: AppText.body(context),
                ),
              ],
              const SizedBox(height: AppSpace.gapMd),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.onPrimary,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TreatmentRecommendationScreen(
                          diagnosis: DiagnosisSummary(
                            diagnosisId: '#CPS-${DateTime.now().millisecondsSinceEpoch % 10000}',
                            plantName: 'Tanaman Cabai (Daun)',
                            statusLabel: 'Penyakit Terdeteksi',
                            diseaseName: nama,
                            latinName: namaLatin,
                            dateTime: 'Hari ini',
                            severityLabel: 'Perlu Penanganan',
                            severityProgress: 0.65,
                            aiAccuracyPercent: result.confidencePercent.toInt(),
                          ),
                          treatmentText: penanganan,
                          descriptionText: deskripsi,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.medical_services_outlined, size: 20),
                  label: const Text('Rekomendasi Penanganan'),
                ),
              ),
            ],
          ),
        );
      },
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
          _infoRow(context, p, 'Model', 'MobileNetV2 (Klasifikasi Daun)'),
          _infoRow(
            context,
            p,
            'Kelas tersedia',
            ModelConfig.leafLabels.length.toString(),
          ),
          _infoRow(
            context,
            p,
            'Semua kelas',
            ModelConfig.leafLabels.join(', '),
          ),
          _infoRow(context, p, 'Input', '224 × 224 piksel'),
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
          child: FilledButton.icon(
            onPressed: () => _simpan(context),
            icon: const Icon(Icons.bookmark_add_outlined, size: 18),
            label: const Text('Simpan ke Riwayat'),
          ),
        ),
        const SizedBox(height: 10),
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
