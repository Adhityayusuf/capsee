// lupa_sandi_screen.dart
//
// Layar "Lupa Kata Sandi" Capsee (form email -> status tautan terkirim).
// Memakai `context.palette` agar kontras di mode terang & gelap.
// Dependensi: google_fonts.
//
// Pemakaian:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => LupaSandiScreen(
//       onSubmit: (email) async { /* panggil API kirim tautan reset */ },
//     ),
//   ));

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_theme.dart';
import '../../core/validators.dart';

TextStyle _ts(double size, double height, FontWeight w, Color color,
        {double? letterSpacing}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: height / size,
      fontWeight: w,
      color: color,
      letterSpacing: letterSpacing,
    );

List<BoxShadow> _softShadowOf(AppPalette p) => [
      BoxShadow(color: p.shadow, blurRadius: 3, offset: const Offset(0, 1)),
    ];

class LupaSandiScreen extends StatefulWidget {
  /// Dipanggil saat tautan reset diminta (juga saat "Kirim Ulang").
  /// Lempar exception untuk menampilkan pesan gagal.
  final Future<void> Function(String email)? onSubmit;

  const LupaSandiScreen({super.key, this.onSubmit});

  @override
  State<LupaSandiScreen> createState() => _LupaSandiScreenState();
}

class _LupaSandiScreenState extends State<LupaSandiScreen> {
  static const int _resendSeconds = 30;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _loading = false;
  bool _sent = false;
  String _sentEmail = '';

  int _countdown = 0;
  Timer? _timer;

  bool get _emailValid => isValidEmail(_emailCtrl.text);

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final email = _emailCtrl.text.trim();
    setState(() => _loading = true);
    try {
      await (widget.onSubmit?.call(email) ??
          Future<void>.delayed(const Duration(milliseconds: 700)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim tautan. Coba lagi.')),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
      _sentEmail = email;
    });
  }

  Future<void> _resend() async {
    if (_countdown > 0) return;
    setState(() => _countdown = _resendSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _countdown -= 1);
      if (_countdown <= 0) t.cancel();
    });
    try {
      await widget.onSubmit?.call(_sentEmail);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim ulang tautan.')),
      );
    }
  }

  void _back() => Navigator.maybePop(context);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topCenter,
                      children: [...previous, ?current],
                    ),
                    child: _sent
                        ? KeyedSubtree(
                            key: const ValueKey('sent'),
                            child: _buildSent(),
                          )
                        : KeyedSubtree(
                            key: const ValueKey('form'),
                            child: _buildFormView(),
                          ),
                  ),
                  const SizedBox(height: 32),
                  _buildSupportCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── AppBar ─────────
  PreferredSizeWidget _buildAppBar() {
    final p = context.palette;
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: p.surface.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
                color: p.shadow, blurRadius: 8, offset: const Offset(0, 1)),
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
                    onPressed: _back,
                    icon: Icon(Icons.arrow_back,
                        size: 24, color: p.title),
                    style: IconButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        shape: const CircleBorder()),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Lupa Kata Sandi',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: _ts(18, 24, FontWeight.w600, p.title,
                            letterSpacing: -0.2),
                      ),
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

  // ───────── Tampilan form ─────────
  Widget _buildFormView() {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _buildHeader(),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEmailField(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _loading ? null : _back,
                icon: Icon(Icons.arrow_back,
                    size: 18, color: p.subtitle),
                label: Text('Kembali ke Halaman Masuk',
                    style: _ts(14, 20, FontWeight.w600, p.subtitle)),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final p = context.palette;
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          width: 84,
          height: 84,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _softShadowOf(p),
                  ),
                  child: Icon(Icons.lock_reset, size: 36, color: p.accent),
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: p.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: p.shadow,
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.eco, size: 16, color: p.onPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Atur Ulang Kata Sandi',
            textAlign: TextAlign.center,
            style: _ts(22, 28, FontWeight.w700, p.title,
                letterSpacing: -0.2)),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            'Masukkan alamat email yang terdaftar pada akun Capsee Anda. Kami akan mengirimkan tautan verifikasi pemulihan.',
            textAlign: TextAlign.center,
            style: _ts(14, 22, FontWeight.w400, p.subtitle),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    final p = context.palette;
    OutlineInputBorder border([Color? color]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: color == null
              ? BorderSide.none
              : BorderSide(color: color, width: 1.5),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Email Terdaftar',
                style: _ts(12, 16, FontWeight.w600, p.subtitle)),
            const SizedBox(width: 4),
            Text('*', style: _ts(14, 14, FontWeight.w400, p.error)),
          ],
        ),
        const SizedBox(height: 4),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _softShadowOf(p),
          ),
          child: TextFormField(
            controller: _emailCtrl,
            enabled: !_loading,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (_) => _submit(),
            style: _ts(16, 24, FontWeight.w400, p.title),
            cursorColor: p.primary,
            validator: validateEmail,
            decoration: InputDecoration(
              hintText: 'petani@capsee.id',
              hintStyle: _ts(16, 24, FontWeight.w400, p.hint),
              filled: true,
              fillColor: p.surfaceAlt,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(Icons.mail_outline, size: 22, color: p.icon),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: _emailValid
                  ? Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(Icons.check_circle,
                          size: 20, color: p.accent),
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              border: border(),
              enabledBorder: border(),
              disabledBorder: border(),
              focusedBorder: border(p.primary),
              errorBorder: border(p.error),
              focusedErrorBorder: border(p.error),
              errorStyle: _ts(12, 16, FontWeight.w400, p.error),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8, left: 4, right: 4),
          child: _HelperLine(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final p = context.palette;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: _loading ? 0.8 : 1,
      child: Material(
        color: p.primary,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _loading ? null : _submit,
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _loading
                  ? [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: p.onPrimary),
                      ),
                      const SizedBox(width: 8),
                      Text('Memproses...',
                          style: _ts(18, 24, FontWeight.w600, p.onPrimary)),
                    ]
                  : [
                      Text('Kirim Link Reset',
                          style: _ts(18, 24, FontWeight.w600, p.onPrimary)),
                      const SizedBox(width: 8),
                      Icon(Icons.send, size: 20, color: p.onPrimary),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────── Tampilan terkirim ─────────
  Widget _buildSent() {
    final p = context.palette;
    final waiting = _countdown > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: p.accentSoft,
              shape: BoxShape.circle,
              boxShadow: _softShadowOf(p),
            ),
            child: Icon(Icons.mark_email_read_outlined,
                size: 32, color: p.onAccentSoft),
          ),
        ),
        const SizedBox(height: 16),
        Text('Tautan Berhasil Dikirim!',
            textAlign: TextAlign.center,
            style: _ts(18, 24, FontWeight.w600, p.title)),
        const SizedBox(height: 4),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text.rich(
              TextSpan(
                style: _ts(14, 22, FontWeight.w400, p.subtitle),
                children: [
                  const TextSpan(text: 'Tautan telah dikirim ke '),
                  TextSpan(
                    text: _sentEmail,
                    style: _ts(14, 22, FontWeight.w600, p.title),
                  ),
                  const TextSpan(
                      text: '. Buka email Anda untuk mengatur sandi baru.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 24),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: waiting ? 0.7 : 1,
          child: Material(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: waiting ? null : _resend,
              child: SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.replay, size: 18, color: p.title),
                    const SizedBox(width: 4),
                    Text(
                      waiting
                          ? 'Kirim Ulang ($_countdown' 's)'
                          : 'Kirim Ulang Tautan',
                      style: _ts(14, 20, FontWeight.w600, p.title),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: p.primary,
          borderRadius: BorderRadius.circular(12),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _back,
            child: SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Kembali Masuk',
                      style: _ts(18, 24, FontWeight.w600, p.onPrimary)),
                  const SizedBox(width: 4),
                  Icon(Icons.login, size: 18, color: p.onPrimary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────── Kartu bantuan ─────────
  Widget _buildSupportCard() {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _softShadowOf(p),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.support_agent, size: 20, color: p.accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bantuan Akun Lapangan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ts(14, 20, FontWeight.w600, p.title)),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    style: _ts(12, 19, FontWeight.w400, p.subtitle),
                    children: [
                      const TextSpan(
                          text:
                              'Belum menerima pesan dalam 2 menit? Periksa folder spam atau hubungi penyuluh pertanian digital Capsee di '),
                      TextSpan(
                        text: '0800-1-CAPSEE',
                        style: _ts(12, 19, FontWeight.w600, p.accent),
                      ),
                      const TextSpan(text: '.'),
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
}

class _HelperLine extends StatelessWidget {
  const _HelperLine();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.verified_user_outlined, size: 15, color: p.accent),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Pastikan email aktif dan dapat menerima pesan inbox.',
            style: _ts(12, 16, FontWeight.w400, p.subtitle),
          ),
        ),
      ],
    );
  }
}
