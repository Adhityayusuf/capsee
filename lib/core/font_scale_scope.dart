import 'package:flutter/material.dart';

/// Pilihan preset ukuran font global Capsee.
enum AppFontSize {
  kecil('Kecil', 0.90),
  normal('Normal', 1.00),
  besar('Besar', 1.15),
  ekstraBesar('Ekstra Besar', 1.25);

  final String label;
  final double scale;

  const AppFontSize(this.label, this.scale);
}

/// Membagikan pilihan ukuran font ke seluruh aplikasi.
///
/// Pasang DI ATAS MaterialApp (bersama ThemeModeScope di main.dart)
/// agar AppText dan AppTheme otomatis memperbarui ukuran teks secara global.
class FontScaleScope extends InheritedNotifier<ValueNotifier<AppFontSize>> {
  const FontScaleScope({
    super.key,
    required ValueNotifier<AppFontSize> notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Versi aman: bernilai null kalau FontScaleScope belum dipasang.
  static ValueNotifier<AppFontSize>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FontScaleScope>()?.notifier;

  /// Versi langsung pakai untuk mengubah ukuran font dari halaman pengaturan.
  static ValueNotifier<AppFontSize> of(BuildContext context) {
    final notifier = maybeOf(context);
    assert(
      notifier != null,
      'FontScaleScope tidak ditemukan. Bungkus MaterialApp dengan '
      'FontScaleScope di main.dart.',
    );
    return notifier!;
  }

  /// Ambil faktor skala aktif (default 1.0 jika scope belum dipasang).
  static double scaleOf(BuildContext context) =>
      maybeOf(context)?.value.scale ?? AppFontSize.normal.scale;
}
