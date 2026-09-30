import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../models/land_data.dart';
import '../widgets/auth_widgets.dart';
import 'dashboard_screen.dart';
import 'tambah_lahan_page.dart';
import 'detail_lahan_screen.dart';

/// Data satu kartu fitur di onboarding.
class _Feature {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;

  const _Feature({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}

const _features = [
  _Feature(
    icon: Icons.location_on_outlined,
    iconBg: AppColors.primarySoft,
    iconColor: AppColors.primaryDark,
    title: 'Catat Lokasi & Luas Petak',
    description:
        'Petakan koordinat mikro-iklim, varietas cabai, dan populasi bibit.',
  ),
  _Feature(
    icon: Icons.document_scanner_outlined,
    iconBg: Color(0xFFDBEAFE),
    iconColor: Color(0xFF1D4ED8),
    title: 'Deteksi Dini Hama & Daun',
    description:
        'Diagnosis otomatis bercak bakteri, antraknosa, dan thrips secara instan.',
  ),
  _Feature(
    icon: Icons.query_stats_rounded,
    iconBg: Color(0xFFE0E7FF),
    iconColor: Color(0xFF4338CA),
    title: 'Rekomendasi & Jadwal Panen',
    description:
        'Panduan dosis pupuk terukur dan prediksi tanggal panen puncak.',
  ),
];

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _showTodo(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 18),
                  const _HeroCard(),
                  const SizedBox(height: 22),
                  _buildHeadline(),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'MULAI CEPAT • 1/1',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: AppColors.primaryDark,
                ),
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
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.title,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Judul + deskripsi
  // ---------------------------------------------------------------
  Widget _buildHeadline() {
    return Column(
      children: [
        Text(
          'Siapkan Lahan Pertama 🌱',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Daftarkan minimal satu petak kebun cabai Anda agar kecerdasan '
          'buatan Capsee dapat memantau kesehatan tanaman secara presisi.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.5,
            height: 1.5,
            color: AppColors.subtitle,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Link "Pelajari cara kerja Capsee"
  // ---------------------------------------------------------------
  Widget _buildLearnMore(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        // TODO: buka halaman panduan / cara kerja
        _showTodo(context, 'Halaman panduan belum dibuat');
      },
      icon: const Icon(
        Icons.menu_book_outlined,
        size: 20,
        color: AppColors.primaryDark,
      ),
      label: Text(
        'Pelajari cara kerja Capsee',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
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
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD1FAE5), Colors.white],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
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
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryShadow,
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
          ),
          // Bingkai scan + ikon cabai
          SizedBox(
            width: 112,
            height: 112,
            child: CustomPaint(
              painter: _ScanFramePainter(),
              child: const Center(
                child: Icon(
                  Icons.eco_rounded,
                  size: 62,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // Badge "AI Ready"
          const Positioned(
            top: 26,
            right: 64,
            child: _Pill(
              leading: Icon(
                Icons.center_focus_strong_rounded,
                size: 14,
                color: AppColors.primaryDark,
              ),
              text: 'AI Ready',
              textColor: AppColors.primaryDark,
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
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                ),
              ),
              text: 'Model v2.4',
              textColor: AppColors.title,
            ),
          ),
          // Badge "Capsee Smart Agronomy"
          const Positioned(
            bottom: 18,
            child: _Pill(
              leading: Icon(
                Icons.bolt_rounded,
                size: 14,
                color: AppColors.primaryDark,
              ),
              text: 'Capsee Smart Agronomy',
              textColor: AppColors.primaryDark,
              background: AppColors.chipBg,
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
  final Color textColor;
  final Color background;
  final bool shadow;

  const _Pill({
    required this.leading,
    required this.text,
    required this.textColor,
    this.background = Colors.white,
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: shadow
            ? const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
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
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Menggambar 4 sudut bingkai scan + lingkaran putus-putus.
class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // --- Sudut bingkai ---
    final bracketPaint = Paint()
      ..color = AppColors.primary
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
      ..color = const Color(0x6615803D)
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ---------------------------------------------------------------
/// Kartu fitur (ikon + judul + deskripsi)
/// ---------------------------------------------------------------
class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: feature.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, size: 22, color: feature.iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
