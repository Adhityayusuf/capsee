// panduan_screen.dart
//
// Layar "Panduan Cara Kerja" (onboarding 4 langkah) Capsee.
// Memakai class warna `C` dari notifikasi_screen.dart (satu folder di lib/).
// Dependensi: google_fonts.
//
// Pemakaian:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => PanduanScreen(
//       onFinish: () { /* ke beranda */ },
//       onSkip: () { /* ke beranda */ },
//     ),
//   ));

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'notifikasi_screen.dart' show C;

// ─────────────────────────── Token tambahan ───────────────────────────
class _P {
  static const inverseSurface = Color(0xFF283044);
  static const inverseOnSurface = Color(0xFFEEF0FF);
  static const onPrimaryContainer = Color(0xFFD3FFD5);
  static const secondaryContainer = Color(0xFF6BFF8F);
  static const onSecondaryContainer = Color(0xFF007432);
  static const secondary = Color(0xFF006E2F);
  static const onSecondaryFixedVariant = Color(0xFF005321);
  static const surfaceDim = Color(0xFFD2D9F4);
  static const outlineVariant = Color(0xFFBECABC);
}

// ─────────────────────────── URL gambar ───────────────────────────
const _kImgLahan =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuA_8ZMqfMOTHDDW6jPNNNjGyuZve0teGpB_dlPY1RW9C1zHGlTwerYB41tLksA8Z7EPuRRZC3p4kjK9bj5C87NxooUOGJo46cLPXKCYUqiOaN0ZZZ3qwYBPKoupUhajuIErp_IHEUU9vB8JPYwJ3nK97AuD2HprE6mSOmqR-_-E4QcCVyPoIXg_e93hTHB6MPLrGXmgF1N-BCczUJCk6uMzvo0mH7nSjoIfyYXYtflcGkGv2bZBcfn_cA';

const _kImgDaun =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBzHTm5Cj7xEe0F3OLZeA22H7ki-qbk1DeDVLTygEIZIQuRpmDkhT9fG39EJM5wM1Wke2skeIncP1a8Fe7pSYOUS8Yy6otOrRYCixOSn5Vr5It9BNciQvSIkI5TgUm64PIp_KhC9dMrbngSF1yhJV7rCIZzHlfVvyUoR_9y2xdf5tjcG4VeCmZ2GLV9oVnq0v60SijRo4KENyVdd5UICTOxg-jbSUdJhGtjtZTGu-iTJSQ1EHqt1Fw5AA';

const _kImgPlot =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDKGKlk9WcxvRgbqzGt1MJtjmUII6U08D2PsdPgAcHVW2XCCEzDZpNxyhORvaRWH1cCrnd7pRctdZGwYsNWuP3mjA4UT1pr2vLeOQiGMgWj89xku8HPgjVO-BLZnoJzGhVaniH9vAX76DBGQqjrsMeQoCTEUo1KbH_q4n0HXcC2LKcdFOvAYZqSRDmURY_S61yW8IR-huhZ7Pz5pLzbQRiNv8iB9eUsITyCb8gBC1XKxLULp4WzX7AP7Q';

// ─────────────────────────── Tipografi ───────────────────────────
TextStyle _ts(double size, double height, FontWeight w, Color color,
        {double? letterSpacing, FontStyle? fontStyle}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: height / size,
      fontWeight: w,
      color: color,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );

const _softShadow = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1)),
];

// ─────────────────────────── Data langkah ───────────────────────────
const _chipLabels = ['1. Lahan', '2. Pindai', '3. Jadwal', '4. Notifikasi'];

const _primaryLabels = [
  'Lanjut',
  'Lanjut ke Jadwal',
  'Lanjut ke Notifikasi',
  'Mulai Gunakan Capsee Sekarang',
];

const _primaryIcons = [
  Icons.arrow_forward,
  Icons.arrow_forward,
  Icons.arrow_forward,
  Icons.check_circle,
];

// Tombol sekunder untuk langkah 2–4 (indeks 1..3)
const _secondaryLabels = [
  '',
  'Lihat Contoh Foto Daun yang Benar',
  'Pelajari Kalibrasi Dosis Pupuk',
  'Atur Preferensi Notifikasi',
];

const _secondaryIcons = [
  Icons.abc,
  Icons.photo_library,
  Icons.menu_book,
  Icons.tune,
];

// ─────────────────────────── Layar utama ───────────────────────────
class PanduanScreen extends StatefulWidget {
  final VoidCallback? onFinish;
  final VoidCallback? onSkip;
  final int initialStep;

  const PanduanScreen({
    super.key,
    this.onFinish,
    this.onSkip,
    this.initialStep = 0,
  });

  @override
  State<PanduanScreen> createState() => _PanduanScreenState();
}

class _PanduanScreenState extends State<PanduanScreen> {
  static const int _total = 4;

  late int _step = widget.initialStep.clamp(0, _total - 1);
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    if (i < 0 || i >= _total || i == _step) return;
    setState(() => _step = i);
    if (_scroll.hasClients) {
      _scroll.animateTo(0,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _next() {
    if (_step < _total - 1) {
      _goTo(_step + 1);
    } else {
      (widget.onFinish ?? () => Navigator.maybePop(context))();
    }
  }

  void _skip() => (widget.onSkip ?? () => Navigator.maybePop(context))();

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return const _Step1();
      case 1:
        return const _Step2();
      case 2:
        return const _Step3();
      default:
        return const _Step4();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.surface,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepChips(current: _step, onTap: _goTo),
            const SizedBox(height: 8),
            _ProgressBar(fraction: (_step + 1) / _total),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, if (current != null) current],
              ),
              child: KeyedSubtree(key: ValueKey(_step), child: _stepBody()),
            ),
            const SizedBox(height: 24),
            _buildPager(),
            const SizedBox(height: 16),
            _buildActions(),
            const SizedBox(height: 12),
            _buildFootnote(),
          ],
        ),
      ),
    );
  }

  // ───────── AppBar ─────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: C.surface.withOpacity(0.95),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back,
                        size: 24, color: C.onSurfaceVariant),
                    style: IconButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        shape: const CircleBorder()),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Panduan Cara Kerja',
                        overflow: TextOverflow.ellipsis,
                        style: _ts(18, 24, FontWeight.w600, C.onSurface,
                            letterSpacing: -0.2)),
                  ),
                  TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text('Lewati',
                        style: _ts(12, 16, FontWeight.w600, C.primary)),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                        color: C.primary, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.person, size: 18, color: C.onPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── Indikator halaman ─────────
  Widget _buildPager() {
    final isLast = _step == _total - 1;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < _total; i++)
              GestureDetector(
                onTap: () => _goTo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: i == _step ? 28 : 8,
                  decoration: BoxDecoration(
                    color: i == _step
                        ? C.primaryContainer
                        : C.surfaceHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          isLast
              ? 'Langkah 4 dari 4 (Selesai)'
              : 'Langkah ${_step + 1} dari $_total',
          style: _ts(10, 14, isLast ? FontWeight.w600 : FontWeight.w700,
              isLast ? C.primary : C.onSurfaceVariant),
        ),
      ],
    );
  }

  // ───────── Tombol aksi ─────────
  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tombol utama
        Material(
          color: C.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _next,
            child: SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(_primaryLabels[_step],
                        overflow: TextOverflow.ellipsis,
                        style: _ts(14, 20, FontWeight.w700, C.onPrimary)),
                  ),
                  const SizedBox(width: 4),
                  Icon(_primaryIcons[_step], size: 20, color: C.onPrimary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_step > 0)
          Center(
            child: TextButton.icon(
              onPressed: () => _goTo(_step - 1),
              icon: const Icon(Icons.arrow_back,
                  size: 18, color: C.onSurfaceVariant),
              label: Text('Kembali',
                  style: _ts(12, 16, FontWeight.w600, C.onSurfaceVariant)),
            ),
          ),
      ],
    );
  }

  Widget _buildFootnote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.info_outline, size: 16, color: C.outline),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text.rich(
            TextSpan(
              style: _ts(12, 16, FontWeight.w400, C.outline),
              children: [
                const TextSpan(
                    text: 'Panduan dapat diakses kembali kapan saja melalui menu '),
                TextSpan(
                  text: 'Bantuan & Akun',
                  style: _ts(12, 16, FontWeight.w600, C.onSurfaceVariant),
                ),
                const TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Chip langkah ───────────────────────────
class _StepChips extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _StepChips({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < _chipLabels.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            _chip(i),
          ],
        ],
      ),
    );
  }

  Widget _chip(int i) {
    final done = i < current;
    final active = i == current;

    Color bg;
    Color fg;
    if (active) {
      bg = C.primaryContainer;
      fg = C.onPrimary;
    } else if (done) {
      bg = C.surfaceHigh;
      fg = C.primary;
    } else {
      bg = C.surfaceLow;
      fg = C.onSurfaceVariant;
    }

    return GestureDetector(
      onTap: () => onTap(i),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: (!active && !done) ? 0.6 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: active ? 14 : 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            boxShadow: active ? _softShadow : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (done) ...[
                const Icon(Icons.check_circle, size: 16, color: C.primary),
                const SizedBox(width: 6),
              ] else if (active) ...[
                const _Blink(child: _Dot(color: Colors.white, size: 8)),
                const SizedBox(width: 6),
              ],
              Text(_chipLabels[i], style: _ts(12, 16, FontWeight.w600, fg)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double fraction;
  const _ProgressBar({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 6,
        color: C.surfaceHigh,
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          alignment: Alignment.centerLeft,
          widthFactor: fraction,
          child: Container(
            decoration: BoxDecoration(
              color: C.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════ LANGKAH 1 – LAHAN ═══════════════════════════
class _Step1 extends StatelessWidget {
  const _Step1();

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 176,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const _NetImage(_kImgLahan),
                  const _BottomGradient(),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: _GlassPill(
                      icon: Icons.nature,
                      text: 'GIS & Plot Telemetri',
                      color: C.onSurface,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const _TagPill('Langkah 1'),
              const SizedBox(width: 8),
              Flexible(
                child: Text('Pemetaan Bedengan',
                    style: _ts(12, 16, FontWeight.w600, C.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('1. Daftarkan Data Lahan Cabai',
              style: _ts(22, 28, FontWeight.w700, C.onSurface)),
          const SizedBox(height: 4),
          Text(
            'Masukkan informasi petak kebun, varietas cabai, dan tanggal tanam untuk kalibrasi kebutuhan nutrisi spesifik.',
            style: _ts(14, 20, FontWeight.w400, C.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.surfaceLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                _CheckRow('Input varietas & luas bedengan dalam hitungan menit'),
                SizedBox(height: 8),
                _CheckRow('Sinkronisasi koordinat GPS & prakiraan cuaca mikro'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════ LANGKAH 2 – PINDAI ═══════════════════════════
class _Step2 extends StatelessWidget {
  const _Step2();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: C.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const _NetImage(_kImgDaun),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Reticle
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Stack(
                      children: [
                        _corner(top: true, left: true),
                        _corner(top: true, left: false),
                        _corner(top: false, left: true),
                        _corner(top: false, left: false),
                        const Center(child: _Ping()),
                      ],
                    ),
                  ),
                ),
                // HUD atas
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _P.inverseSurface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _Blink(
                                child: _Dot(
                                    color: _P.secondaryContainer, size: 8)),
                            const SizedBox(width: 6),
                            Text('AI SCANNER V2.4',
                                style: _ts(10, 14, FontWeight.w700,
                                    _P.inverseOnSurface)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: C.surfaceLowest.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: _softShadow,
                        ),
                        child: Text('Akurasi 98.4%',
                            style: _ts(10, 14, FontWeight.w700, C.primary)),
                      ),
                    ],
                  ),
                ),
                // Pill hasil deteksi
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _P.inverseSurface.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.center_focus_strong,
                            size: 18, color: _P.secondaryContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Terdeteksi: Bercak Daun Cercospora',
                              overflow: TextOverflow.ellipsis,
                              style: _ts(12, 16, FontWeight.w600,
                                  _P.inverseOnSurface)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.errorContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('Level 2',
                              style: _ts(10, 14, FontWeight.w700,
                                  C.onErrorContainer)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TagPill('LANGKAH 2 • PINDAI DAUN TANAMAN',
                    bg: _P.secondaryContainer,
                    fg: _P.onSecondaryContainer,
                    letterSpacing: 0.5),
                const SizedBox(height: 16),
                Text('2. Foto & Pindai Daun Sakit',
                    style: _ts(22, 28, FontWeight.w700, C.onSurface,
                        letterSpacing: -0.2)),
                const SizedBox(height: 4),
                Text(
                  'Arahkan kamera ponsel pada helai daun dengan jarak 10–15 cm di pencahayaan alami. Model AI Capsee akan mengidentifikasi patogen dan bercak daun secara instan.',
                  style: _ts(14, 22, FontWeight.w400, C.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                const _TipTile(
                  icon: Icons.wb_sunny,
                  title: 'Jarak & Pencahayaan Alami',
                  body:
                      'Gunakan jarak 10–15 cm dengan sinar matahari pagi atau siang yang merata.',
                ),
                const SizedBox(height: 10),
                const _TipTile(
                  icon: Icons.coronavirus,
                  title: 'Identifikasi Otomatis Multi-Patogen',
                  body:
                      'Mendeteksi Antraknosa, Cercospora, Gemini Virus, serta defisiensi hara.',
                ),
                const SizedBox(height: 10),
                const _TipTile(
                  icon: Icons.verified,
                  title: 'Diagnosis Computer Vision Presisi',
                  body:
                      'Tingkat akurasi klinis tinggi terlatih dari ribuan sampel daun cabai nusantara.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner({required bool top, required bool left}) {
    const side = BorderSide(color: C.primaryFixed, width: 2);
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: top ? side : BorderSide.none,
            bottom: top ? BorderSide.none : side,
            left: left ? side : BorderSide.none,
            right: left ? BorderSide.none : side,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════ LANGKAH 3 – JADWAL ═══════════════════════════
class _Step3 extends StatelessWidget {
  const _Step3();

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pratinjau jadwal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.surfaceLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: C.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_sync,
                                size: 15, color: C.tertiary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Sinkron BMKG 28°C • Cerah Berawan',
                                overflow: TextOverflow.ellipsis,
                                style: _ts(10, 14, FontWeight.w700,
                                    C.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _Dot(color: _P.secondary, size: 8),
                    const SizedBox(width: 4),
                    Text('Aktif',
                        style: _ts(10, 14, FontWeight.w600, C.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                _scheduleTile(
                  iconBg: C.tertiaryFixed,
                  iconColor: C.tertiary,
                  icon: Icons.water_drop,
                  title: 'Penyiraman Pagi',
                  chip: '06.30 WIB',
                  chipBg: C.primaryFixedDim.withOpacity(0.3),
                  chipFg: C.primary,
                  subtitle: 'Volume 450ml / tanaman • Drip otomatis',
                  trailing: const Icon(Icons.check_circle,
                      size: 22, color: C.primary),
                ),
                const SizedBox(height: 8),
                _scheduleTile(
                  iconBg: _P.secondaryContainer,
                  iconColor: _P.onSecondaryFixedVariant,
                  icon: Icons.science,
                  title: 'Pemupukan NPK 16-16-16',
                  chip: '3 Hari Lagi',
                  chipBg: C.tertiaryFixed.withOpacity(0.4),
                  chipFg: C.tertiary,
                  subtitle: 'Fase Vegetatif Lanjut • Dosis 15g/liter',
                  trailing: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                        color: C.surfaceContainer, shape: BoxShape.circle),
                    child: const Icon(Icons.chevron_right,
                        size: 18, color: C.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 96,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const _NetImage(_kImgPlot),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                _P.inverseSurface.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          bottom: 10,
                          right: 10,
                          child: Row(
                            children: [
                              const Icon(Icons.eco,
                                  size: 16, color: _P.secondaryContainer),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Plot Cabai Rawit Merah (Blok C-2)',
                                  overflow: TextOverflow.ellipsis,
                                  style: _ts(10, 14, FontWeight.w600,
                                      C.onPrimary,
                                      letterSpacing: 0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _TagPill('LANGKAH 3 • KALENDER & PERAWATAN PRESISI',
              bg: Color(0x6679DB8D), fg: C.primary, letterSpacing: 0.5),
          const SizedBox(height: 8),
          Text('Pantau Jadwal Perawatan',
              style: _ts(22, 28, FontWeight.w700, C.onSurface,
                  letterSpacing: -0.2)),
          const SizedBox(height: 4),
          Text(
            'Capsee menyusun kalender penyiraman dan pemupukan presisi otomatis sesuai fase pertumbuhan tanaman cabai Anda.',
            style: _ts(14, 22, FontWeight.w400, C.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          const _FeatureRow(
            icon: Icons.event_repeat,
            iconBg: C.primary,
            iconColor: C.onPrimary,
            shadow: true,
            title: 'Kalender Otomatis Cerdas',
            body:
                'Jadwal penyiraman & pemupukan dihitung berdasarkan usia tanaman dan varietas cabai secara akurat.',
          ),
          const SizedBox(height: 8),
          const _FeatureRow(
            icon: Icons.biotech,
            iconBg: C.surfaceHigh,
            iconColor: C.primary,
            title: 'Rekomendasi Dosis Pupuk',
            body:
                'Takaran spesifik jenis pupuk organik dan anorganik untuk mencegah keracunan hara atau defisiensi mineral.',
          ),
          const SizedBox(height: 8),
          const _FeatureRow(
            icon: Icons.wb_sunny,
            iconBg: C.tertiaryFixed,
            iconColor: C.tertiary,
            title: 'Penyesuaian Cuaca Real-Time',
            body:
                'Jadwal penyiraman otomatis ditunda jika sensor mendeteksi anomali cuaca di koordinat kebun.',
          ),
        ],
      ),
    );
  }

  Widget _scheduleTile({
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String chip,
    required Color chipBg,
    required Color chipFg,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.surfaceLowest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(title,
                          overflow: TextOverflow.ellipsis,
                          style: _ts(12, 16, FontWeight.w600, C.onSurface)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(chip,
                          style: _ts(10, 14, FontWeight.w700, chipFg)),
                    ),
                  ],
                ),
                Text(subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: _ts(12, 16, FontWeight.w400, C.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

// ═══════════════════════════ LANGKAH 4 – NOTIFIKASI ═══════════════════════════
class _Step4 extends StatelessWidget {
  const _Step4();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pusat siaga
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _softShadow,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                            color: C.primaryContainer, shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_active,
                            size: 16, color: C.onPrimary),
                      ),
                      const SizedBox(width: 4),
                      Text('PUSAT SIAGA LAPANGAN',
                          style: _ts(10, 14, FontWeight.w700,
                              C.onSurfaceVariant,
                              letterSpacing: 1.0)),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: C.surfaceLowest,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: _softShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _Blink(child: _Dot(color: C.primary, size: 6)),
                        const SizedBox(width: 4),
                        Text('Real-time',
                            style: _ts(10, 14, FontWeight.w700, C.primary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Alert 1
              _AlertTile(
                color: C.error,
                icon: Icons.thunderstorm,
                title: 'Peringatan Cuaca BMKG',
                badge: 'Prioritas Tinggi',
                badgeBg: C.errorContainer,
                badgeFg: C.onErrorContainer,
                body: Text.rich(
                  TextSpan(
                    style: _ts(12, 16, FontWeight.w400, C.onSurfaceVariant),
                    children: [
                      const TextSpan(
                          text:
                              'Angin kencang & kelembaban 94% di Blok C-2. Risiko penyakit '),
                      TextSpan(
                        text: 'Cercospora capsici',
                        style: _ts(12, 16, FontWeight.w500,
                            C.onSurfaceVariant,
                            fontStyle: FontStyle.italic),
                      ),
                      const TextSpan(text: ' meningkat tajam.'),
                    ],
                  ),
                ),
                footerLeft: '10 menit yang lalu',
                footerRight: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Tindakan Sanitasi',
                        style: _ts(10, 14, FontWeight.w600, C.tertiary)),
                    const Icon(Icons.chevron_right,
                        size: 14, color: C.tertiary),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Alert 2
              _AlertTile(
                color: C.primary,
                icon: Icons.water_drop,
                title: 'Pengingat Jadwal Sore',
                badge: 'Aktif',
                badgeBg: _P.onPrimaryContainer,
                badgeFg: _P.onSecondaryContainer,
                body: Text(
                  'Jadwal Siram 16.30 WIB: Dosis 350ml/tanaman bedeng varietas Cabai Rawit Merah.',
                  style: _ts(12, 16, FontWeight.w400, C.onSurfaceVariant),
                ),
                footerLeft: 'Pukul 16.00 WIB',
                footerRight: Material(
                  color: C.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      child: Text('Konfirmasi Selesai',
                          style: _ts(10, 14, FontWeight.w600, C.primary)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Alert 3 (ringkas)
              _AccentBox(
                color: C.tertiary,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: C.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.document_scanner,
                          size: 18, color: C.tertiary),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Scan Ulang Daun Disarankan',
                              overflow: TextOverflow.ellipsis,
                              style:
                                  _ts(12, 16, FontWeight.w600, C.onSurface)),
                          Text('Evaluasi pasca aplikasi fungisida tembaga',
                              overflow: TextOverflow.ellipsis,
                              style: _ts(12, 16, FontWeight.w400,
                                  C.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: C.surfaceHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('2 Hari Lagi',
                          style: _ts(10, 14, FontWeight.w700, C.tertiary)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _TagPill('LANGKAH 4 • NOTIFIKASI & PERINGATAN DINI',
            bg: _P.onPrimaryContainer,
            fg: _P.onSecondaryContainer,
            icon: Icons.verified,
            letterSpacing: 0.5),
        const SizedBox(height: 8),
        Text('4. Siaga dengan Notifikasi Pintar',
            style: _ts(22, 28, FontWeight.w700, C.onSurface,
                letterSpacing: -0.2)),
        const SizedBox(height: 8),
        Text(
          'Dapatkan peringatan dini risiko hama penyakit, ramalan cuaca ekstrem dari BMKG, serta pengingat rutin pemupukan langsung di ponsel Anda.',
          style: _ts(14, 22, FontWeight.w400, C.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        const _BigFeatureCard(
          icon: Icons.coronavirus,
          iconBg: C.errorContainer,
          iconColor: C.onErrorContainer,
          title: 'Peringatan Dini Penyakit & Hama',
          body:
              'Deteksi potensi wabah penyakit dan bakteri berbahaya berdasarkan anomali kelembaban udara mikro dan tren fluktuasi suhu kanopi tanaman Anda.',
        ),
        const SizedBox(height: 4),
        const _BigFeatureCard(
          icon: Icons.cloud_sync,
          iconBg: C.tertiaryFixed,
          iconColor: C.tertiary,
          title: 'Sinkronisasi Cuaca Ekstrem',
          body:
              'Rekomendasi taktis penundaan jadwal penyemprotan nutrisi saat cuaca ekstrem agar pupuk tidak terbasuh dan terbuang percuma.',
        ),
        const SizedBox(height: 4),
        const _BigFeatureCard(
          icon: Icons.alarm_on,
          iconBg: _P.onPrimaryContainer,
          iconColor: _P.onSecondaryContainer,
          title: 'Pengingat Perawatan Tepat Waktu',
          body:
              'Notifikasi push harian presisi yang bersahabat untuk jadwal penyiraman, perompesan tunas air, hingga pemupukan fase vegetatif dan generatif.',
        ),
      ],
    );
  }
}

// ═══════════════════════════ Widget bersama ═══════════════════════════
class _WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _WhiteCard({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: C.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _softShadow,
      ),
      child: child,
    );
  }
}

class _NetImage extends StatelessWidget {
  final String url;
  const _NetImage(this.url);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : Container(color: C.surfaceLow),
      errorBuilder: (_, __, ___) => Container(
        color: C.surfaceContainer,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, size: 32, color: C.outline),
      ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            _P.inverseSurface.withOpacity(0.8),
            _P.inverseSurface.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final FontWeight weight;
  const _GlassPill({
    required this.icon,
    required this.text,
    required this.color,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: C.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
        boxShadow: _softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: C.primary),
          const SizedBox(width: 8),
          Text(text, style: _ts(10, 14, weight, color)),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;
  final double? letterSpacing;
  const _TagPill(
    this.text, {
    this.bg = _P.onPrimaryContainer,
    this.fg = C.primary,
    this.icon,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: icon != null ? 12 : 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(text,
                style: _ts(10, 14, FontWeight.w700, fg,
                    letterSpacing: letterSpacing)),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String text;
  const _CheckRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
              color: _P.secondaryContainer, shape: BoxShape.circle),
          child: const Icon(Icons.check,
              size: 16, color: _P.onSecondaryContainer),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(text,
                style: _ts(12, 16, FontWeight.w400, C.onSurface)),
          ),
        ),
      ],
    );
  }
}

class _TipTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _TipTile({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
                color: _P.onPrimaryContainer, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: C.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _ts(12, 16, FontWeight.w600, C.onSurface)),
                Text(body,
                    style: _ts(12, 16, FontWeight.w400, C.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool shadow;
  final String title;
  final String body;
  const _FeatureRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.shadow = false,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
              boxShadow: shadow ? _softShadow : null,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _ts(14, 20, FontWeight.w600, C.onSurface)),
                const SizedBox(height: 2),
                Text(body,
                    style: _ts(12, 18, FontWeight.w400, C.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BigFeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String body;
  const _BigFeatureCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: C.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _ts(18, 24, FontWeight.w600, C.onSurface)),
                const SizedBox(height: 4),
                Text(body,
                    style: _ts(12, 18, FontWeight.w400, C.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kotak putih dengan garis aksen 4px di kiri.
class _AccentBox extends StatelessWidget {
  final Color color;
  final Widget child;
  const _AccentBox({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: C.surfaceLowest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: _softShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String badge;
  final Color badgeBg;
  final Color badgeFg;
  final Widget body;
  final String footerLeft;
  final Widget footerRight;
  const _AlertTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.badge,
    required this.badgeBg,
    required this.badgeFg,
    required this.body,
    required this.footerLeft,
    required this.footerRight,
  });

  @override
  Widget build(BuildContext context) {
    return _AccentBox(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(title,
                          overflow: TextOverflow.ellipsis,
                          style: _ts(12, 16, FontWeight.w600, C.onSurface)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(badge,
                    style: _ts(10, 14, FontWeight.w700, badgeFg)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          body,
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(footerLeft, style: _ts(10, 14, FontWeight.w700, C.outline)),
              footerRight,
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════ Animasi kecil ═══════════════════════════
class _Dot extends StatelessWidget {
  final Color color;
  final double size;
  const _Dot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// Efek berdenyut (setara animate-pulse).
class _Blink extends StatefulWidget {
  final Widget child;
  const _Blink({required this.child});

  @override
  State<_Blink> createState() => _BlinkState();
}

class _BlinkState extends State<_Blink> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.4).animate(_c),
        child: widget.child,
      );
}

/// Target scan: cincin yang membesar & memudar (setara animate-ping).
class _Ping extends StatefulWidget {
  const _Ping();

  @override
  State<_Ping> createState() => _PingState();
}

class _PingState extends State<_Ping> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final t = Curves.easeOut.transform(_c.value);
              return Opacity(
                opacity: 0.75 * (1 - t),
                child: Transform.scale(
                  scale: 1 + t,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: C.primaryFixed, width: 1),
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: C.primaryFixed.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 4,
                    offset: Offset(0, 2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}