import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../widgets/popup_notifikasi.dart';
import '../../widgets/ui_kit.dart';
import 'treatment_recommendation_screen.dart';

class HasilScanTidakSehatPage extends StatelessWidget {
  const HasilScanTidakSehatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.title),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Lahan • Petak Cabai Rawit Blok A',
          overflow: TextOverflow.ellipsis,
          style: AppText.subtitle(context),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: p.title),
          ),
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: p.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: p.onPrimary, size: 18),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.page, 12, AppSpace.page, 32),
        child: Column(
          children: [
            _diagnosisHero(context, p),
            const SizedBox(height: AppSpace.gapMd),
            _aboutDisease(context, p),
            const SizedBox(height: AppSpace.gapMd),
            _visualFindings(context, p),
            const SizedBox(height: AppSpace.gapMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Model: Capsee-Vision v2.4 (FP16)',
                    style: AppText.micro(context)),
                Text('ID Scan: #CPS-8849A',
                    style: AppText.micro(context)),
              ],
            ),
            const SizedBox(height: AppSpace.gapMd),
            _actions(context, p),
          ],
        ),
      ),
    );
  }

  Widget _diagnosisHero(BuildContext context, AppPalette p) {
    return CapseeCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpace.radiusCard),
            ),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                children: [
                  Container(
                    color: p.surfaceAlt,
                    width: double.infinity,
                    child: Center(
                      child: Icon(Icons.local_florist,
                          size: 110, color: p.icon),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: .65),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusBadge(
                          label: 'PERLU TINDAKAN CEPAT',
                          kind: BadgeKind.error,
                        ),
                        StatusBadge(
                          label: 'Capsee AI 96.4%',
                          kind: BadgeKind.info,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        border: Border.all(color: p.error, width: 2),
                        borderRadius:
                            BorderRadius.circular(AppSpace.radiusTile),
                      ),
                      child: Center(
                        child: Icon(Icons.warning_amber_rounded,
                            color: p.error, size: 34),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Petak Cabai Rawit Blok A • Daun Bawah & Tengah',
                            style: AppText.micro(context,
                                    color: Colors.white)
                                .copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('10:15 WIB',
                            style: AppText.micro(context,
                                color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpace.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.coronavirus, size: 16, color: p.error),
                    const SizedBox(width: 4),
                    Text('Patologi Daun Terdeteksi',
                        style: AppText.caption(context, color: p.error)
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 3),
                Text('Bercak Daun Cercospora',
                    style: AppText.display(context)),
                Text('Cercospora capsici (Frogeye Leaf Spot)',
                    style: AppText.bodySm(context, color: p.hint)
                        .copyWith(fontStyle: FontStyle.italic)),
                const SizedBox(height: AppSpace.gapMd),
                Row(
                  children: [
                    Expanded(
                      child: _metric(
                        context,
                        p,
                        'Tingkat Keparahan',
                        'Sedang (Stage 2)',
                        'Area daun terinfeksi ~18%',
                        error: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _metric(
                        context,
                        p,
                        'Potensi Transmisi',
                        'Tinggi',
                        'Kelembapan kanopi 82%',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level Progresi Penyakit',
                        style: AppText.micro(context)),
                    Text('Tahap 2 dari 4',
                        style: AppText.micro(context, color: p.error)
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: _severityBar(p, true, false)),
                    const SizedBox(width: 5),
                    Expanded(child: _severityBar(p, true, true)),
                    const SizedBox(width: 5),
                    Expanded(child: _severityBar(p, false, false)),
                    const SizedBox(width: 5),
                    Expanded(child: _severityBar(p, false, false)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Aman', style: AppText.micro(context)),
                    Text('Sedang',
                        style: AppText.micro(context, color: p.error)
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text('Kritis', style: AppText.micro(context)),
                    Text('Defoliasi', style: AppText.micro(context)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutDisease(BuildContext context, AppPalette p) {
    return CapseeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.info,
            title: 'Tentang Penyakit Ini',
          ),
          const SizedBox(height: 10),
          Text(
            'Disebabkan oleh cendawan Cercospora capsici, ditandai dengan bercak bulat konsentris berwarna cokelat keabuan dengan halo klorotik kuning pada helai daun. Jika tidak ditangani, dapat memicu defoliasi daun prematur dan menurunkan produksi buah hingga 40%.',
            style: AppText.body(context),
          ),
          const SizedBox(height: AppSpace.gapMd),
          _parameter(context, p, Icons.pie_chart,
              'Luas Permukaan Terinfeksi',
              '~18% permukaan helai daun menunjukkan nekrosis aktif.'),
          _parameter(context, p, Icons.water_drop, 'Faktor Pemicu Spora',
              'Suhu 27°C - 30°C dengan periode daun basah lebih dari 6 jam.'),
          _parameter(context, p, Icons.shield, 'Risiko Penyebaran Lahan',
              'Tinggi pada tanaman sekitarnya dalam radius 1.5 - 3 meter.'),
        ],
      ),
    );
  }

  Widget _visualFindings(BuildContext context, AppPalette p) {
    return CapseeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.biotech,
            title: 'Temuan Diagnosa Visual & Lingkungan',
          ),
          const SizedBox(height: 10),
          _finding(context, p, Icons.lens, 'Bercak Mata Katak',
              'Titik nekrotik putih-abu di pusat lesi', 'Konfirmasi'),
          _finding(context, p, Icons.water_drop, 'Kelembapan Udara',
              'Tercatat 82% berdasar data cuaca', 'API BMKG'),
          _finding(context, p, Icons.forest, 'Kerapatan Kanopi',
              'Sirkulasi udara bawah terhambat', 'Perlu Pruning'),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, AppPalette p) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TreatmentRecommendationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.medical_services),
            label: const Text('Lihat Rekomendasi Penanganan'),
          ),
        ),
        const SizedBox(height: AppSpace.gapSm),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () =>
                showInfoPopup(context, 'Petak Blok A ditandai untuk isolasi.'),
            icon: const Icon(Icons.flag),
            label: const Text('Tandai Isolasi Petak Blok A'),
          ),
        ),
        const SizedBox(height: AppSpace.gapSm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.maybePop(context),
            icon: Icon(Icons.photo_camera, color: p.accent),
            label: const Text('Pindai Daun Lain'),
          ),
        ),
      ],
    );
  }

  Widget _metric(BuildContext context, AppPalette p, String label,
      String value, String note,
      {bool error = false}) {
    final bg = error ? p.error.withValues(alpha: .12) : p.surfaceAlt;
    final fg = error ? p.error : p.accent;
    final sub = error ? p.error.withValues(alpha: .8) : p.hint;
    return Container(
      padding: const EdgeInsets.all(AppSpace.tile),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.micro(context, color: sub)),
          const SizedBox(height: 3),
          Text(value, style: AppText.subtitle(context, color: fg)),
          const SizedBox(height: 3),
          Text(note, style: AppText.micro(context, color: sub)),
        ],
      ),
    );
  }

  Widget _severityBar(AppPalette p, bool filled, bool current) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: filled
            ? current
                ? p.error
                : p.accent
            : p.border,
        borderRadius: BorderRadius.circular(AppSpace.radiusPill),
      ),
    );
  }

  Widget _parameter(BuildContext context, AppPalette p, IconData icon,
      String title, String description) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.all(AppSpace.tile),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: p.error),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.subtitle(context)),
                const SizedBox(height: 2),
                Text(description, style: AppText.caption(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _finding(BuildContext context, AppPalette p, IconData icon,
      String title, String description, String badge) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(AppSpace.tile),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: p.border.withValues(alpha: .5),
              borderRadius:
                  BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: Icon(icon, size: 18, color: p.icon),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.subtitle(context)),
                Text(description, style: AppText.micro(context)),
              ],
            ),
          ),
          const SizedBox(width: 5),
          StatusBadge(label: badge, kind: BadgeKind.error),
        ],
      ),
    );
  }
}
