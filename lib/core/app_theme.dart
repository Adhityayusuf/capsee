/// ---------------------------------------------------------------
/// ThemeData terang & gelap
/// ---------------------------------------------------------------
class AppTheme {
  AppTheme._();

  static ThemeData light({double fontScale = 1.0}) =>
      _build(Brightness.light, AppPalette.light, fontScale);

  static ThemeData dark({double fontScale = 1.0}) =>
      _build(Brightness.dark, AppPalette.dark, fontScale);

  static ThemeData _build(
    Brightness brightness,
    AppPalette p,
    double fontScale,
  ) {
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

    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(useMaterial3: true, brightness: brightness).textTheme,
    ).apply(
      bodyColor: p.title,
      displayColor: p.title,
      fontSizeFactor: fontScale,
    );

    final buttonTextStyle = GoogleFonts.plusJakartaSans(
      fontSize: 14 * fontScale,
      fontWeight: FontWeight.w600,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.surface, // latar menu dropdown
      iconTheme: IconThemeData(color: p.icon),
      textTheme: baseTextTheme,
      dividerTheme: DividerThemeData(color: p.border),

      // Tombol: ukuran teks ikut skala font global
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.primary.withAlpha(110),
          disabledForegroundColor: p.onPrimary.withAlpha(180),
          textStyle: buttonTextStyle,
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
          textStyle: buttonTextStyle,
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.title,
          side: BorderSide(color: p.border),
          textStyle: buttonTextStyle,
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: buttonTextStyle,
        ),
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
          (states) => GoogleFonts.plusJakartaSans(
            fontSize: 12 * fontScale,
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
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12 * fontScale,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12 * fontScale,
          fontWeight: FontWeight.w500,
        ),
      ),

      extensions: [p],
    );
  }
}
