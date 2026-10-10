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

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../widgets/ui_kit.dart';

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
      backgroundColor: context.palette.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        controller: _scroll,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 576),
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.page),
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
          color: context.palette.surface.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
                color: context.palette.shadow, blurRadius: 8, offset: const Offset(0, 1)),
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
                    icon: Icon(Icons.arrow_back,
                        size: 24, color: context.palette.title),
                    style: IconButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        shape: const CircleBorder()),
                  ),
                  Expanded(
                    child: Text(
                      'Syarat & Ketentuan',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.headline(context),
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
        const StatusBadge(label: 'Versi Dokumen: 2.4.0', kind: BadgeKind.success),
        const SizedBox(height: 4),
        Text('Syarat & Ketentuan', style: AppText.display(context)),
        const SizedBox(height: 4),
        Text('Terakhir diperbarui: 15 Mei 2024',
            style: AppText.caption(context, color: context.palette.hint)),
      ],
    );
  }

  // ───────── Intro ─────────
  Widget _buildIntro() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusCard),
        boxShadow: [BoxShadow(color: context.palette.shadow, blurRadius: 3, offset: const Offset(0, 1))],
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
                color: context.palette.accent.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpace.page),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.palette.primary,
                        borderRadius:
                            BorderRadius.circular(AppSpace.radiusTile),
                        boxShadow: [BoxShadow(color: context.palette.shadow, blurRadius: 3, offset: const Offset(0, 1))],
                      ),
                      child: Icon(Icons.verified_user_outlined,
                          size: 24, color: context.palette.onPrimary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Panduan Kemitraan Digital',
                              style: AppText.title(context)),
                          const SizedBox(height: 4),
                          _rich(
                            const [
                              _Seg('Selamat datang di ekosistem '),
                              _Seg('Capsee', true),
                              _Seg(
                                  '. Kami berdedikasi menjaga kedaulatan data perkebunan cabai Anda serta memberikan wawasan agronomis cerdas yang aman, etis, dan transparan.'),
                            ],
                            _ts(14, 22, FontWeight.w400, context.palette.subtitle),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(AppSpace.page),
                  decoration: BoxDecoration(
                    color: context.palette.surface,
                    borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.diversity_3,
                          size: 18, color: context.palette.accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dengan mengakses atau melanjutkan aplikasi Capsee, Anda menyepakati asas keterbukaan dan pedoman teknis berikut.',
                          style: _ts(12, 19, FontWeight.w400, context.palette.subtitle),
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
          color: context.palette.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpace.radiusPill),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpace.radiusPill),
            onTap: () => _jumpTo(i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_navLabels[i],
                  style: _ts(12, 16, FontWeight.w600, context.palette.subtitle)),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── Kerangka pasal ─────────
  Widget _section(int index, String title, List<Widget> children) {
    return CapseeCard(
      key: _keys[index],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            icon: Icons.article_outlined,
            title: title,
            trailing: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.palette.surfaceAlt,
                borderRadius: BorderRadius.circular(AppSpace.radiusTile),
              ),
              child: Text('${index + 1}',
                  style: AppText.headline(context, color: context.palette.accent)),
            ),
          ),
          const SizedBox(height: AppSpace.page),
          ...children,
        ],
      ),
    );
  }

  TextStyle get _body => _ts(14, 22, FontWeight.w400, context.palette.subtitle);
  TextStyle get _small => _ts(12, 19, FontWeight.w400, context.palette.subtitle);

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
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle_outline, size: 18, color: context.palette.accent),
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
      _tintedItem(Icons.shield_outlined, context.palette.accent,
          'Kerahasiaan nomor ponsel terdaftar, kata sandi, dan kode OTP adalah kewajiban mutlak pemilik akun.'),
      const SizedBox(height: 8),
      _tintedItem(Icons.pin_drop_outlined, context.palette.accent,
          'Pengguna wajib mencantumkan lokasi koordinat bedengan atau petak lahan yang sebenarnya guna kalibrasi sensor cuaca mikro.'),
    ]);
  }

  Widget _tintedItem(IconData icon, Color iconColor, String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
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
      padding: const EdgeInsets.all(AppSpace.page),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.palette.surfaceAlt, context.palette.surface],
        ),
        borderRadius: BorderRadius.circular(AppSpace.radiusCard),
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
                    style: AppText.overline(context,
                        color: context.palette.accent)),
                Text('Agronomi Presisi Ramah Lingkungan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.subtitle(context)),
                Text(
                  'Efisiensi penggunaan input kimiawi melalui deteksi sedini mungkin.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySm(context),
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
        padding: const EdgeInsets.all(AppSpace.page),
        decoration: BoxDecoration(
          color: context.palette.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpace.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 20, color: context.palette.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text('Penting: Panduan Pendukung Keputusan',
                      style: AppText.subtitle(context,
                          color: context.palette.error)),
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
          color: context.palette.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
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
                      style: AppText.subtitle(context)),
                  Text(
                    'Seluruh data riwayat petak tersimpan aman di server terenkripsi.',
                    style: AppText.bodySm(context),
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
      _tintedItem(Icons.thunderstorm_outlined, context.palette.icon,
          'Keadaan kahar (force majeure) mencakup anomali iklim ekstrem (El Niño/La Niña), badai, kekeringan, atau banjir bandang.'),
      const SizedBox(height: 8),
      _tintedItem(Icons.science_outlined, context.palette.icon,
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
        padding: const EdgeInsets.all(AppSpace.page),
        decoration: BoxDecoration(
          color: context.palette.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pusat Resolusi Masalah Pertanian:',
                style: AppText.subtitle(context)),
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
                    Icon(Icons.mail_outline, size: 20, color: context.palette.accent),
                    const SizedBox(width: 4),
                    Text(
                      'bantuan@capsee.id',
                      style: AppText.headline(context, color: context.palette.accent)
                          .copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: context.palette.accent,
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
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: context.palette.onPrimary),
            ),
            const SizedBox(width: 8),
            Text('Menyimpan Persetujuan...',
                style: AppText.subtitle(context,
                    color: context.palette.onPrimary)),
          ],
        );
        break;
      case _AgreeState.saved:
        btnContent = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 20, color: context.palette.onPrimary),
            const SizedBox(width: 8),
            Text('Persetujuan Tersimpan',
                style: AppText.subtitle(context,
                    color: context.palette.onPrimary)),
          ],
        );
        break;
      case _AgreeState.idle:
        btnContent = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 20, color: context.palette.onPrimary),
            const SizedBox(width: 8),
            Text('Saya Mengerti & Setuju',
                style: AppText.subtitle(context,
                    color: context.palette.onPrimary)),
          ],
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: context.palette.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpace.radiusCard),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpace.radiusCard),
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
                        color: _consent ? context.palette.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _consent ? context.palette.primary : context.palette.border,
                          width: 2,
                        ),
                      ),
                      child: _consent
                          ? Icon(Icons.check,
                              size: 18, color: context.palette.onPrimary)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Konfirmasi Pemahaman',
                            style: AppText.subtitle(context)),
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
            color: saved ? context.palette.accent : context.palette.primary,
            borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
              onTap: enabled ? _handleAgree : null,
              child: SizedBox(height: 56, child: btnContent),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: context.palette.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            onTap: busy ? null : () => Navigator.maybePop(context),
            child: SizedBox(
              height: 48,
              child: Center(
                child: Text('Kembali ke Pengaturan Akun',
                    style: AppText.bodySm(context, color: context.palette.title)
                        .copyWith(fontWeight: FontWeight.w700)),
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
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        boxShadow: shadow ? [BoxShadow(color: context.palette.shadow, blurRadius: 3, offset: const Offset(0, 1))] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: context.palette.surfaceAlt,
            alignment: Alignment.center,
            child: Icon(Icons.image_outlined, size: 24, color: context.palette.icon),
          ),
        ),
      ),
    );
  }
}
