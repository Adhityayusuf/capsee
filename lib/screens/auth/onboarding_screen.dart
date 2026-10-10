import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/ui_kit.dart';
import '../bantuan/panduan_screen.dart';
import '../home/dashboard_screen.dart';
import '../lahan/tambah_lahan_page.dart';

/// Data satu kartu fitur di onboarding.
class _Feature {
  final IconData icon;
  final String title;
  final String description;

  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

const _features = [
  _Feature(
    icon: Icons.location_on_outlined,
    title: 'Catat Lokasi & Luas Petak',
    description:
        'Petakan koordinat mikro-iklim, varietas cabai, dan populasi bibit.',
  ),
  _Feature(
    icon: Icons.document_scanner_outlined,
    title: 'Deteksi Dini Hama & Daun',
    description:
        'Diagnosis otomatis bercak bakteri, antraknosa, dan thrips secara instan.',
  ),
  _Feature(
    icon: Icons.query_stats_rounded,
    title: 'Rekomendasi & Jadwal Panen',
    description:
        'Panduan dosis pupuk terukur dan prediksi tanggal panen puncak.',
  ),
];

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.page, AppSpace.page, AppSpace.page, AppSpace.gapXl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 18),
                  const _HeroCard(),
                  const SizedBox(height: 22),
                  _buildHeadline(context),
                  const SizedBox(height: 20),
                  for (final feature in _features) ...[
                    _FeatureCard(feature: feature),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: 'Tambah Lahan Sekarang',
                    icon: Icons.add_circle_outline_rounded,
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TambahLahanPage(),
                        ),
                      );
                      if (result != null && context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const DashboardScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildLearnMore(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Baris atas: chip "MULAI CEPAT • 1/1" + "Lewati untuk nanti"
  // ---------------------------------------------------------------
  Widget _buildTopBar(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: p.accentSoft,
            borderRadius: BorderRadius.circular(AppSpace.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: p.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'MULAI CEPAT • 1/1',
                style: AppText.overline(context, color: p.onAccentSoft),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          },
          child: Text(
            'Lewati untuk nanti',
            style: AppText.body(context, color: p.title)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Judul + deskripsi
  // ---------------------------------------------------------------
  Widget _buildHeadline(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Text(
          'Siapkan Lahan Pertama 🌱',
          textAlign: TextAlign.center,
          style: AppText.display(context),
        ),
        const SizedBox(height: 10),
        Text(
          'Daftarkan minimal satu petak kebun cabai Anda agar kecerdasan '
          'buatan Capsee dapat memantau kesehatan tanaman secara presisi.',
          textAlign: TextAlign.center,
          style: AppText.body(context),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Link "Pelajari cara kerja Capsee"
  // ---------------------------------------------------------------
  Widget _buildLearnMore(BuildContext context) {
    final p = context.palette;
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PanduanScreen()),
        );
      },
      icon: Icon(
        Icons.menu_book_outlined,
        size: 20,
        color: p.accent,
      ),
      label: Text(
        'Pelajari cara kerja Capsee',
        style: AppText.subtitle(context, color: p.accent),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// Kartu hero: ilustrasi cabai + badge melayang
/// ---------------------------------------------------------------
class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpace.radiusCard),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.accentSoft, p.surface],
        ),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran putih di tengah
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              color: p.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: p.shadow,
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          // Bingkai scan + ikon cabai
          SizedBox(
            width: 112,
            height: 112,
            child: CustomPaint(
              painter: _ScanFramePainter(
                bracketColor: p.accent,
                dashColor: p.accent.withValues(alpha: 0.4),
              ),
              child: Center(
                child: Icon(
                  Icons.eco_rounded,
                  size: 62,
                  color: p.accent,
                ),
              ),
            ),
          ),

          // Badge "AI Ready"
          Positioned(
            top: 26,
            right: 64,
            child: _Pill(
              leading: Icon(
                Icons.center_focus_strong_rounded,
                size: 14,
                color: p.accent,
              ),
              text: 'AI Ready',
              textColor: p.accent,
            ),
          ),
          // Badge "Model v2.4"
          Positioned(
            left: 36,
            bottom: 74,
            child: _Pill(
              leading: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: p.accent,
                  shape: BoxShape.circle,
                ),
              ),
              text: 'Model v2.4',
              textColor: p.title,
            ),
          ),
          // Badge "Capsee Smart Agronomy"
          Positioned(
            bottom: 18,
            child: _Pill(
              leading: Icon(
                Icons.bolt_rounded,
                size: 14,
                color: p.accent,
              ),
              text: 'Capsee Smart Agronomy',
              textColor: p.accent,
              background: p.surfaceAlt,
              shadow: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill kecil (badge) yang dipakai di hero card.
class _Pill extends StatelessWidget {
  final Widget leading;
  final String text;
  final Color? textColor;
  final Color? background;
  final bool shadow;

  const _Pill({
    required this.leading,
    required this.text,
    this.textColor,
    this.background,
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background ?? p.surface,
        borderRadius: BorderRadius.circular(AppSpace.radiusPill),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: p.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 6),
          Text(
            text,
            style: AppText.bodySm(context, color: textColor ?? p.title)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Menggambar 4 sudut bingkai scan + lingkaran putus-putus.
class _ScanFramePainter extends CustomPainter {
  final Color bracketColor;
  final Color dashColor;

  const _ScanFramePainter({
    required this.bracketColor,
    required this.dashColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // --- Sudut bingkai ---
    final bracketPaint = Paint()
      ..color = bracketColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const len = 20.0;
    final brackets = Path()
      ..moveTo(0, len)
      ..lineTo(0, 0)
      ..lineTo(len, 0)
      ..moveTo(w - len, 0)
      ..lineTo(w, 0)
      ..lineTo(w, len)
      ..moveTo(w, h - len)
      ..lineTo(w, h)
      ..lineTo(w - len, h)
      ..moveTo(len, h)
      ..lineTo(0, h)
      ..lineTo(0, h - len);
    canvas.drawPath(brackets, bracketPaint);

    // --- Lingkaran putus-putus ---
    final dashPaint = Paint()
      ..color = dashColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(w / 2, h / 2);
    final rect = Rect.fromCircle(center: center, radius: w / 2 - 6);
    const dashCount = 36;
    const sweep = 2 * pi / dashCount;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) =>
      oldDelegate.bracketColor != bracketColor ||
      oldDelegate.dashColor != dashColor;
}

/// ---------------------------------------------------------------
/// Kartu fitur (ikon + judul + deskripsi)
/// ---------------------------------------------------------------
class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return CapseeCard(
      padding: const EdgeInsets.all(AppSpace.card),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.accentSoft,
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            ),
            child:
                Icon(feature.icon, size: 22, color: p.onAccentSoft),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: AppText.subtitle(context),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: AppText.body(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
