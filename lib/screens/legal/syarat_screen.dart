// syarat_screen.dart
//
// Layar "Syarat & Ketentuan" Capsee.
// Memakai class warna `C` dari notifikasi_screen.dart (satu folder di lib/).
// Dependensi: google_fonts.
//
// Pemakaian:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => SyaratScreen(onAgreed: () { /* simpan persetujuan ke backend */ }),
//   ));

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';

const _secondary = AppColors.secondary;

const _kImgCabai =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuACXKFh4uJJo_9LdD7gVIMkBulVs-nN_Lh8BrSPNR5yiexRNG2sMplxELObCVynXUHbWbFAneF85ql3sX4Iah7dUk-2saIkGskfjUxFwLsF2bTU-P6Qd2nDc-tXBS6K9HmwnnBVMuDCW-f9kSvCidnd3jYNZNxbjQ2NCtRxKTkZ7OvSn_-yvPmjRqPCTqLEJVJAtT-gPqI3VcAmNT1W_tdNkYFEi6JwYElFOwcA6JVYJYkQCeCCi6sQSQ';

const _kImgAgronom =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBM6NLnlnqrivMI7Ed64tnTKqFNmzKflCK8vA0hOC76qRXit1P1O-mmjC23y7vCO4AfA7bf7LnejWOeu3A2GR1buqsN5ANUYk8aaWUw0Ute0wKOMrVOv3ZuyEEPT5ZtAL1YGS1JLVvm55oYSqDS8iJmlS7Q0V3EYQc-g9oY37t0V1jRU9GiwrqbSKWKrdZUSNhgd-kgu643EykrqNrakxYXPMKrLAoGobrwiaWg8puweeg_dcNIss86sQ';

TextStyle _ts(double size, double height, FontWeight w, Color color,
        {double? letterSpacing}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: height / size,
      fontWeight: w,
      color: color,
      letterSpacing: letterSpacing,
    );

const _softShadow = [
  BoxShadow(color: AppColors.shadow, blurRadius: 3, offset: Offset(0, 1)),
];

/// Teks dengan potongan tebal. Gunakan `_b('...')` untuk bagian bold.
class _Seg {
  final String text;
  final bool bold;
  const _Seg(this.text, [this.bold = false]);
}

Text _rich(List<_Seg> segs, TextStyle base) => Text.rich(
      TextSpan(
        style: base,
        children: [
          for (final s in segs)
            TextSpan(
              text: s.text,
              style: s.bold ? base.copyWith(fontWeight: FontWeight.w700) : null,
            ),
        ],
      ),
    );

enum _AgreeState { idle, saving, saved }

class SyaratScreen extends StatefulWidget {
  /// Dipanggil setelah persetujuan "tersimpan". Jika null, layar hanya ditutup.
  final Future<void> Function()? onAgreed;
  const SyaratScreen({super.key, this.onAgreed});

  @override
  State<SyaratScreen> createState() => _SyaratScreenState();
}

class _SyaratScreenState extends State<SyaratScreen> {
  static const _navLabels = [
    '1. Definisi',
    '2. Akun & Privasi',
    '3. Deteksi ML',
    '4. Data Lahan',
    '5. Tanggung Jawab',
    '6. Kontak',
  ];

  final _scroll = ScrollController();
  final _keys = List.generate(6, (_) => GlobalKey());

  bool _consent = true;
  _AgreeState _agree = _AgreeState.idle;

  @override
  void dispose() {
    _scroll.dispose();
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

  Future<void> _handleAgree() async {
    if (_agree != _AgreeState.idle || !_consent) return;
    setState(() => _agree = _AgreeState.saving);
    try {
      await (widget.onAgreed?.call() ??
          Future<void>.delayed(const Duration(milliseconds: 500)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _agree = _AgreeState.idle);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan persetujuan. Coba lagi.')),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _agree = _AgreeState.saved);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.surface,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        controller: _scroll,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 576),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMeta(),
                  const SizedBox(height: 24),
                  _buildIntro(),
                  const SizedBox(height: 24),
                  _buildNavPills(),
                  const SizedBox(height: 32),
                  _pasal1(),
                  const SizedBox(height: 32),
                  _pasal2(),
                  const SizedBox(height: 32),
                  _buildInterlude(),
                  const SizedBox(height: 32),
                  _pasal3(),
                  const SizedBox(height: 32),
                  _pasal4(),
                  const SizedBox(height: 32),
                  _pasal5(),
                  const SizedBox(height: 32),
                  _pasal6(),
                  const SizedBox(height: 24),
                  _buildAcceptance(context),
                ],
              ),
            ),
          ),
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
          color: C.surface.withValues(alpha: 0.95),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 1)),
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
                        size: 24, color: C.onSurface),
                    style: IconButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        shape: const CircleBorder()),
                  ),
                  Expanded(
                    child: Text(
                      'Syarat & Ketentuan',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: _ts(18, 24, FontWeight.w600, C.onSurface,
                          letterSpacing: -0.2),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── Metadata ─────────
  Widget _buildMeta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: C.surfaceHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history, size: 14, color: C.primary),
              const SizedBox(width: 4),
              Text('Versi Dokumen: 2.4.0',
                  style: _ts(10, 14, FontWeight.w700, C.onSurfaceVariant)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('Syarat & Ketentuan',
            style: _ts(28, 36, FontWeight.w700, C.onSurface, letterSpacing: -0.3)),
        const SizedBox(height: 4),
        Text('Terakhir diperbarui: 15 Mei 2024',
            style: _ts(12, 16, FontWeight.w400, C.outline)),
      ],
    );
  }

  // ───────── Intro ─────────
  Widget _buildIntro() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _softShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -24,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: C.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: C.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _softShadow,
                      ),
                      child: const Icon(Icons.verified_user_outlined,
                          size: 24, color: C.onPrimary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Panduan Kemitraan Digital',
                              style: _ts(18, 24, FontWeight.w600, C.onSurface)),
                          const SizedBox(height: 4),
                          _rich(
                            const [
                              _Seg('Selamat datang di ekosistem '),
                              _Seg('Capsee', true),
                              _Seg(
                                  '. Kami berdedikasi menjaga kedaulatan data perkebunan cabai Anda serta memberikan wawasan agronomis cerdas yang aman, etis, dan transparan.'),
                            ],
                            _ts(14, 22, FontWeight.w400, C.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: C.surfaceLowest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.diversity_3,
                          size: 18, color: C.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dengan mengakses atau melanjutkan aplikasi Capsee, Anda menyepakati asas keterbukaan dan pedoman teknis berikut.',
                          style: _ts(12, 19, FontWeight.w400, C.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────── Navigator pasal ─────────
  Widget _buildNavPills() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _navLabels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemBuilder: (_, i) => Material(
          color: C.surfaceHigh,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => _jumpTo(i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_navLabels[i],
                  style: _ts(12, 16, FontWeight.w600, C.onSurfaceVariant)),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── Kerangka pasal ─────────
  Widget _section(int index, String title, List<Widget> children) {
    return Container(
      key: _keys[index],
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: C.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: C.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${index + 1}',
                    style: _ts(18, 24, FontWeight.w600, C.primary)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: _ts(18, 24, FontWeight.w600, C.onSurface)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  TextStyle get _body => _ts(14, 22, FontWeight.w400, C.onSurfaceVariant);
  TextStyle get _small => _ts(12, 19, FontWeight.w400, C.onSurfaceVariant);

  // ───────── Pasal 1 ─────────
  Widget _pasal1() {
    return _section(0, 'Ketentuan Umum & Definisi', [
      Text(
        'Aplikasi Capsee diselenggarakan sebagai perangkat lunak asistensi lapangan presisi tinggi untuk komoditas hortikultura, khususnya tanaman cabai (Capsicum annuum & Capsicum frutescens).',
        style: _body,
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Column(
          children: [
            _checkItem([
              const _Seg('Layanan Capsee: ', true),
              const _Seg(
                  'Mencakup modul pemindaian daun via kamera ponsel pintar, diagnosis patogen daun otomatis, dan pencatatan riwayat plot lahan budidaya.'),
            ]),
            const SizedBox(height: 8),
            _checkItem([
              const _Seg('Pengguna: ', true),
              const _Seg(
                  'Petani, mandor kebun, kelompok tani (Poktan), maupun praktisi riset botani yang terdaftar secara sah.'),
            ]),
          ],
        ),
      ),
    ]);
  }

  Widget _checkItem(List<_Seg> segs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle_outline, size: 18, color: C.primary),
        ),
        const SizedBox(width: 8),
        Expanded(child: _rich(segs, _small)),
      ],
    );
  }

  // ───────── Pasal 2 ─────────
  Widget _pasal2() {
    return _section(1, 'Akun & Keamanan Pengguna', [
      Text(
        'Keakuratan hasil kalkulasi analitik sangat bergantung pada validitas informasi agroklimat dan profil kebun yang Anda input ke dalam sistem.',
        style: _body,
      ),
      const SizedBox(height: 16),
      _tintedItem(Icons.shield_outlined, C.primary,
          'Kerahasiaan nomor ponsel terdaftar, kata sandi, dan kode OTP adalah kewajiban mutlak pemilik akun.'),
      const SizedBox(height: 8),
      _tintedItem(Icons.pin_drop_outlined, C.primary,
          'Pengguna wajib mencantumkan lokasi koordinat bedengan atau petak lahan yang sebenarnya guna kalibrasi sensor cuaca mikro.'),
    ]);
  }

  Widget _tintedItem(IconData icon, Color iconColor, String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: _small)),
        ],
      ),
    );
  }

  // ───────── Banner selingan ─────────
  Widget _buildInterlude() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [C.surfaceHigh, C.surfaceContainer],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _RoundedImage(_kImgCabai, size: 64, shadow: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PRINSIP KEBERLANJUTAN',
                    style: _ts(10, 14, FontWeight.w700, C.primary,
                        letterSpacing: 1.0)),
                Text('Agronomi Presisi Ramah Lingkungan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ts(12, 16, FontWeight.w600, C.onSurface)),
                Text(
                  'Efisiensi penggunaan input kimiawi melalui deteksi sedini mungkin.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _ts(12, 16, FontWeight.w400, C.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────── Pasal 3 ─────────
  Widget _pasal3() {
    return _section(2, 'Layanan Machine Learning & AI', [
      Text(
        'Model inferensi visual Capsee didesain dengan tingkat konfidensi tinggi, namun wajib diposisikan sebagai instrumen pendukung keputusan:',
        style: _body,
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.errorContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 20, color: C.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text('Penting: Panduan Pendukung Keputusan',
                      style: _ts(14, 20, FontWeight.w700, C.error)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Keluaran diagnosis (seperti bercak daun Cercospora, virus kuning Gemini, atau antraknosa) merupakan rekomendasi algoritmis. Untuk aplikasi fungisida atau bakterisida skala luas komersial, Pengguna sangat dianjurkan untuk mengikuti dosis pada kemasan atau berkonsultasi dengan ahli pertanian setempat.',
              style: _small,
            ),
          ],
        ),
      ),
    ]);
  }

  // ───────── Pasal 4 ─────────
  Widget _pasal4() {
    return _section(3, 'Data Lahan & Hak Cipta', [
      _rich(
        const [
          _Seg(
              'Semua foto daun, koordinat GPS petak, dan catatan agronomi yang Anda unggah tetap merupakan '),
          _Seg('hak kepemilikan Anda', true),
          _Seg('.'),
        ],
        _body,
      ),
      const SizedBox(height: 8),
      Text(
        'Dengan mengunggah sampel citra, Anda memberikan lisensi non-eksklusif dan anonim kepada tim Capsee untuk memproses citra demi penyempurnaan akurasi dataset model saraf tiruan petani Indonesia.',
        style: _small,
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: C.surfaceLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _RoundedImage(_kImgAgronom, size: 56),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enkripsi Data Standar Industri',
                      style: _ts(12, 16, FontWeight.w600, C.onSurface)),
                  Text(
                    'Seluruh data riwayat petak tersimpan aman di server terenkripsi.',
                    style: _ts(12, 16, FontWeight.w400, C.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  // ───────── Pasal 5 ─────────
  Widget _pasal5() {
    return _section(4, 'Batasan Tanggung Jawab', [
      Text(
        'Capsee tidak bertanggung jawab secara finansial atas kerugian hasil panen, penurunan tonase, atau kegagalan budidaya yang diakibatkan oleh:',
        style: _body,
      ),
      const SizedBox(height: 16),
      _tintedItem(Icons.thunderstorm_outlined, C.outline,
          'Keadaan kahar (force majeure) mencakup anomali iklim ekstrem (El Niño/La Niña), badai, kekeringan, atau banjir bandang.'),
      const SizedBox(height: 8),
      _tintedItem(Icons.science_outlined, C.outline,
          'Kekeliruan dosis pencampuran bahan aktif pestisida yang dilakukan secara mandiri di luar panduan kemasan produk.'),
    ]);
  }

  // ───────── Pasal 6 ─────────
  Widget _pasal6() {
    return _section(5, 'Pembaruan & Saluran Bantuan', [
      Text(
        'Ketentuan ini dapat disesuaikan berkala mengikuti perkembangan teknologi dan regulasi kementerian terkait. Setiap pembaruan material akan dikirimkan melalui notifikasi aplikasi paling lambat 7 hari sebelum efektif.',
        style: _body,
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surfaceLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pusat Resolusi Masalah Pertanian:',
                style: _ts(12, 16, FontWeight.w600, C.onSurface)),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                await Clipboard.setData(
                    const ClipboardData(text: 'bantuan@capsee.id'));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email disalin ke papan klip')),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mail_outline, size: 20, color: C.primary),
                    const SizedBox(width: 4),
                    Text(
                      'bantuan@capsee.id',
                      style: _ts(18, 24, FontWeight.w600, C.primary).copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: C.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('Layanan respon aktif: Senin - Sabtu, 07:00 - 17:00 WIB',
                style: _small),
          ],
        ),
      ),
    ]);
  }

  // ───────── Persetujuan ─────────
  Widget _buildAcceptance(BuildContext context) {
    final busy = _agree != _AgreeState.idle;
    final saved = _agree == _AgreeState.saved;
    final enabled = _consent && !busy;

    Widget btnContent;
    switch (_agree) {
      case _AgreeState.saving:
        btnContent = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: C.onPrimary),
            ),
            const SizedBox(width: 8),
            Text('Menyimpan Persetujuan...',
                style: _ts(14, 20, FontWeight.w600, C.onPrimary)),
          ],
        );
        break;
      case _AgreeState.saved:
        btnContent = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 20, color: C.onPrimary),
            const SizedBox(width: 8),
            Text('Persetujuan Tersimpan',
                style: _ts(14, 20, FontWeight.w600, C.onPrimary)),
          ],
        );
        break;
      case _AgreeState.idle:
        btnContent = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task_alt, size: 20, color: C.onPrimary),
            const SizedBox(width: 8),
            Text('Saya Mengerti & Setuju',
                style: _ts(14, 20, FontWeight.w600, C.onPrimary)),
          ],
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: C.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: busy ? null : () => setState(() => _consent = !_consent),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _consent ? C.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _consent ? C.primary : C.outline,
                          width: 2,
                        ),
                      ),
                      child: _consent
                          ? const Icon(Icons.check,
                              size: 18, color: C.onPrimary)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Konfirmasi Pemahaman',
                            style: _ts(14, 20, FontWeight.w600, C.onSurface)),
                        Text(
                          'Saya telah membaca, memahami, serta menerima seluruh ketentuan pemanfaatan platform Capsee demi keberhasilan panen cabai saya.',
                          style: _small,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: (_consent || busy) ? 1 : 0.45,
          child: Material(
            color: saved ? _secondary : C.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: enabled ? _handleAgree : null,
              child: SizedBox(height: 56, child: btnContent),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: C.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: busy ? null : () => Navigator.maybePop(context),
            child: SizedBox(
              height: 48,
              child: Center(
                child: Text('Kembali ke Pengaturan Akun',
                    style: _ts(12, 16, FontWeight.w600, C.onSurface)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundedImage extends StatelessWidget {
  final String url;
  final double size;
  final bool shadow;
  const _RoundedImage(this.url, {required this.size, this.shadow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: shadow ? _softShadow : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: C.surfaceContainer,
            alignment: Alignment.center,
            child: const Icon(Icons.image_outlined, size: 24, color: C.outline),
          ),
        ),
      ),
    );
  }
}
