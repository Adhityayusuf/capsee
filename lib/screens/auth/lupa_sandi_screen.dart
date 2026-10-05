// lupa_sandi_screen.dart
//
// Layar "Lupa Kata Sandi" Capsee (form email -> status tautan terkirim).
// Memakai class warna `C` dari notifikasi_screen.dart (satu folder di lib/).
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

import '../core/app_colors.dart';
import 'notifikasi_screen.dart' show C;

const _onSecondaryContainer = AppColors.onSecondaryContainer;
const _secondaryContainer = AppColors.secondaryContainer;

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

final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

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

  bool get _emailValid => _emailRegex.hasMatch(_emailCtrl.text.trim());

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
    return Scaffold(
      backgroundColor: C.surface,
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
                      children: [...previous, if (current != null) current],
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
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: C.surface.withOpacity(0.95),
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
                    onPressed: _back,
                    icon: const Icon(Icons.arrow_back,
                        size: 24, color: C.onSurface),
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
                        style: _ts(18, 24, FontWeight.w600, C.onSurface,
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
                icon: const Icon(Icons.arrow_back,
                    size: 18, color: C.onSurfaceVariant),
                label: Text('Kembali ke Halaman Masuk',
                    style: _ts(14, 20, FontWeight.w600, C.onSurfaceVariant)),
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
                    color: C.surfaceHigh,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _softShadow,
                  ),
                  child:
                      const Icon(Icons.lock_reset, size: 36, color: C.primary),
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: C.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 4,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.eco, size: 16, color: C.onPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Atur Ulang Kata Sandi',
            textAlign: TextAlign.center,
            style: _ts(22, 28, FontWeight.w700, C.onSurface,
                letterSpacing: -0.2)),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            'Masukkan alamat email yang terdaftar pada akun Capsee Anda. Kami akan mengirimkan tautan verifikasi pemulihan.',
            textAlign: TextAlign.center,
            style: _ts(14, 22, FontWeight.w400, C.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
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
                style: _ts(12, 16, FontWeight.w600, C.onSurfaceVariant)),
            const SizedBox(width: 4),
            Text('*', style: _ts(14, 14, FontWeight.w400, C.error)),
          ],
        ),
        const SizedBox(height: 4),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _softShadow,
          ),
          child: TextFormField(
            controller: _emailCtrl,
            enabled: !_loading,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (_) => _submit(),
            style: _ts(16, 24, FontWeight.w400, C.onSurface),
            cursorColor: C.primary,
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return 'Email wajib diisi';
              if (!_emailRegex.hasMatch(value)) {
                return 'Format email tidak valid';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'petani@capsee.id',
              hintStyle: _ts(16, 24, FontWeight.w400,
                  C.onSurfaceVariant.withOpacity(0.5)),
              filled: true,
              fillColor: C.surfaceLowest,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 16, right: 12),
                child:
                    Icon(Icons.mail_outline, size: 22, color: C.onSurfaceVariant),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: _emailValid
                  ? const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child:
                          Icon(Icons.check_circle, size: 20, color: C.primary),
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              border: border(),
              enabledBorder: border(),
              disabledBorder: border(),
              focusedBorder: border(C.primary),
              errorBorder: border(C.error),
              focusedErrorBorder: border(C.error),
              errorStyle: _ts(12, 16, FontWeight.w400, C.error),
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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: _loading ? 0.8 : 1,
      child: Material(
        color: C.primary,
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
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: C.onPrimary),
                      ),
                      const SizedBox(width: 8),
                      Text('Memproses...',
                          style: _ts(18, 24, FontWeight.w600, C.onPrimary)),
                    ]
                  : [
                      Text('Kirim Link Reset',
                          style: _ts(18, 24, FontWeight.w600, C.onPrimary)),
                      const SizedBox(width: 8),
                      const Icon(Icons.send, size: 20, color: C.onPrimary),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────── Tampilan terkirim ─────────
  Widget _buildSent() {
    final waiting = _countdown > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _secondaryContainer,
              shape: BoxShape.circle,
              boxShadow: _softShadow,
            ),
            child: const Icon(Icons.mark_email_read_outlined,
                size: 32, color: _onSecondaryContainer),
          ),
        ),
        const SizedBox(height: 16),
        Text('Tautan Berhasil Dikirim!',
            textAlign: TextAlign.center,
            style: _ts(18, 24, FontWeight.w600, C.onSurface)),
        const SizedBox(height: 4),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text.rich(
              TextSpan(
                style: _ts(14, 22, FontWeight.w400, C.onSurfaceVariant),
                children: [
                  const TextSpan(text: 'Tautan telah dikirim ke '),
                  TextSpan(
                    text: _sentEmail,
                    style: _ts(14, 22, FontWeight.w600, C.onSurface),
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
            color: C.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: waiting ? null : _resend,
              child: SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.replay, size: 18, color: C.onSurface),
                    const SizedBox(width: 4),
                    Text(
                      waiting
                          ? 'Kirim Ulang ($_countdown' 's)'
                          : 'Kirim Ulang Tautan',
                      style: _ts(14, 20, FontWeight.w600, C.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: C.primary,
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
                      style: _ts(18, 24, FontWeight.w600, C.onPrimary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.login, size: 18, color: C.onPrimary),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: C.surfaceHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.support_agent, size: 20, color: C.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bantuan Akun Lapangan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ts(14, 20, FontWeight.w600, C.onSurface)),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    style: _ts(12, 19, FontWeight.w400, C.onSurfaceVariant),
                    children: [
                      const TextSpan(
                          text:
                              'Belum menerima pesan dalam 2 menit? Periksa folder spam atau hubungi penyuluh pertanian digital Capsee di '),
                      TextSpan(
                        text: '0800-1-CAPSEE',
                        style: _ts(12, 19, FontWeight.w600, C.primary),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.verified_user_outlined, size: 15, color: C.primary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Pastikan email aktif dan dapat menerima pesan inbox.',
            style: _ts(12, 16, FontWeight.w400, C.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
