// privasi_screen.dart
//
// Layar "Kebijakan Privasi" Capsee.
// Memakai class warna `C` dari notifikasi_screen.dart (satu folder di lib/).
// Dependensi: google_fonts.
//
// Pemakaian:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => PrivasiScreen(onAgreed: () { /* simpan persetujuan */ }),
//   ));

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_theme.dart';

TextStyle _ts(double size, double height, FontWeight w, Color color,
        {double? letterSpacing}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: height / size,
      fontWeight: w,
      color: color,
      letterSpacing: letterSpacing,
    );

class PrivasiScreen extends StatefulWidget {
  /// Dipanggil saat pengguna menyetujui (checkbox tercentang). Layar lalu ditutup.
  final VoidCallback? onAgreed;
  const PrivasiScreen({super.key, this.onAgreed});

  @override
  State<PrivasiScreen> createState() => _PrivasiScreenState();
}

class _PrivasiScreenState extends State<PrivasiScreen> {
  static const _navLabels = [
    '1. Data Dikumpulkan',
    '2. Penggunaan Data',
    '3. Keamanan Data',
    '4. Retensi Data',
    '5. Hak Petani',
    '6. Kontak DPO',
  ];

  final _keys = List.generate(6, (_) => GlobalKey());
  final _consentKey = GlobalKey();

  bool _consent = false;
  bool _flash = false;
  Timer? _flashTimer;

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  void _jumpTo(int i) {
    final ctx = _keys[i].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.02,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _handleAgree() {
    if (!_consent) {
      final ctx = _consentKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.5,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
      setState(() => _flash = true);
      _flashTimer?.cancel();
      _flashTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _flash = false);
      });
      return;
    }
    widget.onAgreed?.call();
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMetaChips(),
            const SizedBox(height: 16),
            Text('Kebijakan Privasi Capsee',
                style: _ts(22, 28, FontWeight.w700, context.palette.title,
                    letterSpacing: -0.2)),
            const SizedBox(height: 12),
            _buildIntro(),
            const SizedBox(height: 20),
            _buildNavPills(),
            const SizedBox(height: 24),
            _sec1(),
            const SizedBox(height: 16),
            _sec2(),
            const SizedBox(height: 16),
            _sec3(),
            const SizedBox(height: 16),
            _sec4(),
            const SizedBox(height: 16),
            _sec5(),
            const SizedBox(height: 16),
            _sec6(),
            const SizedBox(height: 32),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  // ───────── AppBar ─────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        decoration: BoxDecoration(
          color: context.palette.surface.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
                color: context.palette.shadow, blurRadius: 8, offset: const Offset(0, 1)),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.maybePop(context),
                    icon: Icon(Icons.arrow_back,
                        size: 24, color: context.palette.title),
                    style: IconButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        shape: const CircleBorder()),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 36),
                      child: Text(
                        'Kebijakan Privasi',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: _ts(18, 24, FontWeight.w700, context.palette.title,
                            letterSpacing: -0.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── Chip metadata ─────────
  Widget _buildMetaChips() {
    Widget chip(IconData icon, Color iconColor, String text, Color bg,
        Color fg) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(text, style: _ts(12, 16, FontWeight.w600, fg)),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(Icons.verified, context.palette.accent, 'Versi Dokumen: 2.1.0', context.palette.surfaceAlt,
            context.palette.title),
        chip(Icons.schedule, context.palette.subtitle,
            'Terakhir diperbarui: 18 Mei 2024', context.palette.surfaceAlt,
            context.palette.subtitle),
      ],
    );
  }

  // ───────── Intro ─────────
  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: context.palette.shadow, blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.palette.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.verified_user,
                size: 24, color: context.palette.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Komitmen Kedaulatan & Keamanan Data Petani',
                    style: _ts(14, 20, FontWeight.w700, context.palette.title)),
                const SizedBox(height: 4),
                Text(
                  'Di Capsee, kami menghargai privasi dan kepercayaan Anda sebagai penggerak pertanian cabai. Dokumen ini menjelaskan bagaimana kami mengumpulkan, mengelola, serta melindungi data kebun dan privasi akun Anda secara transparan.',
                  style: _ts(12, 19, FontWeight.w400, context.palette.subtitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────── Navigator bagian ─────────
  Widget _buildNavPills() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _navLabels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Material(
          color: context.palette.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => _jumpTo(i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(_navLabels[i],
                  style: _ts(12, 16, FontWeight.w600, context.palette.title)),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── Kerangka bagian ─────────
  Widget _section({
    required int index,
    required String title,
    required List<Widget> children,
    Color? bg,
    Color? badgeBg,
    double gap = 14,
  }) {
    final p = context.palette;
    return Container(
      key: _keys[index],
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg ?? p.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: context.palette.shadow, blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeBg ?? p.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${index + 1}',
                    style: _ts(12, 16, FontWeight.w700, context.palette.accent)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: _ts(18, 24, FontWeight.w600, context.palette.title)),
              ),
            ],
          ),
          SizedBox(height: gap),
          ...children,
        ],
      ),
    );
  }

  TextStyle get _small => _ts(12, 19, FontWeight.w400, context.palette.subtitle);

  // ───────── 1. Data dikumpulkan ─────────
  Widget _sec1() {
    return _section(
      index: 0,
      title: 'Data yang Dikumpulkan',
      children: [
        Text(
          'Untuk memberikan diagnosis patogen daun cabai secara presisi dan kalibrasi rekomendasi mikro-agronomi, kami mengumpulkan kategori data berikut:',
          style: _small,
        ),
        const SizedBox(height: 16),
        _dataItem(
          Icons.person_outline,
          'Data Akun & Profil',
          'Nama lengkap, alamat email, dan nomor telepon terdaftar untuk autentikasi ganda serta komunikasi sistem budidaya.',
        ),
        const SizedBox(height: 12),
        _dataItem(
          Icons.photo_camera_outlined,
          'Citra Daun & Analisis Patogen',
          'Foto sampel visual daun cabai yang diunggah melalui kamera ponsel untuk inferensi model computer vision (Cercospora, Gemini virus, antraknosa).',
        ),
        const SizedBox(height: 12),
        _dataItem(
          Icons.pin_drop_outlined,
          'Data Spasial & Agroklimat',
          'Titik koordinat GPS bedengan lahan untuk kalibrasi cuaca mikro harian BMKG, kelembapan tanah, dan data sensor IoT kebun.',
        ),
      ],
    );
  }

  Widget _dataItem(IconData icon, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
              color: context.palette.accentSoft, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: context.palette.onAccentSoft),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _ts(14, 20, FontWeight.w700, context.palette.title)),
              Text(body, style: _small),
            ],
          ),
        ),
      ],
    );
  }

  // ───────── 2. Penggunaan data ─────────
  Widget _sec2() {
    return _section(
      index: 1,
      title: 'Penggunaan Data',
      children: [
        Text(
          'Data yang terkumpul diproses secara ketat semata-mata untuk meningkatkan produktivitas serta mitigasi hama tanaman cabai Anda:',
          style: _small,
        ),
        const SizedBox(height: 14),
        _useItem('Diagnosis Tanaman Akurat: ',
            'Memproses citra visual menggunakan model machine learning guna mendeteksi penyakit cabai sedini mungkin.'),
        const SizedBox(height: 10),
        _useItem('Rekomendasi Agronomi Presisi: ',
            'Mengoptimalkan rekomendasi jadwal penyiraman, pemupukan NPK/organik, dan dosis fungisida/bakterisida sesuai fase pertumbuhan.'),
        const SizedBox(height: 10),
        _useItem('Penyempurnaan Model AI (Anonim): ',
            'Data citra tanaman dapat diagregasikan secara terenkripsi dan anonim untuk meningkatkan akurasi pendeteksian patogen cabai nusantara tanpa menghubungkannya dengan identitas pribadi Anda.'),
        const SizedBox(height: 10),
        _useItem('Komunikasi Notifikasi: ',
            'Mengirimkan pengingat perawatan berkala dan peringatan dini anomali cuaca ekstrim ke perangkat Anda.'),
      ],
    );
  }

  Widget _useItem(String label, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle_outline, size: 18, color: context.palette.accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: label,
                    style: _ts(12, 19, FontWeight.w700, context.palette.title)),
                TextSpan(text: body, style: _small),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ───────── 3. Keamanan ─────────
  Widget _sec3() {
    return _section(
      index: 2,
      title: 'Keamanan & Enkripsi Data',
      bg: context.palette.surfaceAlt,
      gap: 12,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _secureItem(
                Icons.lock_outline,
                context.palette.primary,
                'Standar Enkripsi End-to-End & AES-256',
                'Seluruh transmisi foto lahan dan data agrikultur dilindungi enkripsi standar industri saat transit maupun at-rest di server awan berstandar ISO 27001.',
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _secureItem(
                  Icons.gavel,
                  context.palette.primary,
                  'Kedaulatan Kepemilikan Data',
                  'Hak cipta dan kepemilikan atas foto kebun serta riwayat plot budidaya sepenuhnya tetap berada di tangan Petani. Capsee tidak pernah memperjualbelikan data lahan Anda kepada pihak ketiga untuk kepentingan periklanan komersial.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _secureItem(IconData icon, Color bg, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: context.palette.onPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _ts(14, 20, FontWeight.w700, context.palette.title)),
              const SizedBox(height: 2),
              Text(body, style: _small),
            ],
          ),
        ),
      ],
    );
  }

  // ───────── 4. Retensi ─────────
  Widget _sec4() {
    return _section(
      index: 3,
      title: 'Penyimpanan & Retensi Data',
      gap: 10,
      children: [
        Text(
          'Data riwayat pemindaian disimpan selama akun Anda aktif untuk memantau tren kesehatan kebun antar musim tanam. Pengguna berhak meminta penghapusan riwayat tertentu kapan saja melalui menu pengelolaan data kebun di aplikasi.',
          style: _small,
        ),
      ],
    );
  }

  // ───────── 5. Hak pengguna ─────────
  Widget _sec5() {
    return _section(
      index: 4,
      title: 'Hak Pengguna & Akses Kontrol',
      gap: 12,
      children: [
        Text(
          'Sesuai regulasi pelindungan data pribadi yang berlaku, Anda memiliki kendali penuh atas akun budidaya Anda:',
          style: _small,
        ),
        const SizedBox(height: 12),
        _rightItem(Icons.download_outlined, context.palette.accent,
            'Hak mengunduh salinan riwayat plot lahan (ekspor PDF/CSV).'),
        const SizedBox(height: 8),
        _rightItem(Icons.edit_note, context.palette.accent,
            'Hak memperbarui atau mengoreksi data profil sewaktu-waktu.'),
        const SizedBox(height: 8),
        _rightItem(Icons.delete_forever_outlined, context.palette.error,
            'Hak menghapus akun dan data kebun secara permanen.'),
      ],
    );
  }

  Widget _rightItem(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: _ts(12, 19, FontWeight.w500, context.palette.title)),
          ),
        ],
      ),
    );
  }

  // ───────── 6. Kontak DPO ─────────
  Widget _sec6() {
    return _section(
      index: 5,
      title: 'Kontak Petugas Perlindungan Data (DPO)',
      bg: context.palette.surfaceAlt,
      badgeBg: context.palette.surfaceAlt,
      gap: 12,
      children: [
        Text(
          'Jika Anda memiliki pertanyaan mengenai tata kelola privasi atau hendak mengeksekusi hak data Anda, silakan hubungi tim DPO Capsee:',
          style: _small,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 2,
                children: [
                  Icon(Icons.mail_outline, size: 20, color: context.palette.accent),
                  Text('Email:',
                      style: _ts(12, 16, FontWeight.w700, context.palette.title)),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(
                          const ClipboardData(text: 'privasi@capsee.id'));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Email disalin ke papan klip')),
                      );
                    },
                    child: Text(
                      'privasi@capsee.id',
                      style: _ts(12, 16, FontWeight.w400, context.palette.accent).copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: context.palette.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 2,
                children: [
                  Icon(Icons.schedule, size: 20, color: context.palette.accent),
                  Text('Layanan respons:',
                      style: _ts(12, 16, FontWeight.w700, context.palette.title)),
                  Text('Senin – Sabtu, 08:00 – 17:00 WIB',
                      style:
                          _ts(12, 16, FontWeight.w400, context.palette.subtitle)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────── Persetujuan & aksi ─────────
  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          key: _consentKey,
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _flash ? context.palette.error.withValues(alpha: 0.12) : context.palette.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _consent = !_consent),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _consent,
                          onChanged: (v) =>
                              setState(() => _consent = v ?? false),
                          activeColor: context.palette.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Saya telah memahami Kebijakan Privasi dan menyetujui pengelolaan data sesuai ketentuan di atas.',
                        style: _ts(12, 17, FontWeight.w400, context.palette.title),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _consent ? 1 : 0.5,
          child: Material(
            color: context.palette.accent,
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _handleAgree,
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.done_all, size: 20, color: context.palette.onPrimary),
                    const SizedBox(width: 8),
                    Text('Saya Mengerti',
                        style: _ts(18, 24, FontWeight.w600, context.palette.onPrimary)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: context.palette.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.maybePop(context),
            child: SizedBox(
              height: 48,
              child: Center(
                child: Text('Kembali ke Pengaturan Akun',
                    style: _ts(14, 20, FontWeight.w500, context.palette.title)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
