import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';
import 'syarat_screen.dart';
import 'privasi_screen.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
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
    _phoneController.dispose();
    _passwordController.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    setState(() => _showTermsError = !_agreed);
    if (!valid || !_agreed) return;

    setState(() => _isLoading = true);

    // TODO: ganti dengan pemanggilan API register sebenarnya
    // Nomor lengkap: '+62${_phoneController.text}'
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Akun berhasil dibuat, silakan masuk')),
    );

    // Setelah daftar, arahkan ke halaman login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          const CapseeLogo(),
          const SizedBox(height: 16),
          _buildBadge(),
          const SizedBox(height: 14),
          const AuthHeader(
            title: 'Daftar Akun Capsee',
            subtitle: 'Mulai pantau & lindungi kebun cabai Anda dengan presisi AI',
          ),
          const SizedBox(height: 24),
          _buildFormCard(),
          const SizedBox(height: 24),
          _buildLoginRow(),
          const SizedBox(height: 20),
          const InfoChip(
            radius: 30,
            leading: Icon(
              Icons.verified_user_rounded,
              size: 16,
              color: AppColors.primaryDark,
            ),
            text: 'Sistem Pertanian Presisi • Data Aman & Terenkripsi',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Badge "AGRI-TECH INTELLIGENCE"
  // ---------------------------------------------------------------
  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_rounded, size: 14, color: AppColors.primaryDark),
          const SizedBox(width: 6),
          Text(
            'AGRI-TECH INTELLIGENCE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Kartu form
  // ---------------------------------------------------------------
  Widget _buildFormCard() {
    return AuthCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Nama lengkap ----------
            const FieldLabel('Nama Lengkap'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: capseeInputDecoration(
                hint: 'Nama lengkap Anda',
                prefixIcon: Icons.person_outline_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama lengkap wajib diisi';
                }
                if (value.trim().length < 3) {
                  return 'Nama terlalu pendek';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // ---------- Email aktif ----------
            const FieldLabel('Email Aktif'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: capseeInputDecoration(
                hint: 'nama@email.com',
                prefixIcon: Icons.mail_outline_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email wajib diisi';
                }
                final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!regex.hasMatch(value.trim())) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // ---------- Nomor WhatsApp / HP ----------
            const FieldLabel('Nomor WhatsApp / HP'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: capseeInputDecoration(
                hint: '812 3456 7890',
                prefix: _buildPhonePrefix(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nomor WhatsApp / HP wajib diisi';
                }
                if (value.startsWith('0')) {
                  return 'Tulis tanpa angka 0 di depan';
                }
                if (value.length < 9 || value.length > 13) {
                  return 'Nomor tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // ---------- Kata sandi ----------
            const FieldLabel('Kata Sandi'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              decoration: capseeInputDecoration(
                hint: 'Minimal 8 karakter',
                prefixIcon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.icon,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kata sandi wajib diisi';
                }
                if (value.length < 8) {
                  return 'Minimal 8 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ---------- Persetujuan ----------
            _buildTermsRow(),
            const SizedBox(height: 22),

            // ---------- Tombol daftar ----------
            PrimaryButton(
              label: 'Daftar Sekarang',
              icon: Icons.arrow_forward_rounded,
              iconAtEnd: true,
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  // Prefix: [ikon telepon] +62 |
  Widget _buildPhonePrefix() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.phone_outlined, size: 22, color: AppColors.icon),
          const SizedBox(width: 8),
          Text(
            '+62',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.title,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 22, color: AppColors.border),
        ],
      ),
    );
  }

  // Checkbox custom + teks Syarat & Ketentuan
  Widget _buildTermsRow() {
    final baseStyle = GoogleFonts.plusJakartaSans(
      fontSize: 14,
      height: 1.4,
      color: AppColors.title,
    );
    final linkStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w800,
      color: AppColors.primaryDark,
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
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _agreed ? AppColors.primaryDark : AppColors.chipBg,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: _showTermsError
                        ? AppColors.error
                        : (_agreed ? AppColors.primaryDark : AppColors.border),
                  ),
                ),
                child: _agreed
                    ? const Icon(Icons.check_rounded,
                        size: 18, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
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
            padding: const EdgeInsets.only(top: 6, left: 38),
            child: Text(
              'Anda harus menyetujui syarat & ketentuan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // "Sudah punya akun? Masuk"
  // ---------------------------------------------------------------
  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: AppColors.title,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          child: Text(
            'Masuk',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}