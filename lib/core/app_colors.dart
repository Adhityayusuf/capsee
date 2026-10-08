import 'package:flutter/material.dart';

/// Warna kanonik Capsee. Ini satu-satunya sumber palette untuk seluruh aplikasi.
///
/// Layar yang dulu memakai `class C` (notifikasi) atau konstanta lokal sekarang
/// memetakan ke token di sini agar tema konsisten.
class AppColors {
  AppColors._();

  // ── Permukaan ──
  static const background = Color(0xFFF7F7FF);
  static const surface = background;
  static const surfaceLowest = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF2F3FF);
  static const surfaceContainer = Color(0xFFEAEDFF);
  static const surfaceHigh = Color(0xFFE2E7FF);
  static const surfaceHighest = Color(0xFFDAE2FD);
  static const surfaceDim = Color(0xFFD2D9F4);
  static const chipBg = Color(0xFFF1F2FC);

  // ── Primer (hijau utama) ──
  static const primary = Color(0xFF15803D);
  static const primaryDark = Color(0xFF166534);
  static const primaryContainer = Color(0xFF15803D);
  static const primarySoft = Color(0xFFDCFCE7);
  static const primaryFixed = Color(0xFF95F8A7);
  static const primaryFixedDim = Color(0xFF79DB8D);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryFixed = Color(0xFF00210A);
  static const onPrimaryContainer = Color(0xFFD3FFD5);
  static const glow = Color(0xFFBBF7D0);

  // ── Sekunder (aksen hijau terang) ──
  static const secondary = Color(0xFF006E2F);
  static const secondaryContainer = Color(0xFF6BFF8F);
  static const onSecondaryContainer = Color(0xFF007432);
  static const onSecondaryFixedVariant = Color(0xFF005321);

  // ── Tersier (biru informasi) ──
  static const tertiary = Color(0xFF005B8C);
  static const tertiaryContainer = Color(0xFF0075B1);
  static const tertiaryFixed = Color(0xFFCCE5FF);
  static const onTertiaryFixedVariant = Color(0xFF004B73);

  // ── Teks & ikon ──
  static const title = Color(0xFF1B2B34);
  static const onSurface = title;
  static const onSurfaceVariant = Color(0xFF3F493F);
  static const subtitle = Color(0xFF4B5563);
  static const hint = Color(0xFF9CA3AF);
  static const icon = Color(0xFF6B7280);

  // ── Garis & pembatas ──
  static const border = Color(0xFFE5E7EB);
  static const outline = Color(0xFF6F7A6E);
  static const outlineVariant = Color(0xFFBECABC);

  // ── Error ──
  static const error = Color(0xFFDC2626);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // ── Status semantik ──
  static const warning = Color(0xFFB45309);
  static const warningSoft = Color(0xFFFEF3C7);
  static const info = Color(0xFF1D4ED8);
  static const infoSoft = Color(0xFFDBEAFE);

  // ── Invers / gelap ──
  static const inverseSurface = Color(0xFF283044);
  static const inverseOnSurface = Color(0xFFEEF0FF);

  // ── Bayangan ──
  static const shadow = Color(0x0A000000);
  static const primaryShadow = Color(0x2615803D);
  static const primaryDisabled = Color(0x9915803D);
}

/// Alias ringkas ke [AppColors] untuk layar yang memakai nama pendek (`C.primary`).
///
/// Dulu didefinisikan di `notifikasi_screen.dart` dan diimpor lintas-fitur.
/// Sekarang tinggal di core agar tidak ada layar yang bergantung ke folder fitur
/// lain hanya demi warna.
class C {
  C._();

  static const surface = AppColors.surface;
  static const surfaceLowest = AppColors.surfaceLowest;
  static const surfaceLow = AppColors.surfaceLow;
  static const surfaceContainer = AppColors.surfaceContainer;
  static const surfaceHigh = AppColors.surfaceHigh;
  static const surfaceHighest = AppColors.surfaceHighest;
  static const onSurface = AppColors.onSurface;
  static const onSurfaceVariant = AppColors.onSurfaceVariant;
  static const outline = AppColors.outline;
  static const primary = AppColors.primary;
  static const primaryContainer = AppColors.primaryContainer;
  static const onPrimary = AppColors.onPrimary;
  static const primaryFixed = AppColors.primaryFixed;
  static const primaryFixedDim = AppColors.primaryFixedDim;
  static const onPrimaryFixed = AppColors.onPrimaryFixed;
  static const tertiary = AppColors.tertiary;
  static const tertiaryContainer = AppColors.tertiaryContainer;
  static const tertiaryFixed = AppColors.tertiaryFixed;
  static const onTertiaryFixedVariant = AppColors.onTertiaryFixedVariant;
  static const error = AppColors.error;
  static const errorContainer = AppColors.errorContainer;
  static const onErrorContainer = AppColors.onErrorContainer;
}
