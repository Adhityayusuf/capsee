import 'package:flutter/material.dart';

import '../core/app_info.dart';
import '../core/app_text.dart';
import '../core/app_theme.dart';
import 'ui_kit.dart';

/// ---------------------------------------------------------------
/// Kerangka halaman auth: background terang + scroll + center.
/// ---------------------------------------------------------------
class AuthScaffold extends StatelessWidget {
  final Widget child;
  const AuthScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpace.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// Bar atas halaman auth: tombol back opsional + nama aplikasi di tengah.
/// ---------------------------------------------------------------
class AuthTopBar extends StatelessWidget {
  final bool showBack;
  const AuthTopBar({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showBack)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: p.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.border),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: p.title,
                  ),
                ),
              ),
            ),
          Text(
            AppInfo.name,
            style: AppText.display(context, color: p.accent),
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
  final bool onPrimary;
  const CapseeLogo({super.key, this.size = 88, this.onPrimary = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final scale = size / 88;
    if (onPrimary) {
      return Icon(
        Icons.eco_rounded,
        size: size * 0.75,
        color: p.onPrimary,
      );
    }
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: p.accentSoft,
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Icon(
          Icons.eco_rounded,
          size: 40 * scale,
          color: p.onAccentSoft,
        ),
      ),
    );
  }
}

/// Kartu putih tempat form berada.
class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CapseeCard(child: child);
  }
}

/// Judul halaman auth.
class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const AuthHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppText.display(context),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: AppText.body(context),
          ),
        ],
      ],
    );
  }
}

/// Label kecil di atas field.
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(
      text,
      style: AppText.subtitle(context).copyWith(color: p.subtitle),
    );
  }
}

/// Tombol hijau utama (full-width, sudut membulat).
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool iconAtEnd;
  final bool isLoading;
  final double radius;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.radius = 26,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.primary.withValues(alpha: 0.6),
          disabledForegroundColor: p.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: p.onPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null && !iconAtEnd) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: AppText.subtitle(context)
                          .copyWith(color: p.onPrimary),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (icon != null && iconAtEnd) ...[
                    const SizedBox(width: 10),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Tombol sosial bulat (UI-only).
class SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  const SocialButton({super.key, required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.surface,
          shape: BoxShape.circle,
          border: Border.all(color: p.border),
          boxShadow: [
            BoxShadow(
              color: p.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Ikon Google sederhana (UI-only) untuk tombol sosial.
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key, this.size = 22});

  final double size;
  @override
  Widget build(BuildContext context) {
    return Text(
      'G',
      style: AppText.title(context).copyWith(
        fontSize: size,
        color: const Color(0xFF4285F4),
      ),
    );
  }
}

/// Teks pemisah "Atau masuk dengan".
class OrDivider extends StatelessWidget {
  final String text;
  const OrDivider(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppText.body(context, color: p.hint),
    );
  }
}

/// Dekorasi input: field abu-abu terisi, tanpa border tebal.
InputDecoration capseeInputDecoration(
  BuildContext context, {
  String? hint,
  IconData? prefixIcon,
  Widget? suffix,
}) {
  final p = context.palette;
  OutlineInputBorder border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: AppText.body(context, color: p.hint),
    prefixIcon:
        prefixIcon != null ? Icon(prefixIcon, color: p.icon) : null,
    suffixIcon: suffix,
    filled: true,
    fillColor: p.surfaceAlt,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    enabledBorder: border(const Color(0x00000000)),
    focusedBorder: border(p.primary, width: 1.5),
    errorBorder: border(p.error),
    focusedErrorBorder: border(p.error, width: 1.5),
  );
}
