import 'package:flutter/material.dart';

/// Membagikan pilihan tema (terang / gelap / ikut sistem) ke seluruh aplikasi.
///
/// Pasang DI ATAS MaterialApp (lihat contoh di main.dart) supaya semua
/// halaman bisa mengakses dan mengganti tema.
class ThemeModeScope extends InheritedNotifier<ValueNotifier<ThemeMode>> {
  const ThemeModeScope({
    super.key,
    required ValueNotifier<ThemeMode> notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Versi aman: bernilai null kalau ThemeModeScope belum dipasang.
  static ValueNotifier<ThemeMode>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeModeScope>()?.notifier;

  /// Versi langsung pakai: memberi pesan error yang jelas kalau lupa
  /// memasang ThemeModeScope di atas MaterialApp.
  static ValueNotifier<ThemeMode> of(BuildContext context) {
    final notifier = maybeOf(context);
    assert(
      notifier != null,
      'ThemeModeScope tidak ditemukan. Bungkus MaterialApp dengan '
      'ThemeModeScope di main.dart.',
    );
    return notifier!;
  }
}

extension ThemeModeNotifierX on ValueNotifier<ThemeMode> {
  /// Ganti terang <-> gelap berdasarkan tampilan yang sedang aktif,
  /// jadi tetap benar walaupun mode saat ini masih "ikut sistem".
  void toggle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    value = isDark ? ThemeMode.light : ThemeMode.dark;
  }
}