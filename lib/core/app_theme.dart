import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ---------------------------------------------------------------
/// Palet warna Capsee untuk mode terang & gelap.
///
/// Ambil lewat `context.palette` (lihat extension di bawah) supaya
/// warnanya otomatis menyesuaikan tema yang sedang aktif.
/// ---------------------------------------------------------------
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background; // latar halaman
  final Color surface; // kartu / panel / app bar
  final Color surfaceAlt; // kotak di dalam kartu (chip, tile, input)
  final Color border;
  final Color title; // teks utama
  final Color subtitle; // teks sekunder
  final Color hint;
  final Color icon;
  final Color primary; // isi tombol utama
  final Color onPrimary; // teks/ikon di atas primary
  final Color accent; // teks, link, dan ikon hijau
  final Color accentSoft; // latar badge hijau
  final Color onAccentSoft; // teks di atas accentSoft
  final Color error;
  final Color shadow;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.icon,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.accentSoft,
    required this.onAccentSoft,
    required this.error,
    required this.shadow,
  });

  static const light = AppPalette(
    background: Color(0xFFF7F7FF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F2FC),
    border: Color(0xFFE5E7EB),
    title: Color(0xFF1B2B34),
    subtitle: Color(0xFF4B5563),
    hint: Color(0xFF9CA3AF),
    icon: Color(0xFF6B7280),
    primary: Color(0xFF15803D),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF166534),
    accentSoft: Color(0xFFDCFCE7),
    onAccentSoft: Color(0xFF166534),
    error: Color(0xFFDC2626),
    shadow: Color(0x0A000000),
  );

  static const dark = AppPalette(
    background: Color(0xFF0E1511),
    surface: Color(0xFF17211B),
    surfaceAlt: Color(0xFF1F2B24),
    border: Color(0xFF2B3A32),
    title: Color(0xFFEAF3EE),
    subtitle: Color(0xFFA9BBB1),
    hint: Color(0xFF70847A),
    icon: Color(0xFF9BB0A5),
    primary: Color(0xFF15803D),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF4ADE80),
    accentSoft: Color(0xFF173A28),
    onAccentSoft: Color(0xFF86EFAC),
    error: Color(0xFFF87171),
    shadow: Color(0x66000000),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? title,
    Color? subtitle,
    Color? hint,
    Color? icon,
    Color? primary,
    Color? onPrimary,
    Color? accent,
    Color? accentSoft,
    Color? onAccentSoft,
    Color? error,
    Color? shadow,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      hint: hint ?? this.hint,
      icon: icon ?? this.icon,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      onAccentSoft: onAccentSoft ?? this.onAccentSoft,
      error: error ?? this.error,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      border: l(border, other.border),
      title: l(title, other.title),
      subtitle: l(subtitle, other.subtitle),
      hint: l(hint, other.hint),
      icon: l(icon, other.icon),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      onAccentSoft: l(onAccentSoft, other.onAccentSoft),
      error: l(error, other.error),
      shadow: l(shadow, other.shadow),
    );
  }
}

/// Pemakaian: `context.palette.surface`, `context.palette.title`, dst.
extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

/// ---------------------------------------------------------------
/// ThemeData terang & gelap
/// ---------------------------------------------------------------
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light, AppPalette.light);
  static ThemeData dark() => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette p) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF15803D),
      brightness: brightness,
    ).copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      surface: p.surface,
      onSurface: p.title,
      onSurfaceVariant: p.subtitle,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceAlt,
      surfaceContainerHighest: p.surfaceAlt,
      outline: p.border,
      outlineVariant: p.border,
      error: p.error,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.surface, // latar menu dropdown
      iconTheme: IconThemeData(color: p.icon),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).apply(bodyColor: p.title, displayColor: p.title),
      dividerTheme: DividerThemeData(color: p.border),

      // Tombol: ini yang memperbaiki tombol "Scan" yang terlihat pucat
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.primary.withAlpha(110),
          disabledForegroundColor: p.onPrimary.withAlpha(180),
          elevation: 0,
          shape: shape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.primary.withAlpha(110),
          disabledForegroundColor: p.onPrimary.withAlpha(180),
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.title,
          side: BorderSide(color: p.border),
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.accent),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(p.onPrimary),
        side: BorderSide(color: p.hint, width: 1.5),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.accentSoft,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? p.accent : p.icon,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? p.accent : p.icon,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: p.accent,
        unselectedItemColor: p.icon,
      ),

      extensions: [p],
    );
  }
}