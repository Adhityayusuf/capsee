import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';

/// ---------------------------------------------------------------
/// Kerangka halaman auth: background + cahaya hijau + scroll + center
/// ---------------------------------------------------------------
class AuthScaffold extends StatelessWidget {
  final Widget child;
  const AuthScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Cahaya hijau lembut di bagian atas
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Container(
              height: 340,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.6,
                  colors: [AppColors.glow, Color(0x00F7F7FF)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// Logo aplikasi.
/// Ganti Icon dengan Image.asset('assets/images/logo.png') jika sudah
/// punya file logo cabai (daftarkan di pubspec.yaml).
/// ---------------------------------------------------------------
class CapseeLogo extends StatelessWidget {
  final double size;
  const CapseeLogo({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) {
    final scale = size / 88;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryShadow,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Icon(
          Icons.eco_rounded,
          size: 40 * scale,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Judul + subjudul di bawah logo.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            height: 1.4,
            color: AppColors.subtitle,
          ),
        ),
      ],
    );
  }
}

/// Kartu putih tempat form berada.
class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Label di atas field ("Email", "Kata Sandi", dst).
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.title,
      ),
    );
  }
}

/// Tombol hijau utama.
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool iconAtEnd;
  final bool isLoading;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconAtEnd = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
    final iconWidget = Icon(icon, size: 20);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryDisabled,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: iconAtEnd
                    ? [text, const SizedBox(width: 10), iconWidget]
                    : [iconWidget, const SizedBox(width: 10), text],
              ),
      ),
    );
  }
}

/// Chip kecil berlatar lavender di bagian bawah (status / info keamanan).
class InfoChip extends StatelessWidget {
  final Widget leading;
  final String text;
  final double radius;

  const InfoChip({
    super.key,
    required this.leading,
    required this.text,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leading,
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dekorasi input yang dipakai ulang di semua TextFormField.
InputDecoration capseeInputDecoration({
  required String hint,
  IconData? prefixIcon,
  Widget? prefix,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      color: AppColors.hint,
    ),
    prefixIcon: prefix ??
        (prefixIcon != null ? Icon(prefixIcon, color: AppColors.icon) : null),
    prefixIconConstraints: prefix != null
        ? const BoxConstraints(minWidth: 0, minHeight: 0)
        : null,
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    enabledBorder: border(AppColors.border),
    focusedBorder: border(AppColors.primary),
    errorBorder: border(AppColors.error),
    focusedErrorBorder: border(AppColors.error),
  );
}