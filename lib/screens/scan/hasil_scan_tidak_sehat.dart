import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../widgets/popup_notifikasi.dart';
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
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: p.title,
          ),
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          children: [
            _diagnosisHero(context, p),
            const SizedBox(height: 12),
            _aboutDisease(context, p),
            const SizedBox(height: 12),
            _visualFindings(context, p),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Model: Capsee-Vision v2.4 (FP16)',
                    style: TextStyle(fontSize: 10, color: p.hint)),
                Text('ID Scan: #CPS-8849A',
                    style: TextStyle(fontSize: 10, color: p.hint)),
              ],
            ),
            const SizedBox(height: 12),
            _actions(context, p),
          ],
        ),
      ),
    );
  }

  Widget _diagnosisHero(BuildContext context, AppPalette p) {
    return Container(
      decoration: _box(p),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
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
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _pill(
                        'PERLU TINDAKAN CEPAT',
                        p.error.withValues(alpha: .15),
                        p.error,
                        icon: Icons.circle,
                      ),
                      _pill(
                        'Capsee AI 96.4%',
                        p.title,
                        p.background,
                        icon: Icons.verified,
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
                      borderRadius: BorderRadius.circular(9),
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
                    children: const [
                      Expanded(
                        child: Text(
                          'Petak Cabai Rawit Blok A • Daun Bawah & Tengah',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('10:15 WIB',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.coronavirus, size: 16, color: p.error),
                    const SizedBox(width: 4),
                    Text('Patologi Daun Terdeteksi',
                        style: TextStyle(
                            color: p.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 3),
                Text('Bercak Daun Cercospora',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: p.title)),
                Text('Cercospora capsici (Frogeye Leaf Spot)',
                    style: TextStyle(
                        fontSize: 12, color: p.hint, fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _metric(
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
                        style: TextStyle(fontSize: 10, color: p.hint)),
                    Text('Tahap 2 dari 4',
                        style: TextStyle(
                            fontSize: 10,
                            color: p.error,
                            fontWeight: FontWeight.w700)),
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
                    Text('Aman', style: TextStyle(fontSize: 9, color: p.hint)),
                    Text('Sedang',
                        style: TextStyle(
                            fontSize: 9,
                            color: p.error,
                            fontWeight: FontWeight.w600)),
                    Text('Kritis', style: TextStyle(fontSize: 9, color: p.hint)),
                    Text('Defoliasi',
                        style: TextStyle(fontSize: 9, color: p.hint)),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: p.accent, size: 20),
              const SizedBox(width: 7),
              Text('Tentang Penyakit Ini',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: p.title)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Disebabkan oleh cendawan Cercospora capsici, ditandai dengan bercak bulat konsentris berwarna cokelat keabuan dengan halo klorotik kuning pada helai daun. Jika tidak ditangani, dapat memicu defoliasi daun prematur dan menurunkan produksi buah hingga 40%.',
            style: TextStyle(fontSize: 13, height: 1.5, color: p.subtitle),
          ),
          const SizedBox(height: 12),
          _parameter(p, Icons.pie_chart, 'Luas Permukaan Terinfeksi',
              '~18% permukaan helai daun menunjukkan nekrosis aktif.'),
          _parameter(p, Icons.water_drop, 'Faktor Pemicu Spora',
              'Suhu 27°C - 30°C dengan periode daun basah lebih dari 6 jam.'),
          _parameter(p, Icons.shield, 'Risiko Penyebaran Lahan',
              'Tinggi pada tanaman sekitarnya dalam radius 1.5 - 3 meter.'),
        ],
      ),
    );
  }

  Widget _visualFindings(BuildContext context, AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.biotech, color: p.accent, size: 20),
              const SizedBox(width: 7),
              Text('Temuan Diagnosa Visual & Lingkungan',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.title)),
            ],
          ),
          const SizedBox(height: 10),
          _finding(p, Icons.lens, 'Bercak Mata Katak',
              'Titik nekrotik putih-abu di pusat lesi', 'Konfirmasi'),
          _finding(p, Icons.water_drop, 'Kelembapan Udara',
              'Tercatat 82% berdasar data cuaca', 'API BMKG'),
          _finding(p, Icons.forest, 'Kerapatan Kanopi',
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
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

  Widget _metric(AppPalette p, String label, String value, String note,
      {bool error = false}) {
    final bg = error ? p.error.withValues(alpha: .12) : p.surfaceAlt;
    final fg = error ? p.error : p.accent;
    final sub = error ? p.error.withValues(alpha: .8) : p.hint;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: sub)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
          const SizedBox(height: 3),
          Text(note, style: TextStyle(fontSize: 10, color: sub)),
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
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _parameter(
      AppPalette p, IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
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
                Text(title,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: p.title)),
                const SizedBox(height: 2),
                Text(description,
                    style: TextStyle(fontSize: 11, color: p.subtitle)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _finding(AppPalette p, IconData icon, String title, String description,
      String badge) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: p.border.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: p.icon),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: p.title)),
                Text(description,
                    style: TextStyle(fontSize: 10, color: p.subtitle)),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: p.error.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge,
                style: TextStyle(
                    fontSize: 9, color: p.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color background, Color foreground,
      {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: TextStyle(
                  fontSize: 9,
                  color: foreground,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  BoxDecoration _box(AppPalette p) => BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border.withValues(alpha: .6)),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      );
}
