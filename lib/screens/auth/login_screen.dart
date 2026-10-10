import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../core/validators.dart';
import '../../widgets/auth_widgets.dart';
import '../../services/services.dart';
import '../home/dashboard_screen.dart';
import 'onboarding_screen.dart';
import 'register_screen.dart';
import 'lupa_sandi_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final hasil = await login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          const CapseeLogo(),
          const SizedBox(height: 24),
          const AuthHeader(
            title: 'Masuk ke Capsee',
            subtitle: 'Pantau kesehatan tanaman cabai Anda dengan presisi AI.',
          ),
          const SizedBox(height: 28),
          _buildFormCard(),
          const SizedBox(height: 28),
          _buildRegisterRow(),
          const SizedBox(height: 28),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return AuthCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Email ----------
            const FieldLabel('Email'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: capseeInputDecoration(
                hint: 'nama@email.com',
                prefixIcon: Icons.mail_outline_rounded,
              ),
              validator: validateEmail,
            ),
            const SizedBox(height: 20),

            // ---------- Kata sandi ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const FieldLabel('Kata Sandi'),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LupaSandiScreen(
                          onSubmit: (email) async {
                            // Implement API
                            await Future.delayed(const Duration(seconds: 1));
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Lupa Kata Sandi?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: capseeInputDecoration(
                hint: 'Masukkan kata sandi',
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
              validator: validatePassword,
            ),
            const SizedBox(height: 18),

            // ---------- Ingat akun ----------
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  child: Text(
                    'Ingat akun di perangkat ini',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.title,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---------- Tombol masuk ----------
            PrimaryButton(
              label: 'Masuk',
              icon: Icons.login_rounded,
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: AppColors.title,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: Text(
            'Daftar',
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

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.view_agenda_outlined, size: 18, color: AppColors.icon),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'SISTEM PERTANIAN PRESISI • TERENKRIPSI',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: AppColors.icon,
            ),
          ),
        ),
      ],
    );
  }
}
