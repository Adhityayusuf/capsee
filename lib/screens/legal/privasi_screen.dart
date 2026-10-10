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

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../widgets/ui_kit.dart';

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
        padding: const EdgeInsets.all(AppSpace.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMetaChips(),
            const SizedBox(height: 16),
            Text('Kebijakan Privasi Capsee',
                style: AppText.display(context)),
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
                        style: AppText.headline(context),
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
    return const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        StatusBadge(label: 'Versi Dokumen: 2.1.0', kind: BadgeKind.success),
        StatusBadge(
            label: 'Terakhir diperbarui: 18 Mei 2024', kind: BadgeKind.info),
      ],
    );
  }

  // ───────── Intro ─────────
  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(AppSpace.page),
      decoration: BoxDecoration(
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusCard),
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
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
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
                    style: AppText.subtitle(context)),
                const SizedBox(height: 4),
                Text(
                  'Di Capsee, kami menghargai privasi dan kepercayaan Anda sebagai penggerak pertanian cabai. Dokumen ini menjelaskan bagaimana kami mengumpulkan, mengelola, serta melindungi data kebun dan privasi akun Anda secara transparan.',
                  style: AppText.bodySm(context),
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
          borderRadius: BorderRadius.circular(AppSpace.radiusPill),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpace.radiusPill),
            onTap: () => _jumpTo(i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(_navLabels[i],
                  style: AppText.bodySm(context, color: context.palette.title)
                      .copyWith(fontWeight: FontWeight.w600)),
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
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          icon: Icons.privacy_tip_outlined,
          title: title,
          trailing: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badgeBg ?? context.palette.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: Text('${index + 1}',
                style: AppText.caption(context, color: context.palette.accent)
                    .copyWith(fontWeight: FontWeight.w800)),
          ),
        ),
        SizedBox(height: gap),
        ...children,
      ],
    );
    if (bg != null) {
      return Container(
        key: _keys[index],
        padding: const EdgeInsets.all(AppSpace.page),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpace.radiusCard),
          boxShadow: [
            BoxShadow(
                color: context.palette.shadow,
                blurRadius: 3,
                offset: const Offset(0, 1))
          ],
        ),
        child: content,
      );
    }
    return CapseeCard(
      key: _keys[index],
      child: content,
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
              Text(title, style: AppText.subtitle(context)),
              Text(body, style: AppText.bodySm(context)),
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
                    style: AppText.bodySm(context,
                            color: context.palette.title)
                        .copyWith(fontWeight: FontWeight.w700)),
                TextSpan(text: body, style: AppText.bodySm(context)),
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
          padding: const EdgeInsets.all(AppSpace.page),
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(AppSpace.radiusTile),
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
              Text(title, style: AppText.subtitle(context)),
              const SizedBox(height: 2),
              Text(body, style: AppText.bodySm(context)),
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
      padding: const EdgeInsets.all(AppSpace.radiusTile),
      decoration: BoxDecoration(
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: AppText.bodySm(context, color: context.palette.title)
                    .copyWith(fontWeight: FontWeight.w600)),
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
            borderRadius: BorderRadius.circular(AppSpace.radiusTile),
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
                  Text('Email:', style: AppText.subtitle(context)),
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
                      style: AppText.bodySm(context, color: context.palette.accent)
                          .copyWith(
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
                  Text('Layanan respons:', style: AppText.subtitle(context)),
                  Text('Senin – Sabtu, 08:00 – 17:00 WIB',
                      style: AppText.bodySm(context)),
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
            borderRadius: BorderRadius.circular(AppSpace.radiusCard),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpace.radiusCard),
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
                        style: AppText.bodySm(context,
                            color: context.palette.title),
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
            borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
              onTap: _handleAgree,
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.done_all, size: 20, color: context.palette.onPrimary),
                    const SizedBox(width: 8),
                    Text('Saya Mengerti',
                        style: AppText.headline(context,
                            color: context.palette.onPrimary)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: context.palette.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            onTap: () => Navigator.maybePop(context),
            child: SizedBox(
              height: 48,
              child: Center(
                child: Text('Kembali ke Pengaturan Akun',
                    style: AppText.subtitle(context)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
