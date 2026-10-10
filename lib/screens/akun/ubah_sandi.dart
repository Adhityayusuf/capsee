import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../services/services.dart';
import '../../widgets/popup_notifikasi.dart';
import '../../widgets/ui_kit.dart';
import '../auth/lupa_sandi_screen.dart';

class UbahKataSandiScreen extends StatefulWidget {
  const UbahKataSandiScreen({super.key});

  @override
  State<UbahKataSandiScreen> createState() => _UbahKataSandiScreenState();
}

class _UbahKataSandiScreenState extends State<UbahKataSandiScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPwdController = TextEditingController();
  final TextEditingController _newPwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  // Password Strength State
  String _pwdStrengthText = 'Lemah';
  int _strengthLevel = 0; // 0: Lemah, 1: Sedang, 2: Kuat, 3: Sangat Kuat
  bool _hasMinLength = false;
  bool _hasMixedCase = false;
  bool _hasSymbolOrNumber = false;

  @override
  void initState() {
    super.initState();
    _newPwdController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _currentPwdController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final pwd = _newPwdController.text;

    setState(() {
      _hasMinLength = pwd.length >= 8;
      _hasMixedCase = pwd.contains(RegExp(r'[A-Z]')) && pwd.contains(RegExp(r'[a-z]'));
      _hasSymbolOrNumber = pwd.contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'));

      int score = 0;
      if (pwd.length >= 6) score++;
      if (_hasMinLength) score++;
      if (_hasMixedCase) score++;
      if (_hasSymbolOrNumber) score++;

      if (score >= 4) {
        _strengthLevel = 3;
        _pwdStrengthText = 'Sangat Kuat';
      } else if (score >= 3) {
        _strengthLevel = 2;
        _pwdStrengthText = 'Kuat';
      } else if (score >= 2) {
        _strengthLevel = 1;
        _pwdStrengthText = 'Sedang';
      } else {
        _strengthLevel = 0;
        _pwdStrengthText = 'Lemah';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AppBar(
              backgroundColor: p.surface.withValues(alpha: 0.85),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: p.title),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Ubah Kata Sandi',
                style: AppText.headline(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.close, color: p.title),
                  onPressed: () => Navigator.pop(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: p.primary,
                    child: Icon(Icons.person, color: p.onPrimary, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.page, AppSpace.page, AppSpace.page, AppSpace.page),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                CapseeCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: p.accentSoft,
                          borderRadius:
                              BorderRadius.circular(AppSpace.radiusTile),
                        ),
                        child: Icon(Icons.lock_person,
                            color: p.onAccentSoft, size: 24),
                      ),
                      const SizedBox(width: AppSpace.gapMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Perbarui Kata Sandi\nAkun',
                                    style: AppText.headline(context),
                                  ),
                                ),
                                const StatusBadge(
                                  label: 'Aman',
                                  kind: BadgeKind.success,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pastikan kata sandi baru Anda kuat, unik, dan terdiri dari minimal 8 karakter demi keamanan data lahan Anda.',
                              style: AppText.body(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Current Password Field
                _buildLabel('Kata Sandi Saat Ini', isRequired: true),
                _buildPasswordField(
                  controller: _currentPwdController,
                  hintText: 'Masukkan kata sandi lama',
                  prefixIcon: Icons.lock_outline,
                  isObscure: _obscureCurrent,
                  onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LupaSandiScreen(
                            onSubmit: (_) async {},
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Lupa kata sandi saat ini?',
                      style: AppText.bodySm(context, color: p.accent)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // New Password Field
                _buildLabel('Kata Sandi Baru', isRequired: true),
                _buildPasswordField(
                  controller: _newPwdController,
                  hintText: 'Buat kata sandi baru',
                  prefixIcon: Icons.vpn_key_outlined,
                  isObscure: _obscureNew,
                  onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 12),

                // Password Strength Meter
                CapseeCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kekuatan Kata Sandi',
                            style: AppText.caption(context),
                          ),
                          Text(
                            _pwdStrengthText,
                            style: AppText.caption(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: _strengthLevel >= 2
                                  ? p.accent
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStrengthBar(1),
                          const SizedBox(width: 4),
                          _buildStrengthBar(2),
                          const SizedBox(width: 4),
                          _buildStrengthBar(3),
                          const SizedBox(width: 4),
                          _buildStrengthBar(4), // Or just 3 bars based on the image
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Rules checklist
                _buildRuleItem('Minimal 8 karakter', _hasMinLength),
                _buildRuleItem('Kombinasi huruf besar & kecil', _hasMixedCase),
                _buildRuleItem('Mengandung angka atau simbol khusus (!@#\$)', _hasSymbolOrNumber),
                const SizedBox(height: 24),

                // Confirm Password Field
                _buildLabel('Konfirmasi Kata Sandi Baru', isRequired: true),
                _buildPasswordField(
                  controller: _confirmPwdController,
                  hintText: 'Ulangi kata sandi baru',
                  prefixIcon: Icons.lock_reset_outlined,
                  isObscure: _obscureConfirm,
                  onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    'Ketik ulang kata sandi baru untuk memastikan kesesuaian.',
                    style: AppText.caption(context),
                  ),
                ),
                const SizedBox(height: 24),

                // Auto Protection Info
                CapseeCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.verified_user, color: p.accent, size: 24),
                      const SizedBox(width: AppSpace.gapMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Perlindungan Akun Otomatis',
                              style: AppText.subtitle(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Demi keamanan akun Capsee Anda, setelah mengganti kata sandi, sesi aktif di perangkat lain akan tetap aman atau dapat ditinjau ulang pada menu Sesi Masuk.',
                              style: AppText.bodySm(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _simpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.primary,
                      foregroundColor: p.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSpace.radiusTile)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isSaving)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: p.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Icon(Icons.check_circle_outline, color: p.onPrimary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          _isSaving ? 'Menyimpan…' : 'Simpan Kata Sandi',
                          style: AppText.subtitle(context, color: p.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: p.surfaceAlt,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSpace.radiusTile)),
                    ),
                    child: Text(
                      'Batal',
                      style: AppText.subtitle(context),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Footer Logo
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco_outlined, color: p.hint, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'CAPSEE AGRO SECURITY\nSTANDARD',
                        textAlign: TextAlign.center,
                        style: AppText.overline(context, color: p.icon)
                            .copyWith(height: 1.2),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _simpan() async {
    if (_currentPwdController.text.isEmpty ||
        _newPwdController.text.length < 8) {
      showErrorPopup(
        context,
        'Isi sandi lama dan sandi baru (min. 8 karakter).',
      );
      return;
    }
    if (_newPwdController.text != _confirmPwdController.text) {
      showErrorPopup(context, 'Konfirmasi sandi baru tidak cocok.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await gantiSandi(
        sandiLama: _currentPwdController.text,
        sandiBaru: _newPwdController.text,
      );
      if (!mounted) return;
      showSuccessPopup(context, 'Kata sandi berhasil diperbarui.');
      Navigator.maybePop(context);
    } catch (e) {
      if (!mounted) return;
      showErrorPopup(context, 'Gagal menyimpan: ${pesanError(e)}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            text,
            style: AppText.bodySm(context, color: p.subtitle)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          if (isRequired)
            Text(' *',
                style: AppText.bodySm(context, color: p.error)
                    .copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required bool isObscure,
    required VoidCallback onToggleObscure,
  }) {
    final p = context.palette;
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        border: Border.all(color: p.border),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        style: AppText.body(context, color: p.title),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppText.body(context, color: p.subtitle),
          prefixIcon: Icon(prefixIcon, color: p.subtitle, size: 22),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: p.subtitle,
              size: 22,
            ),
            onPressed: onToggleObscure,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildStrengthBar(int index) {
    final p = context.palette;
    Color barColor;
    if (index <= _strengthLevel) {
       // Green if filled
       barColor = p.primary;
    } else {
       // Light grey/blue if unfilled
       barColor = p.border;
    }

    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text, bool isMet) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? p.accent : p.hint,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppText.bodySm(
                context, color: isMet ? p.title : p.subtitle),
          ),
        ],
      ),
    );
  }
}
