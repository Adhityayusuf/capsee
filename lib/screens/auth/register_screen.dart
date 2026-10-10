import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../core/validators.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/popup_notifikasi.dart';
import '../../services/services.dart';
import '../legal/privasi_screen.dart';
import '../legal/syarat_screen.dart';
import '../home/dashboard_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreed = false;
  bool _showTermsError = false;
  bool _isLoading = false;

  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SyaratScreen()),
        );
      };
    _privacyTap = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrivasiScreen()),
        );
      };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    setState(() => _showTermsError = !_agreed);
    if (!valid || !_agreed) return;

    setState(() => _isLoading = true);

    try {
      final hasil = await register(
        nama: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Token sudah tersimpan oleh register() → langsung masuk aplikasi.
      if (hasil.sudahPunyaLahan) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorPopup(context, pesanError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          const AuthTopBar(showBack: true),
          const SizedBox(height: 20),
          AuthCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuthHeader(title: 'Daftar Akun Capsee'),
                  const SizedBox(height: 24),
                  const FieldLabel('Nama Lengkap'),
                  const SizedBox(height: 8),
                  _buildNameField(),
                  const SizedBox(height: 16),
                  const FieldLabel('Email'),
                  const SizedBox(height: 8),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  const FieldLabel('Kata Sandi'),
                  const SizedBox(height: 8),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  const FieldLabel('Konfirmasi Kata Sandi'),
                  const SizedBox(height: 8),
                  _buildConfirmField(),
                  const SizedBox(height: 18),
                  _buildTermsRow(),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Daftar Sekarang',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 18),
                  const OrDivider('Atau daftar dengan'),
                  const SizedBox(height: 14),
                  Center(
                    child: SocialButton(
                      onPressed: () {},
                      child: const GoogleIcon(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLoginRow(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      style: AppText.body(context, color: context.palette.title),
      decoration: capseeInputDecoration(context, hint: 'Nama lengkap Anda'),
      validator: validateName,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: AppText.body(context, color: context.palette.title),
      decoration: capseeInputDecoration(context, hint: 'nama@email.com'),
      validator: validateEmail,
    );
  }

  Widget _buildPasswordField() {
    final p = context.palette;
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      style: AppText.body(context, color: p.title),
      decoration: capseeInputDecoration(
        context,
        hint: 'Minimal 8 karakter',
        suffix: IconButton(
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: p.icon,
          ),
        ),
      ),
      validator: validatePassword,
    );
  }

  Widget _buildConfirmField() {
    final p = context.palette;
    return TextFormField(
      controller: _confirmController,
      obscureText: _obscureConfirm,
      textInputAction: TextInputAction.done,
      style: AppText.body(context, color: p.title),
      decoration: capseeInputDecoration(
        context,
        hint: 'Ulangi kata sandi',
        suffix: IconButton(
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          icon: Icon(
            _obscureConfirm
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: p.icon,
          ),
        ),
      ),
      validator: (value) =>
          validateConfirmPassword(value, _passwordController.text),
    );
  }

  Widget _buildTermsRow() {
    final p = context.palette;
    final baseStyle = AppText.body(context);
    final linkStyle = AppText.body(context).copyWith(
      fontWeight: FontWeight.w800,
      color: p.accent,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() {
                _agreed = !_agreed;
                if (_agreed) _showTermsError = false;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _agreed ? p.primary : p.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _showTermsError
                        ? p.error
                        : (_agreed ? p.primary : p.border),
                  ),
                ),
                child: _agreed
                    ? Icon(Icons.check_rounded,
                        size: 16, color: p.onPrimary)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: baseStyle,
                  children: [
                    const TextSpan(text: 'Saya menyetujui '),
                    TextSpan(
                      text: 'Syarat & Ketentuan',
                      style: linkStyle,
                      recognizer: _termsTap,
                    ),
                    const TextSpan(text: ' serta '),
                    TextSpan(
                      text: 'Kebijakan Privasi',
                      style: linkStyle,
                      recognizer: _privacyTap,
                    ),
                    const TextSpan(text: ' Capsee.'),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_showTermsError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 32),
            child: Text(
              'Anda harus menyetujui syarat & ketentuan',
              style: AppText.bodySm(context, color: p.error),
            ),
          ),
      ],
    );
  }

  Widget _buildLoginRow() {
    final p = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun?',
          style: AppText.body(context),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          child: Text(
            'Masuk',
            style: AppText.subtitle(context, color: p.accent),
          ),
        ),
      ],
    );
  }
}
